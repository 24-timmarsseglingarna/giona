# README

=======
# giona

Version 0.3.0.1

=======

createdb -E utf8 -U giona -O giona -T template0 --lc-collate="sv_SE.UTF-8" giona_development

# Populate during developmentish conditions
rake db:migrate
rake scrape:srs:keelboats
rake scrape:srs:certificates
rake import:sxk:certificates
rake scrape:srs:multihulls
rake import:srs:dingies
rake batch:pod:organizers
rake import:starema:people
rake import:starema:regattas
rake import:starema:boats
rake import:starema:teams
rake import:starema:crew_members
rake batch:team_names
rake batch:regatta_names
rake mess:details # In development only
rake testdata:team # In development/test only
