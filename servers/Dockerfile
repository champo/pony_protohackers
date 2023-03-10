FROM ubuntu:22.04 AS deps


RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates \
    clang \
    curl \
    g++ \
    git \
    lsb-core \
    make \
  && rm -rf /var/lib/apt/lists/*

FROM deps AS compiler

ENV PATH "/root/.local/share/ponyup/bin:$PATH"

RUN sh -c "$(curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/ponylang/ponyup/latest-release/ponyup-init.sh)" \
 && ponyup update ponyc release \
 && ponyup update stable release \
 && ponyup update corral release \
 && ponyup update changelog-tool release

FROM compiler AS builder

COPY . /src

RUN cd /src \
    && ponyc -b servers

FROM deps

WORKDIR /app
COPY --from=builder /src/servers /app/servers

CMD ["/app/servers"]