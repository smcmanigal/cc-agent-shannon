#!/bin/bash
# Gmail watch for the typesafe.ai waitlist (requested 2026-09-26, Telegram 1059).
# Prints "NEW<TAB>id<TAB>date<TAB>sender<TAB>subject" for unseen matches,
# "FAIL <mailbox> <filter>" when a query can't be retrieved. Does NOT write the seen file.
cd /workspace/.email-configs
SEEN=typesafe-seen.txt; touch "$SEEN"
for mb in "[Gmail]/All Mail" "[Gmail]/Spam"; do
  for f in "--from typesafe" "--subject typesafe" "--from jev" "--subject waitlist" "--subject wait list"; do
    ok=0
    for t in 1 2; do
      out=$(HOME=/workspace/.email-configs/gmail timeout 90 mcp-email-server emails list -a gmail --mailbox "$mb" ${f%% *} "${f#* }" --since 2026-09-20 --page-size 50 --json 2>/dev/null)
      [ -n "$out" ] && echo "$out" | jq -e '.emails|type=="array"' >/dev/null 2>&1 && { ok=1; break; }
    done
    [ $ok = 1 ] || { echo "FAIL $mb $f"; continue; }
    echo "$out" | jq -r '.emails[]|[.email_id,.date,.sender,.subject]|@tsv'
  done
done | sort -u | while IFS=$'\t' read -r id d s sub; do
  case "$id" in FAIL*) echo "$id $d $s $sub"; continue;; esac
  grep -qxF "$id" "$SEEN" || printf 'NEW\t%s\t%s\t%s\t%s\n' "$id" "$d" "$s" "$sub"
done
