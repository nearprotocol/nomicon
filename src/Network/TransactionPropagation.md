# Transaction propagation

It is essential for all nodes participating in the network having well synchronized their sets of unused transactions, and have an efficient mechanism to propagate them without decreasing transactions throughput. When a transaction is included in a block, every participant should forget(remove) this transaction.

## Strategies

* Dummy Strategy: Each participant has the set of transactions of every other participant from its point of view. This set is always a subset of the real set of transactions. When Alice and Bob want to sync their transactions, Alice will only send to Bob tx that she believes he doesn't have. After sending the transactions she will update her believes from Bob set.

    + PRO: It is easy to implement. **(We will use this strategy for alphanet)**
    + CONS: We are sending the same transactions many times overloading the network.
    + Details: Instead of keeping a set per participant explicitly, we will add a bitmask to each transaction of size the number of participants in the network. (What if participants goes in-n-out?)

* Bloom Filters:

* [Block Syncing in 1.36s with Harmony’s Adaptive IDA Protocol](https://medium.com/harmony-one/block-syncing-in-1-36s-with-harmonys-adaptive-ida-protocol-de5da398569e)