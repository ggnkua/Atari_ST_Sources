; little prog to relocate and play music from LEIF RULLER by ELECTRA!
; savagely ripped by Tony B of THE UNTOUCHABLES!
; Hi Overlanders, your screen in PYM was my favourite! Wild vectors!!!
; (this took 'bout 10 mins to find/rip/work! credit me please!)
; May 1992.


	pea	0.w
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

*------------------- init interrupts
	move	#$2700,sr	
	move.b	$fffffa07.w,mfp7+3
	move.b	$fffffa09.w,mfp9+3
	move.b	$fffffa0b.w,mfpb+3
	move.b	$fffffa0f.w,mfpf+3
	move.b	$fffffa13.w,mfp13+3
	move.b	$fffffa15.w,mfp15+3
	move.b	$fffffa19.w,mfp19+3
	move.b	$fffffa1f.w,mfp1f+3
	move.l	$70.w,oldvbi+2
	move.l	$134.w,oldta+2
	clr.b	$fffffa07.w
	clr.b	$fffffa13.w
	move.b	#$40,$fffffa09.w
	move.b	#$40,$fffffa15.w
	move.l	#nirq,$70.w
	bclr	#3,$fffffa17.w
	
*------------------- relocate
	lea	rstart(pc),a0
	lea	$1618.w,a1
	move	#(rend-rstart)/4-1,d7
copy_blk
	move.l	(a1),d0
	move.l	(a0),(a1)+
	move.l	d0,(a0)+
	dbf	d7,copy_blk

*------------------- init music
	moveq	#1,d0
	jsr	$1618
	jsr	$162a
	
	move.l	#vbl,$70.w	
	move	#$2300,sr

wait	stop	#$2300
	cmp.b	#57,$fffffc02.w
	bne.s	wait
	
*------------------- shutdown
	move	#$2700,sr
	jsr	$1652
	
	move.l	#nirq,$70.w
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	clr.b	$fffffa13.w
	clr.b	$fffffa15.w
	clr.b	$fffffa19.w
	
	lea	rstart(pc),a1
	move	#(rend-rstart)/4-1,d7
	lea	$1618.w,a2
ret_blk
	move.l	(a1)+,(a2)+
	dbf	d7,ret_blk
	
mfp7	move.b	#0,$fffffa07.w
mfp9	move.b	#0,$fffffa09.w
mfpb	move.b	#0,$fffffa0b.w
mfpf	move.b	#0,$fffffa0f.w
mfp13	move.b	#0,$fffffa13.w
mfp15	move.b	#0,$fffffa15.w
mfp19	move.b	#0,$fffffa19.w
mfp1f	move.b	#0,$fffffa1f.w
oldta	move.l	#0,$134.w
oldvbi	move.l	#0,$70.w
	move	#$2300,sr
	
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	
	illegal


*------------------- play it!
vbl
	move	#$2700,sr
	movem.l	d0-a6,-(sp)
	jsr	$180c
	movem.l	(sp)+,d0-a6
	move	#$2300,sr
nirq
	rte

rstart	incbin	synergy.mus
rend
