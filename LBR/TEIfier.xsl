<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    
    
    <xsl:template match="//body/p">
       <!-- get the lemma-->
        <xsl:variable name="lemma">
            <xsl:choose>
                <xsl:when test="hi[@rend='bold'][1][matches(., ',')]">
                    <xsl:value-of select="hi[@rend='bold'][1]/substring-before(., ',')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="hi[@rend='bold'][1]"/>
                </xsl:otherwise>
            </xsl:choose>
            

        </xsl:variable>
    <xsl:variable name="deaccentifiedLemma">
        <!--removes accents as well as the hyphen-->
        <xsl:value-of select="replace(replace(normalize-unicode($lemma, 'NFD'), '\p{IsCombining_Diacritical_Marks}', ''), '-', '')"/>
    </xsl:variable>
       <!-- test if it's a homonym-->
        <xsl:variable name="hom">
            <xsl:choose>
                <xsl:when test="node()[1][self::text()]">
                    <xsl:value-of select="substring-before(node()[1][self::text()], '.')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text></xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
 
        <entry xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="concat('LBR.', $deaccentifiedLemma, $hom)"/>
            </xsl:attribute>
            <xsl:attribute name="xml:lang">la</xsl:attribute>
            <xsl:choose>
                <xsl:when test="$hom != ''">
                    <xsl:attribute name="type">hom</xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates></xsl:apply-templates>
        </entry>
    </xsl:template>
    
<!--    we have to match commas because there are 
    entries like abdico 1 which actually do not have 
    commas, so these have to be treated differently-->
    <xsl:template match="p/hi[@rend='bold'][1][matches(., ',')]">
           <xsl:for-each select="tokenize(., ',')">
               <form xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <xsl:attribute name="type">lemma</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="type">inflected</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                
                <orth>
                    <xsl:value-of select="normalize-space(.)"/>
                </orth>
            </form>
               <xsl:if test="position() != last()">
                   <pc xmlns="http://www.tei-c.org/ns/1.0">,</pc>
                   <xsl:text> </xsl:text>
               </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
   <!-- abidco 1 and similar-->
    <xsl:template match="p/hi[@rend='bold'][1][not(matches(., ','))]">
        <form xmlns="http://www.tei-c.org/ns/1.0" type="lemma">
            <orth>
                <xsl:value-of select="normalize-space(.)"/>
            </orth>
        </form>
    </xsl:template>
    
    <xsl:template match="//text()[matches(normalize-space(.), '^\d')][preceding-sibling::*[1][self::hi[@rend='bold']]]">
   <!--     this gives some 225 results of text nodes starting with a number (which is iType)
        but also includes results such as:
        2 смуча, попивам, поглъщам. and
        3 скрит; прикрит, таен. 
        which could be further processed as translations
        by making sure there is only text, commas and semicolons and ending in full stop
        would have to investigate more-->
        
     <!--   first, we want to separate those that have only iType num and those that have
        iType num and some text-->
        
        <xsl:analyze-string select="." regex="^\s+(\d)+\s*$">
            <xsl:matching-substring>
                <gramGrp xmlns="http://www.tei-c.org/ns/1.0">
                    <gram type="iType">
                        <xsl:value-of select="regex-group(1)"></xsl:value-of>
                    </gram>
                </gramGrp>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <gramGrp xmlns="http://www.tei-c.org/ns/1.0">
                    <gram type="iType">
                        <xsl:value-of select="substring-before(normalize-space(.), ' ')"></xsl:value-of>
                    </gram>
                </gramGrp>
                
                <xsl:text> </xsl:text>
                
         <!--     further processing for tranlsations would
              come out of the string after the iType-->
                <xsl:value-of select="substring-after(normalize-space(.), ' ')"/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
        

        
        
    </xsl:template>
        
    <xsl:template match="p/hi[@rend='italic'][1]">
        <gramGrp xmlns="http://www.tei-c.org/ns/1.0">
            <gram type="pos">
                <xsl:value-of select="."/>
            </gram>
        </gramGrp>
    </xsl:template>
    

<!--    if the first node is a text node (as opposed to hi rend
    lemma, that means it's a homonym number. this
    could be further constrained by making sure it's
    a digit with a dot -\- regex: '\d+.' but I won't do that here-->
    
    <xsl:template match="//body/p/node()[1][self::text()]">
        <lbl  xmlns="http://www.tei-c.org/ns/1.0" type="homNum">
            <xsl:value-of select="normalize-space(.)"/>
        </lbl>
    </xsl:template>
    
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>
