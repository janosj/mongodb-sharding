# Note: Sharding the collection is a required step that is missing from the tutorial.
# See here: https://www.mongodb.com/docs/manual/tutorial/deploy-shard-cluster/#shard-a-collection

source ./demo.conf

echo

mongosh $MONGOS_URI --eval "

  sh.shardCollection( '$DB.$COLL', {'metadata.site':1, 'metadata.sensorID': 1} );

"

echo
