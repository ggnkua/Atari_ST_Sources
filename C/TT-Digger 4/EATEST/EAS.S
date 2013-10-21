		xref	tabx,tab2x,labx
		bss
tabel:	ds		10
tabel2:	ds		5
save:	ds.l	24
savefpsr:
		ds.l	3
tab:	ds		2
tab2:	ds		2
N1234567:
		ds.l	1
M1234567:
		ds.l	1
N2345678:
		ds.l	1
M2345678:
		ds.l	1
		text
testea:
		link.l	a6,#-0xfffff
		move	5(a1,d0),d0
z0:		; test multiple lables
z1:
z2:
z:		move	x(pc,d1),d0
		move	8(a1,d0*2),d0
		move	18(pc,d1*4),d0
		move	14(pc,d1),d0
x:		move	(tab.w,a0,d2.l*8),d0
		move	(tab2.w,d3.l*4),d0
		move	(d3.w*1),d0
/* test 4 8ch namen in move; dit is tevens een 20 byte instructie */
		move	([N1234567,a5,d2.l],M1234567),([N2345678,a5,d2.l],M2345678)
/* memory indirect preindexd */
		move	([labx+4,pc,d2.l],tab2x),d0
		move	([tabx+8,a0,d2*2],tab2x),d0
		move	([tabx,d3.l*4],tab2x+6),d0
		move	([d3.w*8],tabel2+10),d0
		move	([a1,d3.w],tabel2),d0

		move	([y,pc,d2.l*4]),d0
		move	([tabel,a0,d2*2]),d0
		move	([tabel,d3.l]),d0
		move	([d3.w*2]),d0
		move	([a1,d3.w*4]),d0

/* memory indirect postindexed */
		move	([tabel,pc],d2.l*2,tabel2),d0
/* de combinatie bss-name met pc wordt door PASM niet geflagd.
	Het zou ook eigenlijk moeten kunnen.
	  Het relatief maken is dan een taak voor de linker.
	    Het lijkt erop dat PASM geen goede object genereert.

P.S.	in Pure_C format is alles prima in orde.
*/
ddd:	move	([tabel,a0],d2,tabel2),d0
		move	([tabel],d3.l*8,tabel2),d0
		move	([a0],d3.w*4,tabel2),d0

		move	([ddd,pc],d2.l),d0
		move	([tabel,a0],d2*2),d0
		move	([tabel],d3.l*4),d0
		move	([a0],d3.w*8),d0

/* memory indirect */
		move	([ddd.w+4,pc],tabel2),d0
		move	([tabel,a0],tabel2),d0
		move	([tabel],tabel2),d0
		move	([a1],tabel2),d0

		move	([tabel,pc]),d0
y:		move	([tabel,a0]),d0
		move	([tabel]),d0
		move	([a1]),d0

/* without Xn postindexed and preindexed become the same */
/* No outer displacement without memory indirection */

		fmovecr	#1,fp0
		movem.l	d3-d5,-(sp)		; ter vergelijk
		fmovem	fp3-fp5,-(sp)
		fmove.l	fpsr,savefpsr
		fmovem	fpiar/fpcr,(a0)
l1:		fnop
		fsave	save
		frestore save
		fmove.x	#1.125,fp4
		fmove.l fp4,([tabel,a4],d4*4,tabel2)
		fble.l	lf
		fmovem	(a0),fpiar/fpcr
		fmove.l	savefpsr,fpsr
		fsgt	-4(a6)
		fdble	d4,lf1
		ftrapeq
lf:		ftrapne.w #0xfff
lf1:	ftraple.l #0xffffff
		fmovem	(sp)+,fp5-fp3
		movem.l	(sp)+,d5-d3

		tst.l	a0			; pasm vertaalt naar cmpa.w #0,a0
l2:		dc.w	0x4a88		; deze niet
		tst.w	l2
		bkpt	#5
		trapeq
		traple.w #0xfff
		trapgt.l #0xfffff

		pack	-(a1),-(a2),#0x1111
		pack	d3,d4,#0x8888
		unpk	-(a1),-(a2),#0x1111
		unpk	d3,d4,#0x8888

		move	tab.w,d0;		basis voor ahex.w
		move	tab2.w,d0
		blt.l	l1
		bgt.l	heelverweg
		bge.l	lang
		ble.l	langer

		ploadr	d0,8(a6)
		ploadw	#7,10(a5)
		ploadr	sfc,12(a4)
		ploadw	dfc,14(a3)

lang:	pflusha
		pflush	#7,#2,10(a5)
		pflush	sfc,#3,12(a4)
		pflush	dfc,#4,14(a3)

