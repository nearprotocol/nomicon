# Cryptography

Participant should sign every message they sent through the network using its public key.

## [ed25519](https://github.com/exonum/exonum_sodiumoxide)

This scheme is used to sign gossip in the network layer. This are fast verifiable signatures.

* Gossips with invalid signatures are discarded
* Gossips with valid signatures are processed. If they contain invalid content (deviating from the protocol in anyway), the signature and the content of the gossip is used as evidence for the sender as malicious actor.

## [BLS](https://en.wikipedia.org/wiki/Boneh%E2%80%93Lynn%E2%80%93Shacham)

BLS is used to sign triplets in [Nightshade Consensus](Nightshade/Nightshade.md).

* Each triplet contain the BLS signature of the holder.
* The proof for the triplets are the aggregated signatures of the participants.
* Useful because it allow us to run a [threshold scheme](https://en.wikipedia.org/wiki/Threshold_cryptosystem).
* Slow signing/verifying. TODO: Link our benchmark.