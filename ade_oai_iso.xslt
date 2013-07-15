<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet
version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:dm="http://floraresearch.eu/sdi/services/7.0/dataModel/schema"
xmlns:gml="http://www.opengis.net/gml"
xmlns:gml32="http://www.opengis.net/gml/3.2"
xmlns:gmd="http://www.isotc211.org/2005/gmd"
xmlns:gco="http://www.isotc211.org/2005/gco"
xmlns:atom="http://www.w3.org/2005/Atom"
xmlns:georss="http://www.georss.org/georss/"
xmlns:srv="http://www.isotc211.org/2005/srv"
xmlns:flr="http://eu.floraresearch"
xmlns:ical="http://www.w3.org/2002/12/cal/ical#"
xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <xsl:template match="/">
    <add>
      <xsl:for-each select=".//gmd:MD_Metadata">
        <doc>
          <field name="authoritative_id">
            <xsl:value-of select="gmd:fileIdentifier/gco:CharacterString"/>
          </field>
          <field name="title">
            <xsl:value-of select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString"/>
          </field>
          <xsl:comment>
            <!-- check whether element exist http://stackoverflow.com/questions/825831/check-if-a-string-is-null-or-empty-in-xslt -->
          </xsl:comment>
          <xsl:choose>
            <xsl:when test="count(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue='creator']) = 0">
              <field name="authors">unknown</field>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each  select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue='creator']/gmd:individualName">
                <xsl:choose>
                  <xsl:when test="gco:CharacterString != ''">
                    <field name="authors">
                      <xsl:value-of select="gco:CharacterString"/>
                    </field>
                  </xsl:when>
                  <xsl:otherwise>
                    <field name="authors">unknown</field>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>

          <field name="summary">
            <xsl:value-of  select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract/gco:CharacterString"/>
          </field>
          <field name="parameters">
          </field>
          <field name="topics">
          </field>
          <xsl:for-each select=".//gmd:MD_Keywords">
            <field name="keywords">
              <xsl:value-of select="gmd:keyword"/>
            </field>
          </xsl:for-each>
          <field name="platforms">
          </field>
          <field name="sensors">
          </field>
          <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue='publisher']/gmd:organisationName/gco:CharacterString">
            <field name="data_centers">
              <xsl:value-of select="."/>
            </field>
          </xsl:for-each>
          <field name="last_revision_date">
            <xsl:value-of select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:Date"/>
          </field>
          <field name="dataset_url">
            <xsl:value-of select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:supplementalInformation/gco:CharacterString"/>
          </field>
          <field name="source">ADE</field>
        </doc>
      </xsl:for-each>
    </add>
  </xsl:template>
</xsl:stylesheet>
