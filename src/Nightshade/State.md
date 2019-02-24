# State

The state of each participant is the triplet:

`(Primary Confidence, Outcome, Secondary Confidence)`

TODO:

* Describe how `update_state` (inside `Nigthshade` works). Assumptions. Examples and corner cases
* When we receive a state update from a participant that we don't have its payload we discard it (maybe we don't wanth to do this)
* All posible ways an authority can become an adversary from the point of view of other authority (currently one authority can't frame another as an adversary, but maybe is something we would like to add)
