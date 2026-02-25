# DeFiHackLab

This repo is my smart contract security lab.

I pick real exploit patterns and rebuild them in small modules.
Each module has:

- vulnerable contract
- attack contract
- fixed contract
- tests
- short incident note

I keep everything in this repo:

- code in `src/`
- tests in `test/`
- incident notes in `incidents/`

## Modules

- `overflow`
- `reentrancy`
- `access-control`
- `txorigin`
- `selfdestruct`
- `oracle`
- `governance`
- `signature-replay`
- `upgrade-misconfig`

## Run

```bash
forge clean
forge test -vvv
```

## Current status

- full test suite passing locally (`26` tests)
- CI file: `.github/workflows/forge-tests.yml`

## Coverage

| Module | Real incident reference | Status |
|---|---|---|
| overflow | Beauty Chain (2018) | done |
| reentrancy | The DAO (2016) | done |
| access-control | Parity wallet init bug (2017) | done |
| txorigin | tx.origin phishing pattern | done |
| selfdestruct | Parity library kill path (2017) | done |
| oracle | Mango Markets (2022) | done |
| governance | Beanstalk (2022) | done |
| signature-replay | replayable signed action pattern | done |
| upgrade-misconfig | Wormhole UUPS risk (2022) | done |

## Next

- add more invariant/fuzz coverage
- add gas snapshots
- add short exploit trace writeups
