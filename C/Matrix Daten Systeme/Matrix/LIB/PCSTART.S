*      PCSTART.S
*
*      Pure C Startup Code
*
*      Copyright (c) Borland International 1988/89/90
*      All Rights Reserved.


*>>>>>> Export references <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .EXPORT exit, __exit

        .EXPORT _BasPag
        .EXPORT _app
        .EXPORT errno
        .EXPORT _AtExitVec, _FilSysVec
        .EXPORT _RedirTab
        .EXPORT _StkLim
        .EXPORT _PgmSize

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
        MOVE.L  A0, A3
        MOVE.L  A3, D0
        BNE     ACC

        MOVE.L  4(A7), A3   ; BasePagePointer from Stack
        MOVEQ.L #1, D0      ; Program is Application
        BRA     APP
ACC:
        CLR.W   D0          ; Program is DeskAccessory

APP:

        MOVE.L  A3, _BasPag

* Setup applikation flag

        MOVE.W  D0,_app


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

* check application flag

        TST.W   _app
        BEQ     Start8  * No environment and no arguments

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

* scan commandline
        LEA     CmdLine(A3), A0
        MOVE.B  (A0), D1

        CMP.B   #126, D1        * Is this a valid command_tail length ?
        BMI     vallidLength
        ADDQ.L  #1, A0
        MOVEQ.L #-1, D1
getLen:
        ADDQ    #1, D1
        MOVE.B  (A0)+, D0
        BNE     getLen
        LEA     CmdLine(A3), A0

vallidLength:
        MOVE    #1, D3
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
        SUBQ	#1, D1
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
        MOVEA.L A7, A2

* Test if fpu 68881 is present

Start8:
        JSR     _fpuinit

******* Execute main program *******************************************
*
* Parameter passing:
*   <D0.W> = Command line argument count (argc)
*   <A0.L> = Pointer to command line argument pointer array (argv)
*   <A1.L> = Pointer to tos environment string (env)

        MOVE    D3, D0
        MOVE.L  A2, A0
        MOVE.L  A4, A1
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
        MOVE.W  D0,-(A7)

* Execute all registered atexit procedures

        MOVE.L  _AtExitVec,D0
        BEQ     __exit

        MOVE.L  D0,A0
        JSR     (A0)


* Deinitialize file system

__exit:
        MOVE.L  _FilSysVec,D0
        BEQ     Exit1

        MOVE.L  D0,A0
        JSR     (A0)


* Deallocate all heap blocks

Exit1:
        JSR     _FreeAll


* Program termination with return code

        MOVE.W  #76,-(A7)
        TRAP    #1



******* Module end *****************************************************

        .END
