FROM debian:bookworm-20230904-slim

RUN mkdir /api
COPY ./team-builder /api
COPY ./create-employees-table.sql /api

WORKDIR /api

RUN chmod u+x ./team-builder
CMD [ "./team-builder" ]