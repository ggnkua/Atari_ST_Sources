	.extern dspd0b,dspa0

*	software designer: Tom Le
*	Company Atari Microsystem
*	date: 3/30/92
*	define parameters for expansion testing
* 4/17/92  TLE fixed exceptions $14-24 for recover from excep
* 4/18/92  TLE moved e_dspreg, and e_excep to e_var

  .if !(^^defined DEBUG)
DEBUG = 0
  .endif		;  

  .if !(^^defined prod)
prod = 0
  .endif		;  

  .if !(^^defined PRINTER)
PRINTER = 0
  .endif

  .if !(^^defined HOST)
HOST	EQU	0	;default for running from target system
  .endif		; 

  .if !(^^defined TOS)
TOS	EQU	0	;default for running from cartridge ROM
  .endif		;  

  .if !(^^defined C68K)
C68K	EQU	0	;C68k=0 for 68030 CPU; =1 for 680000
  .endif

  .if !(^^defined TRAMQ)
TRAMQ	EQU	0	;
  .endif

  .if !(^^defined LTRAM)
LTRAM	EQU	0	;
  .endif

  .if !(^^defined LERAM)
LERAM	EQU	0	;
  .endif

  .if !(^^defined TRAM)
TRAM	EQU	0	;
  .endif

  .if !(^^defined TROM)
TROM	EQU	0	;
  .endif

  .if !(^^defined TBLT)
TBLT	EQU	0	;
  .endif

  .if !(^^defined ERAM)
ERAM	EQU	0	;
  .endif

   .if !(^^defined TOS)
TOS	EQU	0	;
  .endif

.macro  Pterm0
	clr.w	-(sp)
	trap	#1
	illegal
.endm

.macro	Dohalt
move.b  d0,host+3
.endm

.macro	Doreset
move.b  d0,host+5
.endm

.macro	Dorelease
move.b  d0,host+7
.endm

.macro  Super
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,-(sp)
	move.w	#$20,-(sp)
.endm

host =   $f70000
maphireg = $f70001
mapsize=  $10	;1 megabytes
; mapsize= $40	;4 megabytes
timerint = $134
intvect = $218	;select a user int vect between 100 to 400 hex
int1auto = $64
ebltf=0		;expansion blitter 
eint1f=1	;
eint3f=2
eint5f=3
eint6f=4
eberf=5
ehaltf=6
e500f=7
eprif=8
elatf=9
eramf=10
cart = 0
int1 = 1
int3 = 2
int6 = 3
khzlo = 4
khzhi = 5
int5 = 6
latchen = 6
wasber = 7
halten = 7
expandio = $f70000
expansion = $fc0000
cartridge = $fa0000
switch = $ff9200

blt2 = $f78a00

* e_dspreg

	.text
.macro push	pushreg
	move.l  \pushreg,-(sp)
.endm
.macro pop	popreg
	move.l  (sp)+,\popreg
.endm
.macro  dspregw   regw
	move.l    d0,-(sp)
	move.l    \regw,d0
	bsr	dspd0w
	bsr	dspspc
	move.l    (sp)+,d0
.endm
.macro  dspregl   regl
	move.l    d0,-(sp)
	move.l    \regl,d0
	bsr	dspd0
	bsr	dspspc
	move.l    (sp)+,d0
.endm

.if TOS
dspadd:
.endif
dspa0:
puta0:
	move.l  d1,-(sp)
	move.l  a0,d1
	bra     dspd11

dspa1:
puta1:
	move.l  d1,-(sp)
	move.l  a1,d1
	bra     dspd11

dspa2:
puta2:
	move.l  d1,-(sp)
	move.l  a2,d1
	bra     dspd11

dspd2:
putd2:
	move.l  d1,-(sp)
	move.l  d2,d1
	bra     dspd11


dspd0:
putd0:
	move.l	d1,-(sp)
	move.l  d0,d1
dspd11:
	bsr	dspd1
	move.l  (sp)+,d1
	rts

dspd1:
putd1:
	move.l	d1,-(sp)
	swap	d1
	bsr	putd1w
	move.l	(sp),d1
        bsr	putd1w
	move.l  (sp)+,d1
	rts

dspd3w:
putd3w:
        move.w  d1,-(sp)
	move.w  d3,d1
	bra	dspd1w1

dspd2w:
putd2w:
        move.w  d1,-(sp)
	move.w  d2,d1
	bra	dspd1w1


dspd0w:
putd0w:
	move.w	d1,-(sp)
	move.w  d0,d1
dspd1w1:
	bsr	dspd1w
	move.w  (sp)+,d1
	rts

dspd1w:
putd1w:	
	move.w	d1,-(sp)
	asr	#8,d1
	bsr	dspbyt
	move.w	(sp),d1
	bsr	dspbyt
	move.w	(sp)+,d1
	rts

