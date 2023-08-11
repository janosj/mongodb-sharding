# See here (Segmenting Data by Location):
# https://www.mongodb.com/docs/v5.0/tutorial/sharding-segmenting-data-by-location/

# Note: Sharding the collection is a required step that is missing from the tutorial.
# See here: https://www.mongodb.com/docs/manual/tutorial/deploy-shard-cluster/#shard-a-collection

# Enabling sharding on the database is no longer required. See here (5.0 docs):
# https://www.mongodb.com/docs/v5.0/tutorial/deploy-shard-cluster/#enable-sharding-for-a-database


source demo.conf

echo

mongosh $MONGOS_URI --eval "

  sh.shardCollection( '$DB.$COLL', {'metadata.site':1, 'metadata.sensorID': 1} );

"

echo
