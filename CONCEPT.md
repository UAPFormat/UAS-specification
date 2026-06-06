# UAS — Universal Agreement Schema

## Legal Data Layer for AI-Enabled Contract Creation, Review, Exchange, and Automation

Companion to the [specification](README.md) · part of the [UAPFormat](https://github.com/UAPFormat) ecosystem

---

## Concept

UAS, the Universal Agreement Schema, is a proposed structured data format for representing legal agreements as machine-readable, validated, and exchangeable agreement data.

The core idea is simple: a legal agreement should not exist only as a Word document, PDF, or scanned attachment. It should also exist as a canonical structured data object that captures the agreement’s identity, parties, subject, commercial terms, legal clauses, obligations, service levels, lifecycle rules, attachments, provenance, and references.

In this model, the human-readable contract is a rendered view of the structured agreement data. The structured UAS instance becomes the single source of truth, while DOCX, PDF, HTML, AI summaries, approval workflows, lifecycle dashboards, and obligation trackers become derived outputs.

UAS addresses the growing problem faced by enterprise and public-sector legal departments: legal documents are increasingly processed by AI systems, but the documents themselves remain inconsistent, unstructured, template-driven, and difficult for machines to interpret reliably. Different departments, suppliers, countries, and law firms use different templates for similar agreements. The same legal concept may appear under different headings, wording, numbering, and formatting. This increases lawyer workload, creates clause drift, weakens governance, and reduces the reliability of AI-assisted legal drafting and review.

UAS proposes a common expandable structure for agreements, similar in spirit to how e-invoicing standards transformed invoices from paper/PDF documents into structured business data. If two organizations agree on a shared semantic structure for an agreement type, they can exchange not only a signed PDF but also structured legal data that can be validated, compared, rendered, stored, searched, monitored, and consumed by IT systems.

UAS is therefore not intended to replace lawyers. It is intended to reduce repetitive legal work, improve consistency, support AI-assisted drafting and review, enable contract data exchange, and create a bridge from traditional human-readable agreements toward future machine-readable and machine-actionable contracts.

## The problem

The problem is not that legal teams lack templates. They have too many, and none of them are data.

| Current reality | Practical consequence |
|---|---|
| Contracts live as Word, PDF, scans, email attachments | No reliable machine understanding |
| Different templates for NDA, services, work order, employment, procurement | No unified structure |
| The same legal concept is worded differently in each template | Clause drift |
| Every new version is reviewed manually | Overburdened legal department |
| AI is run on unstructured prose | Hallucination, missed clauses, inconsistent output |
| Legal meaning is trapped in prose | Hard to integrate with ERP, procurement, CLM, CRM, data platforms |
| A contract is treated as a document, not data | No automated lifecycle, obligation tracking, or cross-organization exchange |

## Why now

AI can read a contract, but it is far more reliable when the input is structured. On raw prose, a model must *infer* who the parties are, who holds each obligation, what the deadline is, what the penalty is, which clause is standard and which was changed. UAS makes each of those an explicit, typed field, so the task shifts from "read 40 pages and guess" to "extract, validate and compare this document against a known profile and clause library." That is the difference between AI as a risk and AI as a control.

## From document to data — the value chain

UAS does not remove the lawyer. It moves the lawyer from repetitive reading to controlled review of what matters.

```
  Existing Word / PDF contract
        ↓  AI-assisted extraction
  UAS structured agreement instance
        ↓  schema + business-rule validation
  Legal review by exception / deviation
        ↓  approved clause-library binding
  Rendered DOCX / PDF for humans
        ↓  structured exchange with counterparty
  Obligation monitoring · ERP · procurement · CLM · UAPF processes
```

Three layers coexist, and UAS supports all three rather than pretending everything reduces to fields:

1. **Structured data** — parties, dates, prices, deadlines, obligations, service levels, governing law, notices.
2. **Controlled clause library** — standard, approved legal language, referenced and versioned.
3. **Free legal prose** — exceptional, negotiated or unusual wording that must remain as text.

## Value for legal departments

| Burden today | With UAS |
|---|---|
| Re-reading entire contracts | Review only deviations from the standard structure and clause library |
| Manually locating obligations | Obligations are typed fields |
| Comparing different templates | Normalize both documents to the same structure, then diff |
| Inconsistent AI summaries | AI works against a validated schema and profile |
| Re-keying contract data into CLM / ERP | The UAS instance is the system payload |
| Every department has its own template | Profiles provide controlled variation |
| Missed renewals and deadlines | Lifecycle fields feed reminders and workflows |
| SLA terms buried in annexes | `serviceLevels` becomes an executable matrix |
| Negotiation scattered across email | Versioned, structured changes in ProcessGit |

## Who it is for

- **Enterprise** — an internal legal data contract that standardizes agreements across legal, procurement, finance, sales, HR, IT and compliance systems.
- **Government** — a structured agreement layer for public-sector contracts, procurement orders, grants, framework agreements and service-level obligations, enabling validation, auditability, transparency and automated lifecycle monitoring.
- **AI** — a grounding structure for legal AI that reduces ambiguity by forcing extraction and generation into validated fields, profiles, clause references and rule-checked structures.
- **External exchange** — two organizations can exchange agreement *data* in a common semantic format, while still rendering it into traditional human-readable documents for review and signature.

## Agreement-as-Code

Because a UAS agreement is a structured text file, it is managed like source code in **ProcessGit**: each agreement is a versioned file, every change is a commit, negotiation happens on branches and pull requests, approval is a merge or signed tag, and the full history and audit trail is the Git log. Negotiation history therefore lives in the version-control layer; the instance itself carries only the current state plus light per-clause deviation and review metadata. Agreements are co-versioned with the UAPF process packages that consume them.

## Position among existing standards

UAS does not claim that legal markup did not exist. It occupies a deliberately different niche.

| Standard | Focus | UAS difference |
|---|---|---|
| Akoma Ntoso (OASIS) | Laws, judgments, parliamentary documents | Private and public **agreements / contracts** |
| LegalRuleML (OASIS) | Legal rules and reasoning | Agreement **data**: clauses, obligations, lifecycle |
| EN 16931 (CEN) | Invoice data exchange | **Agreement** data exchange |
| **UAS** | — | **AI-ready legal-document data layer for contracts** |

The defensible position: UAS is the contract/agreement semantic data layer — the missing counterpart to invoice standards for finance and legislative markup for law.

## What UAS is not

It is not a replacement for lawyers; it is a tool to remove repetition and surface exceptions. It is not a smart-contract or blockchain platform; it is the structured rung between prose contracts and machine-executable ones. It is not a legislative markup language; that ground is held by Akoma Ntoso. It does not assume every contract can become fully executable; structuring is gradual, which is why conformance is staged.

## Adoption model

Value starts inside one department, with no dependence on anyone else adopting it: UAS becomes the department’s structured clause library, validation layer and integration payload from day one. Conformance is staged so adoption can be incremental:

- **Level 1 — Structured.** Validates against schema and business rules. Storage, exchange, rendering.
- **Level 2 — Standardized.** Every clause references the library. Clause-level diffing and review-by-deviation.
- **Level 3 — Executable.** Computational terms and service levels fully populated. Automated obligation tracking and UAPF process consumption.

Adoption depends on tooling as much as on the schema. The intended ecosystem is an AI-assisted extractor (prose → UAS), a form/Word/CLM authoring surface, a validator (schema + business rules), and a renderer (UAS → DOCX/PDF). A reference editor already demonstrates the create → store → render → reopen loop.

## References

- CEN EN 16931 — semantic data model of the core elements of an electronic invoice.
- OASIS Akoma Ntoso — XML for parliamentary, legislative and judicial documents.
- OASIS LegalRuleML — machine-readable representation of legal normative rules.
