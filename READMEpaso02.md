# CHALLENGE 05  PASO 2: Crear un Helm Plugin para listar resources requests de CPU y Memoria

## CONFIGURACIÓN
Se usará un helm post-renderer que usará un bash script con el comando "kubectl kustomize" para agregar la funcionalidad nodeAffinity al despliegue del chart.  Usando "helm template" o "helm install" se generará un archivo YAML del chart. Esto se pasará al script de kustomize, quién recibirá el archivo YAML, lo guardará en base.yaml y lo parchará con el contenido de patch.yaml (dicho patch tiene la función nodeAffinity). Notar que patch.yaml tiene una variable de entorno llamado $workerhostname.  Es por ello que el script kustomize.sh usa la herramienta envsubst para poder usar la variable de entorno en el script.

```
ubuntu@lubuntu:~/challenge05/grafanachart$ more kustomization.yaml 
resources:
- base.yaml
patchesStrategicMerge:
- patch.yaml
```
