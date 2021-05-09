FROM ruby:2.6
RUN mkdir /app
WORKDIR /app
ADD Gemfile* /app/
RUN gem install bundler
RUN bundle install
ADD . /app