# Prepare the app manually for the first run

## Prerequisite

* maven >= 3.6
* [oc client](https://docs.openshift.com/container-platform/4.4/cli_reference/openshift_cli/getting-started-cli.html)

Login in to your ocp cluster

Create the project

```
oc new-project acme-app
```

## Build the app

Got to app dir ```cd acme-app```

Build the app:

```mvn clean package -Dappversion=1.0```

## Deploy the app

Go back to project root

Create new app:

```
oc new-app jboss-eap72-openshift:1.1 --binary --name=acmeapp
```

Start the binary build:

```oc start-build acmeapp --from-file acme-app/target/ROOT.war```

Expose the service:

```oc expose svc acmeapp```

Wait for the pod with the app to be available (```oc get pods```).

Now from the route created by OpenShift you can reach the application deployed (the application is published on the root path)

# Tekton Pipeline

Clean if you need

```
oc delete pipeline acme-app-build-and-deploy
oc delete task maven-build
oc delete task eap-binary-deploy-task
```

## The cli

## Create the tasks

We need a maven task for tekton in order to build the warfile

Add maven build task
```
oc apply -f manven-build-task.yaml
```

Create binary deploy task:
```
oc apply -f eap-binary-deploy-task.yaml
``` 

## Create the pipeline

```
oc apply -f pipeline.yaml
````

## OCP: Create a service account

In the target project:

oc project acme-app

Create a new service account called jenkins

```oc create serviceaccount tektonbot```

The service account will need to have project level access to each of the projects it will manage The edit role provides a sufficient level of access needed by Jenkins.

```oc policy add-role-to-user edit system:serviceaccount:acme-app:tektonbot -n acme-app```

```oc serviceaccounts get-token tektonbot -n acme-app```

Get yor token to use as a parameter to start the pipeline

## Run the pipeline