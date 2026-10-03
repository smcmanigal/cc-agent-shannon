# Shannon's install

Owner-specific notes for the generic runbook (`docs/azure-vm.md`). This file lives in the private overlay repo `smcmanigal/cc-agent-shannon`, not in cc-agent.

## Repos

- **cc-agent** (shared template): `git@github.com:smcmanigal/cc-agent.git`, cloned at `~/cc-agent`. The VM uses a read/write deploy key named `cc-agent-vm`.
- **Overlay** (this repo): `smcmanigal/cc-agent-shannon`, git dir `~/.cc-agent-overlay.git`, worktree `~/cc-agent`. Deploy key `~/.ssh/cc-agent-owner_ed25519` (write access), ssh alias `github-owner`. Use `ogit` (alias in `~/.bashrc`) for agent data commits.
- **FinanceAgent**: private repo `smcmanigal/FinanceAgent`, cloned at `agents/finance` (ignored by cc-agent). Deploy key `~/.ssh/finance-agent_ed25519`, ssh alias `github-finance`.
- **mcp-email-server**: the Docker image installs Shannon's fork, `github.com/smcmanigal/mcp-email-server`. Keep it public, or other installs can't build.

## Agents

Four: email, sales, finance, master. `.env` sets `COMPOSE_FILE` to include `docker-compose.finance.yml`; `ops/watchdog.env` lists all four. Telegram chat ID `8718536308`.

- **Email:** three accounts: `personal` (shannon@mcmanigal.net, IMAP/SMTP at ECXSystems, port 465), `work` (smcmanigal@efxfs.com, Microsoft 365 OAuth), `gmail` (smcmanigal@gmail.com, Google OAuth). Work needs `save_to_sent = false`. Gmail has no rules.
- **Sales:** HubSpot legacy private app token, read-only scopes (contacts, companies, deals, owners, contacts schema). Add the `.write` scopes for contacts, companies and deals if sales should update records; decide first whether those edits need a 🔐 approval like finance's email sends.
- **Master:** carries the voice line.

## Current host

The **nucbox** (`nucbox-evo-x2`), since 2026-10-03, when the agents moved back from the VM after the 2026-09-22 outage. All four agents, voice and the watchdog run here.

## Session names

`<agent>-shannon-<host>`: `email-shannon-nucbox`, `sales-shannon-nucbox`, `finance-shannon-nucbox`, `master-shannon-nucbox` since 2026-10-03. On a host move, change the host part in `agents/{email,sales,master}/CLAUDE.local.md` and `ops/finance/CLAUDE.local.md`, then rename the four sessions at claude.ai/code (runbook, Moving to another host, step 7). On the VM they'd be `-shannon-vm`.

## Fallback VM

Used 2026-09-22 to 2026-10-03 (nucbox outage). Agents stopped 2026-10-03 (`docker compose down`, watchdog cron removed). HubSpot token added 2026-09-23 with read-only scopes. Finance agent added 2026-09-24.

**Parked since 2026-10-03:** deallocated, OS disk switched to Standard HDD (64 GB, about $3/month, the only charge left), public IP deleted. Its webhook, deploy keys and tailnet entry are kept. To bring it back, follow the runbook's "Moving to another host", step 1 (a parked VM). Use `--subscription 3a4c03d9-4862-413d-af49-4b856936eed9`: the NucBox's az CLI also has a stale cached "Azure subscription 1" from another tenant. The NIC is `cc-agent-vmVMNic`, ip-config `ipconfigcc-agent-vm`.

| | |
|---|---|
| Subscription | Azure subscription 1 (shannon@circumspect.biz), pay-as-you-go |
| Resource group / VM | `cc-agent-rg` / `cc-agent-vm`, West US 3 |
| Size | Standard_D2als_v6, 2 vCPU, 4 GB, ~$59/mo + disk and IP |
| Swap | 4 GB `/swapfile` on the OS disk (no resource disk on this size), swappiness 10, added 2026-10-02 |
| OS | Ubuntu 24.04, user `shannon` (uid 1000), TZ America/Denver |
| Public IP | deleted 2026-10-03 (was 20.25.158.13); NSG rule `ssh-from-home` kept |
| Funnel | `https://cc-agent-vm.taild3a0e3.ts.net` -> port 8787 |

