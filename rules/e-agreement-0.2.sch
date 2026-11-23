<?xml version="1.0" encoding="UTF-8"?>
<!-- SPDX-License-Identifier: Apache-2.0 -->
<!-- Copyright 2026 Algomation. Part of UAS (Universal Agreement Schema), UAPFormat. -->
<!--
  e-agreement 0.2 — business-rule layer (ISO Schematron, ISO/IEC 19757-3)
  Run with any ISO Schematron processor (lxml.isoschematron, Schxslt, Saxon, ph-schematron).
  This layer expresses the cross-field / semantic rules that XML Schema cannot.
-->
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron">
  <sch:title>e-agreement 0.2 business rules</sch:title>
  <sch:ns prefix="ea" uri="urn:eagreement:0.2"/>

  <sch:pattern id="core">
    <sch:rule context="ea:eAgreement">
      <sch:assert test="@version = '0.2'">BR-001: version MUST equal '0.2'.</sch:assert>
    </sch:rule>
    <sch:rule context="ea:parties">
      <sch:assert test="count(ea:party) &gt;= 1">BR-002: parties MUST contain at least one party.</sch:assert>
    </sch:rule>
    <sch:rule context="ea:party[ea:id]">
      <sch:assert test="count(//ea:party[ea:id = current()/ea:id]) = 1">BR-003: party id "<sch:value-of select="ea:id"/>" MUST be unique within the instance.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="references">
    <sch:rule context="ea:clause">
      <sch:assert test="not(ea:bearer) or //ea:party[ea:id = current()/ea:bearer]">BR-004: clause bearer "<sch:value-of select="ea:bearer"/>" MUST match a party id.</sch:assert>
      <sch:assert test="not(ea:beneficiary) or //ea:party[ea:id = current()/ea:beneficiary]">BR-004: clause beneficiary "<sch:value-of select="ea:beneficiary"/>" MUST match a party id.</sch:assert>
      <sch:assert test="ea:libraryRef or (ea:statement and normalize-space(ea:statement) != '')">BR-006: a clause MUST carry either a libraryRef or a non-empty statement.</sch:assert>
    </sch:rule>
    <sch:rule context="ea:class[ea:calendar]">
      <sch:assert test="//ea:calendar[ea:id = current()/ea:calendar]">BR-005: serviceLevel class calendar "<sch:value-of select="ea:calendar"/>" MUST match a calendar id.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="values">
    <sch:rule context="ea:constraints">
      <sch:assert test="not(ea:capOfContractValue) or (ea:capOfContractValue &gt;= 0 and ea:capOfContractValue &lt;= 1)">BR-007: capOfContractValue MUST be between 0 and 1.</sch:assert>
      <sch:assert test="not(ea:ratePerDay) or ea:ratePerDay &gt;= 0">BR-007: ratePerDay MUST be greater than or equal to 0.</sch:assert>
    </sch:rule>
    <sch:rule context="ea:class[ea:priority]">
      <sch:assert role="warning" test="count(../ea:class[ea:priority = current()/ea:priority]) = 1">BR-008: serviceLevel priority "<sch:value-of select="ea:priority"/>" SHOULD be unique.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- BR-009: profile-mandatory sections and roles. Add one rule per profile. -->
  <sch:pattern id="profile-nda">
    <sch:rule context="ea:eAgreement[@profile = 'nda']">
      <sch:assert test="ea:terms">BR-009 (nda): terms section is mandatory.</sch:assert>
      <sch:assert test="ea:parties/ea:party[ea:role = 'discloser']">BR-009 (nda): a party with role 'discloser' is required.</sch:assert>
      <sch:assert test="ea:parties/ea:party[ea:role = 'recipient']">BR-009 (nda): a party with role 'recipient' is required.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="profile-services">
    <sch:rule context="ea:eAgreement[@profile = 'services']">
      <sch:assert test="ea:subject">BR-009 (services): subject section is mandatory.</sch:assert>
      <sch:assert test="ea:commercials">BR-009 (services): commercials section is mandatory.</sch:assert>
      <sch:assert test="ea:terms">BR-009 (services): terms section is mandatory.</sch:assert>
      <sch:assert test="ea:parties/ea:party[ea:role = 'buyer']">BR-009 (services): a party with role 'buyer' is required.</sch:assert>
      <sch:assert test="ea:parties/ea:party[ea:role = 'supplier']">BR-009 (services): a party with role 'supplier' is required.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="profile-employment">
    <sch:rule context="ea:eAgreement[@profile = 'employment']">
      <sch:assert test="ea:subject and ea:commercials and ea:terms and ea:lifecycle">BR-009 (employment): subject, commercials, terms and lifecycle are mandatory.</sch:assert>
      <sch:assert test="ea:parties/ea:party[ea:role = 'employer']">BR-009 (employment): a party with role 'employer' is required.</sch:assert>
      <sch:assert test="ea:parties/ea:party[ea:role = 'employee']">BR-009 (employment): a party with role 'employee' is required.</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="governance">
    <sch:rule context="ea:clause[ea:riskLevel = 'high']">
      <sch:assert role="warning" test="ea:humanReviewedBy and normalize-space(ea:humanReviewedBy) != ''">BR-010: a high-risk clause SHOULD record humanReviewedBy.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- 0.2: source traceability. Every value points to the text unit it was taken from. -->
  <sch:pattern id="source">
    <sch:rule context="ea:sourceVri[/ea:eAgreement/ea:source/ea:documentVri]">
      <sch:let name="doc" value="normalize-space(/ea:eAgreement/ea:source/ea:documentVri)"/>
      <sch:assert test=". = $doc or starts-with(., concat($doc, '.')) or starts-with(., concat($doc, '@'))">BR-011: sourceVri "<sch:value-of select="."/>" MUST be the document VRI or one of its units.</sch:assert>
    </sch:rule>
    <sch:rule context="ea:clause[/ea:eAgreement/ea:source/ea:documentVri]">
      <sch:assert role="warning" test="ea:sourceVri">BR-012: a clause SHOULD carry sourceVri when the instance declares its source document.</sch:assert>
    </sch:rule>
    <sch:rule context="ea:constraints[ea:thresholdValue]">
      <sch:assert test="ea:thresholdUnit">BR-013: thresholdValue MUST have a thresholdUnit.</sch:assert>
      <sch:assert test="ea:thresholdUnit != 'percent' or (ea:thresholdValue &gt;= 0 and ea:thresholdValue &lt;= 100)">BR-013: a percent threshold MUST be between 0 and 100.</sch:assert>
    </sch:rule>
  </sch:pattern>

</sch:schema>
