# Copyright 2022 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/usr/bin/env python3
ARG username="exporter"
FROM docker.io/library/python:3.9.7-slim AS build

ARG uid=1000
ARG gid=1000
ARG username

COPY exporter /opt/exporter
WORKDIR /opt/exporter

RUN addgroup --gid $gid $username \
    && adduser --disabled-password --gecos '' --uid $uid --gid $gid $username \
    && chown -R $username:$username /opt/exporter
USER $username

RUN pip install --target=/opt/exporter/dependencies prometheus-client==0.14.1 requests==2.28.0

FROM docker.io/library/python:3.9.7-slim AS final

ARG username
ENV PORT=8081
ENV username=$username

WORKDIR /opt/exporter

COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /etc/group /etc/group
COPY --from=build	/opt/exporter .

ENV PYTHONPATH="${PYTHONPATH}:/opt/exporter/dependencies"
USER $username
EXPOSE ${PORT}

ENTRYPOINT ["bash", "./entrypoint.sh"]
