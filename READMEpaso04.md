# CHALLENGE 05  PASO 4: Documentación de plugins y scripts

## CONFIGURACIÓN

Nos piden que los 2 plugins usen el flag --help para mostrar una ayuda amigable y también nos piden que los plugins den un mensaje de error cuando no se cumple con la sintaxis esperada.

Ambos plugins comparten el mismo código para cumplir con esos requerimientos, por eso abajo sólo hacemos los ejemplos con uno solo de los plugins: el plugin "cpumem".

Presentamos el extracto de "script.sh" donde se muestra la función "display_help" que se encarga de mostrar una ayuda amigable e indicar al usuario final la sintaxis correcta y las flags y atributos que necesita.
```
display_help() {
    echo "Calculate cpu and mem resource request by pods in deployment"
    echo
    echo "Usage:"
    echo " helm cpumem -d <chart directory>" >&2
    echo
    echo "   -h, --help         Displays the help message"
    echo "   -d, --dir          Specify the directory where the chart is located "
    echo
    exit 0
}
```

También mostramos el extracto de "script.sh" que se encarga de analizar los argumentos que se pasan al comando "helm cpumem". Vemos que tanto el flag -h como --help disparan la ejecución de la función display_help mostrada arriba.
También vemos que tanto el flag -d como --dir esperar un argumento que apunte al directorio donde está el chart
Finalmente vemos el * que indica que para cualquier otro argumento se imprimirá el mensaje de error "Unknow parameter passed" y también disparará la ejecución de la función display_help

```
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) display_help; shift ;;
        -d| --dir*)
        if ! has_argument $@; then
          echo "Chart directory not specified." >&2
          display_help
          exit 1
        fi
        chart_dir=$(extract_argument $@)
        calculate_cpumem $chart_dir

        shift ;;
        *) echo "Unknown parameter passed: $1"; display_help ;;
    esac
    shift
done
```

## EJECUCIÓN

Vemos que el uso del flag --help efectivamente muestra la ayuda amigable de la función "display_help"

```
ubuntu@lubuntu:~$ helm cpumem --help
Calculate cpu and mem resource request by pods in deployment

Usage:
 helm cpumem -d <chart directory>

   -h, --help         Displays the help message
   -d, --dir          Specify the directory where the chart is located 
```

Ahora vemos el caso cuando nos equivocamos en la sintaxis, lo cual sucede si usamos un argumento diferente a lo explicado arriba entonces debe generar el mensaje de error `Unknown parameter passed` y luego mostrar el mensaje de la función "display_help". Esto lo comprobamos con el output de abajo 

```
ubuntu@lubuntu:~$ helm cpumem mistake
Unknown parameter passed: mistake
Calculate cpu and mem resource request by pods in deployment

Usage:
 helm cpumem -d <chart directory>

   -h, --help         Displays the help message
   -d, --dir          Specify the directory where the chart is located 
```

También manejamos el caso cuando usamos el flag -d pero no especifcamos ningún directorio entonces tenemos el mensaje de error `Chart directory not specified` y luego nos aparece el mensaje de la función "display_help"

```
ubuntu@lubuntu:~$ helm cpumem -d
Chart directory not specified.
Calculate cpu and mem resource request by pods in deployment

Usage:
 helm cpumem -d <chart directory>

   -h, --help         Displays the help message
   -d, --dir          Specify the directory where the chart is located 
```
