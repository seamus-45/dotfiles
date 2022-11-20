#!/usr/bin/env python
# Source: https://framagit.org/DanaruDev/UnseenMail/
from apiclient.discovery import build
from httplib2 import Http
from oauth2client import file, client, tools

import imaplib
import yaml
import os
import socket
import time

dirname = os.path.split(os.path.abspath(__file__))[0]
config_path = os.path.abspath(dirname + '/accounts.yml')
strFormatted = ""
tryConnectWeb = 0
isConnectedToWeb = False

def check_connection():
    try:
        socket.create_connection(("www.qwant.com", 80))
        return True
    except OSError:
        try:
            socket.create_connection(("www.wikipedia.com", 80))
            return True
        except OSError:
            return False


def check_imap(imap_account):
    if imap_account["useSSL"] == "true":
        client = imaplib.IMAP4_SSL(imap_account["host"], int(imap_account["port"]))
    else:
        client = imaplib.IMAP4(imap_account["host"], int(imap_account["port"]))
    try:
        client.login(imap_account["login"], imap_account["password"])
        client.select()
        return len(client.search(None, 'UNSEEN')[1][0].split())
    except OSError:
        return -1


def check_gmail(gmail_account):
    scopes = 'https://www.googleapis.com/auth/gmail.readonly'
    credential_file = os.path.abspath(dirname + '/gmail/' + gmail_account + '.json')
    store = file.Storage(credential_file)
    credentials = store.get()
    if not credentials or credentials.invalid:
        flow = client.flow_from_clientsecrets(os.path.abspath(dirname + '/gmail/client_secret.json'), scopes)
        credentials = tools.run_flow(flow, store)
    try:
        service = build('gmail', 'v1', http=credentials.authorize(Http()))
        labels = service.users().labels().get(userId='me', id='INBOX').execute()
        return labels["messagesUnread"]
    except OSError:
        return -1


# load config
if os.path.isfile(config_path):
    with open(config_path, "r") as conf:
        config = yaml.safe_load(conf)
        accounts = config['accounts']
        settings = config['settings']

isConnectedToWeb = check_connection()
while not isConnectedToWeb and tryConnectWeb < 4:
    tryConnectWeb += 1
    time.sleep(2)
    isConnectedToWeb = check_connection()

if not isConnectedToWeb:
    print("No internet connection")
else:
    for account in accounts:
        currentAccount = accounts[account]
        if currentAccount['protocol'] == "GmailAPI":
            unread = check_gmail(account)
        else:
            unread = check_imap(currentAccount)
        icon = 'icon-unread' if unread > 0 else 'icon-empty'
        if icon in currentAccount:
            icon = currentAccount[icon]
        else:
            icon = settings[icon]
        strFormatted += icon + " " + str(unread) + " "
    print(strFormatted.rstrip())
