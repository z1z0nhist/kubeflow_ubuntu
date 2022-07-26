# kubeflow_ubuntu

Install Kubeflow on Ubuntu 22.04

# Set env

[docker](https://docs.docker.com/desktop/install/ubuntu/)

#### (optional)gpu docker
```json
# /etc/docker/daemon.json
{
  "default-runtime": "nvidia",
  "runtimes": {
      "nvidia": {
          "path": "nvidia-container-runtime",
          "runtimeArgs": []
   }
  }
}
```

[minikube](https://minikube.sigs.k8s.io/docs/start/)

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

minikube start --driver=docker --disk-size=100g --kubernetes-version=1.21.0 --memory=4g --cpus=4
(optional)minikube config set profile test
```

#### (optional)minikube cuda

kubeflow가 kubernetes 위에서 작동하므로 minikube에 cuda 환경이 배포되어야 사용 가능

```bash
sudo apt install conntrack
sudo apt install socat
minikube start --driver=none --kubernetes-version=1.21.0
kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/master/nvidia-device-plugin.yml
kubectl get pod -A | grep nvidia
kubectl get nodes "-o=custom-columns=NAME:.metadata.name,GPU:.status.allocatable.nvidia\.com/gpu"
```

```yaml
# vim gpu.yaml
# in gpu.yaml
# caution cuda version
# 이미지가 본인의 환경에 맞는 cuda 환경을 설정해 주어야 합니다.
apiVersion: v1
kind: Pod
metadata:
  name: gpu
spec:
  restartPolicy: OnFailure
  containers:
    - name: cuda-container
      image: nvidia/cuda:11.4.2-runtime-ubuntu18.04
      command: ["nvidia-smi"]
      resources:
        limits:
          nvidia.com/gpu: 1 # requesting 1 GPU
#
kubectl create -f gpu.yaml
kubectl logs gpu
```


[kubectl](https://kubernetes.io/ko/docs/tasks/tools/install-kubectl-linux/)

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

[kustomize](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)

```bash
wget https://github.com/kubernetes-sigs/kustomize/releases/download/v3.2.0/kustomize_3.2.0_linux_amd64
chmod +x kustomize_3.2.0_linux_amd64
sudo mv kustomize_3.2.0_linux_amd64 /usr/local/bin/kustomize
```

```bash
manifests/common/user-namespace/base/params.env
manifests/common/dex/base/config-map.yaml
kubectl -n auth rollout restart deployment dex 
```

[kubeflow/manifests](https://github.com/kubeflow/manifests)

```bash
git clone https://github.com/kubeflow/manifests.git
cd manifests
git checkout v1.4-branch(kubeflow 버전 변경)

# 아래 명령어는 작동 순서에 예민하므로 성공할 때까지 기다린다
while ! kustomize build example | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done
# 이유를 모르겠으나 이렇게 설치하면 파드가 잘 생성이 안됩니다.
# 아래 참조처럼 한개씩 설치합시다 
# (참조)[https://mlops-for-all.github.io/docs/setup-components/install-components-kf/#cert-manager]
```

#### (optional)Kubeflow local host

```bash
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80

# Login
user@example.com
12341234
```

#### (optional)add user

```yaml
# manifests/common/dex/base/config-map.yaml
# hash는 접속시 비밀번호인데 Bcrypt를 통해 암호화 시킨 값을 넣어야 한다.
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

#### (optional)namespace 설정

```bash
# manifests/common/user-namespace/base/params.env

user=dev7halo@gmail.com
profile-name=krkim
```

# kfp 사용하기

```python
import kfp
import requests

USERNAME = "dev7halo@gmail.com"
PASSWORD = "    "
NAMESPACE = "krkim"
HOST = "http://10.23.13.113:31265" # istio-ingressgateway's external-ip created by the load balancer.

session = requests.Session()
response = session.get(HOST)

headers = {
    "Content-Type": "application/x-www-form-urlencoded",
}

data = {"login": USERNAME, "password": PASSWORD}
session.post(response.url, headers=headers, data=data)
session_cookie = session.cookies.get_dict()["authservice_session"]

client = kfp.Client(
    host=f"{HOST}/pipeline",
    namespace=f"{NAMESPACE}",
    cookies=f"authservice_session={session_cookie}",
)
print(client.list_pipelines())
```

# 명령어

```
# 쿠버네티스 파드 확인
kubectl get pods -A
watch kubectl get pods -A 
kubectl get po -A -w

# namespace별 pod 확인
kubectl get po -n {namespace}

# pod 재생성
kubectl get pod <pod_name> -n <namespace> -o yaml | kubectl replace --force -f-

# pod 삭제
kubectl delete pod <pod_name> -n <namespace>

# 강제종료
kubectl delete pod <pod_name> -n <namespace> --grace-period 0 --force

# namespace 삭제
kubectl delete namespace {삭제할 namespace}

# minikube service list
minikube service list -n istio-system
```

# Info

|Tool|Version|
|----------|------|
|Ubuntu|22.04|
|minikube|v1.26.0|
|kubernetes|v1.21.0|
|kustomize|v3.2.0|
|cuda|11.4|


# 겪었던 문제

- 회사 이메일에 . 이 들어가는데 yaml 파일에서 .이 들어가면 문제가 생겨서 삽질
- on-premise로 구축하려니 쿠버네티스 생태계에 이해를 못해서 gpu 자원 활용에 문제
- on-premise로 구축하고 localhost에서 jupyter notebook에서 kubeflow pipe라인을 작성하니 토큰 문제(client에 localhost:port를 넣어서 해결)
- Could not find CSRF cookie XSRF-TOKEN in the request(참조3)\
- 재부팅시 gpu pod가 생성이 안되는 문제 (참조)[https://my-grope-log.tistory.com/20]

# Reference
https://github.com/kubeflow/manifests

https://velog.io/@moey920/Minikube-Nvidia-GPU-%EC%82%AC%EC%9A%A9%ED%95%98%EA%B8%B0

https://otzslayer.github.io/kubeflow/2022/06/11/could-not-find-csrf-cookie-xsrf-token-in-the-request.html

[모두의 MLOps](https://mlops-for-all.github.io/docs/setup-components/install-components-kf/)
