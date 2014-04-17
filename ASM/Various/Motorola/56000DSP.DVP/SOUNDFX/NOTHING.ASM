BCR		EQU     $FFFE           ; Port A Bus Control Register
HTX		EQU     $FFEB           ; Host Transmit Data Register
HSR   	EQU	    $ffe9	 		; Host status register
RX		EQU     $FFEF           ; Serial Receive Data Register
TX		EQU     $FFEF           ; Serial Transmit Data Register
TSR		EQU 	$ffee			; don't care skip register
CRA  	EQU     $FFEC          	; SSI Control Register A
CRB   	EQU     $FFED           ; SSI Control Register B
SSR		EQU		$FFEE
IPR   	EQU     $FFFF           ; Interrupt Priority Register
PCC   	EQU     $FFE1           ; Port C Control Register
PCDDR 	EQU     $FFE3           ; Port C Data Direction Register

PBC		EQU		$ffe0			
HCR		EQU		$ffe8			
HRX		EQU		$ffeb			
	
	org x:$10

in_l                 dc 1
in_r                 dc 1
out_l                dc 1
out_r                dc 1
temp                 dc 1
temp1                dc 1
inflag               dc 1
outflag              dc 1
sync				 dc 0

	org p:$0
	jmp start

	org p:$000c
	jsr datain
	
	org p:$0010
	jsr dataout
	 
	org p:$40
start:
	MOVEP X:<<HRX,X0
	MOVEC #<0,SP
	MOVEP #>$4100,X:<<CRA
	MOVEP #>$1F8,X:<<PCC
	BTST  #4,X:<<SSR
	MOVEP #>$F800,X:<<CRB
	MOVEP #>0,X:<<BCR
	MOVEP #>$3000,X:<<IPR
	MOVEP #$000001,X:PBC

ints_on:
	ANDI  #<$FC,MR
main:
	JCLR  #0,X:<sync,main

;Daten einfach kopieren und nichts damit tun...

	MOVE  X:<in_l,X0
	MOVE  X0,X:<out_l
	MOVE  X:<in_r,X0
	MOVE  X0,X:<out_r


	BCLR  #0,X:<sync
	JMP   <main


;Interruptroutinen

datain:
	BSET  #0,X:<sync
	MOVE  X0,X:<temp
	MOVE  X1,X:<temp1
	JCLR  #0,X:<inflag,>do_leftin
do_rightin:
	MOVEP X:<<RX,X1
	MOVE  X1,X:<in_r
	BCLR  #0,X:<inflag
	MOVE  X:<temp,X0
	MOVE  X:<temp1,X1
	RTI
do_leftin:
	MOVEP X:<<RX,X0
	MOVE  X0,X:<in_l
	BSET  #0,X:<inflag
	MOVE  X:<temp,X0
	MOVE  X:<temp1,X1
	RTI

dataout:
	MOVE  X0,X:<temp
	MOVE  X1,X:<temp1
	JCLR  #0,X:<outflag,>do_leftout
do_rightout:
	MOVE  X:<out_r,X1
	MOVEP X1,X:<<RX
	BCLR  #0,X:<outflag
	MOVE  X:<temp,X0
	MOVE  X:<temp1,X1
	RTI
do_leftout:
	MOVE  X:<out_l,X0
	MOVEP X0,X:<<RX
	BSET  #0,X:<outflag
	MOVE  X:<temp,X0
	MOVE  X:<temp1,X1
	RTI

	