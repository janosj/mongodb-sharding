# Sharding a Time Series Collection:
# https://www.mongodb.com/docs/manual/core/timeseries/timeseries-shard-collection/

source ./demo.conf

echo

mongosh $MONGOS_URI --eval "

  sh.shardCollection(
      '$DB.$COLL',
      { 'metadata.site': 1, 'metadata.sensorID': 1 },
      {
         timeseries: {
            timeField: 'timestamp',
            metaField: 'metadata',
            granularity: 'hours'
         }
      }
  )

"

echo

