# README

=======
# giona

Version 0.6.1.2

=======

Development environment:
https://railsbox.io/boxes/8a394717f6ed

createdb -E utf8 -U giona -O giona -T template0 --lc-collate="sv_SE.UTF-8" giona_development

# Populate
rake db:migrate
rake scrape:srs:keelboats
rake scrape:srs:certificates
rake import:sxk:certificates URL=https://dl.dropboxusercontent.com/s/whahwj7eknbvulb/SXK-tal.csv # or whatever url        
rake scrape:srs:multihulls
rake import:srs:dingies             # First, manually copy from pdf and paste into spreadsheet.
rake batch:pod:organizers
rake import:pod:terrain
rake batch:agreement                # At least one end user agreement must exist.
# Create first user
rake batch:admin                    # Set admin rights
# Approve/publish PoD/terrain
rake import:pod:default_starts

=======
Import file formats:
*.csv: utf-8, field separator ,  textdelimiter "

=======

/* Development only
rake import:starema:people          # Process file manually and push
rake import:starema:regattas        # Process file manually and push
rake import:starema:boats           # Process file manually and push
rake import:starema:teams           # Process file manually and push
rake import:starema:crew_members    # Process file manually and push
rake batch:team_names               # Only after import from external system
rake mess:details                   # In development only
rake testdata:team                  # In development/test only
*/


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
