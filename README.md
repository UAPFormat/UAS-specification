# UAS — Universal Agreement Schema

## Legal Data Layer for AI‑Enabled Contract Creation, Review, Exchange, and Automation

**Agreement‑as‑Code: a structured, validated, exchangeable data representation of legal agreements.** See [CONCEPT.md](CONCEPT.md) for the concept and business description.

`version 0.1` · `status: draft / proposal` · `namespace: urn:eagreement:0.1` · `license: Apache-2.0 (schema) / CC-BY-4.0 (text)` · part of the [UAPFormat](https://github.com/UAPFormat) ecosystem

---

UAS is an open specification that represents a legal agreement as **structured data** instead of free‑form prose. From one canonical instance you can validate the agreement, render a finished human‑readable document, version it in Git, exchange it between organizations, and feed it into automated processes. The human‑readable contract becomes a *derived view* of the data, the same way an e‑invoice document is rendered from invoice data.

This repository contains the specification (this README), the normative XML Schema, the business‑rule layer, and conformant examples.

## Contents

1. [What UAS is](#1-what-uas-is)
2. [Agreement‑as‑Code and ProcessGit](#2-agreement-as-code-and-processgit)
3. [UAS in the UAPF ecosystem](#3-uas-in-the-uapf-ecosystem)
4. [Architecture](#4-architecture)
5. [Document structure](#5-document-structure)
6. [Document model](#6-document-model)
7. [Code lists](#7-code-lists)
8. [Identifiers and references](#8-identifiers-and-references)
9. [Clause library and binding](#9-clause-library-and-binding)
10. [Validation](#10-validation)
11. [Business rules](#11-business-rules)
12. [Profiles](#12-profiles)
13. [Conformance levels](#13-conformance-levels)
14. [Repository layout](#14-repository-layout)
15. [Getting started](#15-getting-started)
16. [Versioning](#16-versioning)
17. [License](#17-license)
18. [Contributing](#18-contributing)

---

## 1. What UAS is

A UAS instance is an XML document in the namespace `urn:eagreement:0.1`. It captures an agreement as nine typed sections — identity, provenance, parties, subject, commercials, terms, service levels, lifecycle, attachments — where every obligation, party, deadline, price and service target is a typed field rather than a paragraph.

The key words MUST, MUST NOT, REQUIRED, SHALL, SHOULD, SHOULD NOT and MAY are used as defined in RFC 2119. The authoritative grammar is [`schema/e-agreement-0.1.xsd`](schema/e-agreement-0.1.xsd); the cross‑field rules are in [`rules/e-agreement-0.1.sch`](rules/e-agreement-0.1.sch). Where prose and schema disagree, the schema prevails for structure and the business rules prevail for cross‑field constraints.

## 2. Agreement‑as‑Code and ProcessGit

Because a UAS agreement is a structured text file, it can be treated exactly like source code — **Agreement‑as‑Code**:

- **Storage** — each agreement is a file in a Git repository on **ProcessGit**, the version‑controlled platform of the UAPFormat ecosystem.
- **Change** — every edit is a commit; the full history, author, and rationale are the Git log. There is no "final.docx, final2.docx".
- **Negotiation** — drafting and counter‑drafting happen on branches and pull requests; the differences between two positions are a line‑level diff of typed terms, not a manual read‑through of two Word files.
- **Approval / signature** — acceptance is a merge or a signed tag; the approved revision is immutable and reproducible.
- **Co‑versioning** — agreements live alongside the UAPF process packages that consume them, so data and process evolve together under one history.

This turns contract management into a reviewable, auditable, reproducible pipeline, and is the practical bridge from human‑drafted contracts toward machine‑executable ones.

## 3. UAS in the UAPF ecosystem

UAPF (Unified Algorithmic Process Format) describes governed, machine‑executable **processes** — the control plane. UAS describes the **legal data** those processes act on — the data plane. The two are deliberately separate, following the principle that *a process is not its data*: a legal process (contract review, approval, lifecycle management, obligation monitoring) is one thing; the contracts that flow through it are another.

**Consequence for building legal processes:** a UAPF legal process can only consume an agreement that is a valid UAS instance. Any legal document entering such a process — a draft, a counterparty's paper, a scanned PDF — MUST first be:

1. **Converted** to a UAS instance (structured against this schema), and
2. **Validated** against the UAS schema and the business‑rule layer for the relevant profile,

before the process may act on it. UAS is therefore the **data contract at the boundary of every UAPF legal process** — both the gate (non‑conformant data is rejected) and the typed payload (conformant data is consumed).

The integration is concrete:

- A UAPF process package declares its inputs and outputs as UAS documents of a given profile.
- At execution, the runtime validates inputs (Section 10) before the first step runs.
- Clauses carrying `algorithmCardRef` bind to UAPF Algorithm Cards (e.g. a penalty or burn‑down computation).
- The `serviceLevels` matrix feeds UAPF decision tables and downstream ITSM tooling.

```
  INGEST            VALIDATE                     STORE                 CONSUME
  convert to   →    XSD + Schematron      →      Agreement‑as‑Code →   UAPF process
  UAS               (against profile)            in ProcessGit         package
```

## 4. Architecture

UAS is layered, following the EN 16931 pattern:

1. **Semantic layer** — the document model (Section 6), independent of syntax.
2. **Syntax layer** — the canonical XML binding. A JSON binding MAY be added later; XML is normative in 0.1.
3. **Validation layer** — XML Schema for structure plus ISO Schematron for business rules (Section 10).
4. **Rendering layer** — a deterministic template that maps an instance to a formatted document (DOCX/PDF/HTML).

The instance is the single source of truth; the document is always derived.

## 5. Document structure

Root element `eAgreement`, with `version` (REQUIRED, fixed `0.1`) and `profile` (OPTIONAL). Children, in order:

| # | Section | Element | Card. | Purpose |
|---|---------|---------|-------|---------|
| 0 | Identity | `identity` | 1 | Identification, type, status, lineage, signature |
| 1 | Provenance | `provenance` | 0..1 | Authority chain: procurement, funding, governing law |
| 2 | Parties | `parties` | 1 | Parties to the agreement, by reference |
| 3 | Subject | `subject` | 0..1 | What is agreed |
| 4 | Commercials | `commercials` | 0..1 | Price model, ceiling, payment terms |
| 5 | Terms | `terms` | 0..1 | Typed clauses (obligation / permission / prohibition) |
| 6 | Service levels | `serviceLevels` | 0..1 | Executable service / support matrix |
| 7 | Lifecycle | `lifecycle` | 0..1 | Term, amendment, notices, dispute, governing law |
| 8 | Attachments | `attachments` | 0..1 | Referenced annexes |

Element order MUST follow the schema sequence. An absent optional element means "not stated", never a default.

## 6. Document model

Cardinality: `1` mandatory single · `0..1` optional single · `1..*` mandatory repeating · `0..*` optional repeating.

### identity
`agreementType` (1, code), `title` (1), `language` (1, BCP‑47), `status` (1, code), `version` (0..1), `registrationNo` (0..1), `parent` (0..*: `id`, `relationship`, `label`), `signature` (0..1: `method` code, `executedAt` dateTime, `registrationNo`).

### provenance
`ocid` (0..1); `procurement` (0..1: `system`, `procedureId`, `frameworkAgreementId`, `positionId`, `orderId`, `cpv` 0..*); `fundingSources/fundingSource` (0..*: `instrument`, `projectId`, `title`); `normativeBasis/normativeReference` (0..*: `eli`, `label`, `version`).

### parties/party
`id` (0..1, local reference key), `role` (1..*, code), `legalName` (0..1), `registrationNo` (0..1), `identifierScheme` (0..1), `address` (0..1), `signatory` (0..1), `bank` (0..1: `name`,`bic`,`iban`), `contact` (0..1: `name`,`email`,`phone`).

### subject
`summary` (0..1), `system` (0..1), `works/work` (0..*: `no`, `name`).

### commercials
`currency` (0..1), `vatExcluded` (0..1, boolean), `pricing/priceLine` (0..*: `model` code, `unit`, `rate` decimal), `ceiling` (0..1: `unit`, `max` decimal), `paymentTerms` (0..1: `daysAfterInvoice` integer, `dayType` code).

### terms/clause
**Legal content:** `id` (0..1), `type` (1, code), `bearer` (0..1, →party id), `beneficiary` (0..1, →party id), `category` (0..1, code), `libraryRef` (0..1, `id@version`), `heading` (0..1), `statement` (0..1, MAY contain `{{bindings}}`), `trigger` (0..1), `constraints` (0..1), `consequence` (0..1), `algorithmCardRef` (0..1), `sourceClause` (0..1), `normativeRef` (0..1, anyURI).
`constraints` recognises `ratePerDay`, `capOfContractValue`, `deadlineValue`, `deadlineUnit`, and permits profile‑specific parameters via a `##other`‑namespace extension wildcard.

**Governance, review and extraction metadata** (all 0..1): `riskLevel` (code: low/medium/high), `fallbackPosition` (approved alternative clause/library ref), `negotiability` (code: non_negotiable/negotiable/business_approval), `ownerDepartment` (code), `approvalRequired` (who must approve a deviation), `jurisdiction` (country/legal system), `mandatoryByLaw` (boolean), `playbookRuleRef` (link to a legal playbook rule), `aiExtractionConfidence` (0–1, for prose→UAS extraction), `humanReviewedBy` (accountability), `sourceLocation` (`document`, `page`, `paragraph` in the original). These describe the clause for review and automation; they do not alter its legal substance.

### serviceLevels
`ticketingSystem` (0..1: `type`, `instanceRef`, `workflowIsBinding` boolean); `calendars/calendar` (0..*: `id`, `hours`, `days`); `classes/class` (0..*: `id`, `priority` integer, `label`, `calendar` →calendar id, `responseTarget`/`resolutionTarget` as `Duration`, `channels/channel` 0..*, `billing`, `notes`). `Duration` = `value` (decimal), `unit` (code), `note`.

### lifecycle
`effectiveFrom` (0..1); `term` (0..1: `max` integer, `unit`); `amendmentRule` (0..1); `noticeRules` (0..1: `registeredMailDeemedReceivedDays`, `electronicDeemedReceivedWorkingDays`); `disputeResolution` (0..1); `governingLaw` (0..1).

### attachments/attachment
`id` (0..1), `title` (1), `documentType` (0..1), `uri` (0..1, anyURI).

## 7. Code lists

- **AgreementType:** `framework_agreement`, `work_order`, `standalone_contract`, `amendment`, `annex`
- **Status:** `draft`, `offered`, `signed`, `active`, `suspended`, `terminated`, `completed`
- **PartyRole:** `party`, `buyer`, `supplier`, `discloser`, `recipient`, `employer`, `employee`, `lessor`, `lessee`, `responsible_person`, `subcontractor`, `supervisor`, `other`
- **DeonticType:** `obligation`, `permission`, `prohibition`
- **ClauseCategory:** `ip`, `confidentiality`, `warranty`, `termination`, `liability`, `compliance`, `payment`, `subcontracting`, `penalty`, `data_protection`, `other`
- **PricingModel:** `time_and_materials`, `fixed_price`, `subscription`
- **DayType:** `working`, `calendar`
- **DurationUnit:** `work_hour`, `work_day`, `calendar_hour`, `calendar_day`, `by_agreement`
- **SignatureMethod:** `qes`, `aes`, `wet_ink`, `unsigned`
- **RelationshipType:** `framework`, `amends`, `annex_of`, `supersedes`
- **RiskLevel:** `low`, `medium`, `high`
- **Negotiability:** `non_negotiable`, `negotiable`, `business_approval`
- **OwnerDepartment:** `legal`, `finance`, `hr`, `procurement`, `it`, `sales`, `compliance`, `other`

## 8. Identifiers and references

`party.id` values MUST be unique within an instance. `clause.bearer`, `clause.beneficiary` and `class.calendar` are intra‑document references that MUST resolve to an existing `party.id` / `calendar.id`. `libraryRef`, `algorithmCardRef`, `normativeRef` and `parent.id` are external references whose resolvability is out of scope for schema validation but SHOULD be resolvable by consumers. `libraryRef` has the form `<library-id>@<version>` (e.g. `lib.penalty.late@1.0`).

## 9. Clause library and binding

Standardization comes from a versioned **clause library**. Each entry has an identifier, a deontic `type`, a `category`, a default `heading`, and a prose **template**. A clause referencing an entry via `libraryRef` inherits its template; an inline `statement` overrides it.

Templates MAY contain binding tokens `{{path}}` resolved at render time:

| Token | Source |
|---|---|
| `{{party.<role>}}` | `legalName` of the first party with that role |
| `{{rate}}` | first `priceLine/rate` |
| `{{ceiling}}` | `ceiling/max` |
| `{{penaltyRate}}` | `constraints/ratePerDay` (as percent) |
| `{{penaltyCap}}` | `constraints/capOfContractValue` (as percent) |

An unresolved token MUST be rendered verbatim and flagged, never silently dropped. A clause counts as **standard** when `libraryRef` is present and no `statement` overrides it; the share of standard clauses is the instance's **standardization ratio**.

## 10. Validation

Validation is a **two‑stage pipeline**, because no single technology covers both structure and meaning:

**Stage 1 — Structure (XML Schema).** [`schema/e-agreement-0.1.xsd`](schema/e-agreement-0.1.xsd) checks element presence, ordering, datatypes, cardinality and code‑list membership. Any W3C XSD 1.0 processor works: `xmllint` (libxml2), Xerces, Saxon, or `lxml`.

**Stage 2 — Business rules (ISO Schematron).** [`rules/e-agreement-0.1.sch`](rules/e-agreement-0.1.sch) expresses the cross‑field and semantic constraints that XSD cannot — reference integrity, value ranges, uniqueness, and profile‑mandatory sections/roles. Schematron (ISO/IEC 19757‑3) states rules as XPath assertions and compiles to XSLT. Run it with any ISO Schematron implementation:

- **lxml** (`lxml.isoschematron`) — Python, used by this repo's checks
- **Schxslt** or the **ISO reference skeleton** — XSLT pipelines, CI‑friendly
- **Saxon** — XSLT 2.0/3.0
- **ph‑schematron** — Java/Maven

A **profile** is validated as: the base XSD + the profile's Schematron rules (Section 12). Profile‑specific rules are added as new Schematron patterns, not by changing the XSD.

> For a future JSON binding, the equivalent split is JSON Schema (structure) + a rule layer such as JSON Schema `if/then` or a rules engine; for RDF/semantic deployments, SHACL. Schematron is the normative business‑rule language for the XML binding in 0.1.

## 11. Business rules

A conformant instance MUST satisfy, beyond XSD validity:

- **BR‑001** `version` MUST equal `0.1`.
- **BR‑002** `parties` MUST contain at least one `party`.
- **BR‑003** `party.id` values MUST be unique.
- **BR‑004** every `clause.bearer` / `clause.beneficiary`, when present, MUST match some `party.id`.
- **BR‑005** every `class.calendar`, when present, MUST match some `calendar.id`.
- **BR‑006** a `clause` MUST carry either a `libraryRef` or a non‑empty `statement`.
- **BR‑007** `capOfContractValue` MUST be in `0`–`1`; `ratePerDay` MUST be ≥ `0`.
- **BR‑008** `class.priority` values SHOULD be unique (warning).
- **BR‑009** where a profile declares a section or role mandatory, it MUST be present.
- **BR‑010** a clause with `riskLevel` = `high` SHOULD record `humanReviewedBy` (warning).

## 12. Profiles

A profile is declared in the `profile` attribute and constrains the model for a document type **without changing the schema**.

| Profile | Mandatory sections (beyond identity, parties) | Mandatory roles |
|---|---|---|
| `core` | — | ≥ 1 party |
| `nda` | terms | discloser, recipient |
| `services` | subject, commercials, terms | buyer, supplier |
| `employment` | subject, commercials, terms, lifecycle | employer, employee |
| `procurement.work-order` | provenance, subject, commercials, serviceLevels | buyer, supplier |

New document types are added as new profiles (and, if needed, new code values) — never by forking the schema.

## 13. Conformance levels

- **Level 1 — Structured.** Validates against the XSD and the business rules. Sufficient for storage, exchange and rendering.
- **Level 2 — Standardized.** Level 1 plus every clause carries a `libraryRef` (standardization ratio 100%). Enables clause‑level diffing and review‑by‑deviation.
- **Level 3 — Executable.** Level 2 plus all computational terms and service‑level targets are fully populated. Enables automated obligation tracking and UAPF process consumption.

## 14. Repository layout

```
UAS-specification/
├── README.md                       this specification (CC-BY-4.0)
├── CONCEPT.md                      concept and business description (CC-BY-4.0)
├── CONTRIBUTING.md                 how to extend and contribute
├── LICENSE                         Apache License 2.0 (schema, rules, examples)
├── LICENSE-CC-BY-4.0               CC BY 4.0 (specification text)
├── NOTICE                          copyright and licensing notice
├── schema/
│   └── e-agreement-0.1.xsd         normative XML Schema (structure)
├── rules/
│   └── e-agreement-0.1.sch         ISO Schematron (business rules)
└── examples/
    ├── nda-minimal.xml             minimal 'nda' profile instance
    └── services-agreement.xml      generic 'services' profile instance
```

## 15. Getting started

Validate the structure with `xmllint`:

```bash
xmllint --noout --schema schema/e-agreement-0.1.xsd examples/services-agreement.xml
```

Validate structure + business rules with Python and `lxml`:

```python
from lxml import etree, isoschematron

xsd = etree.XMLSchema(etree.parse("schema/e-agreement-0.1.xsd"))
sch = isoschematron.Schematron(etree.parse("rules/e-agreement-0.1.sch"),
                               store_report=True)

doc = etree.parse("examples/services-agreement.xml")
assert xsd.validate(doc), xsd.error_log
assert sch.validate(doc), sch.validation_report
print("valid: structure + business rules")
```

## 16. Versioning

The namespace carries the major version (`urn:eagreement:0.1`). Backward‑compatible additions (new optional elements, code values, profiles) increment the minor version; breaking changes increment the namespace. Profile‑specific computational parameters extend `constraints` through the `##other`‑namespace wildcard, leaving the core stable.

## 17. License

Copyright 2026 Algomation.

| Content | Files | License |
| --- | --- | --- |
| Schema, business rules, examples | `schema/`, `rules/`, `examples/` | [Apache License 2.0](LICENSE) |
| Specification text | `README.md`, `CONCEPT.md` | [Creative Commons Attribution 4.0 International](LICENSE-CC-BY-4.0) |

Each schema, rule and example file carries an `SPDX-License-Identifier: Apache-2.0` header. See [NOTICE](NOTICE).

Anyone — public institutions, companies and individuals — may use, implement, modify and redistribute UAS under these terms, including in commercial and procurement contexts. Attribution: "UAS — Universal Agreement Schema, © Algomation, UAPFormat".

## 18. Contributing

This is a draft proposal (v0.1). Contributions are welcome — especially new profiles, code values, Schematron rules, the clause-library format and the JSON binding. Organisation-specific needs are added as profiles (named `org.<adopter>.<name>` until accepted), not by changing the core schema. See [CONTRIBUTING.md](CONTRIBUTING.md) for the process, the profile proposal checklist, conformance claims and contribution licensing.
