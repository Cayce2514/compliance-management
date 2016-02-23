Setting up GRC for development
==============================

If you've done sufficient Rails development before, you may skip to the end for the condensed version.


Setup environment
-----------------

GRC development uses RVM for environment-isolation during development.

### Install or Update RVM

Follow instructions at http://beginrescueend.com/ to install RVM.

If you already have RVM installed, you may need to update to use Ruby 1.9.3:

    rvm reload && rvm get stable

### Install Ruby 1.9.3 for GRC

If RVM is successfully installed, you should setup a Ruby 1.9.3 environment using:

    rvm install 1.9.3-p194

After the Ruby version has installed, make sure you are using it:

    rvm use 1.9.3-p194

Setup the gemset for GRC using:

    rvm --create use ruby-1.9.3-p194@grc

#### Problems?

If you have problems building Ruby 1.9.3, make sure you have the dependencies described in `rvm requirements`.  Homebrew (http://mxcl.github.com/homebrew/) may help with this.  To install the `mysql` gem, you may need to `brew install mysql`.

You may need to reinstall using `rvm pkg install openssl` and/or `rvm pkg install readline` if you have problems with the `linecache19` or `ruby-debug19` gems later on.


Checkout GRC
------------

GRC is open-source and hosted on Google Code using Git.  You can clone and checkout the project with:

    git clone https://code.google.com/p/compliance-management grc

The original master had a .rvmrc that will ask you if you want to trust it.  You may want to rename the file to avoid the issue:

    mv grc/.rvmrc grc/.rvmrc.orig

Now, you can cd into the grc directory to work with it:

    cd grc

Setup gems
----------

GRC uses Bundler (`Gemfile` and `Gemfile.lock`) to manage Gems and dependencies.  Install bundler into your GRC gemset using:

    gem install bundler

Since the original code is so old, we need to ensure that we're using a compatible rubygems:

    gem update --system 1.8.30

The GRC `Gemfile` references `Gemfile.local`, which you should create with the following template:

    source 'http://rubygems.org'

    group(:development, :test) do
      platform :ruby do
        # Add helpful local gems here, e.g. 'autotest' or 'heroku'
        #gem 'heroku', :git => 'https://github.com/heroku/heroku.git'
        #gem 'autotest'
      end
    end


To get up and running quickly and not have to worry about dependencies that you don't need to deal with for a development instance, I recommend that you make a couple of changes.

First, edit Gemfile to comment out heroku, staging and production:

    vi Gemfile

Comment out:
#  group :heroku do
#    gem "pg"
#  end
#
#  group :staging do
#    gem "mysql2"
#  end
#
#  group :production do
#    gem "mysql2"
#  end

While you're still in the Gemfile, update the version of the prawn gem to resolve an issue between the current version of prawn and the version of Ruby this is using:

    # set prawn to require 1.3 version
    gem 'prawn', '~> 1.3.0' # PDF generation


And install the gems required for GRC using the command below.  (The `--path=.bundle` is optional, but causes bundler to install gems into the `.bundle` local directory.)

    bundle install --path=.bundle

Configure local app settings
----------------------------

### Setup development environment:

After cloning and installing Gems, there are a few files you must modify for your local environment.

First, setup your database by copying the provided `config/database.yml.dist` into place and editting it to your needs:

    cp config/database.yml{.dist,}
    vi config/database.yml

If you're not going to set up a production environment now, there is no reason to have it in the database.yml.

    vi config/database.yml
    comment out production lines:
    #  production:
    #  adapter: mysql
    #  database: cms
    #  username: cms
    #  password: cms
    #  host: localhost

Second, there are a few deployment-specific settings in `config/application.rb`.

#### CMS_CONFIG["SECRET_TOKEN"]

The default is fine for private development, but change this to something secret before deploying (or set with environment variables).

#### CMS_CONFIG["COMPANY_LOGO"]

The company logo shows in the top-left corner of most pages.  If this setting is nil, the logo will just be the text "GRC".  Change this to the URL to display a custom image.

### Initialize database:

Now that your environment and database are configured, you need to initialize the database with the schema and some seed data.  Do the following:

    bundle exec rake db:schema:load
    bundle exec rake db:seed

There is a bug in the account model.  bcrypt wasn't properly required:

    vi app/model/account.rb

add the line:

    require ‘bcrypt’

Now, you can insert the demo seed for the database:

    bundle exec rake demo:seed

And test with the local rails server:

    bundle exec rails server -b 0.0.0.0

### Setup for testing:

To run tests, you must invoke `bundle exec rake db:test:load` after any migration.


Running locally
---------------

### Server:

To run the server locally, use `bundle exec rails s`, and then connect to the webserver using http://localhost:3000 .

### Console:

It is often useful to have a Ruby console to test and debug.  Use `bundle exec rails c` to get to this console.

### Tests (RSpec):

GRC has lots of tests.  You can invoke these tests using `RAILS_ENV=test bundle exec rspec -d`.

After migrations, you may encounter errors running tests.  Run `bundle exec rake db:test:load` to update the test database to the latest schema.


Condensed version
=================

You have RVM, right?  Do this:

    # Install RVM environment
    rvm install 1.9.3-p194
    rvm --create use ruby-1.9.3-p194@grc

    # Checkout code
    git clone https://code.google.com/p/compliance-management grc
    cd grc

    # Install gems
    gem install bundler
    bundle install --path=.bundle

    # Configure application
    cp config/database.yml{.dist,}

    # Initialize database
    bundle exec rake db:schema:load
    bundle exec rake db:seed
    bundle exec rake demo:seed

    # Run tests and cross fingers
    bundle exec rake db:test:load
    RAILS_ENV=test bundle exec rspec -d


CI (continuous integration)
---------------------------

Commits to the `master` branch of the repository are automatically pulled and tested using Jenkins on an external server.  Results are then automatically pushed to a live development server.

