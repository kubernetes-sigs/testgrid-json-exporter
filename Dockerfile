FROM docker.io/library/python:3.9.7-slim 

ADD exporter /opt/exporter
WORKDIR /opt/exporter

ARG PORT=9098
ENV PORT=$PORT
ARG uid=1000
ARG gid=1000
ARG username="exporter"
RUN addgroup --gid $gid $username
RUN adduser --disabled-password --gecos '' --uid $uid --gid $gid $username
RUN chown -R $username:$username /opt/exporter

# Run container as $username
RUN pip install prometheus-client requests
RUN rm /usr/bin/apt* /usr/local/bin/pip*
USER $username

EXPOSE ${PORT}
ENTRYPOINT ["bash", "./entrypoint.sh"]
