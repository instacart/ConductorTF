ConductorTF Terraform Configuration
===========================================

Introduction
------------

Welcome to the ConductorTF Terraform repository! This repository contains the configurations needed to manage Just-In-Time (JIT)
access to roles. This README will guide you through the structure of the modules, how to configure entitlements,
and how to modify or create new custom policies.

Repository Structure
--------------------

The repository has two very important folders to be aware of:

1.  **access**: Contains YAML files defining various user roles and their associated configurations.
2.  **policies**: Contains YAML files defining request policies used to control access approvals to the roles defined in the `access` folder.

Folder and File Overview
---------------

#### Access Folder

The `access` folder contains YAML files defining user roles and their configurations. Each role includes attributes such as name, description, catalog visibility, maximum duration grant, risk level, and associated policies.

**Example: `aws-users.yaml`**

```yaml
---
aws_user:
  - name: "AWS-Developer"
    description: 'AWS Developer role used by default for SWE. This is a baseline AWS role for all developers/software developers at Instacart...'
    catalog_visibility:
      - "Team Engineering"
      - "Team Excellence"
    maximum_duration_grant: "7776000s"
    risk_level: "Low"
    policy:
      request_policy: "Self Approval Request Policy"
      review_policy: "Self Certified Review Policy"
      revoke_policy: "Default Revoke Policy"
      emergency_grant_policy_enabled: False
      emergency_grant_policy_name: "EmergencyAccessPolicy:Self"
```

#### Definitions:
**Catalog**

An entitlement is visible to users within a specific Catalog, and our catalogs are configured so that
specific teams or job functions only see and request access to resources relevant to their roles.

**Maximum Duration Grant**

The maximum amount of time (in seconds) that a user can hold an entitlement before it expires,
requiring renewal. All access managed by ConductorOne is limited to 90 days (7776000s)
in order to avoid needing to perform quarterly access reviews.

**Risk Level**

ConductorOne has a Risk Level field which by itself doesn't do anything within the platform today. However, we
can utilize this field when doing other evaluations, such as when a task is being processed by a bot or
a webhook has been triggered.

**Policy Stanzas**

ConductorOne has built-in policies for approving access (e.g. one we use often is the built-in manager
approval policy). We can also write and manage our own custom policies, which are used fairly extensively.
Policy documents are stored in the `policies` folder; most of the good stuff is located in `policies/request-policies.yaml`.
See the following section for a deep dive on policies.

#### Policies Folder

The `policies` folder contains YAML files defining request policies. These policies control how access requests are approved and processed.

**Example: `request-policies.yaml`**

```yaml
---
request_policy:
  - name: "AccessPolicy:Okta:AWS-Analyst"
    workflow_approvers: [ "john.doe@instacart.com" ]
    description: "AccessPolicy:Okta:AWS-Analyst. [tf]"
    allow_decision_reassignment: true
    approval_steps:
      - approver_type: "Expression"
        expressions: [ 'subject.profile.email.contains("michael.jackson@instacart.com") || subject.profile.email.contains("janet.jackson@instacart.com")' ]
        expressions_match_action:
          - approver_type: "Auto-Approve"
      - approver_type: "Okta Group"
        approver_name: "Cloud Engineers"
        enable_fallback_users: false
        allow_self_review: false
        allow_decision_reassignment: true
        require_decision_reassignment_reason: false
        require_approval_reason: false

  - name: "EmergencyAccessPolicy:Okta:AWS-Analyst"
    workflow_approvers: [ "miley.cyrus@instacart.com" ]
    description: "Grants emergency access for the AWS Analyst role utilized by employees. [tf]"
    allow_decision_reassignment: true
    approval_steps:
      - approver_type: "Okta Group"
        approver_name: "Cloud Engineers"
        enable_fallback_users: false
        allow_self_review: true
        allow_decision_reassignment: true
        require_decision_reassignment_reason: false
        require_approval_reason: true
```

In this policy, which is attached to the AWS-Analyst entitlement, we have two workflows defined: a standard access policy, and an emergency
access policy.

