****************
* extended cstart routine:
* - setting up argc and argv
* - setting up environment
* - shrink memory
* - and start main
*
* parameters are NOT wildcard expanded
* ARGV environment parameter is searched for instead
*
                GLOBL   exit
                GLOBL   __exit
                GLOBL   _BasPag
                GLOBL	_base
                GLOBL	__base
                GLOBL   _app
                GLOBL   errno
                GLOBL   _AtExitVec,_FilSysVec
                GLOBL   _RedirTab
                GLOBL	_stksize
                GLOBL   _StkLim
                GLOBL   _PgmSize
                GLOBL	environ
                GLOBL	__environ
                GLOBL	_init_environ
                GLOBL	__env_argv
                GLOBL	_argc
                GLOBL	_argv
                
                GLOBL   __text
                GLOBL   __data
                GLOBL   __bss
                
                XREF    main
                XREF    _fpuinit
                XREF    _StkSize
                XREF    _FreeAll
				XREF	_StdErrF

* Base page structure

                OFFSET  0

TpaStart:       ds.l    1
TpaEnd:         ds.l    1
TextSegStart:   ds.l    1
TextSegSize:    ds.l    1
DataSegStart:   ds.l    1
DataSegSize:    ds.l    1
BssSegStart:    ds.l    1
BssSegSize:     ds.l    1
DtaPtr:         ds.l    1
PntPrcPtr:      ds.l    1
Reserved0:      ds.l    1
EnvStrPtr:      ds.l    1
Reserved1:      ds.b    7
CurDrv:         ds.b    1
Reserved2:      ds.l    18
CmdLine:        ds.b    128
BasePageSize:   ds      0


                TEXT

Cconws			equ		$09
Fsetdta         equ     $1a
Fgetdta         equ     $2f
Fseek			equ		$42
Fforce			equ		$46
Mshrink         equ     $4a
Pterm           equ     $4c
Fsfirst         equ     $4e
Fsnext          equ     $4f

__text:
Start:          bra     Start0

                dc.l    _RedirTab
_stksize:       dc.l    _StkSize                * Stack size entry

EmpStr:         dc.b    0,0

Start0:         move.l  a0,a3
                move.l  a3,d0
                bne     acc
                move.l  4(a7),a3
                moveq.l #1,d0
                bra     app
acc:            moveq.l #0,d0
app:            move.l  a3,_BasPag
                move.w  d0,_app
                movea.l TextSegSize(a3),a0
                adda.l  DataSegSize(a3),a0
                adda.l  BssSegSize(a3),a0
                adda.w  #BasePageSize,a0
                move.l  a0,_PgmSize

                move.l  a3,d0
                add.l   a0,d0
                and.b   #$FC,d0
                movea.l d0,a7

* check application flag

*        TST.W   _app
*        BEQ     Start8  * No environment and no arguments

                sub.l   _stksize,d0
                add.l	#4,d0
                and.b   #$FC,d0
                movea.l d0,a1
                movea.l a1,a4
                move.l  a1,environ
                move.l  a1,_init_environ
                
                movea.l EnvStrPtr(a3),a2
                move.l  a2,(a1)+
                tst.l	a2
                beq		noenv
Start1:         tst.b   (a2)+
                bne     Start1
                move.l  a2,(a1)+
                tst.b   (a2)+
                bne     Start1
                clr.l   -4(a1)
noenv:
                movea.l a1,a2

                move.l  #EmpStr,(a1)+   ;   argv[0] = ""
                lea     CmdLine(a3),a0
                move.b  (a0)+,d1
                ext.w   d1
                cmp.w	#127,d1
                beq		do_argv
scan_cmd:
                moveq   #1,d3
                clr.b   0(a0,d1)
Start2:         move.b  (a0)+,d1
                beq     Start99
                cmpi.b  #' '+1,d1
                bmi     Start2
                addq.l  #1,d3
                subq.l  #1,a0
                cmpi.b  #'"',d1
                bne     Start4
                addq.l  #1,a0
                move.l  a0,(a1)+
Start3:         move.b  (a0)+,d1
                beq     Start99
                cmp.b   #'"',d1
                bne     Start3
                clr.b   -1(a0)
                bra     Start2
Start4:         move.l  a0,(a1)+
Start6:         move.b  (a0)+,d1
                beq     Start7
                cmp.b   #' '+1,d1
                bpl     Start6
Start7:         clr.b   -1(a0)
                bra     Start2
Start99:        clr.l   (a1)+
				

