*************************************************
*
* GEMMA Extension for STOS, interpreter version.
*
* AES extension, v1.50 Part 1
*
* (c)1997 The GEMMA programming team
* All rights reserved.
*
* This source code, (or any derived from it) may only
* only be distributed under the GNU Public Licence
* (available on request). In essence this states that
* this source code must be available and that binaries
* must be distributed as freeware.
*
* The authors reserves the right to change the status of
* this software at any time, without prior warning or
* notification.
*
*    Supervisor mode   - The AES should NOT be called from
*                        supervisor mode (which STOS is in)
*    on-line help (not one help command per new command!)

* Jump header

	output C:\STOS\GEMMA.EXD

        bra     INIT

***********************************************
*
* Header
*

* Start of token list
        dc.b    128

TOKENS  

* even=instruction, odd=function
	dc.b	"appl_exit",128
	dc.b	"appl_read",129
	dc.b	"objc_sysvar",130
	dc.b	"appl_write",131
	dc.b	"appl_tplay",132	* 5
	dc.b	"appl_init",133
	dc.b	"mnu_popup",134
	dc.b	"appl_search",135
	dc.b	"evnt_mouse",136
	dc.b	"evnt_keybd",137	* 10
	dc.b	"evnt_timer",138
	dc.b	"evnt_buttn",139
	dc.b	"evnt_mesag",140
	dc.b	"evnt_multi",141
	dc.b	"mnu_ienable",142	* 15
	dc.b	"evnt_dclick",143
	dc.b	"mnu_icheck",144
	dc.b	"mnu_br",145
	dc.b	"mnu_tnormal",146
	dc.b	"mnu_register",147	* 20
	dc.b	"mnu_text",148
	dc.b	"appl_trecord",149
	dc.b	"mnu_attach",150
	dc.b	"mnu_istart",151
	dc.b	"mnu_settings",152	* 25
	dc.b	"objc_find",153
	dc.b	"objc_add",154
	dc.b	"objc_delete",155
	dc.b	"objc_draw",156
	dc.b	"objc_offset",157	* 30
	dc.b	"objc_order",158
	dc.b	"frm_keybd",159
	dc.b	"objc_change",160
	dc.b	"dummygemma",161	* Doesn't ever work at this position!
	dc.b	"frm_dial",162		* 35
	dc.b	"frm_do",163
	dc.b	"frm_error",164
	dc.b	"frm_alert",165
	dc.b	"objc_edit",166
	dc.b	"appl_find",167		* 40
	dc.b	"graf_rubberbox",168
	dc.b	"frm_button",169
	dc.b	"graf_dragbox",170
	dc.b	"graf_handle",171
	dc.b	"graf_growbox",172	* 45
	dc.b	"graf_watchbox",173
	dc.b	"graf_shrinkbox",174
	dc.b	"graf_slidebox",175
	dc.b	"graf_movebox",176
	dc.b	"graf_mouse",177	* 50
	dc.b	"graf_mkstate",178
	dc.b	"operver",179
	dc.b	"scrp_write",180
	dc.b	"wind_close",181
	dc.b	"scrp_read",182		* 55
	dc.b	"wind_create",183
	dc.b	"wind_open",184		* wind_open - crashes with people!
	dc.b	"dummygemma",185	* Doesn't work either
	dc.b	"wind_delete",186
	dc.b	"wind_get",187		* 60
	dc.b	"wind_set",188
	dc.b	"wind_find",189
	dc.b	"wind_update",190
	dc.b	"wind_calc",191

* The end of the token list
        dc.b    0

	even
	
* Now the jump table

JUMPS   dc.w   64		in order of token, starting from 128
	dc.l	appl_exit
	dc.l	appl_read
	dc.l	objc_sysvar
	dc.l	appl_write
	dc.l	appl_tplay	* 5
	dc.l	appl_init
	dc.l	menu_popup
	dc.l	appl_search
	dc.l	evnt_mouse
	dc.l	evnt_keybd	* 10
	dc.l	evnt_timer
	dc.l	evnt_button
	dc.l	evnt_mesag
	dc.l	evnt_multi
	dc.l	menu_ienable	* 15
	dc.l	evnt_dclick
	dc.l	menu_icheck
	dc.l	menu_bar
	dc.l	menu_tnormal
	dc.l	menu_register	* 20
	dc.l	menu_text
	dc.l	appl_trecord
	dc.l	menu_attach
	dc.l	menu_istart
	dc.l	menu_settings	* 25
	dc.l	objc_find
	dc.l	objc_add
	dc.l	objc_delete
	dc.l	objc_draw
	dc.l	objc_offset	* 30
	dc.l	objc_order
	dc.l	form_keybd
	dc.l	objc_change
	dc.l	dummy
	dc.l	form_dial	* 35
	dc.l	form_do
	dc.l	form_error
	dc.l	form_alert
	dc.l	objc_edit		* swaped form_keybd+objc_edit around
	dc.l	appl_find	* 40
	dc.l	graf_rubberbox
	dc.l	form_button
	dc.l	graf_dragbox
	dc.l	graf_handle
	dc.l	graf_growbox	* 45
	dc.l	graf_watchbox
	dc.l	graf_shrinkbox
	dc.l	graf_slidebox
	dc.l	graf_movebox
	dc.l	graf_mouse	* 50
	dc.l	graf_mkstate
	dc.l	operver
	dc.l	scrp_write
	dc.l	wind_close
	dc.l	scrp_read	* 55
	dc.l	wind_create
	dc.l	wind_open
	dc.l	dummy
	dc.l	wind_delete
	dc.l	wind_get	* 60
	dc.l	wind_set
	dc.l	wind_find
	dc.l	wind_update
	dc.l	wind_calc

