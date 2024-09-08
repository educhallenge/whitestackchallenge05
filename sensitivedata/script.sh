#!/bin/bash

display_help() {
    echo "This plugin is used to check and enforce password complexity. Also to enforce the use of secrets"
    echo
    echo "Usage:"
    echo " helm sensitivedata -d <chart directory>" >&2
    echo
    echo "   -h, --help         Displays the help message"
    echo "   -d, --dir          Specify the directory where the chart is located "
    echo
    exit 0
}

enforce_passcomplexity() {
    my_array=( $( yq '.deploy.containers.env' $chart_dir/values.yaml | yq '.*pass,.*credentials,.*passwords,.*pwd' ))
    echo
    len=${#my_array[@]}
 
    ## Use bash for loop 
    for (( i=0; i<$len; i++ ))
    do 
      myvar=${my_array[$i]}
      if [ $myvar != null ] ; then
         if [ ${#myvar} -lt 8 ]; then
           echo "Password has below  than 8 characters. Aborting chart installation"
           exit 1
         else
           echo "Policy enforced. Password has 8 or more characters"
           if [[ ! $myvar =~ [A-Z] ]]; then
             echo "Password does not contain an uppercase letter. Aborting chart installation"
             exit 1
           else
             echo "Policy enforced. Password contains at least one uppercase letter."
             if [[ ! $myvar =~ [a-z] ]]; then
               echo "Password does not contain a lowercase letter. Aborting chart installation"
               exit 1
             else
               echo "Policy enforced. Password contains at least one lowercase letter."
               if [[ ! $myvar =~ [0-9] ]]; then
                 echo "Password does not contain a digit. Aborting chart installation"
                 exit 1
               else
                 echo "Policy enforced. Password contains at least one digit."
                 if [[ ! $myvar =~ ['!@#$%^&*()_+'] ]]; then
                   echo "Password does not contain one of the following  !@#$%^&*()_+ special characters. Aborting chart installation"
                   exit 1
                 else
                   echo "Policy enforced. Password contains at least one of the following  !@#$%^&*()_+ special characters."
                 fi
               fi
             fi
           fi
         fi
      fi
    done


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
        enforce_passcomplexity $chart_dir

        myname=$(yq '.deploy.name' $chart_dir/values.yaml)
        cd $chart_dir/paso03kustomize
        helm install $myname .. --post-renderer ./kustomize.sh

        shift ;;
        *) echo "Unknown parameter passed: $1"; display_help ;;
    esac
    shift
done


