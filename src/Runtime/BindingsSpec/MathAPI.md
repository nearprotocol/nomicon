# Math

```rust
random_seed(register_id: u64)
```
Returns random seed that can be used for pseudo-random number generation in deterministic way.

###### Panics
* If the size of the registers exceed the set limit `MemoryAccessViolation`;

---
```rust
sha256(value_len: u64, value_ptr: u64, register_id: u64)
```
Hashes the random sequence of bytes using sha256 and returns it into `register_id`.
###### Panics
* If `value_len + value_ptr` points outside the memory or the registers use more memory than the limit with `MemoryAccessViolation`.

###### Current bugs
* Current name `hash` is not specific to what hash is being used.
* We have `hash32` that largely duplicates the mechanics of `hash` because it returns the first 4 bytes only.

---
```rust
check_ethash(block_number_ptr: u64,
             header_hash_ptr: u64,
             nonce: u64,
             mix_hash_ptr: u64,
             difficulty_ptr: u64) -> u64
```
-- verifies hash of the header that we created using [Ethash](https://en.wikipedia.org/wiki/Ethash). Parameters are:
* `block_number` -- `u256`/`[u64; 4]`, number of the block on Ethereum blockchain. We use the pointer to the slice of 32 bytes on guest memory;
* `header_hash` -- `h256`/`[u8; 32]`, hash of the header on Ethereum blockchain. We use the pointer to the slice of 32 bytes on guest memory;
* `nonce` -- `u64`/`h64`/`[u8; 8]`, nonce that was used to find the correct hash, passed as `u64` without pointers;
* `mix_hash` -- `h256`/`[u8; 32]`, special hash that avoid griefing attack. We use the pointer to the slice of 32 bytes on guest memory;
* `difficulty` -- `u256`/`[u64; 4]`, the difficulty of mining the block. We use the pointer to the slice of 32 bytes on guest memory;

###### Returns
* `1` if the Ethash is valid;
* `0` otherwise.

###### Panics
* If `block_number_ptr + 32` or `header_hash_ptr + 32` or `mix_hash_ptr + 32` or `difficulty_ptr + 32` point outside the memory or registers use more memory than the limit with `MemoryAccessViolation`.

###### Current bugs
* `block_number` and `difficulty` are currently exposed as `u64` which are casted to `u256` which breaks Ethereum compatibility;
* Currently, we also pass the length together with `header_hash_ptr` and `mix_hash_ptr` which is not necessary since
we know their length.