* macro to call a given AES routine
aes	macro	aes_number
	move	#\1,d0
	lea	control,a1
	move.w	d0,(a1)+			store the op code
	sub.w	#10,d0
	mulu	#3,d0			size is the priority, not speed
	lea	gem_ctrl_list,a0
	add.w	d0,a0			points to the entry
	moveq	#0,d0
	move.b	(a0)+,d0
	move.w	d0,(a1)+		do control1
	move.b	(a0)+,d0
	move.w	d0,(a1)+		and control2
	move.b	(a0)+,d0
	move.w	d0,(a1)+		and control3
	clr.w	(a1)			assumes control4=0 (all except RSRC_GADDR)
	move.l	#aes_params,d1

	move.w	#200,d0			function number
	trap	#2

	moveq.l	#0,d2
*	move.l	d0,d3
	clr.l	d3
	move.w	int_out,d3		usually a returned value
	endm



* The welcome mesages in English and French

WELCOME dc.b	10,13

	dc.b	10,13,"                          The GEMMA Extension v1.52"
	dc.b	10,13,"                       (c) 1997 The GEMMA programming team"
 	dc.b	10,13,"                           AES routines installed.",10,13,0

	dc.b	10,13,"                          le Extension GEMMA v1.52"
	dc.b	10,13,"                     (c) 1997 Le GEMMA programming team"
 	dc.b	10,13,"                        routines de AES installes.",10,13,0
        even

* Some system variables

RETURN		dc.l	0
SYSTEM		dc.l	0
SYSSTORE	ds.l	0

* The routine that is called on start-up

INIT    move.l	a6,SYSSTORE	* address of GEMMAOS desktop info!!!
	lea     END,a0
        lea     COLDST,a1
        rts

COLDST  move.l	a0,SYSTEM
	lea     WELCOME,a0      ; vital stuff
        lea     WARMST,a1
        lea     TOKENS,a2
        lea     JUMPS,a3
        rts

* Executed on UNDO in editor

WARMST  rts


*************************
*
* Our commands
*
*

* The AES commands --------------------------------------------

appl_init	move.l	(sp)+,RETURN
		tst	d0
		bne	SYNTAX

		aes	10

		move.l	RETURN,a0
		jmp	(a0)

appl_read	move.l	(sp)+,RETURN
		cmpi.w	#3,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * message
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		movem.l	(sp)+,d2-d4   * length
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * ap_id
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	11

		move.l	RETURN,a0
		jmp	(a0)


appl_write	move.l	(sp)+,RETURN
		cmpi.w	#3,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4    * msg
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		movem.l	(sp)+,d2-d4    * length
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4    * ap_id
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	12

		move.l	RETURN,a0
		jmp	(a0)


appl_find	move.l	(sp)+,RETURN
		cmpi.w	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * fname$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in

		aes	13

		move.l	RETURN,a0
		jmp	(a0)

appl_tplay	move.l	(sp)+,RETURN
		cmpi.w	#3,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * scale
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * num
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * mem&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	14

		move.l	RETURN,a0
		jmp	(a0)


appl_trecord	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * num
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * mem&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	15

		move.l	RETURN,a0
		jmp	(a0)

appl_search	move.l	(sp)+,RETURN
		cmpi.w	#4,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * ap_id
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,addr_in+8

		movem.l	(sp)+,d2-d4   * type
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,addr_in+4

		movem.l	(sp)+,d2-d4   * fname&
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.w	d3,addr_in

		movem.l	(sp)+,d2-d4   * mode
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	15

		move.l	RETURN,a0
		jmp	(a0)

appl_exit	move.l	(sp)+,RETURN
		tst.w	d0
		bne	SYNTAX

		aes	19

		move.l	RETURN,a0
		jmp	(a0)

evnt_keybd	move.l	(sp)+,RETURN
		tst.w	d0
		bne	SYNTAX

		aes	20

		move.l	RETURN,a0
		jmp	(a0)

