# On-boarding a service account to Tectonic cluster

## About service accounts

Service accounts are API credentials stored in the Kubernetes API and mounted onto accessible pods, giving the pod an identity which can be access controlled. Pods use service accounts to authenticate against Kubernetes API from within the cluster. If an app uses kubectl or the official Kubernetes Go client within a pod to talk to the API, these credentials are loaded automatically.
Kubernetes automatically creates a `default` service account in every namespace. If pods don't explicitly request a service account, they're assigned to this `default` one. Creating an additional service account is permitted.

Since RBAC denies all requests unless explicitly allowed, service accounts, and the pods that use them, must be granted access through RBAC rules.

## Creating an additional service accounts

To create an additional service account, for example, an ingress role, either create a yaml file as follows or use the Tectonic console to create one. Given is an example service account for ingress.

### Through command line

1. Define the role, `ingress.yaml`, which gives administrative privileges to the service account within the default namespace:


      apiVersion: rbac.authorization.k8s.io/v1alpha1
      kind: RoleBinding
      metadata:
        name: public-ingress
      roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: ClusterRole
        name: admin
      subjects:
      - kind: ServiceAccount
        name: default
        namespace: public

2. Run the following:

  `kubectl create serviceaccount `ingress.yaml`
   serviceaccount "ingress" created

If multiple pods running in the same namespace require different levels of access, create a unique service account for each. The newly created service account can be mounted onto the pod by specifying the service account name in the pod spec.

    apiVersion: extensions/v1beta1
    kind: Deployment
    metadata:
      name: nginx-deployment
    spec:
      replicas: 3
      template:
        metadata:
          labels:
            k8s-app: nginx
        spec:
          containers:
          - name: nginx
            image: nginx:1.7.9
          serviceAccountName: ingress # Specify the custom service account

## Using the Tectonic console

### Setting up a service account for a cluster

#### Creating a cluster role

1. Log in to the Tectonic UI.
2. Navigate to *Roles* under *Administration*.
3. Select a desired namespace from the drop-down.
4. Click *Create Roles*.
   A YAML editor is displayed.   
5. Make necessary edits.

   A YAML file for an example service account is given below. Note that  cluster roles are not namespaced.

        kind: Role
        apiVersion: rbac.authorization.k8s.io/v1beta1
        metadata:
          name: default-service-account    
        rules:
          - verbs:
              - get
              - watch
              - list
            apiGroups:
              - extensions
            resources:
              - ingress

### Creating a cluster role binding

1. Log in to the Tectonic UI.
2. Navigate to *Role Bindings* under *Administration*.
3. Select a desired namespace from the drop-down.
4. Click *Create Binding*.
   A YAML editor is displayed.   
5. Make necessary edits.

   Given below is a YAML file for a service account with permission to run get, watch, and list commands on the cluster.

      kind: Role
      apiVersion: rbac.authorization.k8s.io/v1beta1
      metadata:
        name: default-service-account
      rules:
        - verbs:
            - get
            - watch
            - list
          apiGroups:
            - extensions
          resources:
            - ingress

### Setting up a service account for a namespace

#### Creating a namespace role

1. Log in to the Tectonic UI.
2. Navigate to *Roles* under *Administration*.
3. Select a desired namespace from the drop-down.
4. Click *Create Roles*.
   A YAML editor is displayed.   
5. Make necessary edits.

   A YAML file for an example service account is given below:

        kind: Role
        apiVersion: rbac.authorization.k8s.io/v1beta1
        metadata:
          name: default-service-account
          namespace: default      
        rules:
          - verbs:
              - get
              - watch
              - list
            apiGroups:
              - extensions
            resources:
              - ingress

#### Creating a role binding

1. Log in to the Tectonic UI.
2. Navigate to *Role Bindings* under *Administration*.
3. Select a desired namespace from the drop-down.
4. Click *Create Binding*.
   A YAML editor is displayed.   
5. Make necessary edits.

   A YAML file for an example service account is given below:

        kind: Role
        apiVersion: rbac.authorization.k8s.io/v1beta1
        metadata:
          name: default-service-account
          namespace: default       
        rules:
          - verbs:
              - get
              - watch
              - list
            apiGroups:
              - extensions
            resources:
              - ingress

The newly created pod can be mounted.

[LDAP user management]:ldap-user-management.md
[Default Roles in Tectonic]:identity-management.md
