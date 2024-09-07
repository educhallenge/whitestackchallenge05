# CHALLENGE 05  PASO 1: Desplegar el pod en un nodo específico con Post Rendering

## CONFIGURACIÓN
Se usará un helm post-renderer que usará un bash script con el comando "kubectl kustomize" para agregar la funcionalidad nodeAffinity al despliegue del chart.  Usando "helm template" o "helm install" se generará un archivo YAML del chart. Esto se pasará al script de kustomize, quién recibirá el archivo YAML, lo guardará en base.yaml y lo parchará con el contenido de patch.yaml (dicho patch tiene la función nodeAffinity).

Debido a que no tenemos permisos de ver los labels de los workers hemos configurado nodeAffinity con el label "kubernetes.io/hostname" el cual es un label por defecto. 

Notar que patch.yaml tiene una variable de entorno llamado $workerhostname el cual se usa para asignar un valor al label "kubernetes.io/hostname"

Es por ello que el script kustomize.sh usa la herramienta envsubst para poder usar la variable de entorno en el script.

```
ubuntu@lubuntu:~/challenge05/grafanachart$ more kustomization.yaml 
resources:
- base.yaml
patchesStrategicMerge:
- patch.yaml
```
```
ubuntu@lubuntu:~/challenge05/grafanachart$ more kustomize.sh
#!/bin/sh
cat > base.yaml
# you can also use "kustomize build ." if you have it installed.
exec kubectl kustomize| envsubst
rm base.yaml
```
```
ubuntu@lubuntu:~/challenge05/grafanachart$ more patch.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
spec:
  template:
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 1
            preference:
              matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                - ${workerhostname}
```

## EJECUCIÓN

Se configura la variable de entorno para seleccionar cuál es el worker en que se prefiere desplegar los pods. Luego ejecutamos la opción post-renderer de helm. Esta opción llama al script [kustomize.sh](chart_files/kustomize.sh)
```
ubuntu@lubuntu:~/challenge05/grafanachart$ export workerhostname=whitestackchallenge-worker-f97ebc81-kfbgg
```
Podemos primero usar "helm template" para verificar que el archivo YAML resultante del script esté correcto. Luego podemos usar "helm install" para instalar el chart.
```
ubuntu@lubuntu:~/challenge05/grafanachart$ helm template mygrafana . --post-renderer ./kustomize.sh 
apiVersion: v1
kind: Service
metadata:
  name: grafana
spec:
  ports:
  - port: 3000
    targetPort: 3000
  selector:
    app: grafana
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
spec:
  replicas: 3
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
      name: grafana
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - preference:
              matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                - whitestackchallenge-worker-f97ebc81-kfbgg
            weight: 1
      containers:
      - env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: whitestack
        image: grafana/grafana:11.2.0
        name: grafana
        ports:
        - containerPort: 3000
          name: grafana
        resources:
          limits:
            cpu: 1000m
            memory: 1Gi
          requests:
            cpu: 500m
            memory: 400M

```
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

Se verifica que las 3 réplicas de Grafana se desplegaron en el worker llamado "whitestackchallenge-worker-f97ebc81-kfbgg" lo cual es el resultado esperado

```
ubuntu@lubuntu:~/challenge05/grafanachart$ kubectl get pod -owide
NAME                       READY   STATUS    RESTARTS   AGE   IP              NODE                                        NOMINATED NODE   READINESS GATES
grafana-7bc9f6c598-5tdg2   1/1     Running   0          6s    10.42.228.179   whitestackchallenge-worker-f97ebc81-kfbgg   <none>           <none>
grafana-7bc9f6c598-chfqj   1/1     Running   0          6s    10.42.228.136   whitestackchallenge-worker-f97ebc81-kfbgg   <none>           <none>
grafana-7bc9f6c598-dzxrh   1/1     Running   0          6s    10.42.228.130   whitestackchallenge-worker-f97ebc81-kfbgg   <none>           <none>

```
