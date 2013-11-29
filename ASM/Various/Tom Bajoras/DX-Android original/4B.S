;*****************************************************************************;
;   module 4b source file    Copyright 1986 Tom Bajoras
;   edit menu command branching routine: br2anch
;*****************************************************************************;

 .text

;*****************************************************************************;
;   br2anch
;      x1 = itemx 0-10 (l)
;*****************************************************************************;

 .global br2anch

br2anch 	movem.l 	#$FFFE,-(a7)		; save registers
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)

			moveq   	#1,d6   		; d6.l = menux = 1 for branch routines
			move.l  	x1,d0   		; d0 = itemx = 0-11 (l)
			beq 		.setedit		; branch according to itemx
			cmpi.b  	#1,d0
			beq 		.wstoed
			cmpi.b  	#2,d0
			beq 		.edtows
			cmpi.b  	#3,d0
			beq 		.paramed
			cmpi.b  	#4,d0
			beq 		.greged
			cmpi.b  	#5,d0
			beq 		.scaled
			cmpi.b  	#6,d0
			beq 		.leved
			cmpi.b  	#7,d0
			beq 		.viewall
			bra 		.returnx		; illegal menu item simply returns

.return 	move.l  	d6,x1
			jsr 		infobar
.returnx	move.l  	(a7)+,x5		; restore registers,x1-x5,return
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1
			movem.l 	(a7)+,#$7FFF
			rts

.setedit	move.l  	d6,x1
			jsr 		creturn
			move.l  	#38,x1
			jsr 		getabc  		; with/without/only ?
			move.b  	y1,monedit  	; set monitoring mode requested
			bra 		.return 		; restore registers,x1-x5,return

.wstoed 	move.l  	d6,x1
			jsr 		creturn
			move.l  	#-1,x1
			move.l  	#6,x2
			jsr 		getyn   		; are you sure?
			tst.b   	y1
			bne 		.wstoed2
			jsr 		branch5
.wstoed2	jsr 		wstoed
			tst.b   	monws   		; if monws=1 send w.s. to synth
			beq 		.returnx
			jsr 		wstosyn
			jsr 		writdx7
			move.l  	#wkspace,x1
			add.l   	#145,x1
			jsr 		writfdx7
			bra 		.returnx		; restore registers,x1-x5,return

.edtows 	move.l  	d6,x1
			jsr 		creturn
			move.l  	#-1,x1
			move.l  	#6,x2
			jsr 		getyn   		; are you sure?
			tst.b   	y1
			bne 		.edtows2
			jsr 		branch5
.edtows2	jsr 		edtows
			tst.b   	monws   		; if monws=1 send w.s. to synth
			beq 		.returnx
			jsr 		wstosyn
			jsr 		writdx7
			move.l  	#wkspace,x1
			add.l   	#145,x1
			jsr 		writfdx7
			bra 		.returnx

.paramed	move.b  	#1,invtext  	; inverse cursor
			jsr 		paramed
			movem.l 	#$FFFE,-(a7)
			move.l  	#remouse,-(a7)
			move.w  	#1,-(a7)		;  These two dis-allow's are just
			move.w  	#25,-(a7)   	;  to be safe.  might not be necessary.
			trap		#14 			; dis-allow mouse arrows
			addq.l  	#8,a7
			movem.l 	(a7)+,#$7FFF
			clr.b   	allowms 		; dis-allow mouse buttons
			clr.b   	invtext 		; normal cursor
			trap		#10 			; key rpt off
			jsr 		branch13		; re-init screen, return
remouse 	.byte   	8,0

.greged 	move.b  	#1,invtext  	; inverse cursor
			jsr 		greged
			clr.b   	invtext 		; normal cursor
			trap		#10 			; key rpt off
			jsr 		branch13		; re-init screen, return

.scaled 	move.b  	#1,invtext  	; inverse cursor
			jsr 		scaled
			clr.b   	invtext 		; normal cursor
			trap		#10 			; key rpt off
			jsr 		branch13		; re-init screen, return

.leved  	move.b  	#1,invtext  	; inverse cursor
			jsr 		leved
			clr.b   	invtext 		; normal cursor
			trap		#10 			; key rpt off
			jsr 		branch13		; re-init screen, return

.viewall	jsr 		viewall 		; view all 6 operator eg's
			jsr 		branch13

;*****************************************************************************;
;   initpri3 -- part of primary initialization daisy chain
;   			save original color pallette
;*****************************************************************************;

 .global initpri3

initpri3:
			lea 		colorsav,a6 	; save original colors
			move.w  	#-1,d0
			clr.w   	d1
.loop   	move.w  	d0,-(a7)
			move.w  	d1,-(a7)
			move.w  	#7,-(a7)
			trap		#14
			move.w  	d0,d7
			addq.l  	#2,a7
			move.w  	(a7)+,d1
			move.w  	(a7)+,d0
			move.w  	d7,(a6)+
			addq.w  	#1,d1
			cmpi.w  	#15,d1
			ble 		.loop

; daisy chain on to next
			jsr 		initpri4

			rts
