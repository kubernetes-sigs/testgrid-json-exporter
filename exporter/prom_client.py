# Copyright 2021 The Kubernetes Authors.
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

import json
import time
import sys
from datetime import datetime
import requests
from prometheus_client import start_http_server, Metric, REGISTRY

urls = ["https://testgrid.k8s.io/sig-release-master-informing/summary",
        "https://testgrid.k8s.io/sig-release-master-blocking/summary"]


class JsonCollector(object):
    def __init__(self, endpoint):
        self._endpoint = list(endpoint)

    def collect(self):
        for url in self._endpoint:
            response = json.loads(requests.get(url).content.decode('UTF-8'))
            for k, v in response.items():
                metric = Metric('test_status', 'Test Status', 'summary')
                if v['overall_status'] == 'FAILING':
                    alert = 1
                    metric.add_sample(
                        'test_status',
                        value=alert,
                        labels={
                            'job_name': k,
                            'overall_status': v['overall_status'],
                            'status': v['status'],
                            'last_green_commit': v['latest_green'],
                            'bug_url': v['bug_url'],
                            'last_run_timestamp': str(datetime.fromtimestamp(v['last_run_timestamp']))
                        }
                    )
                    yield metric
                    for test in v['tests']:
                        metric = Metric('failing_test_details',
                                        'Failing Test Details', 'summary')
                        metric.add_sample(
                            'failing_test_details',
                            value=test['fail_count'],
                            labels={
                                'test_name': test['display_name'],
                                'fail_timestamp': str(datetime.fromtimestamp(test['fail_timestamp'])),
                                'pass_timestamp': str(datetime.fromtimestamp(test['pass_timestamp'])),
                                'fail_count': str(test['fail_count']), 'fail_test_link': test['fail_test_link']
                            }
                        )
                        yield metric
                else:
                    alert = 0
                    metric.add_sample(
                        'test_status',
                        value=alert,
                        labels={
                            'job_name': k,
                            'overall_status': v['overall_status'],
                            'status': v['status'],
                            'last_green_commit': v['latest_green'],
                            'bug_url': v['bug_url'],
                            'last_run_timestamp': str(datetime.fromtimestamp(v['last_run_timestamp']))
                        }
                    )
                    yield metric


if __name__ == '__main__':
    start_http_server(int(sys.argv[1]))
    REGISTRY.register(JsonCollector(urls))

    # TODO: check this looks strange -- reminds me of active waiting
    while True:
        time.sleep(1)
