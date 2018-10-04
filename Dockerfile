FROM ruby:2.5.1

ENV DIR /var/src/gcal_app

RUN apt-get update -qq \
    && apt-get install -y sqlite3 libsqlite3-dev libv8-dev

RUN mkdir -p $DIR

WORKDIR $DIR

#ADD Gemfile $DIR
#RUN bundle install

copy . $DIR

RUN bundle install --path vendor/bundler \
 && bundle exec rake db:migrate

EXPOSE  3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# docker build -t myapp . # Build container with current dockerfile
# docker run -it myapp /bin/bash # Run interactive shell on container