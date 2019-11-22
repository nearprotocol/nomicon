# Transactions

A transaction in Near is a list of [actions](#actions) and additional information:

```rust
pub struct Transaction {
    /// An account on which behalf transaction is signed
    pub signer_id: AccountId,
    /// An access key which was used to sign a transaction
    pub public_key: PublicKey,
    /// Nonce is used to determine order of transaction in the pool.
    /// It increments for a combination of `signer_id` and `public_key`
    pub nonce: Nonce,
    /// Receiver account for this transaction. If
    pub receiver_id: AccountId,
    /// The hash of the block in the blockchain on top of which the given transaction is valid
    pub block_hash: CryptoHash,
    /// A list of actions to be applied
    pub actions: Vec<Action>,
}
```

## Signed Transaction

`SignedTransaction` is what the node receives from a wallet through JSON-RPC endpoint and then routed to the shard where `receiver_id` account lives. Signature proves an ownership of the corresponding `public_key` (which is an AccessKey for a particular account) as well as authenticity of the transaction itself.

```rust
pub struct SignedTransaction {
    pub transaction: Transaction,
    /// A signature of a hash of the Borsh-serialized Transaction
    pub signature: Signature,
```

Take a look some [scenarios](/Runtime/Scenarios/Scenarios) how transaction can be applied:

# Actions

There are a several action types in Near:

```rust
pub enum Action {
    CreateAccount(CreateAccountAction),
    DeployContract(DeployContractAction),
    FunctionCall(FunctionCallAction),
    Transfer(TransferAction),
    Stake(StakeAction),
    AddKey(AddKeyAction),
    DeleteKey(DeleteKeyAction),
    DeleteAccount(DeleteAccountAction),
}
```

Each transaction consists a list of actions to be performed on the `receiver_id` side. Sometimes the `singer_id` equals to `receiver_id`. There is a set of action types when `signer_id` and `receiver_id` is required to be equal. Actions requires arguments and use data from the `Transaction` itself.

// TODO: how to introduce the concept of `sender_id`

## CreateAccount

`CreateAccountAction` doesn't take any additional arguments, it uses `receiver_id` from Transaction. `receiver_id` is an ID for an account to be created. Account ID should be [valid](Account.md#account-id) and unique throughout the system. Usually we want to create an AccessKey with full access keys

```rust
pub struct CreateAccountAction {}
```

// TODO: how to add an initial access key if we don't have an account yet?

## DeployContract

_Requires:_

- _`signer_id` to be equal to `receiver_id`_
- _`public_key` to be `AccessKeyPermission::FullAccess`_

`DeployContractAction` takes a WebAssembly code which will be set for account.

```rust
pub struct DeployContractAction {
    pub code: Vec<u8>, // a valid WebAssembly code
}
```

## FunctionCallAction

_Requires:_

- _`public_key` to be `AccessKeyPermission::FullAccess` or `AccessKeyPermission::FunctionCall`_

Calls a method of a particular contract.

```rust
pub struct FunctionCallAction {
    /// Name of exported Wasm function
    pub method_name: String,
    /// Serialized arguments
    pub args: Vec<u8>,
    /// Prepaid gas (gas_limit) for a function call
    pub gas: Gas,
    /// Amount of tokens to transfer to a receiver_id
    pub deposit: Balance,
}
```

## TransferAction

_Requires:_

- _`public_key` to be `AccessKeyPermission::FullAccess`_

```rust
pub struct TransferAction {
    /// Amount of tokens to transfer to a receiver_id
    pub deposit: Balance,
}
```

## StakeAction

_Requires:_

- _`signer_id` to be equal to `receiver_id`_
- _`public_key` to be `AccessKeyPermission::FullAccess`_

```rust
pub struct StakeAction {
    pub stake: Balance,
    pub public_key: PublicKey,
}
```

## AddKeyAction

_Requires:_

- _`signer_id` to be equal to `receiver_id`_
- _`public_key` to be `AccessKeyPermission::FullAccess`_

Associates an [AccessKey](AccessKey) with a `public_key` provided.

```rust
pub struct AddKeyAction {
    pub public_key: PublicKey,
    pub access_key: AccessKey,
}
```

## DeleteKeyAction

_Requires:_

- _`signer_id` to be equal to `receiver_id`_
- _`public_key` to be `AccessKeyPermission::FullAccess`_

```rust
pub struct DeleteKeyAction {
    pub public_key: PublicKey,
}
```

## DeleteAccountAction

_Requires:_

- _`signer_id` to be equal to `receiver_id`_
- _`public_key` to be `AccessKeyPermission::FullAccess`_
- _`account shouldn't have any locked balance`_

```rust
pub struct DeleteAccountAction {
    /// The remaining account balance will be transferred to the AccountId below
    pub beneficiary_id: AccountId,
}
```
