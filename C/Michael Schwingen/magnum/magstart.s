*      MAGSTART.S
*
*      Pure C Startup Code - short version with checksum
*      no commandline arguments
*      no environment
*      no FPU support
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
        .EXPORT __checkok

*>>>>>> Import references <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .IMPORT main
;        .IMPORT _fpuinit
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
_BasPag:    DS.L   1
__checkok:  ds.w 1

* Applikation flag
_app:       DS.W   1

* Stack limit
_StkLim:    DS.L   1

* Program size
_PgmSize:   DS.L   1

* Redirection address table
_RedirTab:  DS.L   6

*>>>>>>> Initialized data segment <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        .DATA
__data:
* Global error variable
errno:      DC.W   0

* Vector for atexit
_AtExitVec: DC.L   0

* Vector for file system deinitialization
_FilSysVec: DC.L   0

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

__ok_sum:DC.L  $12345678
__ok_xor:DC.L  $87654321

EmpStr:  DC.B   $00
         EVEN

_Argv:   dc.l EmpStr
         dc.l 0

******** Pc startup code
* Setup pointer to base page
Start0: MOVE.L  A0, A3
        MOVE.L  A3, D0
        BNE     ACC

        MOVE.L  4(A7), A3   ; BasePagePointer from Stack
        MOVEQ.L #1, D0      ; Program is Application
        BRA     APP
ACC:    CLR.W   D0          ; Program is DeskAccessory
APP:    MOVE.L  A3, _BasPag
* Setup applikation flag
        MOVE.W  D0,_app

* Compute size of required memory
* := text segment size + data segment size + bss segment size
*  + stack size + base page size
* (base page size includes stack size)

        MOVE.L  TextSegSize(A3),A0
        ADD.L   DataSegSize(A3),A0
        move.l  a0,a6
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
        BEQ     Start8  * ACC: No environment and no arguments

* Free not required memory

        MOVE.L  A0,-(A7)
        MOVE.L  A3,-(A7)
        MOVE.W  #0,-(A7)
        MOVE.W  #74,-(A7)
        TRAP    #1
        LEA.L   12(A7),A7

* Test if fpu 68881 is present
Start8:
;        JSR     _fpuinit

; compute XOR and SUM for program + data
        move.l  a6,d3
        sub.l   #__ok_xor+4-Start,d3
        lea     __ok_xor+4(pc),a0
        clr.w   d1
        clr.w   d2
chk1:   move.w  (a0)+,d0
        add.w   d0,d1
        eor.w   d0,d2
        subq.l  #2,d3
        bpl.s   chk1
        cmp.w   __ok_sum,d1
        bne.s   chk2
        cmp.w   __ok_xor,d2
        bne.s   chk2
        add.w   #1,__checkok
chk2:

******* Execute main program *******************************************
*
* Parameter passing:
*   <D0.W> = Command line argument count (argc)
*   <A0.L> = Pointer to command line argument pointer array (argv)
*   <A1.L> = Pointer to tos environment string (env)

        MOVE    #1, D0        ; argc == 1
        lea     _Argv(pc),a0  ; empty argv[] array
        lea     EmpStr(pc),A1 ; no environment
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
