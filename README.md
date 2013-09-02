# CallM

CallM is a gene annotation framework that aims to be flexible, transparent, specific and distributed.

It is currently in development, and is not ready for public consumption.

## Jpath format

Central to CallM is the jpath file format, which aims to encapsulate annotation in so that it can be used and shared. It is itself a json format to simplify parsing. It has several parts:

* _proteins_ units of translation
* _components_ equivalent to protein complexes
* _units_ ?
* _homology groups_ proteins that share primary sequence similarity, and possibly function (but not necessarily)
* _pathways_ sets of units that constitute a conceptual metabolic pathway, preferably a linear series of enzymes

## Copyright

Copyright (c) 2013 Ben Woodcroft. See LICENSE.txt for
further details.

