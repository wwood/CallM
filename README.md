# CallM

CallM is a gene annotation framework that aims to be flexible, transparent, specific and distributed.

It is currently in development, and is not ready for public consumption.

## Jpath format

Central to CallM is the jpath file format, which aims to encapsulate annotation in so that it can be used and shared. It is itself a json format to simplify parsing. It has several parts:

* **proteins** units of translation
* **components** equivalent to protein complexes
* **units** ? a group of proteins that carry out a certain function ?
* **homology** groups_ proteins that share primary sequence similarity, and possibly function (but not necessarily)
* **pathways** sets of units that constitute a conceptual metabolic pathway, preferably a linear series of enzymes

## Copyright

Copyright (c) 2013 Ben Woodcroft. See LICENSE.txt for
further details.

