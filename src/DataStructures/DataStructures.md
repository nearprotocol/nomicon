# Data Structures

The following is a list of standard data-structures.

## Transaction

```rust,ignored
struct Transaction {
	originator: AccountId,
	receiver: AccountId,
	nonce: u64,
	method_name: Vec<u8>,
	args: Vec<u8>,
	amount: Balance,
}

struct ReceiptBlock {
	header: SignedShardBlockHeader,
	path: Vec<Hash>,
	receipts: Vec<Receipt>,
}
```

## Shard

```rust,ignored
struct ShardBlockHeader {
	parent: Hash,
	index: u64,
	shard_id: u64,
	// State trie
	merkle_root_state: Hash,
 	// Transactions Trie
	merkle_root_tx: Hash,
	// Receipt blocks Trie
    merkle_root_receipt: Hash,
    // Transaction result Trie
	merkle_root_tx_result: Hash,
	// Receipt result Trie
	merkle_root_receipt_result: Hash,
}

struct tShardBlockBody {
	receipts: Vec<ReceiptBlock>,
	transactions: Vec<SignedTransaction>,
}

struct SignedShardBlock {
	header: ShardHeader,
	body: ShardBody,
	signature: BLS,
	authority_mask: Vec<bool>,
}

// ShardBlock Extra (Index?)
// 	TransactionAddress
// 		BlockId
// 		Index
// 	Receipts
// 		HashMap<ShardId, Vec<Receipt>>
// 	Hash -> Transaction/Receipt Result // or should we put into two Vec that align with transactions/receipts?
// 		Status (Completed, Failed)
// 		Gas
// 		Receipts ids of receipts
// 		Logs


struct ShardClient {
	chain: Chain<SignedShardBlock>,
	runtime: Runtime,
	state: StateDb,
}
	
fn to_shard_receipt_blocks(ShardBlockExtra) -> Vec<ReceiptBlock> { 
   
}
```

## Beacon

```rust,ignored
//System extension to every contract/account
//	send_money(to, value)
//	swap_keys(old_public_key, new_public_key)
//
//Transaction(orignator=me, receiver=account, method=”system::swap_keys”, args={...})
//
//Transaction(originator=me, receiver=system, method=send_money, args={...})
```