evnt_button	move.l	(sp)+,RETURN
		cmpi.w	#7,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * kstate
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(kstate)
		move.w	2(a5),int_in+12

		movem.l	(sp)+,d2-d4   * button
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(button)
		move.w	2(a5),int_in+10

		movem.l	(sp)+,d2-d4   * yout
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(y_out)
		move.w	2(a5),int_in+8

		movem.l	(sp)+,d2-d4   * xout
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(x_out)
		move.w	2(a5),int_in+6

		movem.l	(sp)+,d2-d4   * state
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * mask
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * clicks
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	21

		* x
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		* y
		move.l	(y_out),a5
		move.w	int_out+4,2(a5)

		* button
		move.l	(button),a5
		move.w	int_in+6,2(a5)

		* kstate
		move.l	(kstate),a5
		move.w	int_in+8,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)                           

evnt_mouse	move.l	(sp)+,RETURN
		cmpi.w	#9,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * kstate
		tst.b	d2
		bne	TYPEMIS
		move.l	a5,(kstate)
		move.w	2(a5),int_in+16

		movem.l	(sp)+,d2-d4   * button
		tst.b	d2
		bne	TYPEMIS
		move.l	a5,(button)
		move.w	2(a5),int_in+14

		movem.l	(sp)+,d2-d4   * yout
		tst.b	d2
		bne	TYPEMIS
		move.l	a5,(y_out)
		move.w	2(a5),int_in+12

		movem.l	(sp)+,d2-d4   * xout
		tst.b	d2
		bne	TYPEMIS
		move.l	a5,(x_out)
		move.w	2(a5),int_in+10

		movem.l	(sp)+,d2-d4   * h
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+8

		movem.l	(sp)+,d2-d4   * w
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+6

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * flag
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	22

		* x
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		* y
		move.l	(y_out),a5
		move.w	int_out+4,2(a5)

		* button
		move.l	(button),a5
		move.w	int_out+6,2(a5)

		* kstate
		move.l	(kstate),a5
		move.w	int_out+8,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)

evnt_mesag	move.l	(sp)+,RETURN
		cmpi.w	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * msg
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	23

		move.l	RETURN,a0
		jmp	(a0)

evnt_timer	move.l	(sp)+,RETURN
		cmpi.w	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * hicount
		tst.b	d2                    
		bne	TYPEMIS
		swap	d3
		move.l	d3,int_in

		aes	24

		move.l	RETURN,a0
		jmp	(a0)

evnt_multi	move.l	(sp)+,RETURN
		cmpi.w	#22,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * gotclicks
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(gotclicks)
*		move.w	2(a5),int_in+38

		movem.l	(sp)+,d2-d4   * key_pressed
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(key_pressed)
*		move.w	2(a5),int_in+36

		movem.l	(sp)+,d2-d4   * kstate
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(kstate)
*		move.w	2(a5),int_in+34

		movem.l	(sp)+,d2-d4   * button
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(button)
*		move.w	2(a5),int_in+32

		movem.l	(sp)+,d2-d4   * yout
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(y_out)
*		move.w	2(a5),int_in+30

		movem.l	(sp)+,d2-d4   * xout
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(x_out)
*		move.w	2(a5),int_in+28

		movem.l	(sp)+,d2-d4   * time&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,int_in+28		* !!!!

		movem.l	(sp)+,d2-d4   * message&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		movem.l	(sp)+,d2-d4   * h2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+26

		movem.l	(sp)+,d2-d4   * w2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+24

		movem.l	(sp)+,d2-d4   * y2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+22

		movem.l	(sp)+,d2-d4   * x2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+20

		movem.l	(sp)+,d2-d4   * flag2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+18

		movem.l	(sp)+,d2-d4   * h1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+16

		movem.l	(sp)+,d2-d4   * w1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+14

		movem.l	(sp)+,d2-d4   * y1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+12

		movem.l	(sp)+,d2-d4   * x1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+10

		movem.l	(sp)+,d2-d4   * flag1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+8

		movem.l	(sp)+,d2-d4   * state
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+6

		movem.l	(sp)+,d2-d4   * mask
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * clicks
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * eflags
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	25

		* gotclicks
		move.l	(gotclicks),a5
		move.w	int_out+12,2(a5)

		* key_pressed
		move.l	(key_pressed),a5
		move.w	int_out+10,2(a5)

		* kstate
		move.l	(kstate),a5
		move.w	int_out+8,2(a5)

		* button
		move.l	(button),a5
		move.w	int_out+6,2(a5)

		* yout
		move.l	(y_out),a5
		move.w	int_out+4,2(a5)

		* xout
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)

evnt_dclick	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * setorget
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * newvalue
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	26

		move.l	RETURN,a0
		jmp	(a0)

menu_bar	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * flag
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	30

		move.l	RETURN,a0
		jmp	(a0)

menu_icheck	move.l	(sp)+,RETURN
		cmpi.w	#3,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * flag
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * item
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	31

		move.l	RETURN,a0
		jmp	(a0)

menu_ienable	move.l	(sp)+,RETURN
		cmpi.w	#3,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * flag
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * item
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	32

		move.l	RETURN,a0
		jmp	(a0)

