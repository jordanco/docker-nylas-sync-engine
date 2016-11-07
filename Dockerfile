FROM buildpack-deps:jessie-curl

RUN apt-get update && apt-get install -y --no-install-recommends \
		file \
		g++ \
		gcc \
		git \
		libffi-dev \
		liblua5.2-dev \
		libmysqlclient-dev \
		libpython-dev \
		libsodium-dev \
		libssl-dev \
		libxslt1-dev \
		pkg-config \
		python-pip \
	&& rm -rf /var/lib/apt/lists/*
# tell pynacl to use system libsodium
ENV SODIUM_INSTALL system

WORKDIR /opt/sync-engine/
RUN git clone https://github.com/jordanco/sync-engine.git && rm -rf .git
#ENV SYNC_VERSION v0.3.0 # 2014 :'(
#ENV SYNC_VERSION d715f4c7c2869b1e51f92af47908a9e011ae8aea

#RUN curl -fSL "https://github.com/nylas/sync-engine/archive/$SYNC_VERSION.tar.gz" -o sync.tar.gz \
#	&& tar -xzf sync.tar.gz --strip-components=1 \
#	&& rm sync.tar.gz

# ugh, NameError: name 'PROTOCOL_SSLv3' is not defined
#RUN sed -i 's/^gevent==1.0.1/gevent==1.1rc3/' requirements.txt

RUN pip install -r requirements.txt

RUN pip install .

#RUN useradd inbox
RUN mkdir -p /etc/inboxapp
ADD config.json /etc/inboxapp/config-env.json
ADD secrets.yml /etc/inboxapp/secrets-env.yml
#RUN chmod 0644 /etc/inboxapp/config-env.json && chmod 0600 /etc/inboxapp/secrets-env.yml && chown -R inbox:inbox /etc/inboxapp
#RUN mkdir -p /var/lib/inboxapp/parts && mkdir -p /var/log/inboxapp && chown inbox:inbox /var/log/inboxapp &&\
#    chown -R inbox:inbox /var/lib/inboxapp && chown -R inbox:inbox /opt/sync-engine



COPY config.json secrets.yml /etc/inboxapp/

USER 1000:1000
COPY entrypoint.sh /bin/
ENTRYPOINT ["entrypoint.sh"]
CMD ["bash"] # TODO inbox-api or inbox-start
