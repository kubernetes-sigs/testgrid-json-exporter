# K8s-Testgrid Json Exporter

### Usage

#### Testing with docker container

```bash
cd exporter
python prom_client.py 8081
# Now you should be able to access metrics exposed by the exporter at http://127.0.0.1:8081
# You can also run a local Prometheus instance as a container. 
docker run --network=host --mount type=bind,source=./test/prometheus.yml,destination=/etc/prometheus/prometheus.yml --publish published=9090,target=9090,protocol=tcp prom/prometheus
```

#### Testing with K8s
It is also possible to deploy the exporter as standalone container or on kubernetes. This project provides a helm chart to ease the k8s deployment. 

```bash
cd deploy/testgrid-exporter
kubectl create ns monitoring
helm template monitoring -n monitoring . -f values.yaml > exporter.yaml
kubectl -n monitoring create -f exporter.yaml 

kubectl -n monitoring get po 
NAME                                                     READY   STATUS    RESTARTS        AGE
testgrid-exporter-99fc457cd-qpqd5                        1/1     Running   0               1m

kubectl -n monitoring port-forward svc/testgrid-exporter 9098:9098
```

You should be able to access the exposed metrics http://127.0.0.1:9098
