# pgbackups-archive

[![Gem Version](https://badge.fury.io/rb/pgbackups-archive.svg)](http://badge.fury.io/rb/pgbackups-archive)

A means of automating Heroku's pgbackups and archiving them to Amazon S3 via the `fog` gem.

## Overview

The `pgbackups:archive` rake task this gem provides will capture a pgbackup, wait for it to complete, then store it within the Amazon S3 bucket you specify.  This rake task can be scheduled via the Heroku Scheduler, thus producing automated, offsite, backups.

The rake task will use pgbackups' `--expire` flag to remove the oldest pgbackup Heroku is storing when there are no free slots remaining.

You can configure retention settings at the Amazon S3 bucket level from within the AWS Console if you like.

## Use

### Determine which Heroku app to run the task under

#### Option 1 - Add `pgbackups-archive` to your existing application

Add the gem to your Gemfile and bundle:

    gem "pgbackups-archive"
    bundle install

#### Option 2 - Add `pgbackups-archive` to a standalone application

* Create a new Heroku application to dedicate to backing up your database.
* Clone [pgackups-archive-app](https://github.com/kbaum/pgbackups-archive-app) push to your new Heroku app.
* Add a `PGBACKUPS_DATABASE_URL` environment variable to your backup app that points to your main app's `DATABASE_URL`, or other follower URL, so that `pgbackups-archive` knows which database to backup.

This option is generally recommended over Option 1, particularly if your application has larger slug size and therefore higher memory requirements.  This is because the streaming download & upload of the backup file will utilize a certain amount of memory beyond what an instance of your application uses and if you're close to the threshold of your Dyno size as it is, this increment could put the instance over the limit and cause it to encounter a memory allocation error.  By running a dedicated Heroku app to run `pgbackups-archive` the task will have ample room at the 1X Dyno level to stream the backup files.

### Install Heroku addons

    heroku addons:add pgbackups
    heroku addons:add scheduler:standard

### Apply environment variables

    heroku config:add PGBACKUPS_AWS_ACCESS_KEY_ID="XXX"
    heroku config:add PGBACKUPS_AWS_SECRET_ACCESS_KEY="YYY"
    heroku config:add PGBACKUPS_BUCKET="myapp-backups"
    heroku config:add PGBACKUPS_REGION="us-west-2"
    heroku config:add PGBACKUPS_DATABASE_URL="your main app's DATABASE_URL or other follower URL here"

* `PGBACKUPS_DATABASE_URL` can be set either to `DATABASE_URL` or a follower database you setup if you would prefer to not backup from your primary databse for performance reasons.
* If `PGBACKUPS_DATABASE_URL` is omitted, `pgbackups-archive` will default to the `DATABASE_URL` of the Heroku app it runs under.  This setting will be required going forward, so you'll want to have it set.
* As mentioned above, the `PGBACKUPS_DATABASE_URL` is mandatory if you are the using Option 2 above.
* A good security measure would be to use a dedicated set of AWS credentials with a security policy only allowing access to the bucket you're specifying.  See this Pro Tip on [Assigning an AWS IAM user access to a single S3 bucket](http://coderwall.com/p/dwhlma).

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

This gem uses [thincloud-test](https://github.com/newleaders/thincloud-test) to manage its test suite configuration.  This provides MiniTest, Guard and friends.  To run the test suite, use the `guard` command and save a file or hit enter to run the full suite.

Use the [pgbackups-archive-dummy](https://github.com/kjohnston/pgbackups-archive-dummy) test harness to setup a dummy database on Heroku to test against.

## Disclaimer

I shouldn't have to say this, but I will.  Your backups are your responsibility.  Take charge of ensuring that they run, archive and can be restored periodically as expected.  Don't rely on Heroku, this gem, or anything else out there to substitute for a regimented database backup and restore testing strategy.

## Contributing

1. [Fork it](https://github.com/kjohnston/pgbackups-archive/fork_select)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. [Create a Pull Request](https://github.com/kjohnston/pgbackups-archive/pull/new)

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

## License

* Freely distributable and licensed under the [MIT license](http://kjohnston.mit-license.org/license.html).
* Copyright (c) 2012-2013 Kenny Johnston [![endorse](http://api.coderwall.com/kjohnston/endorsecount.png)](http://coderwall.com/kjohnston)
