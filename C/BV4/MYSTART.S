;*******************************************************************************
;	Bitmap view Copyright (c) 1995 by	Christophe BOYANIQUE
;													http://www.raceme.org
;													tof@raceme.org
;*******************************************************************************
;	This program is free software; you can redistribute it and/or modify it
;	under the terms of the GNU General Public License as published by the Free
;	Software Foundation; either version 2 of the License, or any later version.
;	This program is distributed in the hope that it will be useful, but WITHOUT
;	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;	FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
;	more details.
;	You should have received a copy of the GNU General Public License along
;	with this program; if not, write to the Free Software Foundation, Inc.,
;	59 Temple Place - Suite 330, Boston, MA 02111, USA.
;******************************************************************************

MC68000


*******************************************************************************
*	Export references																				*
*******************************************************************************
	.EXPORT	exit,__exit
	.EXPORT	_BasPag
	.EXPORT	_app
	.EXPORT	errno
	.EXPORT	_AtExitVec,_FilSysVec
	.EXPORT	_RedirTab
	.EXPORT	_StkLim
	.EXPORT	_PgmSize
	.EXPORT	__text,__data,__bss


*******************************************************************************
*	Import references																				*
*******************************************************************************
	.IMPORT	main
	.IMPORT	_fpuinit
	.IMPORT	_StkSize
	.IMPORT	_FreeAll


	.OFFSET	0
*******************************************************************************
*	Base page structure																			*
*******************************************************************************
TpaStart:		.DS.L		1
TpaEnd:			.DS.L		1
TextSegStart:	.DS.L		1
TextSegSize:	.DS.L		1
DataSegStart:	.DS.L		1
DataSegSize:	.DS.L		1
BssSegStart:	.DS.L		1
BssSegSize:		.DS.L		1
DtaPtr:			.DS.L		1
PntPrcPtr:		.DS.L		1
Reserved0:		.DS.L		1
EnvStrPtr:		.DS.L		1
Reserved1:		.DS.B		7
CurDrv:			.DS.B		1
Reserved2:		.DS.L		18
CmdLine:			.DS.B		128
BasePageSize:	.DS		0


	.BSS
*******************************************************************************
*	Data segment																					*
*******************************************************************************
__bss:
_BasPag:			.DS.L		1			*	Pointer to base page
_app:				.DS.W		1			*	Applikation flag
_StkLim:			.DS.L		1			*	Stack limit
_PgmSize:		.DS.L		1			*	Program size
_RedirTab:		.DS.L		6			*	Redirection address table


	.DATA
*******************************************************************************
*	Initialized data segment																	*
*******************************************************************************
__data:
errno:			.DC.W		0				*	Global error variable
_AtExitVec:		.DC.L		0				*	Vector for atexit
_FilSysVec:		.DC.L		0				*	Vector for file system deinitialization


*******************************************************************************
*	Code segment																					*
*******************************************************************************
	.CODE
__text:


******** PcStart **************************************************************
Start:
	BRA		Start0

******* Configuration data ****************************************************
	.DC.L		_RedirTab	*	Redirection array pointer
	.DC.L		_StkSize		*	Stack size entry

******* copyright note ********************************************************
	.ALIGN	16
	.DC.B		'    '
	.DC.B		'----------------'
	.DC.B		' Bitmap View IV '
	.DC.B		'----------------'
	.DC.B		'Christophe      '
	.DC.B		'       Boyanique'
	.DC.B		'                '
	.DC.B		'http://         '
	.DC.B		'  www.raceme.org'
	.DC.B		'                '
	.DC.B		' tof@raceme.org '
	.DC.B		'                '
	.DC.B		' THIS IS GPL !  '
	.DC.B		'----------------'
EmpStr:			.DC.B		$00
	.EVEN


******** Pc startup code ******************************************************

Start0:										* Setup pointer to base page
	MOVE.L	A0,A3
	MOVE.L	A3,D0
	BNE		ACC
	MOVE.L	4(A7),A3		*	BasePagePointer from Stack
	MOVEQ.L	#1,D0			*	Program is Application
	BRA		APP
ACC:
	CLR.W		D0				*	Program is DeskAccessory
APP:
	MOVE.L	A3,_BasPag
	MOVE.W	D0,_app		*	Setup applikation flag


******** Pc startup code ******************************************************
	MOVE.L	TextSegSize(A3),A0	*	Compute size of required memory:
	ADD.L		DataSegSize(A3),A0	*	text segment size + data segment size +
	ADD.L		BssSegSize(A3),A0		*	bss segment size + stack + base page 
	ADD.W		#BasePageSize,A0		*	(base page size includes stack size)
	MOVE.L	A0,_PgmSize

	MOVE.L	A3,D0						*	Setup longword aligned application stack
	ADD.L		A0,D0
	AND.B		#$FC,D0
	MOVE.L	D0,A7

	SUB.L		#_StkSize-256,D0		*	Setup stack limit variable
	MOVE.L	D0,_StkLim

	TST.W		_app						*	check application flag
	BEQ		Start8					*	No environment and no arguments

	SUB.L		#250,D0					*	scan environment
	AND.B		#$FC,D0
	MOVE.L	D0,A1
	MOVE.L	A1,A4
	MOVE.L	EnvStrPtr(A3),A2
	MOVE.L	A2,(A1)+