menu_tnormal	move.l	(sp)+,RETURN
		cmpi.w	#3,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * flag
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * title
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	33

		move.l	RETURN,a0
		jmp	(a0)

menu_text	move.l	(sp)+,RETURN
		cmpi.w	#3,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * text$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in+4

		movem.l	(sp)+,d2-d4   * item
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	34

		move.l	RETURN,a0
		jmp	(a0)

menu_register	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * title
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in

		movem.l	(sp)+,d2-d4   * ap_id
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	35

		move.l	RETURN,a0
		jmp	(a0)

menu_popup	move.l	(sp)+,RETURN
		cmpi.w	#4,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * mdata&
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,addr_in+4

		movem.l	(sp)+,d2-d4   * ypos
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,int_in+2

		movem.l	(sp)+,d2-d4   * xpos
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * menu&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	36

		move.l	RETURN,a0
		jmp	(a0)

menu_attach	move.l	(sp)+,RETURN
		cmpi.w	#4,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * mdata&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in+4

		movem.l	(sp)+,d2-d4   * item
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		movem.l	(sp)+,d2-d4   * flag
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in


		aes	37

		move.l	RETURN,a0
		jmp	(a0)

menu_istart	move.l	(sp)+,RETURN
		cmpi.w	#4,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * item
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * imenu
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,int_in+2

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,addr_in

		movem.l	(sp)+,d2-d4   * flag
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,int_in

		aes	38

		move.l	RETURN,a0
		jmp	(a0)

menu_settings	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * set
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * flag
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,int_in

		aes	39

		move.l	RETURN,a0
		jmp	(a0)


objc_add	move.l	(sp)+,RETURN
		cmpi.w	#3,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * child
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * parent
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	40

		move.l	RETURN,a0
		jmp	(a0)

objc_delete	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * object
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	41

		move.l	RETURN,a0
		jmp	(a0)

objc_draw		move.l	(sp)+,RETURN
		cmpi.w	#7,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * h
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+10

		movem.l	(sp)+,d2-d4   * w
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+8

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+6

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * depth
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * object
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	42

		move.l	RETURN,a0
		jmp	(a0)

objc_find		move.l	(sp)+,RETURN
		cmpi.w	#5,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+6

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * depth
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * object
		tst.b	d2
		bne	TYPEMIS
		move.w	d2,int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	43

		move.l	RETURN,a0
		jmp	(a0)

objc_offset	move.l	(sp)+,RETURN
		cmpi.w	#4,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4    * y
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(y_out)
		move.w	2(a5),int_in+4

		movem.l	(sp)+,d2-d4    * x
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(x_out)
		move.w	2(a5),int_in+2

		movem.l	(sp)+,d2-d4    * object
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4    * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	44

		* x
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		* y
		move.l	(y_out),a5
		move.w	int_out+4,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)

objc_order	move.l	(sp)+,RETURN
		cmpi.w	#3,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * newpos
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * object
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	45

		move.l	RETURN,a0
		jmp	(a0)

objc_edit	move.l	(sp)+,RETURN
		cmpi.w	#6,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * newindex
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(w_out)
		move.w	d3,int_in+8

		movem.l	(sp)+,d2-d4   * kind
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+6

		movem.l	(sp)+,d2-d4   * index
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * char
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * object
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	46

		* newindex
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)

objc_change	move.l	(sp)+,RETURN
		cmpi.w	#8,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * flag
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+14

		movem.l	(sp)+,d2-d4   * newstate
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+12

		movem.l	(sp)+,d2-d4   * h
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+10

		movem.l	(sp)+,d2-d4   * w
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+8

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+6

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		clr.w	int_in+2

		movem.l	(sp)+,d2-d4   * object
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	47

		move.l	RETURN,a0
		jmp	(a0)

objc_sysvar	move.l	(sp)+,RETURN
		cmpi.w	#6,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * out2
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(x_out)
		move.w	2(a5),int_in+10

		movem.l	(sp)+,d2-d4   * out1
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(y_out)
		move.w	2(a5),int_in+8

		movem.l	(sp)+,d2-d4   * in2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+6

		movem.l	(sp)+,d2-d4   * in1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * which
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * mode
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	48

		* out1
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		* out2
		move.l	(y_out),a5
		move.w	int_out+4,2(a5)

		move.l	(mystore),a5


		move.l	RETURN,a0
		jmp	(a0)


form_do		move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * object
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	50

		move.l	RETURN,a0
		jmp	(a0)

form_dial		move.l	(sp)+,RETURN
		cmpi.w	#9,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * h2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+16

		movem.l	(sp)+,d2-d4   * w2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+14

		movem.l	(sp)+,d2-d4   * y2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+12

		movem.l	(sp)+,d2-d4   * x2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+10

		movem.l	(sp)+,d2-d4   * h1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+8

		movem.l	(sp)+,d2-d4   * w1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+6

		movem.l	(sp)+,d2-d4   * y1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * x1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * flag
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	51

		move.l	RETURN,a0
		jmp	(a0)

