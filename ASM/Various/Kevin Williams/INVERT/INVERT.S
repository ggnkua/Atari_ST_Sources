
* Screen Inverter.  1992 KevSoft Public Domain Software


        move.l  #ustk,a7
        move.l  #appl_init,aespb
        jsr     aes            		* call AES
	move.w	intout,ap_rid
	move.l	#graf_handle,aespb
	jsr	aes
	move	intout,gr_handle
        move    ap_rid,intin
        move.l  #menu_name,addrin
        move.l  #menu_register,aespb
        jsr     aes
        move    intout,menu_id
	move.w	#1,scr_status		* defalt screen status

wait:   move.l  #messagebuf_b,addrin
	move.l  #evnt_mesag,aespb
        jsr     aes            		* call AES 
        move.l  #messagebuf_b,a0
        move.w  (a0),d0        		
        cmpi.w  #41,d0         		* close acc
        beq	end  
        cmpi.w  #40,d0
	bne	wait
	move.w	8(a0),d0
	cmp.w	menu_id,d0		* open acc
	bne	wait            
        jsr     do_it
	bra	wait
end:	move.w	6(a0),d0
	cmp	menu_id,d0
	beq	quit
	bra	wait
quit:	move.l	#appl_exit,aespb
	jsr	aes
	bra	wait

do_it:		move.l	#form_alert,aespb	* form alert box
		move.w	#1,intin
		move.l	#alert_text,addrin
		jsr	aes
		move.w	#4,-(sp)		* get res
		trap	#14
		addq.l	#2,sp
		move.w	d0,res
		cmpi.w	#1,scr_status
		bne	start
		move.l	#palette_buffer,a3	* read default palette
		move.l	#0,d3
loop:		move.w	#-1,-(sp)		* read contents
		move.w	d3,-(sp)
		move.w	#7,-(sp)		* setcolor
		trap	#14
		addq.l	#6,sp
		move.w	d0,(a3)+
		add	#1,d3
		cmpi.b	#16,d3
		bne	loop
start:		cmpi.w	#1,scr_status
		beq	invert
		bne	restore
restore:	move.l	#palette_buffer,-(sp)	* restore palette
		move.w	#6,-(sp)		* to defaults
		trap	#14
		add.l	#6,sp
		move.w	#1,scr_status
		bra	return
invert:		cmpi	#1,res
		beq	med_res
		cmpi	#2,res
		beq	hi_res
		cmpi	#0,res
		beq	low_res

low_res:	move.l	#pal,a0
		move.w	#$000,(a0)+
		move.w	#$111,(a0)+
		move.w	#$222,(a0)+
		move.w	#$333,(a0)+
		move.w	#$444,(a0)+
		move.w	#$555,(a0)+
		move.w	#$666,(a0)+
		move.w	#$777,(a0)+
		move.w	#$777,(a0)+
		move.w	#$777,(a0)+
		move.w	#$777,(a0)+
		move.w	#$777,(a0)+
		move.w	#$777,(a0)+
		move.w	#$777,(a0)+
		move.w	#$777,(a0)+
		move.w	#$777,(a0)+
		move.l	#pal,-(sp)
		move.w	#6,-(sp)
		trap	#14
		addq.l	#6,sp
		move.w	#0,scr_status
		bra	return

med_res:	move.l	#pal,a0		* adr of palette buffer
		move.w	#$000,(a0)+	* black background
		move.w	#$222,(a0)+	* dark grey
		move.w	#$444,(a0)+	* mid grey
		move.w	#$777,(a0)+	* white
		move.l	#pal,-(sp)	* put buffer address on stack
		move.w	#6,-(sp)	* opcode (set palette)
		trap	#14		* call xbios
		addq.l	#6,sp		* tidy stack
		move.w	#0,scr_status
		bra	return

hi_res:		move.l	#pal,a0
		move.w	#$000,(a0)+	* black
		move.w	#$777,(a0)+	* white
		move.l	#pal,-(sp)
		move.w	#6,-(sp)	
		trap	#14		* call xbios
		addq.l	#6,sp		* tidy stack
		move.w	#0,scr_status
return:		rts


		ds.l	100
		even
ustk:		ds.l	1

aes:		movem.l	d0-d7/a0-a6,-(sp)
		move.l	#aespb,d1
		move.w	#$c8,d0
		trap	#2
		movem.l	(sp)+,d0-d7/a0-a6
		rts

pal:		ds.w	16
w_handle:	ds.w	1		
menu_name:	dc.b	32,14,15," Invert Screen",0
messagebuf_b:	ds.b	16
ap_rid:		ds.w	1
gr_handle:	ds.w	1
scr_status:	ds.w	1
res:		ds.w	1
contrl:		ds.w	128
intin:		ds.w	128
intout:		ds.w	128
global:		ds.w	128
addrin:		ds.w	128
addrout:	ds.w	128
palette_buffer:	ds.w	16
appl_init:	dc.w	10,0,1,0,0
appl_exit:	dc.w	19,0,1,0,0
graf_handle:	dc.w	77,0,5,0,0
menu_register:	dc.w	35,1,1,1,0
evnt_mesag:	dc.w	23,0,1,1,0
form_alert:	dc.w	52,1,1,1,0
menu_id:	dc.w	1
aespb:		dc.l	contrl,global,intin,intout,addrin,addrout
alert_text:	dc.b	"[1][| INVERT SCREEN COLOURS "
		dc.b	"|          1992 KevSoft ]"
		dc.b	"[ DO IT! ]",0
	