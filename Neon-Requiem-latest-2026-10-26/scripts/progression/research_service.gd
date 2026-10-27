extends RefCounted
class_name PrototypeResearchService

## Save-safe permanent Influence purchase framework. It records node ranks but
## intentionally does not apply gameplay effects until research nodes are approved.


static func purchase(permanent_state: Dictionary, node_id: String, catalog: Dictionary) -> Dictionary:
	var catalog_check := _find_node(catalog, node_id)
	if not bool(catalog_check.get("ok", false)):
		return {"ok": false, "error": str(catalog_check.get("error", "Research node is unavailable."))}
	var spendable: Variant = permanent_state.get("spendable_influence", 0)
	var ranks_value: Variant = permanent_state.get("research_nodes", {})
	if not _is_nonnegative_integer(spendable) or typeof(ranks_value) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Permanent Influence or research-rank state is malformed."}
	var node: Dictionary = catalog_check["node"]
	var cost := int(node["influence_cost"])
	var max_rank := int(node["max_rank"])
	var rank_value: Variant = ranks_value.get(node_id, 0)
	if not _is_nonnegative_integer(rank_value):
		return {"ok": false, "error": "Saved research rank is invalid."}
	var current_rank := int(rank_value)
	if current_rank >= max_rank:
		return {"ok": false, "error": "Research node is already at maximum rank."}
	if int(spendable) < cost:
		return {"ok": false, "error": "Not enough spendable Influence."}
	for prerequisite_value in node.get("prerequisites", []):
		var prerequisite_id := str(prerequisite_value)
		if int(ranks_value.get(prerequisite_id, 0)) < 1:
			return {"ok": false, "error": "Research prerequisites are not met."}
	var updated := permanent_state.duplicate(true)
	updated["spendable_influence"] = int(spendable) - cost
	var updated_ranks: Dictionary = ranks_value.duplicate(true)
	updated_ranks[node_id] = current_rank + 1
	updated["research_nodes"] = updated_ranks
	return {
		"ok": true,
		"permanent": updated,
		"node_id": node_id,
		"branch_id": catalog_check["branch_id"],
		"previous_rank": current_rank,
		"new_rank": current_rank + 1,
		"influence_spent": cost
	}


static func purchase_and_save(permanent_state: Dictionary, run_state: Dictionary, settings: Dictionary, node_id: String, catalog: Dictionary, save_callable: Callable, save_path: String) -> Dictionary:
	if not save_callable.is_valid() or save_path.strip_edges().is_empty():
		return {"ok": false, "error": "A valid save operation and explicit path are required."}
	var transaction := purchase(permanent_state, node_id, catalog)
	if not bool(transaction.get("ok", false)):
		return transaction
	var save_error: Error = save_callable.call(transaction["permanent"], run_state, settings, save_path)
	if save_error != OK:
		return {"ok": false, "error": "Research purchase could not be committed; no live state was changed.", "save_error": save_error}
	transaction["run"] = run_state.duplicate(true)
	transaction["settings"] = settings.duplicate(true)
	return transaction


