;*********************************************
; DSP: compute screen in 16 bit gr. mode
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

	;***** port B configuration *****
	movep 	X:<<HRX,X0	;uvolnit host receive reg.
	movep	#1,X:<<PBC	;m¢d: host-interface
	movep	#0,X:<<HCR	;vypni XMT i RCV preruseni

	;***** port C configuration *****
	;SSI interrupt priorita = 2
	movep	#$3000,X:IPR

	;SSI 16 bit a 2 (1+1) sloty na jeden frame
	;CRA = $4n00, kde n=(pocet casovych slotu-1)
	movep	#$4100,X:CRA

	;SSI komunikace + prerus. zapnuto, network mode,
	;    asynchronous transmission (MOD,GCK,SYN,FSL1), external clock
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
;;	jclr  	#0,X:<sync,main	;cekej na synchronizaci

;;	jsr	host_comm	;komunikace s hostitelem

	move	#data_in,R0	;pointer to input data
	move	#weight,R4	;pointer to weight table
	nop
	;data v pameti X	;vahy v pameti Y
	move			X:(R0)+,X0	Y:(R4)+,Y0
	;A=1L*1Wl
	mpy	X0,Y0,A		X:(R0)+,X0	Y:(R4)+,Y0
	;B=1R*1Wr
	mpy	X0,Y0,B		X:(R0)+,X0	Y:(R4)+,Y0
;	move	A,X:out_l
;	move	B,X:out_r

	jmp   <main



;*********************************************
; prijem prikazu od hlavniho procesoru 68030
;*********************************************
host_comm:
	jclr	#0,X:<<HSR,end_comm	;zadna data od 68030

	movep	X:<<HRX,X0	;nactena data: hlavicka prikazu
	move	#$123456,A	;$123456 identifikuje prikaz
	cmp	X0,A
	jne	end_comm

	jsr	host_read	;kod prikazu pro DSP
	jset	#0,X0,read_weight	;KOD 1
end_comm:
	rts

read_weight:	;KOD 1: cte 8 hodnot vah
	jsr	host_read	;dalsi hodnota je vzdy delka dat
rw_loop:
	move	#weight,R0
	jsr	host_read
	move	X0,Y:(R0)+
	jsr	host_read
	move	X0,Y:(R0)+

	jsr	host_read
	move	X0,Y:(R0)+
	jsr	host_read
	move	X0,Y:(R0)+

	jsr	host_read
	move	X0,Y:(R0)+
	jsr	host_read
	move	X0,Y:(R0)+

;;;	jmp	end_comm
	jsr	host_read
	move	X0,Y:(R0)+
	jsr	host_read
	move	X0,Y:(R0)+
	
	jmp	end_comm



;*********************************************
; ceka dokud neprijde slovo od 68030 a vrati jej v X0
;*********************************************
host_read:
	jclr	#0,X:<<HSR,host_read	;zadna data od 68030
	movep	X:<<HRX,X0	;nactena data v X0
	rts



;*********************************************
; prerusovaci rutiny
;*********************************************
receive:
;	bset  	#0,X:<sync
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

	move  	X:<out_l,X0	;output LEFT channel !!!
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
	org	Y:$3FF0	;konec Y pameti

weight	dc $7FFF00	;vahy pro 4 kanaly
	dc $7FFF10	;predstavuji podil
	dc $3FFF20	;kanalu ve vystupni hodnote
	dc $3FFF30
	dc $3FFF40
	dc $3FFF50
	dc $3FFF60
	dc $3FFF70

	org x:$0

data_in	ds 8	;misto pro 8 kanalu: 1L,1R,2L,2R,...
in_l                 ds 1
in_r                 ds 1
out_l                dc $F00000
out_r                dc $001F00
temp                 ds 1
sync                 dc 0

	end
;*********************************************
