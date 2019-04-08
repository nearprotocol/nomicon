# Block Chain

Here we describe how block chain is collectively constructed, the structure of the block chain blocks,
and how these blocks are used by the peers.

As in a classic block chain each block has exactly one parent block and is signed by the validators.
Validators sign the block using BLS signatures only once, i.e. there is no double-signing.
The block can have different states of readiness, depending on the number of signatures and the state of the next block.

To understand the classification of the blocks we need to first see how they are constructed.

Classification of the blocks in the shard chain:
* **Unfinalized block** -- has \\( <2N/3 \\) signatures. The next block is not allowed to refer to it as a parent;
* **Semi-finalized block** -- has \\( \geq 2N/3 \\) signatures but it is not canonical.<br/> The next block is not finished yet.
* **Finalized** -- when there is \\( \geq 2N/3 \\) signatures and the block is canonical.<br/>
Other validators have agreed on the given set of signatures,

where \\( N \\) is the number of validators.

The desire to have canonical set of signatures that sign the block and to not have multi-stage consensus
poses engineering difficulties. Specifically a group of validators that work on block X+1 have to agree on the following:
1. Set of transactions that will go into block X+1;
2. State induced by the transactions of the previous block X (We need to counter adversaries that can produce an invalid state);
3. Set of signatures that signed transactions included in block X (We want this set to be canonical);

