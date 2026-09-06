# Architecture notes / trade-offs

**Policy assignments use built-in definitions** (verified GUIDs, not
custom policy JSON):
- Allowed locations: `e56962a6-4747-49cd-b67b-bf8b01975c4c`
- Require a tag on resources (assigned twice - once per tag):
  `871b6d14-10aa-478d-b590-94f262ecfa99`
- Network interfaces should not have public IPs (fixed Deny effect):
  `83a86a26-fd1f-447c-b59d-e51f44264114`

**ACR: Basic SKU, no Private Endpoint.** Private Link for ACR requires
Premium. Pulls are secured with Azure AD RBAC (`AcrPull` on AKS's kubelet
identity and on the ACI backend's user-assigned identity) instead of the
admin user, which stays disabled.

**PostgreSQL: "Private access (VNet integration)" via a delegated subnet,
not the separate Private Endpoint feature.** Flexible Server's Private
Endpoint option only applies to servers otherwise created in public-access
mode - it adds a private front door in front of what is still, underneath,
a publicly-reachable server. VNet integration has no public path at all.
Both count as "private"; VNet integration is the stronger version of that,
so it's what's implemented here.

**AKS is a private cluster; that's a different thing from the ingress being
public.** "Private cluster" means the Kubernetes API server has no public
IP. A `Service` of `type: LoadBalancer` (what ingress-nginx uses) still
gets an ordinary public Standard Load Balancer IP, independent of that -
which is exactly why the end-to-end "public ingress IP" goal and the
"AKS must be private" requirement aren't in tension.

**Why there's a VM at all**: a private API server can't be reached from a
Microsoft-hosted pipeline agent (public Azure infra, outside your VNet). The
task notes call out "Virtual Machine" as an example dependent resource for
exactly this reason. `terraform/modules/agent-vm` is a small, NIC-has-no-
public-IP VM that self-registers as an Azure DevOps agent via the
run-command extension (no SSH needed to set it up).
