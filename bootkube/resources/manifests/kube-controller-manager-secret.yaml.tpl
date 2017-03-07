apiVersion: v1
kind: Secret
metadata:
  name: kube-controller-manager-secret
  namespace: kube-system
type: Opaque
data:
  service-account.key: ${serviceaccount_key}
  ca.crt: ${ca_cert}