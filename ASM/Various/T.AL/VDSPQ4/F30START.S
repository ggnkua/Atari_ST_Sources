;
;	F30START.S
;
; based on TCSTART.S, Turbo C Startup Code, Version 2.0
; Copyright (c) Borland International 1988/89/90
; All Rights Reserved.
;
; (c) T.AL 94
; done using Brainstorm's Assemble
;

	opt l1
	
	;Export references 
	EXPORT exit,_exit

	EXPORT _BasPag
	EXPORT _app
	EXPORT errno
	EXPORT _AtExitVec,_FilSysVec
	EXPORT _RedirTab
	EXPORT _StkLim
	EXPORT _PgmSize

	EXPORT __text,__data,__bss

	;Import references 
	IMPORT main
	IMPORT _fpuinit
	IMPORT _StkSize
	IMPORT _FreeAll

	IMPORT vmodes
		
	;Base page structure
	OFFSET 0

TpaStart	DS.L   1
TpaEnd	DS.L   1
TextSegStart	DS.L   1
TextSegSize	DS.L   1
DataSegStart	DS.L   1
DataSegSize	DS.L   1
BssSegStart	DS.L   1
BssSegSize	DS.L   1
DtaPtr	DS.L   1
PntPrcPtr	DS.L   1
Reserved0	DS.L   1
EnvStrPtr	DS.L   1
Reserved1	DS.B   7
CurDrv	DS.B   1
Reserved2	DS.L   18
CmdLine	DS.B   128
BasePageSize	DS     0

	TEXT
__text:

Start	BRA    Start0

	;Configuration data
	DC.L   _RedirTab	; Redirection array pointer
	DC.L   _StkSize		; Stack size entry

	ALIGN  16

	DC.B   '>>>> PURE C <<<<'
	DC.B   '  for ATARI-ST  '
	DC.B   '  Version  1.0  '
	DC.B   '(C)88-90 Borland'
	DC.B   ' International  '
	DC.B   '                '
	DC.B   ' F030 startup by'
	DC.B   '     T.AL 94    '
	DC.B   '>>>>>>>><<<<<<<<'

EmpStr	DC.B   $00
	EVEN

;Setup pointer to base page
Start0	MOVE.L  A0,A3
	MOVE.L  A3,D0
	BNE     ACC

	MOVE.L  4(A7),A3	; BasePagePointer from Stack
	MOVEQ.L #1,D0		; Program is Application
	BRA     APP

ACC	CLR.W   D0		; Program is DeskAccessory

APP	MOVE.L  A3,_BasPag

	;Setup applikation flag
	MOVE.W  D0,_app


;Compute size of required memory
;:= text segment size + data segment size + bss segment size
; + stack size + base page size
;(base page size includes stack size)

	MOVE.L  TextSegSize(A3),A0
	ADD.L   DataSegSize(A3),A0
	ADD.L   BssSegSize(A3),A0
	ADD.W   #BasePageSize,A0
	MOVE.L  A0,_PgmSize

	;Setup longword aligned application stack
	MOVE.L  A3,D0
	ADD.L   A0,D0
	AND.B   #$FC,D0
	MOVE.L  D0,A7

	;Setup stack limit variable
	SUB.L   #_StkSize-256,D0
	MOVE.L  D0,_StkLim

	;check application flag
	TST.W   _app
	BEQ     Start8  	;No environment and no arguments

	;scan environment
	SUB.L   #250,D0
	AND.B   #$FC,D0
	MOVE.L  D0,A1
	MOVE.L  A1,A4
	MOVE.L  EnvStrPtr(A3),A2
	MOVE.L  A2,(A1)+

Start1	TST.B   (A2)+
	BNE     Start1
	MOVE.L  A2,(A1)+
	TST.B   (A2)+
	BNE     Start1
	CLR.L   -(A1)

	;Free not required memory
	MOVE.L  A0,-(A7)
	MOVE.L  A3,-(A7)
	MOVE.W  #0,-(A7)
	MOVE.W  #74,-(A7)
	TRAP    #1
	LEA.L   12(A7),A7
	
	;scan commandline
	LEA     CmdLine(A3),A0
	MOVE    #1,D3
	MOVE.B  (A0),D1
	EXT.W   D1
	LEA     1(A0,D1.W),A1
	CLR.B   (A1)
	CLR.l   -(A7)		;argv[argc] = 0
	BRA     Start5

Start2	CMPI.B  #' '+1,(A1)	;testing blank (seperator)
	BPL     Start3
	CLR.B   (A1)
	TST.B   1(A1)
	BEQ     Start3
	PEA     1(A1)
	ADDQ    #1,D3
	BRA     Start5

Start3	CMPI.B  #'"',(A1)	;testing quotation marks
	BNE     Start5
	MOVE.B  #0,(A1)

