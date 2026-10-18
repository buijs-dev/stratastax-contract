FROM flyway/flyway:12.11.0

# The service whose migrations this image applies: engine, game-catalog or i18n.
ARG SERVICE

COPY db/migration/${SERVICE}/v1 /flyway/migrations
COPY entrypoint.sh /flyway/entrypoint.sh
RUN chmod +x /flyway/entrypoint.sh

ENTRYPOINT ["/flyway/entrypoint.sh"]
