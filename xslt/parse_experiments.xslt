<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">

	<xsl:output method="text"/>

	<xsl:template match="/">
		<xsl:apply-templates select="/experiments/experiment"/>
	</xsl:template>

<!--	<xsl:template match="provider">-->
<!--		<xsl:value-of select="contact" />-->
<!--			<xsl:text>,</xsl:text>-->
<!--		<xsl:value-of select="role" />-->
<!--			<xsl:text>,</xsl:text>-->
<!--		<xsl:value-of select="email" />-->
<!--		<xsl:if test="position() != last()">-->
<!--			<xsl:text>;</xsl:text>-->
<!--		</xsl:if>-->
<!--	</xsl:template>-->

	<xsl:template match="provider">
		<xsl:value-of select="normalize-space(contact)" />
		<xsl:if test="role">
			<xsl:text>,</xsl:text>
			<xsl:value-of select="normalize-space(role)" />
		</xsl:if>
		<xsl:if test="not(email='')">
			<xsl:text>,</xsl:text>
			<xsl:text>EMAIL:</xsl:text>
			<xsl:value-of select="normalize-space(email)" />
		</xsl:if>
		<xsl:if test="position() != last()">
			<xsl:text>;</xsl:text>
		</xsl:if>
	</xsl:template>




<!--	<xsl:template match="bibliography">-->
<!--		<xsl:value-of select="doi" />-->
<!--			<xsl:text>,</xsl:text>-->
<!--		<xsl:value-of select="accession" />-->
<!--		<xsl:if test="position() != last()">-->
<!--			<xsl:text>;</xsl:text>-->
<!--		</xsl:if>-->
<!--	</xsl:template>-->

	<xsl:template match="bibliography">
		<xsl:if test="doi">
			<xsl:text>DOI:</xsl:text>
			<xsl:value-of select="normalize-space(doi)" />
			<xsl:text>,</xsl:text>
		</xsl:if>
		<xsl:if test="accession">
			<xsl:text>PMID:</xsl:text>
			<xsl:value-of select="normalize-space(accession)" />
		</xsl:if>
		<xsl:if test="position() != last()">
			<xsl:text>;</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="bioassaydatagroup">
		<xsl:value-of select="normalize-space(name)" />
		<xsl:text>,</xsl:text>
		<xsl:value-of select="bioassays" />
		<xsl:if test="position() != last()">
			<xsl:text>;</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="experimenttype">
		<xsl:value-of select="normalize-space(.)" />
		<xsl:if test="position() != last()">
			<xsl:text>;</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="organism">
		<xsl:value-of select="normalize-space(.)" />
		<xsl:if test="position() != last()">
			<xsl:text>;</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="experiment">

		<xsl:value-of select="normalize-space(id)" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space(accession)" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space(releasedate)" />
		<xsl:text>&#x9;</xsl:text>
<!--		<xsl:value-of select="normalize-space(organism)" />-->
		<xsl:apply-templates select="organism"/>

		<xsl:text>&#x9;</xsl:text>
<!--		<xsl:value-of select="normalize-space(experimenttype)" />-->
		<xsl:apply-templates select="experimenttype"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:apply-templates select="provider"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:apply-templates select="bibliography"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:apply-templates select="bioassaydatagroup"/>

		<xsl:text>&#10;</xsl:text>
	</xsl:template>

</xsl:stylesheet>
