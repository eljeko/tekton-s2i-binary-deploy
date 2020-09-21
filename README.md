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

## The cli

## Create the tasks

We need a maven task for tekton in order to build the warfile


## Create the pipeline

## Run the pipeline