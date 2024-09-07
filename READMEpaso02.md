# CHALLENGE 05  PASO 2: Crear un Helm Plugin para listar resources requests de CPU y Memoria

## CONFIGURACIÓN

El plugin se llama [cpumem](cpumem). Está compuesto de 2 archivos como se muestra:
```
ubuntu@lubuntu:~/.local/share/helm/plugins/cpumem$ tree
.
├── plugin.yaml
└── script.sh

0 directories, 2 files
```

Mostramos el archivo [plugin.yaml](cpumem/plugin.yaml) el cual es obligatorio. Notar que este archivo llama a ejecutar el archivo "script.sh".  También es importante resaltar que hay un "hook" que otorga permisos de ejecución al archivo "script.sh" debido a que es algo muy común el problema de no poder ejecutar un script debido a falta de permisos.
```
ubuntu@lubuntu:~/.local/share/helm/plugins/cpumem$ more plugin.yaml 
name: "cpumem"
version: "0.1.0"
usage: "helm cpumem -d <chart dir>"
description: "Calculate cpu and mem used by pods in deployment"
ignoreFlags: false
command: "$HELM_PLUGIN_DIR/script.sh"
hooks:
  install: "chmod +x $HELM_PLUGIN_DIR/script.sh"
```
