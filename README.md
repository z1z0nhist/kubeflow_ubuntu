# kubeflow_ubuntu

Install Kubeflow on Ubuntu 22.04

# Set the env

[docker](https://docs.docker.com/desktop/install/ubuntu/)

[minikube](https://github.com/kubernetes/minikube/releases/tag/v1.22.0)

[kubectl](https://kubernetes.io/ko/docs/tasks/tools/install-kubectl-linux/)

```
curl -LO https://dl.k8s.io/release/v1.21.2/bin/linux/amd64/kubectl
```

[kustomize](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)

```
wget https://github.com/kubernetes-sigs/kustomize/releases/download/v3.2.0/kustomize_3.2.0_linux_amd64
chmod +x kustomize_3.2.0_linux_amd64
sudo mv kustomize_3.2.0_linux_amd64 /usr/local/bin/kustomize
```

[kubeflow/manifests](https://github.com/kubeflow/manifests)

```
git clone https://github.com/kubeflow/manifests.git
cd manifests

# until Success
while ! kustomize build example | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done
```
# Kubeflow local host

```
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80
```

# Info

|Tool|Version|
|----------|------|
|minikube|1.22.0|
|kubernetes|1.21.2|
|kustomize|3.2.0|
