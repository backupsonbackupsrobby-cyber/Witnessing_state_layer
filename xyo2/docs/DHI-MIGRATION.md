# ENGINE2 Docker Hardened Images Migration Guide

## Overview

This document describes the migration of the ENGINE2 system to Docker Hardened Images (DHI) with a Flower of Life orchestration topology comprising 43 distributed engines across sacred geometry architecture.

## Architecture

### System Components

- **Operator Plane**: 1 center engine (operator-sovereign)
- **Engine Plane**: 5 engine types (Tesla, Einstein, Newton, Heke, Cook) - 6 instances each
- **Identity Plane**: Multi-script support (hiragana, katakana, kanji, Māori, Fijian)
- **Routing Plane**: DNSSEC + ZeroTrust DNS + Cloudflare tunnels
- **Pulse Plane**: Timing constants (0.02/0.05/0.075/0.15 seconds)
- **Support Infrastructure**: XYO cryptographic anchoring, audit trail

### Flower of Life Topology

```
                    Petal 6 (Support)
                   [Identity, Routing,
                    Pulse, Audit]
                        6 engines
                          
    Petal 5 (Cook)                  Petal 1 (Tesla)
    [Mapping,                        [Motion,
     Expansion]                       Energy]
     6 engines                        6 engines
                      
                    Center (1)
              [Operator-Sovereign]
                   
    Petal 4 (Heke)                  Petal 2 (Einstein)
    [Navigation,                     [Relativity,
     Sovereignty]                     Frame]
     6 engines                        6 engines
                        
                   Petal 3 (Newton)
                   [Force,
                    Constraint]
                    6 engines

Total: 1 + (6 × 6) + 1 = 43 engines
```

## DHI Migration Details

### Base Image Selection

**Chosen**: `dhi.io/python:3.13-alpine3.22`

**Rationale**:
- Alpine Linux provides minimal attack surface (~130 MB)
- Python 3.13 supports all required cryptographic libraries
- DHI images are security-hardened and non-root by default
- Alpine provides fast container startup for Flower cycle synchronization

### Multi-Stage Build Strategy

The Dockerfile uses a two-stage approach:

**Stage 1 (Builder)**: `dhi.io/python:3.13-alpine3.22-dev`
- Contains package manager and build tools
- Installs dependencies: Flask, requests, pycryptodome, pydantic, etc.
- Creates clean build artifacts

**Stage 2 (Runtime)**: `dhi.io/python:3.13-alpine3.22`
- Minimal runtime image without package managers
- Only copies necessary artifacts from builder
- No shell, no package manager
- Runs as non-root user (python:1000:1000)

### Non-Root Execution

DHI images run as non-root by default:
- User: `python` (UID 1000)
- Group: `python` (GID 1000)
- No privileged ports (<1024) required
- Application listens on port 5000 and above

### Security Hardening Features

1. **Minimal Base Image**
   - No shell (/bin/sh removed)
   - No package managers (apt, apk removed from runtime)
   - Standard TLS certificates included

2. **Cryptographic Operations**
   - pycryptodome (3.19.0) for ed25519 signatures
   - SHA256 hashing for XYO state verification
   - TLS 1.3 for network communication

3. **Health Checks**
   - Interval: 5 seconds
   - Timeout: 3 seconds
   - Start period: 10 seconds
   - Retries: 3
   - Aligned to Pulse Network cycle (0.15s)

4. **Volume Permissions**
   - All volumes mounted with proper ownership
   - State directories: non-root writable
   - Audit logs: append-only for integrity

## Configuration Planes

### Identity Plane (planes/identity.env)

Supports multi-script identity verification:
- Hiragana (あいうえお...)
- Katakana (アイウエオ...)
- Kanji (一二三四五...)
- Māori (āēīōū)
- Fijian (fj language code)

Device classification:
- Matariki (traditional cluster)
- Rehua (primary star)
- Altair (secondary reference)

Domain split:
- robdoe.com (public, ZeroTrust DNS required)
- robertdoe.pw (private, enhanced security)

### Routing Plane (planes/routing.env)

- DNSSEC: Full validation mode, strict enforcement
- ZeroTrust: Restrictive policy, device trust required
- Cloudflare: Tunnel support for hybrid deployments
- Identity routing: Operator-defined access rules

### Pulse Plane (planes/pulse.env)

Timing constants for distributed synchronization:
- UI: 0.02s (50 Hz) - User interface feedback
- Tactile: 0.05s (20 Hz) - Haptic/touch sensors
- Wearable: 0.075s (13.3 Hz) - Biometric sampling
- Network: 0.15s (6.7 Hz) - Distributed state sync

Flower cycle alignment ensures all engines complete within 1.0s target.

### Operator Plane (planes/operator.env)

Sovereign stance with non-negotiable invariants:
- **Truth Invariant**: Immutable cryptographic verification
- **Boundaries Invariant**: Strict namespace enforcement
- **Allowed-States Invariant**: Explicit whitelist validation

