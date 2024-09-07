#!/bin/bash

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

calculate_cpumem() {
    my_array=( $( helm template dummytest $chart_dir | yq e 'select(.kind == "Deployment").spec.replicas,select(.kind == "Deployment").spec.template.spec.containers[0].resources.requests.memory,select(.kind == "Deployment").spec.template.spec.containers[0].resources.requests.cpu,select(.kind == "Deployment").metadata.name' ))

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

}

has_argument() {
    [[ ("$1" == *=* && -n ${1#*=}) || ( ! -z "$2" && "$2" != -*)  ]];
}

extract_argument() {
  echo "${2:-${1#*=}}"
}

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
        *) echo "Unknown parameter passed: $1" ;;
    esac
    shift
done


