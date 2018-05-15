<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">

	<xsl:output method="text"/>

	<xsl:variable name="type" select="/article/@article-type"/>
	<xsl:variable name="date" select="/article/front/article-meta/pub-date[@pub-type='epub']/year"/>
	<xsl:variable name="day" select="/article/front/article-meta/pub-date[@pub-type='epub']/day"/>
	<xsl:variable name="month" select="/article/front/article-meta/pub-date[@pub-type='epub']/month"/>
	<xsl:variable name="year" select="/article/front/article-meta/pub-date[@pub-type='epub']/year"/>

	<xsl:variable name="journal" select="/article/front/journal-meta/journal-title-group/journal-title"/>
	<xsl:variable name="journal_bis" select="/article/front/journal-meta/journal-title"/>
<!--	<xsl:variable name="title" select="/article/front/article-meta/title-group/article-title"/>-->
	<xsl:variable name="doi" select="/article/front/article-meta/article-id[@pub-id-type='doi']"/>
	<xsl:variable name="pmc" select="/article/front/article-meta/article-id[@pub-id-type='pmc']"/>
	<xsl:variable name="pmid" select="/article/front/article-meta/article-id[@pub-id-type='pmid']"/>
	<xsl:variable name="pubid" select="/article/front/article-meta/article-id[@pub-id-type='publisher-id']"/>

<!--	<xsl:variable name="keywords">-->
<!--		<xsl:apply-templates select="/article/front/article-meta/kwd-group/kwd"/>-->
<!--	</xsl:variable>-->
<!--	<xsl:variable name="affiliations" select="/article/front/article-meta/contrib-group/aff"/> -->


	<xsl:template match="/">
<!--		<xsl:apply-templates select="/article/front/article-meta/contrib-group/contrib"/>-->
		<xsl:apply-templates select="/article/back/ref-list/ref"/>
	</xsl:template>


	<xsl:template match="ref">

		<xsl:value-of select="normalize-space(@id)"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space(citation/@citation-type)"/>
		<xsl:value-of select="normalize-space(element-citation/@publication-type)"/>
		<xsl:value-of select="normalize-space(mixed-citation/@publication-type)"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space(citation/source)"/>
		<xsl:value-of select="normalize-space(element-citation/source)"/>
		<xsl:value-of select="normalize-space(mixed-citation/source)"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space(citation/day)"/>
		<xsl:value-of select="normalize-space(element-citation/day)"/>
		<xsl:value-of select="normalize-space(mixed-citation/day)"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space(citation/month)"/>
		<xsl:value-of select="normalize-space(element-citation/month)"/>
		<xsl:value-of select="normalize-space(mixed-citation/month)"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space(citation/year)"/>
		<xsl:value-of select="normalize-space(element-citation/year)"/>
		<xsl:value-of select="normalize-space(mixed-citation/year)"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space(citation/pub-id[@pub-id-type='doi'])"/>
		<xsl:value-of select="normalize-space(element-citation/pub-id[@pub-id-type='doi'])"/>
		<xsl:value-of select="normalize-space(mixed-citation/pub-id[@pub-id-type='doi'])"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space(citation/pub-id[@pub-id-type='pmid'])"/>
		<xsl:value-of select="normalize-space(element-citation/pub-id[@pub-id-type='pmid'])"/>
		<xsl:value-of select="normalize-space(mixed-citation/pub-id[@pub-id-type='pmid'])"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space(citation/pub-id[@pub-id-type='pmc'])"/>
		<xsl:value-of select="normalize-space(element-citation/pub-id[@pub-id-type='pmc'])"/>
		<xsl:value-of select="normalize-space(mixed-citation/pub-id[@pub-id-type='pmc'])"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space(citation/pub-id[@pub-id-type='publisher-id'])"/>
		<xsl:value-of select="normalize-space(element-citation/pub-id[@pub-id-type='publisher-id'])"/>
		<xsl:value-of select="normalize-space(mixed-citation/pub-id[@pub-id-type='publisher-id'])"/>
		<xsl:text>&#x9;</xsl:text>

		<xsl:value-of select="normalize-space($journal)"/>
		<xsl:value-of select="normalize-space($journal_bis)"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space($pubid)"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space($doi)"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space($pmc)"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space($pmid)"/>
		<xsl:text>&#x9;</xsl:text>


<!--		<xsl:value-of select="normalize-space($type)"/>-->
<!--		<xsl:text>&#x9;</xsl:text>-->
<!--		<xsl:value-of select="$title"/>-->
<!--		<xsl:text>&#x9;</xsl:text>-->


		<xsl:value-of select="normalize-space($day)"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space($month)"/>
		<xsl:text>&#x9;</xsl:text>
		<xsl:value-of select="normalize-space($year)"/>
		<xsl:text>&#x9;</xsl:text>


