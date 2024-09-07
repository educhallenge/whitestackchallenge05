# CHALLENGE 05  PASO 4: Documentación de plugins y scripts

## CONFIGURACIÓN

Nos piden que los plugins use el flag --help para mostrar una ayuda amigable y también nos piden que los plugin se den cuenta cuando su ejecución no cumple con la sintaxis esperada.

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

Vemos que el uso del flag --help efectivamente muestra una ayuda amigable

```
ubuntu@lubuntu:~$ helm cpumem --help
Calculate cpu and mem resource request by pods in deployment

Usage:
 helm cpumem -d <chart directory>

   -h, --help         Displays the help message
   -d, --dir          Specify the directory where the chart is located 
```

Si usamos un argumento diferente a lo explicado arriba entonces debe generar el mensaje de error "Unknown parameter passed" y luego debe mostrar la ayuda amigable. Esto lo comprobamos con el output de abajo 

```
ubuntu@lubuntu:~$ helm cpumem mistake
Unknown parameter passed: mistake
Calculate cpu and mem resource request by pods in deployment

Usage:
 helm cpumem -d <chart directory>

   -h, --help         Displays the help message
   -d, --dir          Specify the directory where the chart is located 
```