form_alert	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4    * alert$ (alert)
*		tst.b	d2
*		beq	TYPEMIS

		cmp.w	#$80,d2
		beq	.text
		bne	.value

.text		add.l	#2,d3
.value		move.l	d3,addr_in


		movem.l	(sp)+,d2-d4   * default
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	52

		move.l	RETURN,a0
		jmp	(a0)

form_error	move.l	(sp)+,RETURN
		cmpi.w	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * errorcode
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	53

		move.l	RETURN,a0
		jmp	(a0)

form_center	move.l	(sp)+,RETURN
		cmpi.w	#5,d0
		bne	SYNTAX

* form_center tree&, x, y, w,h

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * h
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(h_out)
		move.w	2(a5),int_in+6

		movem.l	(sp)+,d2-d4   * w
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(w_out)
		move.w	2(a5),int_in+4

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(y_out)
		move.w	2(a5),int_in+2

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(x_out)
		move.w	2(a5),int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	54

		* h
		move.l	(h_out),a5
		move.w	int_out+8,2(a5)

		* w
		move.l	(w_out),a5
		move.w	int_out+6,2(a5)

		* y
		move.l	(y_out),a5
		move.w	int_out+4,2(a5)

		* x
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)

form_keybd	move.l	(sp)+,RETURN
		cmpi.w	#6,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * keyout
		tst.b	d2
		bne 	TYPEMIS
		move.l	d3,a5
		move.l	a5,(x_out)
		move.w	2(a5),int_in+8

		movem.l	(sp)+,d2-d4   * newobj
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(y_out)
		move.w	2(a5),int_in+6

		movem.l	(sp)+,d2-d4   * kc
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * nextobj
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * obj
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	55

		* newobj
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		* keyout
		move.l	(y_out),a5
		move.w	int_out+4,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)

form_button	move.l	(sp)+,RETURN
		cmpi.w	#4,d0
		bne	SYNTAX

		move.l	a5,(mystore)	

		movem.l	(sp)+,d2-d4   * newobj
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(x_out)
		move.w	2(a5),int_in+4

		movem.l	(sp)+,d2-d4   * clicks
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * obj
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	56

		* newobj
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)

graf_rubberbox	move.l	(sp)+,RETURN
		cmpi.w	#6,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * outh
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(h_out)
		move.w	2(a5),int_in+10

		movem.l	(sp)+,d2-d4   * outw
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(w_out)
		move.w	2(a5),int_in+8

		movem.l	(sp)+,d2-d4   * minh
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+6

		movem.l	(sp)+,d2-d4   * minw
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	70

		* outw
		move.l	(w_out),a5
		move.w	int_out+2,2(a5)

		* outh
		move.l	(h_out),a5
		move.w	int_out+4,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)
	
graf_dragbox	move.l	(sp)+,RETURN
		cmpi.w	#10,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * outy
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(y_out)
*		move.w	2(a5),int_in+18

		movem.l	(sp)+,d2-d4   * outx
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(x_out)
*		move.w	2(a5),int_in+16

		movem.l	(sp)+,d2-d4   * boxh
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+14

		movem.l	(sp)+,d2-d4   * boxw
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+12

		movem.l	(sp)+,d2-d4   * boxy
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+10

		movem.l	(sp)+,d2-d4   * boxx
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+8

		movem.l	(sp)+,d2-d4   * starty
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+6

		movem.l	(sp)+,d2-d4   * startx
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * h
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * w
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	71

		* outx
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		* outy
		move.l	(y_out),a5
		move.w	int_out+4,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)

graf_movebox	move.l	(sp)+,RETURN
		cmpi.w	#6,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * y2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+10

		movem.l	(sp)+,d2-d4   * x2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+8

		movem.l	(sp)+,d2-d4   * y1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+6

		movem.l	(sp)+,d2-d4   * x1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * h
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * w
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	72

		move.l	RETURN,a0
		jmp	(a0)

graf_growbox	move.l	(sp)+,RETURN
		cmpi.w	#8,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * h2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+14

		movem.l	(sp)+,d2-d4   * w2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+12

		movem.l	(sp)+,d2-d4   * y2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+10

		movem.l	(sp)+,d2-d4   * x2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+8

		movem.l	(sp)+,d2-d4   * h1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+6

		movem.l	(sp)+,d2-d4   * w1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * y1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * x1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	73

		move.l	RETURN,a0
		jmp	(a0)

graf_shrinkbox	move.l	(sp)+,RETURN
		cmpi.w	#8,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * h2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+14

		movem.l	(sp)+,d2-d4   * w2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+12

		movem.l	(sp)+,d2-d4   * y2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+10

		movem.l	(sp)+,d2-d4   * x2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+8

		movem.l	(sp)+,d2-d4   * h1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+6

		movem.l	(sp)+,d2-d4   * w1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * y1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * x1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	74

		move.l	RETURN,a0
		jmp	(a0)

