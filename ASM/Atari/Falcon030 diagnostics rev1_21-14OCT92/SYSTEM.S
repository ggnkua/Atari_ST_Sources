	.extern SysControl
	.text
* Submenu.s  
*       Display submenu for examine/modify system screen

* SPARROW TEST -------------------------------------------------
* V1.00 : 18DEC91 : RWS : Started from menu.s
* V1.01 : 19DEC91 : RWS : Now works, Moved stuff from menu.s 
* V1.10 : 16JAN92 : RWS : added config sys menu
* V1.11 : 22JAN92 : RWS : added pop of old return address, cleaned up
* V1.12 : 18MAY92 : RWS : took Switches & 50/60 Hz out. Don't need 'em anymore
* --------------------------------------------------------------
*********************************************************
*       Display title, RAM, menu, TV standard, etc.     *       
*********************************************************
*       This is the return point for finished command followed by cr
s1menu:	bsr     clearsc
	move.w  #bgrnd,palette

*------------------------------------------------
*       Print menu and wait for selection       

*       Display menu
s1dspmenu:
        movea.l #s1menumsg,a5     ;display tests
        bsr     dspinv
        btst    #kfail,consol   ;keyboard ok?
        bne.s   s1getkey

        moveq   #$1a,d1         ;disable joysticks
        bsr     ikbdput

*-------------------------------
*       Input selections
s1getkey:

*-------------------------------
*       Get immediate help keystrokes only right here. <- RWS : FOR SUBMENU

	bsr     uconin           ;get some upcase input

*       Check immediate type keys: help, ?, E, B, V, $ 
        cmpi.b  #esc,d0
        bne     s1scanch
	popretaddr		; back to the old menu
	popretaddr		; back to main menu
	bra	menu

s1scanch:   
        cmpi.b  #$62,d1         ;help key scan code?
        beq     s1mhelp
        cmpi.b  #'?',d0
        beq     s1mhelp
        cmpi.b  #'E',d0         ;E
        beq     w_r_mem         
*************************************************************************
        cmpi.b  #'B',d0         ;B	; MOVED TO E MENU : RWS : 19DEC91
        beq     bpsrate 
;	cmpi.b	#'S',d0		;S ADDED 19DEC91 : RWS
;	beq	swit1q
	cmpi.b	#'C',d0		;S ADDED 16JAN92 : RWS
	beq	sctrlq
;        cmpi.b  #'V',d0         ;V - cycle ( WAS X )
;        beq     v_50_60
        cmpi.b  #'$',d0         ;hidden key
        beq     date2

*************************************************************************

	bra	s1gb_ret

s1getbf7: rts                     

        bra     s1menu
  	
********************************* 19DEC91 : RWS
;swit1q:
;	bsr	Switches
;	bra	s1gb_ret

********************************* 16JAN92 : RWS
sctrlq:
	bsr	SysControl
	bra	s1gb_ret

*********************************
w_r_mem:
        bsr     wrmem
        bra     s1gb_ret

********************************
*       Video output rate toggle
;v_50_60:
;        btst    #1,v_shf_mod    ;mono?
;        bne     s1gb_ret          ;then do nothing
;        move.b  synmod,d0
;        eor.b   #2,d0
;        move.b  d0,synmod
;        bra.s   s1gb_ret

********************************
*       Display Help screen
s1mhelp:  bsr     clearsc
        lea     s1help1,a5
        bsr     dspmsg
        bsr     conin

s1gb_ret: moveq   #0,d0           ;flag empty getbuf ret
        rts

*********************************
*       Set RS232 rate
bpsrate:
        bsr     clearsc
        lea     bpsmsg,a5
        bsr     dspmsg

bps0:   moveq   #0,d0
        moveq   #1,d1
        bsr     move_cursor
        clr.l   d0
        move    rsrate,d0
;        bsr     dsprate         ;display current rate

newrate:
        bsr     conin
        cmp.b   #cr,d0
        beq.s   nrate2
        cmp.b   #esc,d0
        beq.s   nrate2
        cmp.b   #' ',d0
        bne.s   nrate1
nrate2: bra.s   s1gb_ret

nrate1: move    rsrate,d0       ;get current rate
        cmp.b   #$48,d1
        beq.s   bpsup
        cmp.b   #$50,d1
        bne.s   newrate

*       Decrease RS232 rate
        lsl     d0              ;x2 clock divider
        cmp     #64,d0
        bls.s   bpsset
        move    #2,d0           ;wrap around to max (9600)
        bra.s   bpsset

*       Increase RS232 rate
bpsup:  lsr     d0              ;/2 clock divider
        cmp     #1,d0           ;max rate 9600
        bhi.s   bpsset
        move    #64,d0          ;wrap around to min

*       save new rate
bpsset: move    d0,rsrate
        bsr     rsinit
        bra.s   bps0

*********************************
*       display date of this version
date2:   bsr     clearsc
        lea     datem,a5
        bsr     dspmsg
        bsr     conin
        cmpi.b  #'&',d0
        bne.s   .date1
        lea     myname2,a5
        bsr     dspmsg
        bsr     conin
.date1:  bra     gb_ret

**************
*            *
*  messages  *
*            *
**************
	.data

bpsmsg: dc.b    'Increase ',1,', Decrease ',2,cr,lf,eot

v_50msg:
        dc.b    '50 Hz  ',eot
v_60msg:
        dc.b    '60 Hz  ',eot

myname2: dc.b    tab,' by RWS',cr,lf,eot

*       character preceded by 1 is printed in inverse video
s1menumsg:
	dc.b	tab,tab,invtog,'Examine/Modify System Submenu',invtog,cr,lf,cr,lf	
 	dc.b	tab,iv,'B Set RS232 rate',cr,lf	; MOVED 19DEC91 : RWS
	dc.b	tab,iv,'C System Controls',cr,lf ; ADDED 16JAN92 : RWS 
	dc.b	tab,iv,'E Examine/Modify Memory',cr,lf
;	dc.b	tab,iv,'S Show configuration switch settings',cr,lf	
;	dc.b	tab,iv,'V Toggle video output--50/60 Hz',cr,lf
	dc.b	cr,lf
	dc.b	tab,iv,'? Submenu Help',cr,lf
	dc.b	lf
	dc.b	tab,'Enter letter: ',eot


*               '1234567890123456789012345678901234567890'

s1help1:
.if 0
	dc.b    'Use ESC to exit this submenu'
        dc.b    cr,lf
        dc.b    'Other stuff is still same as old test, just moved.'
	dc.b	cr,lf
	dc.b	'S - Displays current configuration switch settings.',cr,lf
	dc.b	'  Change switches, and press a key to display new settings',cr,lf
	dc.b	'  use ESC to exit.'
	dc.b	cr,lf
	dc.b	'C - Change System Controls. Allows setting of various soft switches',cr,lf
	dc.b	'  System clocks, enable and disable units, etc',cr,lf
	dc.b	cr,lf
	dc.b	' THIS WILL BE UPDATED! (we hope)'
        dc.b    cr,lf,lf
        dc.b    eot 
.endif             
