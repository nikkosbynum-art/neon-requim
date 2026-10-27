# I-04c — Twelve-recruit ability contract packet

**Status:** Complete for provisional playtest implementation — 2026-10-26 America/Chicago.  
**Decision authority:** Under the owner's standing authorization to select supported recommendations, the rules below are selected as owner-delegated playtest defaults. They are explicitly provisional, non-canon, and do not approve release balance, character canon, art, or production effects. The user selected all-twelve sequencing before any ability implementation.  
**Readiness:** All twelve simulation contracts are ready for implementation behind a configurable trial profile. ECHO's abstract gameplay decoy is ready; mapping that decoy to authored devices, art, or the approved air lane remains gated by source/Character decisions.

## Source and verification provenance

Skill labels are retained from the local roster reconstruction and the recorded Founding Recruit Roster fetch (2026-10-26T03:12:07.445Z; verification.state=unverified). The reconstruction is explicitly non-verbatim. Local roster gap audit docs/I-06A_ROSTER_GAP_AUDIT.md reports that only BREAKER has an individual combat definition, all twelve use generic actors/stats or placeholders, and no recruit ability currently executes gameplay.

I-05 hybrid combat and the existing playable combat slice have since passed focused and full Godot verification, as recorded at the top of docs/IMPLEMENTATION_STATUS.md. The ability-resolved event hook is transport only until an ability commits an authoritative effect.

## Shared ability execution contract — selected playtest defaults

- Each living deployed recruit checks its one signature ability at simulation action boundaries when its configured cooldown is ready and its eligibility predicate passes. Activation and target choice remain automatic. No manual trigger, target override, or per-target command is added.
- An ability gets one check at the actor's normal action boundary. If it commits, the actor does not begin a second ordinary action in that same boundary; if the ability is ineligible or cannot commit, ordinary behavior continues. Use the normal automatic target policy where a skill-specific rule is not listed, using existing ordinary attack target legality/range and stable actor ID for trial tie-breaks. Squad-wide support and ECHO's logical decoy are not restricted to weapon range. Revalidate targets immediately before commit. With no legal target, stay ready without cost/cooldown, except for CIPHER's explicit ordinary-shot fallback.
- Abilities use no separate resource. Cooldown starts at the first committed effect. Each ability has one configurable cooldown; its numeric duration is a playtest value, not canon.
- Apply gameplay effects to authoritative simulation state first, then emit the ability-resolved presentation event. Attack damage within an ability follows the active combat mode, including I-05 per-committed-attack hybrid resolution.
- A candidate invalidated before commit cancels without effect or cooldown. A committed action resolves atomically and is not interrupted mid-commit. This is the selected test default; the existing I-03 rule to finish the current ability before regrouping also applies.
- Temporary effects use simulation time, do not stack by magnitude, and refresh their own expiry when reapplied. Clear temporary effects and cooldowns at encounter end (victory, defeat, or retreat). If a source is defeated before commit, cancel its pending action; if it is defeated after commit, finish the committed effect. Target-bound effects clear when their target is defeated and never transfer to another target.
- A committed ability that changes HP or effective combat state reports qualifying progress through the I-05 hook. Presentation-only cues, props, drones, and decoys do not independently change combat state or reset progress timers.
- The trial adds no new passive, synergy, or equipment-derived combat modifier beyond the effect fields explicitly listed in each contract. Existing character stats remain the supplied base inputs; weapons, implants, drones, decoys, and other attachments do not independently act from presentation. Ability action order follows the combat director's existing deterministic actor/action order, and fixed-step actions resolve before timer checks.
- Values such as thresholds, damage, durations, and target limits live in a clearly labeled configurable trial profile. Their profile values remain provisional and are not defined as canon here.

## Per-recruit contracts

### BULWARK — Last Protocol

- **Check/target:** At an action boundary, if at least one living deployed ally, including BULWARK, is at or below the configured emergency-health ratio, select every living deployed ally at or below that ratio. If none qualify, remain ready.
- **Effect:** Restore the configured flat HP amount to each selected ally, capped at max HP. The trial does not revive defeated allies.
- **Commit/lifecycle:** Revalidate recipients at commit; if none remain, remain ready. Healing is immediate. Emit the authoritative heal result, then the presentation cue. Start cooldown on the batch commit. Cooldown/temporary effects clear at encounter end.

