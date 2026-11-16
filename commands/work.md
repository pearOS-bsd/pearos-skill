---
description: Work on a pearOS task unattended (overnight loop): search first, do what Apple does, test on the VM, CI, docs, commit, repeat until done
argument-hint: "[task | resume]"
---
Load the `pearos` skill (read STATE.md, RULES.md, MACHINE.md, TOOLS.md, WORKFLOW.md). Use caveman style for your own chatter.

Task: $ARGUMENTS   (empty or "resume" = continue "Active", else the first "Next" item of STATE.md)

Run the loop of WORKFLOW.md until the definition of done is met:
search first → Apple's real behaviour → small step → test on the VM → CI → docs + skill → commit/push (no Claude trailer) → next step.
After each milestone update STATE.md. When not finished, schedule the next tick with ScheduleWakeup (20–30 min, same prompt: `/work resume`). When finished or blocked on the user: write the result/question in STATE.md, set `ACTIVE: none`, send a one-line notification, stop the loop.
Never stop to ask unless the decision is the user's (RULES 15). Report honestly what was not verified.
