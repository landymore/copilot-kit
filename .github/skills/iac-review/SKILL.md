---
name: iac-review
description: "Review Terraform, Bicep, and related IaC for blast radius, secrets, identity, encryption, backups, and unsafe applies. Use when changing .tf, .tfvars, .bicep, .bicepparam, CloudFormation, or Helm."
---

# IaC review

Review the diff first. Do not run `terraform apply`, `terraform destroy`, or a deployment unless the user explicitly asks. Run `terraform plan`, `az deployment what-if`, or a change set only when the user asks and credentials already exist.

## Scope

1. Find changed `*.tf`, `*.tfvars`, `*.bicep`, `*.bicepparam`, CloudFormation templates, and Helm charts.
2. Identify the environment from the folder, workspace, backend, or resource group before judging risk.
3. Read the module or existing resource the change calls, not only the diff.
4. Production and anything that holds sensitive data get every security check. Dev and test can waive exposure, encryption, and backup only when the diff says so.

## Check

- **Blast radius.** Replacements, name changes, removed `prevent_destroy`, and deletes. Call out data stores, networks, and identity.
- **State.** Shared environments use a remote backend with locking. No committed `.tfstate` or plan files. No hard-coded resource IDs when a data source or output exists.
- **Secrets.** No passwords, keys, or connection strings in source, committed tfvars, parameter files, or outputs. Terraform sensitive variables use `sensitive = true`. Bicep sensitive parameters use `@secure()`. Prefer managed identity and a secret store over literals.
- **Identity.** OIDC or managed identity over long-lived keys. Flag `Owner`, `Contributor`, `*Admin`, or `*` actions unless the change justifies the scope.
- **Exposure.** Public IPs, `0.0.0.0/0`, public storage, disabled firewalls, and open management ports (22, 3389).
- **Encryption.** Data stores and disks encrypted at rest. TLS for external traffic. Flag a production data store with no encryption.
- **Backups.** Stateful production resources have a backup or recovery setting. Say if it is missing.
- **Logging.** Production changes that add a network, data store, or identity plane should not turn audit logs off.
- **Sources.** Pin modules to a version or commit. Flag a floating `ref=main`.
- **Bicep.** Correct `targetScope`. Use `existing` for resources this file does not own. No secret outputs.
- **Cost.** Note a production SKU in dev, or a missing autoscale on a variable workload. Do not block a review for cost alone unless the size is clearly wrong.
- **Hygiene.** Tags on taggable resources. `terraform fmt` or `bicep build` if the diff is unformatted. Unused variables are a request, not a block.

## Block or request

Block: hardcoded secrets, production data unencrypted, production management ports open to the world, or a wildcard identity grant with no justification.

Request changes: naming, tags, missing comments, unused variables, and cost notes.

## Output

One-line risk: safe, needs changes, or do not merge.

Then findings with file, the risky change, and a smaller alternative. Say whether a plan or what-if was run. If it was not, label the review static.
