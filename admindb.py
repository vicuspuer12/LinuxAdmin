#!/usr/bin/python
import fdb
import os

conn = fdb.connect(
       host='DB server IP',
       database='dir of DB',
       port='Port N0',
       user='DB Username',
       password='Password'
   )


def read_db():
    cur = conn.cursor()
    
    data = cur.execute("select ID,ORGID,SITEURL,NAME,CONTROLLIP from TODO where STATUS = 0;").fetchone()
    ID = data[0]   
    ORGID = data[1]
    SITEURL = data[2]
    NAME = data[3]
    CONTROLLIP = data[4]

    orgid = f"org_{ORGID}"
    path = f"/srv/firebird/{orgid}"

    if os.path.exists(path):
        print(f'found')
    else:
        query:str = f"""echo "create database '/srv/firebird/{orgid}.gdb';" | isql-fb"""
        os.system(f"{query}")
        os.system(f"/mnt/data/shared/tms/updates/create_organisation.isql | isql-fb {orgid}.gdbry")
        #print(f"/mnt/data/shared/tms/updates/create_organisation.isql | isql-fb {orgid}.gdb")

        conn = fdb.connect(
            host='10.1.2.132',
            database=f'/srv/firebird/{orgid}.gdb',
            port=3050,
            user='tyreweb',
            password='42k-JMq@'
        )
        cur = conn.cursor()
        cur.execute("update or insert into flags (mode,controllip,orgid,orgname,siteurl,certificate,currency,mintread,replicate,cpkreport,languageid,pressure,auto_trips,odo_in_miles,year_start,casing_cost,logo,budget_cpk,case_devalue,cpk_calc,batch_force,prefix) values (0,{CONTROLLIP},{ORGID},'{NAME}','{SITEURL}','','',40,0,0,1,500,0,0,0,0.0,'',0.0,150,1,0,3) matching (orgid);")

if __name__ == "__main__":
    read_db()
