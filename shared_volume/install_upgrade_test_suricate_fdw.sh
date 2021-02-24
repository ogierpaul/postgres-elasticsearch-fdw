docker exec postgres59 /bin/bash -c "cd /suricate_fdw; pip install --upgrade ."
cd /Users/pogier/Documents/59-fdw/postgres-elasticsearch-fdw
docker stop postgres59
docker-compose up -d
sleep 3
docker exec -it postgres59 psql -U myuser -d mydb -f /shared_volume/test_suricate_fdw.sql