
        .EXPORT _BasPag
        .EXPORT _app
        .EXPORT errno

        .IMPORT main
        .IMPORT _StkSize

        .OFFSET 0

TpaStart:		.DS.L   1
TpaEnd:			.DS.L   1
TextSegStart:	.DS.L   1
TextSegSize:    .DS.L   1
DataSegStart:   .DS.L   1
DataSegSize:    .DS.L   1
BssSegStart:    .DS.L   1
BssSegSize:     .DS.L   1
DtaPtr:         .DS.L   1
PntPrcPtr:      .DS.L   1
Reserved0:      .DS.L   1
EnvStrPtr:      .DS.L   1
Reserved1:      .DS.B   7
CurDrv:         .DS.B   1
Reserved2:      .DS.L   18
CmdLine:        .DS.B   128
BasePageSize:   .DS     0

        .BSS

_BasPag:.DS.L   1
_app:   .DS.W   1

        .DATA

errno:	.DC.W   0

        .CODE

		MOVEQ.L	#0,D0

        MOVE.L  A0,A3
        MOVE.L  A3,D1
        BNE.S   ACC

        MOVE.L  4(A7), A3	; BasePagePointer from Stack
        MOVEQ.L #1,D0		; Program is Application

ACC:  	MOVE.W	D0,_app
		MOVE.L  A3,_BasPag

		MOVE.L  TextSegSize(A3),A0
        ADD.L   DataSegSize(A3),A0
        ADD.L   BssSegSize(A3),A0
        ADD.W   #BasePageSize,A0

        MOVE.L  A3,D0
        ADD.L   A0,D0
        AND.B   #$FC,D0
        MOVE.L  D0,A7

		PEA		(A0)
		PEA		(A3)
        CLR.W	-(A7)
        MOVE.W  #74,-(A7)
        TRAP    #1
        LEA.L   12(A7),A7

        BSR     main

        CLR.W	-(A7)
        TRAP    #1

        .END
