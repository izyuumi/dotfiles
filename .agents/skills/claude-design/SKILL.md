---
name: claude-design
description: >-
  Use Claude Design through Claude Code before implementing new screens,
  redesigns, substantial layout, styling, or UX changes, visual explorations,
  or prototypes. Skip small mechanical UI edits such as changing text, fixing
  a constraint, renaming a button, or adjusting a single value.
---

# Claude Design

Use Claude Code's native Claude Design capability for visual and interaction
design before implementing substantial UI/UX work in the project's existing
technology stack.

## Workflow

1. Open Claude Code in the relevant project. Confirm that the current execution
   mode can invoke native `/design`; do not assume that sending `/design` as
   ordinary prompt text invokes the capability.
2. Give Claude Code the complete UI/UX task and relevant project context,
   including user requirements, target platform, existing stack, and references.
   Have it inspect the application's components, styles, architecture, and
   platform conventions before designing.
3. If an existing supported design system can be synchronized, use
   `/design-sync` before `/design`.
4. Instruct Claude Code to use native `/design` to create or iterate on the
   design. Inspect the resulting design artifact and iterate until it satisfies
   the user's requirements.
5. Tell Claude Code to implement the resulting design in the actual application:
   SwiftUI/UIKit as appropriate for Swift projects, the existing React stack for
   React projects, or the corresponding native stack for other projects.
   Preserve the design's visual and interaction intent using existing components
   and platform conventions.
6. Run the project's normal build/tests after implementation. Report the design
   artifact, implementation, and verification results, including any limitations.

## Capability and stack boundaries

- The Claude Design prototype is a design artifact, not an instruction to replace
  the application's native technology with HTML.
- Use the real Claude Design capability when available; generic HTML generation
  is not a substitute for invoking it.
- If Claude Code or native `/design` cannot be invoked in the current execution
  mode, report that limitation and the unfinished design step. Never claim
  Claude Design was used without evidence that it ran.
