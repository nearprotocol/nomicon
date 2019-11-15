# Events

We allow developers to subscribe events that happen on blockchain. Events
on blockchain are, from a developer perspective, just state changes. 
More specifically, an event is defined as the change to a prefix in state.
If a prefix is subscribed to, when transactions are applied, runtime will check
whether there is any key or value change for all the (key, value) pairs stored
under the prefix and push the changes, i.e, a hashmap of keys to new values,
 to the subscription channel (TBD).

Notice that because we push the change after applying transactions
in every chunk, subscription can only reflect changes that happen on
the chunk level, i.e, if a key is changed multiple times in the same
chunk, only the last change will be recorded. 

Also, given the nature of subscription as a service that pushes data to the subscriber,
the node will reject request
to subscribing to a prefix that it doesn't have state for, instead of routing to 
other peers. The subscriptions will also not be persisted in storage.
However, we will also provide the ability to query state change
for a given block through rpc. Therefore, if a developer cares about 
the reliability of the subscription, they should opt to a polling model
where they query the node for state changes in blocks.
