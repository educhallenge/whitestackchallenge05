# CHALLENGE 05  PASO 3: Crear Helm Plugin para validación y configuración de información sensible

## ESTRUCTURA DEL PLUGIN

Los archivos de este plugin se encuentran disponibles en este git y en este directorio [sensitivedata](sensitivedata). El plugin está compuesto de 2 archivos como se muestra:
```
ubuntu@lubuntu:~/sensitivedata$ tree
.
├── plugin.yaml
└── script.sh

0 directories, 2 files
```

El archivo [plugin.yaml](sensitivedata/plugin.yaml) es obligatorio. Notar que este archivo llama a ejecutar el archivo "script.sh".  También es importante resaltar que hay un "hook" que otorga permisos de ejecución al archivo "script.sh" debido a que es algo muy común el problema de no poder ejecutar un script debido a falta de permisos.
```
ame: "sensitivedata"
version: "0.1.0"
usage: "helm sensitivedata -d <chart dir>"
description: "This plugin is used to check and enforce password complexity. Also to enforce the use of secrets"
ignoreFlags: false
command: "$HELM_PLUGIN_DIR/script.sh"
hooks:
  install: "chmod +x $HELM_PLUGIN_DIR/script.sh"
```

El plugin necesita que declaremos el valor del directorio del chart. A continuación un ejemplo de su uso

```
ubuntu@lubuntu:~$ helm sensitivedata -d ./challenge05/grafanachart
```

## REQUISITO DE PASSWORD COMPLEXITY

Cumplimos este requisito con la función El archivo [script.sh](sensitivedata/script.sh)  es un bash script que ejecuta el comando "helm template dummytest $chart_dir". Esto es debido al requerimiento de que el plugin no debe instalar la aplicación.

El resultado de dicho comando es parseado por la herramienta yq.  A continuación mostramos el extracto del script que muestra el parseo

```
    my_array=( $( helm template dummytest $chart_dir | yq e 'select(.kind == "Deployment").spec.replicas,select(.kind == "Deployment").spec.template.spec.containers[0].resources.requests.memory,select(.kind == "Deployment").spec.template.spec.containers[0].resources.requests.cpu,select(.kind == "Deployment").metadata.name' ))
```


## REQUISITO DE CREAR SECRET

