.if !(^^defined HOST)
HOST = 0
.endif

.if !(^^defined TOS)
TOS = 0
.endif

.if !TOS
	.include hardware
	.include defs
	.include nvram
; 	.include e_data
	.include e_var		
	.extern ebltmsg,got_blt
	.extern testexp
.endif


*	Software designer: Tom Le
*	Company: Atari Microsystem
*	Date: 3/30/92
*	Testing expansion port
* 4/17/92 TLE Added the expansion blitter test (long and short)
*         TLE Fixed bug in the priority test to run at 16 MHZ
*         TLE Modified e_excep to recover from TRAPV
*	  TLE Removed e_blt, and modified blt, and xblt
* 8/03/92 TLE Fixed bugs to run with 6 pilot Falcon030 PCB's

*	.include e_dspreg	;moved to e_var, TLE
*	.include e_excep	;moved to e_var, TLE

	.text
e_expbe:
	move.l  a2,8		;restore bus error
	move.l  a4,sp		;restore sp
.if TOS=0
	move.w  #red,palette
.endif
	lea	msgexpno,a5
	bsr	dspmsg
	RTCSETFAIL #t_XBUS	; RWS 1.18f
	rts			;

testexp:
	move.b  SPControl,spc_sav ; save control byte
	move.b  #5,SPControl	; CPUCLK/BLTCLK = 16MHZ

; FOR NOW SET PASS BITS ALWAYS
	move.b	ProdTestStat,tries	; temp stg
	move.b	#t_POSTBURN,ProdTestStat
	RTCCLEARPASS #t_XBUS
	move.b	tries,ProdTestStat
	clr.b   erflg0		; blitter status
	clr.b   erflg1		; blitter status
	move.l  #blt2,Blt	; add new variable for exp Blitter TLE
;	move.l	#ebltmsg,Bltmsg	; add new variable for exp Blitter TLE
.if TOS
	clr.w   passw
	movea.l	#msgexp,a5
	move.l  a5,msgsave1
	bsr	dspmsg
	bsr	sav_cur
.else
	lea	msgexp,a5
	bsr	dsptst
.endif
	move.l  8,a2		;save bus error 	
	move.l  sp,a4		;save sp
	move.l  #e_expbe,8
	move.w  blt2,d0		;is expansion fixture connected
	move.l  a2,8		;restore bus error
	clr.w   flag		;clear all possible failure
.if TOS=0
	bsr	saveexcep
	bsr	getexcep
.endif

.if TOS
	bsr	testeram
.endif
	bsr	testber
	bsr	testlat
	bsr	testint1
	bsr	testint3
	bsr	testint6
	bsr	test500
	bsr	testhalt
	bsr	testpri
; bra     doneexp
	move.l  sp,stacksave	;TLE 7/23/92 
	bsr	got_blt		; test blitter
	move.b  erflg0,d0
	or.b    erflg1,d0	; blitter passed?
	beq.s   doneexp		; yes
	bset    #ebltf,flag	; no

doneexp:
	move.b  spc_sav,SPControl ; restore control byte
        movea.l #pasmsg,a5	; default 
	tst.w   flag		; test passed?
.if TOS
	rts
.else
	beq.s   testexpp	; test passed
        movea.l #falmsg,a5	; test failed
testexpp:
	move.b  #t_XBUS,d0	; expansion test ID from RTC
; FOR NOW SET PASS BITS ALWAYS
	move.b	ProdTestStat,tries	; temp stg
	move.b	#t_POSTBURN,ProdTestStat	; RWS.TPEX
	bsr     dsppf		; display pass/fail and mark RTC
	move.b  tries,ProdTestStat
	bsr	resexcep
;	move.b  d3,expandio
	rts
.endif

*	.include e_lat
* test the address latch
latbe:				;bus error routine  
	move.l  spsave0,sp
	bra	latch1
	rte	

latbeer:				;bus error routine  
	move.l  spsave0,sp
	bra	latch1er
	rte	

