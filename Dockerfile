FROM ruby:2.7.1

ENV HOME "/app"
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

WORKDIR ${HOME}

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt update && \
    apt install -y build-essential \
                   libpq-dev \
                   nodejs \
                   yarn

COPY Gemfile      ${HOME}
COPY Gemfile.lock ${HOME}
COPY package.json ${HOME}
COPY yarn.lock    ${HOME}

RUN bundle install -j4 && \
    yarn install

COPY . ${HOME}

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]