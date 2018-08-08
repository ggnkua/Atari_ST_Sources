*      PCSTART.S
*
*      Pure C Startup Code
*	   adapted for fixed Stack
*      Copyright (c) Borland International 1988/89/90
*      All Rights Reserved.

cfgStackSize = 4096
intStackSize = 4096

*>>>>>> Export references <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .EXPORT exit, __exit

        .EXPORT _BasPag
        .EXPORT errno
        .EXPORT _AtExitVec, _FilSysVec
        .EXPORT _RedirTab
        .EXPORT _StkLim
        .EXPORT _PgmSize
        .EXPORT	_cfgStackTop,_intStackTop

        .EXPORT __text, __data, __bss

*>>>>>> Import references <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .IMPORT main
        .IMPORT _fpuinit
        .IMPORT _StkSize
        .IMPORT _FreeAll
        
*>>>>>> Data structures <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


* Base page structure

        .OFFSET 0

TpaStart:
        .DS.L   1
TpaEnd:
        .DS.L   1
TextSegStart:
        .DS.L   1
TextSegSize:
        .DS.L   1
DataSegStart:
        .DS.L   1
DataSegSize:
        .DS.L   1
BssSegStart:
        .DS.L   1
BssSegSize:
        .DS.L   1
DtaPtr:
        .DS.L   1
PntPrcPtr:
        .DS.L   1
Reserved0:
        .DS.L   1
EnvStrPtr:
        .DS.L   1
Reserved1:
        .DS.B   7
CurDrv:
        .DS.B   1
Reserved2:
        .DS.L   18
CmdLine:
        .DS.B   128
BasePageSize:
        .DS     0



*>>>>>>> Data segment <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .BSS
__bss:

* Pointer to base page

_BasPag:
        .DS.L   1

_cfgStackTop:
		.ds.l	1

_intStackTop:
		.ds.l	1

* Stack limit

_StkLim:
        .DS.L   1

* Program size

_PgmSize:
        .DS.L   1

* Redirection address table

_RedirTab:
        .DS.L   6

*>>>>>>> Initialized data segment <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .DATA
__data:

* Global error variable

errno:
        .DC.W   0


* Vector for atexit

_AtExitVec:
        .DC.L   0


* Vector for file system deinitialization

_FilSysVec:
        .DC.L   0


*>>>>>>> Code segment <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .CODE
__text:


******** PcStart ********************************************************

Start:
        BRA.B   Start0



******* Configuration data


* Redirection array pointer

        .DC.L   _RedirTab


* Stack size entry

        .DC.L   _StkSize



******* Pc library copyright note

        .ALIGN  16

        .DC.B   '>>>> PURE-C <<<<'
        .DC.B   '  for ATARI-ST  '
        .DC.B   '  Version  1.0  '
        .DC.B   '(C)88-90 Borland'
        .DC.B   ' International  '

EmpStr:
        .DC.B   $00
        .EVEN



******** Pc startup code

* Setup pointer to base page

Start0:
        MOVE.L  4(A7), A3   ; BasePagePointer from Stack
        MOVE.L  A3, _BasPag

* Compute size of required memory
* := text segment size + data segment size + bss segment size
*  + stack size + base page size
* (base page size includes stack size)

        MOVE.L  $18(a3),a0	; Start of BSS
        ADDA.L  $1c(A3),A0	; Size of BSS
		ADDA.L	#cfgStackSize,a0
		move.l	a0,a7
		move.l	a0,_cfgStackTop

		ADDA.L	#intStackSize,a0
		move.l	a0,_intStackTop
		

* The next 2 lines are switched from original as per earx on IRC
		suba.l	_BasPag,a0
        MOVE.L  A0, _PgmSize

		move.l	a0,-(sp)
		move.l	_BasPag,-(sp)
		clr.w	-(sp)
		move.w	#$4a,-(sp)
		trap	#1
		lea		12(sp),sp

******* Execute main program *******************************************
*
* Parameter passing:
*   <D0.W> = Command line argument count (argc)
*   <A0.L> = Pointer to command line argument pointer array (argv)
*   <A1.L> = Pointer to tos environment string (env)

		MOVEQ	#0,d0
		MOVEA.L	d0,a0
		MOVEA.L	d0,a1
        JSR     main



******** exit ***********************************************************
*
* Terminate program
*
* Entry parameters:
*   <D0.W> = Termination status : Integer
* Return parameters:
*   Never returns

exit:
		move.w	d0,-(sp)
		move.l	_PgmSize,-(sp)
		move.w	#$31,-(sp)
		trap	#1
		addq.l	#8,sp


******* Module end *****************************************************

        .END