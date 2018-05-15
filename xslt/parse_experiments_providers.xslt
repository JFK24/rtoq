<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">

	<xsl:output method="text"/>

	<xsl:template match="/">
		<xsl:apply-templates select="/experiments/experiment"/>
	</xsl:template>

	<xsl:template name="process_provider">
		<xsl:param name="current_id"/>
		<xsl:param name="current_accession"/>
		<xsl:param name="current_releasedate"/>
		<xsl:param name="current_organism"/>
		<xsl:param name="current_experimenttype"/>
		<xsl:value-of select="$current_id" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="$current_accession" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="$current_releasedate" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="$current_organism" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="$current_experimenttype" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="contact" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="role" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="email" />
	</xsl:template>

	<xsl:template match="experiment">
		<xsl:for-each select="provider">
			<xsl:call-template name="process_provider">
				<xsl:with-param name="current_id"             select="normalize-space(../id)"/>
				<xsl:with-param name="current_accession"      select="normalize-space(../accession)"/>
				<xsl:with-param name="current_releasedate"    select="normalize-space(../releasedate)"/>
				<xsl:with-param name="current_organism"       select="normalize-space(../organism)"/>
				<xsl:with-param name="current_experimenttype" select="normalize-space(../experimenttype)"/>
			</xsl:call-template>
			<xsl:text>&#10;</xsl:text>
		</xsl:for-each>

	</xsl:template>

</xsl:stylesheet>
