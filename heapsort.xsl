<?xml version="1.1" encoding="UTF-8"?>
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:math="http://exslt.org/math">

    <xsl:output omit-xml-declaration="no" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:template name="identify" match="listOfNumbers">
        <xsl:variable name="list">
            <xsl:for-each select="data(.)">
                <item value="{.}"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="heap">
            <xsl:call-template name="growHeap">
                <xsl:with-param name="list" select="$list"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="sortedHeap">
            <xsl:call-template name="heapSort">
                <xsl:with-param name="pheap" select="$heap"/>
                <xsl:with-param name="heapSize" select="math:max($heap//heap/@index)"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="output">
            <xsl:with-param name="heap" select="$sortedHeap"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="growHeap">
        <xsl:param name="list"/>
        <xsl:variable name="index" select="1"/>
        <xsl:variable name="length" select="count($list/item)"/>
        <xsl:if test="$length &gt;= 1">
            <heap xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:noNamespaceSchemaLocation="heapdata.xsd" index="{$index}"
                value="{$list/item[position() = $index]/@value}">
                <xsl:call-template name="feedHeap">
                    <xsl:with-param name="list" select="$list"/>
                    <xsl:with-param name="index" select="$index"/>
                </xsl:call-template>
            </heap>
        </xsl:if>
    </xsl:template>

    <xsl:template name="feedHeap">
        <xsl:param name="list"/>
        <xsl:param name="index"/>
        <xsl:variable name="left" select="$index * 2"/>
        <xsl:variable name="right" select="$index * 2 + 1"/>
        <xsl:variable name="length" select="count($list/item)"/>
        <xsl:if test="$left &lt;= $length">
            <heap index="{$left}" value="{$list/item[position() = $left]/@value}">
                <xsl:call-template name="feedHeap">
                    <xsl:with-param name="index" select="$left"/>
                    <xsl:with-param name="list" select="$list"/>
                </xsl:call-template>
            </heap>
        </xsl:if>
        <xsl:if test="$right &lt;= $length">
            <heap index="{$right}" value="{$list/item[position() = $right]/@value}">
                <xsl:call-template name="feedHeap">
                    <xsl:with-param name="index" select="$right"/>
                    <xsl:with-param name="list" select="$list"/>
                </xsl:call-template>
            </heap>
        </xsl:if>
    </xsl:template>

    <xsl:template name="swap">
        <xsl:param name="heap"/>
        <xsl:param name="index1"/>
        <xsl:param name="index2"/>
        <xsl:variable name="list">
            <xsl:call-template name="harvestHeap">
                <xsl:with-param name="heap" select="$heap"/>
                <xsl:with-param name="index" select="1"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="length" select="count($list/item)"/>
        <xsl:choose>
            <xsl:when
                test="$index1 &lt; 1 or $index2 &lt; 1 or $index1 &gt; $length or $index2 &gt; $length">
                <xsl:copy-of select="$list"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="item1" select="$list/item[position() = $index1]"/>
                <xsl:variable name="item2" select="$list/item[position() = $index2]"/>
                <xsl:variable name="swapped">
                    <xsl:for-each select="$list/item">
                        <xsl:variable name="value">
                            <xsl:choose>
                                <xsl:when test="position() = $index1">
                                    <xsl:value-of select="$item2/@value"/>
                                </xsl:when>
                                <xsl:when test="position() = $index2">
                                    <xsl:value-of select="$item1/@value"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@value"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <item value="{$value}"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:call-template name="growHeap">
                    <xsl:with-param name="list" select="$swapped"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="heapSort">
        <xsl:param name="pheap"/>
        <xsl:param name="heapSize"/>
        <xsl:variable name="heap">
            <xsl:call-template name="buildHeap">
                <xsl:with-param name="pheap" select="$pheap"/>
                <xsl:with-param name="index" select="0"/>
                <xsl:with-param name="heapSize" select="$heapSize"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$heapSize &gt; 1">
                <xsl:variable name="swapped">
                    <xsl:call-template name="swap">
                        <xsl:with-param name="heap" select="$heap"/>
                        <xsl:with-param name="index1" select="1"/>
                        <xsl:with-param name="index2" select="$heapSize"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:call-template name="heapSort">
                    <xsl:with-param name="pheap" select="$swapped"/>
                    <xsl:with-param name="heapSize" select="$heapSize - 1"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$heap"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="buildHeap">
        <xsl:param name="pheap"/>
        <xsl:param name="index"/>
        <xsl:param name="heapSize"/>
        <xsl:variable name="length" select="floor(math:max($pheap//heap/@index) div 2)"/>
        <xsl:variable name="start" select="$length - $index"/>
        <xsl:choose>
            <xsl:when test="$start &gt;= 1">
                <xsl:variable name="heap">
                    <xsl:call-template name="heapify">
                        <xsl:with-param name="pheap" select="$pheap"/>
                        <xsl:with-param name="index" select="$start"/>
                        <xsl:with-param name="heapSize" select="$heapSize"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:call-template name="buildHeap">
                    <xsl:with-param name="pheap" select="$heap"/>
                    <xsl:with-param name="index" select="$index + 1"/>
                    <xsl:with-param name="heapSize" select="$heapSize"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$pheap"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="heapify">
        <xsl:param name="pheap"/>
        <xsl:param name="index"/>
        <xsl:param name="heapSize"/>
        <xsl:variable name="left" select="$index * 2"/>
        <xsl:variable name="right" select="$index * 2 + 1"/>
        <xsl:variable name="largest">
            <xsl:variable name="parent" select="$pheap//heap[@index = $index]/@value"/>
            <xsl:variable name="leftChild">
                <xsl:choose>
                    <xsl:when test="$left &lt;= $heapSize">
                        <xsl:value-of select="$pheap/heap//heap[@index = $left]/@value"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$parent - 1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="rightChild">
                <xsl:choose>
                    <xsl:when test="$right &lt;= $heapSize">
                        <xsl:value-of select="$pheap/heap//heap[@index = $right]/@value"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$parent - 1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$parent &lt;= $leftChild and $rightChild &lt;= $leftChild">
                    <xsl:value-of select="$left"/>
                </xsl:when>
                <xsl:when test="$parent &lt; $rightChild and $leftChild &lt; $rightChild">
                    <xsl:value-of select="$right"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$index"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$largest != $index">
                <xsl:variable name="swapped">
                    <xsl:call-template name="swap">
                        <xsl:with-param name="heap" select="$pheap"/>
                        <xsl:with-param name="index1" select="$index"/>
                        <xsl:with-param name="index2" select="$largest"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:call-template name="heapify">
                    <xsl:with-param name="pheap" select="$swapped"/>
                    <xsl:with-param name="index" select="$largest"/>
                    <xsl:with-param name="heapSize" select="$heapSize"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$pheap"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="harvestHeap">
        <xsl:param name="heap"/>
        <xsl:param name="index"/>
        <xsl:choose>
            <xsl:when test="$heap//heap[@index=$index]">
                <item value="{$heap//heap[@index=$index]/@value}"/>
            </xsl:when>
            <xsl:when test="$heap//.[@index=$index]">
                <item value="{$heap//.[@index=$index]/@value}"/>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="$heap//heap[@index=$index+1]">
                <xsl:call-template name="harvestHeap">
                    <xsl:with-param name="heap" select="$heap"/>
                    <xsl:with-param name="index" select="$index+1"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="output">
        <xsl:param name="heap"/>
        <xsl:variable name="list">
            <xsl:call-template name="harvestHeap">
                <xsl:with-param name="index" select="1"/>
                <xsl:with-param name="heap" select="$heap"/>
            </xsl:call-template>
        </xsl:variable>
        <listOfNumbers xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:noNamespaceSchemaLocation="list.xsd">
            <xsl:for-each select="$list/item">
                <xsl:if test="position() > 1">
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:value-of select="@value"/>
            </xsl:for-each>
        </listOfNumbers>
    </xsl:template>
</xsl:stylesheet>
