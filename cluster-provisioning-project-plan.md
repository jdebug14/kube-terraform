# kube-portal on GKE — cluster provisioning project plan

## Why this exists

kube-portal proved you can build a solid, well-tested tool that *observes* a
cluster. This track proves the other half: that you can *provision and
operate* one. The target isn't a new app — it's the ability to say, backed by
firsthand experience, "I provisioned a GKE cluster with Terraform, wired up
least-privilege IAM, and deployed a real workload onto it, reachable over the
network." That's the resume line this validates.

kube-portal is the workload. This repo/plan covers the infrastructure around it.

## Philosophy

- **Apply early, don't perfect Terraform in isolation.** The value is in what
  breaks and how you fix it — quota limits, IAM errors, a forgotten API
  enablement. Reading docs doesn't produce that; running `apply` does.
- **Treat the cluster as disposable.** No infra should be up when you're not
  actively working. `terraform destroy` at the end of every session is part
  of the workflow, not an afterthought.
- **Cost discipline is a design constraint, not a worry.** Budget alert on
  day one, small node footprint, short-lived clusters. Should cost close to
  nothing if followed.
- **Standard mode over Autopilot, deliberately.** Autopilot is cheaper and
  easier, but it abstracts away node pools, machine types, and autoscaling —
  the actual "cluster operations" surface area. Standard mode is the one
  worth learning first.

## Explicitly out of scope (for now)

| Item | Reason | Revisit when |
|---|---|---|
| Multi-region / multi-cluster | Complexity multiplier, not needed to prove the fundamental | After single-cluster story is solid |
| CI/CD to auto-build/push images | Separate skill (pipelines), not cluster ops | Natural phase 2 |
| GitOps (ArgoCD/Flux) | Interesting, but a different tool category | Once manual deploys feel routine |
| Cluster autoscaler / spot nodes | Cost-optimization depth, not fundamentals | Stretch goal, see Phase 6 |
| AWS/EKS translation | You said it yourself — validate GCP hands-on first, translate later | After GCP DoD is met |
| Observability stack (Prometheus/Grafana) | Separate from what kube-portal already gives you | Possible later platform-depth add-on |

## Phase 0 — Account & safety net (~30 min, do first)

- Confirm GCP free trial eligibility (never had a paying GCP/Firebase/Maps
  account) and create the billing account if eligible
- Set a budget alert (e.g. $10) immediately — before creating any resources
- Enable required APIs: Compute Engine, GKE, Artifact Registry, IAM
- Install/auth `gcloud` CLI and Terraform locally

## Phase 1 — Terraform: base infrastructure

- Provider config (`google` provider; local state is fine solo — note that
  remote state/locking would be the production answer, but won't build it
  now)
- VPC + subnet
- GKE Standard cluster resource, **zonal** (not regional — keeps it inside
  the free tier's cluster-fee coverage)
- Node pool: `e2-medium`, 1–2 nodes, no autoscaler
  yet
- `terraform fmt` / `validate` / `plan` review before the first `apply`
- `terraform apply` — first real hands-on milestone

## Phase 2 — IAM / Workload Identity

- Create a Google service account scoped to only what kube-portal actually
  needs (minimal — it only talks to the in-cluster k8s API)
- Bind the Kubernetes service account (from the RBAC manifests) to it via
  Workload Identity
- This is the real-cloud-IAM completion of the least-privilege RBAC story
  that was deferred in kube-portal's own plan

## Phase 3 — Deploy kube-portal onto the cluster

- `kubectl apply` namespace, serviceaccount, clusterrole/clusterrolebinding
  (get/list/watch only, matching kube-portal's original RBAC design),
  deployment (pointing at the Artifact Registry image), service
- Confirm the pod is healthy (`kubectl get pods`, `describe`)
- Expose via a LoadBalancer Service, get the external IP, load it in a
  browser
- Nice validation point: the portal should be able to see the very
  namespaces/pods/deployments that make up its own infrastructure

## Phase 4 — Teardown & repeatability

- Document the exact `terraform destroy` steps and confirm billing drops to
  zero afterward
- Re-`apply` from scratch once to prove the whole thing is reproducible, not
  a one-off that happened to work
- "I can tear this down and rebuild it reliably" is its own interview point

## Phase 5 — Stretch goals (pick one, later, not required for DoD)

- Regional cluster / multi-zone node pool, to discuss availability trade-offs
- Ingress + managed cert instead of a bare LoadBalancer
- Stand up an Autopilot cluster as a side-by-side comparison and write up
  the trade-offs firsthand
- Translate the Terraform module to AWS/EKS

## Definition of done

- [ ] Terraform provisions VPC + GKE cluster + node pool from scratch,
      reproducibly
- [ ] Workload Identity configured for least-privilege access
- [ ] kube-portal running in-cluster, reachable over the network via
      external IP
- [ ] Can explain the Standard vs Autopilot trade-off from firsthand
      experience
- [ ] Teardown/rebuild cycle verified at least once
- [ ] Total spend stayed near $0 (free tier + short-lived clusters +
      budget alert)

## Running notes (fill in as you go)

Keep a short log of what broke and how you fixed it as you work through
this. That log — not the finished Terraform — is the material the interview
story is actually built from.
