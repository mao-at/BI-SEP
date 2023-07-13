import asyncio
import time
import os
import uuid
import datetime
import random
import json
from azure.eventhub import EventHubProducerClient, EventData

start_time = time.time()

# create a producer client
producer = EventHubProducerClient.from_connection_string(
    conn_str="Endpoint=sb://septsep.servicebus.windows.net/;SharedAccessKeyName=sepdemo;SharedAccessKey=xenvUbM+jUGfpnZjCF9FiXUOrn6UlAhHspVB84/hrc8=;EntityPath=myhub",
    eventhub_name="myhub"
)
to_send_message_cnt = 50
bytes_per_message = 256

# create 10 devices
devices = []
for i in range(0, 10):
    devices.append(str(uuid.uuid4()))

with producer:
    for i in range(to_send_message_cnt):
        time.sleep(1)
        reading = {'id': devices[random.randint(0, len(devices) - 1)], 'timestamp': str(datetime.datetime.utcnow()),
                   'uv': random.random(), 'temperature': random.randint(70, 100), 'humidity': random.randint(70, 100)}
        s = json.dumps(reading)

        event_data_batch = producer.create_batch()
        while len(event_data_batch) == 0:
            event_data_batch.add(EventData(s))
        producer.send_batch(event_data_batch)
        print("Send messages in {} seconds.".format(time.time() - start_time))
