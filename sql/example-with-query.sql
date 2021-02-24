CREATE EXTENSION IF NOT EXISTS multicorn;
DROP SERVER IF EXISTS multicorn_es CASCADE ;
CREATE SERVER IF NOT EXISTS multicorn_es FOREIGN DATA WRAPPER multicorn
OPTIONS (
  wrapper 'pg_es_fdw.ElasticsearchFDW'
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
CREATE FOREIGN TABLE IF NOT EXISTS articles_es
    (
        id bigint,
        title text,
        content text
    )
SERVER multicorn_es
OPTIONS
    (
        host '127.0.0.1',
        port '9200',
        type 'test',
        index 'articles'
    )
;

INSERT INTO articles_es
    (
        id,
        title,
        content
    )
VALUES
    (
        1,
        'Cameron seeks parliament backing for bombing Islamic State in Syria',
        'LONDON Prime Minister David Cameron is likely to ask parliament to vote on Wednesday to approve British air strikes against Islamic State militants in Syria after months of wrangling over whether enough opposition Labour members of parliament would'
    ),
    (
        2,
        'Luton anti-terror arrests: Four men held over alleged plot for attack on',
        'Police have broken up a suspected Islamist terror cell planning to launch an attack in the UK. Counter-terrorism officers arrested four men in the Luton area on Wednesday morning and are searching seven addresses, Scotland Yard said.'
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
    )
    ;

SELECT
    id,
    title,
    content
FROM
    articles_es
;

SELECT
    id,
    title,
    content,
    score
FROM
    articles_es
WHERE
    query = 'content:officer* or title:cameron'
;
