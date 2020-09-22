#!/bin/bash

if [ ! -z "$1" ]; then
    echo "Using prefix: " $1    
    #sed "s/REPLACEME/$1/g" tekton-pipeline/ocp-projects/projects.input.yaml > tekton-pipeline/ocp-projects/projects.yaml
    
    oc_user="`oc whoami`"
    echo "Logged in ocp with user: " $oc_user

    if [ ! $oc_user == "" ]; then
        echo "Cleaning all"

        #Clean apps        
        echo ""
        oc delete project acme-app-stage-$1           
        oc delete project acme-app-prod-$1  
        oc delete project acme-app-cicd-$1
  
        
        echo "Clean Done"        
    else        
        echo "ERROR ##########################"
        echo "Please login in your OCP cluster"
        echo "################################"            
    fi
else    
    echo "No prefix provided"    
    echo ""    
    echo "Usage setup.sh <prefix>"

fi