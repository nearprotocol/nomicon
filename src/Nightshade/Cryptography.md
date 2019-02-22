# Cryptography

Participant should sign every message they sent through the network using its public key.

* [ed25519](https://github.com/exonum/exonum_sodiumoxide) signature is used for gossips, it is very fast signing/verifying.
* [BLS](https://en.wikipedia.org/wiki/Boneh%E2%80%93Lynn%E2%80%93Shacham) to sign triplets inside Nigthshade Consensus.
    * Useful because it allow us to run a [threshold scheme](https://en.wikipedia.org/wiki/Threshold_cryptosystem).
    * Slow signing/verifying.