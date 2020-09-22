# Tekton s2i binary deploy example

## Prerequisite

* [oc client](https://docs.openshift.com/container-platform/4.4/cli_reference/openshift_cli/getting-started-cli.html)

## Install the examples

Login on your OCP cluster then just run the ```setup.sh``` and provide a prefix.

```
$ ./setup.sh demo
```

The script should output all the steps

* Creates the projects
* Creates the app in both stage and prod project
* Creates ```serviceaccount``` in the projects to use from CI/CD project
* Creates the Tekton tasks
* Creates pvc for the build
* Creates the Pipeline

## Remove the examples

Login on your OCP cluster then just run the ```clean.sh``` and provide a prefix (the same provided to install.sh).

```
$ ./clean.sh demo
```

This will delete the projects created.

# Extra: Manual testing the App

## Build the app

Got to app dir ```cd acme-app```

Build the app:

```mvn clean package -Dappversion=1.0```

## Deploy the app

Go back to project root

Create new app:

```oc new-app jboss-eap72-openshift:1.1 --binary --name=acmeapp```

Start the binary build:

```oc start-build acmeapp --from-file acme-app/target/ROOT.war```

Expose the service:

```oc expose svc acmeapp```

Wait for the pod with the app to be available (```oc get pods```).

Now from the route created by OpenShift you can reach the application deployed (the application is published on the root path)
