# Testing a Site Failure

Note [here](https://www.mongodb.com/docs/manual/tutorial/troubleshoot-sharded-clusters/#all-members-of-a-shard-become-unavailable) in the docs ("Troubleshooting Sharded Clusters: All Members of a Shard Become Unavailable") that when a shard becomes unavailable, all the data in that shard becomes unavailable but the data on the other shards remains available. For example, if zone 2 goes down you should still be able to query zone 1. *That is only true for targeted queries.* Non-targeted scatter-gather queries will produce an error:

> encountered non-retryable error during query: caused by: Could not find host matching read preference (mode: "primary") for set shard01".

Queries targeted at the available shards *using the full compound shard key* will continue processing queries (including writes).

To test this behavior: 

1. Launch the cluster and perform all setup steps, up through loading the minimal sample data records. 

2. Simulate a site failure: 
```
mlaunch kill shard02
````

3. Log in to the mongosh:
```
mongosh --port 27017
```

4. Run queries to examine the data. For example, with site 2 down:
```
use zoneDB

# A scatter-gather query fails:
db.sensorData.find()

# A targeted query on site 1 using the full shard key succeeds:
db.sensorData.find( {"metadata.site": "site1", "metadata.sensorID": "sensorABC"} )
```

5. Recover the site and verify things are fully operational:
```
mlaunch start shard02
```

Targeted queries that use a partial shard key can also return partial data from any available shards, but care must be taken when defining the tag ranges. The ranges defined in `2-defineZoneRanges.sh`, which follows the [tutorial](https://www.mongodb.com/docs/manual/tutorial/sharding-segmenting-data-by-location/) ("Segmenting Data by Location"), will not work if you query the data using the zone only without also specifying a sensorID. You can verify this by killing zone 2 and then executing the following query: 
```
db.sensorData.find( {"metadata.site": "site1"} )
```

This query will succeed if you define the tag ranges provided in `defineZoneRanges.BETTER.sh`.

This only applies to regular collections. With time series collections, the view definition is stored on the primary shard. If this shard becomes unavailable, no data can be returned. See [SERVER-80914](https://jira.mongodb.org/browse/SERVER-80914).