*  change a0=test address, a1=expandio
*  change d0=working reg, d1=read data, d2=address increment, d3=vector bit
testlat:			
	move.l  #$10000,d2	; test address increment
	lea	expandio,a1	;	
	move.b  1(a1),d3	; try to preserve the vector bits
	move.b  d3,1(a1)	; if no expansion fixture, then bus error, and 
				; abort to stay alive from new bus error.
	move.w  sr,srsave0
	move.l  sp,spsave0
	move.l  8,besave0
	move.l  #latbe,8	; load the latch bus error routine
	move.w  #$2700,sr	; no interrupt allows
	move.b  d3,1(a1)	; set latch bit 
	move.b  (a0),d1		; latch address, and clear latch bit

latch3: clr.l   a0		; test address starts from 0
latch:
	move.b  d3,1(a1)	; enable latch 
	move.b  (a0),d1		;
	cmp.l   #$f70000,a0
	bne.s   .1
	and.b   #$3f,d1 
.1:
	move.b  d1,(a0)		; latch test address, and clear latch bit
latch1:
	move.w  (a1),d1		; read from latch
	and.l   #$ff,d1		; 
	swap    d1
	cmp.l   d1,a0		; latch works?
	bne     latcher		; no

latch2:
	add.l   d2,a0
	cmp.l   #$1000000,a0
	blt     latch
	
latchrt:
	move.w  srsave0,sr
	move.l  spsave0,sp
	move.l  besave0,8
	btst    #elatf,flag
        rts

latcher:
	swap    d1
	move.l  a0,d0
	swap    d0
.if TOS=0
        move    #red,palette
.endif
        lea     latchmsg,a5
	bsr	dspmsg
	bsr     dspa0	;fail address
	bsr	dspspc
	bsr     dspd0b
	bsr	dspspc
	bsr     dspd1b
	bsr	crlf
.if TOS
	bsr	wait100
	bsr	chkkey
	bsr	sav_cur
.endif
	bset    #elatf,flag
	bra	latchrt

debuglat:
	move.l  #latbeer,8	; load the latch bus error routine

latchl:
	move.b  d3,1(a1)	; enable latch 
	move.b  (a0),d1		;
	and.b   #$3f,d1 
	move.b  d1,(a0)		; latch test address, and clear latch bit
latch1er:
	move.w  (a1),d1		; read from latch
	bra.s   latchl

*	.include e_ber
excepbebe:
	move.l  spsave0,sp
	bra	testber0
	rts

testber:
	move.l  sp,spsave0
	move.l  8,intsave0
	move.l  #excepbebe,8
        lea     expandio,a0
	move.b  2(a0),d0 		;clear bus error
	move.w   #0,$f10000		;set bus error bit

testber0:
	move.b  (a0),d0
	btst	#wasber,d0
	beq	tberlo			;stuck hi
	move.b  2(a0),d0 		;clear bus error
	move.b  (a0),d0
	btst	#wasber,d0
	bne     tberhi			;stuck hi

tbert:
	move.l  intsave0,8
	btst    #eberf,flag
        rts

tberhi:
.if (TOS = 0)
        move    #red,palette
.endif
	lea	testbeh,a5
	bsr	dspmsg
	bset    #eberf,flag
	bra	tbert

tberlo:
.if (TOS = 0)
        move    #red,palette
.endif
	lea	testbel,a5
	bsr	dspmsg
	bset    #eberf,flag
	bra	tbert

*	.include e_int1
spurint1:			;
	bsr	clear_io
	lea	spurina1,a5
	bsr	dspmsg
        move.w  #$1234,intword
	rte

eint1a:
	bsr	clear_io
        move.w  #$3456,intword
	bclr    #eint1f,flag
	rte

testint1:
;	bsr	maskall		;mask off all mfp interrupts 
	bset	#eint1f,flag
	move.w  #$abcd,intword
	move.b  #int1,intlev
	move.l  $60,intsave0
	move.l  #spurint1,$60    ;
	move.l  #eint1a,int1auto
	move.w  sr,srsave0	;
;	move.w  sr,d0
;	and.w   #$f8ff,d0	;
;	move.w  d0,sr
	bsr	set_io
	move.l  #$800,d2        ;setup a sw timer
	move.w  #$2000,sr
	
testint1a:
	move.w  #$2000,sr
	move.w  intword,d0
	cmp.w   #$3456,d0
	beq     testint1p	;passed
	sub.l   #1,d2
	bne     testint1a
	btst    #eint1f,flag
	beq	testint1p	;passed
	bsr	clear_io
	
.if (TOS=0)
        move    #red,palette
