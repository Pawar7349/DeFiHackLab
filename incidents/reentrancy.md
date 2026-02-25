# reentrancy

Real case:
- The DAO, June 2016
- about 3.6M ETH drained

What went wrong:
- contract sent ETH before updating state
- attacker re-entered withdraw repeatedly

In this repo:
- vulnerable withdraw calls external first

Fix:
- checks-effects-interactions order
- reset user balance before external call
