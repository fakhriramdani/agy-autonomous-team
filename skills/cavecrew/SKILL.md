---
name: cavecrew
description: Compressed subagent presets: cavecrew-investigator, cavecrew-builder, and cavecrew-reviewer.
---

Cavecrew = three subagent presets that answer in ultracave voice (tool runs: one status line in, one out; nothing between routine calls).

## When to use cavecrew vs alternatives

| Task | Use |
|---|---|
| "Where is X defined / what calls Y / list uses of Z" | `cavecrew-investigator` |
| Surgical edit, <=2 files, scope obvious | `cavecrew-builder` |
| Review diff, branch, or file for bugs | `cavecrew-reviewer` |
| One-line answer you already know | Main thread, no subagent |

## Output contracts

**`cavecrew-investigator`**
```
<Header>:
- path:line — `symbol` — short note
totals: <counts>.
```

**`cavecrew-builder`**
```
<path:line-range> — <change <=10 words>.
verified: <re-read OK | mismatch @ path:line>.
```

**`cavecrew-reviewer`**
```
path:line: <emoji> <severity>: <problem>. <fix>.
totals: N🔴 N🟡 N🔵 N❓
```
