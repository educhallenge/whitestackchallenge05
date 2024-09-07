# CHALLENGE 05  PASO 3: Crear Helm Plugin para validación y configuración de información sensible

## CONFIGURACIÓN

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
