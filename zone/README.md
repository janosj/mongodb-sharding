# Zone Sharding

This collection of scripts illustrates how to configure zone sharding, for both regular and time series collections. Zone sharding is a way of applying tags (i.e. zones) to a subset of shards with a MongoDB Sharded Cluster, and directing writes to specific shards on the basis of those tags. It can be used to support a variety of use cases, including directing writes to local data centers or specialized hardware. 

Zone Sharding is covered [here](https://www.mongodb.com/docs/manual/core/zone-sharding/) in the MongoDB docs. 

## Prerequisites

- A MongoDB sharded cluster with 2 shards. You can deploy such a cluster using either MongoDB Atlas or self-managed MongoDB. These scripts establish two zones, `US` and `WORLD`, mapping a single shard to each zone. This demo was written and tested using MongoDB 6.x.

- Mongosh is required, to execute the scripts. 

## Running the Demo

### 1. Update project settings

Update `demo.conf` with your MongoDB connect string (to the mongos). Additionally, the names of the shards *must* match your environment. During setup, the US and WORLD zones will be mapped to these specific shards, which must exist in your cluster. Adjusting the names of the demo database and collection is optional - as provided, data will be written to `zoneDB.sensorData`.

### 2. Decide on regular collections vs. time series collections

Any type of data or application can utilize zone sharding, as long as the incoming data contains some field and accompanying rule to direct the write to the appropriate zone. If the data contains a time value, it may be a candidate to be stored in a MongoDB Time Series Collection. For more information about Time Series Collections, see [here](https://www.mongodb.com/docs/manual/core/timeseries-collections/). 

Time Series Collections have certain structural requirements. The data format used by the `insertData.sh` script was specifically designed with these requirements in mind, and so when you run the script you can choose whether to store the data in a regular collection or a time series collection. Time Series Collections do support zone sharding, but some of configuration steps need to be tailored. When runnning `defineZoneRanges` and `shardCollection`, use *either* the regular version or the time series version. 

### 3. Execute the scripts and validate the results

Execute the scripts in sequence to tag the shards with zone labels, map data values to the zones, shard the document collection, and insert the test data. The test data is intentionally minimal - only two records are inserted, one for each zone. To query the complete data set, connect to the mongos (using *mongosh*) and query the entire collection. To verify that the data was routed as expected, attach to the individual shards and query the collection. When using Time Series Collections, note that the underlying collection on the individual shards is actually a system-created bucket collection and not the collection that was explicitly created (which is actually stored as a view). 

