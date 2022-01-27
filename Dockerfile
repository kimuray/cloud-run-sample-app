FROM ruby:3.1-alpine

ARG RAILS_ENV
ARG RAILS_MASTER_KEY
ARG CLOUD_SQL_CONNECTION_NAME
ARG GOOGLE_PROJECT_ID

ENV RAILS_ENV=${RAILS_ENV}
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
ENV CLOUD_SQL_CONNECTION_NAME=${CLOUD_SQL_CONNECTION_NAME}
ENV GOOGLE_PROJECT_ID=${GOOGLE_PROJECT_ID}

RUN apk upgrade && \
  apk add --no-cache linux-headers libxml2-dev make gcc libc-dev nodejs tzdata mariadb-dev && \
  apk add --virtual build-packages --no-cache build-base curl-dev

RUN mkdir /myapp
WORKDIR /myapp

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

RUN apk del build-packages
COPY . /myapp

RUN if ["${RAILS_ENV}" = "production"] ; then \
  bundle exec rails assets:precompile; \
  fi

COPY docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "s", "-b", "0.0.0.0"]