graf_watchbox	move.l	(sp)+,RETURN
		cmpi.w	#4,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * outstate
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+6

		movem.l	(sp)+,d2-d4   * instate
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * object
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2
		clr.w	int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	75

		move.l	RETURN,a0
		jmp	(a0)

graf_slidebox	move.l	(sp)+,RETURN
		cmpi.w	#4,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * vertical
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * object
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * parent
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	76

		move.l	RETURN,a0
		jmp	(a0)

graf_handle	move.l	(sp)+,RETURN
		cmpi.w	#4,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * wcell
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(x_out)
		move.w	2(a5),int_in+6

		movem.l	(sp)+,d2-d4   * hcell
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(y_out)
		move.w	2(a5),int_in+4

		movem.l	(sp)+,d2-d4   * wbox
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(w_out)
		move.w	2(a5),int_in+2

		movem.l	(sp)+,d2-d4   * hbox
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(h_out)
		move.w	2(a5),int_in

		aes	77

		* wcell
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		* hcell
		move.l	(y_out),a5
		move.w	int_out+4,2(a5)

		* wbox
		move.l	(w_out),a5
		move.w	int_out+6,2(a5)

		* hbox
		move.l	(h_out),a5
		move.w	int_out+8,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)

graf_mouse	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * user_form&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		movem.l	(sp)+,d2-d4   * flag
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	78

		move.l	RETURN,a0
		jmp	(a0)

graf_mkstate	move.l	(sp)+,RETURN
		cmpi.w	#4,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(x_out)
		move.w	2(a5),int_in+6

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(y_out)
		move.w	2(a5),int_in+4

		movem.l	(sp)+,d2-d4   * state
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(w_out)
		move.w	2(a5),int_in+2

		movem.l	(sp)+,d2-d4   * kstate
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(h_out)
		move.w	2(a5),int_in

		aes	79

		* x
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		* y
		move.l	(y_out),a5
		move.w	int_out+4,2(a5)

		* state
		move.l	(w_out),a5
		move.w	int_out+6,2(a5)

		* kstate
		move.l	(h_out),a5
		move.w	int_out+8,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)

scrp_read	move.l	(sp)+,RETURN
		cmpi.w	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * directory_name$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in

		aes	80

		move.l	RETURN,a0
		jmp	(a0)

scrp_write	move.l	(sp)+,RETURN
		cmpi.w	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * directory_name$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in

		aes	81

		move.l	RETURN,a0
		jmp	(a0)

fsel_input	move.l	(sp)+,RETURN
		cmpi.w	#3,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * ok (address!)
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(x_out)
		move.w	2(a5),int_in

		movem.l	(sp)+,d2-d4   * name$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in+4

		movem.l	(sp)+,d2-d4   * path$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in

		aes	90

		* ok
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)

fsel_exinput	move.l	(sp)+,RETURN
		cmpi.w	#4,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * promt$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in+8

		movem.l	(sp)+,d2-d4   * ok
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(x_out)
		move.w	2(a5),int_in

		movem.l	(sp)+,d2-d4   * name$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in+4

		movem.l	(sp)+,d2-d4   * path$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in

		aes	91

		* ok
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)
	
wind_create	move.l	(sp)+,RETURN
		cmpi.w	#5,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * h
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+8

		movem.l	(sp)+,d2-d4   * w
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+6

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * kind
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	100

		move.l	RETURN,a0
		jmp	(a0)

wind_open	move.l	(sp)+,RETURN
		cmpi.w	#5,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * h
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+8

		movem.l	(sp)+,d2-d4   * w
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+6

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	101

		move.l	RETURN,a0
		jmp	(a0)

wind_close	move.l	(sp)+,RETURN
		cmpi.w	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	102
		move.l	RETURN,a0
		jmp	(a0)

wind_delete	move.l	(sp)+,RETURN
		cmpi.w	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	103
		move.l	RETURN,a0
		jmp	(a0)

wind_get	move.l	(sp)+,RETURN
		cmpi.w	#6,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * h
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(h_out)
		move.w	2(a5),int_in+10

		movem.l	(sp)+,d2-d4   * w
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(w_out)
		move.w	2(a5),int_in+8

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(y_out)
		move.w	2(a5),int_in+6

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(x_out)
		move.w	2(a5),int_in+4

		movem.l	(sp)+,d2-d4   * sort
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	104

		* x
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		* y
		move.l	(y_out),a5
		move.w	int_out+4,2(a5)

		* w
		move.l	(w_out),a5
		move.w	int_out+6,2(a5)

		* h
		move.l	(h_out),a5
		move.w	int_out+8,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)

wind_set	move.l	(sp)+,RETURN
		cmpi.w	#6,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+10

		movem.l	(sp)+,d2-d4   * sort
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+8

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+6

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * w
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * h
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	105
		move.l	RETURN,a0
		jmp	(a0)

