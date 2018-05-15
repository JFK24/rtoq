<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">

	<xsl:output method="text"/>

	<xsl:template match="/">
		<xsl:apply-templates select="/experiments/experiment"/>
	</xsl:template>

	<xsl:template name="process_bibliography">
		<xsl:param name="current_id"/>
		<xsl:param name="current_accession"/>
		<xsl:value-of select="$current_id" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="$current_accession" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="accession" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="doi" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="year" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="publication" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="volume" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="issue" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="pages" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="authors" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="title" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="status" />
	</xsl:template>

	<xsl:template match="experiment">
		<xsl:for-each select="bibliography">
			<xsl:call-template name="process_bibliography">
				<xsl:with-param name="current_id"             select="normalize-space(../id)"/>
				<xsl:with-param name="current_accession"      select="normalize-space(../accession)"/>
			</xsl:call-template>
			<xsl:text>&#10;</xsl:text>
		</xsl:for-each>

	</xsl:template>

</xsl:stylesheet>
