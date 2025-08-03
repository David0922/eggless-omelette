```bash
# podman machine reset
# podman machine init --cpus 4 --memory 4096 --disk-size 20 --volume /Volumes:/Volumes
# podman machine start

podman-compose up

# clickhouse
podman exec -it clickhouse clickhouse-client \
  'clickhouse://clickhouse_user:clickhouse_password@localhost:9000/clickhouse_db' \
  --query="select 'goodbye world'"

# mysql
podman exec -it mysql mysql \
  --host=localhost \
  --port=3306 \
  --database=mysql_database \
  --user=mysql_user \
  --password=mysql_password \
  --execute="select 'goodbye world'"

# postgres
podman exec -it postgres psql \
  'postgresql://postgres_user:postgres_pw@localhost:5432/postgres_db' \
  --command="select 'goodbye world'"

# redis
podman exec -it redis redis-cli -h localhost -p 6379 keys '*'
```

todo: set timezone
