CREATE EXTENSION IF NOT EXISTS multicorn;
DROP SERVER IF EXISTS multicorn_es CASCADE ;

CREATE SERVER IF NOT EXISTS  multicorn_es FOREIGN DATA WRAPPER multicorn
OPTIONS (
  wrapper 'suricate_fdw.ElasticsearchFDW'
);

DROP FOREIGN TABLE IF EXISTS qix;
CREATE FOREIGN TABLE IF NOT EXISTS qix (
    id INTEGER,
    body JSON
)
SERVER multicorn_es
OPTIONS
    (
        host 'elasticsearch',
        port '9200',
        index 'qix',
        rowid_column 'id',
        -- query_column 'query',
        -- score_column 'score',
        --default_sort 'last_updated:desc',
        --sort_column 'sort',
        refresh 'false',
        complete_returning 'false',
        timeout '20',
        username 'elastic',
        password 'changeme'
    )
;



DROP FOREIGN TABLE IF EXISTS articles_es;
CREATE FOREIGN TABLE IF NOT EXISTS articles_es
    (
        id BIGINT,
        title TEXT,
        body TEXT,
        query TEXT,
        score NUMERIC
    )
SERVER multicorn_es
OPTIONS
    (
        host 'elasticsearch',
        port '9200',
        index 'article-index',
        type 'article',
        rowid_column 'id',
        query_column 'query',
        score_column 'score',
        --default_sort 'last_updated:desc',
        --sort_column 'sort',
        refresh 'false',
        complete_returning 'false',
        timeout '20',
        username 'elastic',
        password 'changeme'
    )
;

INSERT INTO articles_es
    (
        id,
        title,
        body
    )
VALUES
    (
        1,
        'foo',
        'spike'
    ),
     (
        2,
        'Luton anti-terror arrests: Four men held over alleged plot for attack on',
        'Police have broken up a suspected Islamist terror cell planning to launch an attack in the UK. Counter-terrorism officers arrested four men in the Luton area on Wednesday morning and are searching seven addresses, Scotland Yard said.'''
    ),
    (
        3,
        'Priscilla Chan and Mark Zuckerberg''s 99% pledge is born with strings attached',
        'Mark Zuckerberg and Priscilla Chan are part of a cycle that perpetuates inequality even if they try to fight it. Photograph: Scott Olson/Getty Images.'
    ),
    (
        4,
        'Mars landing: Photo shows Perseverance about to touch down',
        'It shows the robot heading down to the ground on Thursday to make its landing. It was acquired by the rocket cradle that placed the vehicle on the surface. Perseverance has a large amount of data in its memory banks which it is gradually offloading to Earth.     Among other pictures is a view from a satellite that captures the rover in the parachute phase of its descent.'
    ),
    (
     5,
     'Postcard from London',
     'First transmitted in 1991, Clive James recalls his experiences in 1960s London and trades anecdotes with Victoria Wood, Terence Donovan, Peter Cook and Michael Caine along the way.'
    ),
    ( 6,
        'Cameron seeks parliament backing for bombing Islamic State in Syria',
        'LONDON Prime Minister David Cameron is likely to ask parliament to vote on Wednesday to approve British air strikes against Islamic State militants in Syria after months of wrangling over whether enough opposition Labour members of parliament would'
    )
    ;

DROP TABLE IF EXISTS myquery CASCADE ;
CREATE TABLE IF NOT EXISTS myquery (
    id INTEGER PRIMARY KEY ,
    body JSON
);
TRUNCATE TABLE myquery;
INSERT INTO myquery (id, body) VALUES
    (
        1,
     json_build_object(
         'query', json_build_object(
             'match_all', json_build_object(
                 )
             )
         )
     ),
    (2,
     json_build_object(
             'query', json_build_object(
             'match', json_build_object(
                     'body', json_build_object(
                             'query', 'London'
                         )
                 )
            )
         )
     );
INSERT INTO qix (id, body)
SELECT id, body::json FROM myquery;

DROP FOREIGN TABLE IF EXISTS myjson;
CREATE FOREIGN TABLE IF NOT EXISTS myjson
    (
        id BIGINT,
        title TEXT,
        body TEXT,
        query TEXT,
        score NUMERIC
    )
SERVER multicorn_es
OPTIONS
    (
        host 'elasticsearch',
        port '9200',
        index 'article-index',
        rowid_column 'id',
        query_column 'query',
        score_column 'score',
        --default_sort 'last_updated:desc',
        --sort_column 'sort',
        refresh 'false',
        complete_returning 'false',
        timeout '20',
        username 'elastic',
        password 'changeme',
        query_json 'true'
    )
;


CREATE OR REPLACE FUNCTION getq(i INT)
RETURNS JSON
LANGUAGE sql
AS
$$
SELECT body from myquery WHERE myquery.id=i;
$$;

SELECT
    *
FROM
    myjson
WHERE query='{"query" : {"match_all" : {}}}'
;



SELECT getq(1)::TEXT;

