#%%

import json
import elasticsearch
import psycopg2
import pandas as pd

if __name__ == '__main__':
    #%%
    pg_conn = psycopg2.connect(database='mydb', host='localhost', port=5432, user='myuser', password='mypassword')
    print(pg_conn.status)
    pg_conn.autocommit =True
    #%%
    e = elasticsearch.Elasticsearch(
        [{"host": 'localhost', "port": 9200}], http_auth=('elastic', 'changeme')
    )
    e.ping()
    #%%
    dfq = pd.read_sql("SELECT id, body::TEXT FROM myquery", pg_conn)
    #%%
    q = dfq['body'].iloc[0]
    q =  [{u'query': {u'match_all': {}}}]
    print(type(q))
    r = e.search(body=q, index='article-index')
    print(r)
    #%%

    #%%
    r = dfq['response'].iloc[0]
    #%%
    pg_conn.close()

