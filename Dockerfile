# Base docker image
FROM debian:stable-slim

LABEL maintainer="David Colmenares <ersoul@sdf.org>"

# Install dependencies to add Tor's repository.
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    libcap2-bin \
    --no-install-recommends

# See: <https://2019.www.torproject.org/docs/debian.html.en>
RUN curl -o /etc/apt/keyrings/torproject.gpg https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc && \
      echo "deb [signed-by=/etc/apt/keyrings/torproject.gpg] https://deb.torproject.org/torproject.org stable main" >> /etc/apt/sources.list.d/tor.list

# Install remaining dependencies.
RUN apt-get update && apt-get install -y \
    tor \
    tor-geoipdb \
    obfs4proxy \
    nyx \
    --no-install-recommends

# Allow obfs4proxy to bind to ports < 1024.
RUN setcap cap_net_bind_service=+ep /usr/bin/obfs4proxy

# Our torrc is generated at run-time by the script start-tor.sh.
RUN rm /etc/tor/torrc && chown -R debian-tor:debian-tor /etc/tor && chown -R debian-tor:debian-tor /var/lib/tor

COPY start-tor.sh /usr/local/bin
COPY get-bridge-line /usr/local/bin

RUN chmod 0755 /usr/local/bin/get-bridge-line /usr/local/bin/start-tor.sh

USER debian-tor

ENTRYPOINT [ "/usr/local/bin/start-tor.sh" ]