do_argv:
                move.l	a4,-(a7)	; push envp
                move.l  a2,-(a7)	; push argv
                move.w  d3,-(a7)	; push argc
				move.w	d1,-(a7)
				
                move.l  a1,_StkLim
                move.l  _PgmSize,-(a7)
                move.l  a3,-(a7)
                move.w  #0,-(a7)
                move.w  #Mshrink,-(a7)
                trap    #1
                lea     12(a7),a7

                move.w	(a7)+,d1
                cmp.w	#127,d1
				bne		no_argv
				
				lea		0(a7),a0
				lea		2(a7),a1
				move.l	environ,a2
				bsr		argv
				tst.b	d2
				bne		no_argv
				moveq	#126,d1
                lea     CmdLine+1(a3),a0
                move.w	(a7)+,d3
                move.l	(a7)+,a2
                move.l	a2,a1
                move.l	#EmpStr,(a1)+
				bra		scan_cmd
				
no_argv:

				move.w	(a7),d0		; restore argc
				move.l	2(a7),a0	; restore argv
                movea.l a4,a1		; restore envp
				move.w	d0,_argc
				move.l	a0,_argv

				jsr     main


exit:           move.w  d0,-(a7)
                move.l  _AtExitVec,d0
                beq     __exit
                movea.l d0,a0
                jsr     (a0)
__exit:
				
				move.l  _FilSysVec,d0
                beq     Exit1
                movea.l d0,a0
                jsr     (a0)
Exit1:          /* jsr     _FreeAll */
                move.w  #Pterm,-(a7)
                trap    #1



*
* passed: (a0) = &argc
*         (a1) = &argv
*         a2   = envp[]
*
* returns: d1 != 0 -> STDERR found
* returns: d2 != 0 -> ARGV found
*
argv:			movem.l	a3-a4,-(a7)
				sf		d1
				sf		d2
argv1:			move.l	(a2)+,a3
				move.l	a3,d0
				beq		xenv
				cmp.b	#'A',(a3)
				beq		argv2
				cmp.b	#'S',(a3)
				bne		argv1
				cmp.b	#'T',1(a3)
				bne		argv1
				cmp.b	#'D',2(a3)
				bne		argv1
				cmp.b	#'E',3(a3)
				bne		argv1
				cmp.b	#'R',4(a3)
				bne		argv1
				cmp.b	#'R',5(a3)
				bne		argv1
				cmp.b	#'=',6(a3)
				bne		argv1
				st		d1
				bra		argv1
argv2:			cmp.b	#'R',1(a3)
				bne		argv1
				cmp.b	#'G',2(a3)
				bne		argv1
				cmp.b	#'V',3(a3)
				bne		argv1
				cmp.b	#'A',(a3)
				bne		argv1
				cmp.b	#'=',4(a3)
				bne		argv1
				st		d2
				clr.l	-4(a2)		; terminate env[] array here
				clr.b	(a3)		; remove ARGV from env
				lea		6(a3),a3
				move.l	a3,a4
				move.l	a3,__env_argv
scanslash:		tst.b	(a3)
				beq		endslash
				cmp.b	#$5c,(a3)+
				bne		scanslash
				; move.l	a3,a4
				bra		scanslash
endslash:		move.l	a4,a3
lowerit:		move.b	(a4)+,d0
				beq		lowerend
				cmp.b	#'A',d0
				bcs		lowerit
				cmp.b	#'Z'+1,d0
				bcc		lowerit
				add.b	#'a'-'A',d0
				move.b	d0,-1(a4)
				bra		lowerit
lowerend:		move.l	(a1),a4
				clr.w	(a0)
nxarg:			move.l	a3,(a4)+
				add.w	#1,(a0)
nxar1:			tst.b	(a3)+
				bne		nxar1
				tst.b	(a3)
				bne		nxarg
				clr.l	(a4)
xenv:			movem.l	(a7)+,a3-a4
				rts
				

                DATA
                
__data:
errno:          dc.l    0
_AtExitVec:     dc.l    0
_FilSysVec:     dc.l    0


                BSS

__bss:
_base:
__base:
_BasPag:        ds.l    1
_app:           ds.w    1
_StkLim:        ds.l    1
_PgmSize:       ds.l    1
_RedirTab:      ds.b    24
__environ:
environ:        ds.l    1
_init_environ:  ds.l    1
__env_argv:		ds.l	1
_argc:			ds.w	1
_argv:			ds.l	1