.endif
	lea     int1msg1,a5
	bsr	dspmsg
	bset  #eint1f,flag

testint1r:
;	bsr     unmaskall
	move.l  intsave0,$60
	move.w  srsave0,sr	;
        btst    #eint1f,flag
        rts

testint1p:
	bclr    #eint1f,flag
	bra	testint1r

*	.include e_int3
spurint:			;ste int3 only
	bsr	clear_io
        move.w  #$4567,intword
	rte

int3auto:			;sparrow int3 only
	bsr	clear_io
        move.w  #$3456,intword
	rte

testint3:
	move.b  #int3,intlev
	move.l  #spurint,$60    ;
	move.l  #int3auto,$6c    ;
	move.w  sr,srsave0	;
	move.w  sr,d0
	and.w   #$f8ff,d0	;
	or.w    #$0200,d0	;enable int3 
	move.w  d0,sr

	clr.w   intword	        ;
	bsr	set_io
	move.l  #$800,d1        ;setup a sw timer

testint3a:
	move.w  intword,d0
	cmp.w   #$3456,d0
	beq     testint3p	
	sub.l   #1,d1
	bne     testint3a
	bsr	clear_io
.if TOS=0
        move    #red,palette
.endif
	lea     int3msg1,a5
	bsr	dspmsg
	bset   #eint3f,flag

testint3r:
	move.w  srsave0,sr	;
	btst    #eint3f,flag
        rts

testint3p:
	bra	testint3r

*	.include e_int6
eint6:				;
        move.w  #$6789,intword
	bsr	clear_io
	rte

eint6sp:		;for spurious int
	lea	spurina0,a5
	bsr	dspmsg
	bsr	clear_io
	rte

testint6:
	move.b  #int6,intlev
	bsr	loadvect
	move.l  $60,spurisave		;
	move.l  #eint6sp,$60
	move.l  intvect,intsave0	;save the OP int routine
	move.l  #eint6,intvect  	;
	move.l  #10,d2		;setup a sw timer
	clr.w   intword	        ;
	bsr	set_io		;gen int

testint6a:
	move.w  intword,d0
	cmp.w   #$6789,d0
	beq     testint6p	
	sub.l   #1,d2
	bne    testint6a
	bsr	clear_io
.if TOS=0       
        move    #red,palette
.endif
	lea     int6msg1,a5
	bsr	dspmsg
	bset    #eint6f,flag

testint6r:
	move.l  intsave0,intvect	;restore int
	move.l  spurisave,$60		;
	btst    #eint6f,flag
        rts

testint6p:
	bra	testint6r

*	.include e_500
test500:
	move.b   #khzhi,intlev
	bsr	set_io
	move.b  expandio,d2	;get latchen bit
	bsr	clear_io
	btst	#latchen,d2
	beq	t500lo		;stuck low

	move.b   #khzlo,intlev
	bsr	set_io
	move.b  expandio,d2	;get latchen bit
	bsr	clear_io
	btst	#latchen,d2
	bne	t500hi		;stuck hi

t500rt:
	btst    #e500f,flag
        rts

t500lo:
.if TOS=0
        move    #red,palette
.endif
	lea	test500l,a5
	bsr	dspmsg
	bset    #e500f,flag
	bra	t500rt

t500hi:
.if TOS=0
        move    #red,palette
.endif
	lea	test500h,a5
	bsr	dspmsg
	bset    #e500f,flag
	bra	t500rt

*	.include e_halt
timeria0:
	move.w  #$3456,intword
	lea	mfp,a0
	clr.b   tacr(a0)	;stop timer
	moveq	#13,d0
	jsr	disint		;disable int
        rte

testhalt:
	lea	mfp,a0
	move.l  #$50,d0
testhaltw:
	sub.l   #1,d0
	cmp.l   #0,d0
	bne	testhaltw

	bsr	save_tmr
	move.b  #0,imra(a0)
	move.b  #0,imrb(a0)

	move.l  timerint,inttmrsave ;save interrupt
	move.l	#timeria0,timerint ; Set interrupt vector
	clr.w   intword
	bsr	gotimer		;start timer A
	move.b  #halten,intlev
	bsr	set_io		;halt the CPU
	moveq	#2,d2		

