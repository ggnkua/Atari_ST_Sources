;*********************************************
; VPIS 1: komunikace pomoc¡ host-interface
;*********************************************
	org	P:0	;reset
	jmp	$40	;main programm

	org	P:$0020	;HI receive
	jmp	to_dsp
	org	P:$0022	;HI transmit
	jmp	from_dsp

	org	P:$40
main:	move	#data_in,R0
	move	#3,M0

	movep	#1,X:PBC	;m¢d: host-interface
	movep	#$0C00,X:IPR	;priorita: 2
	movep	#0,X:HCR	;vypni XMT i RCV
	move	#0,SR	;odmaskuj v¨echna p©eru¨en¡

	move	#>8,X0	;maska pro HF0
loop:	movep	X:HSR,A	;‡ekej na nastaven¡ HF0
	and	X0,A
	jeq	loop

	movep	#3,X:HCR	;zapni XMT i RCV

	jmp	*	;nekone‡n  smy‡ka
;*********************************************
; p©eru¨ovac¡ rutiny
;*********************************************
to_dsp:
	movep	X:HRX,X:(R0)+	;p©ijmut  data
	rti

from_dsp:
	movep	#$123456,X:HTX	;vysl n¡ 24 bit– dat
	rti

	end	;konec v˜pisu 1
;*********************************************
