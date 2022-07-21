# cert-manager
kustomize build common/cert-manager/cert-manager/base | kubectl apply -f -
kustomize build common/cert-manager/kubeflow-issuer/base | kubectl apply -f -

# istio
kustomize build common/istio-1-9/istio-crds/base | kubectl apply -f -
kustomize build common/istio-1-9/istio-namespace/base | kubectl apply -f -
kustomize build common/istio-1-9/istio-install/base | kubectl apply -f -

# dex
kustomize build common/dex/overlays/istio | kubectl apply -f -

# oidc
kustomize build common/oidc-authservice/base | kubectl apply -f -

# kubeflow-namespace
kustomize build common/kubeflow-namespace/base | kubectl apply -f -

# kubeflow-roles
kustomize build common/kubeflow-roles/base | kubectl apply -f -

# istio-resources
kustomize build common/istio-1-9/kubeflow-istio-resources/base | kubectl apply -f -

# kubeflow-pipeline (For docker env)
kustomize build apps/pipeline/upstream/env/platform-agnostic-multi-user | kubectl apply -f -

# katib
kustomize build apps/katib/upstream/installs/katib-with-kubeflow | kubectl apply -f -

# central dashboard
kustomize build apps/centraldashboard/upstream/overlays/istio | kubectl apply -f -

# admission webhook
kustomize build apps/admission-webhook/upstream/overlays/cert-manager | kubectl apply -f -

# Notebooks
kustomize build apps/jupyter/notebook-controller/upstream/overlays/kubeflow | kubectl apply -f -
kustomize build apps/jupyter/jupyter-web-app/upstream/overlays/istio | kubectl apply -f -

# profiles
kustomize build apps/profiles/upstream/overlays/kubeflow | kubectl apply -f -

# volumes web app
kustomize build apps/volumes-web-app/upstream/overlays/istio | kubectl apply -f -

# tensor board
kustomize build apps/tensorboard/tensorboards-web-app/upstream/overlays/istio | kubectl apply -f -
kustomize build apps/tensorboard/tensorboard-controller/upstream/overlays/kubeflow | kubectl apply -f -

# training operator
kustomize build apps/training-operator/upstream/overlays/kubeflow | kubectl apply -f -

# user namespace
kustomize build common/user-namespace/base | kubectl apply -f -