### BREAKER — Redline

- **Check/target:** Attach to BREAKER's next valid automatic fist attack when its attack action becomes eligible. If there is no legal attack target, remain ready.
- **Effect:** Apply the configured Redline damage multiplier before I-05 resolves that committed attack. After the attack commits, apply a temporary self status that increases BREAKER's attack interval by a configured amount. This is a provisional operational meaning for neural strain.
- **Commit/lifecycle:** If the attack is invalid before commit, do not spend Redline or apply strain. Once the attack commits, finish its resolution, apply strain, emit the event, and start cooldown. Strain expires on its configured simulation timer or encounter end.

### CIPHER — Ghost Round

- **Check/target:** At an action boundary, select the nearest living enemy with the trial-profile flag for functional cyberware; break equal-distance ties by stable actor ID. Revalidate before commit.
- **Effect:** Commit one precision-rifle attack and disable the target's configured cyberware-derived combat modifier until encounter end. If no eligible cyberware target exists, or it becomes invalid before commit, use the ordinary automatic precision target and commit an ordinary precision attack; this consumes Ghost Round. This preserves the owner-selected fallback.
- **Commit/lifecycle:** If there is no ordinary legal attack target either, remain ready. Cooldown starts when either the disruption shot or fallback shot commits. The owner-selected exception consumes no separate resource.

### SPARK — Scrap Swarm

- **Check/target:** At an action boundary, require at least one living enemy. Resolve the source-defined three attack drones as three sequential attack sub-actions. The first uses the normal automatic target selector; if that target is defeated, retarget the next nearest living enemy for the next drone.
- **Effect:** Each drone commits one configured attack independently, with I-05 applied per committed attack. No independent combat actors or autonomous paths are created by this trial rule.
- **Commit/lifecycle:** The swarm commits when its first drone attack commits; start cooldown then. Stop remaining sub-actions if no legal target remains. Emit one authoritative attack result per committed drone sub-action, then route the three presentation events. No target at activation means remain ready. Drone presentation clears at encounter end.

### SPECTER — Null Trace

- **Check/target:** At an action boundary, select the living enemy with the highest configured I-05 effective-power score; break ties by stable actor ID. This is the provisional definition of “priority.”
- **Effect:** Commit a configured priority-strike attack, then apply a temporary cloak state. While cloaked, enemy automatic targeting excludes SPECTER if another living ally is eligible; if SPECTER is the only eligible ally, it can still be targeted. This is the provisional gameplay meaning of “cloaked,” not a canon rule.
- **Commit/lifecycle:** If the strike target is invalid before commit, remain ready. Cloak ends on its simulation timer or encounter end; cooldown starts when the strike commits. The strike and cloak are authoritative before their presentation cues.

### IRONCLAD — Lockdown

- **Check/target:** At an action boundary, select the nearest living enemy using the normal automatic target policy.
- **Effect:** On commit, anchor IRONCLAD by preventing movement for a configured duration and suppress that enemy by reducing its attack power for a configured duration. This is the provisional operational definition of “anchor and suppress.”
- **Commit/lifecycle:** If the enemy is invalid before commit, remain ready. Target defeat clears suppression; the anchor expires on its timer or encounter end. Cooldown starts on commit. Apply both simulation statuses before emitting the Lockdown event.

### STITCH — Black Market Cocktail

- **Check/target:** At an action boundary, if any living deployed ally is below a configured heal threshold, select the living ally with the lowest HP ratio; break ties by stable recruit/slot order. If none qualify, remain ready.
- **Effect:** Heal the selected ally by a configured amount, apply a configured attack boost to living deployed allies, and apply a temporary attack-interval penalty to STITCH as the instability cost. These are provisional gameplay meanings for the source-named components.
- **Commit/lifecycle:** Revalidate the selected ally at commit; if invalid and no other eligible ally exists, remain ready. Apply the three effects atomically and emit the result. Effects expire on configured simulation timers or encounter end; cooldown starts on commit. No healing revives a defeated recruit.

### RECOIL — Breach Charge

