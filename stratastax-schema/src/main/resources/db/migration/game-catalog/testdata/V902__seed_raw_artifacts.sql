-- Source material behind a few of the seeded candidates.
INSERT INTO raw_artifact (public_id, candidate_id, source, content, created_at)
SELECT format('0192f100-0004-7000-8000-%s', lpad(to_hex(a.n), 12, '0'))::uuid,
       c.id, a.source, a.content::jsonb, c.created_at + a.n * interval '1 minute'
FROM (VALUES
    (1, 199792, 'BGG_API',
     '{"id":199792,"type":"boardgame","name":"Everdell","minPlayers":1,"maxPlayers":4,"playingTime":80,"minAge":13,"yearPublished":2018,"categories":["Animals"],"mechanics":["Worker Placement"]}'),
    (2, 199792, 'OLLAMA_WEB_SEARCH',
     '{"query":"Find the rulebook in english for the following game: Everdell","sources":[{"title":"Everdell Rulebook","uri":"https://example.org/everdell-rules.pdf","domain":"example.org","content":"The player with the most points wins. 1-4 players."}]}'),
    (3, 199792, 'OLLAMA_EXTRACTION',
     '{"scoreType":"SCORE","winCondition":"HIGHER_WINS","minPlayers":1,"maxPlayers":4,"playingTime":80,"description":"A worker-placement game in a woodland valley."}'),
    (4, 266192, 'BGG_API',
     '{"id":266192,"type":"boardgame","name":"Wingspan","minPlayers":1,"maxPlayers":5,"playingTime":70,"minAge":10,"yearPublished":2019}'),
    (5, 266192, 'OLLAMA_WEB_SEARCH',
     '{"query":"Find the rulebook in english for the following game: Wingspan","sources":[{"title":"Wingspan rules","uri":"https://example.org/wingspan.pdf","domain":"example.org","content":"After 4 rounds, the player with the most points wins."}]}')
) AS a (n, bgg_id, source, content)
JOIN candidate c ON c.bgg_id = a.bgg_id;
