# CHALLENGE 05  PASO 1: Desplegar el pod en un nodo específico con Post Rendering


## EJECUCIÓN

Se configura la variable de entorno para seleccionar cuál es el worker en que se prefiere desplegar los pods. Luego ejecutamos la opción post-renderer de helm. Esta opción llama al script [kustomize.sh](chart_files/kustomize.sh)

```
ubuntu@lubuntu:~/challenge05/grafanachart$ helm install mygrafana . --post-renderer ./kustomize.sh 
NAME: mygrafana
LAST DEPLOYED: Fri Sep  6 22:59:57 2024
NAMESPACE: challenger-004
STATUS: deployed
REVISION: 1
TEST SUITE: None
```


## VERIFICACION

Se verifica que los 3 replicas de Grafana se deplegaron en el worker llamado whitestackchallenge-worker-f97ebc81-kfbgge

```
ubuntu@lubuntu:~/challenge05/grafanachart$ kubectl get pod -owide
NAME                       READY   STATUS    RESTARTS   AGE   IP              NODE                                        NOMINATED NODE   READINESS GATES
grafana-7bc9f6c598-5tdg2   1/1     Running   0          6s    10.42.228.179   whitestackchallenge-worker-f97ebc81-kfbgg   <none>           <none>
grafana-7bc9f6c598-chfqj   1/1     Running   0          6s    10.42.228.136   whitestackchallenge-worker-f97ebc81-kfbgg   <none>           <none>
grafana-7bc9f6c598-dzxrh   1/1     Running   0          6s    10.42.228.130   whitestackchallenge-worker-f97ebc81-kfbgg   <none>           <none>

```
