-- Source material behind a few of the seeded candidates.
INSERT INTO raw_artifact (candidate_id, source, content) VALUES
    ('0192f100-0000-7000-8000-000000000002', 'BGG_API',
     '{"id":199792,"type":"boardgame","name":"Everdell","minPlayers":1,"maxPlayers":4,"playingTime":80,"minAge":13,"yearPublished":2018,"categories":["Animals"],"mechanics":["Worker Placement"]}'),
    ('0192f100-0000-7000-8000-000000000002', 'OLLAMA_WEB_SEARCH',
     '{"query":"Find the rulebook in english for the following game: Everdell","sources":[{"title":"Everdell Rulebook","uri":"https://example.org/everdell-rules.pdf","domain":"example.org","content":"The player with the most points wins. 1-4 players."}]}'),
    ('0192f100-0000-7000-8000-000000000002', 'OLLAMA_EXTRACTION',
     '{"scoreType":"SCORE","winCondition":"HIGHER_WINS","minPlayers":1,"maxPlayers":4,"playingTime":80,"description":"A worker-placement game in a woodland valley."}'),
    ('0192f100-0000-7000-8000-000000000006', 'BGG_API',
     '{"id":266192,"type":"boardgame","name":"Wingspan","minPlayers":1,"maxPlayers":5,"playingTime":70,"minAge":10,"yearPublished":2019}'),
    ('0192f100-0000-7000-8000-000000000006', 'OLLAMA_WEB_SEARCH',
     '{"query":"Find the rulebook in english for the following game: Wingspan","sources":[{"title":"Wingspan rules","uri":"https://example.org/wingspan.pdf","domain":"example.org","content":"After 4 rounds, the player with the most points wins."}]}');
