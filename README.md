# pgbackups-archive

A means of automating Heroku's pgbackups and archiving them to Amazon S3 via the `fog` gem.

## Overview

The `pgbackups:archive` rake task that this gem provides will capture a pgbackup, wait for it to complete, then store it within the Amazon S3 bucket you specify.  This rake task can be scheduled via the Heroku Scheduler, thus producing automated, offsite, backups.

The rake task will use pgbackups' `--expire` flag to remove the oldest pgbackup Heroku is storing when there are no free slots remaining.

You can configure retention settings at the Amazon S3 bucket level from within the AWS Console if you like.

## Use

Add the gem to your Gemfile and bundle:

    gem "pgbackups-archive"
    bundle install

Install Heroku addons:

    heroku addons:add pgbackups:plus
    heroku addons:add scheduler:standard
    
Note: You can use paid-for versions of pgbackups if you'd like, however the dev and basic database offerings only support the free (plus) version.

Apply environment variables:

    heroku config:add PGBACKUPS_AWS_ACCESS_KEY_ID="XXX"
    heroku config:add PGBACKUPS_AWS_SECRET_ACCESS_KEY="YYY"
    heroku config:add PGBACKUPS_BUCKET="myapp-backups"
    heroku config:add PGBACKUPS_REGION="us-west-2"
    
Note: A good security measure would be to use a dedicated set of AWS credentials with a security policy only allowing access to the bucket you're specifying.

Add the rake task to scheduler:

    heroku addons:open scheduler
    
Then specify `rake pgbackups:archive` as a task you would like to run at any of the available intervals.

## Loading the Rake task

If you're using this gem in a Rails 3 app the rake task will be automatically loaded via a Railtie.

If you're using this gem with a Rails 2 app, or non-Rails app, add the following to your Rakefile:

    require "pgbackups-archive"
    load "tasks/pgbackups_archive.rake"

## Disclaimer

I shouldn't have to say this, but I will.  Your backups are your responsibility.  Take charge of ensuring that they run, archive and can be restored periodically as expected.  Don't rely on Heroku, this gem, or anything else out there to substitute for a regimented database backup and restore testing strategy.

## Contributing

1. [Fork it](https://github.com/kjohnston/pgbackups-archive/fork_select)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. [Create a Pull Request](hhttps://github.com/kjohnston/pgbackups-archive/pull/new)

## License

* Freely distributable and licensed under the [MIT license](http://kjohnston.mit-license.org/license.html).
* Copyright (c) 2012 Kenny Johnston [![endorse](http://api.coderwall.com/kjohnston/endorsecount.png)](http://coderwall.com/kjohnston)
