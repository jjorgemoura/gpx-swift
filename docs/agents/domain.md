# Domain Docs

Synced from `ios-platform` (`platform/templates/sync/`). Edit it there, not here.

How the engineering skills should read this repo's domain documentation before exploring the
code.

## Before exploring, read these

- **`GLOSSARY.md`** at the repo root: the terms of this repo's domain (for example a track,
  a waypoint, a FIT message).
- **ADRs** in `decisions/` of `jjorgemoura/ios-platform`: read the ones that touch the area
  you are about to work in.
- **Standards** in `standards/` of `jjorgemoura/ios-platform`: the rules in force, each with an
  ID (`TEST-3`) to cite.

ADRs and standards are central: there is no `docs/adr/` in this repo. Read them from a local
clone at `~/Developer/myProjs/ios-platform` when there is one, otherwise from GitHub:

```
gh api repos/jjorgemoura/ios-platform/contents/decisions --jq '.[].name'
gh api repos/jjorgemoura/ios-platform/contents/decisions/<file> -H "Accept: application/vnd.github.raw"
```

If `GLOSSARY.md` does not exist yet, proceed silently. `/domain-modeling` (reached through
`/grill-with-docs` and `/improve-codebase-architecture`) creates it the first time a term
actually gets resolved.

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis,
a test name), use the term as defined in `GLOSSARY.md`. Don't drift to synonyms the glossary
explicitly avoids.

If the concept you need isn't in the glossary yet, either you are inventing language the
project doesn't use (reconsider) or there is a real gap (note it for `/domain-modeling`).

## Recording decisions

A new decision is an ADR in `jjorgemoura/ios-platform`, even when it only affects this repo
(see `decisions/README.md` there). Don't write ADRs in this repo.

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently
overriding it:

> _Contradicts ADR-0007 (swift-format), but worth reopening because…_
