#!/bin/bash
# PreToolUse hook for the finance agent: blocks every email send. The agent runs with
# --dangerously-skip-permissions, and hooks still run in that mode, so this holds even
# if the model ignores CLAUDE.local.md. Shannon sends invoices; the agent prepares them.
input=$(cat)
tool=$(jq -r '.tool_name // ""' <<<"$input")
cmd=$(jq -r '.tool_input.command // ""' <<<"$input")
msg="Blocked: the finance agent cannot send email. Send Shannon the attachment and the exact To/Cc/Subject/body on Telegram, and wait for them to confirm it was sent."
if [[ "$tool" == mcp__* && "$tool" =~ [Ss]end ]]; then echo "$msg" >&2; exit 2; fi
if [[ "$cmd" =~ mcp[-_]email[-_]server && "$cmd" =~ (^|[^a-zA-Z_])send([^a-zA-Z_]|$) ]]; then echo "$msg" >&2; exit 2; fi
exit 0
