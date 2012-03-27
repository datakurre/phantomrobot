<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template match="title|h1|h2|p|th|tr|td|a"/>
<xsl:template match="/html/body/b|/html/body/text()"/>

<xsl:template match="table[last()]/tr">
<xsl:for-each select="td">

<xsl:if test="position()=1">
<xsl:apply-templates select="node()"/>
</xsl:if>

<xsl:if test="position()=2">
<xsl:text> *(</xsl:text><xsl:apply-templates select="node()"/><xsl:text>)*</xsl:text>
</xsl:if>

<xsl:if test="position()=3">
<xsl:choose>
<xsl:when test="string-length(normalize-space(node()))>3">
<xsl:text>
    </xsl:text><xsl:apply-templates select="node()"/>
</xsl:when>
<xsl:otherwise>
<xsl:text>
    n/a</xsl:text>
</xsl:otherwise>
</xsl:choose>
<xsl:text>

</xsl:text>
</xsl:if>

</xsl:for-each>
</xsl:template>

<xsl:template match="i">
<xsl:text> *</xsl:text><xsl:value-of select="text()"/><xsl:text>* </xsl:text>
</xsl:template>

<xsl:template match="b">
<xsl:text> **</xsl:text><xsl:value-of select="text()"/><xsl:text>** </xsl:text>
</xsl:template>

<!-- Filtering identity templates -->
<xsl:template match="text()">
  <xsl:if test="string-length(normalize-space(.))>3">
    <xsl:value-of select="normalize-space(.)" />
  </xsl:if>
</xsl:template>

<!-- Define technical details for the output -->
<xsl:output method="text" mediatype="text/plain" encoding="UTF-8" />

</xsl:stylesheet>
