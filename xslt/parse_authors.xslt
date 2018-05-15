<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">

	<xsl:output method="text"/>

	<xsl:variable name="type" select="/article/@article-type"/>
	<xsl:variable name="date" select="/article/front/article-meta/pub-date[@pub-type='epub']/year"/>

<!--	<xsl:variable name="date">-->
<!--		<xsl:choose>-->
<!--			<xsl:when test="/article/front/article-meta/pub-date[@pub-type='epub']/year">-->
<!--				<xsl:variable name="date" select="/article/front/article-meta/pub-date[@pub-type='epub']/year"/>-->
<!--			</xsl:when>-->
<!--			<xsl:otherwise>-->
<!--				<xsl:variable name="date" select="max(//date)"/>-->
<!--			</xsl:otherwise>-->
<!--		</xsl:choose>-->
<!--	</xsl:variable>-->
<!-- select="/article/front/article-meta/pub-date[@pub-type='epub']/year"/>-->



	<xsl:variable name="journal" select="/article/front/journal-meta/journal-title-group/journal-title"/>
	<xsl:variable name="journal_bis" select="/article/front/journal-meta/journal-title"/>
	<xsl:variable name="title" select="/article/front/article-meta/title-group/article-title"/>
	<xsl:variable name="doi" select="/article/front/article-meta/article-id[@pub-id-type='doi']"/>
	<xsl:variable name="pmc" select="/article/front/article-meta/article-id[@pub-id-type='pmc']"/>
	<xsl:variable name="keywords">
		<xsl:apply-templates select="/article/front/article-meta/kwd-group/kwd"/>
	</xsl:variable>
	<xsl:variable name="affiliations" select="/article/front/article-meta/contrib-group/aff"/> <!-- <aff id="Aff1"><label/>Human Genome -->


	<xsl:template match="/">
		<xsl:apply-templates select="/article/front/article-meta/contrib-group/contrib"/>
	</xsl:template>


	<xsl:template match="kwd">
		<xsl:value-of select="." />
		<xsl:if test="position() != last()">
			<xsl:text>; </xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template match="contrib">
		<xsl:choose>
			<xsl:when test="$date">
				<xsl:value-of select="normalize-space($date)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(//year)"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space(name/surname)" />
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space(name/given-names)" />
		<xsl:text>&#x9;</xsl:text>
<!--		<xsl:value-of select="address/email" />-->
<!--		<xsl:value-of select="email" />-->
		<xsl:choose>
			<xsl:when test="email">
				<xsl:value-of select="normalize-space(email)" />
			</xsl:when>
			<xsl:when test="address/email">
				<xsl:value-of select="normalize-space(address/email)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="corresponding_ref" select="xref[@ref-type='corresp']/@rid"/>
				<xsl:value-of select="normalize-space(/article/front/article-meta/author-notes/corresp[@id=$corresponding_ref]/email)"/>
<!--				<xsl:text>EMAIL $corresponding_ref</xsl:text>-->
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&#x9;</xsl:text>
<!--		<xsl:value-of select="@corresp"/>-->
		<xsl:choose>
			<xsl:when test="@corresp">
				<xsl:value-of select="normalize-space(@corresp)" />
			</xsl:when>
			<xsl:when test="xref[@ref-type='corresp']">
				<xsl:text>yes</xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space($type)"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space($journal)"/>
		<xsl:value-of select="normalize-space($journal_bis)"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space($doi)"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space($pmc)"/>
		<xsl:text>&#x9;</xsl:text>
<!--		<xsl:value-of select="$title"/>-->
<!--		<xsl:text>&#x9;</xsl:text>-->
		<xsl:value-of select="normalize-space($keywords)"/>
		<xsl:text>&#x9;</xsl:text>
<!--		<xsl:for-each select="xref[@ref-type='aff']">-->
<!--			<xsl:value-of select="@rid"/>-->
<!--			<xsl:if test="position() != last()">-->
<!--				<xsl:text>; </xsl:text>-->
<!--			</xsl:if>-->
<!--		</xsl:for-each>-->
		<!-- FULL AFFILIATIONS -->
<!--		<xsl:text>&#x9;</xsl:text>-->
		<xsl:for-each select="xref[@ref-type='aff']">
			<xsl:variable name="current_aff" select="@rid"/>
			<xsl:value-of select="normalize-space($current_aff)"/>
			<xsl:text> - </xsl:text>
			<xsl:value-of select="normalize-space(/article/front/article-meta/contrib-group/aff[@id=$current_aff])"/>
			<xsl:value-of select="normalize-space(/article/front/article-meta/aff[@id=$current_aff])"/>
			<xsl:if test="position() != last()">
				<xsl:text>; </xsl:text>
			</xsl:if>
		</xsl:for-each>
		<!-- line feed char -->
		<xsl:text>&#10;</xsl:text>
	</xsl:template>


	<xsl:template match="xref">
		<xsl:value-of select="normalize-space(.)" />
		<xsl:if test="position() != last()">
			<xsl:text>; </xsl:text>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
