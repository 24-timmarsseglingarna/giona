# README

=======

# giona

Version 1.15.0

# Ubuntu

install postgres

create unix user giona w/o password:
`$ adduser --disabled-password giona`

edit `pg_hba.conf` with:
```
-local   all             all                                     peer
+local   all             all                                     md5
```

restart postgressql server

create postgres user giona:
`$ createuser -d -s -P -e giona`
(use password giona)


# Create Database

createdb -E utf8 -U giona -O giona -T template0 --lc-collate="sv_SE.UTF-8" giona_development


# Install Ruby

We're using a rather old version of ruby, and old versions of many
packages.  Hence, we need to install that old ruby version locally.  I
use `rbenv` for this.

## Install `rbenv`

See https://github.com/rbenv/rbenv

For Ubuntu, I did:

```shell
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc
```

restart bash, then

```shell
# install our ruby version
rbenv install 2.7.5
```

Then in giona's top directory do:

```
# use 2.7.5 for this project
rbenv local 2.7.5
# install the bundler we use
gem install bundler:1.17.1
# install all dependencies
bundle install
```

# Populate
rake db:migrate
rake batch:agreement                # At least one end user agreement must exist.

start server:
bin/rails server

go to: http://127.0.0.1:3000 and register a user

rake batch:admin                    # Set admin rights on this user

rake batch:add_nobody               # User with no specific permissions

rake scrape:srs:keelboats
rake scrape:srs:certificates
rake import:srs:multihull_certificates
rake import:sxk:certificates
rake scrape:srs:multihulls
rake import:srs:dingies             # First, manually copy from pdf and paste into spreadsheet.

rake batch:pod:organizers
rake import:pod:terrain

bin/rails server
go to: http://127.0.0.1:3000/terrains and Approve/publish PoD/terrain

rake import:pod:default_starts


# Set environment variable DEFAULT_URL='whatever.domain'
# Defaults to 'segla.24-timmars.nu'
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

export SENDGRID_USERNAME=`heroku config:get SENDGRID_USERNAME --app giona`
export SENDGRID_PASSWORD=`heroku config:get SENDGRID_PASSWORD --app giona`


======

# Database heroku --> dev
heroku pg:backups:capture
heroku pg:backups:download
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U giona -d giona_development latest.dump

# Database dev --> heroku
pg_dump -Fc --no-acl --no-owner -h localhost -U giona giona_development > mydb.dump
heroku pg:backups:restore 'https://what.ever/giona/mydb.dump' HEROKU_POSTGRESQL_PUCE_URL
