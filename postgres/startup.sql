CREATE TABLE IF NOT EXISTS demo(
    row_id INTEGER PRIMARY KEY,
    name VARCHAR,
    city VARCHAR
);
TRUNCATE TABLE demo;
INSERT INTO demo (row_id, name, city) VALUES (1, 'Paul', 'New York');
INSERT INTO demo (row_id, name, city) VALUES (2, 'Robert', 'Milan');
INSERT INTO demo (row_id, name, city) VALUES (3, 'Alice', 'Shanghai');
INSERT INTO demo (row_id, name, city) VALUES (4, 'Alizah', 'Schanghai');
INSERT INTO demo (row_id, name, city) VALUES (5, 'Bob', 'Mailand');


CREATE EXTENSION IF NOT EXISTS multicorn;
DROP SERVER IF EXISTS multicorn_es CASCADE ;

CREATE SERVER IF NOT EXISTS  multicorn_es FOREIGN DATA WRAPPER multicorn
OPTIONS (
  wrapper 'suricate_fdw.ElasticsearchFDW'
);

CREATE TABLE IF NOT EXISTS articles
    (
        id SERIAL PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE
    )
;

DROP FOREIGN TABLE IF EXISTS articles_es;
CREATE FOREIGN TABLE articles_es
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

SELECT
    id,
    title,
    body
FROM
    articles_es
;

DROP FOREIGN TABLE myjson;
CREATE FOREIGN TABLE myjson
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

