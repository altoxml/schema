<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" queryBinding="xslt2">

    <sch:ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>

    <sch:title>ALTO schematron validation (namespace-agnostic: ALTO v1-v5)</sch:title>


    <!-- ========================================================= -->
    <!-- 0. Document / namespace check                             -->
    <!-- ========================================================= -->

    <sch:pattern id="alto-root">
        <sch:title>Document must be ALTO</sch:title>

        <sch:rule context="/">
            <sch:assert role="error" test="
                    *:alto[starts-with(namespace-uri(), 'http://www.loc.gov/standards/alto/')
                           or namespace-uri() = 'http://schema.ccs-gmbh.com/ALTO']
                    "> Root element is not recognized as an ALTO document (found root
                '<sch:value-of select="name(*)"/>' in namespace
                '<sch:value-of select="namespace-uri(*)"/>'); any results below are
                unreliable. </sch:assert>

            <sch:report role="info" test="
                    *:alto[starts-with(namespace-uri(), 'http://www.loc.gov/standards/alto/')
                           or namespace-uri() = 'http://schema.ccs-gmbh.com/ALTO']
                    "> ALTO namespace detected:
                <sch:value-of select="namespace-uri(*)"/>. </sch:report>
        </sch:rule>
    </sch:pattern>


    <!-- ========================================================= -->
    <!-- 1. Numeric sanity checks                                  -->
    <!-- ========================================================= -->

    <sch:pattern id="numeric-box-attributes">
        <sch:title>Numeric validity of box attributes</sch:title>

        <sch:rule context="
                *:Page |
                *:PrintSpace |
                *:TextBlock |
                *:Illustration |
                *:GraphicalElement |
                *:ComposedBlock |
                *:TextLine |
                *:String |
                *:HYP |
                *:Glyph |
                *:SP
                ">

            <sch:assert role="error" test="
                    not(@VPOS)
                    or (@VPOS castable as xs:double and xs:double(@VPOS) >= 0)
                    "> VPOS must be a non-negative number; found
                VPOS='<sch:value-of select="@VPOS"/>' on <sch:value-of select="name()"/>
                ID='<sch:value-of select="@ID"/>'. </sch:assert>

            <sch:assert role="error" test="
                    not(@HPOS)
                    or (@HPOS castable as xs:double and xs:double(@HPOS) >= 0)
                    "> HPOS must be a non-negative number; found
                HPOS='<sch:value-of select="@HPOS"/>' on <sch:value-of select="name()"/>
                ID='<sch:value-of select="@ID"/>'. </sch:assert>

            <sch:assert role="error" test="
                    not(@WIDTH)
                    or (@WIDTH castable as xs:double and xs:double(@WIDTH) >= 0)
                    "> WIDTH must be a non-negative number; found
                WIDTH='<sch:value-of select="@WIDTH"/>' on <sch:value-of select="name()"/>
                ID='<sch:value-of select="@ID"/>'. </sch:assert>

            <sch:assert role="error" test="
                    not(@HEIGHT)
                    or (@HEIGHT castable as xs:double and xs:double(@HEIGHT) >= 0)
                    "> HEIGHT must be a non-negative number; found
                HEIGHT='<sch:value-of select="@HEIGHT"/>' on <sch:value-of select="name()"/>
                ID='<sch:value-of select="@ID"/>'. </sch:assert>
        </sch:rule>
    </sch:pattern>


    <!-- ========================================================= -->
    <!-- 2. Parent-child box containment                           -->
    <!-- ========================================================= -->

    <sch:pattern id="parent-child-containment">
        <sch:title>Child boxes should be fully contained in parent boxes</sch:title>

        <sch:rule context="
                *:TextLine/*:String |
                *:TextLine/*:HYP |
                *:TextLine/*:SP |
                *:String/*:Glyph |
                *:TextBlock/*:TextLine |
                *:ComposedBlock/* |
                *:PrintSpace/*
                ">

            <sch:assert role="warning" test="
                    not(
                    @HPOS and @VPOS and @WIDTH and @HEIGHT
                    and parent::*/@HPOS and parent::*/@VPOS and parent::*/@WIDTH and parent::*/@HEIGHT
                    )
                    or
                    (
                    (@HPOS castable as xs:double)
                    and (@VPOS castable as xs:double)
                    and (@WIDTH castable as xs:double)
                    and (@HEIGHT castable as xs:double)
                    and (parent::*/@HPOS castable as xs:double)
                    and (parent::*/@VPOS castable as xs:double)
                    and (parent::*/@WIDTH castable as xs:double)
                    and (parent::*/@HEIGHT castable as xs:double)
                    and xs:double(@HPOS) >= xs:double(parent::*/@HPOS)
                    and xs:double(@VPOS) >= xs:double(parent::*/@VPOS)
                    and xs:double(@HPOS) + xs:double(@WIDTH)
                    &lt;= xs:double(parent::*/@HPOS) + xs:double(parent::*/@WIDTH)
                    and xs:double(@VPOS) + xs:double(@HEIGHT)
                    &lt;= xs:double(parent::*/@VPOS) + xs:double(parent::*/@HEIGHT)
                    )
                    "> <sch:value-of select="name()"/> ID='<sch:value-of select="@ID"/>' is not
                fully contained within the bounding box of its parent
                <sch:value-of select="name(parent::*)"/> ID='<sch:value-of select="parent::*/@ID"/>'.
            </sch:assert>
        </sch:rule>

        <sch:rule context="*:Page/*">

            <sch:assert role="warning" test="
                    not(
                    @HPOS and @VPOS and @WIDTH and @HEIGHT
                    and parent::*/@WIDTH and parent::*/@HEIGHT
                    )
                    or
                    (
                    (every $a in (@HPOS, @VPOS, @WIDTH, @HEIGHT,
                                  parent::*/@WIDTH, parent::*/@HEIGHT)
                     satisfies $a castable as xs:double)
                    and xs:double(@HPOS) + xs:double(@WIDTH) &lt;= xs:double(parent::*/@WIDTH)
                    and xs:double(@VPOS) + xs:double(@HEIGHT) &lt;= xs:double(parent::*/@HEIGHT)
                    )
                    "> <sch:value-of select="name()"/> ID='<sch:value-of select="@ID"/>' is not
                fully contained within the dimensions of its Page
                ID='<sch:value-of select="parent::*/@ID"/>'.
            </sch:assert>
        </sch:rule>

    </sch:pattern>


    <!-- ========================================================= -->
    <!-- 3. Empty container checks                                 -->
    <!-- ========================================================= -->

    <sch:pattern id="empty-containers">
        <sch:title>Containers must not be empty</sch:title>

        <sch:rule context="*:Layout">
            <sch:assert role="warning" test="*:Page"> Layout contains no Page
                elements; the document describes no content. </sch:assert>
        </sch:rule>

        <sch:rule context="*:TextBlock">
            <sch:assert role="warning" test="*:TextLine"> TextBlock
                ID='<sch:value-of select="@ID"/>' must contain at least one TextLine. </sch:assert>
        </sch:rule>

        <sch:rule context="*:ComposedBlock">
            <sch:assert role="warning" test="
                    *:TextBlock or *:Illustration or *:GraphicalElement or *:ComposedBlock
                    "> ComposedBlock ID='<sch:value-of select="@ID"/>' must contain at least
                one block-type element (TextBlock, Illustration, GraphicalElement or
                ComposedBlock). </sch:assert>
        </sch:rule>

        <sch:rule context="*:TextLine">
            <sch:assert role="warning" test="*:String or *:HYP or *:SP"> TextLine
                ID='<sch:value-of select="@ID"/>' must contain at least one String, HYP or SP
                element. </sch:assert>
        </sch:rule>
    </sch:pattern>


    <!-- ========================================================= -->
    <!-- 4. Text-specific semantic checks                          -->
    <!-- ========================================================= -->

    <sch:pattern id="text-semantics">
        <sch:title>Text-related semantic constraints</sch:title>

        <sch:rule context="*:String">
            <sch:assert role="error"
                test="not(@FONTSIZE) or (@FONTSIZE castable as xs:double and xs:double(@FONTSIZE) > 0)"
                > FONTSIZE must be a positive number; found
                FONTSIZE='<sch:value-of select="@FONTSIZE"/>' on String
                ID='<sch:value-of select="@ID"/>'. </sch:assert>

            <sch:assert role="error" test="
                    not(@WC)
                    or (@WC castable as xs:double
                        and xs:double(@WC) >= 0 and xs:double(@WC) &lt;= 1)
                    "> WC (word confidence) must be a number between 0 and 1; found
                WC='<sch:value-of select="@WC"/>' on String
                ID='<sch:value-of select="@ID"/>'. </sch:assert>

            <sch:assert role="warning" test="
                    not(@CONTENT) or normalize-space(@CONTENT) != ''
                    "> String ID='<sch:value-of select="@ID"/>' has an empty CONTENT
                attribute. </sch:assert>
        </sch:rule>
    </sch:pattern>


    <!-- ========================================================= -->
    <!-- 5. Page-level semantic checks                             -->
    <!-- ========================================================= -->

    <sch:pattern id="page-semantics">
        <sch:title>Page semantic constraints</sch:title>

        <sch:rule context="*:Page">
            <sch:assert role="error" test="
                    not(@PHYSICAL_IMG_NR)
                    or (@PHYSICAL_IMG_NR castable as xs:integer and xs:integer(@PHYSICAL_IMG_NR) > 0)
                    "> PHYSICAL_IMG_NR must be a positive integer; found
                PHYSICAL_IMG_NR='<sch:value-of select="@PHYSICAL_IMG_NR"/>' on Page
                ID='<sch:value-of select="@ID"/>'. </sch:assert>

            <sch:assert role="error" test="
                    not(@PC)
                    or (@PC castable as xs:double
                        and xs:double(@PC) >= 0 and xs:double(@PC) &lt;= 1)
                    "> PC (page confidence) must be a number between 0 and 1; found
                PC='<sch:value-of select="@PC"/>' on Page
                ID='<sch:value-of select="@ID"/>'. </sch:assert>

            <sch:assert role="error" test="
                    not(@ACCURACY)
                    or (@ACCURACY castable as xs:double
                        and xs:double(@ACCURACY) >= 0 and xs:double(@ACCURACY) &lt;= 100)
                    "> ACCURACY must be a percentage between 0 and 100; found
                ACCURACY='<sch:value-of select="@ACCURACY"/>' on Page
                ID='<sch:value-of select="@ID"/>'. </sch:assert>
        </sch:rule>
    </sch:pattern>


    <!-- ========================================================= -->
    <!-- 6. Reference checks (TAGREFS, STYLEREFS, PROCESSINGREFS)  -->
    <!-- ========================================================= -->

    <sch:pattern id="alto-tagrefs">
        <sch:title>TAGREFS validity checks</sch:title>

        <sch:rule context="*[@TAGREFS]">
            <sch:let name="refs" value="tokenize(@TAGREFS, '\s+')"/>
            <sch:let name="tagIDs" value="ancestor::*:alto/*:Tags/*/@ID"/>

            <sch:assert role="error" test="empty($refs[not(. = $tagIDs)])"> Invalid TAGREFS on
                <sch:value-of select="name()"/> ID='<sch:value-of select="@ID"/>':
                <sch:value-of select="
                    string-join(
                        $refs[not(. = $tagIDs)],
                    ', ')
                "/> (no matching Tags/*/@ID).
            </sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="alto-stylerefs">
        <sch:title>STYLEREFS validity checks</sch:title>

        <sch:rule context="*[@STYLEREFS]">
            <sch:let name="refs" value="tokenize(@STYLEREFS, '\s+')"/>
            <sch:let name="styleIDs" value="ancestor::*:alto/*:Styles/*/@ID"/>

            <sch:assert role="error" test="empty($refs[not(. = $styleIDs)])"> Invalid STYLEREFS on
                <sch:value-of select="name()"/> ID='<sch:value-of select="@ID"/>':
                <sch:value-of select="
                    string-join(
                        $refs[not(. = $styleIDs)],
                    ', ')
                "/> (no matching Styles/*/@ID).
            </sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="alto-processingrefs">
        <sch:title>PROCESSINGREFS validity checks</sch:title>

        <sch:rule context="*[@PROCESSINGREFS]">
            <sch:let name="refs" value="tokenize(@PROCESSINGREFS, '\s+')"/>
            <sch:let name="processingIDs" value="ancestor::*:alto/*:Description/*:Processing/@ID"/>

            <sch:assert role="error" test="empty($refs[not(. = $processingIDs)])"> Invalid
                PROCESSINGREFS on <sch:value-of select="name()"/>
                ID='<sch:value-of select="@ID"/>':
                <sch:value-of select="
                    string-join(
                        $refs[not(. = $processingIDs)],
                    ', ')
                "/> (no matching Description/Processing/@ID).
            </sch:assert>
        </sch:rule>
    </sch:pattern>


    <!-- ========================================================= -->
    <!-- 7. Object overlaps (blocks, lines, strings)               -->
    <!-- ========================================================= -->

    <sch:pattern abstract="true" id="overlap-check">
        <sch:title>Bounding-box overlap check</sch:title>

        <sch:rule context="$context">

            <sch:let name="me" value="."/>

            <sch:let name="overlap" value="
                    ($candidates)
                    [
                        number(@HPOS) + $tolerance &lt; number($me/@HPOS) + number($me/@WIDTH)
                        and number(@HPOS) + number(@WIDTH) &gt; number($me/@HPOS) + $tolerance
                        and number(@VPOS) + $tolerance &lt; number($me/@VPOS) + number($me/@HEIGHT)
                        and number(@VPOS) + number(@HEIGHT) &gt; number($me/@VPOS) + $tolerance
                    ]
                    "/>

            <sch:report role="info" test="exists($overlap)">
                <sch:value-of select="name()"/> ID='<sch:value-of select="@ID"/>' overlaps
                with: <sch:value-of select="
                    string-join(
                        for $o in $overlap
                        return concat(name($o), ' ID=''', $o/@ID, ''''),
                    ', ')
                "/>.
            </sch:report>

        </sch:rule>
    </sch:pattern>

    <sch:pattern is-a="overlap-check" id="alto-overlap-blocks">
        <sch:param name="context" value="
                *:TextBlock |
                *:Illustration |
                *:GraphicalElement |
                *:ComposedBlock
                "/>
        <sch:param name="candidates" value="
                following::*[
                    self::*:TextBlock
                 or self::*:Illustration
                 or self::*:GraphicalElement
                 or self::*:ComposedBlock
                ]
                [ancestor::*:Page[1] is $me/ancestor::*:Page[1]]
                "/>
        <sch:param name="tolerance" value="0"/>
    </sch:pattern>

    <sch:pattern is-a="overlap-check" id="alto-overlap-textlines">
        <sch:param name="context" value="*:TextLine"/>
        <sch:param name="candidates" value="following-sibling::*:TextLine"/>
        <sch:param name="tolerance" value="0"/>
    </sch:pattern>

    <sch:pattern is-a="overlap-check" id="alto-overlap-strings">
        <sch:param name="context" value="*:String"/>
        <sch:param name="candidates" value="following-sibling::*:String"/>
        <sch:param name="tolerance" value="1"/>
    </sch:pattern>


    <!-- ========================================================= -->
    <!-- 8. Hyphenation consistency                                -->
    <!-- ========================================================= -->

    <sch:pattern id="alto-hyphenation">
        <sch:title>Hyphenated word parts must pair up</sch:title>

        <sch:rule context="*:String[@SUBS_TYPE = 'HypPart1']">
            <sch:assert role="warning" test="
                    following::*:String[1]/@SUBS_TYPE = 'HypPart2'
                    "> String ID='<sch:value-of select="@ID"/>' is marked
                SUBS_TYPE='HypPart1' but the next String is not marked
                'HypPart2'. </sch:assert>
        </sch:rule>

        <sch:rule context="*:String[@SUBS_TYPE = 'HypPart2']">
            <sch:assert role="warning" test="
                    preceding::*:String[1]/@SUBS_TYPE = 'HypPart1'
                    "> String ID='<sch:value-of select="@ID"/>' is marked
                SUBS_TYPE='HypPart2' but the preceding String is not marked
                'HypPart1'. </sch:assert>
        </sch:rule>

        <sch:rule context="*:TextLine/*:HYP">
            <sch:assert role="warning" test="not(following-sibling::*)"> HYP in TextLine
                ID='<sch:value-of select="parent::*/@ID"/>' is not the last element of
                the line. </sch:assert>
        </sch:rule>
    </sch:pattern>

</sch:schema>
