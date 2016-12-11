# hashira-rails [![Build Status](https://secure.travis-ci.org/mcmire/hashira-rails.svg?branch=master)](http://travis-ci.org/mcmire/hashira-rails)

Hashira (柱) generates apps, preconfigured with sensible defaults. This project
generates Rails apps.

## Installation

First install the hashira-rails gem:

    gem install hashira-rails

Then run:

    hashira-rails projectname

This will create a Rails app in `projectname` using the latest version of Rails.

### Associated services

* Enable [Circle CI](https://circleci.com/) Continuous Integration
* Enable [GitHub auto deploys to Heroku staging and review
    apps](https://dashboard.heroku.com/apps/app-name-staging/deploy/github).

## Gemfile

To see the latest and greatest gems, look at the
[Gemfile](templates/Gemfile.erb), which will be appended to the default
generated Gemfile for your app.

It includes application gems like:

* [Autoprefixer Rails](https://github.com/ai/autoprefixer-rails) for CSS vendor prefixes
* [Bourbon](https://github.com/thoughtbot/bourbon) for Sass mixins
* [Bitters](https://github.com/thoughtbot/bitters) for scaffold application styles
* [Sidekiq](https://github.com/mperham/sidekiq) for background
  processing
* [Flutie](https://github.com/thoughtbot/flutie) for `page_title` and `body_class` view
  helpers
* [High Voltage](https://github.com/thoughtbot/high_voltage) for static pages
* [jQuery Rails](https://github.com/rails/jquery-rails) for jQuery
* [Neat](https://github.com/thoughtbot/neat) for semantic grids
* [Normalize](https://necolas.github.io/normalize.css/) for resetting browser styles
* [Postgres](https://github.com/ged/ruby-pg) for access to the Postgres database
* [Rack Canonical Host](https://github.com/tylerhunt/rack-canonical-host) to
  ensure all requests are served from the same domain
* [Rack Timeout](https://github.com/heroku/rack-timeout) to abort requests that are
  taking too long
* [Recipient Interceptor](https://github.com/croaky/recipient_interceptor) to
  avoid accidentally sending emails to real people from staging
* [Refills](https://github.com/thoughtbot/refills) for “copy-paste” components
  and patterns based on Bourbon, Neat and Bitters
* [Sentry](https://sentry.io) for exception notification
* [Simple Form](https://github.com/plataformatec/simple_form) for form markup
  and style
* [Skylight](https://www.skylight.io/) for monitoring performance
* [Title](https://github.com/calebthompson/title) for storing titles in
  translations
* [Puma](https://github.com/puma/puma) to serve HTTP requests

And development gems like:

* [Dotenv](https://github.com/bkeepers/dotenv) for loading environment variables
* [Pry Rails](https://github.com/rweng/pry-rails) for interactively exploring
  objects
* [ByeBug](https://github.com/deivid-rodriguez/byebug) for interactively
  debugging behavior
* [Bullet](https://github.com/flyerhzm/bullet) for help to kill N+1 queries and
  unused eager loading
* [Bundler Audit](https://github.com/rubysec/bundler-audit) for scanning the
  Gemfile for insecure dependencies based on published CVEs
* [Spring](https://github.com/rails/spring) for fast Rails actions via
  pre-loading
* [Web Console](https://github.com/rails/web-console) for better debugging via
  in-browser IRB consoles.

And testing gems like:

* [Capybara](https://github.com/jnicklas/capybara) and
  [Capybara WebKit](https://github.com/thoughtbot/capybara-webkit) for
  integration testing
* [Factory Girl](https://github.com/thoughtbot/factory_girl) for test data
* [Formulaic](https://github.com/thoughtbot/formulaic) for integration testing
  HTML forms
* [RSpec](https://github.com/rspec/rspec) for unit testing
* [RSpec Mocks](https://github.com/rspec/rspec-mocks) for stubbing and spying
* [Shoulda Matchers](https://github.com/thoughtbot/shoulda-matchers) for common
  RSpec matchers
* [Timecop](https://github.com/ferndopolis/timecop-console) for testing time

## Other goodies

Your generated Rails app also comes with:

* The [`./bin/setup`][setup] convention for new developer setup
* The `./bin/deploy` convention for deploying to Heroku
* Rails' flashes set up and in application layout
* A few nice time formats set up for localization
* `Rack::Deflater` to [compress responses with Gzip][compress]
* A [low database connection pool limit][pool]
* [Safe binstubs][binstub]
* [t() and l() in specs without prefixing with I18n][i18n]
* An automatically-created `SECRET_KEY_BASE` environment variable in all
  environments
* Configuration for [CircleCI][circle] Continuous Integration (tests)
* Configuration for [Hound][hound] Continuous Integration (style)
* The analytics adapter [Segment][segment] (and therefore config for Google
  Analytics, Intercom, Facebook Ads, Twitter Ads, etc.)

[setup]: https://robots.thoughtbot.com/bin-setup
[compress]: https://robots.thoughtbot.com/content-compression-with-rack-deflater
[pool]: https://devcenter.heroku.com/articles/concurrency-and-database-connections
[binstub]: https://github.com/thoughtbot/suspenders/pull/282
[i18n]: https://github.com/thoughtbot/suspenders/pull/304
[circle]: https://circleci.com/docs
[hound]: https://houndci.com
[segment]: https://segment.com

## Heroku

You can optionally create Heroku staging and production apps:

    hashira-rails app --heroku true

This:

* Creates a staging and production Heroku app
* Sets them as `staging` and `production` Git remotes
* Configures staging with `RACK_ENV` environment variable set
  to `staging`
* Adds the [Rails Stdout Logging][logging-gem] gem
  to configure the app to log to standard out,
  which is how [Heroku's logging][heroku-logging] works.
* Creates a [Heroku Pipeline] for review apps

[logging-gem]: https://github.com/heroku/rails_stdout_logging
[heroku-logging]: https://devcenter.heroku.com/articles/logging#writing-to-your-log
[Heroku Pipeline]: https://devcenter.heroku.com/articles/pipelines

You can optionally specify alternate Heroku flags:

    hashira-rails app \
      --heroku true \
      --heroku-flags "--region eu --addons sendgrid,ssl"

See all possible Heroku flags:

    heroku help create

## Git

This will initialize a new git repository for your Rails app. You can
bypass this with the `--skip-git` option:

    hashira-rails app --skip-git true

## GitHub

You can optionally create a GitHub repository for the generated Rails app. It
requires that you have [Hub](https://github.com/github/hub) on your system:

    curl http://hub.github.com/standalone -sLo ~/bin/hub && chmod +x ~/bin/hub
    hashira-rails app --github organization/project

This has the same effect as running:

    hub create organization/project

## Spring

Your Rails app will be generated with [Spring](https://github.com/rails/spring)
by default. It makes Rails applications load faster, but it might introduce
confusing issues around stale code not being refreshed. If you think your
application is running old code, run `spring stop`. And if you'd rather not use
spring, add `DISABLE_SPRING=1` to your login file.

## Dependencies

In order to use this gem, you must have the latest version of Ruby.

Some gems included in your app will have native extensions. You should have GCC
installed on your machine before generating an app.

Use [OS X GCC Installer](https://github.com/kennethreitz/osx-gcc-installer/) for
Snow Leopard (OS X 10.6).

Use [Command Line Tools for Xcode](https://developer.apple.com/downloads/index.action)
for Lion (OS X 10.7) or Mountain Lion (OS X 10.8).

We use [Capybara WebKit](https://github.com/thoughtbot/capybara-webkit) for
full-stack JavaScript integration testing. It requires QT. Instructions for
installing QT are
[here](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit).

PostgreSQL needs to be installed and running for the `db:create` rake task.

## Issues

If you have problems, please create a
[GitHub Issue](https://github.com/mcmire/hashira-rails/issues).

## License

hashira-rails is copyright © 2016 Elliot Winkler.
It is adapted from [Suspenders], a [thoughtbot] project.
It is free software, and may be redistributed under the terms specified in the
[LICENSE] file.

[Suspenders]: https://github.com/thoughtbot/suspenders
[thoughtbot]: http://thoughtbot.com
[LICENSE]: LICENSE
