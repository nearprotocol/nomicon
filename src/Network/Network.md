# Network

The network crate has two levels of abstractions:
1. **Peer management** is a low-level code that only works with discovering peers and connecting to them. It is not domain-specific, meaning it does not care about the content of the messages that it receives from the peers;
2. **Protocol** is a higher-level code that understands the content of incoming and outgoing messages and communicates them with the corresponding parts of the infrastructure.

## Current state

Our current implementation of the network is the minimal one for running nodes locally, on AWS, or in integration tests.
It contains the following functionality:
* **Peer discovery through the gossip.** Peers periodically exchange information with each other about other peers that they know allowing all peers to gradually discover each other;
* **Booting from the boot nodes.** Peers start discovering of other peers by initially connecting to the boot nodes;
* **Handshake.** Peers that establish the connection with each other are required to perform a handshake that involves exchanging certain information, like information about other peers;
* **Unique connection.** We guarantee that there is at most one connection between two peers, by breaking a tie when they try to connect to each other simultaneously;
* **Timeouts.** Certain operations, like establishing a connection or performing a handshake are limited by a timeout;
* **Reconnection.** Peers that have some connections dropped will try to re-establish them after a certain period of time.

The following functionality is not implemented yet:
* **Relays.** The peers that are behind the NAT cannot have a direct communication and have to use relays. Our current code does not implement that;
* **Broadcasting.** We need a broadcasting for announcements over the network;
* **Encryption.** Currently our messages are not encrypted;
* **Verification.** During the handshake we should verify that the other peer is not an impostor, by verifying their signed handshake;
* **Connection limit.** We need to limit the number of connections a single peer can have. When we try to establish a connection with a maxed-out boot node it should redirect us to other nodes;
* **Tight coupling between gossip and relaying.** Our consensus algorithms use gossip, since we want them to adversary-proof the relaying should be adversary-proof too.
* **DNS.** DNS resolution.
