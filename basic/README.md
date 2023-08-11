# Sharding Exercise

This exercise steps through some fundamentals of MongoDB sharding. To use, first deploy a 3-shard cluster (you can use Atlas or Ops Manager, or deploy it manually). Then, configure sharding with the scripts contained here, which will create a collection and pre-splits the single chunk into 3 (1 for each shard). The shard key is the process ID – the data loader will spawn 3 processes and each process will end up writing to its own shard. The shards will grow and grow – they cannot be split because the shard key is the process ID and thus indivisible (making it a bad choice). The next step (not currently scripted) would be to refine the shard key to allow auto-splitting and chunk redistribution by the balancer.

