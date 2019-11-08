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

## Draining iterator

Draining Iterator is a structure to pull transactions from the pool.
It allows to request a next transaction either with the new key (next key) or with the same key.
When a draining iterator is dropped the remaining transactions are returned back to the pool.

It implements `fn next(from_same_tx_group: bool) -> Option<SignedTransaction>`.
If `from_same_tx_group` is true, then the iterator returns a transaction from the same group as the last transaction.
If it's false, then the iterator returns a transaction from the next group with the different key.

### Transaction ordering example using draining iterator.

Let's say:
- account IDs as uppercase letters (`"A"`, `"B"`, `"C"` ...)
- public keys are lowercase letters (`"a"`, `"b"`, `"c"` ...)
- nonces are numbers (`1`, `2`, `3` ...)

A pool might have group of transactions in the hashmap:
```
transactions: {
  ("A", "a") -> [1, 3, 2, 1, 2]
  ("B", "b") -> [13, 14]
  ("C", "d") -> [7]
  ("A", "c") -> [5, 2, 3]
}
```

There are 3 accounts (`"A"`, `"B"`, `"C"`). Account `"A"` used 2 public keys (`"a"`, `"c"`). Other accounts used 1 public key each.
Transactions within each group may have repeated nonces while in the pool.
That's because the pool doesn't filter transactions with the same nonce, only transactions with the same hash.

##### Initialization

Here's how the iterator would work. When the iterator is first created nothing happens.
The iterator internally hold 2 maps, the current map and the next map.
At start the current map is the same as above, and the next map is empty.

The internal iterator structure looks like this:
```
current map: {
  ("A", "a") -> [1, 3, 2, 1, 2]
  ("B", "b") -> [13, 14]
  ("C", "d") -> [7]
  ("A", "c") -> [5, 2, 3]
}
sorted: false
next map: {
}
last_entry: None
```

##### Transaction #1
The iterator is called with `.next(false)`.

An entry `("A", "a") -> [1, 3, 2, 1, 2]` is pulled from the current map.
Then the transactions are sorted in non-decreasing order, so the last transaction has the smallest nonce.
The entry becomes the following: `("A", "a") -> [3, 2, 2, 1, 1]`. The last transaction with nonce `1` from the vector is returned.

The internal iterator structure becomes the following:
```
current map: {
  ("B", "b") -> [13, 14]
  ("C", "d") -> [7]
  ("A", "c") -> [5, 2, 3]
}
sorted: false
next map: {
}
last_entry: ("A", "a") -> [3, 2, 2, 1]
```

##### Transaction #2
Now if the returned transaction is valid the iterator is going to be called with `.next(false)` again.

The iterator needs a new entry, so it inserts the last entry into the `next_map` and pulls the new entry `("B", "b") -> [13, 14]`.
Sorts it and returns the last transaction with nonce `13`.

The internal iterator structure becomes the following:
```
current map: {
  ("C", "d") -> [7]
  ("A", "c") -> [5, 2, 3]
}
sorted: false
next map: {
  ("A", "a") -> [3, 2, 2, 1]
}
last_entry: ("B", "b") -> [14]
```

##### Transaction #3
Let's say the last transaction was invalid. The iterator is called with `.next(true)`.

Instead of pulling a new entry from the current map, the iterator returns a transaction with nonce `14` from the last entry.
The entry becomes empty, so the iterator sets it to `None`.

The internal iterator structure becomes the following:
```
current map: {
  ("C", "d") -> [7]
  ("A", "c") -> [5, 2, 3]
}
sorted: false
next map: {
  ("A", "a") -> [3, 2, 2, 1]
}
last_entry: None
```

##### Transaction #4
Let's say the transaction was valid and iterator was called with `.next(false)`.

But even if the last transaction was invalid, the iterator would still pull the new entry, because the `last_entry` is `None`.
The new entry is `("C", "d") -> [7]`, the iterator returns transaction with nonce `7`, entry becomes empty, so it is set to `None`.

The internal iterator structure becomes the following:
```
current map: {
  ("A", "c") -> [5, 2, 3]
}
sorted: false
next map: {
  ("A", "a") -> [3, 2, 2, 1]
}
last_entry: None
```

##### Transaction #5
Iterator called with `.next(false)`.

The new entry is `("A", "c") -> [5, 2, 3]`, sorted to `("A", "c") -> [5, 3, 2]` and the transaction with nonce `2` is returned.

The internal iterator structure becomes the following:
```
current map: {
}
sorted: false
next map: {
  ("A", "a") -> [3, 2, 2, 1]
}
last_entry: ("A", "c") -> [5, 3]
```

##### Transaction #6
Iterator called with `.next(false)` again. The last entry is added to the next map.

Note, that the next map doesn't have to maintain the order of inserts, cause it's a hashmap.
The iterator need to get a new entry, but the current map is empty.
It means the new batch is starting.

The iterator swaps current and next maps.
Also, since the iterator went through all entries and sorted them all, the next time they don't need to be sorted.

Let's the iterator pulls a new entry `("A", "c") -> [5, 3]`. Then returns the transaction with nonce `3`.

The internal iterator structure becomes the following:
```
current map: {
  ("A", "a") -> [3, 2, 2, 1]
}
sorted: true
next map: {
}
last_entry: ("A", "c") -> [5]
```

##### Dropping iterator

Let's say the chunk producer collected enough transactions.
It drops the iterator, so the iterator has to return all remaining transactions to the pool.
First it inserts the last entry into the pool transactions map.
Then it inserts all transactions from iterator maps into the pool transactions map.

The pool map becomes the following:
```
transactions: {
  ("A", "a") -> [3, 2, 2, 1]
  ("A", "c") -> [5]
}
```

##### Chunk Transactions

Transactions that were pulled from the pool: 
```
("A", "a", 1),
("B", "b", 13), // Invalid
("B", "b", 14),
("C", "d", 7),
("A", "c", 2),
("A", "c", 3),
```

After filtering invalid transactions out:
```
("A", "a", 1),
("B", "b", 14),
("C", "d", 7),
("A", "c", 2),
("A", "c", 3),
```

So there are 2 batches of transactions. The first batch contains 4 keys and the second batch contains 1 key.
And this is a valid order.

