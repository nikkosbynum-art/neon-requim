# Image-generated semantic-part sheet candidates — quarantined

**Status: FAILED INTAKE. Do not use in the runtime project or treat as production rig art.**

These sheets were generated from the approved BREAKER visual/art references and the approved concept/anatomy references for BULWARK, CIPHER, and SPARK. They are exploratory references only. Review found missing/duplicated or ambiguous parts, inconsistent semantic mapping, dark background/halo pixels, and insufficient transparent margins.

The source sheets and cleanup attempt are retained here for comparison. They are not valid cutouts or rig inputs. Mechanical audit results from `tools/art/audit_semantic_cutout.py`:

| Recruit | Candidate | External low-alpha pixels | Minimum measured edge margin | Result |
|---|---|---:|---:|---|
| BREAKER | Candidate 01 | 2,492 | 1.4% | FAIL |
| BREAKER | Cleanup candidate 02 | 646 | 1.1% | FAIL |
| BULWARK | Candidate 01 | 10,881 | 1.5% | FAIL |
| CIPHER | Candidate 01 | 18,126 | 0.9% | FAIL |
| SPARK | Candidate 01 | 13,541 | 0.3% | FAIL |

These audits test alpha/margins only; they do not establish semantic identity, anatomy, pivots, or animation. The image-generation and alpha-cleanup approach was stopped after the cleanup remained outside intake thresholds. Continue with a manually authored, source-preserving cutout workflow and do not repeat the same prompt iteration loop.
