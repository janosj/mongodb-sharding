source ./demo.conf
echo "Using database $DB."

echo

# MongoDB Atlas requires a mandatory 'location' attribute
# that constitutes the basis for mapping documents to zones.
# 'sensorID' can be used as the second shard key field.
# See here:
# https://www.mongodb.com/docs/atlas/shard-global-collection/

# Connect to the individual shards to verify documents are being
# routed to the appropriate zone. 
# Note: Atlas connections require the --tls flag.
# See here: https://kb.corp.mongodb.com/article/000021064


mongosh $MONGOS_URI --eval "

  db = db.getSiblingDB('$DB')

  var sensorReading1 = {
         location: 'US-DC',
         sensorID: 'sensorABC',
         timestamp: ISODate('2023-05-18T00:00:00.000Z'),
         reading: 123.7
      }

  var sensorReading2 = {
         location: 'US-HI',
         sensorID: 'sensorXYZ',
         timestamp: ISODate('2023-05-18T00:30:00.000Z'),
         reading: 93.2
      }

  console.log('Inserting record at site 1...');
  db.$COLL.insertOne( sensorReading1 );

  console.log('Inserting record at site 2...');
  db.$COLL.insertOne( sensorReading2 );

  // Done simply to avoid misleading output - 
  // only output from the last command is shown.
  console.log('Querying collection:');
  db.$COLL.find();

"

echo
