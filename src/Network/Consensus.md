# Blockchain protocol overview

## Consensus

Participants will try to agree on the next block, to do that each participant will propose a block. `Proposal` in this diagram is the hash of the proposed block.

<div class="mermaid">
sequenceDiagram
    participant Mempool
    participant Nightshade
    participant Network
    Mempool->>Nightshade: Send RESET signal.
    Note over Nightshade: Start running consensus on confirmed proposals.
    loop Do for every other participant async.
        Nightshade->>Network: Gossip signed proposal [1].
        Network->>Nightshade: Receive signed proposal [2].
        Nightshade->>Mempool: Request confirmation.
        Mempool-->Network: Sync mempool until this proposal is valid [4].
        Mempool->>Nightshade: Send confirmation.
        Note over Nightshade: Set proposal as confirmed.
    end
    loop Consensus not achieved
        Nightshade->>Network: Gossip current state.
        Network->>Nightshade: Receive state update.
        alt missing proposal
            Nightshade->>Network: Request signed proposal [3].
        else achieve consensus
            Note over Nightshade: Send consensus.
        end
    end
</div>

Notes:

* [1] This can fail. Network fails or participant is offline.
* [2] If we fail to receive a proposal and we need it later for consensus it will be requested in [3]
* [3] Request missing proposal.
* [4] A `proposal` is valid if the block proposed can be fetched from the mempool.