Start1:
	TST.B		(A2)+
	BNE		Start1
	MOVE.L	A2, (A1)+
	TST.B		(A2)+
	BNE		Start1
	CLR.L		-(A1)

	MOVE.L	A0,-(A7)					*	Free not required memory
	MOVE.L	A3,-(A7)
	MOVE.W	#0,-(A7)
	MOVE.W	#74,-(A7)				*	Mshrink
	TRAP		#1
	LEA.L		12(A7),A7

	LEA		CmdLine(A3),A0			*	scan commandline
	MOVE.B	(A0),D1

	CMP.B		#126,D1					*	Is this a valid command_tail length ?
	BMI		vallidLength
	ADDQ.L	#1,A0
	MOVEQ.L	#-1,D1

getLen:
	ADDQ		#1,D1
	MOVE.B	(A0)+,D0
	BNE		getLen
	LEA		CmdLine(A3),A0

vallidLength:
	MOVE		#1, D3
	EXT.W		D1
	LEA		1(A0, D1.W), A1
	CLR.B		(A1)
	CLR.L		-(A7)						*	argv[argc]=0
	BRA		Start5

Start2:									*	testing blank (seperator)
	CMPI.B	#' '+1,(A1)
	BPL		Start3
	CLR.B		(A1)
	TST.B		1(A1)
	BEQ		Start3
	PEA		1(A1)
	ADDQ		#1, D3
	BRA		Start5

Start3:									*	testing quotation marks
	CMPI.B	#'"',(A1)
	BNE		Start5
	MOVE.B	#0, (A1)

Start4:									*	scan previous
	SUBQ		#1, A1
	CMPI.B	#'"', (A1)
	DBEQ		D1, Start4
	SUBQ		#1, D1
	BMI		Start6
	PEA		1(A1)
	ADDQ		#1,D3
	CLR.B		(A1)

Start5:
	SUBQ.L	#1,A1
	DBF		D1,Start2

Start6:
	TST.B		1(A1)
	BEQ		Start7
	PEA		1(A1)
	ADDQ		#1,D3

Start7:
	PEA		EmpStr
	MOVEA.L	A7,A2

Start8:									*	Test if fpu 68881 is present
	JSR		_fpuinit

******* Test Cookie Jar *******************************************************

;	MOVE.L	#$5F435055,D0			*	'_CPU'
;	BSR		_Startcookie
;	CMPI.L	#$00000014,D0			*	68030 at least !
;	BGE		Start9

;	pea		StartTxt
;	move.w	#9,-(sp)
;	trap		#1
;	addq.l	#6,sp

;	move.w	#7,-(sp)
;	trap		#1
;	addq.l	#2,sp

;	move.l	#0,D0
;	bra		exit
******* Execute main program **************************************************
Start9:
	MOVE		D3,D0			*	Parameter passing:
	MOVE.L	A2,A0			*	<D0.W>	Command line argument count (argc)
	MOVE.L	A4,A1			*	<A0.L>	Command line argument pointer array (argv)
	JSR		main			*	<A1.L>	Tos environment string (env)


******** exit *****************************************************************
exit:
	MOVE.W	D0,-(A7)					*	<D0.W>	Termination status: Integer


	MOVE.L	_AtExitVec,D0			*	Execute all registered atexit procedures
	BEQ		__exit
	MOVE.L	D0,A0
	JSR		(A0)

__exit:
	MOVE.L	_FilSysVec,D0			*	Deinitialize file system
	BEQ		Exit1
	MOVE.L	D0,A0
	JSR		(A0)

Exit1:
	JSR		_FreeAll					*	Deallocate all heap blocks

	MOVE.W	#76,-(A7)				*	Program termination with return code
	TRAP		#1

******* Test Cookie Jar *******************************************************
;_Startcookie:
;	movem.l	a0-a6/d1-d7,-(sp)
;	move.l	d0,d6					;	d6: Cookie recherch‚
;	pea		_StartScookie
;	move.w	#$26,-(sp)
;	trap		#14					;	Supexec !!
;	addq.l	#6,sp
;	move.l	Startlong,d0
;	movem.l	(sp)+,d1-d7/a0-a6
;	rts
;_StartScookie:
;	move.l	$5A0,a6				;	a6: pointeur sur Cookie
;_tst_cook:
;	cmp.l		#0,(a6)				;	Cookie NULL: Fin du Jar
;	bne.s		_ok_cook
;	move.l	#0,Startlong		;	long: valeur du Cookie ou 0
;	bra.s		_end_cook
;_ok_cook:	
;	cmp.l		(a6),d6
;	bne.s		_notyet_cook
;	move.l	4(a6),Startlong
;	bra.s		_end_cook
;_notyet_cook:
;	lea		8(a6),a6
;	bra.s		_tst_cook
;_end_cook:	
;	rts

;Startlong:
;	dc.l		1
;StartTxt:
;	dc.b		'Je veux au moins un 68020 !',13,10
;	dc.b		'I want a 68020 at least !',13,10,0

	.END
******* Module end ************************************************************
