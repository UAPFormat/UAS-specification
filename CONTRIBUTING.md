# Contributing to UAS — Universal Agreement Schema

UAS is an open specification. Public institutions, companies and individuals are welcome to use it, adapt it and contribute back. This document explains how to extend UAS without breaking interoperability, and how to propose changes to the official specification.

## 1. What we welcome

- **Profiles** for new agreement types (e.g. works, supply, easement, grid connection, balancing, lease, data processing).
- **Code values** for existing code lists (e.g. new `ClauseCategory` or `PartyRole` values).
- **Business rules** (ISO Schematron patterns), including profile-specific rules.
- **Examples** — validating instances for existing or proposed profiles.
- **Specification work** — the clause-library format, the JSON binding, clarifications, corrections, translations of the specification text.
- **Tooling** — validators, converters (prose → UAS, UAS → document), rendering templates.

## 2. Principles: extend, don't fork the core

UAS is only useful if agreements stay exchangeable between organisations. Please follow these rules, whether you contribute upstream or keep a private adaptation.

1. **Use profiles for organisation- or domain-specific needs.** A profile constrains the model (mandatory sections, roles, rules) without changing the XSD. See README §12.
2. **Use the `constraints` extension point** (`##other` namespace) for profile-specific computational parameters. Do not add elements to the core schema for them.
3. **Do not change the core schema in a private copy while keeping the UAS namespace.** If you must change the core structure, use your own namespace (not `urn:eagreement:0.1`) so your documents are not mistaken for UAS instances — and consider proposing the change here instead.
4. **Name adopter profiles by owner until accepted.** Use `org.<adopter>.<name>` (e.g. `org.example.works`). When a profile is accepted into the official list, it receives an unprefixed name (e.g. `works`) and the prefixed name remains documented as an alias.
5. **Never put real agreements or personal data in examples.** Examples must be synthetic. Do not include real party names, registration numbers, bank details, signatures or contact data.

## 3. How to contribute

1. **Open an issue first** for anything beyond a small fix: describe the need, the agreement type and who uses it.
2. **Fork and create a branch** from `main`.
3. **Make the change** following section 4 (profile) or section 5 (code values) where relevant.
4. **Validate** every example you add or change (section 6).
5. **Sign off your commits** (Developer Certificate of Origin, section 8): `git commit -s`.
6. **Open a pull request** that references the issue and explains what changes and why.

Small fixes (typos, broken links, clarifications that do not change meaning) can go directly to a pull request.

## 4. Proposing a profile

A profile proposal is complete when the pull request contains:

| Item | Content |
| --- | --- |
| Profile name | `org.<adopter>.<name>` until accepted |
| Agreement type | What kind of agreement it covers and in which context |
| Mandatory sections | Beyond `identity` and `parties` |
| Mandatory roles | e.g. `buyer`, `supplier` |
| Business rules | Schematron patterns for the profile (in `rules/`, one pattern per rule, with a rule ID) |
| Code values | Any new values needed, with definitions (section 5) |
| Example | At least one validating, synthetic instance in `examples/` |
| Rationale | Why existing profiles are not sufficient; known adopters |

Profile rules are added as new Schematron patterns. They must not change the behaviour of existing profiles.

## 5. Proposing code values

For each new value give: the code list, the value (lower-case, `snake_case`), a one-sentence definition, and an example of use. New values are backward-compatible additions and increment the minor version (README §16). Values are never removed; obsolete values are marked deprecated in the specification text.

## 6. Validation

Every example must pass both stages:

```python
from lxml import etree, isoschematron

xsd = etree.XMLSchema(etree.parse("schema/e-agreement-0.1.xsd"))
sch = isoschematron.Schematron(etree.parse("rules/e-agreement-0.1.sch"), store_report=True)

doc = etree.parse("examples/<your-example>.xml")
assert xsd.validate(doc), xsd.error_log
assert sch.validate(doc), sch.validation_report
```

or with `xmllint --noout --schema schema/e-agreement-0.1.xsd examples/<your-example>.xml` for the structural stage.

## 7. Conformance claims

An instance, product or process may be described as **"UAS-conformant"** only if its documents validate against the official XSD and Schematron of the stated version. State the level and profile, e.g. *"UAS 0.1, Level 1, profile `services`"* (conformance levels: README §13).

An adaptation that changes the core schema is not UAS-conformant. It may be described as "based on UAS".

## 8. Licensing of contributions

By contributing you agree that your contribution is licensed under the same terms as the part of the repository it changes:

- schema, business rules, examples and tooling — **Apache License 2.0** (`LICENSE`);
- specification text — **Creative Commons Attribution 4.0 International** (`LICENSE-CC-BY-4.0`).

Contributions are accepted under the **Developer Certificate of Origin 1.1** (https://developercertificate.org). Signing off a commit (`Signed-off-by: Name <email>`, added by `git commit -s`) certifies that you have the right to submit the work under these licences. If you contribute on behalf of an organisation, make sure you are authorised to do so.

## 9. Adapting UAS privately

You may use and modify UAS without contributing back. If you distribute an adapted version, keep the `LICENSE`, `LICENSE-CC-BY-4.0` and `NOTICE` files, keep the copyright notice (© Algomation), and mark the files you changed. Do not present an adapted version as the official UAS.

## 10. Review and versioning

Pull requests are reviewed by the UAPFormat maintainers against these criteria: interoperability with existing profiles, validating examples, clear definitions, and no personal or confidential data. Backward-compatible changes (new optional elements, code values, profiles) increment the minor version; breaking changes increment the namespace (README §16).

## 11. Conduct

Be respectful and constructive. Discussions focus on the specification, its use cases and its correctness.

## 12. Contact

Use GitHub issues for questions, proposals and bug reports.
