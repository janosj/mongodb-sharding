source ./demo.conf

echo
echo "Mapping Shards to Zones (via tags)... "
echo

mongosh $MONGOS_URI --eval "

  sh.addShardTag('$SHARD0', 'US');
  sh.addShardTag('$SHARD1', 'WORLD');

  console.log();
  console.log('Finished mapping shards to zones (via tags).');
  console.log();

  db = db.getSiblingDB('config');

  console.log('Listing all shards in US zone:');
  var data = db.shards.find({ tags: 'US' });
  data.forEach(printjson);

  console.log();

  console.log('Listing all shards in WORLD zone:');
  data = db.shards.find({ tags: 'WORLD'});
  data.forEach(printjson);

  console.log();

"

