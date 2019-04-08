# Block Structure

The following code explains how each block is structured:

```rust,ignored
struct Block {
    parent_hash: CryptoHash,
    /// State computed from the transations and the state in the parent block.
    parent_state: State,
    /// A canonical set of signatures signing `transactions`
    /// and `parent_state` of the parent block.
    parent_signatures: BLSAggregate,
    transactions: Transactions,
}

struct SignedBlock {
    block: Block,
    /// A non-canonical set of signatures that verifies `block` but is subject
    /// to change until the next block is constructed.
    signatures: BLSAggregate,
}
```

Each `SignedBlock` can then be of three types:
* `Unfinalized` -- the number of `signatures` is \\( < 2N/3 \\).
   This state only exists for the blocks on the beacon chain, where we allow temporary forks;
* `Semi-finalized` -- the number of `signatures` is \\( \geq 2N/3 \\) but the parent block is missing,
   which means `signatures` is subject to change since they are agreed on in the next block;
* `Finalized` -- the number of `signatures` is \\( \geq 2N/3 \\) and the parent block is known.
   For beacon chain the number of signatures can be \\( < 2N/3 \\) but the parent block should be known.

The shard-chain is therefore always looks like this:
<div class="mermaid">
graph LR
    id0(Finalized block X-3)-->id1
    id1(Finalized block X-2)-->id2
    id2(Finalized block X-1)-->id3(Semi-finalized block X)
    style id0 fill:#f9f,stroke:#333,stroke-width:4px
    style id1 fill:#f9f,stroke:#333,stroke-width:4px
    style id2 fill:#f9f,stroke:#333,stroke-width:4px
    style id3 fill:#ccf,stroke:#f66,stroke-width:2px,stroke-dasharray: 5, 5
</div>

While beacon-chain can also look like this, for a brief moment while resolving a fork:
<div class="mermaid">
graph LR
    id0(Finalized block X-3)-->id1
    id1(Finalized block X-2)-->id2
    id2(Finalized block X-1)-->id3(Unfinalized block X)
    style id0 fill:#f9f,stroke:#333,stroke-width:4px
    style id1 fill:#f9f,stroke:#333,stroke-width:4px
    style id2 fill:#f9f,stroke:#333,stroke-width:4px
    style id3 fill:#ccf,stroke:#f66,stroke-width:0px
</div>


## Usage
`SignedBlock` is mostly used for the network exchange, for the situations when a catching-up peer requests a single block.
`SignedBlock` is also used for block announcements.

`Block` is used for when a peer requests a range of \\( m \\) blocks (we then return \\( m - 1\\) `Block`'s and one `SignedBlock`).
`Block` is also used for internal representation of the chain and the storage.
