## [ALTO XML schema](https://github.com/altoxml/schema/wiki)
This repository contains ALTO schema versions - drafts and final released ones.

All open issues and discussions about changes to the ALTO standard can be found and tracked in the [issues](https://github.com/altoxml/schema/issues) repository

Latest official schema version is 4.0.<br>
Primary source for the schema is (http://www.loc.gov/standards/alto/v4/alto-4-0.xsd)<br>
Alternate source for the schema is (https://cdn.rawgit.com/altoxml/schema/master/v4/alto-4-0.xsd)<br>

Summary of changes

* Changed schema version to 4.0
* Changed namespace and targetNamespace to http://www.loc.gov/standards/alto/ns-v4#
* Clarification and definition of the licensing to common standard "CC BY-SA 4.0" for this ALTO standard (with agreement of the authors)
* Added character based text description with new Glyph element and its subelement Variant (GlyphType, VariantType)
* Extended annotation for clarification of the difference of existing element ALTERNATIVE and Glyph/Variant
* Introduced generic "Processing" and deprecate "OcrProcessing"
* Introduce generic "processingStep" with "ProcessingStepType" and required attribute "ID" and deprecate "preProcessingStep", "ocrProcessingStep", "postProcessingStep"
* Add common vocabulary for "processingStep" comprising the "ContentGeneration", "ContentModification", "PreOperation", "PostOperation", "Other"
* Fix for the element Shape. The Shape element can now only be used once within a PageSpace or a TextLine as it was intended.

Details about the changes of the version and further documentation can be found in the ALTO
[documentation](https://github.com/altoxml/documentation/wiki) repository.