In the standard access policy, we are doing a custom CEL expression
([ConductorOne's flavor of CEL documented here](https://www.conductorone.com/docs/product/manage-access/conditional-policies/)) to check
and see if the requestor is either Miley or Michael, who are two members of a leadership team. If that
condition is satisifed, the evaluation will immediately return an approval and stop evaluating further conditions. If the requestor is
not one of those two people, it will go on to the next stanza, which says that the request will need to be approved by a member of the
`Cloud Engineers` Okta group. `allow_self_review` is `false`, meaning that even if the requester is already in that group,
some other member of it will need to review and approve.

Entitlements can be configured with a specific workflow to run if the user clicks the 'Emergency Access' button (which is
configurable on a per-entitlement basis). The normal emergency access flow grants instant access to the requestor without
any approval steps. Most users enable this option very sparingly.

Finally, CEL is hard to get right on the first try and extraordinarily challenging to debug. [We recommend you test your
expressions in the CEL Playground.](https://playcel.undistro.io/?content=H4sIAAAAAAAAA61T72vbMBD9Vw5%2FKA0soYOygUthIUtgI1lDnTEK%2BXKWz841%2BmEkOV227n%2BfHCtN1jVsg32T7t7dezq9%2B54U6DFJE9fk9yR8utQAtTUlS9qdAbKmJrthZ%2Bz2xlao%2BRt6NjqFsa5gLtGXxirow8RiU3Qlwjg%2FIu3JpnB58WaH7MOcpUTrOkhBNVqvAih9Mc02qLml2ljvUrijp7irJW4%2FoaIUJrgmGKtami1RlyeFLFMoQ2ZAMfOOtfMoAt1AGLXHtbmWfrGt21aNlLBg9bxfydb5jm3K6xispMlRfjT5lDYU2N52YYkHaBNDRsRhfc76X4b9W1LG0z5Xsf4LqQo1VtRKjXQfdMEbLhqUMDLaW84bb%2Bwx2Ma28fZi10r50QpbBQujt5CZ2qI2VzDh4p4hYxXOc%2FRiBcMClbuC9w2Gh9XY1WsW65O%2FYMqSBY0kYegp6Oj%2FzC8OmmEtKQ%2Bo8CYxgCLHcIhSO7xnH4wImceyDBpL%2F4CWWsOwJopvbhzZ7hfHs%2Fn05m487uIPxq5DoW%2BCgYbC8yaoS14l9LW25FwQEGx%2FHn0%2FiJ4f7AjDmLQPs3Hny2SGYhXIlkkPHh%2Fhz%2FDpCeSJNfpftd32Jb0enJ0t9fMG%2BxHB9TUsk6cxJTvwbzM47OYxQxj6CXmHdT%2FGX178G%2Fx1i%2B8lP34C3Ou%2FF5MEAAA%3D)

Configuring Entitlements
------------------------

To configure an entitlement:

1.  **Navigate to the `access` folder**:

    -   Open the relevant YAML file (e.g., `aws-users.yaml`).
2.  **Add or modify an entitlement**:

    -   Use the existing format to define a new role or modify an existing one.
    -   Ensure all necessary attributes are included:
        -   `name`: The name of the role.
        -   `description`: A detailed description of the role and its privileges.
        -   `catalog_visibility`: Teams that can see this role.
        -   `maximum_duration_grant`: The maximum duration for which access can be granted (in seconds).
        -   `risk_level`: The risk level associated with the role.
        -   `policy`: Associated policies for request, review, and revoke.
3.  **Save the changes and issue a PR**.

Modifying or Creating Custom Policies
-------------------------------------

To modify or create a custom policy:

1.  **Navigate to the `policies` folder**:

    -   Open the relevant YAML file (e.g., `request-policies.yaml`).
2.  **Add or modify a policy**:

    -   Use the existing format to define a new policy or modify an existing one.
    -   Ensure all necessary attributes are included:
        -   `name`: The name of the policy.
        -   `workflow_approvers`: List of approvers.
        -   `description`: A detailed description of the policy.
        -   `allow_decision_reassignment`: Boolean indicating if decision reassignment is allowed.
        -   `approval_steps`: Define the steps required for approval, including `approver_type`, `expressions`, and `expressions_match_action`.
3.  **Save the changes and issue a PR**.
