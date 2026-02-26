# oracle

Real case:
- Mango Markets, Oct 2022
- around $110M drained

What went wrong:
- protocol trusted manipulable spot price

In this repo:
- vulnerable vault reads price from local AMM spot
- attacker moves price then withdraws

Fix:
- do not use raw spot price for critical accounting
- use stronger oracle design (TWAP / bounds / multiple feeds)
