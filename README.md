# pgbackups-archive

[![Gem Version](https://badge.fury.io/rb/pgbackups-archive.svg)](http://badge.fury.io/rb/pgbackups-archive)
[![Code Climate](https://codeclimate.com/github/kjohnston/pgbackups-archive/badges/gpa.svg)](https://codeclimate.com/github/kjohnston/pgbackups-archive)

A means of automating Heroku PGBackups and archiving them to Amazon S3.

## Upgrade Alert

As of v1.0.0, `pgbackups-archive` works with the new [Heroku PGBackups](https://devcenter.heroku.com/articles/heroku-postgres-backups) service, which replaced the older [PG Backups](https://devcenter.heroku.com/articles/pgbackups) add-on.

If you're still using an older version of `pgbackups-archive`, it's time to upgrade!

Read more about this transition in Heroku's offerings on the Heroku Blog: [PG Backups Levels Up](https://blog.heroku.com/archives/2015/3/11/pgbackups-levels-up)

Please note that the environment variables that need to be defined have changed with
v1.0.0.

## Overview

The `pgbackups:archive` rake task this gem provides will capture a Heroku PGBackup, wait for it to complete, then store it within the Amazon S3 bucket you specify.  This rake task can be scheduled via the Heroku Scheduler, thus producing automated, offsite, backups.

This gem doesn't interfere with or utilze automated backups, so feel free to schedule those with the `pg:backups schedule` command as you desire.

You can configure how many manual backups (created by you or this gem) you'd like to keep at the Heroku PGBackups level to ensure there is always space to capture a new backup.

You can configure retention settings at the Amazon S3 bucket level from within the AWS Console if you like.

## Use

### Install the gem

Add the gem to your Gemfile and bundle:

    gem "pgbackups-archive"
    bundle install

### Install Heroku Scheduler add-on

    heroku addons:add scheduler:standard

### Setup an AWS IAM user, S3 bucket and policy

A good security measure would be to use a dedicated set of AWS credentials with a security policy only allowing access to the bucket you're specifying.  See this Pro Tip on [Assigning an AWS IAM user access to a single S3 bucket](http://coderwall.com/p/dwhlma).

### Apply Environment Variables

    # Required
    heroku config:add HEROKU_API_KEY="collaborator-api-key"
    heroku config:add PGBACKUPS_APP="myapp"
    heroku config:add PGBACKUPS_AWS_ACCESS_KEY_ID="XXX"
    heroku config:add PGBACKUPS_AWS_SECRET_ACCESS_KEY="YYY"
    heroku config:add PGBACKUPS_BUCKET="myapp-backups"
    heroku config:add PGBACKUPS_REGION="us-west-2"

    # Optional: If you wish to backup a database other than the one that
    # DATABASE_URL points to, set this to the name of the variable for that
    # database (useful for follower databases).
    heroku config:add PGBACKUPS_DATABASE="HEROKU_POSTGRESQL_BLACK_URL"

    # Optional: If you wish to customize the number of manual backups kept at
    # the Heroku PGBackups level, set this.
    heroku config:add PGBACKUPS_KEEP="30"

### Add the rake task to scheduler

    heroku addons:open scheduler

Then specify `rake pgbackups:archive` as a task you would like to run at any of the available intervals.

### Loading the Rake task

If you're using this gem in a Rails 3 app the rake task will be automatically loaded via a Railtie.

If you're using this gem with a Rails 2 app, or non-Rails app, add the following to your Rakefile:

```ruby
require "pgbackups-archive"
```

## Testing

To run the test suite, use the `guard` command and save a file or hit enter to run the full suite.

Use the [pgbackups-archive-dummy](https://github.com/kjohnston/pgbackups-archive-dummy) test harness to setup a dummy database on Heroku to test against.

## Disclaimer

I shouldn't have to say this, but I will.  Your backups are your responsibility.  Take charge of ensuring that they run, archive and can be restored periodically as expected.  Don't rely on Heroku, this gem, or anything else out there to substitute for a regimented database backup and restore testing strategy.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a Pull Request

## Contributors

Many thanks go to the following who have contributed to making this gem even better:

* [Robert Bousquet (@bousquet)](https://github.com/bousquet)
  * Autoload rake task into Rails 2.x once the gem has been loaded.
* [Daniel Morrison (@danielmorrison)](https://github.com/danielmorrison)
  * Ruby 1.8-compatible hash syntax.
* [Karl Baum (@kbaum)](https://github.com/kbaum)
  * Custom setting for database to backup.
  * Streaming support to handle large backup files.
* [Conroy Whitney (@conroywhitney)](https://github.com/conroywhitney)
  * Use S3 server-side encryption by default
* [Chris Gaffney (@gaffneyc)](https://github.com/gaffneyc)
  * Switch from fog to fog-aws.
  * Gem config improvements.

## License

* Freely distributable and licensed under the [MIT license](http://kjohnston.mit-license.org/license.html).
* Copyright (c) 2012-2015 Kenny Johnston [![endorse](http://api.coderwall.com/kjohnston/endorsecount.png)](http://coderwall.com/kjohnston)
