	output	.ro
	opt	o+,w-
	text
	bra.s	main
	;to get logic screen
	dc.l	'PHYS'
	;to be called in USER mode
	dc.l	'USER'
	;end of flags
	dc.l	0
main:
	;menu_bar on
	move.w	#1,intin
	move.l	#menu_tree,addrin
	bsr	menu_bar
.more_msg:
	bsr	evnt_mesag
	cmp.w	#10,msgbuf
	bne.s	.more_msg
	;off
	clr.w	intin
	move.l	#menu_tree,addrin
	bsr	menu_bar
	rts

evnt_mesag:
	move.w	#23,control
	move.w	#0,control+2
	move.w	#1,control+4
	move.w	#1,control+6
	move.l	#msgbuf,addrin
	bra	call_aes	

menu_bar:
	move.w	#30,control
	move.w	#1,control+2
	move.w	#1,control+4
	move.w	#0,control+6
;	bra	call_aes
call_aes:
	move.l	#gem_array,d1
	move.w	#$c8,d0
	trap	#2
	move.w	intin(pc),d0
	rts

	data
	even
gem_array:
	dc.l	control
	dc.l	global
	dc.l	intin
	dc.l	intout
	dc.l	addrin
	dc.l	addrout
menu_tree:
	dc.w	0
	bss
	even
control:	ds.w	4
global:	ds.w	14
intin:	ds.w	16
intout:	ds.w	7
addrin:	ds.w	6
addrout:	ds.w	6
msgbuf:	ds.w	16
	end

