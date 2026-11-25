---
name: iac-review
description: "Review Terraform and Bicep changes for blast radius, secrets, identity, and unsafe applies. Use when changing .tf, .tfvars, .bicep, .bicepparam, or Terraform or Bicep module sources."
---

# IaC review (Terraform and Bicep)

Review the diff first. Do not run `terraform apply`, `terraform destroy`, or a Bicep deployment unless the user explicitly asks. Run `terraform plan` or `az deployment what-if` only when the user asks and credentials already exist.

## Scope

1. Find changed `*.tf`, `*.tfvars`, `*.bicep`, `*.bicepparam`, and module files.
2. Identify the environment from the folder, workspace, backend, or resource group before judging risk.
3. Read the module or existing resource the change calls, not only the diff.

## Check

- **Blast radius.** Replacements, name changes, removed `prevent_destroy`, and deletes. Call out data stores, networks, and identity.
- **State.** Shared environments use a remote backend. No committed `.tfstate` or plan files.
- **Secrets.** No passwords, keys, or connection strings in source, committed tfvars, or outputs. Prefer managed identity and a secret store over literals.
- **Identity.** OIDC or managed identity over long-lived keys. Flag `Owner`, `Contributor`, or `*Admin` unless the change justifies the scope.
- **Exposure.** Public IPs, `0.0.0.0/0`, public storage, disabled firewalls, and open management ports.
- **Sources.** Pin modules to a version or commit. Flag a floating `ref=main`.
- **Bicep.** Correct `targetScope`. Use `existing` for resources this file does not own. No secret outputs. Do not commit parameter files that hold secrets.

## Output

One-line risk: safe, needs changes, or do not merge.

Then findings with file, the risky change, and a smaller alternative. Say whether a plan or what-if was run. If it was not, label the review static.
