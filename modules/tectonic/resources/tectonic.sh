#!/bin/bash
set -e

if [ "$#" -ne "3" ]; then
    echo "Usage: $0 kubeconfig assets_path experimental"
    exit 1
fi

KUBECONFIG="$1"
ASSETS_PATH="$2"
EXPERIMENTAL="$3"

# Setup API Authentication
KUBECTL="/kubectl --kubeconfig=$KUBECONFIG"

# Setup helper functions

function kubectl() {
  local i=0

  echo "Executing kubectl $@"
  while true; do
    (( i++ )) && (( i == 100 )) && echo "kubectl failed, giving up" && exit 1

    set +e
    out=$($KUBECTL "$@" 2>&1)
    status=$?
    set -e

    if [[ "$out" == *"AlreadyExists"* ]]; then
      echo "$out, skipping"
      return
    fi

    echo "$out"
    if [ "$status" -eq 0 ]; then
      return
    fi

    echo "kubectl failed, retrying in 5 seconds"
    sleep 5
  done
}

function wait_for_tpr() {
  local i=0

  echo "Waiting for TPR $2"
  until $KUBECTL -n "$1" get thirdpartyresources "$2"; do
    (( i++ )) && (( i == 100 )) && echo "TPR $2 not available, giving up" && exit 1

    echo "TPR $2 not available yet, retrying in 5 seconds"
    sleep 5
  done
}

function wait_for_pods() {
  set +e
  local i=0
  echo "Waiting for pods in namespace $1"
  while $KUBECTL -n "$1" get po -o custom-columns=STATUS:.status.phase,NAME:.metadata.name | tail -n +2 | grep -v '^Running'; do
    (( i++ )) && (( i == 100 )) && echo "components not available, giving up" && exit 1
    echo "Pods not available yet, waiting for 5 seconds"
    sleep 5
  done
  set -e
}

# chdir into the assets path directory
cd "$ASSETS_PATH/tectonic"

# Wait for Kubernetes to be in a proper state
i=0
echo "Waiting for Kubernetes API..."
until $KUBECTL cluster-info; do
  (( i++ )) && (( i == 100 )) && echo "cluster not available, giving up" && exit 1
  echo "Cluster not available yet, waiting for 5 seconds"
  sleep 5
done

# wait for Kubernetes pods
wait_for_pods kube-system

# Creating resources
echo "Creating Tectonic Namespace"
kubectl create -f namespace.yaml

echo "Creating Initial Roles"
kubectl delete -f rbac/role-admin.yaml

kubectl create -f rbac/role-admin.yaml
kubectl create -f rbac/role-user.yaml
kubectl create -f rbac/binding-admin.yaml
kubectl create -f rbac/binding-discovery.yaml

echo "Creating Tectonic ConfigMaps"
kubectl create -f config.yaml

echo "Creating Tectonic Secrets"
kubectl create -f secrets/pull.json
kubectl create -f secrets/license.json
kubectl create -f secrets/ingress-tls.yaml
kubectl create -f secrets/ca-cert.yaml
kubectl create -f secrets/identity-grpc-client.yaml
kubectl create -f secrets/identity-grpc-server.yaml

echo "Creating Tectonic Identity"
kubectl create -f identity/configmap.yaml
kubectl create -f identity/services.yaml
kubectl create -f identity/deployment.yaml

echo "Creating Tectonic Console"
kubectl create -f console/service.yaml
kubectl create -f console/deployment.yaml

echo "Creating Tectonic Monitoring"
kubectl create -f monitoring/prometheus-operator-service-account.yaml
kubectl create -f monitoring/prometheus-operator-cluster-role.yaml
kubectl create -f monitoring/prometheus-operator-cluster-role-binding.yaml
kubectl create -f monitoring/prometheus-k8s-service-account.yaml
kubectl create -f monitoring/prometheus-k8s-cluster-role.yaml
kubectl create -f monitoring/prometheus-k8s-cluster-role-binding.yaml
kubectl create -f monitoring/prometheus-k8s-config.yaml
kubectl create -f monitoring/prometheus-k8s-rules.yaml
kubectl create -f monitoring/prometheus-svc.yaml
kubectl create -f monitoring/node-exporter-svc.yaml
kubectl create -f monitoring/node-exporter-ds.yaml
kubectl create -f monitoring/prometheus-operator.yaml
wait_for_tpr tectonic-system prometheus.monitoring.coreos.com
kubectl create -f monitoring/prometheus-k8s.yaml

echo "Creating Ingress"
kubectl create -f ingress/default-backend/configmap.yaml
kubectl create -f ingress/default-backend/service.yaml
kubectl create -f ingress/default-backend/deployment.yaml
kubectl create -f ingress/ingress.yaml

if [ "${ingress_kind}" = "HostPort" ]; then
  kubectl create -f ingress/hostport/service.yaml
  kubectl create -f ingress/hostport/daemonset.yaml
elif [ "${ingress_kind}" = "NodePort" ]; then
  kubectl create -f ingress/nodeport/service.yaml
  kubectl create -f ingress/nodeport/deployment.yaml
else
  echo "Unrecognized Ingress Kind: ${ingress_kind}"
fi

echo "Creating Heapster / Stats Emitter"
kubectl create -f heapster/service.yaml
kubectl create -f heapster/deployment.yaml
kubectl create -f stats-emitter.yaml

if [ "$EXPERIMENTAL" = "true" ]; then
echo "Creating Tectonic Updater"
  kubectl create -f updater/tectonic-channel-operator-kind.yaml
  kubectl create -f updater/app-version-kind.yaml
  kubectl create -f updater/migration-status-kind.yaml
  kubectl create -f updater/node-agent.yaml
  kubectl create -f updater/kube-version-operator.yaml
  kubectl create -f updater/tectonic-channel-operator.yaml
  kubectl create -f updater/tectonic-prometheus-operator.yaml
  wait_for_tpr tectonic-system channel-operator-config.coreos.com
  kubectl create -f updater/tectonic-channel-operator-config.json
  wait_for_tpr tectonic-system app-version.coreos.com
  kubectl create -f updater/app-version-tectonic-cluster.json
  kubectl create -f updater/app-version-kubernetes.json
  kubectl create -f updater/app-version-tectonic-monitoring.yaml
fi

# wait for Tectonic pods
wait_for_pods tectonic-system

echo "Tectonic installation is done"
exit 0