static func validate_catalog(catalog_value: Variant) -> Dictionary:
	if typeof(catalog_value) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Research catalog must be an object."}
	var catalog: Dictionary = catalog_value
	var branches_value: Variant = catalog.get("branches", null)
	if typeof(branches_value) != TYPE_ARRAY:
		return {"ok": false, "error": "Research catalog branches are missing or malformed."}

	var seen_branches: Dictionary = {}
	var graph: Dictionary = {}
	for branch_value in branches_value:
		if typeof(branch_value) != TYPE_DICTIONARY:
			return {"ok": false, "error": "Research catalog branch is malformed."}
		var branch: Dictionary = branch_value
		var branch_id_value: Variant = branch.get("id", null)
		var nodes_value: Variant = branch.get("nodes", null)
		if typeof(branch_id_value) != TYPE_STRING or str(branch_id_value).strip_edges().is_empty() or str(branch_id_value).strip_edges() != str(branch_id_value) or typeof(nodes_value) != TYPE_ARRAY:
			return {"ok": false, "error": "Research branch ID or node list is invalid."}
		var branch_id := str(branch_id_value)
		if seen_branches.has(branch_id):
			return {"ok": false, "error": "Research branch IDs must be unique."}
		seen_branches[branch_id] = true
		for node_value in nodes_value:
			if typeof(node_value) != TYPE_DICTIONARY:
				return {"ok": false, "error": "Research catalog node is malformed."}
			var node: Dictionary = node_value
			var id_value: Variant = node.get("id", null)
			var cost_value: Variant = node.get("influence_cost", null)
			var max_rank_value: Variant = node.get("max_rank", null)
			var prerequisites_value: Variant = node.get("prerequisites", [])
			if typeof(id_value) != TYPE_STRING or str(id_value).strip_edges().is_empty() or str(id_value).strip_edges() != str(id_value):
				return {"ok": false, "error": "Research node ID is invalid."}
			if not _is_positive_integer(cost_value) or not _is_positive_integer(max_rank_value) or typeof(prerequisites_value) != TYPE_ARRAY:
				return {"ok": false, "error": "Research node definition is incomplete or invalid."}
			var node_id := str(id_value)
			if graph.has(node_id):
				return {"ok": false, "error": "Research node IDs must be unique across branches."}
			graph[node_id] = []
			var seen_prerequisites: Dictionary = {}
			for prerequisite_value in prerequisites_value:
				if typeof(prerequisite_value) != TYPE_STRING or str(prerequisite_value).strip_edges().is_empty() or str(prerequisite_value).strip_edges() != str(prerequisite_value) or str(prerequisite_value) == node_id:
					return {"ok": false, "error": "Research prerequisites must be other non-empty node IDs."}
				var prerequisite_id := str(prerequisite_value)
				if seen_prerequisites.has(prerequisite_id):
					return {"ok": false, "error": "Research prerequisite IDs must be unique per node."}
				seen_prerequisites[prerequisite_id] = true
				graph[node_id].append(prerequisite_id)

	for node_id in graph:
		for prerequisite_id in graph[node_id]:
			if not graph.has(prerequisite_id):
				return {"ok": false, "error": "Research prerequisite references an unconfigured node."}

	var visiting: Dictionary = {}
	var visited: Dictionary = {}
	for node_id in graph:
		if _research_graph_has_cycle(str(node_id), graph, visiting, visited):
			return {"ok": false, "error": "Research prerequisites must not contain cycles."}
	return {"ok": true}


static func _find_node(catalog: Dictionary, node_id: String) -> Dictionary:
	if node_id.strip_edges().is_empty() or node_id.strip_edges() != node_id:
		return {"ok": false, "error": "Research node ID is invalid."}
	var catalog_check := validate_catalog(catalog)
	if not bool(catalog_check.get("ok", false)):
		return catalog_check
	var branches_value: Array = catalog["branches"]
	var found: Dictionary = {}
	for branch_value in branches_value:
		var branch: Dictionary = branch_value
		for node_value in branch["nodes"]:
			var node: Dictionary = node_value
			if str(node["id"]) == node_id:
				found = {"node": node, "branch_id": str(branch["id"])}
	if found.is_empty():
		return {"ok": false, "error": "Research node is not configured."}
	return {"ok": true, "node": found["node"], "branch_id": found["branch_id"]}


static func _research_graph_has_cycle(node_id: String, graph: Dictionary, visiting: Dictionary, visited: Dictionary) -> bool:
	if visited.has(node_id):
		return false
	if visiting.has(node_id):
		return true
	visiting[node_id] = true
	for prerequisite_id in graph[node_id]:
		if _research_graph_has_cycle(str(prerequisite_id), graph, visiting, visited):
			return true
	visiting.erase(node_id)
	visited[node_id] = true
	return false


static func _is_nonnegative_integer(value: Variant) -> bool:
	return _is_integer(value) and int(value) >= 0


static func _is_positive_integer(value: Variant) -> bool:
	return _is_integer(value) and int(value) > 0


static func _is_integer(value: Variant) -> bool:
	if typeof(value) == TYPE_INT:
		return true
	return typeof(value) == TYPE_FLOAT and is_finite(float(value)) and float(value) == floor(float(value))