.if !(^^defined dspwrd)
dspwrd = dspd1w
.endif

dspd2b:
putd2b:
        move.w  d1,-(sp)
	move.w  d2,d1
        bra     dspd1b1
	

dspd1b:
putd1b:
	bra	dspbyt

dspd0b:
putd0b:
	move.w  d1,-(sp)
	move.w  d0,d1

dspd1b1:
	bsr	dspbyt		;dsp d1b
	move.w  (sp)+,d1
	rts

.if !(^^defined dspasc)
dspasc = dspd1b
.endif

* e_excep
set_io:
	movem.l d0-d1,-(sp)
	clr.l   d1
	move.b  intlev,d1
	move.b  expandio,d0
	and.l   #$3f,d0
	bset    d1,d0	
	move.b  d0,expandio     ;
	movem.l (sp)+,d0-d1
	rts

clear_io:
	movem.l d0-d1,-(sp)
	move.b  expandio,d0
	and.l   #$3f,d0
	clr.l   d1
	move.b  intlev,d1
	bclr    d1,d0	
	move.b  d0,expandio     ;
	movem.l (sp)+,d0-d1
	rts

loadvect:
	move.l  d0,-(sp)
	move.w  #intvect,d0	;make vector address to a
	lsr.w   #2,d0		;   vector number
	lea	expandio,a0
	move.b  d0,1(a0)	;
	move.l  (sp)+,d0
	rts

excepbe:   			;bus error
	movea.l #msgbe0,a5     
excepbe1:
        bsr     dspmsg
        lea     msgaccadd,a5
        bsr     dspmsg
.if (C68K=1)
        move.l  2(sp),a0        ;access address 68000
.else
        move.l  $10(sp),a0      ;access address 68030
.endif	
	move.l  a0,accaddr	; TLE 7/23/92
        bsr     puta0           ;display access address
        lea     msgpc,a5
        bsr     dspmsg
.if (C68K=1)
        move.l  $a(sp),a0       ; program counter 68000
.else
        move.l  $2(sp),a0       ; program counter 68030
.endif
        bsr     puta0           ;display pc
	bsr	dspspc
.if (TOS=1)
	bsr	dspspc
	move.b  maphi,d0
	bsr	dspd0b
.else
	move.w  #red,palette
.endif
	move.l  stacksave,sp
	move.l  pcsave,a6
	jmp	(a6)
        rte

excepae: movea.l #msgae0,a5	;address error      
	bra	excepbe1

excepii: movea.l #msgii0,a5     ;instruction error
	bra	excepbe1	

excepsp0: 			;spurious interrupt
        movea.l #spurina0,a5     
        bsr     dspmsg
        rte

exc_14:				;zero divide
	lea	msgexc14,a5
	bsr	dspmsg
;	move.l  pcsave,a6	;removed to recover from excep, TLE
;	jmp    (a6)
;	move.l  stacksave,sp
        rte
exc_18:				;CHK instruction
	lea	msgexc18,a5	;removed to recover from excep, TLE
	bsr	dspmsg
;	move.l  stacksave,sp
;	move.l  pcsave,a6
;	jmp    (a6)
        rte
exc_1c:				;TRAP instruction
	lea	msgexc1c,a5
	bsr	dspmsg
	move.l  stacksave,sp	;removed to recover from excep, TLE
	move.l  pcsave,a6
	jmp    (a6)
        rte
exc_20:				;priviledge violation
	lea	msgexc20,a5
	bsr	dspmsg
;	move.l  stacksave,sp	;removed to recover from excep, TLE
;	move.l  pcsave,a6
;	jmp    (a6)
        rte
exc_24:				;trace exception
	lea	msgexc24,a5
	bsr	dspmsg
;	move.l  stacksave,sp	;removed to recover from excep, TLE
;	move.l  pcsave,a6
;	jmp    (a6)
        rte

saveexcep:
        movea.l #excepsave,a1
        movea.l #8,a0           ;point to start of vector ram
        moveq   #7,d0
saveexcep1:  
	move.l  (a0)+,(a1)+     ;move 2-11
        dbra    d0,saveexcep1
	rts

getexcep:
        movea.l #vectexp,a0
        movea.l #8,a1           ;point to start of vector ram
        moveq   #7,d0
getexcep1:  
	move.l  (a0)+,(a1)+     ;move 2-11
        dbra    d0,getexcep1
	rts

resexcep:
        movea.l #excepsave,a0
        movea.l #8,a1           ;point to start of vector ram
        moveq   #7,d0
resexcep1:  
	move.l  (a0)+,(a1)+     ;move 2-11
        dbra    d0,resexcep1
	rts

	.data
vectexp: dc.l    excepbe
        dc.l    excepae
        dc.l    excepii
        dc.l    exc_14
        dc.l    exc_18
        dc.l    exc_1c
        dc.l    exc_20
        dc.l    exc_24
