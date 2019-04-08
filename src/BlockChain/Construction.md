# Construction

Each validator performs the following tasks:
1. Collects transactions by accepting incoming transactions from the peers and through the gossip from the validators;
2. Runs consensus with other validators to agree on a set of transactions that will be used for the block.
The consensus also includes agreeing on the previous state see (3), and the previous set of signatures see (4);
3. Computes the new state from the set of transactions and the previous state;
4. Collects BLS signatures for the given block.


## The challenges
We want our block chain to have the following properties that make the design challenging:
1. Each block is signed only once by a BLS signature;
2. BLS signature of the given block is canonical
(Recall, that the block is valid when it is signed by \\( > 2N/3 \\) validators. However, in a general block chain,
this set of validators does not have to be the same as known by the peers in the network. In our design we want this
set to be canonical, i.e. agreed upon by the network, and therefore unique.);
3. Each block is self-contained, i.e. we do not need to have another block to verify it.

## The invariant
The general invariant for most of the PoS block chains, is that for transactions to be incorporated into a block chain
the following must be performed:
* The transactions are collected;
* The transactions are executed;
* The set of transactions is agreed on through a consensus;
* The execution result is agreed on through a consensus.

Additionally, as discussed in the previous section, we want the following:
* The set of BLS parts that sign the given block is agreed on through a consensus.

In our design, the set of transactions, the execution result (the new state), and the BLS parts are agreed on
simultaneously through a single consensus.
Specifically, the consensus agrees on the following:
* Set of transactions for block \\( X + 1 \\);
* Execution result of the transactions from the block \\( X \\);
* BLS parts of block \\( X \\) .

## The state machine

The block chain logic of a validator is implemented as a state-machine with three "states": 
1. Collecting transactions for block \\( X + 1 \\);
2. Computing state from transactions of block \\( X \\) and continuing collecting transactions for block \\( X + 1 \\);
3. Running consensus to agree on a set of transactions for block \\( X + 1\\) .

(1) is initiated when the validator receives the announcement of the block \\( X - 1 \\);<br/>
(2) is initiated when the validator receives the announcement of the block \\( X \\);<br/>
(1) + (2) terminate and (3) is initiated when the state computation is finished;<br/>
(3) terminates when the consensus is finished.<br/>

See the flow diagram and the state machine diagram below:
<img src="../img/block_production.jpg" />

Interestingly, the transaction collection state has nuances. Specifically, transaction collection happens passively 
through the maintenance of a mempool the collects transactions. While a newly-joining validator that wants to build
block \\( X \\) has to start collecting transactions when it gets announcement of block \\( X - 2 \\), the validator
that was already building block \\( X \\) will collect transactions only during its state (3) while building consensus.

## Submitting transactions
The user that wants to send a transactions must then send it to validators that are currently in state (1) or (2) by
anticipating when they might have received the corresponding block announcements and started listening to transactions.
