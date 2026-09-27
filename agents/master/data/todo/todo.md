# To do

Added 2026-09-22. Shannon is in Tampa 28 Sep – 2 Oct, back around 3 Oct.

## Before Monday 28 Sep
- [ ] **Truck tires:** get prices and book the appointment by Mon 28 Sep. The appointment itself should be in the first few days of Oct, after he's back. Truck: **2023 Ford F-350 Super Duty**, tires **LT245/75R17** (Shannon, 23 Sep). Location: Cedar City, UT. Likes Big O Tires, open to any good deal. Single vs dual rear wheels still unknown.
- [ ] **Contractor payroll during Tampa:** the pay period ends Sat 26 Sep. Timesheets arrive about 26–28 Sep, and the Gusto payroll normally goes out 28–30 Sep while Shannon is travelling. Options: run Gusto from the road, or pay late (e.g. Mon 5 Oct). About $4,000–4,200 (finance-agent, 24 Sep).
- [ ] **Taxes:** if they aren't done, get with the tax advisor to finish them. Telegram reminders are set for Fri 25 Sep and Mon 28 Sep at 9 AM MT; they're session-only, so if master-agent restarts they're lost (asked by phone 24 Sep).
- [ ] **Salary:** contact Phyllis at work about renegotiating salary (changed from Silas by phone, 24 Sep). Telegram reminders are set for Fri 25 Sep and Mon 28 Sep at 9 AM MT, session-only (asked by phone 24 Sep). Private: don't share with other agents.

## After returning (~3 Oct)
- [ ] **Move agents back to local host:** master-agent, sales-agent and email-agent are temporarily running in the cloud because the original host went down. Move all three back to the local host.

## Someday (no date)
- [ ] **Web search on the phone line:** add OpenAI's built-in `web_search` tool to the voice bridge backend model (`/channels/voice/server.ts`, `tools: [ASK_TOOL, END_CALL_TOOL]`), plus an instruction to search the web for general questions and send anything about Shannon's own stuff to master-agent. Requires a voice server restart (drops live calls) and a test call, because it isn't confirmed that the live delegation setup accepts built-in tools. Shannon, 24 Sep: "not now". Options were sent on Telegram (msg 101).
