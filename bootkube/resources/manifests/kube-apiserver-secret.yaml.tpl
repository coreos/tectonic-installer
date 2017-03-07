apiVersion: v1
kind: Secret
metadata:
  name: kube-apiserver-secret
  namespace: kube-system
type: Opaque
data:
  apiserver.key: ${apiserver_key}
  apiserver.crt: ${apiserver_cert}
  service-account.pub: ${serviceaccount_pub}
  ca.crt: ${ca_cert}