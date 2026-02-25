# signature-replay

Real pattern:
- signed claim/permit messages reused multiple times
- happened across token/NFT projects

What went wrong:
- missing replay protection
- nonce/domain binding not enforced

In this repo:
- vulnerable contract accepts same signature again and again

Fix:
- include nonce + contract + chain in signed payload
- store used digest/nonce
