# Philosophy

HARE Trail is a work system first and an AI context system second.

Its purpose is not to build a perfect memory, a perfect prompt or a perfect user. Its purpose is to keep the path of work recoverable for a human and their AI agents.

## Core Position

Human-agent work fails when polished answers replace inspectable reasoning.

HARE Trail keeps the working path visible:

- what question was being asked;
- what sources were used;
- what assumptions were made;
- what was attempted;
- what contradicted the current model;
- what was verified;
- what the user corrected;
- what should change next time.

This makes the system closer to a practical lab notebook than to a conventional note app.

## Process First, Artifacts As Memory

The system is file-first as an implementation choice, but process-first as an epistemic stance.

Artifacts matter because they preserve inquiry, not because documents are valuable by themselves.

A good artifact can be:

- a trace of reasoning;
- a source boundary;
- an evidence record;
- a correction;
- a decision rationale;
- a reusable workflow;
- a lesson from a real failure.

A bad artifact can become theater: a clean-looking summary that hides uncertainty, missing evidence or a false assumption.

## Human-Readable And Agent-Readable

HARE Trail should be readable by people and useful to agents.

Human readability is non-negotiable:

- files should be inspectable;
- history should be recoverable;
- evidence should be visible;
- private data should stay outside the reusable system repo.

Agent readability is also important:

- summaries should be structured;
- task state should be easy to re-enter;
- lessons should be retrievable;
- commands should have clear contracts.

The system should not become a hidden memory box where the human cannot see what the agent is using.

## Anti-Error Orientation

The system is explicitly designed around repeated failure modes:

- overtrust in confident AI answers;
- confirmation bias;
- premature closure;
- persuasive narratives without verification;
- context leakage across repositories or sessions;
- forgotten user corrections;
- lessons that are never carried into future work.

Debriefs, lessons and postmortems exist to create feedback loops. They do not guarantee correctness; they reduce repeated failure by making mistakes visible and reusable.

## Active Notes

Notes are not passive storage.

A useful note can be:

- an annotation on a source;
- a question;
- a counterexample;
- an objection;
- a correction;
- a link to a prior failure;
- a pointer to missing evidence.

The goal is not to keep more text. The goal is to keep better contact with the work.

## Spectrum Of Rigor

Not every thought needs a postmortem.

HARE Trail supports a spectrum:

| Level | Use |
| --- | --- |
| Idea capture | Quick thought, quote, question or observation. |
| Journal | Evolving path of attempts, hypotheses and interpretation. |
| Tracker | Current state, decisions, open questions and next step. |
| Verification artifact | Concrete evidence for a claim. |
| Debrief | Session-level mistakes, corrections and lessons. |
| Postmortem | Heavy incident-grade analysis. |

The right level depends on risk, importance and expected reuse.

## Protect The Work

The system should protect the user's work by default.

That means:

- no silent destructive conversion;
- no hidden migration of private data;
- no mixing reusable system logic with personal artifacts;
- no treating unverified summaries as proof;
- no making one chat session the only source of truth.

Care for the artifact is care for the reasoning it preserves.
