# K8s-Testgrid Json Exporter

### Usage

```bash
python prom_client.py 8081 https://testgrid.k8s.io/sig-release-master-informing/summary

### For local testing purpose
docker run --network=host --mount type=bind,source=/opt/lab/github/testgrid_json_exporter/test/prometheus.yml,destination=/etc/prometheus/prometheus.yml --mount type=bind,source=/opt/lab/github/testgrid_json_exporter/test/alert.rules,destination=/alertmanager/alert.rules --publish published=9090,target=9090,protocol=tcp prom/prometheus
```
