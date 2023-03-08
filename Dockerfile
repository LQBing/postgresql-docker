ARG PG_MAJOR=15
FROM timescale/timescaledb:latest-pg${PG_MAJOR}

RUN set -ex \
    && apk add --no-cache --virtual .fetch-deps \
                ca-certificates \
                git \
                openssl \
                openssl-dev \
                tar \
    && mkdir -p /build/ \
    && git clone https://github.com/pgaudit/pgaudit /build/pgaudit \
    \
    && apk add --no-cache --virtual .build-deps \
                make \
                gcc \
                krb5-dev \
                libc-dev \
                clang \
                llvm \
    \
    # Build current version \
    && cd /build/pgaudit \
    && git checkout REL_${PG_MAJOR}_STABLE\
    && make install USE_PGXS=1 \
    && cd ~ \
    \
    && apk del .fetch-deps .build-deps \
    && rm -rf /build \
    && sed -r -i "s/[#]*\s*(shared_preload_libraries)\s*=\s*'(.*)'/\1 = 'pgaudit,\2'/;s/,'/'/" /usr/local/share/postgresql/postgresql.conf.sample
