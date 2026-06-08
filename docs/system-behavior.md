# System Behavior

Canonical agent-facing behavior lives in:

```text
skills/_shared/system-behavior.md
```

That file is read by HARE Trail skills before their workflow-specific instructions.

This docs page exists for human navigation: system behavior is not just documentation. It is part of the reusable skill contract and should be changed with the same care as workflow files.

## Summary

HARE Trail behavior is based on these reusable rules:

- preserve the path of work, not only final outputs;
- keep artifacts human-readable first and agent-readable second;
- prefer inspectable files over opaque runtime memory;
- keep source boundaries visible;
- verify important claims;
- treat debriefs and lessons as calibration tools;
- keep local preferences in data repos, but promote reusable improvements through issue/PR discussion.

See `skills/_shared/system-behavior.md` for the full contract.
