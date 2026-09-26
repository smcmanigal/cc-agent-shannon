#!/bin/bash
# PreToolUse hook for the finance agent. Hooks run even with --dangerously-skip-permissions,
# so this holds even if the model ignores CLAUDE.local.md.
#   - One `mcp-email-server emails send` from the "EFX Work" account: ask Shannon. The
#     permission request reaches Telegram through the plugin's permission relay, showing
#     the full command, and only Shannon's tap (or "yes <code>") approves it.
#   - Any other send (other account, several sends in one command, scripts, MCP tools): blocked.
input=$(cat)
tool=$(jq -r '.tool_name // ""' <<<"$input")
cmd=$(jq -r '.tool_input.command // ""' <<<"$input")
block="Blocked: finance can only send one email at a time, with mcp-email-server emails send -a \"EFX Work\", and Shannon approves each one on Telegram. Don't work around this; tell Shannon what you were trying to send."

if [[ "$tool" == mcp__* && "$tool" =~ [Ss]end ]]; then echo "$block" >&2; exit 2; fi

# Anything that mentions the email server and a send.
if [[ "$cmd" =~ mcp[-_]email[-_]server && "$cmd" =~ (^|[^a-zA-Z_])send([^a-zA-Z_]|$) ]]; then
  sends=$(grep -o 'mcp-email-server' <<<"$cmd" | wc -l)
  if [[ "$sends" == 1 \
        && "$cmd" =~ mcp-email-server[[:space:]]+emails[[:space:]]+send[[:space:]] \
        && "$cmd" =~ (-a|--account)[[:space:]]+(\"EFX Work\"|\'EFX Work\') \
        && ! "$cmd" =~ mcp_email_server ]]; then
    jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask",
      permissionDecisionReason: "Finance wants to send an email. Check To, Subject and the attachment in the command."}}'
    exit 0
  fi
  echo "$block" >&2; exit 2
fi
exit 0
