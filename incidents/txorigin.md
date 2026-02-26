# txorigin

Real pattern:
- phishing style drains where auth used `tx.origin`

What went wrong:
- `tx.origin` is original EOA for whole tx
- malicious middle contract can still pass checks

In this repo:
- vulnerable contract uses `tx.origin == owner`

Fix:
- use `msg.sender` for auth
- make trusted caller paths explicit
