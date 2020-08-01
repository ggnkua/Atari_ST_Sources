;*********************************************
; v˜pis 2: komunikace pomoc¡ SSI rozhran¡
;*********************************************

	include 'EXC_EQU.INC'
	include 'IO_EQU.INC'

	org p:$0
	jmp init

	org P:SSIR
	jsr receive
	org P:SSIRE
	jsr receive	;receive with exception
	
	org P:SSIT
	jsr transmit
	org P:SSITE
	jsr transmit	;transmit with exception



;*********************************************

	org p:$40
init:
	movec	#0,SP

	;***** port A configuration *****
	movep 	#>0,X:<<BCR

	;***** port C configuration *****
	;SSI interrupt priorita = 2
	movep	#$3000,X:IPR

	;SSI 16 bit a 2 (1+1) sloty na jeden frame
	;CRA = $4n00, kde n=(pocet casovych slotu-1)
	movep	#$4100,X:CRA

	;SSI network mode, komunikace + prerus. zapnuto, ext. clock
	movep	#$F800,X:CRB	;F800

	;port C: SSI mod zapnout
	movep	#$01F8,X:PCC

	btst	#4,X:<<SSR	;SCI status reg.
int_on:
	andi  	#<$FC,MR



;********************************************************
;******** zde umistit vlastni vypocetni rutiny **********
;********************************************************

main:
	move  X:<in_l,X0
	move  X0,X:<out_l
	move  X:<in_r,X0
	move  X0,X:<out_r

	jmp   <main



;*********************************************
; prerusovaci rutiny
;*********************************************
receive:
	move  	X0,X:<temp
	jclr	#3,x:<<SSISR,no_fsync	;RFS

	move	#<data_in,R7
	movep 	X:<<RX,X0	;first in frame is 1L
	move  	X0,X:(R7)+
	move  	X:<temp,X0
	rti
no_fsync:
	movep 	X:<<RX,X0	;other channels: 1R, 2L, ...
	move  	X0,X:(R7)+
	move  	X:<temp,X0
	rti
;*********************************************
transmit:
	move  	X0,X:<temp
	jset	#2,x:<<SSISR,fsync

	move  	X:<out_l,X0	;output LEFT channel
	movep 	X0,X:<<RX
	move  	X:<temp,X0
	rti
fsync:
	move  	X:<out_r,X0	;TFS is set at end of frame ->
	movep 	X0,X:<<RX 	;-> output RIGHT channel !!!
	move  	X:<temp,X0
	rti



;*********************************************
; data a promenne
;*********************************************
	org x:$0

data_in	ds 8	;misto pro 8 kanalu: 1L,1R,2L,2R,...
out_l                ds 1
out_r                ds 1
temp                 ds 1

	end	;konec vypisu 2
;*********************************************
