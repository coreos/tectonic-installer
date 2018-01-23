import _ from 'lodash';

import { BARE_METAL_TF } from './platforms';
import { keyToAlg } from './utils';

// TODO: (ggreer) clean up key names. Warning: Doing this will break progress files.
export const AWS_ACCESS_KEY_ID = 'awsAccessKeyId';
export const AWS_SUBNETS = 'awsSubnets';
export const AWS_CONTROLLER_SUBNETS = 'awsControllerSubnets';
export const AWS_CONTROLLER_SUBNET_IDS = 'awsControllerSubnetIds';
export const DESELECTED_FIELDS = 'deselectedFields';
export const AWS_HOSTED_ZONE_ID = 'awsHostedZoneId';
export const AWS_SPLIT_DNS = 'awsSplitDNS';
export const AWS_REGION = 'awsRegion';
export const AWS_SECRET_ACCESS_KEY = 'awsSecretAccessKey';
export const AWS_SESSION_TOKEN = 'awsSessionToken';
export const AWS_SSH = 'aws_ssh';
export const AWS_TAGS = 'awsTags';

export const AWS_ADVANCED_NETWORKING = 'awsAdvancedNetworking';
export const AWS_CREATE_VPC = 'awsCreateVpc';
export const AWS_VPC_CIDR = 'awsVpcCIDR';
export const AWS_VPC_ID = 'awsVpcId';

export const VPC_CREATE = 'VPC_CREATE';
export const VPC_PRIVATE = 'VPC_PRIVATE';
export const VPC_PUBLIC = 'VPC_PUBLIC';

export const AWS_WORKER_SUBNETS = 'awsWorkerSubnets';
export const AWS_WORKER_SUBNET_IDS = 'awsWorkerSubnetIds';

export const BM_MATCHBOX_CA = 'matchboxCA';
export const BM_MATCHBOX_CLIENT_CERT = 'matchboxClientCert';
export const BM_MATCHBOX_CLIENT_KEY = 'matchboxClientKey';
export const BM_MATCHBOX_HTTP = 'matchboxHTTP';
export const BM_MATCHBOX_RPC = 'matchboxRPC';
export const BM_MASTERS = 'masters';
export const BM_OS_TO_USE = 'osToUse';
export const BM_TECTONIC_DOMAIN = 'tectonicDomain';
export const BM_WORKERS = 'workers';

export const CA_CERTIFICATE = 'caCertificate';
export const CA_PRIVATE_KEY = 'caPrivateKey';
export const CA_TYPE = 'caType';
export const CA_TYPES = {SELF_SIGNED: 'self-signed', OWNED: 'owned'};
export const CLUSTER_NAME = 'clusterName';
export const CLUSTER_SUBDOMAIN = 'clusterSubdomain';
export const CONTROLLER_DOMAIN = 'controllerDomain';
export const EXTERNAL_ETCD_CLIENT = 'externalETCDClient';

export const ETCD_OPTION = 'etcdOption';

export const DRY_RUN = 'dryRun';
export const PLATFORM_TYPE = 'platformType';
export const PULL_SECRET = 'pullSecret';
export const SSH_AUTHORIZED_KEY = 'sshAuthorizedKey';
export const STS_ENABLED = 'sts_enabled';
export const TECTONIC_LICENSE = 'tectonicLicense';
export const ADMIN_EMAIL = 'adminEmail';
export const ADMIN_PASSWORD = 'adminPassword';
export const ADMIN_PASSWORD2 = 'adminPassword2';

// Networking
export const POD_CIDR = 'podCIDR';
export const SERVICE_CIDR = 'serviceCIDR';

export const IAM_ROLE = 'iamRole';
export const NUMBER_OF_INSTANCES = 'numberOfInstances';
export const INSTANCE_TYPE = 'instanceType';
export const STORAGE_SIZE_IN_GIB = 'storageSizeInGiB';
export const STORAGE_TYPE = 'storageType';
export const STORAGE_IOPS = 'storageIOPS';

export const RETRY = 'retry';

// FORMS:
export const AWS_CREDS = 'AWSCreds';
export const AWS_ETCDS = 'aws_etcds';
export const AWS_VPC_FORM = 'aws_vpc';
export const AWS_CONTROLLERS = 'aws_controllers';
export const AWS_WORKERS = 'aws_workers';
export const AWS_REGION_FORM = 'aws_regionForm';
export const BM_SSH_KEY = 'bm_sshKey';
export const CREDS = 'creds';
export const LICENSING = 'licensing';
export const PLATFORM_FORM = 'platform';

