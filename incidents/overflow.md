# overflow

Real case:
- Beauty Chain (BEC), April 2018
- overflow bug in token math

What went wrong:
- multiplication wrapped around
- balance check got bypassed

In this repo:
- vulnerable contract uses `unchecked`
- attacker gets tokens without proper debit

Fix:
- use checked math
- validate transfer totals
