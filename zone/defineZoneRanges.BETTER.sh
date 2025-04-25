# This is a better way to define the tag ranges than that provided in "defineZoneRanges.sh". 
# This improved configuration allows queries using partial shard keys 
# to continue functioning in the presence of a site failure.
# See "testSiteFailure.md" for details.

# Note: remove any existing tag ranges before applying this configuration.


source ./demo.conf

echo
echo "Defining Zone Ranges... "
echo

mongosh $MONGOS_URI --eval "

  var data = sh.addTagRange( '$DB.$COLL',
                                { 'metadata.site': MinKey, 'metadata.sensorID': MinKey },
                                { 'metadata.site': 'site1', 'metadata.sensorID': MinKey },
                                'US' );

  //printjson(data);
  if (data.ok == 1) {
    console.log('Zone Range 0 created.');
  } else {
    throw new Error('Zone Range 0 was NOT created successfully!');
  }
  console.log();

  var data = sh.addTagRange( '$DB.$COLL', 
                             { 'metadata.site': 'site1', 'metadata.sensorID': MinKey },
                             { 'metadata.site': 'site2', 'metadata.sensorID': MinKey },
                             'US' );

  //printjson(data);
  if (data.ok == 1) {
    console.log('Zone Range 1 created.');
  } else {
    throw new Error('Zone Range 1 was NOT created successfully!');
  }
  console.log();
  
  var data = sh.addTagRange( '$DB.$COLL', 
                                    { 'metadata.site': 'site2', 'metadata.sensorID': MinKey },
                                    { 'metadata.site': MaxKey, 'metadata.sensorID': MaxKey },
                                    'WORLD' );

  //printjson(data);
  if (data.ok == 1) { 
    console.log('Zone Range 2 created.');
  } else {
    throw new Error('Zone Range 2 was NOT created successfully!');
  }
  console.log();

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

