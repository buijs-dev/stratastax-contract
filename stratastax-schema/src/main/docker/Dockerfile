FROM flyway/flyway:12.11.0

COPY db/migration/v1 /flyway/migrations
COPY entrypoint.sh /flyway/entrypoint.sh
RUN chmod +x /flyway/entrypoint.sh

ENTRYPOINT ["/flyway/entrypoint.sh"]