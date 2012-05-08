Setting up CMS for development
==============================

If you've done sufficient Rails development before, you may skip to the end for the condensed version.

Setup environment
-----------------

CMS development uses RVM for environment-isolation during development.

### Install RVM

Follow instructions at http://beginrescueend.com/ to install RVM.

### Install Ruby 1.9.2 for CMS

If RVM is successfully installed, you should setup a Ruby 1.9.2 environment using:

    rvm install 1.9.2

After the Ruby version has installed, setup the gemset for CMS using:

    rvm --create use ruby-1.9.2@cms

#### Problems?

If you have problems building Ruby 1.9.2, make sure you have the dependencies described in `rvm requirements`.  If on OSX, use Xcode 4.1 (Xcode 4.2 uses LLVM, which in turn breaks everything.)

You may need to reinstall using `rvm pkg install openssl` and/or `rvm pkg install readline` if you have problems with the `linecache19` or `ruby-debug19` gems later on.


Checkout CMS
------------

CMS is open-source and hosted on Google Code using Git.  You can clone and checkout the project with:
    git clone https://code.google.com/p/compliance-management cms
    cd cms


Setup gems
----------

CMS uses Bundler (`Gemfile` and `Gemfile.lock`) to manage Gems and dependencies.  Install bundler into your CMS gemset using:

    gem install bundler

And install the gems required for CMS using the command below.  (The `--path=.bundle` is optional, but causes bundler to install gems into the `.bundle` local directory.)

    bundle install --path=.bundle


Setup locally
-------------

### Setup development environment:

After cloning and installing Gems, there are a few files you must modify for your local environment.

First, setup your database by copying the provided `config/database.yml.dist` into place and editting it to your needs:

    cp config/database.yml{.dist,}
    vi config/database.yml

Second, there are a few deployment-specific settings in `config/application.rb`.

#### CMS_CONFIG["SECRET_TOKEN"]

The default is fine for private development, but change this to something secret before deploying (or set with environment variables).

#### CMS_CONFIG["COMPANY_LOGO"]

The company logo shows in the top-left corner of most pages.  If this setting is nil, the logo will just be the text "CMS".  Change this to the URL to display a custom image.

### Initialize database:

Now that your environment and database are configured, you need to initialize the database with the schema and some seed data.  Do the following:

    bundle exec rake db:migrate
    bundle exec rake db:seed


### Setup for testing:

To run tests, you must invoke `bundle exec rake db:test:load` after any migration.


Running locally
---------------

### Server:

To run the server locally, use `bundle exec rails s`, and then connect to the webserver using http://localhost:3000 .


### Console:

It is often useful to have a Ruby console to test and debug.  Use `bundle exec rails c` to get to this console.


### Tests (RSpec):

CMS has lots of tests.  You can invoke these tests using `RAILS_ENV=test bundle exec rspec -d`.

After migrations, you may encounter errors running tests.  Run `bundle exec rake db:test:load` to update the test database to the latest schema.


Condensed version
=================

You have RVM, right?  Do this:

    # Install RVM environment
    rvm install 1.9.2
    rvm --create use ruby-1.9.2@cms

    # Checkout code
    git clone https://code.google.com/p/compliance-management cms
    cd cms

    # Install gems
    gem install bundler
    bundle install --path=.bundle

    # Configure application
    cp config/database.yml{.dist,}
    cp config/initializers/secret_token.rb{.dist,}

    # Initialize database
    bundle exec rake db:migrate
    bundle exec rake db:seed

    # Run tests and cross fingers
    bundle exec rake db:test:load
    RAILS_ENV=test bundle exec rspec -d


CI (continuous integration)
---------------------------

Commits to the `master` branch of the repository are automatically pulled and tested using Jenkins on an external server.  Results are then automatically pushed to a live development server.



