# ConductorTF Policy Module

## Introduction

This Terraform module is designed to facilitate the setup and management of policies in ConductorOne. It allows for the creation of detailed policy configurations that determine how approvals are handled within your organization. Supported policy types include granting, revoking, and certifying access, each with customizable approval workflows.

## Usage

This is a technical reference. To utilize this module, or to **Add/Remove/Change** a policy, please instead use the designated YAML files provided in the `conductorone/policies` folder. The YAML files are ingested by this module. 

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `environment` | The deployment environment. This is derived by Atlantis. | `string` | N/A |
| `policy_name` | Name of the Policy. A list of templates is available. See go/c1 | `string` | N/A |
| `policy_description` | Description of the Policy. Ex. 'This policy requires review from someone within A,B,C Okta Groups before being granted.' | `string` | N/A |
| `policy_type` | The type of policy (`POLICY_TYPE_GRANT`, `POLICY_TYPE_REVOKE`, `POLICY_TYPE_CERTIFY`). |
| `allow_decision_reassignment` | Whether decisions for this policy can be delegated. | `bool` | N/A |
| `fallback_user_ids` | User IDs that can serve as fallback approvers over the entire policy. Step-based fallback users can be declared in `approval_steps`. These are Okta e-mail addresses. | `string` | N/A |
| `require_decision_reassignment_reason` | Whether a reason is needed for reassigning a decision over the entire policy. Decision reassignment reasoning can also be required per step under `approval_steps`. | `bool` | False |
| `require_approval_reason` | Whether a reason is needed for approval over the entire policy. Approval reasoning can also be declared per step under `approval_steps`. | `bool` | False |
| `approval_steps` | A list detailing the steps required for approval. See below for structure details. | `list(object({...})` | N/A
| `post_exec_immediate_deprovision` | Option for immediate deprovisioning upon policy certification. | `bool` | False
| `conductorone_directory_app_id` | The app ID to the IdP assigned within ConductorOne, this is derived by the `environment` variable. | `string` | N/A |
| `trigger` | An MD5 hash used to trigger Terraform on changes. | `string` | N/A
| `conductorone_service_account_id` | Service account ID used in ConductorOne. This is derived by the `environment` variable. | `string` | N/A |

## Approval Steps Configuration

The `approval_steps` variable consists of a list of objects, each detailing an approval step within a single policy process. Below is the structure for each object within the list:

- `approver_type` (string): The type of approver: "User", "Manager", "Okta Group", "Account Owner" (Self).
- `approver_name` (string, optional): The name of the approver. Relevant for types like "Okta Group" where a specific group name is required.
- `enable_fallback_users` (bool): Whether to enable fallback users in case the primary approver is unavailable.
- `user_ids` (list(string), optional): Specific user IDs for when the approver type is "User". These are typically e-mail addresses.
- `fallback_user_ids` (list(string), optional): IDs of users to be used as fallback approvers.
- `allow_self_review` (bool): Indicates whether an approver can approve their own request.
- `allow_decision_reassignment` (bool): Whether decision-making can be reassigned to a different approver.
- `require_decision_reassignment_reason` (bool): Whether a reason is required when reassigning the decision.
- `require_approval_reason` (bool): Whether a reason is required for approval.
- `expressions` (list(string), optional): A list of expressions used for determining approval in more complex scenarios.

## Expressions

Complex conditional rules may be attached to Policies in the form of `Expressions`. These statements are constructed using Common Expression Language (CEL). Use the reference links below or reach out to a member of the Security team for additional assistance.

- [CEL Usage in C1 / Examples](https://www.conductorone.com/docs/product/manage-access/conditional-policies/)
- [CEL Evaluator with a C1 Example](https://playcel.undistro.io/?content=H4sIAAAAAAAAA61T72vbMBD9Vw5%2FKA0soYOygUthIUtgI1lDnTEK%2BXKWz841%2BmEkOV227n%2BfHCtN1jVsg32T7t7dezq9%2B54U6DFJE9fk9yR8utQAtTUlS9qdAbKmJrthZ%2Bz2xlao%2BRt6NjqFsa5gLtGXxirow8RiU3Qlwjg%2FIu3JpnB58WaH7MOcpUTrOkhBNVqvAih9Mc02qLml2ljvUrijp7irJW4%2FoaIUJrgmGKtami1RlyeFLFMoQ2ZAMfOOtfMoAt1AGLXHtbmWfrGt21aNlLBg9bxfydb5jm3K6xispMlRfjT5lDYU2N52YYkHaBNDRsRhfc76X4b9W1LG0z5Xsf4LqQo1VtRKjXQfdMEbLhqUMDLaW84bb%2Bwx2Ma28fZi10r50QpbBQujt5CZ2qI2VzDh4p4hYxXOc%2FRiBcMClbuC9w2Gh9XY1WsW65O%2FYMqSBY0kYegp6Oj%2FzC8OmmEtKQ%2Bo8CYxgCLHcIhSO7xnH4wImceyDBpL%2F4CWWsOwJopvbhzZ7hfHs%2Fn05m487uIPxq5DoW%2BCgYbC8yaoS14l9LW25FwQEGx%2FHn0%2FiJ4f7AjDmLQPs3Hny2SGYhXIlkkPHh%2Fhz%2FDpCeSJNfpftd32Jb0enJ0t9fMG%2BxHB9TUsk6cxJTvwbzM47OYxQxj6CXmHdT%2FGX178G%2Fx1i%2B8lP34C3Ou%2FF5MEAAA%3D)

## Resources

This module creates and manages `conductorone_policy` resources tailored for revoke, certify, and request policies according to the given configurations.

## Examples

```hcl
module "policy" {
  source                          = "../_modules/conductorone/policy"
  environment                     = var.environment
  trigger                         = local.master_hash
  policy_type                     = "POLICY_TYPE_GRANT"
  policy_name                     = each.value.name
  policy_description              = each.value.description
  allow_decision_reassignment     = each.value.allow_decision_reassignment
  approval_steps                  = each.value.approval_steps
  conductorone_directory_app_id   = var.conductorone_directory_app_id
  conductorone_service_account_id = var.conductorone_service_account_id
}
```

YAML file example :

```yaml
request_policy:
  - 
    name: "Group-based Approval"
    description: "This template can be re-used for a simple group-based review and approval. [tf]"
    allow_decision_reassignment: true

    approval_steps:
      -   approver_type: "Okta Group"
          approver_name: "Team Infrastructure"
          enable_fallback_users: true
          fallback_user_ids: [ "jane.doe@instacart.com" ]
          allow_self_review: false
          allow_decision_reassignment: true
          require_decision_reassignment_reason: false
          require_approval_reason: false

      -   approver_type: "Okta Group"
          approver_name: "Dept Eng - Security"
          enable_fallback_users: true
          fallback_user_ids: [ "john.doe@instacart.com", "george.washington@instacart.com" ]
          allow_self_review: false
          allow_decision_reassignment: true
          require_decision_reassignment_reason: false
          require_approval_reason: false
```

## External Sources

This module is currently dependent upon external data sources from ConductorOne which pull and store data into Confs. The following json files must be up-to-date to ensure successful policy deployment.

See `c1-data-sync.sh`

- c1-data-sync-catalogs.json
- c1-data-sync-entitlements.json
- c1-data-sync-policies.json

## Contributing

Contributions to this module are welcome.
