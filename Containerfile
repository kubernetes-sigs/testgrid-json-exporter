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

FROM docker.io/library/python:3.9.7-slim 

ADD exporter /opt/exporter
WORKDIR /opt/exporter

ARG PORT=8081
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