export const SPLIT_DNS_ON = 'on';
export const SPLIT_DNS_OFF = 'off';
export const SPLIT_DNS_OPTIONS = {
  [SPLIT_DNS_ON]: 'Create an additional Route 53 private zone (default).',
  [SPLIT_DNS_OFF]: 'Do not create a private zone.',
};

export const ETCD_OPTIONS = {EXTERNAL: 'external', PROVISIONED: 'provisioned'};

// String that would be an invalid IAM role name
export const IAM_ROLE_CREATE_OPTION = '%create%';

export const selectedSubnets = (cc, subnets) => {
  const awsSubnets = {};
  _.each(subnets, (v, availabilityZone) => {
    if (v && availabilityZone.startsWith(cc[AWS_REGION]) && !_.get(cc, [DESELECTED_FIELDS, AWS_SUBNETS, availabilityZone])) {
      awsSubnets[availabilityZone] = v;
    }
  });
  return awsSubnets;
};

export const getAwsZoneDomain = cc => _.get(cc, ['extra', AWS_HOSTED_ZONE_ID, 'zoneToName', cc[AWS_HOSTED_ZONE_ID]]);

export const getTectonicDomain = (cc) => {
  if (cc[PLATFORM_TYPE] === BARE_METAL_TF) {
    return cc[BM_TECTONIC_DOMAIN];
  }
  if (!cc[CLUSTER_SUBDOMAIN]) {
    return;
  }
  return cc[CLUSTER_SUBDOMAIN] + (cc[CLUSTER_SUBDOMAIN].endsWith('.') ? '' : '.') + getAwsZoneDomain(cc);
};

export const DEFAULT_CLUSTER_CONFIG = {
  error: {}, // to store validation errors
  inFly: {}, // to store inFly
  extra: {}, // extraneous, non-value data for this field
  [BM_MATCHBOX_HTTP]: '',
  [BM_OS_TO_USE]: '',
  [DRY_RUN]: false,
  [RETRY]: false, // whether we're retrying a terraform apply
};

// Cluster config that is common to all platforms
const baseConfig = cc => {
  const config = {
    dryRun: cc[DRY_RUN],
    license: cc[TECTONIC_LICENSE],
    pullSecret: cc[PULL_SECRET],
    retry: cc[RETRY],
    variables: {
      Console: {
        AdminEmail: cc[ADMIN_EMAIL],
        AdminPassword: cc[ADMIN_PASSWORD],
      },
      Name: cc[CLUSTER_NAME],
      Networking: {
        PodCIDR: cc[POD_CIDR],
        ServiceCIDR: cc[SERVICE_CIDR],
      },
      Version: '1.0',
    },
  };

  if (cc[CA_TYPE] === CA_TYPES.OWNED) {
    config.variables.CA = {
      Cert: cc[CA_CERTIFICATE],
      Key: cc[CA_PRIVATE_KEY],
      KeyAlg: keyToAlg(cc[CA_PRIVATE_KEY]),
    };
  }

  return config;
};

