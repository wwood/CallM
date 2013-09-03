# CallM

CallM is a gene annotation framework that aims to be flexible, transparent, specific and distributed.

It is currently in development, and is not ready for public consumption.

## Jpath format

Central to CallM is the jpath file format, which aims to encapsulate annotation in so that it can be used and shared. It is itself a json format to simplify parsing. It has several parts:

* **proteins** translated sequences that form the base building block of annotation
* **components** equivalent to protein complexes
* **units** one or more proteins or components that carry out a certain function
* **homology groups** proteins that share primary sequence similarity, and possibly function (but not necessarily)
* **pathways** sets of units that constitute a conceptual metabolic pathway, preferably a linear series of steps,
  where each step is defined by either a protein, a component or a unit.

## Copyright

Copyright (c) 2013 Ben Woodcroft. See LICENSE.txt for
further details.

