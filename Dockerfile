FROM ruby:3.2.2
RUN apt-get update -qq
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get install -y nodejs
RUN apt-get update && apt-get install -y yarn
RUN mkdir /stretchly_server
WORKDIR /stretchly_server
ADD Gemfile Gemfile.lock /stretchly_server/
RUN bundle install
ADD package.json yarn.lock /stretchly_server/
RUN yarn
ADD . /stretchly_server
