# Recovering self-hosted etcd operator

This document covers major failure scenarios of a self-hosted etcd operator and instructions to recover.

## Limitations

Before performing recovery operations, consider the following limitations to avoid attempting unsupported cases.

* The etcd operator only manages the etcd cluster created in the same namespace. Users need to create multiple operators in different namespaces to manage etcd clusters in different namespaces.

* Backup works only for data stored in a etcd3 storage, not the data stored in a etcd2 storage.

* Backing up persistent volume only works on [GCE](GCE) and [AWS](AWS) for now.

* Migration, the process of allowing the etcd operator to manage existing etcd3 clusters, only supports a single-member cluster, with its node running in the same Kubernetes cluster.

* The operator collects anonymous usage statistics to help the development team learn how the software is being used and how can be improved. To disable usage collection, run the operator with the flag -analytics=false

## Recovery semantics

understanding recovery semantics in terms of data loss from catastrophic failure scenario, and giving users a choice as to whether they prefer downtime or data-loss, or at least define what choice has been made

## High availability

### Recovering an etcd member

#### Minority of etcd members crashed

If a minority of the etcd members crash, the etcd operator will automatically recover from the failure by creating new pods. For example, simulate a member failure:

1. Create an etcd cluster with three members:

    `$ kubectl create -f example/example-etcd-cluster.yaml`

    Wait until all the etcd members are up and running.

2. Simulate a member failure by deleting a pod:

    `$ kubectl delete pod example-etcd-cluster-0000 --now`

3. Run the following to print all the running pods:

    `$ kubectl get pods`

   The etcd operator recovers from the failure by creating a new pod example-etcd-cluster-0003:

    ```
    NAME                            READY     STATUS    RESTARTS   AGE
    example-etcd-cluster-0001       1/1       Running   0          1m
    example-etcd-cluster-0002       1/1       Running   0          1m
    example-etcd-cluster-0003       1/1       Running   0          1m
    ```

#### Majority of etcd members crashed (quorum loss)
(Recovering from quorum loss)

If majority of the etcd members are crashed, but at least one backup exists for the cluster, the entire cluster can be recovered from the backup. By default, the etcd operator creates a storage class on initialization. This storage class is used to request the persistent volume to store the backup data.

Verify by retrieve the storage class:

  `$ kubectl get storageclass`

    ```  
    NAME                 TYPE
    etcd-backup-gce-pd   kubernetes.io/gce-pd
    ```

To create a backup, create a cluster from a backup-enable specification. For demonstration purpose, consider the following specification. Do not use the following for production.

```
apiVersion: "etcd.coreos.com/v1beta1"
kind: "Cluster"
metadata:
  name: "example-etcd-cluster-with-backup"
spec:
  size: 3
  version: "3.1.8"
  backup:
    # short snapshot interval for testing. do not use this in production
    backupIntervalInSecond: 30
    maxBackups: 5
    storageType: "PersistentVolume"
    pv:
      volumeSizeInMB: 512
```

1. Create a cluster from the above specification:

    `kubectl create -f example/example-etcd-cluster-with-backup.yaml`

2. Verify a persistent volume claim is created for the backup pod:

    `$ kubectl get pvc`

    If created, the following message is displayed:

    ```
    NAME                           STATUS    VOLUME                                     CAPACITY   ACCESSMODES   AGE
    example-etcd-with-backup-pvc   Bound     pvc-79e39bab-b973-11e6-8ae4-42010af00002   1Gi        RWO           9s

    ```

3. Write some data into the etcd cluster:

    ```
    $ kubectl run --rm -i --tty fun --image quay.io/coreos/etcd --restart=Never -- /bin/sh
/ # ETCDCTL_API=3 etcdctl --endpoints http://example-etcd-cluster-with-backup-client:2379 put foo bar

    OK
    ```

    If OK is printed writing is successful. Press Ctrl+D to exit.

