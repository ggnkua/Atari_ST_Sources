*----------------------------------------------
* Sparrow Dignostics 
* By Roy Stedman @ Atari 16DEC91

*(Stolen From:)

*       STe computer test v. 0.0
*       by      John Hinman
*               Atari Corp.
*       June 15 89

 .if !(^^defined HOST)
HOST    EQU     0      
 .endif                

 .if !(^^defined TOS)
TOS    EQU     0       
 .endif                

SUPERVISORCART = 0		; set to 1 for supervisor only cartridge
				; doesn't do much but reset NVRAM
	.globl	clearsc,dspinv,dspmsg,uconin
* prod/host/etc defines in defs.s now..
	.include defs		; non hardware equates should go here..

        .include hardware

	.include macros

	.include nvram		; added : 19MAY92 : RWS : RTC NVRAM ops (requires RTC.s)
*- non storage stuff only above this line.
        .include var

*	.include e_data		;expansion data space : 09APR92 : RWS (NOW IN VAR)

	.include version

        .include init

;	.include sysctrl	; added : 16JAN92 : RWS
;        .include excep
;        .include rom
;        .include color  
;        .include keybd
;        .include serial

        .include audio

        .include ram    

        .include timer

;        .include dma
;        .include joy

        .include hires

;        .include scroll

        .include menu
	
        .include rwh_at		; swapped : 11MAR92 : TF (not tested)

	.include wait		; MOVED FROM INIT.S 09APR92 : RWS
        
        .include wr

        .include blt		; RWS 1.18f

	.include system		; examine/modify system submenu added : 19DEC91 : RWS

;	.include switches	; added : 19DEC91 : RWS : removed again 18MAY92 : RWS
;	.include video		; added : 21JAN92 : RWS
;        .include hflop		; changed from flop by RWS 16DEC91        
;	.include dsp

        .include scrn16

	.include console	; ADDED 29JAN92 : RWS

;	.include sdma		; added in 30JUN92 : RWS : not linked yet.

        .include scc            ; added : 06FEB92 : RWS - try scc_r.s 
                                ; fixed : 11MAR92 : TF (SCC version working)

        .include midi

;	.include rtc		; ADDED 24JAN92 : RWS

	.include init2

;        .include scsi           ; added (not linked to test) : 06FEB92 : RWS ; modified and linked : 11MAR92 : TF (not tested)
;        .include xblt
;	.include e_exp		; Tom Le's expansion port tester

             .NLIST

;        .include fonts
        .end