- **Check/target:** At an action boundary, select the normal automatic target first, then order the remaining living enemies by the same deterministic automatic target policy. No physical front-line rank or spatial path is inferred.
- **Effect:** Commit a charge attack against the selected target sequence, attacking each living enemy once up to a configurable target limit. The trial charge does not change authoritative world position; movement is presentation only.
- **Commit/lifecycle:** Revalidate each target before its sub-action and skip invalid targets. If the initial target is invalid, remain ready. The ability commits with its first attack; cooldown starts then. Stop if no legal targets remain. Apply attack resolution in sequence before emitting the committed charge results.

### ECHO — Signal Cascade

- **Check/target:** At an action boundary, require at least one living enemy. Create one logical decoy token for this playtest profile; it is not assigned to a physical device, art piece, or attachment.
- **Effect:** Register the token as a separate eligible target that enemy automatic targeting prefers over living recruits while it remains active. Enemy attacks consume its configured durability. It is not a recruit, does not count toward squad defeat, and does not itself attack.
- **Commit/lifecycle:** The ability commits when the decoy token is registered; cooldown starts then. Remove the token when its durability is exhausted, its timer expires, or the encounter ends. Emit the authoritative token state before presentation. The rule is gameplay-ready with abstract presentation; ECHO device identity/count, drone/decoy mapping, and air-lane art/attachment integration remain unresolved and gated.

### VECTOR — Slipstream

- **Check/target:** At an action boundary, select living enemies in nearest-first order, with stable actor ID as tie-break. Continue until the configured target limit or no unvisited legal targets remain.
- **Effect:** Commit one attack per selected target as a single Slipstream sequence. The trial does not change authoritative actor position; the dash path is represented by presentation following the committed target sequence.
- **Commit/lifecycle:** Revalidate each target before its strike and skip invalid targets. If no target remains at initial commit, remain ready. Cooldown starts on the first committed strike; stop if the target list is exhausted. Emit results after simulation resolves the sequence.

### DEADLOCK — System Break

- **Check/target:** At an action boundary, eligible enemies must have a functional-implant trial-profile flag. Select the enemy with the highest configured implant-strength field; break ties by stable actor ID. With no eligible target, remain ready.
- **Effect:** Disable all configured implant-derived combat modifiers on the selected target until encounter end. This is a bounded trial definition of “disables strongest enemy implant.”
- **Commit/lifecycle:** Revalidate the implant before commit. If it is no longer functional, remain ready without cooldown. Cooldown starts on successful disable commit. Target defeat or encounter end clears the status. Emit the authoritative disable state before its presentation cue.

### GLITCH — Frame Skip

- **Check/target:** At an action boundary, require at least two living enemies and a ready automatic attack. If only one enemy exists, remain ready rather than consume a target-switching burst with no alternative.
- **Effect:** For a configured burst duration, re-evaluate the automatic target after each committed attack and choose the nearest living enemy different from the previous target when one exists. If no alternative remains, keep the current legal target. This is the provisional meaning of accelerated target switching.
- **Commit/lifecycle:** Finish the current attack before starting the burst; no attack is interrupted. Cooldown starts when the burst commits. Restore ordinary target selection when its simulation timer expires or the encounter ends. Emit each attack event before any corresponding target-change presentation event.

## Readiness and remaining gate

- **Ready for implementation under owner-delegated trial defaults:** BULWARK, BREAKER, CIPHER, SPARK, SPECTER, IRONCLAD, STITCH, RECOIL, VECTOR, DEADLOCK, and GLITCH.
- **Ready for simulation implementation; presentation/attachment integration gated:** ECHO. Its abstract decoy token is specified without asserting device count or mapping. Do not attach it to visual devices, author lane transforms, or run count-dependent attachment tests until Character/source evidence resolves the mapping.
- Values in trial profiles remain configurable feasibility inputs, not owner-approved release balance. The roster source remains non-verbatim/unverified. This packet does not decide final character lore, art, weapon/cyberware source details, or production behavior.
- The earlier scope instruction required all twelve contracts before any skill implementation. This packet completes that design handoff under the owner-delegated playtest selection. Implementation still owns runtime changes and focused tests; this Design task made none.
