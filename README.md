# kubeflow_ubuntu

Install Kubeflow on Ubuntu 22.04

# Set the env

[docker](https://docs.docker.com/desktop/install/ubuntu/)

[minikube](https://minikube.sigs.k8s.io/docs/start/)

```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

minikube start --driver=docker --disk-size=100g --kubernetes-version=1.21.0 --memory=4g --cpus=4
(optional)minikube config set profile test
```

[kubectl](https://kubernetes.io/ko/docs/tasks/tools/install-kubectl-linux/)

```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

[kustomize](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)

```
wget https://github.com/kubernetes-sigs/kustomize/releases/download/v3.2.0/kustomize_3.2.0_linux_amd64
chmod +x kustomize_3.2.0_linux_amd64
sudo mv kustomize_3.2.0_linux_amd64 /usr/local/bin/kustomize
```

```
manifests/common/user-namespace/base/params.env
manifests/common/dex/base/config-map.yaml
kubectl -n auth rollout restart deployment dex 
```

[kubeflow/manifests](https://github.com/kubeflow/manifests)

```
git clone https://github.com/kubeflow/manifests.git
cd manifests
git checkout v1.4-branch(kubeflow 버전 변경)
while ! kustomize build example | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done
```

# Kubeflow local host

```
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80

# Login
user@example.com
12341234
```

# Kubectl 명령어

```
# 쿠버네티스 파드 확인
kubectl get pods -A

# 파드 상태 실시간 확인
watch kubectl get pods -A 

# 파드 상태 변경될때마다 상태 확인
kubectl get po -A -w

# namespace별 pod 확인
kubectl get po -n {namespace}

# pod 삭제
kubectl delete pod <pod_name> -n <namespace>

# 강제종료
kubectl delete pod <pod_name> -n <namespace> --grace-period 0 --force

# namespace 삭제
kubectl delete namespace {삭제할 namespace}
```

# 로그인 추가
```
# manifests/common/dex/base/comnfig-map.yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: dex
data:
  config.yaml: |
    issuer: http://dex.auth.svc.cluster.local:5556/dex
    storage:
      type: kubernetes
      config:
        inCluster: true
    web:
      http: 0.0.0.0:5556
    logger:
      level: "debug"
      format: text
    oauth2:
      skipApprovalScreen: true
    enablePasswordDB: true
    staticPasswords:
    - email: user@example.com
      hash: $2y$12$4K/VkmDd1q1Orb3xAt82zu8gk7Ad6ReFR4LCP9UeYE90NLiN9Df72
      # https://github.com/dexidp/dex/pull/1601/commits
      # FIXME: Use hashFromEnv instead
      username: user
      userID: "15841185641784"
    - email: dev7halo@gmail.com
      hash: $2a$12$pnfKk2PSRTyM8Wm3jrEkKuM339fgBqWcFPrHbcsEHGhzDmH/pm/Uy
      username: krkim
      userID: krkim
    staticClients:
    # https://github.com/dexidp/dex/pull/1664
    - idEnv: OIDC_CLIENT_ID
      redirectURIs: ["/login/oidc"]
      name: 'Dex Login Application'
      secretEnv: OIDC_CLIENT_SECRET
```

# namespace 설정

```
# manifests/common/user-namespace/base/params.env

user=dev7halo@gmail.com
profile-name=krkim
```

# Info

|Tool|Version|
|----------|------|
|Ubuntu|22.04|
|minikube|1.22.0|
|kubernetes|1.21.2|
|kustomize|3.2.0|

# Reference
https://github.com/kubeflow/manifests
