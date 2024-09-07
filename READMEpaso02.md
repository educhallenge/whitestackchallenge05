# CHALLENGE 05  PASO 2: Crear un Helm Plugin para listar resources requests de CPU y Memoria

## CONFIGURACIÓN

Los archivos de este plugin se encuentran disponibles en este git y en este directorio [cpumem](cpumem). El plugin está compuesto de 2 archivos como se muestra:
```
ubuntu@lubuntu:~/cpumem$ tree
.
├── plugin.yaml
└── script.sh

0 directories, 2 files
```

El archivo [plugin.yaml](cpumem/plugin.yaml) es obligatorio. Notar que este archivo llama a ejecutar el archivo "script.sh".  También es importante resaltar que hay un "hook" que otorga permisos de ejecución al archivo "script.sh" debido a que es algo muy común el problema de no poder ejecutar un script debido a falta de permisos.
```
ubuntu@lubuntu:~/cpumem$ more plugin.yaml 
name: "cpumem"
version: "0.1.0"
usage: "helm cpumem -d <chart dir>"
description: "Calculate cpu and mem used by pods in deployment"
ignoreFlags: false
command: "$HELM_PLUGIN_DIR/script.sh"
hooks:
  install: "chmod +x $HELM_PLUGIN_DIR/script.sh"
```

El archivo [script.sh](cpumem/script.sh)  es un bash script que ejecuta el comando "helm template dummytest $chart_dir". Esto es debido al requerimiento de que el plugin no debe instalar la aplicación.

El resultado de dicho comando es parseado por la herramienta yq.  A continuación mostramos el extracto del script que muestra el parseo

```
    my_array=( $( helm template dummytest $chart_dir | yq e 'select(.kind == "Deployment").spec.replicas,select(.kind == "Deployment").spec.template.spec.containers[0].resources.requests.memory,select(.kind == "Deployment").spec.template.spec.containers[0].resources.requests.cpu,select(.kind == "Deployment").metadata.name' ))
```

Dicho parseo sirve para analizar el archivo YAML que resultó del comando "helm template" y capturar los valores de replica, memory resource request , cpu resource request.  Dichos valores se pasan a un array llamado my_array.

Luego manipulamos el valor de memory resource request y cpu resource request para tener por separado el valor númerico y la unidad de medida. Ahora que tenemos el valor numérico podemos multiplicar por el número de replicas y tener el valor total de memory resource request y cpu resource request a nivel de todo el despliegue lo cual es lo que nos piden que haga este plugin.

A continuación un extracto del script que ejecuta lo que se acaba de explicar
```
    replicas=${my_array[0]}
    mem=( $(grep -Eo '[0-9]+|[[:alpha:]]+' <<<${my_array[1]}))

    mem_number=${mem[0]}
    mem_unit=${mem[1]}

    cpu=( $(grep -Eo '[0-9]+|[[:alpha:]]+' <<<${my_array[2]}))
    cpu_number=${cpu[0]}
    cpu_unit=${cpu[1]}

    chartname=${my_array[3]}
    
    echo "Reviewing template of deployment:" $chartname 
    echo "Pod replication number=" $replicas
    echo
    echo "MEM resource request for single pod=" ${my_array[1]}
    echo "CPU resource request for single pod=" ${my_array[2]}
    echo
    echo "MEM resource request for all replicated pods=" $((mem_number * replicas))$mem_unit
    echo "CPU resource request for all replicated pods=" $((cpu_number * replicas))$cpu_unit
```

Instalamos y verificamos que el plugin quedó instalado

```
ubuntu@lubuntu:~/cpumem$ ls
plugin.yaml  script.sh

ubuntu@lubuntu:~/cpumem$ helm plugin install .
Installed plugin: cpumem

ubuntu@lubuntu:~/cpumem$ helm plugin list
NAME  	VERSION	DESCRIPTION                                     
cpumem	0.1.0  	Calculate cpu and mem used by pods in deployment
ubuntu@lubuntu:~/cpumem$ 
```
También podemos verificar que los archivos plugin fueron copiados al directorio $HELM_PLUGIN

```
ubuntu@lubuntu:~/cpumem$ helm env | grep HELM_PLUGIN
HELM_PLUGINS="/home/ubuntu/.local/share/helm/plugins"

ubuntu@lubuntu:~/cpumem$ cd /home/ubuntu/.local/share/helm/plugins/cpumem
ubuntu@lubuntu:~/.local/share/helm/plugins/cpumem$ ls -hal
total 16K
drwxrwxr-x 2 ubuntu ubuntu 4.0K Sep  7 02:07 .
drwxr-xr-x 9 ubuntu ubuntu 4.0K Sep  7 02:10 ..
-rw-rw-r-- 1 ubuntu ubuntu  245 Sep  6 02:01 plugin.yaml
-rwxrwxr-x 1 ubuntu ubuntu 2.0K Sep  7 00:17 script.sh
```

## EJECUCIÓN

El plugin se llama cpumem por tanto se ejecuta con el comando "helm cpumem". Es necesario usar el flag -d para especificar el directorio donde se encuentra el chart.

Vemos abajo que efectivamente se extraen los valores de # de réplicas,  mem resource request, cpu resource request y luego se hace la multiplicación para encontrar los valores totales necesarios a nivel de todo el deployment.  También se respetan las unidades de medida de memoria y cpu.

```
ubuntu@lubuntu:~$ helm cpumem -d challenge05/grafanachart
Reviewing template of deployment: grafana
Pod replication number= 3

MEM resource request for single pod= 400M
CPU resource request for single pod= 500m

MEM resource request for all replicated pods= 1200M
CPU resource request for all replicated pods= 1500m

```
