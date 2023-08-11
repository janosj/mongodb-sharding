source ./demo.conf
echo "Using database $DB."

echo

mongosh $MONGOS_URI --eval "

  db = db.getSiblingDB('$DB')

  var sensorReading1 = {
         metadata: {
            site: 'site1',
            sensorID: 'sensorABC',
         },
         timestamp: ISODate('2023-05-18T00:00:00.000Z'),
         reading: 123.7
      }

  var sensorReading2 = {
         metadata: {
            site: 'site2',
            sensorID: 'sensorXYZ',
         },
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
