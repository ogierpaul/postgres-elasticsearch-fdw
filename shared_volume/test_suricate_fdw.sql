-- make sure to have run before test_pg_es_fdw.sql to populate the elastic index

CREATE EXTENSION IF NOT EXISTS multicorn;
DROP SERVER IF EXISTS multicorn_es CASCADE ;

CREATE SERVER IF NOT EXISTS  multicorn_es FOREIGN DATA WRAPPER multicorn
OPTIONS (
  wrapper 'suricate_fdw.SuricateFDW'
);


DROP FOREIGN TABLE IF EXISTS suricate;
CREATE FOREIGN TABLE IF NOT EXISTS suricate(
        pg_id INTEGER,
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

DROP FUNCTION IF EXISTS es_search(body TEXT, i INTEGER);
CREATE OR REPLACE FUNCTION es_search(body TEXT, i INTEGER)
RETURNS TABLE (pg_id INTEGER, query TEXT, response TEXT)
AS
$$
    BEGIN
RETURN QUERY
SELECT
    b."pg_id",
    b."query",
    b."response"
FROM
    suricate b
WHERE b."query"=body and b."pg_id" =i;
END
$$ LANGUAGE plpgsql;

DROP TABLE IF EXISTS sample_queries;
CREATE TABLE IF NOT EXISTS sample_queries(
    id INTEGER,
    body JSON
);
INSERT INTO sample_queries (id, body)
VALUES (1,
        json_build_object('query',
                          json_build_object('match_all', json_build_object()))),
       (2,
        json_build_object(
            'query',
            json_build_object(
                'match',
                json_build_object(
                    'body',
                    json_build_object('query', 'London')
                    )
                )
            )
        );



SELECT es_search(body::TEXT,id)
FROM sample_queries;
