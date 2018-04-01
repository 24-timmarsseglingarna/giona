# README

=======
# giona

Version 0.5.2.1

=======

Development environment:
https://railsbox.io/boxes/8a394717f6ed

createdb -E utf8 -U giona -O giona -T template0 --lc-collate="sv_SE.UTF-8" giona_development

# Populate during developmentish conditions
rake db:migrate
rake scrape:srs:keelboats
rake scrape:srs:certificates
rake import:sxk:certificates        # Push file first
rake scrape:srs:multihulls
rake import:srs:dingies             # First, manually copy from pdf and paste into spreadsheet.
rake batch:pod:organizers
rake import:pod:terrain
rake import:pod:default_starts
rake import:starema:people          # Process file manually and push
rake import:starema:regattas        # Process file manually and push
rake import:starema:boats           # Process file manually and push
rake import:starema:teams           # Process file manually and push
rake import:starema:crew_members    # Process file manually and push
rake batch:team_names               # Only after import from external system
rake mess:details                   # In development only
rake testdata:team                  # In development/test only

======

Mail setup in development environment:

export SENDGRID_USERNAME=`heroku config:get SENDGRID_USERNAME`
export SENDGRID_PASSWORD=`heroku config:get SENDGRID_PASSWORD`


======

# Database heroku --> dev
heroku pg:backups:capture
heroku pg:backups:download
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U giona -d giona_development latest.dump

# Database dev --> heroku
pg_dump -Fc --no-acl --no-owner -h localhost -U giona giona_development > mydb.dump
heroku pg:backups:restore 'https://what.ever/giona/mydb.dump' HEROKU_POSTGRESQL_PUCE_URL
