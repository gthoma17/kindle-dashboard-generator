# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START calendar_quickstart]
from __future__ import print_function

import datetime
import os.path
import pytz
import json


from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

STEP_SIZE = datetime.timedelta(minutes=30)
NUM_ROWS = 15

# If modifying these scopes, delete the file token.json.
SCOPES = ['https://www.googleapis.com/auth/calendar.readonly']

def handleAuth():
    creds = None
    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=52531)
        # Save the credentials for the next run
        with open('token.json', 'w') as token:
            token.write(creds.to_json())
    return creds

def getEvents(timeMin, calendarId, pageSize, service):
    events_result = service.events().list(calendarId=calendarId, timeMin=timeMin,
                                              maxResults=pageSize, singleEvents=True,
                                              orderBy='startTime').execute()
    return events_result.get('items', [])

def transformEvent(event):
    return {
        "name": event['summary'], 
        "start": event['start']['dateTime'], 
        "end": event['end']['dateTime'] 
    }

def getEventsForCalendarInRange(calendarId, minTime, maxTime, service):
    events = getEvents(minTime.isoformat() + 'Z', calendarId, 10, service)

    lastEventTime = datetime.datetime.fromisoformat(events[-1]['start']['dateTime'])
    while datetime.datetime.fromisoformat(events[-1]['start']['dateTime']) < maxTime:
        moreEvents = getEvents(lastEventTime.isoformat(), calendarId, 10, service)
        events = events + moreEvents
        lastEventTime = datetime.datetime.fromisoformat(events[-1]['start']['dateTime'])

    return [transformEvent(e) for e in events]


def main():
    """Shows basic usage of the Google Calendar API.
    Prints the start and name of the next 10 events on the user's calendar.
    """

    creds = handleAuth()

    try:
        service = build('calendar', 'v3', credentials=creds)

        minTime = datetime.datetime.utcnow() - datetime.timedelta(hours=36)
        maxTime = pytz.utc.localize(datetime.datetime.utcnow() + datetime.timedelta(hours=36))

        revaEvents = getEventsForCalendarInRange('pen2345678@gmail.com', minTime, maxTime, service)
        gregEvents = getEventsForCalendarInRange('gatlp9@gmail.com', minTime, maxTime, service)
        
        sharedEvents = [e for e in revaEvents if e in gregEvents]

        #remove shared events from individual's lists
        gregEvents = [e for e in gregEvents if e not in sharedEvents]
        revaEvents = [e for e in revaEvents if e not in sharedEvents]

        agenda = {
            "greg": gregEvents,
            "reva": revaEvents,
            "shared": sharedEvents
        }

        with open('agenda.json', 'w') as f:
            json.dump(agenda, f)

    except HttpError as error:
        print('An error occurred: %s' % error)


if __name__ == '__main__':
    main()
