CREATE EXTENSION IF NOT EXISTS multicorn;
DROP SERVER IF EXISTS multicorn_es CASCADE ;

CREATE SERVER IF NOT EXISTS  multicorn_es FOREIGN DATA WRAPPER multicorn
OPTIONS (
  wrapper 'suricate_fdw.SuricateFDW'
);


DROP FOREIGN TABLE IF EXISTS suricate;
CREATE FOREIGN TABLE IF NOT EXISTS suricate(
        pg_id BIGINT,
        query TEXT,
        response TEXT
    )
SERVER multicorn_es
OPTIONS
    (
        host 'elasticsearch',
        port '9200',
        index 'article-index',
        --rowid_column 'id',
        query_column 'query',
        pg_id_column 'pg_id',
        response_column 'response',
        size '10',
        explain 'true',
        --default_sort 'last_updated:desc',
        --sort_column 'sort',
        refresh 'false',
        complete_returning 'false',
        timeout '20',
        username 'elastic',
        password 'changeme'
    )
;


CREATE TABLE IF NOT EXISTS es_results (
        pg_id BIGINT,
        query TEXT,
        response TEXT
);
TRUNCATE TABLE es_results;
INSERT INTO es_results
SELECT
    *
FROM
    suricate
WHERE query='{"query" : {"match" : {"body" : {"query" : "London"}}}}' and pg_id =1
;

WITH d as (SELECT  pg_id, response::JSON as data FROM es_results)
SELECT pg_id,
       CAST(data->>'_score' AS FLOAT) as score,
       CAST(data->>'_id' AS INTEGER) as es_id,
       data->'_explanation' as details
FROM d;

