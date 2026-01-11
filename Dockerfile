FROM ruby:3.2.2
RUN apt-get update -qq
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN NODE_VERSION=20.19.6 \
	&& ARCH=linux-x64 \
	&& curl -fsSLO "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-${ARCH}.tar.xz" \
	&& tar -xJf "node-v${NODE_VERSION}-${ARCH}.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
	&& rm "node-v${NODE_VERSION}-${ARCH}.tar.xz" \
	&& curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
	&& echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
	&& apt-get update && apt-get install -y yarn \
	&& node -v && npm -v && yarn -v
RUN mkdir /stretchly_server
WORKDIR /stretchly_server
ADD Gemfile Gemfile.lock /stretchly_server/
RUN bundle install
ADD package.json yarn.lock /stretchly_server/
RUN yarn
ADD . /stretchly_server
