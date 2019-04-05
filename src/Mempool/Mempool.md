# Mempool

Mempool is responsible for temporarily storing transactions and receipts received from other peers or rpc calls. Nodes in the network reach consensus on payload, which is produced by the mempool. More specifically, nightshade consensus agrees on the hash of a `Snapshot`, which consists of hashes of transactions and receipts in the mempool.

 at the beginning of nightshade consensus, nodes snapshot the mempool content and produce a `Snapshot`, which consists of hashes of transactions and receipts in the mempool. Then they start to gossip the hash of the snapshot to peers and fetch missing transactions/receipts from peers if necessary. Finally, a consensus is reached on the hash of a snapshot and the block is produced with the transactions and receipts corresponding to the ones in the snapshot.

## Payload Gossipping and Fetching
This sections describes how gossipping works from the perspective of mempool. Mempool gossips `ChainPayload`, which consists of transactions and receipts, to peers periodically.

The complexity of gossipping arises from snapshot gossipping and fetching. Mempool maintains two containers of snapshots, `snapshots`, which stores the snapshots that are ready, i.e, the mempool have all the transactions and receipts of the snapshots, and `pending_snapshots`, which stores the snapshots that mempool have learned from peers but do not yet have the full set of transactions and receipts of.

When consensus starts, mempool would receive`BlockProposal`, which consists of hash of `Snapshot`. If it does not know this hash, it would request the snapshot from the peer who sends the block proposal by sending a`PayloadSnapshotRequest` message. When the mempool receives a `Snapshot`, it checks whether the snapshot is known to them. If so, the snapshot is added to `snapshots`.  Otherwise it requests the missing transactions and receipts from the peer who sends the snapshot by sending a `MissingPayloadRequest` and add the snapshot to `pending_snapshots`. The snapshot will be moved to `snapshots` once the mempool receives the response and verifies that the response actually covers the missing parts.

## Block Production and Importing
When consensus is reached and a block is being produced, `pop_payload_snapshot` is called in mempool to remove the snapshot corresponding to the block from `snapshots`. When a block is imported, mempool removes transactions and receipts in the block.


## Assumptions
We list some assumptions we made about the mempool code.

**transactions**: Transactions in mempool are grouped by account id and, within each group, ordered by transaction nonce. When a transaction arrives, mempool checks whether the nonce is feasible, i.e., whether it is larger than the largest known nonce of the account in the last block. If it is not, the transaction is dropped. Mempool then checks whether the transaction signature is valid and drops the transaction if the signature is invalid.

**add_missing_payload**: When mempool receives a payload response from peer because it requests missing transactions/receipts in a snapshot, the mempool checks whether the response covers the missing parts, i.e., whether the response is a super set of the missing transactions/receipts.

**known_to**: Mempool mains a hashmap of hash to `AuthorityId` to keep track of what has been sent to which peers. The intention is to reduce the amount of messages sent over the network. When a payload gossip is sent to some peer, mempool adds the hash of transactions and receipts to `known_to` for that peer and will not send the same transaction/receipt to the peer during future gossipping. Notice that this is intentionally optimistic because if the peer does not receive the message, they will request the missing parts in the future.