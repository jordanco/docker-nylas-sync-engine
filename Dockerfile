FROM buildpack-deps:jessie-curl
ARG NYLAS_MYSQL_HOST
ARG NYLAS_MYSQL_PORT
ARG NYLAS_MYSQL_USER
ARG NYLAS_MYSQL_PASS
ARG NYLAS_REDIS_HOST
ARG NYLAS_REDIS_PORT
RUN apt-get -qq -y install python-software-properties
RUN apt-get update && apt-get install -y --no-install-recommends \
		git \
                   mercurial \
                   wget \
                   supervisor \
                   mysql-server \
                   mysql-client \
                   python \
                   python-dev \
                   python-pip \
                   python-setuptools \
                   build-essential \
                   libmysqlclient-dev \
                   gcc \
                   g++ \
                   libxml2-dev \
                   libxslt-dev \
                   lib32z1-dev \
                   libffi-dev \
                   pkg-config \
                   python-lxml \
                   tmux \
                   curl \
                   tnef \
                   stow \
                   lua5.2 \
                   liblua5.2-dev \
	&& rm -rf /var/lib/apt/lists/*
# tell pynacl to use system libsodium
ENV SODIUM_INSTALL system
 
WORKDIR /opt/sync-engine
RUN git clone https://github.com/jordanco/sync-engine.git . && rm -rf .git
#ENV SYNC_VERSION v0.3.0 # 2014 :'(
#ENV SYNC_VERSION d715f4c7c2869b1e51f92af47908a9e011ae8aea

#RUN curl -fSL "https://github.com/nylas/sync-engine/archive/$SYNC_VERSION.tar.gz" -o sync.tar.gz \
#	&& tar -xzf sync.tar.gz --strip-components=1 \
#	&& rm sync.tar.gz

# ugh, NameError: name 'PROTOCOL_SSLv3' is not defined
#RUN sed -i 's/^gevent==1.0.1/gevent==1.1rc3/' requirements.txt

#RUN pip install -r requirements.txt
#RUN pip install .
RUN pip install -r requirements.txt && pip install -e . && \
    useradd inbox && \ mkdir -p /etc/inboxapp



#RUN useradd inbox
#RUN mkdir -p /etc/inboxapp
#ADD config.json /etc/inboxapp/config-env.json
#ADD secrets.yml /etc/inboxapp/secrets-env.yml
#RUN chmod 0644 /etc/inboxapp/config-env.json && chmod 0600 /etc/inboxapp/secrets-env.yml && chown -R inbox:inbox /etc/inboxapp
#RUN mkdir -p /var/lib/inboxapp/parts && mkdir -p /var/log/inboxapp && chown inbox:inbox /var/log/inboxapp &&\
#    chown -R inbox:inbox /var/lib/inboxapp && chown -R inbox:inbox /opt/sync-engine


COPY config.json secrets.yml /etc/inboxapp/
RUN sed -i s/"NYLAS_MYSQL_PORT"/"$NYLAS_MYSQL_PORT"/g /etc/inboxapp/config.json
RUN sed -i s/"NYLAS_MYSQL_HOST"/"$NYLAS_MYSQL_HOST"/g /etc/inboxapp/config.json
RUN sed -i s/"NYLAS_REDIS_HOST"/"$NYLAS_REDIS_HOST"/g /etc/inboxapp/config.json
RUN sed -i s/"NYLAS_REDIS_PORT"/"$NYLAS_REDIS_PORT"/g /etc/inboxapp/config.json
RUN sed -i s/"NYLAS_MYSQL_USER"/"$NYLAS_MYSQL_USER"/g /etc/inboxapp/secrets.yml
RUN sed -i s/"NYLAS_MYSQL_PASS"/"$NYLAS_MYSQL_PASS"/g /etc/inboxapp/secrets.yml

USER 1000:1000
COPY entrypoint.sh /bin/
ENTRYPOINT ["entrypoint.sh"]
CMD ["bash"] # TODO inbox-api or inbox-start
