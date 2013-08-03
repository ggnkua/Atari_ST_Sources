;This program reads every file in the directory, and saves them into
;folder named PROCESS under the same directory.
;
;You need to create PROCESS-folder BEFORE running this program,
;no checking is made.
;
;Make also sure, that the files fit into the memory, as no checking 
;is made on this either.
;

upx_dir
	pea	file2(pc)
	move.w	#$19,-(sp)
*	trap	#1
	addq.l	#6,a7

          pea	buffer(pc)
          move   #$1a,-(sp)
          trap   #1
          addq.l #6,sp
          move   #%11001,-(sp)
          pea 	file1(pc)
          move   #$4e,-(sp)
          trap   #1
          addq.l #8,sp
          tst    d0
          bne    exit
more:     
	lea	file1+44-$10(pc),a4
	lea	where(pc),a6
	move.w #0,-(sp)          ;let's load the program
          pea (a4)
          move.w #$3d,-(sp)
          trap #1
          addq.l #8,sp
	  tst.l	d0
	  bmi	not_this
          pea $1c(a6)
          move.l #$ffffff,-(sp)       
          move.w d0,-(sp)
          move.w #$3f,-(sp)
          move.w d0,d7
          trap #1
          add.l #12,sp
	btst #0,d0
	beq.s	equal
	addq.l	#1,d0
equal
		move.l	d0,2(a6)
		move.l	d0,a5
	
		lea	$1c(a5),a5
          move.w d7,-(sp)
          move.w #$3e,-(sp)
          trap #1
          addq.l #4,sp
	
	cmp.w	#$601a,$1c(a6)	;already a program?
*	beq.s	not_this

	lea	file1+44-$10(pc),a4
	lea	extension(pc),a0
	moveq	#12,d0
loopex2
	move.b	(a4)+,(a0)+
	dbf	d0,loopex2
	lea	file2(pc),a4
again		
          move.w #0,-(sp)          ;let's save the program
          pea (a4)
          move.w #$3c,-(sp)
          trap #1
          addq.l #8,sp
          pea	(a6)
          pea	(a5)       ;length of the program again
          move.w d0,-(sp)
          move.w #$40,-(sp)
          move.w d0,d7
          trap #1
          add.l #12,sp
	  move.l	a5,d1
	  cmp.l	d0,d1
	  bne.s	error
          move.w d7,-(sp)
          move.w #$3e,-(sp)
          trap #1
          addq.l #4,sp
not_this
          move #$4f,-(sp)
          trap #1
          addq.l #2,sp
          tst d0
          bne exit
          bra more
exit:     clr.l -(sp)              ;exit to Desktop
          trap #1
error
	  move.w	#7,-(sp)
	  trap	#1
	  addq.l	#2,a7
	  bra.s	again

          SECTION DATA
file2:
	dc.b	'process\'
extension
	dc.b	0,'2345678.123',0
	even
start2:   ds.l 1
store1:   ds.l 1
	  ds.b	1
bull:     dc.b 11
buffer:   dc.b 44
shit:     dc.b 22
file1:    dc.b '*.*',0 
	  ds.b	100
where
	dc.w	$601a
	ds.b	$1a
*	incbin	header.dat
here


          END

