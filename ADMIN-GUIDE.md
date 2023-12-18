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

### Publish the PoD on S3

The app needs the PoD as JSON, and it will read it from our S3
bucket.  We have three buckets:

  giona{dev,stage,prod}

Currently this is a manual step.  In the future this will happen
automatically when a PoD is published.  Note the filename which MUST
be on the form terrain-<TERRAIN-ID>.json.gz.  Also note that we have a
file terrain-latest.json.gz which contains the TERRAIN-ID of the
latest published PoD.  This will be used in the app if no race is
activated.

1. Run ```$ wget https://<HOST>.24-timmars.nu/terrains/NN.json```
2. Run ```$ cp NN.json terrain-NN.json```
3. Run ```$ gzip terrain-NN.json```
4. Run ```$ aws s3 cp terrain-NN.json.gz s3://<BUCKET> --acl public-read \
          --content-type 'application/json' --content-encoding gzip```
5. Run ```$ echo "{\"id\": NN}" > terrain-latest.json```
6. Run ```$ gzip terrain-latest.json```
7. Run ```$ aws s3 cp terrain-latest.json.gz s3://<BUCKET> --acl public-read \
          --content-type 'application/json' --content-encoding gzip```


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

If a team has selected a handicap that is later changed, Giona
automatically updates the team to the new handicap, if a new handicap
is found.  Otherwise, if no new handicap is found, or the current
handicap is expired, the team needs to update their entry in Giona.
In this situation Giona sends emails to the skippers.

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

Importing SRS certificates can also be done at any time, but note that
if the SRS certificates are imported early, lets say in March, not all
certificates have been renewed yet.  Pre 2024, Giona used to mark all
non-renewed certificates as expired, but that doesn't happen anymore,
in order to get a better user experience (avoid having to go back and
pick a new handicap).

At some point we need to mark old non-renewed SRS certificates as
expired though.  This is done with the calls

    heroku run --app <APP> rake scrape:srs:certificates[expire]
    heroku run --app <APP> rake import:srs:multihull_certificates[expire]

dryrun can also be used:

    heroku run --app <APP> rake scrape:srs:certificates[expire,dryrun]

Run this command a couple of weeks before the first regatta (mid May).


TODO: we should have a cron job that imports the SRS certificates
every night, starting in March perhaps (we have this in staging).

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


# FIXME - Result

(wkhtmltopdf http://localhost:3000/regattas/1/result r1.pdf)
weasyprint http://localhost:3000/regattas/47/result r2.pdf
weasyprint http://localhost:3000/regattas/34/result r3.pdf
