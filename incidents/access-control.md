# access-control

Real case I mapped this to:
- Parity Multisig init bug (July 2017)
- around 153k ETH stolen

What went wrong:
- setup function was public
- attacker could initialize ownership

In this repo:
- vulnerable contract has public `initialize`
- attacker calls it, then withdraws

Fix:
- set owner during deploy
- block re-initialize path
