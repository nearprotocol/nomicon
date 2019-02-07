# Peer Management

As discussed before, peer management takes care of peers and does not work with the content of the
messages sent between the peers.

Each peer in peer management is represented by a state-machine, represented by `Peer` object. Peer can then be in
multiple states:
* **Unconnected** -- we know that peer's info but we have not established a connection yet;
* **Connecting** -- we are in process of connecting to a peer;
* **Connected** -- we have sent a handshake and are waiting for a response handshake;
* **Ready** -- we are exchanging domain-specific messages with the peer, like block announcements, gossip, etc;
* **Incoming** -- someone, we do not know who, has established a incoming connection with us. We are waiting for a handshake;

Here is an example of Alice establishing connection with a boot node, Bob.
<div class="mermaid">
sequenceDiagram
    Note over Alice: Alice has Bob's state as Unconnected
    Alice->>Alice: Connection timeout expires
    Note over Alice: Alice switches Bob's state to Connecting
    Alice->>+Bob: Opening connection
    Note over Alice,Bob: Bob adds a peer with the state Incoming. Alice switches Bob's state to Connected
    Alice->>Bob: Sending handshake
    Note over Bob: Bob switches Alice's state to Ready.
    Bob->>-Alice: Replying with handshake
    Note over Alice: Alice switches Bob's state to Ready.
</div>
