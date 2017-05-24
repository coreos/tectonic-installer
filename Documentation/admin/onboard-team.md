# On-boarding a team to a Tectonic cluster

A group can be assigned to a cluster or a specific namespace within a cluster. Use the *Role Binding* option in the Tectonic cluster to do so.

##  Prerequisites and guidelines

Before proceeding, ensure that the prerequisites given in the respective Identity Provider (IdP) section are met. Depending on the IdP used in the deployment, see the following:

* [LDAP user management][ldap-user-management]
* [SAML user management][saml-user-management]

## Setting up a namespace administrator

Tectonic configures three default namespaces:  default, kube-system, and tectonic-system. The namespace administrator role will have full permission to the objects in a namespace. All Kubernetes clusters have two categories of users: service accounts managed by Kubernetes, and normal users. Service accounts are managed by the API server and can be created by using API calls. Normal user accounts are externally created and managed, such as by using an LDAP server or Google account. Kubernetes does not have corresponding objects representing normal user accounts.

## Granting access rights

Access rights are granted by using roles and roles binding. Create a cluster or namespace role and bind to a role binding created for a group.

### Namespace

1. Log in to the Tectonic UI.
2. Navigate to *Roles* under *Administration*.
3. Select a desired namespace from the drop-down.
4. Create a role by editing the YAML editor.   
5. Navigate to *Roles* under *Administration*.
6. Select a desired namespace from the drop-down.
7. Click *Create Binding*.
   A YAML editor is displayed.
8. Make necessary edits to create the role binding.
   An example YAML file that grant access to kube-system namespace:

        apiVersion: rbac.authorization.k8s.io/v1beta1
        kind: RoleBinding
        metadata:
          name: example-role-binding
          namespace: kube-system
        subjects:
          - kind: Group
            name: tstgroup
            apiGroup: rbac.authorization.k8s.io
        roleRef:
          kind: Role
          name: example-role
          apiGroup: rbac.authorization.k8s.io

### Cluster

1. Log in to the Tectonic UI.
2. Navigate to *Roles* under *Administration*.
3. Select a desired namespace from the drop-down.
4. Create a role by editing the YAML editor.   
5. Navigate to *Roles* under *Administration*.
6. Select a desired namespace from the drop-down.
7. Click *Create Binding*.
   A YAML editor is displayed.
8. Make necessary edits to create the role binding.
   An example YAML file that grant access to kube-system namespace. Note that "namespace" omitted because Cluster Roles are not namespaced.

        apiVersion: rbac.authorization.k8s.io/v1beta1
        kind: RoleBinding
        metadata:
          name: example-role-binding
        subjects:
          - kind: Group
            name: tstgroup
            apiGroup: rbac.authorization.k8s.io
        roleRef:
          kind: ClusterRole
          name: example-cluster-role
          apiGroup: rbac.authorization.k8s.io

## Users as part of multiple groups

Individual users can be part of multiple groups. The individual LDAP users or groups aren't viewable on the Tectonic Console. However, the roles and role bindings attached to users and groups are displayed on the individual Roles page. Editing the YAML file associated with individual roles is permitted to the role with necessary rights. For example, a cluster admin with full permission is allowed to edit a YAML file of a cluster admin with limited permissions, but not vice versa. Creating a rule or role binding is allowed from the role detail page.

## Managing removed LDAP users and groups

[LDAP user management]:ldap-user-management.md
[Default Roles in Tectonic]:identity-management.md
