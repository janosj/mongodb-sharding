# Zone Sharding

This collection of scripts illustrates how to configure zone sharding, for both regular and time series collections. Zone sharding is a way of applying tags (i.e. zones) to a subset of shards with a MongoDB Sharded Cluster, and directing writes to specific shards on the basis of those tags. It can be used to support a variety of use cases, including directing writes to local data centers or specialized hardware. 

Zone Sharding is covered [here](https://www.mongodb.com/docs/manual/core/zone-sharding/) in the MongoDB docs. Other helpful documentation: 
- Tutorial: "Segmenting Data by Location" ([link](https://www.mongodb.com/docs/manual/tutorial/sharding-segmenting-data-by-location/)). This is the best starting point.

- That tutorial omits sharding the collection, a required step. See [here](https://www.mongodb.com/docs/manual/tutorial/deploy-shard-cluster/#shard-a-collection).

- Enabling sharding on the database is no longer a required step. See [here](https://www.mongodb.com/docs/v5.0/tutorial/deploy-shard-cluster/#enable-sharding-for-a-database) in the 5.0 docs.


## Prerequisites

These scripts establish two zones, `US` and `WORLD`, on a Sharded Cluster with two shards, mapping a single shard to each zone. There are many ways to deploy such a test cluster. See notes below if using MongoDB Atlas. Otherwise, you can deploy it locally. This demo was written and tested using a MongoDB 6.x sharded cluster, deployed using *mlaunch* (one of the utilities included with *mtools* - see [here](https://rueckstiess.github.io/mtools/mlaunch.html)). Your *mlaunch* command should resemble the following:

```
mlaunch --replicaset --nodes 1 --sharded 2 --config 1 --binarypath $HOME/.local/m/versions/6.0.6-ent/bin
```

Mongosh is also required, to execute the scripts. 

## Running the Demo

### 1. Update project settings

Update `demo.conf` with your MongoDB connect string (to the mongos). Additionally, the names of the shards *must* match your environment. During setup, the US and WORLD zones will be mapped to these specific shards, which must exist in your cluster. Adjusting the names of the demo database and collection is optional - as provided, data will be written to `zoneDB.sensorData`.

### 2. Decide on regular collections vs. time series collections

Any type of data or application can utilize zone sharding, as long as the incoming data contains some field and accompanying rule to direct the write to the appropriate zone. If the data contains a time value, it may be a candidate to be stored in a MongoDB Time Series Collection. For more information about Time Series Collections, see [here](https://www.mongodb.com/docs/manual/core/timeseries-collections/). 

Time Series Collections have certain structural requirements. The data format used by the `insertData.sh` script was specifically designed with these requirements in mind, so you can choose which type of collection you want to use. Time Series Collections do support zone sharding, but some configuration steps need to be tailored. When runnning `defineZoneRanges` and `shardCollection`, use *either* the regular version or the time series version. 

### 3. Execute the scripts and validate the results

Execute the scripts in sequence to tag the shards with zone labels, map data values to the zones, shard the document collection, and insert the test data. The test data is intentionally minimal - only two records are inserted, one for each zone. To query the complete data set, connect to the mongos (using *mongosh*) and query the entire collection. To verify that the data was routed as expected, attach to the individual shards and query the collection. When using Time Series Collections, note that the underlying collection on the individual shards is actually a system-created bucket collection and not the collection that was explicitly created (which is actually stored as a view). 

## MongoDB Atlas

If using MongoDB Atlas, you can use the scripts provided here in conjunction with a (2 shard) sharded Atlas cluster. Alternatively, however, Atlas also supports Global Clusters with multiple zones and multiple shards per zone: 

- Zones and associated tags are configured during cluster deployment. 
- You then define (also through the Atlas UI) a compound shard key to shard the collection. 
- The first shard key field is a mandatory document attribute ('location') that is used to map documents to a corresponding zone. After sharding the collection, Atlas provides a table of location values and corresponding zones (also available [here](https://cloud.mongodb.com/static/atlas/country_iso_codes.txt)).
- The second shard key field is user-defined. 

If using an Atlas Global Cluster, perform the necessary zone setup steps using the Atlas UI, rather than the scripts provided here. `insertDataAtlas.sh` can then be used to generate some minimal test data. To inspect this data, connect to the individual shards. Note: the --tls flag is required when connecting to the individual shards in Atlas (see [here](https://kb.corp.mongodb.com/article/000021064)).
