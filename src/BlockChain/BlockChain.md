# Block Chain

Here we describe how block chain is collectively constructed, the structure of the block chain blocks,
and how these blocks are used by the peers.

As in a classic block chain each block has exactly one parent block and is signed by the validators.
Validators sign the block using BLS signatures only once, i.e. there is no double-signing.
The block can have different states of readiness, depending on the number of signatures and the state of the next block.
