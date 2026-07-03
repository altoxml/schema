<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl">

  <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-public="-//W3C//DTD HTML 4.01//EN"/>

  <!-- Key to look up svrl:active-pattern by its id attribute -->
  <xsl:key name="patternById" match="svrl:active-pattern" use="@id"/>

  <!-- ============================================================ -->
  <!-- Root template                                                -->
  <!-- ============================================================ -->
  <xsl:template match="/">
    <xsl:variable name="errorCount"   select="count(//svrl:failed-assert[@role='error'])"/>
    <xsl:variable name="warningCount" select="count(//svrl:failed-assert[@role='warning'])"/>
    <xsl:variable name="infoCount"    select="count(//svrl:successful-report[@role='info'])"/>

    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <title>Schematron Validation Report</title>
        <style>
          body            { font-family: Arial, sans-serif; font-size: 13px; margin: 24px; color: #222; }
          h1              { font-size: 20px; color: #333; margin-bottom: 4px; }
          h2              { font-size: 15px; margin-top: 28px; margin-bottom: 6px; }
          .summary        { background: #f4f4f4; border: 1px solid #ddd; border-radius: 4px;
                            padding: 12px 18px; margin: 16px 0 24px 0; display: inline-block; }
          .summary span   { margin-right: 18px; font-weight: bold; }
          .cnt-error      { color: #b00020; }
          .cnt-warning    { color: #b06000; }
          .cnt-info       { color: #005faf; }
          table           { border-collapse: collapse; width: 100%; margin-bottom: 10px; }
          th              { background: #e8e8e8; border: 1px solid #ccc; padding: 7px 10px;
                            text-align: left; font-size: 12px; }
          td              { border: 1px solid #ddd; padding: 6px 10px; vertical-align: top; }
          .col-level      { width: 80px;  white-space: nowrap; font-weight: bold; }
          .col-test       { width: 220px; }
          .col-msg        { }
          .row-error   td { background: #fff5f5; }
          .row-warning td { background: #fffbf0; }
          .row-info    td { background: #f0f6ff; }
          .lbl-error      { color: #b00020; }
          .lbl-warning    { color: #b06000; }
          .lbl-info       { color: #005faf; }
          .none           { color: #888; font-style: italic; margin: 4px 0 20px 0; }
        </style>
      </head>
      <body>

        <h1>Schematron Validation Report</h1>

        <!-- ====================================================== -->
        <!-- Summary                                                 -->
        <!-- ====================================================== -->
        <div class="summary">
          <span class="cnt-error">
            <xsl:value-of select="$errorCount"/> error<xsl:if test="$errorCount != 1">s</xsl:if>
          </span>
          <span class="cnt-warning">
            <xsl:value-of select="$warningCount"/> warning<xsl:if test="$warningCount != 1">s</xsl:if>
          </span>
          <span class="cnt-info">
            <xsl:value-of select="$infoCount"/> info<xsl:if test="$infoCount != 1"> messages</xsl:if><xsl:if test="$infoCount = 1"> message</xsl:if>
          </span>
        </div>

        <!-- ====================================================== -->
        <!-- Errors table                                            -->
        <!-- ====================================================== -->
        <h2>&#9940; Errors (<xsl:value-of select="$errorCount"/>)</h2>
        <xsl:choose>
          <xsl:when test="$errorCount > 0">
            <table>
              <thead>
                <tr>
                  <th class="col-level">Level</th>
                  <th class="col-test">Test Name</th>
                  <th class="col-msg">Message</th>
                </tr>
              </thead>
              <tbody>
                <xsl:for-each select="//svrl:failed-assert[@role='error']">
                  <tr class="row-error">
                    <td class="col-level lbl-error">Error</td>
                    <td class="col-test">
                      <xsl:value-of select="key('patternById', @patternId)/@name"/>
                    </td>
                    <td class="col-msg">
                      <xsl:value-of select="normalize-space(svrl:text)"/>
                    </td>
                  </tr>
                </xsl:for-each>
              </tbody>
            </table>
          </xsl:when>
          <xsl:otherwise>
            <p class="none">No errors.</p>
          </xsl:otherwise>
        </xsl:choose>

        <!-- ====================================================== -->
        <!-- Warnings table                                          -->
        <!-- ====================================================== -->
        <h2>&#9888; Warnings (<xsl:value-of select="$warningCount"/>)</h2>
        <xsl:choose>
          <xsl:when test="$warningCount > 0">
            <table>
              <thead>
                <tr>
                  <th class="col-level">Level</th>
                  <th class="col-test">Test Name</th>
                  <th class="col-msg">Message</th>
                </tr>
              </thead>
              <tbody>
                <xsl:for-each select="//svrl:failed-assert[@role='warning']">
                  <tr class="row-warning">
                    <td class="col-level lbl-warning">Warning</td>
                    <td class="col-test">
                      <xsl:value-of select="key('patternById', @patternId)/@name"/>
                    </td>
                    <td class="col-msg">
                      <xsl:value-of select="normalize-space(svrl:text)"/>
                    </td>
                  </tr>
                </xsl:for-each>
              </tbody>
            </table>
          </xsl:when>
          <xsl:otherwise>
            <p class="none">No warnings.</p>
          </xsl:otherwise>
        </xsl:choose>

        <!-- ====================================================== -->
        <!-- Info table                                              -->
        <!-- ====================================================== -->
        <h2>&#8505; Info (<xsl:value-of select="$infoCount"/>)</h2>
        <xsl:choose>
          <xsl:when test="$infoCount > 0">
            <table>
              <thead>
                <tr>
                  <th class="col-level">Level</th>
                  <th class="col-test">Test Name</th>
                  <th class="col-msg">Message</th>
                </tr>
              </thead>
              <tbody>
                <xsl:for-each select="//svrl:successful-report[@role='info']">
                  <tr class="row-info">
                    <td class="col-level lbl-info">Info</td>
                    <td class="col-test">
                      <xsl:value-of select="key('patternById', @patternId)/@name"/>
                    </td>
                    <td class="col-msg">
                      <xsl:value-of select="normalize-space(svrl:text)"/>
                    </td>
                  </tr>
                </xsl:for-each>
              </tbody>
            </table>
          </xsl:when>
          <xsl:otherwise>
            <p class="none">No info messages.</p>
          </xsl:otherwise>
        </xsl:choose>

      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>