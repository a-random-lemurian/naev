#!/bin/python3

# STEAM 2FA SCRIPT FOR NAEV
# Requires Python3
# TFA_USER, TFA_PASS, TFA_IMAP should be exported before running
#
# This script should be run after querying for a Steam Guard code (attempting to login)
# The 2FA code will be saved to a file called "2fa.txt" in the same directory as this python script is located.
#

import imaplib
import email
import os

# account credentials
user = os.environ['TFA_USER']
password = os.environ['TFA_PASS']
imap_url = os.environ['TFA_IMAP']

with open(os.path.join(os.path.dirname(__file__), "2fa.txt"), "w") as file:
    # try to create IMAP connection and login
    connection = imaplib.IMAP4_SSL(imap_url)
    try:
        connection.login(user, password)
    except:
        print("Could not connect to IMAP server, check credentials or server status")
        exit(1)

    # Select default mailbox and search for all messages
    try:
        connection.select()
        result, data = connection.uid('search', None, "ALL")
    except:
        print("Could not search the mailbox.. something is definitely wrong")
        exit(1)

    body = ""

    # if successful, fetch the top 1 mail message (newest)
    if result == 'OK':
        for num in data[0].split()[-1:]:
            result, data = connection.uid('fetch', num, '(RFC822)')

            # If fetching the message succeeds, parse the message.
            if result == 'OK':
                email_message = email.message_from_bytes(data[0][1])
                if email_message.is_multipart():
                    for payload in email_message.get_payload():

                        # Assemble the body of the message if the message is a multipart one
                        body += str((payload.get_payload()))
                else:
                    # Assemble the body of the message
                    body = str(email_message.get_payload())

                # Write parsed TFA code to file
                file.write(str(body.split('\n')[5])+"\n")
            else:
                print("Could not parse the message for some reason..")
                exit(1)
    else:
        print("Could not find any messages.. something has gone wrong.")
        exit(1)

connection.close()
connection.logout()
