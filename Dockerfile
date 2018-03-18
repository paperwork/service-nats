FROM paperworkco/paperplane:latest

RUN apk update \
 && rm -rf /var/cache/apk/*

# add ContainerPilot configuration
COPY containerpilot.json5 /etc/containerpilot.json5
COPY containerpilot.sh /usr/local/bin/
RUN chmod 500 /usr/local/bin/containerpilot.sh


########### Service related ###########

# Add NATS
ENV GNATSD_VERSION=1.0.6 \
    GNATSD_CHECKSUM=019ee2170feb68504d1d15e4959cd2dbabbd6cd1
RUN curl -Lso /tmp/gnatsd.zip "https://github.com/nats-io/gnatsd/releases/download/v${GNATSD_VERSION}/gnatsd-v${GNATSD_VERSION}-linux-amd64.zip" \
 && echo "${GNATSD_CHECKSUM}  /tmp/gnatsd.zip" | sha1sum -c \
 && unzip -j /tmp/gnatsd.zip -d /tmp

RUN mv /tmp/gnatsd /usr/local/bin/gnatsd \
 && rm /tmp/gnatsd.zip

# COPY NATS config & manage.sh
COPY gnatsd.conf.tmpl /etc/gnatsd.conf.tmpl


EXPOSE 4222 8222 6222

ENTRYPOINT []
CMD ["containerpilot"]
