# Nightshade

**Nightshade** is the Byzantine-fault tolerant consensus protocol used at the core of *NEAR PROTOCOL*.

Important features:

* Tolerates up to \\( \frac 1 3 \\) Byzantine participants.
* It is not DAG-Based and the space complexity growth linear with respect to the number of participants.
* It only requires from 3 to 4 rounds of communication (where one round involves \\( O(n) \\) participants hearing from \\( O(n) \\) participants via the gossip network, so total of \\( O(n^2) \\) communication).
  * This is not true when malicious actor adaptatively try to break liveness.
  * We need to measure properly expected number of rounds if we change the gossiping mechanism.
* It is guaranteed that after one honest participant commits to some value, other honest participants will not commit to a different value.

## The Prototocol

This protocol allows `N` participants achieving consensus on one proposal. At the beginning of the protocol, each participant makes a proposal (proposals can coincide) and gossip it through the network.

Each participant (or node) maintain the prefered proposal in the form of a triplet:

`(primary confidence, outcome, secondary confidence)`

They have for every proposal a confidence (which is not explicetily stored). At the begining of the protocol, every proposal have confidence 0. The triplet stands for:

* `primary confidence`: Highest confidence among all proposals.
* `outcome`: Proposal with highest confidence.
* `secondary confidence`: Highest confidence among all proposals differents from `outcome` (It can be equal to `primary confidence`).


Triplet with highest primary_confidence is prefered, highest secondary confidence is used as first tie-breeaker, and order defined between outcomes is used as final tie-breaker. Among all seen triplets participants state will be the prefered triplet. At the begining of the protocol each node state is (0, v_i, 0), where v_i is its own proposal.

It is important to define a complete and unbiased order for proposals so `outcome` can be uniquely chosen when there are several values with the same highest confidence. In the current implementation each participant have an ID, and their proposal has the form of the tuple `(ID, value)`. `value` can be anything (for example the hash of a block to append in the chain). This works if participants ID are assigned randomly without malicious actor having the chance to bias this assignment.

Using a gossiping mechanism each node shares it current state with other nodes, and after collecting the same prefered state from more than \\( \frac 2 3 \\)  of the total number of participants, the confidence on this `outcome` is increased by 1 and the triplet transfroms from `(A, O, B)` into `(A + 1, O, B)`.

Participants will update its own state after receiving triplets from other participants if the proposed triplet is better than the current triplet, or second highest confidence can increase. If current triplet is `(3, A, 1)` and a node receive triplet `(2, B, 0)` then the next state will be `(3, A, 2)` (Secondary confidence is set to two). We will see specific details about state [later](State.md).

## Proofs. Secure and verifiable triplets

In order for a triplet to be valid, it must carry a proof for both confidences (primary and secondary). Each triplet endorsed by some participant will be signed using BLS signature scheme. This scheme, despite being slow to sign/verify, allows to aggregate signatures fast and verify easily aggregated signatures.

The proof for primary confidence for a triplet `(A, O, B)` consist on the aggregated BLS signature from more than \\( \frac 2 3 \\) of the participants on triplet `(A - 1, O, B)` and the mask that points who were the participants who signed this message. Triplet with zero primary confidence don't require such proof. Since public keys are ... well, public, everyone having the aggregated signature and the mask can verify that the proof is correct.

The proof for secondary confidence is the proof for primary confidence of the state that was responsible of the last secodary confidence update.

## Commit

Participants will commit to some outcome after its primary confidence exceed the secondary confidence by 3 or more margin. Read [Nightshade Whitepaper](https://www.overleaf.com/read/snswgqkjvwvy) to see why this gap of 3 is enough to guarantee that after some node commit to a value, no other node will commit to a different value.

Even if a node have enough evidence to commit soon for some outcome `O` it must remain participating in the protocol, until at least \\( \frac 2 3 \\) of other nodes have committed too. Early exit for the protocol disallow remaining participants from committing, since they will stop receiving updates from some participants.

It is also necessary that participants who have already committed, not only gossip its own state but keep updating it from external gossip as established in the protocol (even if they transition to a non commit state).

### Non blocking state example

This is an example of why participants must follow the protcol even after committing.

* Participant 1, State `(4, A, 1)`: She can already commit to outcome A.
* Participant 2, State `(2, B, 0)`: He can't get from this state to `(4, A, 1)`, because after changing outcome its secondary confidence will be always grater than or equal to 2.
* Participant 1, State `(4, A, 2)`: She must update the secondary confidence after receiving state update from participant 2. Notice that after doing that she has not a committing triplet. But **Nightshade** guarantees that it is not possible for them committing to a different outcome.
* Both participants will commit on triplet on outcome A after arriving at state `(5, A, 2)`.

## Details

* This protocol works with less than \\( \frac 1 3 \\) of byzantine participants.
* We assume that a message sent between a pair of non-byzantines peers will arrive on a finite time (maybe after resending it).
* Since the expected primary confidence to commit should be no much larger than 3, if at some point the confidence for some outcome is greater than \\( (C > 5) \\) and it have not committed yet, participants know almost surely that something is not going well.
* Liveness is an issue in the current protocol, since malicious actors can stall the protocol creating a metastable situation. TODO: Describe how they can move the consensus toward such situation and how we address this problem (wait randoms delay without updating the state for message of several participants).

## Byzantine behaviour

* Failing in unexpected ways. *This is not penalized*. It is expected that nodes go in-n-out of the network: because of network failures, shutting down the node, hardware issues and more.
* Deviating from the protocol. *This should be penalized whenever detected and concrete evidence exists*.