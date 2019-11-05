# Transactions

A client creates a transaction, computes the transaction hash and signs this hash to get a signed transaction.
Now this signed transaction can be sent to a node.

When a node receives a new signed transaction, it validates the transaction (if the node tracks the shard) and gossips it to the peers. Eventually, the valid transaction is added to a transaction pool.

Every validating node has its own transaction pool. The transaction pool maintains transactions that were not yet discarded and not yet included into the chain.

Before producing a chunk transactions are ordered and validated again. This is done to produce chunks with only valid transactions.

## Transaction ordering

The transaction pool groups transactions by a pair of `(signer_id, signer_public_key)`. The `signer_id` is the account ID of the user who signed the transaction, the `signer_public_key` is the public key of the account's access key that was used to sign the transactions. 
Within the group, the transactions are ordered by nonce in non-decreasing order.

The valid order of the transactions is the following:
- transactions are ordered in batches.
- each batch should contain exactly one transaction with the lowest nonce for every transaction group keyed by the pair of `(signer_id, signer_public_key)`.
- the order within a batch is undefined and each node should use a unique secret seed for that ordering.

Transaction pool provides a draining structure that allows to select valid transactions in a proper order.

## Transaction validation

The transaction validation happens twice, once before adding to the transaction pool, next before adding to a chunk.

### Before adding to a transaction pool

This is done to quickly filter out transactions that have an invalid signature or are invalid on the latest state.

### Before adding to a chunk
 
A chunk producer pulls ordered transactions from the transaction pool using a draining structure.
Transactions are pulled from the the pool and validated one by one on top of latest state. The state is persisted after each successful validation.
E.g. if the first transaction charged the account, the next transaction for the same account may become invalid.

If the last transaction was invalid, the chunk producer requests the next transaction from the pool with the same key to maintain the proper order.
Otherwise we'd skip this key pair within this batch and the order will become invalid.

Valid transactions are added to the chunk. For every valid transaction, the validation result contains the amount of burnt gas that will be charged for converting this
transaction to a receipt. When the total sum of burnt gas for valid transactions exceeds the gas limit of a chunk, the chunk 
producer drops the draining iterator and the remaining transactions stay in the pool.

