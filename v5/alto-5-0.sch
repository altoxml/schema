<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
	xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
	<sch:ns uri="http://www.loc.gov/standards/alto/ns-v2#" prefix="alto"/>

	<sch:title>VPOS, HPOS, WIDTH and HEIGHT checks</sch:title>

	<sch:pattern>
		<sch:title>Check if all VPOS, HPOS, WIDTH and HEIGHT attributes have positive
			values</sch:title>
		<sch:rule context="*">
			<sch:assert test="not(@VPOS) or number(@VPOS) = @VPOS and number(@VPOS) &gt;= 0">VPOS
					(<sch:value-of select="@VPOS"/>) must be a positive value.</sch:assert>
			<sch:assert test="not(@HPOS) or number(@HPOS) = @HPOS and number(@HPOS) &gt;= 0">HPOS
					(<sch:value-of select="@HPOS"/>) must be a positive value.</sch:assert>
			<sch:assert test="not(@WIDTH) or number(@WIDTH) = @WIDTH and number(@WIDTH) &gt;= 0"
				>WIDTH (<sch:value-of select="@WIDTH"/>) must be a positive value.</sch:assert>
			<sch:assert test="not(@HEIGHT) or number(@HEIGHT) = @HEIGHT and @HEIGHT &gt;= 0">HEIGHT
				must be a positive value (<sch:value-of select="@HEIGHT"/>).</sch:assert>
		</sch:rule>
	</sch:pattern>

	<sch:pattern>
		<sch:title>TextBlock specific checks</sch:title>
		<sch:rule context="alto:TextBlock">
			<sch:assert test="number(@VPOS) &lt;= number(ancestor::alto:Page/@HEIGHT)">TextBlock
				VPOS (<sch:value-of select="@VPOS"/>) must be less than Page HEIGHT (<sch:value-of
					select="ancestor::alto:Page/@HEIGHT"/>).</sch:assert>
			<sch:assert
				test="number(@VPOS) + number(@HEIGHT) &lt; number(ancestor::alto:Page/@HEIGHT)"
				>TextBlock VPOS (<sch:value-of select="@VPOS"/>) + TextBlock HEIGHT (<sch:value-of
					select="@HEIGHT"/>) must be less than Page HEIGHT (<sch:value-of
					select="ancestor::alto:Page/@HEIGHT"/>).</sch:assert>
		</sch:rule>
	</sch:pattern>

	<sch:pattern>
		<sch:title>TextLine specific checks</sch:title>
		<sch:rule context="alto:TextLine">
			<sch:assert test="count(./alto:String) &gt; 0">TextLine can not be empty.</sch:assert>
		</sch:rule>
	</sch:pattern>

	<sch:pattern>
		<sch:title>String specific checks</sch:title>
		<sch:rule context="alto:String">
			<sch:assert test="number(@VPOS) &gt;= number(parent::alto:TextLine/@VPOS)">String VPOS
					(<sch:value-of select="@VPOS"/>) must be greater than TextLine VPOS
					(<sch:value-of select="parent::alto:TextLine/@VPOS"/>).</sch:assert>
			<sch:assert
				test="number(@VPOS) + number(@HEIGHT) &lt;= number(parent::alto:TextLine/@VPOS) + number(parent::alto:TextLine/@HEIGHT)"
				>String VPOS (<sch:value-of select="@VPOS"/>) + String HEIGHT (<sch:value-of
					select="@HEIGHT"/>) must be less than the parent TextLine VPOS (<sch:value-of
					select="parent::alto:TextLine/@VPOS"/>) + TextLine HEIGHT (<sch:value-of
					select="parent::alto:TextLine/@HEIGHT"/>). </sch:assert>
		</sch:rule>
	</sch:pattern>


</sch:schema>
