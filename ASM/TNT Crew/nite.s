;****************************************************************
;*********************** NITE-PROGRAM ***************************
;****************************************************************
;by Michael Bittner, October 18th 1990, for "ST NEWS"

start_prog:

	move.l	#3*60*200,delay0	;3 min
	clr.w	move_flag

	pea	install_vectors(pc)
	move	#38,-(sp)
	trap	#14		;SUPEXEC
	addq.l	#6,sp

;*** keep resident ***
	clr.w	-(sp)
	move.l	#end_prog-start_prog+256+32256,-(sp)
	move	#$31,-(sp)
	trap	#1

 
;*** set new vectors ***
install_vectors:
	move.l	$4ba.w,old_4ba
;--- change keyboard ---
	move.l	$118.w,old_kbd
	move.l	#new_kbd,$118.w
;--- change vbl ---
	move.l	$70.w,old_vbl
	move.l	#new_vbl,$70.w
	rts


;******************************
;*** new keyboard-interrupt ***
;******************************
new_vbl:
	move.l	d0,-(sp)
	move.l	$4ba.w,d0
	sub.l	old_4ba(pc),d0
	cmp.l	delay0(pc),d0
	blt.s	waitlonger
	move.l	$4ba.w,old_4ba
;--- timeout ---
	tst	nite_flag
	bne.s	waitlonger	;-> already dark
	move	#-1,nite_flag
	clr.w	move_flag
;--- switch away !!!! ---
	move.l	$ffff8200.w,save_scraddr  ;old screen address
	move.l	#screen+256,d0		  ;new screen address
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move	$ffff8240.w,save_color
	clr.w	$ffff8240.w			;black
waitlonger:
;--- switch back ? ---
	tst	nite_flag
	beq.s	vbl_ready
	tst	move_flag
	beq.s	vbl_ready
;--- switch back !!!! ---
	clr.l	$45e.w
	move.l	save_scraddr,$ffff8200.w
	move.w	save_color(pc),$ffff8240.w
	clr.w	nite_flag
vbl_ready:
	move.l	(sp)+,d0
old_vbl=*+2
	jmp	$123456


;*************************
;*** new vbl-interrupt ***
;*************************
new_kbd:
	move	#-1,move_flag
	move.l	$4ba.w,old_4ba		;start delay again

old_kbd=*+2
	jmp	$123456


	bss

move_flag:	ds.w	1
delay0:		ds.l	1
old_4ba:	ds.l	1
nite_flag:	ds.w	1
save_color:	ds.w	1
save_scraddr:	ds.l	1

end_prog:
screen:		ds.b	32256


	end
