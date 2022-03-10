; rs38400.s
;
; Set RS232 port to 38400 baud
;
; It does this by switching off the /16 flag and using a count of 8 in
; divide by 4 mode.
;
; 2.4576MHz / (2 * 4 * 8) = 38400
;
; This is unlikely to work reliably because the auto-synch feature of
; the RS232 is disabled!

	csect text,0

;----------------
; Define the MFP68901 registers

mfp equ $fffffa01

gpip	equ 0
aer     equ 2
ddr     equ 4
iera    equ 6
ierb    equ 8
ipra    equ 10
iprb    equ 12
isra    equ 14
isrb    equ 16
imra    equ 18
imrb    equ 20
vr      equ 22
tacr    equ 24
tbcr    equ 26
tcdcr   equ 28
tadr    equ 30
tbdr    equ 32
tcdr    equ 34
tddr    equ 36
scr     equ 38
ucr     equ 40
rsr     equ 42
tsr     equ 44
udr     equ 46

;----------------------------
; Set the baud rate to 38400
;
; Must be called in Superviser mode

	xdef set38400
set38400:
	lea		mfp,a0			; Point to the MFP chip

	clr.b	rsr(a0)			; Disable receiver
	clr.b	tsr(a0)			; Disable sender


	bclr 	#4,imrb(a0)		; Disable interrupt and clear pending/in-service/etc
	bclr 	#4,ierb(a0)
	bclr 	#4,iprb(a0)
	bclr 	#4,isrb(a0)

	move.b	tcdcr(a0),d0	; Stop timer
	andi.b	#$f8,d0
	move.b	d0,tcdcr(a0)

	move.b	%00001000,ucr(a0)	; no div16, 1 start, 1 stop, no parity
.wait
	move.b	#8,tddr(a0)			; divide by 8
	cmpi.b	#8,tddr(a0)
	bne.s	.wait

	ori.b	#1,d0			; Enable timer in div 4 mode
	move.b	d0,tcdcr(a0)

	move.b	#1,rsr(a0)		; Enable receiver
	move.b	#1,tsr(a0)		; Enable Sender

	rts


	end