langer:	ptestr	d0,8(a6),#1
		ptestw	#7,10(a5),#2
		ptestr	sfc,12(a4),#3,a1
		ptestw	dfc,14(a3),#4,a2

		pmove	TT0,(a1)
		pmove	TT1,(a2)
		pmove	(a2),TT0
		pmovefd	(a2),TT1

		pmove	(a1),TC
		pmovefd	(a1),SRP
		pmove	(a2),CRP
		pmove	(a2),MMUSR

		pmove	TC,(a1)
		pmove	srp,(a1)
		pmove	crp,(a2)
		pmove	mmusr,(a2)

		moves	a1,(a0)
		moves	(a2),d0
		cas.b	d1,d2,-12(sp)
		cas 	d1,d2,-12(sp)
		cas.l	d1,d2,-12(sp)
		cas2.w	d1:d2,d3:d4,(a1):(a2)
		cas2.l	d1:d2,d3:d4,(a1):(a2)
		callm	#24,ergens
		chk2.b	8(a3,d2),a1
		chk2.l	16(a4,d3),a2
		cmp2.b	8(a3,d2),a1
		cmp2.l	16(a4,d3),a2
		
		muls.l	-8(a6),d1
		mulu.l	-10(a5),d2:d3
		divs.l	-12(a6),d4
		divu.l	-14(a6),d5:d6
		divul.l	-16(a6),d7:d0

		unlk	a6
		rts
ergens:
		bftst	d6{d5:d4}
		bfextu	tabel{15:8},d3
		bfchg	8(a6){1:2}
		bfexts	12(a4){31:1},d4
		bfclr	10(a5){d0:d1}
		bfffo	14(a3){d2:32},d5
		bfset	(a4){d1:8}
		bfins	d6,(tabel2,d7){6:d3}

		chk 	-4(a6),d4
		chk.l	-8(a6),d5
		rtd  	#24

		globl	mandelbrot
* int cdecl
* mandelbrot(double re,double im,double rec,double imc,int iter,int threshold)
* d0		 complex a           complex c             d0       d1

* re en im = 0 : mandelbrot set; anders juliaset

		offset;		parameter stack frame 
a6plus:
rpc:	ds.l	1
;ra6:	ds.l	1
re:		ds.x	1;			NB 12 bytes
im:		ds.x	1
rec:	ds.x	1
imc:	ds.x	1
it:		ds.w	1
thr:	ds.w	1

		text
mandelbrot:
		fmove.x rec(sp),fp1
		fmove.x imc(sp),fp7
		fmove.x re(sp),fp2
		fmove.x im(sp),fp3

		fmove.w	d1,fp6;			thres

		clr.l	d2;				num
l0:
		fmove.x	fp3,fp0;		im
		fmul.x	fp0,fp0;		*im
		fmove.x	fp2,fp5
		fmul.x	fp5,fp5;   		re2=re*re
		fmove.x	fp5,fp4
		fadd.x	fp0,fp4;		magn

		fcmp.x	fp6,fp4;		magn-thres
		fbgt.w	lx;				magn > thres
		cmp		d2,d0
		ble.w		lx;				it<=num

		fsub.x	fp0,fp5;		re*re-im*im
		fadd.x	fp1,fp5;		+rec
		fmul.x	fp2,fp3;		re*im
		fadd.x	fp3,fp3;		*2
		fadd.x	fp7,fp3;		+imc = im
		fmove.x	fp5,fp2;		re2 -> re

		addq	#1,d2;			num++
		bra.w		l0

lx:		move	d2,d0;			return num
		rts

/* shifts names testen */
		asl		2(a0)
		asr		2(a0)
		lsl		2(a0)
		ror		2(a0)
		lsr		2(a0)
		roxl	2(a0)
lbt:	roxr	2(a0)
lbd:	rol		2(a0)
lbc:	asl		#2,d1
lbf:	asr		#2,d1
		lsl		#2,d1
		ror		#2,d1
		lsr		#2,d1
		roxl	#2,d1
		roxr	#2,d1
		rol		#2,d1
* maskx testen
		btst	#1,lbt(pc)
		btst	#2,([lbd.l,pc,a0],tab)
;		movem.l	lmv(pc),d3-d0			pasm geeft error
		dc.w	0x4cfa,0x000f,0xffe8 ;	zo niet (ook voorbeeld van locale label niet in symbol table)
		btst	#3,([pc],a1)	     ;  randeffect
		frestore lbf(pc)
		fabs	(lbc,pc,a2),fp0
		fabs	(tab,a0,d2*4),fp0
		fadd	fp1,fp0
		fsabs	fp0
		fdabs	fp1
		end
