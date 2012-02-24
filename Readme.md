# AttributeD

An attribute service. Update, query, and sync attributes among distributed components.

## Running

Configure your environment with appropriate keys found in `env.sample`
to `.env`, install gems, migrate your database, start foreman:

    cp env.sample .env
    bundle install
    bundle exec bin/migrate
    bundle exec foreman start

## Usage

Turn on attributes in your service for entities (multiple attributes can be turned on):

    curl -X POST -d '[{"service_name":"router", "name":"fast-path", "entity_name":"customer-4"}]' http://host/on
    curl -X POST -d '[{"service_name":"router", "name":"ssl", "entity_name":"customer-7"}]' http://host/on

Turn off attributes in your service for entities (multiple attributes can be turned off):

    curl -X POST -d '[{"service_name":"router", "name":"fast-path", "entity_name":"customer-4"}]' http://host/off
    curl -X POST -d '[{"service_name":"router", "name":"ssl", "entity_name":"customer-7"}]' http://host/off

Get a dump of attributes in your service:

    curl -X POST -d '{"service_name":"router"}' http://host/dump
        {"service_name":"router","name":"fast-path","entity_name":"customer-4","state":"on","since":680}
        {"service_name":"router","name":"fast-path","entity_name":"customer-5","state":"on","since":681}
        {"service_name":"router","name":"fast-path","entity_name":"customer-6","state":"on","since":682}
        {"service_name":"router","name":"ssl","entity_name":"customer-7","state":"on","since":686}

    curl -X POST -d '{"service_name":"router", "name":"ssl"}' http://host/dump
        {"service_name":"router","name":"ssl","entity_name":"customer-7","state":"on","since":686}

    curl -X POST -d '{"service_name":"router", "entity_name":"customer-7"}' http://host/dump
        {"service_name":"router","name":"ssl","entity_name":"customer-7","state":"on","since":686}
        {"service_name":"router","name":"fast-path","entity_name":"customer-7","state":"on","since":687}

Get a feed of attributes in your service - similar to dump, but updating as changes are made:

    curl -X POST -d '{"service_name":"router"}' http://host/feed
        {"service_name":"router","name":"fast-path","entity_name":"customer-4","state":"on","since":680}
        {"service_name":"router","name":"fast-path","entity_name":"customer-5","state":"on","since":681}
        {"service_name":"router","name":"fast-path","entity_name":"customer-6","state":"on","since":682}
        ... time passes ...
        {"service_name":"router","name":"ssl","entity_name":"customer-7","state":"on","since":686}






