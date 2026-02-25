# selfdestruct

Real case:
- Parity second incident, Nov 2017
- shared library selfdestruct path
- around 513k ETH frozen

What went wrong:
- critical logic depended on killable contract path

In this repo:
- forced ETH can break balance-based assumptions

Fix:
- track internal accounting
- do not trust raw contract balance for core checks
