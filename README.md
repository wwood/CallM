# CallM

CallM is a gene annotation framework that aims to be flexible, transparent, specific and distributed.

It is currently in development, and is not ready for public consumption.

## Jpath format

Central to CallM is the jpath file format, which aims to encapsulate annotation in so that it can be used and shared. It is itself a json format to simplify parsing. It has several parts:

* **units** roughly equivalent to a proteins (translated sequences)
* **components** roughly equivalent to protein complexes
* **homology groups** proteins that share primary sequence similarity, and possibly function (but not necessarily)
* **pathways** sets of units that constitute a conceptual metabolic pathway, preferably a linear series of steps,
  where each step is defined by either a protein, a component or a unit.

## Copyright

Copyright (c) 2013 Ben Woodcroft. See LICENSE.txt for
further details.

