# hashira-rails [![Build Status][]][Travis]

[Build Status]: https://secure.travis-ci.org/Mossio/hashira-rails.svg?branch=master
[Travis]: http://travis-ci.org/Mossio/hashira-rails

Hashira (柱) generates apps which are preconfigured with gems and settings that
we find useful at [Mossio]. This project generates Rails apps in particular.

[Mossio]: http://mossio.co

## Usage

### Dependencies

In order to use this gem, you must have the latest version of Ruby (2.3.3 as of
this writing).

Some gems included in your app will have native extensions. You should have a
compiler installed and set up on your machine before generating an app. These
days, Xcode supplies one with their Command Line Tools. You can easily install
them by running `xcode-select --install`.

### Generating a new app

First you'll need to install the gem:

    gem install hashira-rails

Then, from any directory, run:

    hashira-rails projectname

Your generated Rails app will be available under a `projectname` directory.

When we make new apps we will typically follow through by setting up some
associated services:

* We will set up [CircleCI] so that our tests are run on each push to a branch
* We will set up Heroku so that it [automatically deploys staging] when master
  is updated

[CircleCI]: https://circleci.com/
[automatically deploys staging]: https://devcenter.heroku.com/articles/github-integration#automatic-deploys

### Heroku

By default, the generator will assume that you plan on deploying your app to
Heroku. During the process, then, it will:

* Create a staging and production Heroku app
* Create `staging` and `production` Git remotes pointing to those apps
* Configure staging with `RACK_ENV` environment variable set to `production`
* Add the [rails_stdout_logging] gem to configure the app to log to standard
  out, which is how [Heroku's logging] works.
* Create a [pipeline] on Heroku for review apps

[rails_stdout_logging]: https://github.com/heroku/rails_stdout_logging
[Heroku's logging]: https://devcenter.heroku.com/articles/logging#writing-to-your-log
[pipeline]: https://devcenter.heroku.com/articles/pipelines

The generator makes use of the `heroku` executable to create and configure apps.
If there are any command-line options for `heroku` you wish to provide you can
easily do that. For instance:

    hashira-rails app --heroku-flags "--region eu --addons sendgrid,ssl"

You can see all possible options with:

    heroku help create

If you don't care about Heroku and want to disable the behavior described above,
you can say:

    hashira-rails app --heroku false

### Git

The generator will automatically initialize a new Git repository after
generating the app. You can disable this by saying:

    hashira-rails app --skip-git true

### GitHub

You can tell the generator to create a GitHub repository along with the app if
you wish. The generator will use [Hub] internally to do this, so you must have
that installed first. Then you can say:

    hashira-rails app --github organization/project

[Hub]: https://github.com/github/hub

### Spring

As in a standard Rails app, Hashira will generate your Rails app configured with
[Spring] by default. It makes Rails applications load faster, but it might
introduce confusing issues around stale code not being refreshed. If you run
into an issue during development and you think your application is running old
code, you can run `spring stop` to reset Spring. And if you'd rather not use
Spring, run `hashira-rails` with `DISABLE_SPRING=1`.

[Spring]: https://github.com/rails/spring

## Included gems

Generated apps come bundled with a set of gems that we've found to be invaluable
in our projects.

### Gems for frontend developers

* [Autoprefixer] for automatically augmenting CSS with vendor prefixes
* [Normalize] for resetting browser styles
* [Bitters], a foundation for elemental styles and settings
* [Bourbon], a handy set of Sass mixins
* [Neat], an unobtrusive grid system for laying out pages
* [High Voltage], for making static pages such as HTML/CSS mockups

[Normalize]: https://github.com/markmcconachie/normalize-rails
[Autoprefixer]: https://github.com/ai/autoprefixer-rails
[Bitters]: https://github.com/thoughtbot/bitters
[Bourbon]: https://github.com/thoughtbot/bourbon
[Neat]: https://github.com/thoughtbot/neat
[High Voltage]: https://github.com/thoughtbot/high_voltage

### Gems for backend developers

#### Gems common to all environments

* The [PG] gem (and related configuration) for connecting to PostgreSQL,
  a capable, extensible, and generally awesome database
* [Puma], a speedy, performant, and multi-threaded web server
* [Simple Form], a nice DSL for creating forms whose HTML can be customized in
  response to frontend developers
* [Sidekiq] for running background jobs like a beast
* [Sentry] for capturing exceptions that the app produces and logging them in a
  really nice interface
* [Flutie] for setting page titles with ease
* [rack-canonical-host], for ensuring that the URL of the application that users
  see is what we set it to be
* [rack-timeout] for aborting requests that are take too long
* [Recipient Interceptor] for preventing emails from being accidentally sent to
  real people from within staging

[PG]: https://github.com/ged/ruby-pg
[Puma]: https://github.com/puma/puma
[Simple Form]: https://github.com/plataformatec/simple_form
[Sidekiq]: https://github.com/mperham/sidekiq
[Sentry]: https://sentry.io
[Flutie]: https://github.com/thoughtbot/flutie
[rack-canonical-host]: https://github.com/tylerhunt/rack-canonical-host
[rack-timeout]: https://github.com/heroku/rack-timeout
[Recipient Interceptor]: https://github.com/croaky/recipient_interceptor

#### Gems that are useful during the development process

* [Dotenv] for keeping to the [twelve-factor guidelines] and making it possible
  to store and load environment variables from a file
* [pry-byebug] and [pry-rails] for debugging code interactively
* [Awesome Print] for making values in the Rails console look pretty
* [Bullet] to help kill N+1 queries and to identify unused eager loading
* [bundler-audit] to alert developers of insecure gem dependencies based on
  published CVEs
* [rack-mini-profiler] for profiling the app as it is being developed

[twelve-factor guidelines]: https://12factor.net/
[Dotenv]: https://github.com/bkeepers/dotenv
[pry-byebug]: https://github.com/deivid-rodriguez/pry-byebug
[pry-rails]: https://github.com/rweng/pry-rails
[Awesome Print]: https://github.com/awesome-print/awesome_print
[Bullet]: https://github.com/flyerhzm/bullet
[bundler-audit]: https://github.com/rubysec/bundler-audit
[rack-mini-profiler]: https://github.com/MiniProfiler/rack-mini-profiler

#### Testing-related gems

* [RSpec] for unit testing Ruby
* [Factory Girl] for creating test data in RSpec tests on the fly
* [Capybara] and [Poltergeist] for integration testing
* [Shoulda Matchers] for writing model tests for validations and associations
  with ease
* [Timecop] for freezing time
* [Teaspoon] and [Jasmine] for unit testing JavaScript

[Capybara]: https://github.com/jnicklas/capybara
[Poltergeist]: https://github.com/teampoltergeist/poltergeist
[Factory Girl]: https://github.com/thoughtbot/factory_girl
[RSpec]: https://github.com/rspec/rspec-rails
[Shoulda Matchers]: https://github.com/thoughtbot/shoulda-matchers
[Timecop]: https://github.com/travisjeffery/timecop
[Teaspoon]: https://github.com/jejacks0n/teaspoon
[Jasmine]: https://jasmine.github.io/

### Other goodies

Your generated Rails app also comes with these extras:

* An expanded setup script that performs the following checks:
  * Ensures that the correct version of Ruby is installed
  * Ensures that Postgres and Redis are installed and running
  * Ensures that Rubocop and ESLint are installed so that code can be autolinted
    as it is written in editors like Vim
  * Ensures that Bower is installed and installs Bower dependencies
* A `bin/deploy` script for deploying the app to Heroku
* Basic date and time formats in `config/locales/en.yml`
* `Rack::Deflater` to [compress responses with Gzip][compress]
* A [low database connection pool limit][pool]
* [Safe binstubs][binstub]
* [Usage of t() and l() in specs without a need to prefix it with `I18n.`][i18n]
* An automatically-created `SECRET_KEY_BASE` environment variable in all
  environments
* Configuration for [CircleCI][circle]
* Configuration for [Hound][hound]
* HTML code for [Segment][segment] (a service that bridges analytics services
  such as Google Analytics, Intercom, Facebook Ads, Twitter Ads, etc.)

[setup]: https://robots.thoughtbot.com/bin-setup
[compress]: https://robots.thoughtbot.com/content-compression-with-rack-deflater
[pool]: https://devcenter.heroku.com/articles/concurrency-and-database-connections
[binstub]: https://github.com/thoughtbot/suspenders/pull/282
[i18n]: https://github.com/thoughtbot/suspenders/pull/304
[circle]: https://circleci.com/docs
[hound]: https://houndci.com
[segment]: https://segment.com

## Issues

If you run into problems while using this gem, please create an [issue].

[issue]: https://github.com/Mossio/hashira-rails/issues

## Legal stuff

hashira-rails is copyright © 2016 Elliot Winkler and the Mossio team. It is
adapted from [Suspenders], a [thoughtbot] project. It is free software, and may
be redistributed under the terms specified in the [LICENSE] file.

[Suspenders]: https://github.com/thoughtbot/suspenders
[thoughtbot]: http://thoughtbot.com
[LICENSE]: LICENSE
