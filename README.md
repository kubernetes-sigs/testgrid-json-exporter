# K8s-Testgrid Json Exporter

### Usage

#### Testing with docker container

```bash
vim prom_client.py
# change addr according to your local network settings
#addr='127.0.0.1'
python prom_client.py 8081 https://testgrid.k8s.io/sig-release-master-informing/summary
docker run --network=host --mount type=bind,source=./test/prometheus.yml,destination=/etc/prometheus/prometheus.yml --mount type=bind,source=./test/alert.rules,destination=/alertmanager/alert.rules --publish published=9090,target=9090,protocol=tcp prom/prometheus
```

#### Testing with K8s

