FROM ruby:2.4.2
RUN apt-get update -qq && apt-get install -y build-essential nodejs mysql-client
RUN mkdir /es-desk
WORKDIR /es-desk
ADD Gemfile /es-desk/Gemfile
ADD Gemfile.lock /es-desk/Gemfile.lock
RUN bundle install
ADD . /es-desk
