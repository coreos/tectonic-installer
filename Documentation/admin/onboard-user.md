# On-boarding a user to a Tectonic cluster

An individual user can be assigned to a cluster or a specific namespace within a cluster. Use the *Roles* option to create a role and *Role Binding* option to associate necessary permissions to access the objects within a Tectonic cluster or namespace.

##  Prerequisites and guidelines

Before proceeding, ensure that the prerequisites given in the respective Identity Provider (IdP) section are met. Depending on the IdP used in the deployment, see the following:

* [LDAP user management][ldap-user-management]
* [SAML user management][saml-user-management]

## Setting up a cluster user

Access rights are granted to a user by using roles. In order to grant permission to resources within a namespace, you can either choose a default role from the Roles page and navigate to create a role binding, or directly navigate to the *Role Bindings* page and choose an appropriate role.

### Creating a Cluster Role

For roles, use the default role, *user*, or create a new Cluster Role by using either of the following in the *Roles* option under *Administration*:

* YAML editor
* Selecting a default role and editing the associated rules by using the *Add Rules* option

The following describes how to add a cluster role by using the YAML editor.

1. Log in to the Tectonic UI.
2. Select *Roles* under *Administration*.
3. Select *all* from the drop-down given at the top of the page.
4. Click *Create Role*.
   A YAML editor screen is displayed.
5. Make necessary edits.

  The following shows an example of granting a user basic access to the cluster. The `user-readonly` role can run commands get, watch, list, proxy, and redirect namespaces and pods in the given cluster.

    ```yaml
          kind: Role
          apiVersion: rbac.authorization.k8s.io/v1beta1
          metadata:
            name: user-readonly
            labels:
              kubernetes.io/bootstrapping: rbac-defaults
            annotations:
              rbac.authorization.kubernetes.io/autoupdate: 'true'
            rules:
            - verbs:
                - '*'
              apiGroups:
                - ''
              resources:
                - '*'
            - verbs:
                - get
                - watch
                - list
                - proxy
                - redirect
             nonResourceURLs:
                - ''
                ```

### Creating a Roles Binding

A Cluster Role Binding grants permissions to users in all namespaces across the entire cluster. Bind the `user-readonly` role appropriately to the privileges associated with a Cluster Role Binding, `sample-user`.

Note that "namespace" is omitted because Cluster Roles are not namespaced.

1. Navigate to *Role Bindings* under *Administration*.
2. Select *all* from the drop-down given at the top of the page.
3. Click *Create Binding*.
   A YAML editor screen is displayed.
4. Make necessary edits.

    ```yaml
            kind: RoleBinding
            apiVersion: rbac.authorization.k8s.io/v1alpha1
            metadata:
              name: user-readonly
            subjects:
            - kind: User
              name: sample-user
            roleRef:
              kind: ClusterRole
              name: user-readonly
              apiGroup: rbac.authorization.k8s.io
              ```

5. Click *Create*.

A Role Binding can also be associated to a Cluster Role to grant permissions to resources within a namespace as defined in the Role Binding. This allows administrators to define a set of common roles for the entire cluster, then reuse them within multiple namespaces.

For instance, even though the following Role Binding refers to a Cluster Role, user will only be having read access to the `kube-system` namespace:

```yaml
      kind: ClusterRoleBinding
      apiVersion: rbac.authorization.k8s.io/v1alpha1
      metadata:
        name: support-reader
        namespace: kube-system
      subjects:
        - kind: user
          name: sample-user
      roleRef:
        kind: ClusterRole
        name: support-readonly
        apiGroup: rbac.authorization.k8s.io
```

### Setting up a Namespace user

For a namespace, either use one of the default cluster roles or namespace roles, or create a new role exclusively for a selected namespace, and then bind appropriately to a namespace role binding.

> A namespace role can't be bound to a cluster role binding. However a cluster role can be bound to a namespace role binding as seen in the previous section.

#### Creating a Role

1. Log in to the Tectonic UI.
2. Select *Roles* under *Administration*.
3. Select *all* from the drop-down given at the top of the page.
4. Click *Create Role*.
   A YAML editor screen is displayed.
5. Make necessary edits.

  The following shows an example of granting a user basic access to the `kube-public` namespace. The `namespace-user` role can run commands get, watch, and list pods within `kube-public`.

```yaml
        kind: Role
        apiVersion: rbac.authorization.k8s.io/v1beta1
        metadata:
          name: namespace-user
          namespace: kube-public      
        rules:
          - verbs:
              - get
              - watch
              - list
            apiGroups:
              - ''
            resources:
              - pods
              ```
  6. Click *Create*.

#### Creating a Roles Binding

Bind the `namespace-user` role appropriately to the privileges associated with a namespace role binding, `namespace-user-binding`.

1. Log in to the Tectonic UI.
2. Navigate to *Role Bindings* under *Administration*.
3. Select a desired namespace from the drop-down given at the top of the page.
4. Click *Create Binding*.

   A YAML editor screen is displayed.
5. Make necessary edits.

  An example YAML file for a namespace role binding:

```yaml
       apiVersion: rbac.authorization.k8s.io/v1beta1
       kind: RoleBinding
       metadata:
         name: namespace-user-binding
         namespace: kube-public
       subjects:
         - kind: User
           name: my-sample-group
           apiGroup: rbac.authorization.k8s.io
       roleRef:
         kind: Role
         name: namespace-user
         apiGroup: rbac.authorization.k8s.io
```
6. Click *Create*.



[LDAP user management]:ldap-user-management.md
[Default Roles in Tectonic]:identity-management.md
