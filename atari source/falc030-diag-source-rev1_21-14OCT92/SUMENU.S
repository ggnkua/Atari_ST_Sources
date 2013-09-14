*------------------------------------------------
SUtest:
        btst    #kfail,consol   ;keyboard ok?
        bne.s   .dspSUMenu
        moveq   #$1a,d1         ;disable joysticks
        bsr     ikbdput
.dspSUMenu:
        ISRTCVALID
        beq     .valid          
        bsr     setzerotime
        bsr     ClearNVRAM      ; if RTC ram not initialized (by P test), initialize it & skip other tests...
        RTCVALIDATE
.valid:
        lea.l   SUMenuMsg,a5     ; top part of menu
        bsr     dspinv
        btst    #kfail,consol   ;keyboard ok?
        bne     getkey
        moveq   #$1a,d1         ;disable joysticks
        bsr     ikbdput
        bsr     uconin          ; Wait for upcase char
        bsr     clearsc
* get key to change or exit
        cmpi.b  #'W',d0
	beq	WipeNVRAM
        cmpi.b  #'E',d0
        beq     ErrorReport
        cmpi.b  #'F',d0         ; secret key. Don't advertise it.
        beq     ForcePass
        bra     menu

*==============================
* ForcePass - set force status bits 
* I don't have time to be clever with this, though
* the lower case hooks might still be there.. : RWS
ForcePass:
	lea.l	forcemenu,a5
	bsr	dspinv
        bsr     uconin
        cmpi.b  #'P',d0
        beq     .ForceP
        cmpi.b  #'B',d0
        beq     .ForceB
        cmpi.b  #'F',d0
        beq     .ForceF
        cmpi.b  #'I',d0
        beq     .ForceI
        cmpi.b  #'U',d0
        beq     .ForceU
        bra     menu
.ForceP:
        RTCSETSUITEPASS #t_PREBURN
        lea.l   ptbl,a0
        bra     ForceBits
.ForceB:
        RTCSETSUITEPASS #t_BURNIN
        lea.l   btbl,a0
        bra     ForceBits
.ForceF:
        RTCSETSUITEPASS #t_POSTBURN
        lea.l   ftbl,a0
        bra     ForceBits
.ForceI:
        RTCSETSUITEPASS #t_INPROCESS
        lea.l   itbl,a0
        bra     ForceBits
.ForceU:
        RTCSETSUITEPASS #t_UNITASSY
        lea.l   utbl,a0
        bra     ForceBits
*=========================

	.data

*       character preceded by 1 is printed in inverse video
SUMenuMsg:
	dc.b	cr,lf,'-----',invtog,'SUPERVISOR CARTRIDGE',invtog,'-----',cr,lf
	dc.b	cr,lf
	dc.b	'Options:',cr,lf,lf
	dc.b	tab,iv,'F Force Tests',cr,lf
	dc.b	cr,lf
	dc.b	tab,iv,'W Erase Status and Start Over',cr,lf
	dc.b  cr,lf
	dc.b  '================================',cr,lf
	dc.b  lf
	dc.b  tab,iv,'E Error Report',cr,lf
	dc.b  lf
	dc.b  tab,'Enter letter: ',eot

forcemenu:
	dc.b  tab,iv,'P Pre Burn-In   ',tab,cr,lf
	dc.b  tab,iv,'B Burn-In  ',tab,tab,cr,lf
	dc.b  tab,iv,'F Post Burn-In  ',tab,cr,lf
	dc.b  tab,iv,'I In Process Assembly',cr,lf
	dc.b  tab,iv,'U Assembled Unit',tab,cr,lf
	dc.b	eot

	.text
