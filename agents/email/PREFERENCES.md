# Email Preferences

Learned preferences from Shannon. One per line.

- Auth failures (OAuth token revoked, e.g. after password change): when detected, append a reminder to the next routine notice/report sent to Shannon — "ACCOUNT X needs reauth, reply when ready." Don't generate a device code until she signals she's at a browser. When she responds ready, immediately issue a fresh code/link and explicitly call out the ~15-minute code expiry window.
