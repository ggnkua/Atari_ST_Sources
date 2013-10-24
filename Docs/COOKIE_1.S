**** show cookie jar contents	
****

_p_cookies	equ	$5a0
dos		equ	1
xbios		equ	14
Pterm0		equ	0
Cconws		equ	9
Supexec		equ	$26

start:
	move.l	#stack,sp		;set up our stack
	pea	disp_jar
	move.w	#Supexec,-(sp)
	trap	#xbios
	addq.l	#6,sp

	move.w	#Pterm0,-(sp)
	trap	#1

disp_jar
	move.l	_p_cookies,d0
	beq	no_jar			;terminate if no jar
	move.l	d0,a0

loop:	move.l	(a0)+,d0		;get cookie ID
	move.l	(a0)+,d1		;get cookie value
	tst.l	d0			;end of jar?
	beq	jar_end
	bsr	show_cookie
	bsr	print_crlf
	bra	loop

no_jar	lea	no_jarm,a1
	bsr	print_stg
	rts

jar_end	lea	end_msg,a1
	bsr	print_stg
	lea	scratch,a1
	bsr	print_hex
	bsr	print_crlf
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

show_cookie
	lea	scratch,a1		;scratch buffer
	move.l	d0,(a1)+		;store ID
	move.l	#" = $",(a1)+
	clr.b	(a1)			;zero terminate
	lea	scratch,a1
	bsr	print_stg
	lea	scratch,a1

;fall through to print hex

print_hex
	move.l	a1,-(sp)
	bsr	print_hex_1
	clr.b	(a1)
	move.l	(sp)+,a1

print_stg
	movem.l	d0-d1/a0-a1,-(sp)	;save regs
	move.l	a1,-(sp)		;address of string
	move.w	#Cconws,-(sp)
	trap	#dos
	addq.l	#6,sp
	movem.l	(sp)+,d0-d1/a0-a1
	rts

print_crlf
	lea	crlf,a1
	bra	print_stg

print_hex_1
	swap	d1
	bsr	print_hex_w
	swap	d1
	bsr	print_hex_w
	rts

print_hex_w
	move.l	d1,-(sp)
	lsr.w	#8,d1			;shift low byte into D1
	bsr	print_hex_b
	move.l	(sp),d1			;get D1 from stack but don't unstack
	bsr	print_hex_b
	move.l	(sp)+,d1		;get D1 from stack and tidy
	rts

print_hex_b
	move.l	d1,-(sp)
	lsr.w	#4,d1			;shift high nibble
	bsr	lookup
	move.l	(sp)+,d1
	bsr	lookup
	rts

lookup	and.l	#$f,d1			;mask of crap
	lea	hextable,a2		;look up table
	move.b	0(a2,d1.w),d2		;get ASCII equivalent
	move.b	d2,(a1)+		;save in scratch area
	rts

hextable
	dc.b	'0123456789ABCDEF'

no_jarm	dc.b	'No cookie jar installed',13,10,0
end_msg	dc.b	'Total no of cookie slots :',0
crlf	dc.b	13,10,0

scratch	ds.l	4

	ds.l	99
stack	ds.l	1

	END


