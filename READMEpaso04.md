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

También mostramos el extracto de "script.sh" donde 
