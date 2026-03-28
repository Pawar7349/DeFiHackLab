# DeFiHackLab 🔐

> Reproducing real-world DeFi exploits in Solidity  vulnerable contract, attack simulation, and secure fix for each incident. Built to understand how major hacks happened at the code level.

[![Tests](https://img.shields.io/badge/Tests-26%20passing-brightgreen)](https://github.com/Pawar7349/DeFiHackLab)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.24-blue)](https://soliditylang.org)
[![Built with Foundry](https://img.shields.io/badge/Built%20with-Foundry-FF6B6B)](https://foundry.sh)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI](https://img.shields.io/badge/CI-passing-brightgreen)](https://github.com/Pawar7349/DeFiHackLab/blob/main/.github/workflows/forge-tests.yml)

---

## Why I Built This

Reading about reentrancy is one thing. Writing the attacker contract, watching it drain the vault in a test, then fixing it  that's a different level of understanding.

I built this lab because I wanted to go beyond knowing *that* these bugs exist and actually understand *how* they work at the EVM level. Every module here starts with a real incident, reproduces the exploit in Solidity, and ends with a working fix and tests that prove it.

---

## What's Inside

9 exploit modules. Each one has:
- A **vulnerable contract** : — the buggy code
- An **attacker contract**  : — the exploit
- A **fixed contract**      : — the patched version
- **Tests**                 : — that prove both the exploit works and the fix holds
- An **incident note**      : — linking back to the real event

I simulate attacks using Foundry tests and fork-based reproduction where applicable.

| Module | Real Incident | Loss |
|---|---|---|
| Integer Overflow | Beauty Chain (2018) | Unlimited mint |
| Reentrancy | The DAO (2016) | $60M |
| Access Control | Parity Wallet init bug (2017) | $30M frozen |
| tx.origin Misuse | Phishing pattern | Auth bypass |
| Selfdestruct | Parity Library kill (2017) | $150M frozen |
| Oracle Manipulation | Mango Markets (2022) | $117M |
| Governance Attack | Beanstalk (2022) | $182M |
| Signature Replay | Replayable signed actions | Fund drain |
| Upgrade Misconfiguration | Wormhole UUPS risk (2022) | Takeover risk |

---

## Exploit Modules

### 1. 🔢 Integer Overflow — Beauty Chain (2018)

Solidity <0.8 arithmetic wraps silently. Multiplying two large `uint256` values overflows back to zero  letting attackers mint unlimited tokens from nothing.

```solidity
// VULNERABLE — overflows to 0, then adds 0 to balance
uint256 amount = _value * 2**255;
balances[msg.sender] += amount;
```

**Fix:** Solidity ^0.8 reverts on overflow by default. For older code, use OpenZeppelin `SafeMath`.

---

### 2. 🔄 Reentrancy — The DAO (2016)

The contract sent ETH before updating the sender's balance. An attacker's fallback function recursively called `withdraw()` before the balance was ever decremented  draining the entire vault.

```solidity
// VULNERABLE — state update comes after the external call
(bool success,) = msg.sender.call{value: amount}(""); // ← attacker re-enters here
balances[msg.sender] -= amount;                        // ← never reached
```

```solidity
// FIXED — state first, then interaction
balances[msg.sender] -= amount;
(bool success,) = msg.sender.call{value: amount}("");
```

This is the bug that caused Ethereum to hard fork. The fix is three words: Checks-Effects-Interactions.

---

### 3. 🔑 Access Control — Parity Wallet (2017)

The shared library contract's `initWallet()` had no access control — no check for whether it had already been initialized. Anyone could call it, claim ownership, then call `kill()`. One person did exactly that, and $150M worth of ETH was frozen with no recovery path.

**Fix:** Use OpenZeppelin's `initializer` modifier, or manually check `owner == address(0)` before allowing initialization.

---

### 4. 🧾 tx.origin Misuse — Phishing Pattern

`tx.origin` is always the original EOA — not the immediate caller. A malicious contract in the middle of a call chain can use this to impersonate the user who triggered the transaction.

```solidity
// VULNERABLE
require(tx.origin == owner); // passes even if called through a malicious contract
```

**Fix:** Use `msg.sender`. Never use `tx.origin` for access control.

---

### 5. 💣 Selfdestruct — Parity Library Kill (2017)

A publicly callable `kill()` function on a shared library. One accidental call destroyed the library that hundreds of multisig wallets depended on — freezing all their funds permanently with no upgrade or recovery path.

**Fix:** `selfdestruct` should either not exist, or be locked behind strict multi-sig access control. In modern contracts, avoid it entirely where possible.

---

### 6. 📈 Oracle Manipulation — Mango Markets (2022)

An attacker pumped the price of MNGO tokens on a thin on-chain market using their own capital, then used the inflated token balance as collateral to borrow against — draining the entire protocol treasury.

The core issue: the protocol trusted a spot price that could be moved in a single transaction.

**Fix:** Use time-weighted average prices (TWAP) or external feeds like Chainlink. Spot prices from low-liquidity pools are trivially manipulable within one block.

---

### 7. 🏛️ Governance Attack — Beanstalk (2022)

Beanstalk let flash-loan-acquired tokens vote immediately, with no timelock on execution. An attacker borrowed enough to hold a supermajority, voted on their own malicious proposal, and executed it — all in one atomic transaction.

```
Flash loan → Hold majority → Vote → Execute → Drain treasury → Repay loan
```

This entire chain happened in a single transaction. No waiting period. No one could stop it.

**Fix:** Snapshot voting power at a previous block. Add a mandatory delay between a proposal passing and it being executable.

---

### 8. ✍️ Signature Replay — Replayable Signed Actions

A signed message with no nonce or chain ID can be submitted more than once. If a protocol accepts a signature to authorize a withdrawal, an attacker can replay that same signature repeatedly — draining funds with a message the user signed only once.

**Fix:** Every signed message must include `nonce`, `chainId`, and an expiry timestamp. Use EIP-712 for typed structured data. Invalidate nonces after use.

---

### 9. 🔧 Upgrade Misconfiguration — Wormhole UUPS Risk (2022)

UUPS proxies forward all calls to an implementation contract. If the implementation is deployed uninitialized, anyone can call `initialize()`, claim ownership, and then upgrade the proxy to point at a malicious contract — taking over everything it controls.

**Fix:** Always call `_disableInitializers()` in the implementation's constructor. A deployed-but-uninitialized implementation is an open door.

---

## Quick Start

```bash
git clone https://github.com/Pawar7349/DeFiHackLab.git
cd DeFiHackLab
forge install
forge test -vvv
```

Run a specific module:
```bash
forge test --match-contract ReentrancyTest -vvv
forge test --match-contract GovernanceAttackTest -vvv
```

---

## Project Structure

```
DeFiHackLab/
│
├── src/                   ← vulnerable, attacker, and fixed contracts
│   ├── overflow/
│   ├── reentrancy/
│   ├── access-control/
│   ├── txorigin/
│   ├── selfdestruct/
│   ├── oracle/
│   ├── governance/
│   ├── signature-replay/
│   └── upgrade-misconfig/
│
├── test/                  ← 26 tests, all passing
├── incidents/             ← incident notes per module
└── .github/workflows/     ← CI runs on every push
```

---

## Roadmap

- [x] 9 exploit modules — vulnerable, attacker, fixed contracts
- [x] 26 tests across all modules
- [x] CI pipeline (GitHub Actions)
- [ ] Invariant and fuzz testing per module
- [ ] Mainnet fork tests for oracle and governance modules
- [ ] Detailed exploit trace writeups per incident
- [ ] Gas snapshot comparisons — vulnerable vs fixed
- [ ] Module links in this README once writeups are complete

---

## Author

**Pratik Pawar** — Solidity Developer with a focus on smart contract security

I'm based in Pune, India. I'm actively looking for Solidity developer and smart contract security roles — junior auditor, protocol dev, or security researcher positions.

[![GitHub](https://img.shields.io/badge/GitHub-Pawar7349-black?logo=github)](https://github.com/Pawar7349)
[![Twitter](https://img.shields.io/badge/Twitter-@PratikP43786754-1DA1F2?logo=twitter)](https://x.com/PratikP43786754)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-pratik--pawar-blue?logo=linkedin)](https://www.linkedin.com/in/pratik-pawar-600731237/)
---

## License

MIT
