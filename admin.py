#!/usr/bin/python3

# -*- coding: UTF-8 -*-

import firebirdsql
from pathlib import Path
import os
import cgi
import cgitb

cgitb.enable()
print('Content-Type: text/html\n')
arguments = cgi.FieldStorage()
print(arguments["site NAME"].value)
print("<br />\n")
print(arguments["site URL"].value)
print("<br />\n")
name = arguments["sitename"].value
site = arguments["siteurl"].value

orgID = input('Please type Organisation ID number')

conn = firebirdsql.connect(
       host='DB server IP',
       database='dir of DB',
       port='Port N0',
       user='DB Username',
       password='Password'
   )
cur = conn.cursor()
cur.execute("insert into todo (id, datestamp, {orgID}, {site}, {name}, controllip, status, lastupdate, msg) values ((select max(id)+1 from todo), %d, %d, '%s', %d, 0, 0, '')")
conn.close()

with open("/mnt/data/tms/templates/org_urls.txt", "a") as file_object:
    file_object.write(f"\n{orgID},{site},{name}")
