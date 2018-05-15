<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">
<xsl:output method="text"/>

<xsl:template match="/">
	<xsl:apply-templates select="/experiment/sample"/>
</xsl:template>

<xsl:template match="sample">
	<xsl:value-of select="../accession"/>
	<xsl:text>&#x9;</xsl:text>
	<xsl:value-of select="assay/comment[name='ENA_EXPERIMENT']/value"/>
	<xsl:text>&#x9;</xsl:text>
	<xsl:value-of select="characteristic[category='organism']/value"/>
	<xsl:text>&#x9;</xsl:text>
	<xsl:value-of select="assay/comment[name='SPOT_LENGTH']/value"/>
	<xsl:text>&#x9;</xsl:text>
	<xsl:value-of select="assay/comment[name='Platform_title']/value"/>
	<xsl:text>&#x9;</xsl:text>
	<xsl:value-of select="extract/comment[name='INSTRUMENT_MODEL']/value"/>
	<xsl:text>&#x9;</xsl:text>
	<xsl:value-of select="extract/comment[name='LIBRARY_LAYOUT']/value"/>
	<xsl:text>&#x9;</xsl:text>
	<xsl:value-of select="extract/comment[name='LIBRARY_STRATEGY']/value"/>
	<xsl:text>&#x9;</xsl:text>
	<xsl:value-of select="scan/comment[name='ENA_RUN']/value"/>
	<xsl:text>&#x9;</xsl:text>
	<xsl:value-of select="scan/comment[name='FASTQ_URI']/value"/>
	<xsl:text>&#x9;</xsl:text>
	<xsl:value-of select="source/comment[name='Sample_description']/value"/>
	<xsl:text>&#x9;</xsl:text>
	<xsl:value-of select="source/comment[name='Sample_source_name']/value"/>
	<xsl:text>&#x9;</xsl:text>
	<xsl:value-of select="source/comment[name='Sample_title']/value"/>
	<xsl:text>&#x9;</xsl:text>
	<xsl:value-of select="source/comment[name='biosource provider']/value"/>
	<xsl:text>&#x9;</xsl:text>
	<xsl:value-of select="variable[name='organism part']/value"/>
	<xsl:text>&#x9;</xsl:text>
	<xsl:value-of select="variable[name='phenotype']/value"/>
	<xsl:text>&#10;</xsl:text>
</xsl:template>

</xsl:stylesheet>

