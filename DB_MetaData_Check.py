import argparse
import pandas as pd
import datetime
import fdb

USER = 'DBUSER'
PASSWD = 'DBUSER_Password'
CHARSET = 'utf8'
BASE_PATH = 'DB_PATH'

if __name__ == '__main__':
    
    args_2_parse = argparse.ArgumentParser(description='a utility to check if database meta data is correct')
    args_2_parse.add_argument('-s', '--source_DB', type=str, metavar='', help="the source organization's int DB")
    args_2_parse.add_argument('-t', '--target_DB', type=str, metavar='', help="the target organization's int DB")
    
    args = args_2_parse.parse_args()
    siteid = 0
    date = datetime.datetime.today().strftime('%d/%m/%Y %H:%M:%S')
    tables_sql = """
    SELECT a.RDB$RELATION_NAME as table_name
    FROM RDB$RELATIONS a
    WHERE COALESCE(RDB$SYSTEM_FLAG, 0) = 0 AND RDB$RELATION_TYPE = 0
    """

    if args.source_orgid and args.target_orgid:
        
        print(f'{date=} check if org {siteid} has correct meta data')
         
        with fdb.connect(dsn=f'{BASE_PATH}{args.source_DB}.gdb',user=USER,password=PASSWD,charset=CHARSET) as db_src \
            ,fdb.connect(dsn=f'{BASE_PATH}{args.target_DB}.gdb',user=USER,password=PASSWD,charset=CHARSET) as db:

            if db_src and db:
                
                test_data = pd.read_sql_query(tables_sql,db_src)
                data_2_check = pd.read_sql_query(tables_sql,db)
                
                # print(f"there are {len(test_data) - len(data_2_check)} missing tables, bellow is the respective list")
                print('\nmissing tables, bellow is the respective list if any\n')
                print(test_data[~test_data.TABLE_NAME.isin(data_2_check.TABLE_NAME)].reset_index(drop=True))
            
            else: print('couldnt connect to the database')    
    
    else:   print('DB not specifies, please use the -h tag to get help')
