tkn pipeline start build-and-deploy \
  -w name=shared-workspace,claimName=source-pvc \
  -p deployment-name=pipelines-vote-ui \
  -p git-url=https://github.com/openshift/pipelines-vote-ui.git \
  -p IMAGE=image-registry.openshift-image-registry.svc:5000/pipelines-tutorial/vote-ui \
  -p git-revision=master \
  --showlog