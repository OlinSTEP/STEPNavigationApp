import json
import os
from firebase_functions import params, scheduler_fn
from firebase_functions.alerts import (
    app_distribution_fn,
    crashlytics_fn,
    performance_fn,
)
import urllib
import google.auth.transport.requests
import google.auth.transport.requests
from google.auth.transport.requests import AuthorizedSession
import google.oauth2.id_token
from google.oauth2 import service_account

def extend_token(authed_session, anchor_id, new_expiration_time):
    response = authed_session.request('PATCH',
                                      'https://arcorecloudanchor.googleapis.com/v1beta2/management/anchors/' + anchor_id + '?updateMask=expire_time',
                                      data='{ "expireTime": "' + new_expiration_time  + '"}',
                                      headers={'Content-Type': 'application/json'})
    print(response)
    print(response.content)


def main():
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "invisible-map-d42125204dbe.json"

    credentials = service_account.Credentials.from_service_account_file('invisible-map-d42125204dbe.json', scopes=['https://www.googleapis.com/auth/arcore.management'])
    authed_session = AuthorizedSession(credentials)
    next_page_token = None
    while True:
        print(next_page_token)
        if next_page_token is not None:
            response = authed_session.request('GET', 'https://arcorecloudanchor.googleapis.com/v1beta2/management/anchors?page_size=100&order_by=expire_time%20asc&pageToken=' + next_page_token)
        else:
            response = authed_session.request('GET', 'https://arcorecloudanchor.googleapis.com/v1beta2/management/anchors?page_size=100&order_by=expire_time%20asc')

        data = json.loads(response.content)
        for anchor in data['anchors']:
            if anchor['expireTime'] != anchor['maximumExpireTime']:
                extend_token(authed_session, os.path.basename(anchor['name']), anchor['maximumExpireTime'])
        if 'nextPageToken' not in data:
            return
        else:
            next_page_token = data['nextPageToken']

# Run once a day at midnight, to clean up inactive users.
# Manually run the task here https://console.cloud.google.com/cloudscheduler
@scheduler_fn.on_schedule(schedule="0 * * * *")
def extend_cloud_anchors(event: scheduler_fn.ScheduledEvent) -> None:
    """Extend cloud anchors"""
    main()

if __name__ == '__main__':
    main()
