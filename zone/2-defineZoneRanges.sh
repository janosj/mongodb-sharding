source ./demo.conf

echo
echo "Defining Zone Ranges... "
echo

mongosh $MONGOS_URI --eval "

  var data = sh.addTagRange( '$DB.$COLL', 
                             { 'metadata.site': 'site1', 'metadata.sensorID': MinKey },
                             { 'metadata.site': 'site1', 'metadata.sensorID': MaxKey },
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
                 
  data = sh.addTagRange( '$DB.$COLL', 
                         { 'metadata.site': 'site2', 'metadata.sensorID': MinKey },
                         { 'metadata.site': 'site2', 'metadata.sensorID': MaxKey },
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