export const toAwsConfig = ({clusterConfig: cc, dirty}) => {
  const credentials = {
    AWSAccessKeyID: cc[AWS_ACCESS_KEY_ID],
    AWSSecretAccessKey: cc[AWS_SECRET_ACCESS_KEY],
  };
  if (cc[STS_ENABLED]) {
    credentials.AWSSessionToken = cc[AWS_SESSION_TOKEN];
  }

  const etcdsVal = id => cc[`${AWS_ETCDS}-${id}`];
  const mastersVal = id => cc[`${AWS_CONTROLLERS}-${id}`];
  const workersVal = id => cc[`${AWS_WORKERS}-${id}`];
  const iamRole = role => role === IAM_ROLE_CREATE_OPTION ? undefined : role;

  const variables = {
    AWS: {
      Master: {
        EC2Type: mastersVal(INSTANCE_TYPE),
        IAMRoleName: iamRole(mastersVal(IAM_ROLE)),
        RootVolume: {
          Size: mastersVal(STORAGE_SIZE_IN_GIB),
          Type: mastersVal(STORAGE_TYPE),
        },
      },
      Worker: {
        EC2Type: workersVal(INSTANCE_TYPE),
        IAMRoleName: iamRole(workersVal(IAM_ROLE)),
        RootVolume: {
          Size: workersVal(STORAGE_SIZE_IN_GIB),
          Type: workersVal(STORAGE_TYPE),
        },
      },
      Region: cc[AWS_REGION],
      SSHKey: cc[AWS_SSH],
    },
    DNS: {
      BaseDomain: getAwsZoneDomain(cc),
      DNSName: cc[CLUSTER_SUBDOMAIN],
    },
    Etcd: {},
    Masters: {
      NodeCount: mastersVal(NUMBER_OF_INSTANCES),
    },
    Platform: 'aws',
    Workers: {
      NodeCount: workersVal(NUMBER_OF_INSTANCES),
    },
  };

  _.each(cc[AWS_TAGS], ({key, value}) => {
    if (key && value) {
      _.set(variables.AWS, `ExtraTags.${key}`, value);
    }
  });

  if (mastersVal(STORAGE_TYPE) === 'io1') {
    variables.AWS.Master.RootVolume.IOPS = mastersVal(STORAGE_IOPS);
  }
  if (workersVal(STORAGE_TYPE) === 'io1') {
    variables.AWS.Worker.RootVolume.IOPS = workersVal(STORAGE_IOPS);
  }
  if (cc[ETCD_OPTION] === ETCD_OPTIONS.EXTERNAL) {
    variables.Etcd = {ExternalServers: [cc[EXTERNAL_ETCD_CLIENT]]};
  } else if (cc[ETCD_OPTION] === ETCD_OPTIONS.PROVISIONED) {
    variables.Etcd = {NodeCount: etcdsVal(NUMBER_OF_INSTANCES)};
    variables.AWS.Etcd = {
      EC2Type: etcdsVal(INSTANCE_TYPE),
      RootVolume: {
        Size: etcdsVal(STORAGE_SIZE_IN_GIB),
        Type: etcdsVal(STORAGE_TYPE),
      },
    };
    if (etcdsVal(STORAGE_TYPE) === 'io1') {
      variables.AWS.Etcd.IOPS = etcdsVal(STORAGE_IOPS);
    }
  }

  if (cc[AWS_CREATE_VPC] === VPC_CREATE) {
    variables.AWS.VPCCIDRBlock = cc[AWS_VPC_CIDR];

    // If the AWS Advanced Networking section was never opened, omit these variables so that sensible default subnets
    // will be created
    if (dirty[AWS_ADVANCED_NETWORKING]) {
      variables.AWS.Master.CustomSubnets = selectedSubnets(cc, cc[AWS_CONTROLLER_SUBNETS]);
      variables.AWS.Worker.CustomSubnets = selectedSubnets(cc, cc[AWS_WORKER_SUBNETS]);
    }
  } else {
    variables.AWS.External = cc[AWS_VPC_ID];
    variables.AWS.Master.SubnetIDs = _.values(selectedSubnets(cc, cc[AWS_CONTROLLER_SUBNET_IDS]));
    variables.AWS.PublicEndpoints = cc[AWS_CREATE_VPC] !== VPC_PRIVATE;
    variables.AWS.Worker.SubnetIDs = _.values(selectedSubnets(cc, cc[AWS_WORKER_SUBNET_IDS]));
  }

  if (cc[AWS_CREATE_VPC] !== VPC_PRIVATE && cc[AWS_SPLIT_DNS] === SPLIT_DNS_OFF) {
    variables.AWS.PrivateEndpoints = false;
  }

  return _.merge(baseConfig(cc), {credentials, variables});
};

export const toMetalConfig = ({clusterConfig: cc}) => {
  const masters = cc[BM_MASTERS];
  const workers = cc[BM_WORKERS];

  const variables = {
    ContainerLinux: {
      Version: cc[BM_OS_TO_USE],
    },
    Metal: {
      Matchbox: {
        CA: cc[BM_MATCHBOX_CA],
        Client: {
          Cert: cc[BM_MATCHBOX_CLIENT_CERT],
          Key: cc[BM_MATCHBOX_CLIENT_KEY],
        },
        HTTPURL: `http://${cc[BM_MATCHBOX_HTTP]}`,
        RPCEndpoint: cc[BM_MATCHBOX_RPC],
      },
      Controller: {
        Domain: cc[CONTROLLER_DOMAIN],
        Domains: masters.map(({host}) => host),
        MACs: masters.map(({mac}) => mac),
        Names: masters.map(({host}) => host.split('.')[0]),
      },
      IngressDomain: getTectonicDomain(cc),
      SSHAuthorizedKey: cc[SSH_AUTHORIZED_KEY],
      Worker: {
        Domains: workers.map(({host}) => host),
        MACs: workers.map(({mac}) => mac),
        Names: workers.map(({host}) => host.split('.')[0]),
      },
    },
    Platform: 'metal',
  };

  if (cc[ETCD_OPTION] === ETCD_OPTIONS.EXTERNAL) {
    variables.Etcd = {ExternalServers: [cc[EXTERNAL_ETCD_CLIENT]]};
  }

  return _.merge(baseConfig(cc), {variables});
};
