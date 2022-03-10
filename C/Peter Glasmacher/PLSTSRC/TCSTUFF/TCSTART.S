*      TCSTART.S
*
*      Turbo C Startup Code, Beta Release 1.1b
*
*      Copyright (c) Borland International 1988
*      All Rights Reserved.


*>>>>>> Export references <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .EXPORT exit

        .EXPORT _BasPag
        .EXPORT _AccFlag
        .EXPORT errno
        .EXPORT _AtExitVec, _FilSysVec
        .EXPORT _RedirTab




*>>>>>> Import references <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .IMPORT main
        .IMPORT _FpuIni
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


* Pointer to base page

_BasPag:
        .DS.L   1


* Accessory flag

_AccFlag:
        .DS.W   1


* Redirection address table

_RedirTab:
        .DS.L   6




*>>>>>>> Initialized data segment <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .DATA


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

TcStart:
        BRA.B   TcStart0



******* Configuration data


* Redirection array pointer

        .DC.L   _RedirTab


* Stack size entry

        .DC.L   _StkSize



******* Tc library copyright note

        .ALIGN  16

        .DC.B   '>>> TURBO-C <<<<'
        .DC.B   '  for ATARI-ST  '
        .DC.B   ' á Release 1.1b '
        .DC.B   ' (C) 88 Borland '
        .DC.B   ' International  '

EmpStr:
        .DC.B   $00
        .EVEN



******** Tc startup code

* Setup pointer to base page

TcStart0:
        LEA.L   TcStart-256(PC),A3
        MOVE.L  A3,_BasPag


* Setup accessory flag

        TST.L   PntPrcPtr(A3)
        SEQ.B   D0
        EXT.W   D0
        MOVE.W  D0,_AccFlag


* Compute size of required memory


* Compute size of required memory
* := text segment size + data segment size + bss segment size
*  + stack size + base page size

        MOVE.L  TextSegSize(A3),A0
        ADD.L   DataSegSize(A3),A0
        ADD.L   BssSegSize(A3),A0
        ADD.W   #BasePageSize,A0


* Setup longword aligned application stack

        MOVE.L  A3,D0
        ADD.L   A0,D0
        AND.B   #$FC,D0
        MOVE.L  D0,A7


* Free not required memory

        MOVE.L  A0,-(A7)
        MOVE.L  A3,-(A7)
        MOVE.W  #0,-(A7)
        MOVE.W  #74,-(A7)
        TRAP    #1
        LEA.L   12(A7),A7


* Test if fpu 68881 is present

        JSR     _FpuIni


* Allocate space for command line tail on stack

TcStart2:
        MOVEQ.L #1,D0
        CLR.W   D1

        LEA.L   CmdLine(A3),A0
        MOVE.W  (A0),D2
        CMP.W   #$601E,D2
        BEQ     TcStart4
        CMP.W   #$602E,D2
        BEQ     TcStart4

        MOVE.B  (A0)+,D1
        BEQ     TcStart4

        MOVE.W  D1,D2
        ADDQ.W  #1+1,D2
        AND.W   #$0FFE,D2
        SUB.W   D2,A7


* Copy command line tail to stack

        MOVE.L  A7,A1
        MOVE.W  D1,D2
        SUBQ.W  #1,D2
TcStart3:
        MOVE.B  (A0)+,(A1)+
        DBRA    D2,TcStart3


* Scan command line tail backwards for arguments
* Count arguments and build argument pointer array
* Insert terminator after each command argument

TcStart4:
        CLR.L   -(A7)                   ;argv[argc] := 0.

        MOVEQ.L #' ',D2
TcStart5:
        SUBQ.W  #1,D1
        BCS     TcStart8
        CMP.B   -(A1),D2
        BHS     TcStart5

        CLR.B   1(A1)

TcStart6:
        SUBQ.W  #1,D1
        BCS     TcStart7
        CMP.B   -(A1),D2
        BLO     TcStart6

        PEA.L   1(A1)
        ADDQ.W  #1,D0
        BRA     TcStart5

TcStart7:
        MOVE.L  A1,-(A7)
        ADDQ.W  #1,D0


TcStart8:
        PEA.L   EmpStr(PC)              ;argv[0] := ^emptystring.



******* Execute main program *******************************************
*
* Parameter passing:
*   <D0.W> = Command line argument count (argc)
*   <A0.L> = Pointer to command line argument pointer array (argv)
*   <A1.L> = Pointer to tos environment string (env)

        MOVE.L  EnvStrPtr(A3),A1
        MOVE.L  A7,A0
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
        BEQ     Exit0

        MOVE.L  D0,A0
        JSR     (A0)


* Deinitialize file system

Exit0:
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