# Openshift Pipelines

This demo showcases Openshift pipelines with Tekton. Tasks and a pipeline are created and the pipeline triggered via the Tekton cli. The pipeline fetches code from a Github repo and deploys it to the cluster. Finally the app can be accessed via a route.

## Prererequesites

- Openshift
- Red Hat Pipeline Operator
- Tekton CLI
- PVC: `oc apply -f pipelines/source.yaml`

## Tasks

```bash
oc apply -f tasks/hello.yaml

oc create -f tasks/apply_manifest_task.yaml

oc create -f tasks/update_deployment_task.yaml
```

Run "Hello World" task:

```bash
tkn task start --showlog hello
```

List tasks:

```bash
tkn task ls
```

## Pipelines

A Pipeline defines an ordered series of Tasks that you want to execute along with the corresponding inputs and outputs for each Task.

Pipeline Steps:

1. `fetch-repository` clones the source code of the application from a git repository by referring (`git-url` and `git-revision` param)
2. `build-image` builds the container image of the application using the `buildah` clustertask that uses Buildah to build the image
3. The application image is pushed to an image registry by referring (image param)
4. The new application image is deployed on OpenShift using the apply-manifests and update-deployment tasks

There are no references to the git repository or the image registry it will be pushed to in the pipeline. That's because pipeline in Tekton is designed to be generic and re-usable across environments and stages through the application's lifecycle. Pipelines abstract away the specifics of the git source repository and image to be produced as PipelineResources or Params.

The execution order of task is determined by dependencies that are defined between the tasks via inputs and outputs as well as explicit orders that are defined via `runAfter`.

`workspaces` field allows you to specify one or more volumes that each Task in the Pipeline requires during execution. You specify one or more Workspaces in the `workspaces` field.

## Trigger a Pipeline via CLI

By creating a `PipelineRun` with the name of our applied Pipeline, we can define various arguments to our command like params that will be used in the Pipeline. For example, we an apply a request for storage with a `persistentVolumeClaim`, as well as define a name for our deployment, `git-url` repository to be cloned, and `IMAGE` to be created.

As soon as you start the `build-and-deploy` pipeline, a `PipelineRun` will be instantiated and pods will be created to execute the tasks that are defined in the pipeline. To display a list of Pipelines, use the following command:

```bash
tkn pipeline ls
```

Trigger pipeline for backend and frontend:

```bash
sh run/backend.sh

# OR
tkn pipeline start build-and-deploy \
  -w name=shared-workspace,claimName=source-pvc \
  -p deployment-name=pipelines-vote-api \
  -p git-url=https://github.com/openshift/pipelines-vote-api.git \
  -p IMAGE=image-registry.openshift-image-registry.svc:5000/pipelines-tutorial/vote-api \
  -p git-revision=master \
  --showlog

sh run/frontend.sh

# OR
tkn pipeline start build-and-deploy \
  -w name=shared-workspace,claimName=source-pvc \
  -p deployment-name=pipelines-vote-ui \
  -p git-url=https://github.com/openshift/pipelines-vote-ui.git \
  -p IMAGE=image-registry.openshift-image-registry.svc:5000/pipelines-tutorial/vote-ui \
  -p git-revision=master \
  --showlog
```

Again, notice the reusability of pipelines, and how one generic Pipeline can be triggered with various params. We've started the `build-and-deploy` pipeline, with relevant pipeline resources to deploy backend/frontend application using a single pipeline. Let's list our `PipelineRuns`:

```bash
tkn pipelinerun ls
```

Get the route of the deployed app:

```bash
oc get route pipelines-vote-ui --template='http://{{.spec.host}}'
```