<!-- WORKING CODE TO GET A YEAR AS A DATE-->
<!--		<xsl:choose>-->
<!--			<xsl:when test="$date">-->
<!--				<xsl:value-of select="normalize-space($date)"/>-->
<!--			</xsl:when>-->
<!--			<xsl:otherwise>-->
<!--				<xsl:value-of select="normalize-space(//year)"/>-->
<!--			</xsl:otherwise>-->
<!--		</xsl:choose>-->
<!--		<xsl:text>&#x9;</xsl:text>-->


<!--		<xsl:value-of select="normalize-space($keywords)"/>-->
<!--		<xsl:text>&#x9;</xsl:text>-->
		<!-- line feed char -->


		<xsl:text>&#10;</xsl:text>
	</xsl:template>





<!--	<xsl:template match="kwd">-->
<!--		<xsl:value-of select="." />-->
<!--		<xsl:if test="position() != last()">-->
<!--			<xsl:text>; </xsl:text>-->
<!--		</xsl:if>-->
<!--	</xsl:template>-->


<!--	<xsl:template match="contrib">-->
<!--		<xsl:choose>-->
<!--			<xsl:when test="$date">-->
<!--				<xsl:value-of select="normalize-space($date)"/>-->
<!--			</xsl:when>-->
<!--			<xsl:otherwise>-->
<!--				<xsl:value-of select="normalize-space(//year)"/>-->
<!--			</xsl:otherwise>-->
<!--		</xsl:choose>-->
<!--		<xsl:text>&#x9;</xsl:text>-->
<!--		<xsl:value-of select="normalize-space(name/surname)" />-->
<!--		<xsl:text>&#x9;</xsl:text>-->
<!--		<xsl:value-of select="normalize-space(name/given-names)" />-->
<!--		<xsl:text>&#x9;</xsl:text>-->
<!--		<xsl:choose>-->
<!--			<xsl:when test="email">-->
<!--				<xsl:value-of select="normalize-space(email)" />-->
<!--			</xsl:when>-->
<!--			<xsl:when test="address/email">-->
<!--				<xsl:value-of select="normalize-space(address/email)" />-->
<!--			</xsl:when>-->
<!--			<xsl:otherwise>-->
<!--				<xsl:variable name="corresponding_ref" select="xref[@ref-type='corresp']/@rid"/>-->
<!--				<xsl:value-of select="normalize-space(/article/front/article-meta/author-notes/corresp[@id=$corresponding_ref]/email)"/>-->
<!--			</xsl:otherwise>-->
<!--		</xsl:choose>-->
<!--		<xsl:text>&#x9;</xsl:text>-->
<!--		<xsl:choose>-->
<!--			<xsl:when test="@corresp">-->
<!--				<xsl:value-of select="normalize-space(@corresp)" />-->
<!--			</xsl:when>-->
<!--			<xsl:when test="xref[@ref-type='corresp']">-->
<!--				<xsl:text>yes</xsl:text>-->
<!--			</xsl:when>-->
<!--		</xsl:choose>-->
<!--		<xsl:text>&#x9;</xsl:text>-->
<!--		<xsl:value-of select="normalize-space($type)"/>-->
<!--		<xsl:text>&#x9;</xsl:text>-->
<!--		<xsl:value-of select="normalize-space($journal)"/>-->
<!--		<xsl:value-of select="normalize-space($journal_bis)"/>-->
<!--		<xsl:text>&#x9;</xsl:text>-->
<!--		<xsl:value-of select="normalize-space($doi)"/>-->
<!--		<xsl:text>&#x9;</xsl:text>-->
<!--		<xsl:value-of select="normalize-space($pmc)"/>-->
<!--		<xsl:text>&#x9;</xsl:text>-->
<!--		<xsl:value-of select="normalize-space($keywords)"/>-->
<!--		<xsl:text>&#x9;</xsl:text>-->
<!--		<xsl:for-each select="xref[@ref-type='aff']">-->
<!--			<xsl:variable name="current_aff" select="@rid"/>-->
<!--			<xsl:value-of select="normalize-space($current_aff)"/>-->
<!--			<xsl:text> - </xsl:text>-->
<!--			<xsl:value-of select="normalize-space(/article/front/article-meta/contrib-group/aff[@id=$current_aff])"/>-->
<!--			<xsl:value-of select="normalize-space(/article/front/article-meta/aff[@id=$current_aff])"/>-->
<!--			<xsl:if test="position() != last()">-->
<!--				<xsl:text>; </xsl:text>-->
<!--			</xsl:if>-->
<!--		</xsl:for-each>-->
<!--		<xsl:text>&#10;</xsl:text>-->
<!--	</xsl:template>-->


<!--	<xsl:template match="xref">-->
<!--		<xsl:value-of select="normalize-space(.)" />-->
<!--		<xsl:if test="position() != last()">-->
<!--			<xsl:text>; </xsl:text>-->
<!--		</xsl:if>-->
<!--	</xsl:template>-->

</xsl:stylesheet>
