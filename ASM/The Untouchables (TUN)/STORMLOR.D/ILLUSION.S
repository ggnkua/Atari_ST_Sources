 format 0-,1-,2-
 list +

* SCROLLY RASTERS!!!
* USES: A0	TABS = 10		DEVPAC V2.23
 list -


	pea	start(pc)		; XBIOS -execute main program
	move	#38,-(sp)		; in supervisor mode
	trap	#14
	addq.l	#6,sp
	
	clr	-(sp)		; exit
	trap	#1



*------------------
start	move.b	#$12,$fffffc02.w	; disable mouse
	clr.b	$ffff8203.w	; set screen back (clear screen!)
	bsr	set_ints		; save/install interrupts


scan:	cmp.b	#57,$fffffc02.w	; wait for 'space'
	bne.s	scan


	bsr	rem_ints		; remove interrupts
	move.b	#8,$fffffc02.w	; enable mouse
	move	#$777,$ffff8240.w	; make border color white again

	rts


*------------------
keyhand:	move	#$2500,sr		; don't disturb us keyboard
	move.b	$fffffc02.w,rubbish	; empty kbd
	bclr	#6,$fffffa11.w	; clear interrrupt bit
	rte


*------------------
newvbl:	clr.b	$fffffa1b.w	; disable timer b 
	move.b	#1,$fffffa21.w	; set scanline
	move.b	#8,$fffffa1b.w	; enable timer b
	
	clr	scanline		; used to count scanlines
	
	addq	#8,pointer	; try these values: 2,4,8,10,16,20
	cmp	#400,pointer	; have we done the first 200 cols?
	bne.s	continue		; not yet, so carry on...
	clr	pointer		; yes! so reset pointer value

continue:	lea	palette(pc),a0	; address of color palettes
	add	pointer(pc),a0	; add the offset to that
	move.l	a0,next_col	; gives us the next color

	rte


*------------------
newhbl:	cmp	#199,scanline	; check for last scanline
	beq.s	end_of_scrn	; if so then ensure black into border
	move.l	a0,-(sp)		; save a0 onto stack
	move.l	next_col(pc),a0	; get the next color into a0
	move	(a0)+,$ffff8240.w	; put into border & increment
	move.l	a0,next_col	; save incremented color pointer
	move.l	(sp)+,a0		; POP!
	addq	#1,scanline	; counts scanlines for check above!
end_hbl	bclr	#0,$fffffa0f.w	; end the timer b interrupt
	rte
end_of_scrn
	clr	$ffff8240.w	; black out the last scanline
	bra.s	end_hbl		; that's it ...


*------------------
set_ints:	move	#$2700,sr		; shut ints.
	clr.b	$fffffa07.w	; disable timer b
	clr.b	$fffffa09.w	; disable timer c
	move.l	#keyhand,$118.w	; install keyhandler
	move.l	#newvbl,$70.w	; install vbl
	move.l	#newhbl,$120.w	; install timer b
	bset	#0,$fffffa07.w	; enable timer b
	bset	#0,$fffffa13.w	; set timer b mask
	move	#$2300,sr
	rts


*------------------
rem_ints:	move	#$2700,sr
	move.b	#$1e,$fffffa07.w	; mfp ...
	move.b	#$64,$fffffa09.w
	move.b	#$1e,$fffffa13.w
	move.l	#$fc06de,$70.w	; vbl
	move.l	#$e5f0e044,$120.w	; hbl
	move.l	#$fc29ce,$118.w	; key handler
	move	#$2300,sr
	rts



*------------------
	section data
rubbish	dc.b 0		; space for kbd data
scanline	dc.w 0		; holds value of current scanline
pointer	dc.w 0		; points to an offset in the color table
next_col	dc.l 0		; points to the next color

*------------------
* Yeah, the same palette as last time, but it scrolls nicely anyway ...
palette:
	rept 2	; devpac command -repeat the block of palettes twice
	
	dc.w	0,0,1,$11
	dc.w	$111,$112,$122,$222
	dc.w	$223,$233,$333,$334
	dc.w	$344,$444,$445,$455
	dc.w	$555,$556,$566,$666
	dc.w	$667,$677,$777,$776
	dc.w	$766,$666,$665,$655
	dc.w	$555,$554,$544,$444
	dc.w	$443,$433,$333,$332
	dc.w	$322,$222,$221,$211
	dc.w	$111,$110,$100,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	$10,$110,$111,$121
	dc.w	$221,$222,$232,$332
	dc.w	$333,$343,$443,$444
	dc.w	$454,$554,$555,$565
	dc.w	$665,$666,$676,$776
	dc.w	$777,$677,$667,$666
	dc.w	$566,$556,$555,$455
	dc.w	$445,$444,$344,$334
	dc.w	$333,$233,$223,$222
	dc.w	$122,$112,$111,$11
	dc.w	1,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,$100,$110
	dc.w	$111,$211,$221,$222
	dc.w	$322,$332,$333,$433
	dc.w	$443,$444,$544,$554
	dc.w	$555,$655,$665,$666
	dc.w	$766,$776,$777,$767
	dc.w	$667,$666,$656,$556
	dc.w	$555,$545,$445,$444
	dc.w	$434,$334,$333,$323
	dc.w	$223,$222,$212,$112
	dc.w	$111,$101,1,0
	dc.w	0,0,0,0
	dc.w	0,1,$11,$111
	dc.w	$112,$122,$222,$223
	dc.w	$233,$333,$334,$344
	dc.w	$444,$445,$455,$555
	dc.w	$556,$566,$666,$667
	dc.w	$677,$777,$777,$776
	dc.w	$766,$666,$665,$655
	dc.w	$555,$554,$544,$444
	dc.w	$443,$433,$333,$332
	dc.w	$322,$222,$221,$211
	dc.w	$111,$110,$100
	dc.w	$110,0,0,0,0
	dc.w	0,0,0,0

	endr	; end of repeat block