The usual host is the **nucbox** (`nucbox-evo-x2` on the tailnet). Never run both hosts at once.

## Voice

- Twilio number +1 813 441 3956 on secure SIP trunk `openai-voice`, origination URI `sip:proj_wWnNQivx0MsyJ3UdsJou5AAu@sip.api.openai.com;transport=tls`. CLI profile `ShannonTwilio` (twilio-cli via nvm Node 24).
- OpenAI project `proj_wWnNQivx0MsyJ3UdsJou5AAu`: restricted key, budget cap. Webhooks: `https://nucbox-evo-x2.taild3a0e3.ts.net/openai/webhook` (nucbox) and `cc-agent-vm` -> `https://cc-agent-vm.taild3a0e3.ts.net/openai/webhook` (VM). Each has its own signing secret; each host's `channels/voice/.env` holds its own. The nucbox's OpenAI key had stopped working by 2026-10-03 (calls failed with `call.accept_failed` 401 in `channels/voice/logs/events.jsonl` while the test event still got 200) and was replaced.
- `channels/voice/.env` sets `OWNER_NAME=Shannon`.

## Finance agent (Shannon only)

Finance is not part of the template. Its setup, on top of the generic runbook:

1. **Credentials:** the FinanceAgent deploy key (`~/.ssh/finance-agent_ed25519`), or make a new one and add it to `smcmanigal/FinanceAgent` on GitHub.
2. **Repo:** add a `github-finance` host to `~/.ssh/config` (HostName github.com, `IdentityFile ~/.ssh/finance-agent_ed25519`, `IdentitiesOnly yes`), then `git clone git@github-finance:smcmanigal/FinanceAgent.git agents/finance`. The finance container gets no SSH key: it commits, and you review and push from the host (`git -C agents/finance log -p origin/master..master`, then `git -C agents/finance push`). Also `mkdir ~/.claude-agent-finance`.
3. **Email login:** finance has its own login to the work mailbox. `install -d -m 700 ~/.finance-agent-secrets/zerolib`, then in `docker compose run --rm -it --entrypoint bash finance-agent` run `mcp-email-server accounts add-oauth2` (microsoft, device code) with the account name **`EFX Work`** exactly. Then set `enable_attachment_download = true` at the top of its `config.toml` (finance saves timesheet PDFs from email and can't change the setting itself), and `save_to_sent = false`. Check with `mcp-email-server emails list -a "EFX Work" --page-size 3 --json`.
4. **Start it after sales, before master.** Before its first start, create `~/.claude-agent-finance/settings.json` from `ops/finance/settings.json`. Its rules (`ops/finance/CLAUDE.local.md`), the email hook script and `ops/finance/managed-settings.json` (which registers the hook where the agent can't change it) are mounted read-only (see `docker-compose.finance.yml`). The hook sends each EFX Work email send to Shannon on Telegram as a 🔐 approval and blocks every other send. It has no schedules. Test it by asking finance on Telegram to send a test email: you should get the 🔐 message, and after Allow, one copy in Sent Items.
5. **Moving hosts:** review and push finance's commits first. The state bundle adds `.finance-agent-secrets`, `cc-agent/agents/finance/imports` and `cc-agent/agents/finance/exports` (untracked bank CSVs, timesheet PDFs and invoices), and on the new host `git -C agents/finance pull` (clone it as in step 2 if missing). If the bundle went in first, `agents/finance` already holds `imports/` and `exports/` and `git clone` refuses the non-empty folder: move it aside, clone, `cp -an` the old folder's contents back (adds only the git-ignored files), check `git status --short --ignored imports exports`, then delete the old folder. On a host that has never run finance, create `shared/finance/{inbox,outbox}` before its first start; otherwise Docker creates `shared/finance` owned by root and the agent can't write to it.