Start4	SUBQ    #1,A1		;scan previous
	CMPI.B  #'"',(A1)
	DBEQ    D1,Start4
	TST     D1
	BMI     Start6
	PEA     1(A1)
	ADDQ    #1,D3
	CLR.B   (A1)

Start5	SUBQ.L  #1,A1
	DBF     D1,Start2

Start6	TST.B   1(A1)
	BEQ     Start7
	PEA     1(A1)
	ADDQ    #1,D3

Start7	PEA     EmpStr
	MOVEA.L A7,A2

;Test if fpu 68881 is present
Start8	JSR     _fpuinit
	
	pea save		; save hardware
	move.w #$26,-(sp)
	trap #14
	addq.w #6,sp

	pea fucknvdi		;fuck nvdi
	move.w #$26,-(sp)
	trap #14
	addq.w #6,sp
	
	pea init		; init hardware
	move.w #$26,-(sp)
	trap #14
	addq.w #6,sp

;Execute main program 
;Parameter passing:
;  D0.W = Command line argument count (argc)
;  A0.L = Pointer to command line argument pointer array (argv)
;  A1.L = Pointer to tos environment string (env)

	MOVE    D3,D0
	MOVE.L  A2,A0
	MOVE.L  A4,A1
	JSR     main

;exit 
;Terminate program
;Entry parameters:
;  D0.W = Termination status : Integer
;Return parameters:
;  Never returns

exit	MOVE.W  D0,-(A7)
	beq.s .noerror

	pea _waitprompt
	move.w #9,-(sp)
	trap #1
	addq.w #6,sp
	
	bsr waitkey
	
.noerror	pea conoutvec		; restore conout vectors
	move.w #$26,-(sp)
	trap #14
	addq.w #6,sp
	
	pea restore		; restore hardware
	move.w #$26,-(sp)
	trap #14
	addq.w #6,sp

	;Execute all registered atexit procedures
	MOVE.L  _AtExitVec,D0
	BEQ     _exit

	MOVE.L  D0,A0
	JSR     (A0)

;Deinitialize file system
_exit	MOVE.L  _FilSysVec,D0
	BEQ     Exit1

	MOVE.L  D0,A0
	JSR     (A0)

;Deallocate all heap blocks
Exit1	JSR     _FreeAll

;Program termination with return code

	MOVE.W  #76,-(A7)
	TRAP    #1

;-----------------------------------------------
fucknvdi	movem.l d0-a6,-(sp)

	move.l $200.w,d0
	beq.s .nofuck
	
	move.l d0,a0
	cmp.l #"Fuck",(a0)+
	bne.s .nofuck
	cmp.l #"NVDI",(a0)+
	bne.s .nofuck
	
	move.l $586.w,sav_nvdi_dev2
	move.l $592.w,sav_nvdi_dev5
	move.l $28.w,sav_Alinevec
	
	move.l (a0)+,$586.w
	move.l (a0)+,$592.w
	move.l (a0)+,$28.w

.nofuck	movem.l (sp)+,d0-a6
	rts

;-----------------------------------------------
conoutvec	movem.l d0-a6,-(sp)

	move.l sav_nvdi_dev2,d0
	beq.s .novec
	
	move.l d0,$586.w
	move.l sav_nvdi_dev5,$592.w
	move.l sav_Alinevec,$28.w
	
.novec	movem.l (sp)+,d0-a6
	rts
	
;-----------------------------------------------
waitkey	movem.l d0-d3/a0-a2,-(sp)

.wait	move.w #$b,-(sp)
	trap #1		;cconis
	addq.w #2,sp
	
	move.w d0,d3

	move.w #1,-(sp)
	trap #1
	addq.w #2,sp

	tst.w d3
	bne.s .wait
			
	movem.l (sp)+,d0-d3/a0-a2
	rts

;-----------------------------------------------
;include f30 hardware init
BUS_ERROR	;intall bus error exception handler
NOT_A_DEMO	;defines basic hardware features
	include e:\src\work\init5.s
	
;-----------------------------------------------
	DATA
__data:

errno	DC.W   0		;global error number
_AtExitVec	DC.L   0		;Vector for atexit
_FilSysVec	DC.L   0		;Vector for file system deinitialization

_waitprompt	dc.b $a,$d,$a,$d
	dc.b 'return code != 0,',$a,$d
	dc.b 'press a key ...',$a,$d,0

;-----------------------------------------------
	BSS
__bss:

_BasPag	DS.L   1		;Pointer to base page
_app	DS.W   1		;Applikation flag
_StkLim	DS.L   1		;Stack limit
_PgmSize	DS.L   1		;Program size
_RedirTab	DS.L   6		;Redirection address table


sav_nvdi_dev2	ds.l 1		;device output vectors
sav_nvdi_dev5	ds.l 1
sav_Alinevec	ds.l 1

	END
