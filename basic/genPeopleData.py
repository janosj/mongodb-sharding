#!/usr/bin/env python3
# call with parameter: MongoDB URI.

# This is a modified version of code first created by Guillaume Meister.
# See here: https://github.com/10gen/pov-proof-exercises/tree/master/proofs/06

# Bulk insert code comes straight out of the docs.
# See here: https://pymongo.readthedocs.io/en/stable/tutorial.html#bulk-inserts

import random
import sys
import time
from multiprocessing import Process
from faker import Factory
from pymongo import MongoClient, WriteConcern
from pymongo.errors import BulkWriteError, PyMongoError

# for country codes
ccFile = "countryCodes.txt"

SHARD_COUNT = 3
DOCS_PER_SHARD = 100000
BATCH_SIZE = 1000

# Number of processes to launch
processesNumber = SHARD_COUNT
processesList = []

# Settings for Faker, change locale to create other language data
fake = Factory.create('en_US')

# loads all country codes from file
def read_country_codes():
    with open(ccFile) as f:
        codes = f.read().splitlines()
    print("read", str(len(codes)), "country codes from file", ccFile)
    return codes

# Main processes code
def run(process_id, uri, codes):
    country_codes_count = len(codes)

    print("process", process_id, "connecting to MongoDB...")
    mdbClient = MongoClient(host=uri, socketTimeoutMS=10000, connectTimeoutMS=10000, serverSelectionTimeoutMS=10000)
    targetDatabase = mdbClient.shardDB
    targetCollection = targetDatabase.people

    docList = []
    for j in range(DOCS_PER_SHARD):
        docList.append({
            "process": process_id,
            "index": j,
            "lastName": fake.last_name(),
            "firstName": fake.first_name(),
            "ssn": fake.ssn(),
            "job": fake.job(),
            "phone": [
                {"type": "home", "number": fake.phone_number()},
                {"type": "cell", "number": fake.phone_number()}
            ],
            "address": {
                "street": fake.street_address(),
                "city": fake.city()
            },
            "revenue": random.randint(50000, 250000),
            "age": random.randint(20, 60),
            "location": codes[random.randint(1, country_codes_count - 1)]
        })

        if ( (j + 1) % BATCH_SIZE == 0 ) or ( (j + 1) == DOCS_PER_SHARD ) :
            try:
                result = targetCollection.insert_many(docList)
                print('%s - process %s - records %s' % (time.strftime("%H:%M:%S"), process_id, j + 1))
                docList = []
            except BulkWriteError as bwe:
                print(bwe.details)
                print("Process {process_id} died - fix the issue as not all data will have loaded")
                sys.exit(1)
            except PyMongoError as e:
                print("failed to write to MongoDB cluster with URI", uri, "with error", e)
                print("Process {process_id} died - fix the issue as not all data will have loaded")
                sys.exit(2)


# Main
if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("You forgot the MongoDB URI parameter!")
        print(" - example: mongodb://mongo1,mongo2,mongo3/test?replicaSet=replicaTest&retryWrites=true")
        print(" - example: mongodb+srv://user:password@cluster0-abcde.mongodb.net/test?retryWrites=true")
        exit(1)
    mongodb_uri = str(sys.argv[1])

    country_codes = read_country_codes()

    print("launching", str(processesNumber), "processes...")

    # Creation of processesNumber processes
    for i in range(processesNumber):
        process = Process(target=run, args=(i, mongodb_uri, country_codes))
        processesList.append(process)

    # launch processes
    for process in processesList:
        process.start()

    # wait for processes to complete
    for process in processesList:
        process.join()

