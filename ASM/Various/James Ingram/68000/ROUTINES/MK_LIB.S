* make library
* select "ingnore multilple includes" from control dialog
* and "GST Linkable" from "Format" option on Control dialog


link_library	equ	1

	opt	GST,CASE
	opt	INCONCE		; ignore multiple includes

	opt	o+,ow-

	OUTPUT	c:\routines\LIBRARY.BIN

	include	vdi_defs.i
	include	aes_defs.i
	include	lineadef.i
	include	xbiosdef.i
	include	lens.i
	include	keys.i

	include	linea.s

	include	dialogs.s
	include	aes_calls.s
	include	vdi_calls.s
	include	windows.s

	include	files.s


* have the basic shells down here
* because you must make definitions (XDEF)
* AFTER the references (XREF)!!!

	include	maths.s
	include	bits.s

	include	biosshel.s
	include	xbioshel.s
	include	gem_shel.s
	include	aes_shel.s
	include	vdi_shel.s

