*      TCSTART.S
*
*      Turbo C Startup Code, Version 1.1
*
*      Copyright (c) Borland International 1988/89
*      All Rights Reserved.


*>>>>>> Export references <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .EXPORT exit, _exit

        .EXPORT _BasPag
        .EXPORT _app
        .EXPORT errno
        .EXPORT _AtExitVec, _FilSysVec
        .EXPORT _RedirTab
        .EXPORT _StkLim
        .EXPORT _PgmSize

		.EXPORT function_number

		.EXPORT wort1
		.EXPORT wort2
		.EXPORT wort3
		.EXPORT wort4
		.EXPORT wort5
		.EXPORT wort6
		.EXPORT wort7
		.EXPORT wort8

		.EXPORT long1
		.EXPORT long2
		.EXPORT long3
		.EXPORT long4
		.EXPORT long5


*>>>>>> Import references <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .IMPORT _StkSize
        .IMPORT _FreeAll

        .IMPORT	gfa_call_function

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


* Pointer to base page

_BasPag:
        .DS.L   1


* Applikation flag

_app:
        .DS.W   1


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

* GFA-Stack
gfastack:
        .DC.L   0

* Turbo-stack
turbostack:
        .DC.L   0


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

******** TcStart ********************************************************

Start:  BRA   Start0

wort1:		.DC.W	0			; Offsets in GFA +4
wort2:		.DC.W	2
wort3:		.DC.W	4
wort4:		.DC.W	6
wort5:		.DC.W	8
wort6:		.DC.W	10
wort7:		.DC.W	12
wort8:		.DC.W	14

long1:		.DC.L	16
long2:		.DC.L	20
long3:		.DC.L	24
long4:		.DC.L	28
long5:		.DC.L	32

function_number:	.DC.W	36

ad1:		.DS.L   38

******* Configuration data


* Redirection array pointer
        .DC.L   _RedirTab

* Stack size entry
        .DC.L   _StkSize

******* Tc library copyright note

        .ALIGN  16
        .DC.B   '    >>> TURBO-C <<<<   '
        .DC.B   ' v1.x/gfa (st) overlay '
        .DC.B   ' (C)88/89 Borland Int. '
        .DC.B   '   modified 03.90 by   '
        .DC.B   '    Sascha Ldemann    '
        .DC.B   '  						'

EmpStr: .DC.B   $00
        .EVEN



******** Tc startup code

* Setup pointer to base page

Start0: MOVE.L  A7, gfastack

        * initialisation de l'adresse de saut pour le GFA

        MOVE.L  #rout1,ad1

        * ENDE der Initialisierung

        MOVE.L  #0, A3
        MOVE.L  A3, D0

        MOVE.L  4(A7), A3   ; BasePagePointer from Stack
        MOVEQ.L #1, D0      ; Program is Application
APP:

        MOVE.L  A3, _BasPag

* Setup application flag

        MOVE.W  D0,_app

* Compute size of required memory


* Compute size of required memory
* := text segment size + data segment size + bss segment size
*  + stack size + base page size
* (base page size includes stack size)

        MOVE.L  TextSegSize(A3),A0
        ADD.L   DataSegSize(A3),A0
        ADD.L   BssSegSize(A3),A0
        ADD.W   #BasePageSize,A0
        MOVE.L  A0, _PgmSize

* Setup longword aligned application stack

        MOVE.L  A3,D0
        ADD.L   A0,D0
        AND.B   #$FC,D0
        MOVE.L  D0,A7

* Setup stack limit variable

        SUB.L   #_StkSize-256,D0
        MOVE.L  D0,_StkLim

* scan environment

        SUB.L   #250, D0
        AND.B   #$FC, D0
        MOVE.L  D0, A1
        MOVE.L  A1, A4
        MOVE.L  EnvStrPtr(A3), A2
        MOVE.L  A2, (A1)+
Start1:
        TST.B   (A2)+
        BNE     Start1
        MOVE.L  A2, (A1)+
        TST.B   (A2)+
        BNE     Start1
        CLR.L   -(A1)

* Free not required memory

        MOVE.L  A0,-(A7)
        MOVE.L  A3,-(A7)
        MOVE.W  #0,-(A7)
        MOVE.W  #74,-(A7)
        TRAP    #1
        LEA.L   12(A7),A7


* Test if fpu 68881 is present
*        JSR     _FpuInit


* scan commandline
        LEA     CmdLine(A3), A0
        MOVE    #1, D3
        MOVE.B  (A0), D1
        EXT.W   D1
        LEA     1(A0, D1.W), A1
        CLR.B   (A1)
        CLR.l   -(A7)           * argv[argc] = 0
        BRA     Start5

Start2:                         * testing blank (seperator)
        CMPI.B  #' '+1, (A1)
        BPL     Start3
        CLR.B   (A1)
        TST.B   1(A1)
        BEQ     Start3
        PEA     1(A1)
        ADDQ    #1, D3
        BRA     Start5

Start3:                         * testing quotation marks
        CMPI.B  #'"', (A1)
        BNE     Start5
        MOVE.B  #0, (A1)

Start4:                         * scan previous
        SUBQ    #1, A1
        CMPI.B  #'"', (A1)
        DBEQ    D1, Start4
        TST     D1
        BMI     Start6
        PEA     1(A1)
        ADDQ    #1, D3
        CLR.B   (A1)

Start5:
        SUBQ.L  #1, A1
        DBF     D1, Start2

Start6:
        TST.B   1(A1)
        BEQ     Start7
        PEA     1(A1)
        ADDQ    #1, D3

Start7:
        PEA     EmpStr
        MOVE.L  A7, A2


******* Execute main program *******************************************
*
* Parameter passing:
*   <D0.W> = Command line argument count (argc)
*   <A0.L> = Pointer to command line argument pointer array (argv)
*   <A1.L> = Pointer to tos environment string (env)

        MOVE    D3, D0
        MOVE.L  A2, A0
        MOVE.L  A4, A1
        MOVE.L  A7,turbostack

		moveq #0,d0

        MOVE.L  gfastack,A7
        rts

rout1:	MOVE.L  A7,gfastack
        MOVE.L  turbostack,A7

*		illegal

		bsr		gfa_call_function

		MOVE.L  A7,turbostack
        MOVE.L  gfastack,A7
        rts




******** exit ***********************************************************
*
* Terminate program
*
* Entry parameters:
*   <D0.W> = Termination status : Integer
* Return parameters:
*   Never returns

exit:   MOVE.L A7,gfastack
        MOVE.L turbostack,A7

        MOVE.L EnvStrPtr,D0
*	    MOVE.L D0,errtext

* Execute all registered atexit procedures

        MOVE.L  _AtExitVec,D0
        BEQ     _exit

        MOVE.L  D0,A0
        JSR     (A0)


* Deinitialize file system

_exit:
        MOVE.L  _FilSysVec,D0
        BEQ     Exit1

        MOVE.L  D0,A0
        JSR     (A0)


* Deallocate all heap blocks

Exit1:
        JSR     _FreeAll


* Program termination with return code

        MOVE.L  gfastack,A7
        rts



******* Module end *****************************************************

        .END
