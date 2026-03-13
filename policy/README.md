# ConductorTF Policy Module

## Introduction

This Terraform module facilitates the setup and management of policies in ConductorOne. It supports creating grant (request), revoke, and certify policy types with flexible multi-step approval workflows including user, group, manager, webhook, and on-call approvers. Conditional expression rules (CEL) are also supported.

## Usage

This is a technical reference. To utilize this module, or to **Add/Remove/Change** a policy, use the designated YAML files provided in your `conductorone/policies` folder. The YAML files are ingested by a root module that calls this module.

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `environment` | The deployment environment. | `string` | N/A |
| `policy_name` | Name of the policy. | `string` | N/A |
| `policy_description` | Description of the policy. | `string` | N/A |
| `policy_type` | Type of policy: `POLICY_TYPE_GRANT`, `POLICY_TYPE_REVOKE`, or `POLICY_TYPE_CERTIFY`. | `string` | N/A |
| `allow_decision_reassignment` | Whether decisions for this policy can be delegated. | `bool` | N/A |
| `fallback_user_ids` | Fallback approver user IDs (email addresses). | `list(string)` | `[]` |
| `require_decision_reassignment_reason` | Whether a reason is needed for reassigning a decision. | `bool` | `false` |
| `require_approval_reason` | Whether a reason is needed for approval. | `bool` | `false` |
| `approval_steps` | List of approval step objects. See below for structure. | `list(object)` | N/A |
| `post_exec_immediate_deprovision` | Immediately deprovision upon policy certification completion. | `bool` | `false` |
| `conductorone_directory_app_id` | The app ID for your IdP in ConductorOne. | `string` | N/A |
| `conductorone_service_account_id` | Service account user ID used as fallback approver. | `string` | N/A |
| `opsgenie_app_id` | App ID for OpsGenie in ConductorOne. Only required for Opsgenie On-Call approver type. | `string` | `""` |
| `all_entitlements` | Map of entitlement display names to IDs. | `any` | N/A |
| `all_webhooks` | Map of webhook display names to IDs. | `any` | `{}` |
| `all_schedules` | Map of schedule display names to IDs. Only required for Opsgenie On-Call approver type. | `any` | `{}` |
| `trigger` | An MD5 hash used to trigger Terraform on external data changes. | `string` | N/A |

## Approval Steps Configuration

The `approval_steps` variable is a list of objects, each defining one approval step:

- `approver_type` (string): `"User"`, `"Manager"`, `"Account Owner"`, `"Okta Group"`, `"Webhook"`, or `"Opsgenie On-Call"`
- `approver_name` (string, optional): Name of the approving group or schedule. Required for `"Okta Group"` and `"Opsgenie On-Call"`.
- `webhook_name` (string, optional): Display name of the webhook. Required for `"Webhook"` approver type.
- `enable_fallback_users` (bool): Whether to use fallback users if the primary approver is unavailable.
- `user_ids` (list(string), optional): Email addresses for `"User"` approver type.
- `fallback_user_ids` (list(string), optional): Email addresses of fallback approvers.
- `allow_self_review` (bool): Whether an approver can approve their own request.
- `allow_decision_reassignment` (bool): Whether this step's decision can be reassigned.
- `require_decision_reassignment_reason` (bool): Whether a reason is required for reassignment.
- `require_approval_reason` (bool): Whether a reason is required for approval.
- `expressions` (list(string), optional): CEL expressions for conditional policy routing.
- `expressions_match_action` (list(object), optional): Actions to take when expressions match.

## Expressions

Complex conditional rules may be attached to policies using Common Expression Language (CEL).

- [CEL Usage in C1 / Examples](https://www.conductorone.com/docs/product/manage-access/conditional-policies/)
- [CEL Evaluator with a C1 Example](https://playcel.undistro.io/?content=H4sIAAAAAAAAA61T72vbMBD9Vw5%2FKA0soYOygUthIUtgI1lDnTEK%2BXKWz841%2BmEkOV227n%2BfHCtN1jVsg32T7t7dezq9%2B54U6DFJE9fk9yR8utQAtTUlS9qdAbKmJrthZ%2Bz2xlao%2BRt6NjqFsa5gLtGXxirow8RiU3Qlwjg%2FIu3JpnB58WaH7MOcpUTrOkhBNVqvAih9Mc02qLml2ljvUrijp7irJW4%2FoaIUJrgmGKtami1RlyeFLFMoQ2ZAMfOOtfMoAt1AGLXHtbmWfrGt21aNlLBg9bxfydb5jm3K6xispMlRfjT5lDYU2N52YYkHaBNDRsRhfc76X4b9W1LG0z5Xsf4LqQo1VtRKjXQfdMEbLhqUMDLaW84bb%2Bwx2Ma28fZi10r50QpbBQujt5CZ2qI2VzDh4p4hYxXOc%2FRiBcMClbuC9w2Gh9XY1WsW65O%2FYMqSBY0kYegp6Oj%2FzC8OmmEtKQ%2Bo8CYxgCLHcIhSO7xnH4wImceyDBpL%2F4CWWsOwJopvbhzZ7hfHs%2Fn05m487uIPxq5DoW%2BCgYbC8yaoS14l9LW25FwQEGx%2FHn0%2FiJ4f7AjDmLQPs3Hny2SGYhXIlkkPHh%2Fhz%2FDpCeSJNfpftd32Jb0enJ0t9fMG%2BxHB9TUsk6cxJTvwbzM47OYxQxj6CXmHdT%2FGX178G%2Fx1i%2B8lP34C3Ou%2FF5MEAAA%3D)

## External Data

This module requires pre-loaded maps of ConductorOne resource data (`all_entitlements`, `all_webhooks`). These should be synced from the ConductorOne API and passed in from the root module.

## Examples

```hcl
module "policy" {
  source = "./modules/policy"

  environment                     = var.environment
  trigger                         = local.master_hash
  policy_type                     = "POLICY_TYPE_GRANT"
  policy_name                     = each.value.name
  policy_description              = each.value.description
  allow_decision_reassignment     = each.value.allow_decision_reassignment
  approval_steps                  = each.value.approval_steps
  conductorone_directory_app_id   = var.conductorone_directory_app_id
  conductorone_service_account_id = var.conductorone_service_account_id
  all_entitlements                = var.all_entitlements
  all_webhooks                    = var.all_webhooks
}
```

YAML file example:

```yaml
request_policy:
  -
    name: "Group-based Approval"
    description: "Simple group-based review and approval policy."
    allow_decision_reassignment: true

    approval_steps:
      - approver_type: "Okta Group"
        approver_name: "Team Infrastructure"
        enable_fallback_users: true
        fallback_user_ids: ["jane.doe@example.com"]
        allow_self_review: false
        allow_decision_reassignment: true
        require_decision_reassignment_reason: false
        require_approval_reason: false

      - approver_type: "Okta Group"
        approver_name: "Team Security"
        enable_fallback_users: true
        fallback_user_ids: ["john.doe@example.com"]
        allow_self_review: false
        allow_decision_reassignment: true
        require_decision_reassignment_reason: false
        require_approval_reason: false
```

Webhook approver example:

```yaml
    approval_steps:
      - approver_type: "Webhook"
        webhook_name: "My Approval Webhook"
        allow_decision_reassignment: false
        require_approval_reason: false
```

## Contributing

Contributions to this module are welcome. Please open an issue or pull request.