Non-reactive mode with deterministic decision engine.

## XYO Cryptographic Anchoring

### State Verification

- Protocol: XYO 4.0
- Hash: SHA256 with chain verification
- Merkle tree depth: 43 (one per engine)
- Block signature: ed25519

### Ledger Storage

- Location: `/data/xyo-ledger`
- Format: JSON with timestamps (RFC 3339)
- Rotation: 100 MB per file
- Retention: 365 days

### Flower-Level Anchoring

- Center engine anchors all petal states
- Distributed consensus on merkle root
- Sync interval aligned to network pulse (0.15s)
- Verification on every cycle completion

## Deployment on WSL2

### Prerequisites

1. Docker Desktop with WSL2 integration
2. WSL2 distribution with Linux kernel 5.10+
3. 8+ GB RAM allocated to WSL2
4. 20+ GB disk space for volumes and logs

### Deployment Process

```bash
# 1. Deploy services
./scripts/deploy.sh

# 2. Monitor startup
docker-compose logs -f operator-sovereign

# 3. Check health
./scripts/healthcheck.sh

# 4. View metrics
curl http://localhost:5000/metrics

# 5. Stop system
docker-compose down -v
```

### Port Mapping

**Center**: 5000
**Tesla Petal**: 5001-5006
**Einstein Petal**: 5010-5015
**Newton Petal**: 5020-5025
**Heke Petal**: 5030-5035
**Cook Petal**: 5040-5045
**Support Petal**: 5050-5055

### Volume Management

Each engine has its own state volume:
- Format: `{engine_name}_state` or `{engine_name}_logs`
- Driver: local
- Persisted across restarts
- Backup-enabled for operator-sovereign

## Maintenance

### Image Updates

When DHI base images are updated:

```bash
# Rebuild with latest DHI images
docker-compose build --pull --no-cache

# Restart services
docker-compose up -d
```

### Log Rotation

XYO ledger files rotate at 100 MB:
- Automatic compression
- 365-day retention policy
- Audit log separate from application logs

### Health Monitoring

```bash
# Check individual engine health
docker ps --filter "label=engine-type=tesla" --format "table {{.Names}}\t{{.Status}}"

# Monitor cycle completion
docker-compose logs audit-trail | grep "cycle-complete"

# Track XYO anchor verification
docker-compose logs operator-sovereign | grep "merkle-root"
```

## Troubleshooting

### Image Build Failures

**Issue**: `dhi.io/python:3.13-alpine3.22` image not found

**Solution**:
```bash
# Verify registry access
docker pull dhi.io/python:3.13-alpine3.22

# Fallback to published digest
# FROM dhi.io/python@sha256:...
```

### Health Check Timeouts

**Issue**: Services fail initial health checks

**Solution**:
- Increase `start_period` to 30s for slow systems
- Check available Docker resources
- Verify network isolation is disabled

### Non-Root Permission Errors

**Issue**: Application cannot write to volumes

**Solution**:
```bash
# Fix volume ownership (from host)
docker exec operator-sovereign \
  chown -R 1000:1000 /app/state /app/logs
```

### XYO Anchor Verification Failures

**Issue**: Merkle tree verification fails

**Solution**:
- Check ledger file integrity
- Verify all engines have synchronized state
- Restart center engine to resync all petals

## Compliance and Auditing

### Security Compliance

- NIST 800-190: Container security guidelines
- CIS Docker Benchmark: Hardened image practices
- DHI certification: Security-hardened base images

### Audit Trail

- **Location**: `/app/logs/audit.trail`
- **Format**: JSON with cryptographic proofs
- **Retention**: 365 days minimum
- **Access**: Non-writable after creation (append-only)

### Cryptographic Verification

```bash
# Verify ledger signature
docker exec operator-sovereign \
  python -m xyo.verify /data/xyo-ledger

# Export audit trail with proofs
docker exec audit-trail \
  python -m audit.export --format=pdf
```

## Performance Metrics

### Target Specifications

- Cycle completion time: <1.0s (6 petals × 0.167s)
- Network synchronization: 0.15s (pulse-network)
- State anchor verification: <100ms per cycle
- Message latency (p99): <50ms

### Monitoring

```bash
# Prometheus metrics endpoint
curl http://localhost:5000/metrics

# Flower cycle duration
curl http://localhost:5000/metrics | grep flower_cycle_duration

# Engine health status
curl http://localhost:5000/health | jq '.engines[] | {name, status, latency}'
```

## References

- [Docker Hardened Images](https://docs.docker.com/hardened-images/)
- [XYO Whitepaper](https://xyo.network/research)
- [Flower of Life Sacred Geometry](https://en.wikipedia.org/wiki/Flower_of_Life)
- [NIST Container Security](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-190.pdf)
