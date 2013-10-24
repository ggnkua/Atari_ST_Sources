*
* BORIS SAMPLE PACKER II (ANALYSER)
*
* On exit :-
*   d7-d1 = no. of bytes saved
*      a6 = minimum size of WORKSIZE for depacker
*

	opt	o+,ow-

start	lea	mess,a0
	bsr	print_string
	lea	0.w,a5
	lea	0.w,a6
	moveq	#0,d0
	moveq	#0,d1
	lea	sample,a0
.loop
	move.b	(a0)+,d2
	move.b	d0,d3
	move.b	d2,d4
	and.b	#$e0,d4
	and.b	#$e0,d3
	cmp.b	d4,d3
	bne	.store
	addq.l	#6,d1
	addq.w	#1,a5
	bra	.cont
.store	add.l	#9,d1
	cmp.l	a5,a6
	bgt.s	.ok
	move.l	a5,a6
.ok	lea	0.w,a5
.cont	move.b	d2,d0
	cmp.l	#end_s,a0
	blt.s	.loop
	lsr.l	#3,d1
	move.l	#end_s,d7
	sub.l	#sample,d7
	sub.l	d1,d7
	bpl.s	not_longer
	move.w	#$ffff,er_flag
not_longer
	move.l	d7,bytes_saved
	move.l	a6,workspace
	lea	saved_mess,a0
	bsr	print_string
	tst.w	er_flag
	beq.s	fns
	lea	xxxx,a0
	bsr	print_string
	bra.s	ws
fns	move.l	bytes_saved,d0
	move.l	#10,d1
	bsr	printn
ws	lea	workspace_mess,a0
	bsr	print_string
	move.l	workspace,d0
	move.l	#10,d1
	bsr	printn
	lea	pak,a0
	bsr	print_string
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
exit	clr.w	-(sp)
	trap	#1

;************************************
;* Print out any number in any base *
;*     D0.L=number / D1.L=base      *
;*         Uses D0, D1, A0          *
;************************************
printn
	lea	buffer,a0	A0=buffer
	clr.l	(a0)+		Zero buffer
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
loop1
	divu	d1,d0
	swap	d0
	addi	#'0',d0
	cmpi	#'9',d0
	ble.s	ok
	addq	#7,d0
ok
	move.b	d0,-(a0)
	clr	d0
	swap	d0
	bne	loop1
loop2
print_string
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

buffer
	ds.l	5            Number$ - 20 digits
	dc.b	0            Buffer end marker
	even

er_flag:	dc.w	0
bytes_saved	dc.l	0
workspace	dc.l	0
mess	dc.b	27,'E'
	dc.b	"P.O.V. sample analyser V2.1",13,10
	dc.b	"---------------------------",13,10,10
	dc.b	"Original written by Boris",13,10,10
	dc.b	"Version 2.1 by Mac Sys Data",13,10,10,10
	dc.b	"Analysing sample...",13,10,10
	dc.b	0
	even
saved_mess
	dc.b	13,10,"Bytes saved      > ",0
workspace_mess
	dc.b	13,10,"Workspace needed > ",0
xxxx	dc.b	"XXXXX - file is larger",0
	even
pak	dc.b	13,10,10,"Press a key..",13,10,0
	even
sample
	incbin	"e:\acid_mix\acid_mix.spl"
end_s