wind_find	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(y_out)
		move.w	2(a5),int_in+2

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(x_out)
		move.w	2(a5),int_in

		aes	106

		* x
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		* y
		move.l	(y_out),a5
		move.w	int_out+4,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)

wind_update	move.l	(sp)+,RETURN
		cmpi.w	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * sort
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	107
		move.l	RETURN,a0
		jmp	(a0)

wind_calc	move.l	(sp)+,RETURN
		cmpi.w	#10,d0
		bne	SYNTAX



		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * hout
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(h_out)
		move.w	2(a5),int_in+18

		movem.l	(sp)+,d2-d4   * wout
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(w_out)
		move.w	2(a5),int_in+16

		movem.l	(sp)+,d2-d4   * yout
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(y_out)
		move.w	2(a5),int_in+14

		movem.l	(sp)+,d2-d4   * xout
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(x_out)
		move.w	2(a5),int_in+12

		movem.l	(sp)+,d2-d4   * h
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+10

		movem.l	(sp)+,d2-d4   * w
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+8

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+6

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * kind
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * type
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	108





					* place values back into variables



		move.l	(h_out),a5
		move.w	int_out+8,2(a5)



		move.l	(w_out),a5
		move.w	int_out+6,2(a5)

		* yout
		move.l	(y_out),a5
		move.w	int_out+4,2(a5)


		* xout
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)



		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)

operver		move.l	(sp)+,RETURN
		cmpi	#0,d0
		bne	SYNTAX

		move.l	($4f2),sysbase		* Find OS base
		moveq.l	#0,d2
		move.l	(sysbase),a0
		add.w	#2,a0
		move.w	(a0),d3			* Return deek (OS+2)

		move.l	RETURN,a0
		jmp	(a0)
		
*******************
*
* Odds and sods...
*

dummy	move.l	(sp)+,RETURN
	bra	NOTDONE

SYNTAX	moveq	#12,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)

TYPEMIS	moveq	#19,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)

NOTDONE	moveq	#0,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)

call_vdi
	move.l	#vdi_params,d1
	move.w	#$73,d0
	trap	#2
	rts

call_aes
	move.l	#aes,d1
	move.w	#$C8,d0
	trap	#2
	move.w	int_out,d0
	rts

*************************
*
* Data space...
*


* this is a table of pointers to all the AES arrays
aes_params	dc.l	control,global,int_in,int_out,addr_in,addr_out

