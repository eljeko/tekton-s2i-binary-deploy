#!/bin/bash

if [ ! -z "$1" ]; then
    echo -e "Using prefix: " $1    
    #sed "s/REPLACEME/$1/g" tekton-pipeline/ocp-projects/projects.input.yaml > tekton-pipeline/ocp-projects/projects.yaml
    
    oc_user="`oc whoami`"
    echo -e "Logged in ocp with user: " $oc_user

    if [ ! $oc_user == "" ]; then
        echo -e "Preparing projects"

        #Create projects
        
        oc process -f tekton-pipeline/ocp-projects/projects.input.yaml -p PREFIX=$1 | oc create -f -
        
        echo -e "\n> Projects done\n"
        
        #Create apps    

        ###
        # STAGE
        ###    

        echo -e ""
        oc new-app jboss-eap72-openshift:1.1 --binary --name=acmeapp -n acme-app-stage-$1
        if [ $? -ne 0 ]; then 
            echo -e "\nError creating new app\n"
            exit
        fi
        oc expose svc acmeapp -n acme-app-stage-$1
        if [ $? -ne 0 ]; then 
            echo -e "\nError exposing service\n"
            exit
        fi

        ###
        # PROD
        ###    

        oc new-app jboss-eap72-openshift:1.1 --binary --name=acmeapp -n acme-app-prod-$1
        if [ $? -ne 0 ]; then 
            echo -e "\nError creating new app\n"
            exit
        fi
        oc expose svc acmeapp -n acme-app-prod-$1
        if [ $? -ne 0 ]; then 
            echo -e "E\nrror exposing service\n"
            exit
        fi
        
        echo -e "\n> App prepared\n"
        

        #######
        # Create tektonbot serviceaccount
        #######
        
        #Stage
        
        oc create serviceaccount tektonbot -n acme-app-stage-$1
        oc policy add-role-to-user edit system:serviceaccount:acme-app-stage-$1:tektonbot -n acme-app-stage-$1
        STAGE_SERVICEACCOUNT_TOKEN=`oc serviceaccounts get-token tektonbot -n acme-app-stage-$1`
        echo -e "\nTOKEN > "$STAGE_SERVICEACCOUNT_TOKEN

        #Prod
       
        oc create serviceaccount tektonbot -n acme-app-prod-$1
        oc policy add-role-to-user edit system:serviceaccount:acme-app-prod-$1:tektonbot -n acme-app-prod-$1
        PROD_SERVICEACCOUNT_TOKEN=`oc serviceaccounts get-token tektonbot -n acme-app-prod-$1`
        echo -e "\nTOKEN > "$PROD_SERVICEACCOUNT_TOKEN

        
        echo -e "\n> Service account and Tokens generated\n"
        
        #Prepare CI/CD project

        #Create Tasks
        oc process -f tekton-pipeline/eap-binary-deploy-task-template.yaml -p TOKEN=$STAGE_SERVICEACCOUNT_TOKEN | oc create -f - -n acme-app-cicd-$1
        oc apply -f tekton-pipeline/maven-build-task.yaml -n acme-app-cicd-$1
    
        echo -e "\n> Tasks created\n"        

        #Create PVC
        oc apply -f tekton-pipeline/pvc-pipeline.yaml -n acme-app-cicd-$1
        oc process -f tekton-pipeline/pipeline-template.yaml -p DEFAULT_TARGET_NAMESPACE=acme-app-stage-$1 | oc create -f - -n acme-app-cicd-$1

        echo -e "\n> Pipeline installed\n"        

    else        
        echo -e "\nERROR ##########################"
        echo -e "Please login in your OCP cluster"
        echo -e "################################\n"
    fi
else    
    echo -e "\nNo prefix provided"       
    echo -e "Usage setup.sh <prefix>\n"

fi