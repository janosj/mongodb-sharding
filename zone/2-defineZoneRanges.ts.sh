source ./demo.conf

echo
echo "Defining Zone Ranges... "
echo

mongosh $MONGOS_URI --eval "

  // Note the differences here: 
  //   1) the user-facing collection is replaced by the underlying bucket.
  //   2) 'meta' replaces 'metadata', based on the underlying bucket schema.
  var data = sh.addTagRange( '$DB.system.buckets.$COLL', 
                             { 'meta.site': 'site1', 'meta.sensorID': MinKey },
                             { 'meta.site': 'site1', 'meta.sensorID': MaxKey },
                             'US' );
  //printjson(data);
  if (data.ok == 1) {
    console.log('Zone range for US zone created.');
    console.log('Anything originating at site1 goes to US zone.');
    console.log('US zone might contain multiple shards (shards are tagged with a zone).');
  } else { 
    throw new Error('US zone range was NOT created successfully!');
  }
  console.log();
  
  // Note the differences (see above).
  data = sh.addTagRange( '$DB.system.buckets.$COLL', 
                         { 'meta.site': 'site2', 'meta.sensorID': MinKey },
                         { 'meta.site': 'site2', 'meta.sensorID': MaxKey },
                         'WORLD' );
  //printjson(data);
  if (data.ok == 1) {
    console.log('Zone range for WORLD zone created.');
    console.log('Anything originating at site2 goes to WORLD zone.');
    console.log('WORLD zone might contain multiple shards (shards are tagged with a zone).');
  } else {
    throw new Error('WORLD zone range was NOT created successfully!');
  }

  console.log();

  db = db.getSiblingDB('config');

  console.log('Listing all tag ranges for US zone:');
  data = db.tags.find({ tag: 'US' });
  data.forEach(printjson);
  
  console.log();

  console.log('Listing all tag ranges for WORLD zone:');
  data = db.tags.find({ tag: 'WORLD' });
  data.forEach(printjson);

  console.log();

"

echo

