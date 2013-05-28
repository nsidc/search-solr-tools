<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
                xmlns="http://www.openarchives.org/OAI/2.0/"
                xmlns:oai-identifier="http://www.openarchives.org/OAI/2.0/"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd"
                xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gml="http://www.opengis.net/gml" xmlns:gts="http://www.isotc211.org/2005/gts" xmlns:gmi="http://eden.ign.fr/xsd/isotc211/isofull/20090316/gmi/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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
                    <xsl:if test="count(/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:edition/gco:CharacterString) >1 ">
                        <field name="_version_">
                            <xsl:value-of select="/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:edition/gco:CharacterString"/>
                        </field>
                    </xsl:if>
                    <field name="iso">
                        <xsl:text disable-output-escaping="yes"> &lt;![CDATA[</xsl:text>
                        <xsl:copy-of select="node() | @*"/>
                        <xsl:text disable-output-escaping="yes">]]&gt; </xsl:text>
                    </field>
                </doc>
            </xsl:for-each>
        </add>
    </xsl:template>

</xsl:stylesheet>