# rstmdb Helm Chart

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/rstmdb)](https://artifacthub.io/packages/helm/rstmdb/rstmdb)
[![Lint and Test](https://github.com/rstmdb/rstmdb-helm/actions/workflows/lint.yaml/badge.svg)](https://github.com/rstmdb/rstmdb-helm/actions/workflows/lint.yaml)
[![Release](https://github.com/rstmdb/rstmdb-helm/actions/workflows/release.yaml/badge.svg)](https://github.com/rstmdb/rstmdb-helm/actions/workflows/release.yaml)

A Helm chart for deploying [rstmdb](https://github.com/rstmdb/rstmdb) - a state machine database with WAL durability.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installing the Chart

### From Artifact Hub / Helm Repository

This chart is available on [Artifact Hub](https://artifacthub.io/packages/helm/rstmdb/rstmdb).

Add the Helm repository:

```bash
helm repo add rstmdb https://rstmdb.github.io/rstmdb-helm
helm repo update
```

Install the chart:

```bash
helm install rstmdb rstmdb/rstmdb -n rstmdb --create-namespace
```

### From Source

```bash
git clone https://github.com/rstmdb/rstmdb-helm.git
cd rstmdb-helm
helm install rstmdb . -n rstmdb --create-namespace
```

## Uninstalling the Chart

```bash
helm uninstall rstmdb -n rstmdb
```

**Note:** This will not delete the PersistentVolumeClaims. To delete them:

```bash
kubectl delete pvc -l app.kubernetes.io/name=rstmdb -n rstmdb
```

## Configuration

See [values.yaml](values.yaml) for the full list of configurable parameters.

### Common Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of rstmdb replicas | `1` |
| `image.repository` | Image repository | `rstmdb/rstmdb` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Network Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `network.bindAddr` | RCP server bind address | `0.0.0.0:7401` |
| `network.idleTimeoutSecs` | Idle connection timeout | `300` |
| `network.maxConnections` | Maximum connections | `1000` |

### Storage Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `storage.dataDir` | Data directory path | `/data` |
| `storage.walSegmentSizeMb` | WAL segment size in MB | `64` |
| `storage.fsyncPolicy` | Fsync policy | `every_write` |
| `storage.persistence.enabled` | Enable persistent storage | `true` |
| `storage.persistence.storageClass` | Storage class | `""` (default) |
| `storage.persistence.size` | PVC size | `10Gi` |

### Authentication

| Parameter | Description | Default |
|-----------|-------------|---------|
| `auth.required` | Require authentication | `false` |
| `auth.tokenHashes` | List of SHA-256 token hashes | `[]` |
| `auth.existingSecret` | Existing secret with tokens | `""` |

### TLS Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `tls.enabled` | Enable TLS | `false` |
| `tls.existingSecret` | Existing TLS secret | `""` |
| `tls.requireClientCert` | Require client certificates | `false` |

### Compaction

| Parameter | Description | Default |
|-----------|-------------|---------|
| `compaction.enabled` | Enable compaction | `true` |
| `compaction.eventsThreshold` | Events threshold | `10000` |
| `compaction.sizeThresholdMb` | Size threshold in MB | `100` |
| `compaction.minIntervalSecs` | Minimum interval | `60` |

### Metrics

| Parameter | Description | Default |
|-----------|-------------|---------|
| `metrics.enabled` | Enable metrics endpoint | `true` |
| `metrics.bindAddr` | Metrics bind address | `0.0.0.0:9090` |
| `metrics.serviceMonitor.enabled` | Create ServiceMonitor | `false` |

### Resources

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `128Mi` |
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `512Mi` |

## Examples

### Basic Installation

```bash
helm install rstmdb . -n rstmdb --create-namespace
```

### Production Installation

```bash
helm install rstmdb . -n rstmdb --create-namespace -f values-production.yaml
```

### With Custom Values

```bash
helm install rstmdb . -n rstmdb --create-namespace \
  --set replicaCount=3 \
  --set storage.persistence.size=50Gi \
  --set auth.required=true
```

### With TLS Using Existing Secret

First, create the TLS secret:

```bash
kubectl create secret tls rstmdb-tls \
  --cert=path/to/tls.crt \
  --key=path/to/tls.key \
  -n rstmdb
```

Then install:

```bash
helm install rstmdb . -n rstmdb --create-namespace \
  --set tls.enabled=true \
  --set tls.existingSecret=rstmdb-tls
```

### With Authentication

Generate a token hash:

```bash
echo -n "your-secret-token" | sha256sum
```

Install with the hash:

```bash
helm install rstmdb . -n rstmdb --create-namespace \
  --set auth.required=true \
  --set auth.tokenHashes[0]="<your-token-hash>"
```

## Connecting to rstmdb

### Port Forward

```bash
kubectl port-forward svc/rstmdb 7401:7401 -n rstmdb
```

### Using rstmdb-cli

```bash
rstmdb-cli -s localhost:7401 ping
```

## Monitoring

If you have Prometheus Operator installed, enable the ServiceMonitor:

```bash
helm install rstmdb . -n rstmdb --create-namespace \
  --set metrics.serviceMonitor.enabled=true
```

The metrics endpoint exposes Prometheus metrics at `/metrics` on port 9090.

## Testing

Run Helm tests:

```bash
helm test rstmdb -n rstmdb
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -n rstmdb -l app.kubernetes.io/name=rstmdb
```

### Check Logs

```bash
kubectl logs -n rstmdb -l app.kubernetes.io/name=rstmdb
```

### Check Events

```bash
kubectl get events -n rstmdb --sort-by='.lastTimestamp'
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `helm lint .` to validate
5. Submit a pull request

## Releasing

Releases are automated via GitHub Actions:

1. Update the `version` in `Chart.yaml`
2. Push to `main` branch
3. The release workflow will automatically package and publish to GitHub Pages
4. Artifact Hub will index the new version within a few minutes

## License

This chart is licensed under the [MIT License](LICENSE).
