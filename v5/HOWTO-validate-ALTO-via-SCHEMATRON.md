# How to validate an ALTO XML file with the ALTO Schematron

This guide describes how to validate an ALTO file (`alto.xml`) against
`alto_schematron_initial_vX.sch` using free, open-source tools, and
alternatively with Oxygen XML Editor.

The schematron is namespace-agnostic: a single file validates ALTO v1
through v5 documents (the pre-LoC v1 namespace `http://schema.ccs-gmbh.com/ALTO`
as well as `ns-v2#` through `ns-v5#`). Non-ALTO input is reported
explicitly instead of passing silently.

Note that Schematron validation complements, but does not replace, XSD
validation against the official ALTO schema: run both if you need full
conformance checking.

## 1. Command line (Saxon-HE + SchXslt2)

### Prerequisites

| Tool | Tested version | Download |
|---|---|---|
| Java (JRE 11+) | any recent | <https://adoptium.net/> or your package manager |
| Saxon-HE | 13.0 | <https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/> |
| xmlresolver (Saxon dependency) | 6.0.18 | <https://repo1.maven.org/maven2/org/xmlresolver/xmlresolver/> |
| SchXslt2 | 1.11.1 | <https://codeberg.org/SchXslt/schxslt2/releases> |

Unpack the SchXslt2 zip; the only file you need from it is `transpile.xsl`.
The examples below assume `saxon.jar`, `xmlresolver.jar` and
`transpile.xsl` are in the current directory (adjust paths as needed).

### Step 1 — Transpile the schematron to XSLT (once)

Schematron validation is a two-step process: the `.sch` file is first
compiled ("transpiled") into an XSLT stylesheet, which is then applied to
the document under validation.

```sh
java -cp saxon.jar:xmlresolver.jar net.sf.saxon.Transform \
    -xsl:transpile.xsl \
    -s:alto_schematron_initial_v_5_1.sch \
    -o:alto-schematron.xsl
```

(On Windows, use `;` instead of `:` as the classpath separator.)

This step only needs to be repeated when the schematron itself changes.
The generated `alto-schematron.xsl` can be distributed and reused.

### Step 2 — Validate an ALTO file

```sh
java -cp saxon.jar:xmlresolver.jar net.sf.saxon.Transform \
    -xsl:alto-schematron.xsl \
    -s:alto.xml \
    -o:report.svrl
```

The result `report.svrl` is an SVRL document (Schematron Validation Report
Language), the standard XML report format for Schematron.

Note that Saxon exits with status 0 even when the document contains
validation findings; you must inspect the SVRL report to determine the
outcome (see below).

### Batch validation

To validate a directory of ALTO files in one run:

```sh
java -cp saxon.jar:xmlresolver.jar net.sf.saxon.Transform \
    -xsl:alto-schematron.xsl \
    -s:path/to/alto-files/ \
    -o:path/to/reports/
```

Saxon processes every `.xml` file in the source directory and writes one
report per file to the output directory.

## 2. Oxygen XML Editor

Oxygen handles the transpilation internally, so no setup is required:

1. Open the ALTO file to validate.
2. Choose **Document → Validate → Validate with...** and select
   `alto_schematron_initial_vX.sch`.
3. Findings appear in the results pane. The severity shown by Oxygen
   (error / warning / info) is taken from the `role` attribute in the
   schematron.

For recurring use, create a validation scenario (**Document → Validate →
Configure Validation Scenarios...**) that associates the schematron —
optionally alongside the official ALTO XSD — with your ALTO files.

## 3. Reading the SVRL report

The report contains two kinds of findings:

- **`svrl:failed-assert`** — a rule that the document violates.
- **`svrl:successful-report`** — an informational observation (overlapping
  bounding boxes, and the detected ALTO namespace).

Both carry a `role` attribute with the severity, and a `location`
attribute with an XPath pointing at the offending element:

| `role` | Meaning | Emitted for |
|---|---|---|
| `error` | The file contains invalid data | non-numeric or negative coordinates, invalid `FONTSIZE` / `PHYSICAL_IMG_NR`, confidence values out of range (`WC`, `PC`, `ACCURACY`), dangling `TAGREFS` / `STYLEREFS` / `PROCESSINGREFS`, non-ALTO root element |
| `warning` | Suspicious but not fatal | child box not contained in its parent box or `Page`, empty `TextBlock` / `TextLine` / `ComposedBlock` / `Layout`, empty `String/@CONTENT`, unpaired hyphenation parts (`HypPart1`/`HypPart2`, misplaced `HYP`) |
| `info` | Observation, no action required | overlapping blocks / text lines / strings, detected ALTO namespace |

Example finding:

```xml
<svrl:failed-assert location="/Q{...}alto[1]/Q{...}Layout[1]/..."
                    role="error" ...>
    <svrl:text> WIDTH must be a non-negative number; found
        WIDTH='-20' on String ID='String4'. </svrl:text>
</svrl:failed-assert>
```

### Quick pass/fail check in a shell

```sh
# count errors (non-zero means the file has real problems)
grep -c '<svrl:failed-assert[^>]*role="error"' report.svrl

# list all messages
grep -o '<svrl:text>[^<]*' report.svrl
```

### Basic xslt transformation

A xslt transformation is available as svrl-to-html.xslt for an easy to read HTML summary:

```sh
java -cp saxon.jar:xmlresolver.jar net.sf.saxon.Transform \
    -xsl:svrl-to-html.xslt \
    -s:report.svrl \
    -o:report.html
```