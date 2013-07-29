<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
                xmlns="http://www.openarchives.org/OAI/2.0/"
                xmlns:oai-identifier="http://www.openarchives.org/OAI/2.0/"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd"
                xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gml="http://www.opengis.net/gml" xmlns:gts="http://www.isotc211.org/2005/gts" xmlns:gmi="http://eden.ign.fr/xsd/isotc211/isofull/20090316/gmi/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template name="split_into_fields">
    <xsl:param name="text" select="."/>
    <xsl:param name="fieldName"/>

    <xsl:if test="string-length($text) > 0">
      <xsl:variable name="next" select=
        "substring-before(concat($text, ' > '), ' > ')"/>

      <xsl:element name="field">
        <xsl:attribute name="name">
          <xsl:value-of select="$fieldName"/>
        </xsl:attribute>
        <xsl:value-of select="$next"/>
      </xsl:element>

      <xsl:call-template name="split_into_fields">
        <xsl:with-param name="text" select=
          "substring-after($text, ' > ')"/>
        <xsl:with-param name="fieldName" select="$fieldName"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="/">
    <add>
      <xsl:for-each select=".//oai-identifier:metadata">
        <doc>
          <field name="authoritative_id">
            <xsl:value-of select="gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString"/>
          </field>
          <field name="title">
            <xsl:value-of select="gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString"/>
          </field>
          <field name="summary">
            <xsl:value-of select="gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract/gco:CharacterString"/>
          </field>
          <xsl:for-each select=".//gmd:MD_Keywords[.//gmd:MD_KeywordTypeCode='discipline']//gmd:keyword/gco:CharacterString">
            <xsl:call-template name="split_into_fields">
              <xsl:with-param name="text" select="."/>
              <xsl:with-param name="fieldName" select="'parameters'"/>
            </xsl:call-template>
            <field name="full_parameters">
              <xsl:value-of select="."/>
            </field>
          </xsl:for-each>
          <xsl:for-each select=".//gmd:MD_TopicCategoryCode">
            <field name="topics">
              <xsl:value-of select="."/>
            </field>
          </xsl:for-each>
          <xsl:for-each select=".//gmd:MD_Keywords[.//gmd:MD_KeywordTypeCode='theme' and not(.//gmd:thesaurusName)]//gmd:keyword/gco:CharacterString">
            <field name="keywords">
              <xsl:value-of select="."/>
            </field>
          </xsl:for-each>
          <xsl:for-each select=".//gmi:MI_Platform/gmi:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString">
            <field name="platforms">
              <xsl:value-of select="."/>
            </field>
          </xsl:for-each>
          <xsl:for-each select=".//gmi:MI_Instrument/gmi:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString">
            <field name="sensors">
              <xsl:value-of select="."/>
            </field>
          </xsl:for-each>
          <xsl:if test="count(gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:edition/gco:CharacterString) >1 ">
            <field name="_version_">
              <xsl:value-of select="gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:edition/gco:CharacterString"/>
            </field>
          </xsl:if>
          <xsl:if test="count(.//gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[gmd:CI_OnLineFunctionCode='offlineAccess']) &gt; 0">
            <field name="brokered">true</field>
          </xsl:if>
          <field name="published_date"><xsl:value-of select="gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:Date"/>T00:00:00Z</field>

          <!-- non-indexed fields -->
          <xsl:for-each select=".//gmd:EX_GeographicBoundingBox">
            <field name="spatial_coverages">
              <xsl:value-of select="gmd:northBoundingLatitude/gco:Decimal"/>,<xsl:value-of select="gmd:eastBoundingLongitude/gco:Decimal"/>,<xsl:value-of select="gmd:southBoundingLatitude/gco:Decimal"/>,<xsl:value-of select="gmd:westBoundingLongitude/gco:Decimal"/>
            </field>
          </xsl:for-each>
          <xsl:for-each select=".//gmd:EX_TemporalExtent">
            <field name="temporal_coverages">
              <xsl:value-of select=".//gml:beginPosition"/>,<xsl:value-of select=".//gml:endPosition"/>
            </field>
          </xsl:for-each>
          <xsl:for-each select=".//gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty[.//gmd:CI_RoleCode='custodian']/gmd:organisationName/gco:CharacterString">
            <field name="supporting_programs">
              <xsl:value-of select="."/>
            </field>
          </xsl:for-each>
          <xsl:for-each select="gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty[.//gmd:CI_RoleCode='principalInvestigator']//gmd:individualName/gco:CharacterString">
            <field name="authors">
              <xsl:value-of select="."/>
            </field>
          </xsl:for-each>
          <field name="last_revision_date">
            <xsl:value-of select=".//gmd:dateStamp/gco:Date"/>
          </field>
          <field name="dataset_url">
            <xsl:value-of select=".//gmd:dataSetURI"/>
          </field>
          <xsl:for-each select=".//gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[gmd:CI_OnLineFunctionCode='download']//gmd:URL/gco:CharacterString">
            <field name="data_access_urls">
              <xsl:value-of select="."/>
            </field>
          </xsl:for-each>
          <xsl:for-each select=".//gmd:MD_Format/gmd:name/gco:CharacterString">
            <field name="distribution_formats">
              <xsl:value-of select="."/>
            </field>
          </xsl:for-each>
          <xsl:if test="count(gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceSpecificUsage/gmd:MD_Usage/gmd:popularity/gco:Integer) > 0 ">
            <field name="popularity">
              <xsl:value-of select="gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceSpecificUsage/gmd:MD_Usage/gmd:popularity/gco:Integer"/>
            </field>
          </xsl:if>
          <field name="source">NSIDC</field>
          <field name="source">ADE</field>
        </doc>
      </xsl:for-each>
    </add>
  </xsl:template>

</xsl:stylesheet>