CREATE EXTENSION IF NOT EXISTS multicorn;
DROP SERVER IF EXISTS multicorn_es CASCADE ;

CREATE SERVER IF NOT EXISTS  multicorn_es FOREIGN DATA WRAPPER multicorn
OPTIONS (
  wrapper 'pg_es_fdw.ElasticsearchFDW'
);


DROP FOREIGN TABLE IF EXISTS myjson;
CREATE FOREIGN TABLE IF NOT EXISTS myjson
    (
        pg_id BIGINT,
        query TEXT,
        result TEXT
    )
SERVER multicorn_es
OPTIONS
    (
        host 'elasticsearch',
        port '9200',
        index 'article-index',
        rowid_column 'pg_id',
        query_column 'query',
        -- score_column 'score',
        --default_sort 'last_updated:desc',
        --sort_column 'sort',
        refresh 'false',
        complete_returning 'false',
        timeout '20',
        username 'elastic',
        password 'changeme',
        query_json 'true',
        raw_results 'true'
    )
;


SELECT
    *
FROM
    myjson
WHERE query='{"body":{"query" : {"match" : {"body" : {"query" : "London"}}}}, "pg_id":1}'
;