thalt0:
	sub.w   #1,d2
	cmp.w   #$3456,intword	
	beq.s	thaltp		;
	cmp.w   #00,d2
	bgt	thalt0
	bset    #ehaltf,flag	;set error
.if TOS=0
        move    #red,palette
.endif
	lea	testhaltm,a5
	bsr	dspmsg

thaltrt:
	move.l  inttmrsave,timerint ;
	bsr	res_tmr
	btst    #ehaltf,flag
        rts

thaltp:
	bra	thaltrt

gotimer:
	movea.l	#mfp,a0		;
	clr.b	tacr(a0)
	move.b	#6,tadr(a0)     ; 1 counts at 2.4576 MHz / 200 = 325.5 us
	move.b	keyboard,d0	;read stat to assure no irq at 6850
	move.b	iodata+keyboard,d0  ;clear data buffer
	moveq	#13,d0		;timer A
	jsr	enabint		;set enable, mask bits
	move.b	#7,tacr(a0)	;start timer /200
	rts

res_tmr:
	movea.l	#mfp,a0		;
	move.b  imra_save,imra(a0)
	move.b  iera_save,iera(a0)
	move.b  isra_save,isra(a0)
	move.b  ipra_save,ipra(a0)
	move.b  imrb_save,imrb(a0)
	move.b  tadr_save,tadr(a0)
	move.b  tacr_save,tacr(a0)
	rts

save_tmr:
	movea.l	#mfp,a0		;
	move.b  imra(a0),imra_save
	move.b  iera(a0),iera_save
	move.b  isra(a0),isra_save
	move.b  ipra(a0),ipra_save
	move.b  imrb(a0),imrb_save
	move.b  tadr(a0),tadr_save
	move.b  tacr(a0),tacr_save
	rts

.if TOS&!HOST
	.include blt
	.include e_eram
.endif

*	.include e_pri
* Test priority signal XIEO 
eint6p:				;
	bsr	clear_io	;clear interrupt
	lea	expandio,a0
	move.b  #0,2(a0)	;negates XIEO to disable MFP int
	move.w  #$789a,intword6
	rte

spurip:
;	move.w  #$1234,intword
	bclr    #eprif,flag
	rte

buserrp:
	move.w  #$bebe,intword
	move.l  stacksave,sp
	move.l  pcsave,a6
	jmp     (a6)
	rte

testpri:
	bset    #eprif,flag	;default = fail
	move.b  SPControl,d0
;	move.b  d0,savectl	; TLE 7/31/92 
	bset    #7,d0
	move.b  d0,SPControl

	clr.w   intflg	        ;
	clr.w   intword
	clr.w   intword6
	lea	mfp,a0
	bsr	save_tmr
	move.b  #0,imra(a0)
	move.b  #0,imrb(a0)
	move.b  #int6,intlev	;
	move.l  $60,intsave0
	move.l  8,besave0
	move.l  timerint,inttmrsave ;save tmr interrupt
	move.l  intvect,int6save	;save the OP int routine
	move.l  #eint6p,intvect  ;
	move.l	#timeria0,timerint ; Set interrupt vector
	move.l  #spurip,$60
	bsr	loadvect
	move.l  #$f000,d1	;setup a sw timer
	bsr	set_io		;

testpril:
	move.w  intword6,d0
	cmp.w   #$789a,d0
	beq     testpric	;continue testing	
	sub.l   #1,d1
	bne    testpril       

testprif:
.if (TOS=0)
        move    #red,palette
.endif
	lea     primsg1,a5
	bsr	dspmsg
	bset    #eprif,flag

testprir:
	move.b  SPControl,d0
	bclr    #7,d0
	move.b  d0,SPControl
	move.l  intsave0,$60
	move.l  inttmrsave,timerint 	;restore interrupt
	move.l  int6save,intvect	;restore int
	move.l  besave0,8	
	bsr	res_tmr
	btst    #eprif,flag
        rts

testprip:
	bra	testprir

testpric:
	move.l  sp,stacksave
	move.l  #testprif,pcsave
	move.l  #buserrp,8
	bsr	gotimer		;start timer A

testpri3:
	move.l  #$f000,d1	;setup a sw timer

testpril1:
;	move.w  intword,d0
;	cmp.w   #$1234,d0	; spuri interrupt? or passed?
;	beq     testprip	; yes
	btst    #eprif,flag	; passed?
	beq     testprip	; yes
	sub.l   #1,d1
	bne    testpril1
	bra	testprif	;

