|
| Helper for defining consecutive cell offsets of a data structure
|

.MACRO CELLS members:vararg
.IRP member \members
\member = OFFSET
OFFSET = OFFSET + CELL_BYTES
.ENDR
.ENDM

| vim: set ts=16:
