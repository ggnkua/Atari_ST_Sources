* Modem term-prg
* By Tobias Nilsson, Techwave
* (7 bit, capture)
* Hey this is a test of the realtime, live, (visual) text-TV of TV4!
* v0.1
* Tone oriented... call 071-610133/62 (15.70:-/min)
* Sid: 695= klotter - nonexistant
* 940325...
* Sunbird hacks into computer mainframes...08 - xx20329  14xx	
* ATS11=0 fastest!  Abt 4.2tkn/sec
* 694= k„rleksh„lsning...

		bsr cnfg_RS232

***********************************************	
main_loop:

		tst.b	mac_flgx1
		beq.s	ignore
****
* We're now in modem tone-code mode...
****
		move.w	#$505,$ffff8240.w

		bsr	rawconio
		tst.w	d0
		beq.s	go_on
		bsr	code_char

		bra	go_on
****
ignore:
		move.w	#$777,$ffff8240.w
		bsr 	auxin_stat
		tst.w	d0
		beq.s	no_char
		bsr	auxin
		bsr	conout			; ASCII in d0...
no_char:
		bsr 	rawconio
		tst.w	d0
		beq.s	go_on
		bsr	auxout

go_on:

*** macros	
		tst.b 	mac_flg1
		beq.s 	ready
		sf 	mac_flg1
		lea 	mac_string1,a0
maclp1:		move.b 	(a0)+,d0	
		bsr.L 	auxout
		cmp.b 	#-1,(a0)
		bne.s 	maclp1
***

ready:		tst.b 	exit_flg
		beq.s 	main_loop
* quit
		lea	hang_string,a1
		bsr	send_string
		rts

***********************************************	

cnfg_RS232:
		move.w 	#-1,-(sp)  ; scr
		move.w 	#-1,-(sp)  ; tsr
		move.w 	#-1,-(sp)  ; rsr
		move.w 	#-1,-(sp)  ; ucr
		move.w 	#2,-(sp)   ; ctrl
		move.w 	#4,-(sp)   ; baud
		move.w 	#15,-(sp)
		trap   	#14
		lea    	14(sp),sp
		rts

* chk RS232 if character coming
auxin_stat:	move.w 	#$12,-(sp)	; auxin stat
		trap	#1
		addq.l 	#2,sp 
		rts

* chk RS232 state
auxout_stat:	move.w 	#$13,-(sp)	; auxout stat
		trap	#1
		addq.l 	#2,sp 
		rts

* wait for character from RS232
* with state chk
auxin:
		bsr	auxin_stat
		tst.w	d0
		beq.s	no_avail

		move.w 	#3,-(sp)
		trap 	#1
		addq.l 	#2,sp
no_avail:	rts

* check keyboard
rawconio:
		move.w 	#$ff,-(sp)
		move.w 	#6,-(sp)
		trap 	#1
		addq.l 	#4,sp
		tst.l 	d0
		bne.s 	got_it		
		rts

got_it:
* chk macrokeys...

		move.l 	d0,d1
		swap 	d1
		cmp.b 	#$3b,d1			; scancode
		beq.s 	st_mac1
		cmp.b 	#$44,d1			; f10= exit	
		beq.s 	st_exit
		cmp.b 	#$44-1,d1		; f9= tone mode	
		beq.s 	not_macx1
		cmp.b 	#$44-2,d1		; f8= send mess <<<			
		beq.s 	send_mess		
		rts

;		bra.s 	auxout	

st_mac1:	st 	mac_flg1
		rts
not_macx1:	not.b 	mac_flgx1
		rts
;not_macx2:	not.b 	mac_flgx2
;		rts
st_exit:	st 	exit_flg
		rts
  

* transfer character to RS232
* with state chk...
auxout:		and.w 	#$00ff,d0		; (8 or 7bit..)	
		movem.l	a0/a1,-(sp)		; fix shit later

		move.w	d0,d4
wait_out:	bsr	auxout_stat
		tst.w	d0
		beq.s	wait_out		; 0= not yet		

		move.w 	d4,-(sp)
		move.w 	#4,-(sp)
		trap 	#1
		addq.l 	#4,sp
		movem.l	(sp)+,a0/a1		; fix shit later
		rts		


* print character
conout:		and.w 	#$00ff,d0
;		move.b 	d0,(a6)+	; capture
		move.w 	d0,-(sp)
		move.w 	#2,-(sp)
		trap 	#1
		addq.l 	#4,sp
		rts


exit_flg:	dc.b 0
mac_string1:	dc.b "ATDT 071-610162;",$0d,-1
mac_flg1:	dc.b 0
;macst1:		dc.b "ATDT #;"


mac_flgx1:	dc.b 0
;mac_flgx2:	dc.b 0
even

*******************************************************	
* Tone-Message sender...			      * 
*******************************************************
* rating: about 140 chars/min (2.3/sec)
bflg:	dc.b 0,0

send_mess:
		tst.b	bflg
		bne.s	ff	
		movem.l	d0-d7/a0-a6,-(sp)
		bsr	autosend
		movem.l	(sp)+,d0-d7/a0-a6
				st	bflg
		bsr	pause
		bsr	pause
ff:
* send init	

		lea	i_string(pc),a1
		bsr	send_string

		lea	tone_message,a0
		moveq	#-36/2,d3			; modem buffer...
code_mess:
		move.b	(a0)+,d0
		cmp.b	#-1,d0
		beq.s	end_mess
		
		move.w	d0,d6
		move.l	a0,-(sp)
		bsr	conout
		move.l	(sp)+,a0
		move.w	d6,d0

		move.l	a0,-(sp)	; <
		bsr	get_tone
		move.b	(a0)+,d0
		bsr	auxout
		move.b	(a0)+,d0
		bsr	auxout
		move.l	(sp)+,a0	; <

		addq.w	#1,d3
		bmi.s	code_mess

		move.b	#";",d0
		bsr	auxout
		moveq	#$0d,d0			; "return", send it!!! 
		bsr	auxout	

		move.l	a0,-(sp)
		bsr	wait_ok
		move.l	(sp)+,a0
		bsr	modem_pause
		bsr	modem_pause
		bsr	modem_pause
		bsr	modem_pause

		cmp.b	#-1,(a0)
		beq.s	end_now				

		moveq	#-36/2,d3
		lea	i_string(pc),a1
		bsr	send_string
		bra.s	code_mess

end_mess:
		move.b	#";",d0
		bsr	auxout
		moveq	#$0d,d0			; "return", send it!!! 
		bsr	auxout	
		bsr	wait_ok
		bsr	modem_pause
		clr.w	d0
;		rts

end_now:	
;		illegal
		bsr	pause
		lea	endst(pc),a1
		bsr	send_string

		bsr	pause
		rts

endst:		dc.b 	"ATDT#;",$0d,-1
		even

pause:		move.w	#$2,d7
l2:		moveq	#$-1,d6
l1:		dbf	d6,l1
		dbf	d7,l2
		rts

;mac1:		dc.b "ATDT 071-610162;",$0d,-1
mac1:		dc.b "ATDT 29623;",$0d,-1
mac2:		dc.b "ATDT 694;",$0d,-1

autosend:
		lea	mac1(pc),a1
		bsr	send_string
		moveq	#40,d5
pl1:		bsr	pause
		dbf	d5,pl1

		rts

		lea	mac2(pc),a1
		bsr	send_string
		moveq	#10,d5
pl2:		bsr	pause
		dbf	d5,pl2
		rts

*******************************************************	
* Phone-tone coder...  For modem (Hayes comb.)        * 
*******************************************************
* char to B coded (toned) in d0...

code_char:
		bsr	get_tone
		cmp.w	#-1,d0
		beq.s	ready_tone
		

		move.l	a0,-(sp)
		bsr	conout
		move.l	(sp)+,a0

* send tone...	
		lea	i_string(pc),a1
		bsr	send_string
	
		move.b	(a0)+,d0
		bsr	auxout
		move.b	(a0)+,d0
		bsr	auxout

		move.b	#";",d0
		bsr	auxout
		moveq	#$0d,d0			; "return", send it!!! 
		bsr	auxout	
		bsr	wait_ok
		bsr	modem_pause
		bsr	modem_pause
;		not.b	$ffff8240.w		; <
ready_tone:
		rts

error:		move.w	#$600,$ffff8240.w
		illegal

********************************
* wait for modem... "OK"+$0d...
wait_ok:
		not.b	$ffff8240.w		; <
wait_1:		bsr 	auxin
		cmp.b 	er_string,d0		; "E"
		beq.s	error
		cmp.b	ok_string,d0		; "O"
		bne.s	wait_1
		not.b	$ffff8240.w
		rts

************
modem_pause:
		move.w	#$1b,d6
pa1:		move.w	#$ff,d5
pa2:		dbf	d5,pa2
		dbf	d6,pa1
		rts
*****
* d0=ASCII
get_tone:
		lea	tone_table(pc),a0
search:		cmp.b	(a0),d0
		beq.s	found
		addq.w	#3,a0
		cmp.b	#-1,(a0)
		bne.s	search
		moveq	#-1,d0
		rts				; fuck, no hunting luck...
found:	
		addq.w	#1,a0
		rts

**************
* string in a1
send_string:
		move.b	(a1)+,d0
		bsr	auxout
		cmp.b	#-1,(a1)
		bne.s	send_string		
		rts


i_string:  dc.b "ATDT",-1
ok_string: dc.b "OK",$0d,-1
er_string: dc.b "ERROR",$0d,-1
hang_string:dc.b "ATH",$0d,-1

* Input/Output ASCII table
tone_table:

	dc.b "A","10"
	dc.b "B","11"
	dc.b "C","12"
	dc.b "D","13"
	dc.b "E","14"
	dc.b "F","15"
	dc.b "G","16"
	dc.b "H","17"
	dc.b "I","18"
	dc.b "J","19"
	dc.b "K","20"
	dc.b "L","21"
	dc.b "M","22"
	dc.b "N","23"
	dc.b "O","24"
	dc.b "P","25"
	dc.b "Q","26"
	dc.b "R","27"
	dc.b "S","28"
	dc.b "T","29"
	dc.b "U","30"
	dc.b "V","31"
	dc.b "W","39"	; obs!
	dc.b "X","32"
	dc.b "Y","33"
	dc.b "Z","34"
	dc.b "","35"
	dc.b "Ž","36"
	dc.b "™","37"

	dc.b "0","0*"
	dc.b "1","1*"
	dc.b "2","2*"
	dc.b "3","3*"
	dc.b "4","4*"
	dc.b "5","5*"
	dc.b "6","6*"
	dc.b "7","7*"
	dc.b "8","8*"
	dc.b "9","9*"
	
	dc.b ".","40"
	dc.b ",","41"
	dc.b "?","42"
	dc.b "!","43"
	dc.b 34,"44"		; "
	dc.b "-","45"
	dc.b "&","46"
	dc.b "+","47"
	dc.b ":","48"

	dc.b " ","38"		; space
	dc.b "/","**"		; clr char...

	dc.b -1

tone_message:
	
;	dc.b "LOVE, PEACE & HARMONY... OUR OBSESSION IS OUR DESTINY... "
;	dc.b "LET EACHOTHER RULE THEMSELVES...   "
;	dc.b "THIS MESSAGE WAS BROUGHT 2 U BY LIFE & BELIEVE! "
;	dc.b "   SIGNING OFF - ",34,"XTC",34," " 
;	dc.b "I FJŽRRAN LAND VI ALLA SKALL VANDRA... "
;	DC.B "EN DR™M F™R MIG, ETT LIV T DIG... POR FAVOR! "
	dc.b " AQ, AQUARIUS... "

	dc.b -1

even
;capture:	equ $40000