* this is the list of Control parameters for the AES calls
* contains control(1..3), comment is the function number
* (an asterisk indicates it is not defined)
gem_ctrl_list
	dc.b	0,1,0	10	appl_init
	dc.b	2,1,1	11	appl_read
	dc.b	2,1,1	12	appl_write
	dc.b	0,1,1	13	appl_find
	dc.b	2,1,1	14	appl_tplay
	dc.b	1,1,1	15	appl_record
	dc.b	0,0,0	16*
	dc.b	0,0,0	17*
	dc.b	1,3,1	18	appl_search (4.0)
	dc.b	0,1,0	19	appl_exit
	dc.b	0,1,0	20	evnt_keybd
	dc.b	3,5,0	21	evnt_button
	dc.b	5,5,0	22	evnt_mouse
	dc.b	0,1,1	23	evnt_mesag
	dc.b	2,1,0	24	evnt_timer
	dc.b	16,7,1	25	evnt_multi
	dc.b	2,1,0	26	evnt_dclick
	dc.b	0,0,0	27*
	dc.b	0,0,0	28*
	dc.b	0,0,0	29*
	dc.b	1,1,1	30	menu_bar
	dc.b	2,1,1	31	menu_icheck
	dc.b	2,1,1	32	menu_ienable
	dc.b	2,1,1	33	menu_tnormal
	dc.b	1,1,2	34	menu_text
	dc.b	1,1,1	35	menu_register
	dc.b	2,1,2	36	menu_popup (3.3)
	dc.b	2,1,2	37	menu_attach (3.3)
	dc.b	3,1,1	38	menu_istart (3.3)
	dc.b	1,1,1	39	menu_settings (3.3)
	dc.b	2,1,1	40	objc_add
	dc.b	1,1,1	41	objc_delete
	dc.b	6,1,1	42	objc_draw
	dc.b	4,1,1	43	objc_find
	dc.b	1,3,1	44	objc_offset
	dc.b	2,1,1	45	objc_order
	dc.b	4,2,1	46	objc_edit
	dc.b	8,1,1	47	objc_change
	dc.b	4,3,0	48	objc_sysvar
	dc.b	0,0,0	49*
	dc.b	1,1,1	50	form_do
	dc.b	9,1,0	51	form_dial
	dc.b	1,1,1	52	form_alert
	dc.b	1,1,0	53	form_error
	dc.b	0,5,1	54	form_center
	dc.b	3,3,1	55	form_keybd
	dc.b	2,2,1	56	form_button
	dc.b	0,0,0	57*
	dc.b	0,0,0	58*
	dc.b	0,0,0	59*
	dc.b	0,0,0	60*
	dc.b	0,0,0	61*
	dc.b	0,0,0	62*
	dc.b	0,0,0	63*
	dc.b	0,0,0	64*
	dc.b	0,0,0	65*
	dc.b	0,0,0	66*
	dc.b	0,0,0	67*
	dc.b	0,0,0	68*
	dc.b	0,0,0	69*
	dc.b	4,3,0	70	graf_rubberbox
	dc.b	8,3,0	71	graf_dragbox
	dc.b	6,1,0	72	graf_movebox
	dc.b	8,1,0	73	graf_growbox
	dc.b	8,1,0	74	graf_shrinkbox
	dc.b	4,1,1	75	graf_watchbox
	dc.b	3,1,1	76	graf_slidebox
	dc.b	0,5,0	77	graf_handle
	dc.b	1,1,1	78	graf_mouse
	dc.b	0,5,0	79	graf_mkstate
	dc.b	0,1,1	80	scrp_read
	dc.b	0,1,1	81	scrp_write
	dc.b	0,0,0	82*
	dc.b	0,0,0	83*
	dc.b	0,0,0	84*
	dc.b	0,0,0	85*
	dc.b	0,0,0	86*
	dc.b	0,0,0	87*
	dc.b	0,0,0	88*
	dc.b	0,0,0	89*
	dc.b	0,2,2	90	fsel_input
	dc.b	0,2,3	91	fsel_exinput
	dc.b	0,0,0	92*
	dc.b	0,0,0	93*
	dc.b	0,0,0	94*
	dc.b	0,0,0	95*
	dc.b	0,0,0	96*
	dc.b	0,0,0	97*
	dc.b	0,0,0	98*
	dc.b	0,0,0	99*
	dc.b	5,1,0	100	wind_create
	dc.b	5,1,0	101	wind_open
	dc.b	1,1,0	102	wind_close
	dc.b	1,1,0	103	wind_delete
	dc.b	2,5,0	104	wind_get
	dc.b	6,1,0	105	wind_set
	dc.b	2,1,0	106	wind_find
	dc.b	1,1,0	107	wind_update
	dc.b	6,5,0	108	wind_calc
	dc.b	0,0,0	109	wind_new
	dc.b	0,1,1	110	rsrc_load
	dc.b	0,1,0	111	rsrc_free
	dc.b	2,1,0	112 ** Control(4)=1 ** rsrc_gaddr
	dc.b	2,1,1	113	rsrc_saddr
	dc.b	1,1,1	114	rsrc_obfix
	dc.b	0,0,0	115	rsrc_rcfix (4.0)
	dc.b	0,0,0	116*
	dc.b	0,0,0	117*
	dc.b	0,0,0	118*
	dc.b	0,0,0	119*
	dc.b	0,1,2	120	shel_read
	dc.b	3,1,2	121	shel_write
	dc.b	1,1,1	122	shel_get
	dc.b	1,1,1	123	shel_put
	dc.b	0,1,1	124	shel_find
	dc.b	0,1,3	125	shel_envrn
	dc.b	0,0,0	126*
	dc.b	0,0,0	127*
	dc.b	0,0,0	128*
	dc.b	0,0,0	129*
	dc.b	1,5,0	130*	appl_getinfo (4.0)

	even

* these don't need initialising...
dummyout	ds.l	1
control		ds.w	5
global		ds.w	14
int_in		ds.w	16
int_out		ds.w	7
addr_in		ds.l	3
addr_out	ds.l	1
gemma		dc.b	0,4,"1.52"

*the VDI parameters

current_handle	ds.w	1

contrl		ds.w	1
contrl1		ds.w	1
contrl2		ds.w	1
contrl3		ds.w	1
contrl4		ds.w	1
contrl5		ds.w	1
contrl6		ds.w	1
contrl7		ds.w	1
contrl8		ds.w	1
contrl9		ds.w	1
contrl10	ds.w	1
contrl11	ds.w	1

intin		ds.w	128
intout		ds.w	128
ptsin		ds.w	128
ptsout		ds.w	128

global2		ds.w	14

vdi_params	dc.l	contrl,intin,ptsin,intout,ptsout
aes		dc.l	control,global2,int_in,int_out,addr_in,addr_out



mystore		ds.l	1
x_out		ds.l	1
y_out		ds.l	1
w_out		ds.l	1
h_out		ds.l	1
button		ds.l	1
kstate		ds.l	1
key_pressed	ds.l	1
gotclicks	ds.l	1
addr		ds.l	1
oldsp		ds.l	1
newsp		ds.l	1

sysbase		ds.l	1
mupb		ds.l	1

dump1		ds.w	1
dump2		ds.l	1
dump3		ds.l	1
dump4		ds.l	1

param		ds.l	4

END