.if TOS=0
   .data
msgexc14: dc.b cr,lf,'  $14: Zero  Divide ',eot
msgexc18: dc.b cr,lf,'  $18: CHK,CHK2 instruction ',eot
msgexc1c: dc.b cr,lf,'  $1c: TRAP instruction ',eot
msgexc20: dc.b cr,lf,'  $20: priviledge violation ',eot
msgexc24: dc.b cr,lf,'  $24: Trace exception ',eot
msgint5v: dc.b cr,lf,'  Interrupt 5 user vector  ',eot
msgint6: dc.b cr,lf,'   Interrupt 6 user vector  ',eot
msgint1a: dc.b cr,lf,'  Interrupt 1 auto vector  ',eot
spurina5: dc.b cr,lf,'  Spurious interrupt 5  ',eot
spurina1: dc.b cr,lf,'  Spurious interrupt 1  ',eot
spurina6: dc.b cr,lf,'  Spurious interrupt 6  ',eot
msgbe6: dc.b cr,lf,'  Bus error from int level 6  ',eot
msgbe0: dc.b cr,lf,'  Bus Error ',eot
spurina0: dc.b   cr,lf,'  Spurious Interrupt ',eot
msgii0: dc.b    cr,lf,'  Illegal Instruction  ',eot     
msgae0: dc.b    cr,lf,'  Address Error  ',eot
msgaccadd: dc.b    ' Access Address: ',eot
msgpc:  dc.b    ' Program Counter: ',eot

mess1: dc.b cr,lf,'  Block test: ',eot
mess2: dc.b cr,lf,'  Adddress test: ',eot
mess3: dc.b cr,lf,'  Hilo test: ',eot
mess4: dc.b cr,lf,'  Copy test: ',eot
testhaltm: dc.b cr,lf,'  Halt Test failed  ',eot
msgtmr: dc.b cr,lf,'      timer interrupt...: ',eot
test500l: dc.b cr,lf,'  500 KHZ clock stuck low',eot
test500h: dc.b cr,lf,'  500 KHZ clock stuck high',eot
prnfmsg:  dc.b cr,lf,'  printer is not responding... ',eot
prnmsg0:  dc.b cr,lf,'  printer is working',eot
testbel: dc.b cr,lf,'  Bus error signal stuck low',eot
testbeh: dc.b cr,lf,'  Bus error signal stuck high',eot
bltmsg1:  dc.b cr,lf,'  Blitter test failed  ',eot
bemsg:   dc.b '*',eot
msgtr:  dc.b cr,'  Testing Target Ram               Test No. ',eot
msgtrq: dc.b cr,'  Testing Videl Data Latch         Test No. ',eot
msgexpram: 
	dc.b cr,'  Testing Expansion Ram            Test No. ',eot
msgexp: dc.b  'Testing Expansion  Date: Aug 7, 92 ',eot
msgexpno: dc.b cr,lf,'  Expansion port is not connected ',eot
passmsg: dc.b    'Pass: ',eot
failmsg: dc.b    'Fail at cycle:',eot

; .if !(^^defined falmsg)
; falmsg = failmsg
; .endif

; .if !(^^defined pasmsg)
; pasmsg = passmsg
; .endif

latchmsg: dc.b cr,lf,'  Address Latch failed at addr-exp-read: ',eot
int1msg1: dc.b cr,lf,'  Interrupt level 1 failed ',eot
int3msg1: dc.b cr,lf,'  Interrupt level 3 failed ',eot
int5msg1: dc.b cr,lf,'  Interrupt level 5 failed ',eot
int6msg1: dc.b cr,lf,'  Interrupt level 6 failed ',eot
primsg1: dc.b cr,lf,'  Interrupt priority failed ',eot
rammsg1: dc.b     cr,lf,'  RAM test start.end: ',eot
ramfmsg: dc.b    cr,lf,'    RAM failed addr.write.read: ',eot
startmsg: dc.b   'Testing in progress sp/sr: ',eot
donemsg2: dc.b    cr,lf,lf,'Test is done sp/sr: ',eot
spacemsg: dc.b   '  ',eot
crlfmsg: dc.b    cr,lf,eot
crmsg: dc.b    cr,eot
.endif

