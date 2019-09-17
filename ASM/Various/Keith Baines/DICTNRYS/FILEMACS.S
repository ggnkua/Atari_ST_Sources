
open	MACRO	filename	; open for input
	CLR.W	-(A7)
	PEA	\1
	call_gemdos	$3D,8
	ENDM

create	MACRO	filename
	CLR.W	-(A7)
	PEA	\1
	call_gemdos	$3C,8
	ENDM


close	MACRO	handle
	MOVE.W	\1,-(A7)
	call_gemdos	$3E,4
	ENDM

f_read	MACRO	handle,address,length
	MOVE.L	\2,-(A7)
	MOVE.L	\3,-(A7)
	MOVE.W	\1,-(A7)
	call_gemdos	$3F,12
	ENDM

f_write	MACRO	handle,address,length
	MOVE.L	\2,-(A7)
	MOVE.L	\3,-(A7)
	MOVE.W	\1,-(A7)
	call_gemdos	$40,12
	ENDM	
