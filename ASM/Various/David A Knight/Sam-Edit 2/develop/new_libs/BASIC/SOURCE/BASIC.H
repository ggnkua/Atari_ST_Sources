	OUTPUT	d:\develop\new_libs\basic\basic.app

minX	equ	640
minY	equ	185	; (allow for menu bar)

	SECTION	data
resourceFile	dc.b	'basic.rsc',0
version	dc.b	'Version: 2.00  (26/12/1997)',0

	SECTION	text

	bra	initProgram

