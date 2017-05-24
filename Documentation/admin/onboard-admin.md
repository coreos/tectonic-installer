# On-boarding an administrator to a Tectonic cluster

An administrator can be assigned to a cluster or a specific namespace within a cluster. Use the *Role Binding* option in the Tectonic Console to do so.

##  Prerequisites and guidelines

Before proceeding, ensure that the prerequisites given in the respective Identity Provider (IdP) section are met. Depending on the IdP used in the deployment, see either of the following:

* [LDAP user management][ldap-user-management]
* [SAML user management][saml-user-management]

## Setting up a Cluster administrator

Access rights are granted to an administrator user by using an appropriate Cluster Role, then associating that with a Cluster Role Binding.

### Creating a Cluster Role

For roles, use the default role, *cluster-admin*, or create a new cluster admin by using either of the following in the *Roles* option under *Administration*:

* YAML editor
* Selecting a default role and changing the rules using the *Add Rules* option

The following describes how to add a cluster role by using the YAML editor.

1. Log in to the Tectonic UI.
2. Select *Roles* under *Administration*.
3. Select *all* from the drop-down given at the top of the page.
4. Click *Create Role*.
   A YAML editor screen is displayed.
5. Make necessary edits.

    The following shows an example of granting a user admin access to the cluster. The `sample-cluster-admin` role can run commands get, watch, and list the cluster. `*` stands for full access.

      ``` yaml
          kind: ClusterRole
          apiVersion: rbac.authorization.k8s.io/v1beta1
          metadata:
           name: sample-cluster-admin
           labels:
             kubernetes.io/bootstrapping: rbac-defaults
           annotations:
             rbac.authorization.kubernetes.io/autoupdate: 'true'
           rules:
           - verbs:
               - '*'
             apiGroups:
               - '*'
             resources:
               - '*'
           - verbs:
               - '*'
             nonResourceURLs:
               - '*'
               ```
6. Click *Create*.

### Creating a Cluster Role Binding

A Cluster Role Binding grants permissions to users in all namespaces across the entire cluster. Bind the `sample-cluster-admin` role appropriately to the privileges associated with a cluster role binding, `sample-admin`. `namespace` has been omitted from the configuration because Cluster Roles are not namespaced.

1. Navigate to *Role Bindings* under *Administration*.
2. Select a desired namespace from the drop-down given at the top of the page.
3. Click *Create Binding*.
   A YAML editor screen is displayed.

       apiVersion: rbac.authorization.k8s.io/v1beta1
       kind: RoleBinding
       metadata:
         name: sample-role-binding-admin
       subjects:
         - kind: User
           name: sample-admin
           apiGroup: rbac.authorization.k8s.io
       roleRef:
         kind: ClusterRole
         name: sample-cluster-admin
         apiGroup: rbac.authorization.k8s.io


4. Make necessary edits.
5. Click *Create*.

## Setting up a Namespace administrator

For a namespace, either use one of the default cluster roles or namespace roles, or create a new role exclusively for a selected namespace, and then bind appropriately to a namespace role binding.
> A namespace role can't be bound to a cluster role binding. However a cluster role can be bound to a namespace role binding.

### Creating a Role

For roles, use one of the default cluster roles, or create a new role by using either of the following in the *Roles* option under *Administration*:

* YAML editor
* Selecting a default role and changing the rules using the *Add Rules* option

An example YAML file of namespace admin:

    kind: Role
    apiVersion: rbac.authorization.k8s.io/v1beta1
    metadata:
      name: sample-namespace-admin
      namespace: kube-public      
    rules:
      - verbs:
          - ''
        apiGroups:
          - ''
        resources:
          - ''

### Creating a Roles Binding

Bind the `sample-namespace-admin` role appropriately to the privileges associated with a namespace role binding, `rolebinding-admin`.

1. Navigate to *Role Bindings* under *Administration*.
2. Select a desired namespace from the drop-down given at the top of the page.
3. Click *Create Binding*.

   A YAML editor screen is displayed.
4. Make necessary edits.

    An example YAML file for a role binding for `kube-public` cluster:

       apiVersion: rbac.authorization.k8s.io/v1beta1
       kind: RoleBinding
       metadata:
         name: rolebinding-admin
         namespace: kube-public
       subjects:
         - kind: User
           name: my-sample-group
           apiGroup: rbac.authorization.k8s.io
       roleRef:
         kind: Role
         name: sample-namespace-admin
         apiGroup: rbac.authorization.k8s.io

5. Click *Create*.


[LDAP user management]:ldap-user-management.md
[Default Roles in Tectonic]:identity-management.md
[SAML user management]:saml-user-management.md
