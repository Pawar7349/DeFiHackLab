# upgrade-misconfig

Real case:
- Wormhole white-hat incident, Feb 2022
- uninitialized UUPS path showed full takeover risk

What went wrong:
- upgrade/init controls were not locked correctly

In this repo:
- vulnerable implementation can be initialized by attacker via proxy
- attacker upgrades to malicious logic and drains funds

Fix:
- one-time initializer guard
- strict owner-only upgrade path
