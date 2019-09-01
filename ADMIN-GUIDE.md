# Admin Guide for Giona

## Importing the PoD

The PoD is defined in a separate database.  It needs to be imported
into Giona.

The PoD is not automatically imported, since it is not version
controlled in the primary PoD database.

In Giona, every time a PoD is imported, it gets a new unique name.

Typically the PoD is supposed to be ready around end of April each
year.  When it is ready, perform the following steps to import it:

1. Run ```$ heroku run --app <APP> rake import:pod:terrain```.
If there are changes to the existing terrains, a new terrain is
created.
2. Go to ```https://<HOST>.24-timmars.nu/terrains```
and change name and publish the new terrain.
3. Run ```$ heroku run --app <APP> rake import:pod:default_starts```

The default starts are not version controlled.

### Handling existing regattas

Any active regatta that was created before the PoD was imported,
should probably be changed to use the new PoD.  This needs to be done
manually.

Also, in some cases the start points may have changed, so each regatta
may need to change its startpoints.

## Importing Handicaps

Handicaps are imported from different external systems:

* The SXK certificate database
* The SRS tables (for mono- and mulithulls and dinghies)
* The SRS certificates (for mono- and mulithulls)

The SXK certificate database should be imported as soon as it is
changed.  (TODO: make this automatic).

The SRS tables are published in March/April, and the SRS certificates
from March and onwards.

This means that if a regatta is defined and opened for entries in
January, the SRS numbers for the participant teams may change.

Giona never changes existing handicaps in the database during import,
but instead existing handicaps are marked as expired, and new
handicaps are created.

This means that teams that have selected a handicap that is later
changed need to update their entry in Giona.  When handicaps are
imported, Giona detects this situation and sends emails to the
skippers.

NOTE: Before importing handicaps, ensure that no old regattas are
still active in the system.  If this happens, handicaps may be changed
for teams on old regattas.

The following commands are used to import handicaps:

    heroku run --app <APP> rake import:sxk:certificates

    heroku run --app <APP> rake scrape:srs:keelboats
    heroku run --app <APP> rake scrape:srs:certificates

    heroku run --app <APP> rake scrape:srs:multihulls
    heroku run --app <APP> rake import:srs:multihull_certificates

Note that all these commands can be passed the parameter "dryrun",
which performs all import steps, but doesn't actually do anything.  It
is a good idea to use "dryrun" first and check the output.

    heroku run --app <APP> rake import:sxk:certificates[dryrun]

Importing SXK certificates can be done at any time.

Importing the SRS tables (srs:keelboats and srs:multihullls) can be
done as soon as the tables are published.  Running the same command
again is a no-op.

When the SRS certificates are imported, all existing SRS certificates
of that type that no longer exists are marked as expired.  This means
that if the SRS certificates are imported early, lets say in March,
not all certificates have been renewed yet.  The result is that the
few certificates that have been renewed are imported, and all the
existing ones are marked as expired and can no longer be selected by
teams.

In order to solve this, we should have a cron job that imports the SRS
certificates every night, starting in March perhaps.

## Temporary procedure for team lifecycle

Currently, the full review process is not yet implemented in Giona.
Until it is done, we must run a special task that closes all teams in
all archived regattas as "incomplete".  Their data can not be trusted
(e.g., they might not have a log book, or incomplete log book.)

After a regatta is finished, ensure that the admin marks it as
"archived" (by unchecking the "is open" checkbox).  When this is done,
run:

    heroku run --app <APP> rake batch:close_teams[dryrun]

Ensure that the result is what you want, and rerun w/o the "dryrun"
parameter.