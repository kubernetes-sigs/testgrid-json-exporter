from prometheus_client import start_http_server, Metric, REGISTRY, Enum
from prometheus_client.core import CounterMetricFamily, GaugeMetricFamily
import json
import requests
import sys
import time
from datetime import datetime


class JsonCollector(object):
  def __init__(self, endpoint):
    self._endpoint = endpoint
  def collect(self):
    # Fetch the JSON
    response = json.loads(requests.get(self._endpoint).content.decode('UTF-8'))
    for k,v in response.items():
      if v['overall_status'] == 'FAILING':
        alert=1
        metric = Metric('alert_status', 'Alert Status', 'summary')
        metric.add_sample('alert_status', value=alert, labels={'job_name': k, 'overall_status': v['overall_status'], 'last_run_timestamp': str(datetime.fromtimestamp(v['last_run_timestamp']))})
        yield metric
      else:
        metric = Metric('alert_status', 'Alert Status', 'summary')
        metric.add_sample('alert_status', value=0, labels={'job_name': k, 'overall_status': v['overall_status'], 'last_run_timestamp': str(datetime.fromtimestamp(v['last_run_timestamp']))})
        yield metric 

if __name__ == '__main__':
  # Usage: json_exporter.py port endpoint
  start_http_server(int(sys.argv[1]))
  REGISTRY.register(JsonCollector(sys.argv[2]))

  while True: time.sleep(1)
