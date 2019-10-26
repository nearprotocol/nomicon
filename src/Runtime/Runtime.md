# Runtime

Runtime layer is used to execute smart contracts and other actions created by the users and preserve the state between the executions.

The components of the runtime layer are:
* `near-vm-logic` crate -- describes the interface that smart contract uses to interact with the blockchain.
Encapsulates the behavior of the blockchain visible to the smart contract, e.g. fee rules, storage access rules, promise rules;
* `near-vm-runner` crate -- a wrapper around Wasmer that does the actual execution of the smart contract code. It exposes the
interface provided by `near-vm-logic` to the smart contract;
* `runtime` crate -- works with the receipts. When receipt contains an action that calls a smart contract it calls
`near-vm-runner`;
* `store` crate -- interfaces with the KV databases and implements a trie on the top of it that smart contracts interface
through `near-vm-logic`.
