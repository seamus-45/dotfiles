#!/usr/bin/python
import psycopg2 as pg
import cracklib
import string
from random import choice
try:
    from config import config
except:
    print('Error: config.py does not exist.')
    exit(1)


def makepasswd(length=16):
    chars = string.letters + string.digits
    return ''.join(choice(chars) for _ in range(length))


def update_pass(conn, login):
    """
        Generate random password
    """
    cur = conn.cursor()
    cur.execute("UPDATE users set password = %s WHERE login = %s", (makepasswd(), login))
    conn.commit()
    cur.close


cracklib.MIN_LENGTH = 6

conn = pg.connect(**config)
cur = conn.cursor()

cur.execute("SELECT login,password FROM users;")
row = cur.fetchone()
while row is not None:
    login, password = row
    #if password[:7] == 'blocked':
    #    update_pass(conn, login)
    try:
        cracklib.FascistCheck(password)
    except ValueError as e:
        print "{0:40}{1:20}{2}".format(login, password, e.message)
    row = cur.fetchone()
cur.close
conn.close
