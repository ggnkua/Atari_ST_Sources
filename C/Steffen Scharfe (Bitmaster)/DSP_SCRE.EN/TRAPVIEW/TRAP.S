
trap1			equ		$84
host			equ 	$ffffa200

				import	txt
				
				move.l	4(sp),a0		;Base-Page
				move.l	#256,d7			;L„nge Base-Page
				add.l	$0c(a0),d7		;L„nge Programm
				add.l	$14(a0),d7		;L„nge Data
				add.l	$1c(a0),d7		;L„nge BSS
				
				pea		super
				move.w	#$26,-(sp)
				trap	#14
				addq.l	#6,sp
			
				clr.w	-(sp)
				move.l	d7,-(sp)
				move.w	#$31,-(sp)		;resident lassen
				trap	#1
				
super:			move.l	trap1,old_trap1
				move.l	#new_trap1,trap1
				rts

				dc.b	"XBRA"
				dc.b	"DSPS"
old_trap1:		dc.l	0
			
new_trap1:		btst	#5,(sp)			;Supervisor-Modus ?
				movem.l	d0/a0,-(sp)
				bne.s	super_trap		;ja
				move.l	usp,a0			;Stack-Adresse
				bra.s	m1

super_trap:		lea		16(sp),a0

m1:				move.w	(a0),d0			;Trap #1 - Nr
				cmp.w	#88,d0
				bcs.s	trap_ok
				move.w	#90,d0			;unknow Trap #1 call
trap_ok:		lea		txt,a0
				move.l	(a0,d0.w*4),a0	;Adresse fr Text				

OutTxt:			tst.b	(a0)
				bne.s	WaitEmpty
				move.b	#$d,(a0)		;0 -> $d
WaitEmpty:		btst	#1,host.w+2		;Host empty ?
				beq.s	WaitEmpty		;nein
				move.b	(a0),host.w+5	;TXH
				clr.b	host.w+6		;TXM
				clr.b	host.w+7		;TXL
				cmp.b	#$d,(a0)+
				bne.s	OutTxt

new_trap1_end:	movem.l	(sp)+,d0/a0
				move.l	old_trap1,-(sp)
				rts
				
