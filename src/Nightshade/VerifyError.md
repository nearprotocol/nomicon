# State errors

This cover all possible way in which a state verification might fail. If the verification fails the participant sending this state must be considered adversarial (since he signs the gossip containing this state).

```rust,ignored
pub enum NSVerifyErr {
    // Bad formed triplet. Primary confidence must be equal or greater than secondary confidence.
    // Both confidence must be non negative integers.
    InvalidTriplet,
    // Bls signature provided doesn't match against bls public key + triplet data
    InvalidBlsSignature,
    // Proof doesn't contain enough signatures to increase confidence
    MissingSignatures,
    // Proofs provided are incorrect. Aggregated signature doesn't match with aggregated public keys + triplet data
    InvalidProof,
    // The proof for the current triplet is wrong. Confidence/Outcomes are not valid.
    InconsistentState,
    // There is a proof for a triplet that doesn't require it.
    ExtraProof,
    // Triplet requires a proof that is not present
    MissingProof,
}
```