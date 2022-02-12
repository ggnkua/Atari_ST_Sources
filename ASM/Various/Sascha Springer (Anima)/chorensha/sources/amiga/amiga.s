
OldOpenLibrary = -$0198
CloseLibrary = -$019e
PutStr = -$3b4

	text

start:
	move.l	$4.w,a6
	lea		dos_lib_name,a1
	jsr		OldOpenLibrary(a6)

	move.l	d0,a6
	beq		.skip

	move.l	#string,d1
	jsr		PutStr(a6)

	move.l	a6,a1
	move.l	$4.w,a6
	jsr		CloseLibrary(a6)

.skip:
	rts

	data

dos_lib_name:
	dc.b	'dos.library',0

string:
	dc.b	'Hello World!',10,13,0

