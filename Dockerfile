FROM buildpack-deps:precise-curl
ARG NYLAS_MYSQL_HOST
ARG NYLAS_MYSQL_PORT
ARG NYLAS_MYSQL_USER
ARG NYLAS_MYSQL_PASS
ARG NYLAS_REDIS_HOST
ARG NYLAS_REDIS_PORT
RUN apt-get update && apt-get install -y --no-install-recommends \
		   python-software-properties \
		   git \
                   mercurial \
                   wget \
                   #supervisor \
                   #mysql-server \
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
 
WORKDIR /opt/sync-engine
RUN git clone https://github.com/jordanco/sync-engine.git . && rm -rf .git

RUN mkdir -p /tmp/build
WORKDIR /tmp/build
ENV LIBSODIUM_VER=1.0.0

RUN curl -L -O https://github.com/jedisct1/libsodium/releases/download/${LIBSODIUM_VER}/libsodium-${LIBSODIUM_VER}.tar.gz
RUN echo 'ced1fe3d2066953fea94f307a92f8ae41bf0643739a44309cbe43aa881dbc9a5 *libsodium-1.0.0.tar.gz' | sha256sum -c || exit 1
RUN tar -xzf libsodium-${LIBSODIUM_VER}.tar.gz
WORKDIR /tmp/build/libsodium-1.0.0
RUN ./configure --prefix=/usr/local/stow/libsodium-${LIBSODIUM_VER} &&\
                  make -j4 &&\
                  rm -rf /usr/local/stow/libsodium-${LIBSODIUM_VER} &&\
                  mkdir -p /usr/local/stow/libsodium-${LIBSODIUM_VER} &&\
                  make install &&\
                  stow -d /usr/local/stow -R libsodium-${LIBSODIUM_VER} &&\
                  ldconfig
WORKDIR /tmp/build
RUN rm -rf libsodium-${LIBSODIUM_VER} libsodium-${LIBSODIUM_VER}.tar.gz &&\
     pip install 'pip>=1.5.6' 'setuptools>=5.3' && hash pip && pip install 'pip>=1.5.6' 'setuptools>=5.3' tox &&\
     rm -rf /usr/lib/python2.7/dist-packages/setuptools.egg-info
WORKDIR /opt/sync-engine
RUN pip install -r requirements.txt && pip install -e .
#RUN useradd inbox && \ mkdir -p /etc/inboxapp



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
RUN sed -i s/"NYLAS_REDIS_HOST"/"$NYLAS_REDIS_HOST"/g /etc/inboxapp/secrets.yml

COPY entrypoint.sh /bin/
WORKDIR /bin
RUN chmod +x /bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["bash"] # TODO inbox-api or inbox-start
