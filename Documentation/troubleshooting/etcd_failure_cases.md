# Understanding self-hosted etcd failure

A self-hosted etcd cluster powers the Kubernetes it runs on as pods. The etcd cluster itself is managed by the etcd operator, which also runs as a pod inside the same Kubernetes cluster. This setup significantly simplifies the installation of Kubernetes, and the maintenance of the etcd cluster. However, it does make the failure model of both etcd and Kubernetes more complicated.

This documentation explains how a self-hosted etcd cluster relies on Kubernetes, various failure scenarios, and of those what cases it can handle.

## Networking requirements

* DNS rules for resolving IP addresses of the etcd members. In normal operation, the kube-dns provides this functionality.

* iptables rules for connectivity between Kubernetes API servers and etcd members. In normal operation, the kube-proxy provides this functionality.

The self-hosted etcd members use host network to communicate with each other. Thus, its network availability does not rely on pod network (overlay network like flannel) or kube-proxy as other Kubernetes pods normally do. However, self-hosted etcd members reaches to its peers through Fully Qualified Domain Names (FQDNs) for TLS SAN(Subject Alternative Name) requirements. They rely on the availability of kube-dns to propagate DNS entries to resolve it peers’ IPs from their advertised FQDNs.
Kubernetes API servers connect to the self-hosted etcd cluster through a Kubernetes service with a pre-defined cluster IP. It relies on the kube-proxy  to ensure the connectivity to the etcd cluster. kube-proxy acts as a iptable rule manager and uses iptables rules to control connectivity and communication.

## Storage

The self-hosted etcd members use host path to store its data. From storage perspective, a self-hosted etcd cluster does not rely on Kubernetes after the initial bootstrap.

## Failure scenarios

Components of a self-hosted etcd cluster run only on master nodes. Worker node failures does not affect self-hosted etcd.

There are two types of failures on master nodes: transient and permanent. Transient failures occur due to machine reboots, maintenance, or temporary unavailability of Kubernetes control plane components, such as loss one of the three API servers. Self-hosted etcd can handle transient failures. Permanent failures occurs due to machine failures or a total loss of Kubernetes control plane components, and requires human intervention to recover the cluster.

### Rebooting master nodes

Rebooting master nodes does not affect the stability of self-hosted etcd. The control plane can be recovered when the majority of the nodes that etcd pods are scheduled to are back online. But handling this failure is tricky.

When all the master nodes reboot at the same time, Kubernetes control plane becomes unavailable. To recover the Kubernetes cluster after the reboot, the self-hosted etcd needs to be ready first. However, self-hosted etcd also runs inside Kubernetes, and relies on Kubernetes components like kube-proxy and kube-dns to communicate.

To break this circular dependency, use checkpointing tools for both pod and network. The pod checkpointer can restart etcd pod without a working Kubernetes control plane, and the network checkpointer can recovery the network setup (DNS and iptables rules) without a working Kubernetes control plane.

### Machine maintenance

Machine maintenance will cause Kubelet to drain pods. The etcd operator will reschedule the drained etcd pod to another available machine, or add it back to the original machine once the maintenance is completed and if there is no other available machines.

### Unavailability of Kubernetes components

Temporary or partial unavailability of Kuberenetes components does not affect self-hosted etcd nor Kubernetes in general. It should recover itself when the failure is removed. However, there are certain cases when human interventions are needed, which are given below.  

#### API Server

If all API servers are lost, a disaster recovery action must be taken. etcd operator cannot manage self-hosted etcd anymore when API server is down.

#### Scheduler

If all scheduler pods are lost, etcd operator cannot recover any etcd pod failures happened afterward.

To recover from a scheduler failure, create a temporary scheduler by using static pod or directly bind to a node through API server.
See https://coreos.com/tectonic/docs/latest/troubleshooting/controller-recovery.html.

#### Controller Manager

If all controller manager pods are lost, etcd operator cannot create services correctly for newly created etcd pods afterward.

To recover controller manager failure, create a temporary scheduler pod by using static pod or directly bind to a node through API server.
See https://coreos.com/tectonic/docs/latest/troubleshooting/controller-recovery.html.

#### etcd unavailability

If the majority of etcd nodes are lost, a disaster recovery action must be taken.
