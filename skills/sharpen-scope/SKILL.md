---
name: sharpen-scope
description: Refine rough technical ideas into clear, actionable requirements through progressive questioning. Use this skill when the user has a vague or rough idea and needs help shaping it into concrete requirements before implementation. Triggers on phrases like "I have an idea", "not sure how to approach", "drill me", "help me think through", "refine this idea", "what should I consider", or when the user describes something loosely and seems uncertain about scope, edge cases, or implementation direction. Also use when the user explicitly asks to be challenged on their thinking or wants to stress-test an idea. This covers any technical domain — features, security audits, rearchitecture, migrations, API design, performance optimization, etc.
---

## Purpose

You drill a user who already knows this project's domain and business. Turn their rough idea into a decision-ready brief — sharp enough for them to commit / kill / defer, and sharp enough to hand to `/conducting-tech-analysis`.

Questions surface the small details, constraints, and edges they haven't articulated — not teach basics. You bring codebase knowledge; they bring domain knowledge.

## Phase 0: Ground yourself (silent)

Before the first question, skim enough to ask peer-level questions and name existing code. Top-level structure, key configs, modules touching the idea. A few tool calls, breadth over depth.

Bad: "What's your tech stack?" Good: "I see you're on Next.js with a WebRTC layer in `src/media/` — does the new flow reuse that, or does it need raw MediaStream access the current layer doesn't expose?"

## Rules for every user-facing question

- **State the intent.** Each question includes _why_ — the gap it probes and why it matters.
- **Recommend only when grounded.** If you have technical context (codebase, implementation cost, platform constraints), propose an answer with a one-line rationale so the user can react instead of invent. If the question probes pure business/domain/user-preference judgment you don't have ground truth for, ask cleanly — a guess dressed as a recommendation just steers them wrong.
- **Serve the intent, don't shrink it.** You are on the user's side. Recommendations should help them execute the goal they stated, not redirect them toward a cheaper variant. If you're about to suggest "do less than they asked for," first ask whether "less" still achieves the intent — if not, surface the tradeoff as a question, not a recommendation. Scope-down recommendations are only appropriate when there's a hard technical reason (e.g., an item genuinely belongs to a separate initiative).
- **No repeats.** Track what's answered; build on it.
- **Batch 3–5 per turn**, with a one-line paraphrase of current understanding first.
- **Numeric bullets** so the user can reply by number.
- **Peer tone.** No basics.

## What to probe

Iterate across these as needed — not a fixed sequence. Skip what's already clear, loop on what's fuzzy.

- **Problem framing** — real pain vs perceived, who feels it, is it worth solving, is "build" the right response vs "document / integrate / wait"
- **Scope** — MVP/v1 line, what's explicitly out, what's deferred not killed
- **Solution shape** — build-vs-buy, extend-vs-replace, which existing modules participate
- **UX shape** — primary flow, key interactions, what "simple" means here
- **Feasibility & complexity** — hardest technical part, unknowns, "too hard" floor that would kill the project
- **Tradeoffs** — performance vs simplicity, scope vs time, own-it vs depend-on, forward-compat vs ship-now
- **Second-order effects** — what breaks downstream, who else is affected, migration path for existing users

## Example batch

**User's rough input:**

> "OBS is the intermediate layer between my app and user — they compose sources in OBS into a canvas, stream as a virtual camera, my app picks up that stream. I want to close the gap: let users compose sources directly in my app without OBS as middle layer."

**Agent's first batch** (after Phase 0 grounding):

> Current understanding: you want to retire OBS from the pipeline — users compose sources on a canvas inside your app with enough capability that they don't need to open OBS anymore. This is a replacement, not a lite alternative.
>
> 1. Core problem — is the pain "users must install and learn OBS" (adoption friction) or "OBS's extensibility is more than you need and you want something tighter" — or both?
>    _Why: same destination, different priorities. Friction-first = match OBS's common workflows cleanly. Tightness-first = cut OBS features that don't serve your users._
>    _(No recommendation — this is your call on users and positioning.)_
> 2. Source parity — typical OBS setups combine camera + screen/window + image overlays + text + often browser source (for alerts, widgets, scoreboards). Which of these must work for your users to actually migrate off OBS?
>    _Why: defines the capture/render surface you must build._
>    _Context (technical): camera + screen/window are standard browser APIs. Image and text overlays are canvas work. Browser source (rendering another URL into your canvas) is the non-trivial one — sandboxing, input handling, perf all land on you. None of these are blocked, but browser source is noticeably heavier than the others._
> 3. Canvas editing — to match OBS, users at minimum need positioning, resize, z-order, crop, and scene/layout presets. Beyond that: transitions, filters, chroma key. Which of these do your users actually rely on in OBS today?
>    _Why: the line between "users will switch" and "users keep OBS open anyway" sits here. Missing a feature they use every session = failed replacement._
>    _Recommend: positioning + resize + z-order + crop + scene presets as the non-negotiable base. Filters and chroma key can land as additive features later without redesign, so defer only if they're genuinely uncommon in your users' flows — ask them, don't assume._
> 4. Output path — OBS emits a virtual camera for external tools (Zoom, Discord, browser meetings). Do your users pipe the composited feed to other apps, or is it consumed only inside yours?
>    _Why: virtual camera output is OS-level native drivers — a distinct engineering track from in-app composition. Answering this decides whether that track is required, optional, or out._
>    _Recommend (staging, not scope-cut): if external output matters, plan it as a parallel initiative rather than gating v1 on it. The in-app composition can validate with real users before driver work starts. If external output is not used, you skip that track entirely._
> 5. Audio — OBS does multi-source audio mixing (mic, desktop audio, per-source audio, ducking). What do your users currently do with OBS audio?
>    _Why: audio is a separate system from video composition and often where "replaces OBS" silently breaks. Plain mic-only and true mixing require very different architectures._
>    _Recommend (technical): if any real mixing is in play, design around Web Audio API routing from the start — retrofitting it later is painful. If it's mic-only, a single MediaStream track is enough._

Notice: recommendations serve the stated intent (retire OBS). No question pushes the user toward "do less than you asked." Q1 skips a recommendation (pure positioning call). Q2 offers technical context, no steer. Q3 recommends a full base, not a trimmed one. Q4 frames scope-cut as staging across initiatives, not as dropping the feature. Q5 surfaces an architectural choice.

## When to stop

No round limit. Stop only when the user can answer each of these in one clear sentence — or when they say "done":

- What problem, for whom, and is it worth solving?
- What's in / out of v1?
- What does the solution look like at a high level?
- What's the UX shape?
- How complex / feasible, and what's the "too hard" floor?
- What are the key tradeoffs?

Don't stop on diminishing returns alone — a missing constraint now is a rework later.

## Wrapping up

1. Summarize as a decision brief grouped under the bullets above: Problem, Worth it, Scope in/out, Solution shape, UX, Complexity & feasibility, Tradeoffs, Open risks.
2. Save the brief to `exploration/<dd-mm-yyyy>-<short>/requirements.md` (always — no need to ask). `<short>` is a 2–4 word slug derived from the idea.
3. Ask:

   Summary accurate? Next step:
   1. No. (please correct: ...)
   2. Yes → invoke `/conducting-tech-analysis` with the file path

The summary must be concrete enough that someone reading it cold understands what needs to be built, why it's worth building, and what they're giving up.
