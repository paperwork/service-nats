FROM paperworkco/paperplane:latest

RUN apk update \
 && rm -rf /var/cache/apk/*

# add ContainerPilot configuration
COPY containerpilot.json5 /etc/containerpilot.json5
COPY containerpilot.sh /usr/local/bin/
RUN chmod 500 /usr/local/bin/containerpilot.sh


########### Service related ###########

# Add NATS
ENV GNATSD_VERSION=1.2.0 \
    GNATSD_CHECKSUM=c544891f510fe3afc3b1eae90ee7c26adafca845
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
