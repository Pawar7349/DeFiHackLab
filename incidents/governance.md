# governance

Real case:
- Beanstalk, Apr 2022
- around $182M stolen

What went wrong:
- governance execution trusted instant voting power
- flash loan gave temporary majority

In this repo:
- vulnerable contract checks current balance and executes immediately

Fix:
- snapshot voting power
- add timelock / delay before execution
- require stake lock period
