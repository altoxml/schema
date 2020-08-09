## [ALTO XML schema](https://github.com/altoxml/schema/wiki)
This repository contains ALTO schema versions - drafts and final released ones.

All open issues and discussions about changes to the ALTO standard can be found and tracked in the [issues](https://github.com/altoxml/schema/issues) repository

Latest official schema version is 4.1.<br>
Primary source for the schema is (http://www.loc.gov/standards/alto/v4/alto-4-1.xsd)<br>
Alternate source for the schema is (https://cdn.rawgit.com/altoxml/schema/master/v4/alto-4-1.xsd)<br>

Summary of changes

* Changed schema version to 4.1
* Fix for Processing including  processingStepType.
* Add missing PROCESSINGREFS to PageType, PageSpaceType, BlockType, TextLine, StringType for referencing Processing history.

Draft schema version is 4.2 available for comment

Summary of proposed changes

* Change schema version to 4.2
* Change BASELINE to accommodate a list of points in addition to a single point
* Make FONTSIZE optional
* Add "strikethrough" to list of allowed values for FONTSTYLE

Details about the changes of the version and further documentation can be found in the ALTO
[documentation](https://github.com/altoxml/documentation/wiki) repository.