4. Terminate two pods to simulate a failure:

   ```
   $ kubectl delete pod example-etcd-cluster-with-backup-0000 example-etcd-cluster-with-backup-0001 --now`

    pod "example-etcd-cluster-with-backup-0000" deleted
    pod "example-etcd-cluster-with-backup-0001" deleted
    ```

Now quorum is lost. The etcd operator will start to recover the cluster by:

* Creating a new seed member to recover from the backup

* Adding more members until the size reaches to a specified number

Verify a seed member is created by retrieving the pods:

`$ kubectl get pods`

```
NAME                                                    READY     STATUS     RESTARTS   AGE
example-etcd-cluster-with-backup-0003                   0/1       Init:0/2   0          11s
example-etcd-cluster-with-backup-backup-sidecar-e9gkv   1/1       Running    0          18m
```

Verify membered are added until size reaches to a specified number:

`$ kubectl get pods`

```
NAME                                                    READY     STATUS    RESTARTS   AGE
example-etcd-cluster-with-backup-0003                   1/1       Running   0          3m
example-etcd-cluster-with-backup-0004                   1/1       Running   0          3m
example-etcd-cluster-with-backup-0005                   1/1       Running   0          3m
example-etcd-cluster-with-backup-backup-sidecar-e9gkv   1/1       Running   0          22m
```
Destroy the cluster and cleanup the backup:

`$ kubectl delete pvc example-etcd-cluster-with-backup-pvc`

 If a pod is recovered before all the members are deleted, other members cannot be recovered.





### Recovering from a full cluster failure

i.e. power-off (I think this can be accomplished using snapshotting and the operator's built in restart tolerance)

### Recovering from a failed, partial, or an interrupted upgrade

### Recovering from a failed or total control plane outage

If a partial or total control plane outage (due to lose of master nodes) occurs an experimental `recover` command can extract and write manifests from a backup location. These manifests can then be used by the `start` command to restart the cluster. Currently recovery from a running API server, an external running etcd cluster, or an etcd backup taken from the self-hosted etcd cluster are supported.

To recover from an external running etcd cluster:

```
$ bootkube recover --asset-dir=recovered --etcd-servers=http://127.0.0.1:2379 --kubeconfig=/etc/kubernetes/kubeconfig
```

To recover from a running API server (i.e. if the scheduler pods are all down):

```
$ bootkube recover --asset-dir=recovered --kubeconfig=/etc/kubernetes/kubeconfig
```
Recover from an etcd backup when self hosted etcd is enabled:

```
$ bootkube recover --asset-dir=recovered --etcd-backup-file=backup --kubeconfig=/etc/kubernetes/kubeconfig
```

### Restoring from a backup

if a failed upgrade occurs, the user can manual restore from a backup file. See quorum loss.

#### Recovering from an etcd backup when self hosted etcd is enabled

## Recovering a cluster during or soon after etcd 2 to etcd 3 upgrade, where the bootstrap version is older than local version

## etcd running but not responding to queries


## apiserver runs but does not make progress after etcd operation

## k-c-m runs but does not make progress after etcd operation

## kube-scheduler runs but does not make progress after etcd operation

## kubelet upgrade runs but does not make progress after etcd operation

## recovery from SSL key expiry

## master cluster down and power-on

## master cluster API server failure

if non-HA you need to recover the load balancer or pods via static pods

## disk loss failure of entire master cluster

you need to recover from backups, see bootkube recovery

## pod checkpoint checkpoints bad versions

you need to manually fix the static manifests checkpointed in /etc/kubernetes/inactive-manifests

<from https://docs.google.com/document/d/1tMtONz4w9C-EpADtoTHWRUSQo7892KtjC-Oh_S-xfC4/edit?ts=594b05ab>

etcd is under stress either IO or Memory Pressure.
  Need alerts for this in the UI.
  Customer perception is that the cluster is intermittently working.
  Sizing for etcd cluster.

etcd recovery for tectonic
  Configure snapshot to remote destination.
  How to use that remote snapshot to seed a new cluster.
  How to configure tectonic to use the new cluster (Could be a label thing since we are using kube services.)


<ref: https://github.com/kubernetes/kubeadm/issues/277>

[GCE](https://kubernetes.io/docs/concepts/storage/volumes/#gcepersistentdisk)
[AWS](https://kubernetes.io/docs/concepts/storage/volumes/#awselasticblockstore)
