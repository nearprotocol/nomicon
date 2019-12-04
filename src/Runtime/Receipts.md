# Receipts

All cross-contract (we assume that each account lives in it's own shard) communication in Near happens trough Receipts.
Receipts are stateful in a sense that they serve not only as messages between accounts but also can be stored in the account storage to await other receipts.

Each Receipt has the following fields:

#### predecessor_id

_type: AccountId_

The account_id which issued a receipt.

#### receiver_id

_type: AccountId_

The destination account_id.

#### receipt_id

_type: AccountId_

An unique id for the receipt.

#### type

Could be either [ActionReceipt](#actionreceipt) or [DataReceipt](#datareceipt)

## ActionReceipt

`ActionReceipt` represents a request to apply actions on the `receiver_id` side. It could be a derived as a result of a `Transaction` execution or a another `ActionReceipt` processing. `ActionReceipt` consists the following fields:

#### signer_id

_type: AccountId_

An account_id which signed the original [transaction](Transaction.md).

#### signer_public_key

_type: PublicKey_

An [AccessKey](../Primitives/AccessKey.md) which was used to sign the original transaction.

#### gas_price

_type: u128_

Gas price is a gas price which was set in a block where original [transaction](Transaction.md) has been applied.

#### output_data_receivers

_type: [(CryptoHash, AccountId)]_

Output data receivers will be converted to `DataReceipt`s when smart contract finish its execution with some value.

#### input_data_ids

_type: [CryptoHash]_

`input_data_ids` are the receipt data dependencies. We These IDs are `DataReceipt.data_id`.

## DataReceipt

#### data_id

_type: CryptoHash_

An a unique DataReceipt identifier.

#### data

_type: [u8]_

An an associated data in bytes.

# Receipt Matching

Runtime doesn't expect that Receipts are coming in a particular order. Each Receipt is processed individually. The goal of the `Receipt Matching` process is to match all [`ActionReceipt`s](#actionreceipt) to the corresponding [`DataReceipt`s](#datareceipt).

## Processing ActionReceipt

For each incoming [`ActionReceipt`](#actionreceipt) runtime checks whether the storage has all data (defined by [`input_data_ids`](#input_data_ids)) required for execution. If all required `input_data_ids` are in the [storage](#Processing-DataReceipt), runtime applies the `ActionReceipt`. Otherwise runtime saves the following information:

#### Pending Data Count

The counter which counts the estimated [`DataReceipt`s](#DataReceipt) for [ActionReceipt](Receipts.md#actionreceipt) set to the length of [`input_data_ids`](#input_data_ids):

_`key` = `receiver_id: AccountId`,`receipt_id: CryptoHash`_

_`value` = `u32`_

#### Awaiting ActionReceipt

Stores the data_id's which `receipt_id` awaits.

_`key` = `receiver_id: AccountId`,`data_id: CryptoHash`_

_`value` = `receipt_id`_

And the [`Receipt`](#receipts) itself:

_`key` = `receiver_id: AccountId`,`receipt_id: CryptoHash`_

_`value` = `Receipt`_

## Processing DataReceipt

Each incoming [`DataReceipt`](#datareceipt) saved it in the storage as:

_key = `receiver_id: String`,`data_id: CryptoHash`_

_value = `Option[u8]>`_

Next, runtime gets `ActionReceipt` which awaits this incoming `DataReceipt` by quiring [`Awaiting ActionReceipt`](#awaiting-actionreceipt) . If no `ActionReceipt` awaits this `DataReceipt` we expect it to arrive later. Otherwise

- get `receipt_id` from [`Awaiting ActionReceipt`s](#awaiting-actionreceipt)
- remove itself from [`Awaiting ActionReceipt`s](#awaiting-actionreceipt)
- decrement [`Pending Data Count`](#pending-data-count)

If the current `DataReceipt` is the last awaited [`DataReceipt`](#datareceipt) ([`Pending Data Count`](#pending-data-count) = 1) that means all the [`ActionReceipt.input_data_ids`](#input_data_ids) for [`Awaiting ActionReceipt`](#awaiting-actionreceipt)) are satisfied and runtime can apply this `ActionReceipt`.
