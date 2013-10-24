	NOLIST
; 25.07.1994 RxT Bernd Hbenett
; Zweiter Anlauf
; Diesmal mit Hilfe der Print-Window Funktion
; aus dem DSP-Debugger von Brainstorm

; 18.08.1994 RxT Bernd Hbenett
; In der Zwischenzeit ist die DSP-Routine schneller geworden.
; Bei einer Aufl”sung von 640x400 Pixeln betr„gt der Unterschied 0.50 Seknden.
; 29.08.1994 RxT Bernd Hbenett
; Die Routine ist NICHT mehr kompatible zu der Original-Routine

PBC	EQU	$FFE0	; Port B(HOST) Bus Control Register
PCC	EQU	$FFE1	; Port C Bus Control Register
HCR	EQU	$FFE8	; Host Control Register
HSR	EQU	$FFE9	; Host Status Register
HTX	EQU	$FFEB	; Host Transmit Data Register
HRX	EQU	$FFEB	; Host Receive Data Register
BCR	EQU	$FFFE	; Port A Bus Control Register
IPR	EQU	$FFFF	; Interupt Priority Register

	org	X:0
x1buf	dc	0
y1buf	dc	0
x1h	dc	0
width	dc	0
height	dc	0
depth	dc	0

	org	Y:0
y1h	dc	0
ydelta	dc	0
xdelta	dc	0
	dc	$400000		; Sehr Wichtig !!!

	org	P:$0
	jmp	Start

	org	P:$40

Start: 
	MOVEP #>0,X:<<HCR
	MOVEP #>$C00,X:<<IPR
	MOVEP #>1,X:<<PBC
	MOVEP #>0,X:<<BCR
	MOVEP #>$1FF,X:<<PCC
	ANDI  #<$F3,MR
	ANDI  #<$BF,CCR
	MOVEC #>$FFFF,M7
	MOVEC M7,M6
	MOVEC M7,M1
	MOVEC M7,M2
	MOVE  #<0,R7
	MOVE  #<3,R6
	MOVE  #<2,R1
	MOVE  #<2,R2
 main_loop: 
rec1:	JCLR  #0,X:<<HSR,rec1
	MOVEP X:<<HRX,X0
	MOVE  X0,X:<depth
rec2:	JCLR  #0,X:<<HSR,rec2
	MOVE  X:>$FFEB,X0
	MOVE  X0,X:<x1h

rec3:	JCLR  #0,X:<<HSR,rec3	
	MOVE  X:>$FFEB,X0
	MOVE  X0,Y:<xdelta

rec4:	JCLR  #0,X:<<HSR,rec4
	MOVEP X:<<HRX,X0
	MOVE  X0,X:<width

rec5:	JCLR  #0,X:<<HSR,rec5
	MOVE  X:>$FFEB,X0
	MOVE  X0,Y:<y1h

;rec6:	JCLR  #0,X:<<HSR,rec6	; Der Wert wird nicht ben”tigt
;	MOVE  X:>$FFEB,X0
;	MOVE  X0,Y:<ydelta

;rec7:	JCLR  #0,X:<<HSR,rec7	; Der Wert wird nicht ben”tigt
;	MOVEP X:<<HRX,X0
;	MOVE  X0,X:<height

	MOVE  X:<depth,N7
	MOVE  #>$1000,R5
	MOVE  X:<width,A
	MOVE  #<1,X0
	SUB   X0,A
	MOVEC A,M5
	DO    X:<width,>gegendx
	MOVE  #<0,X0
	MOVE  #<0,Y0
	MOVE  X:<x1h,X1
	MOVE  Y:<y1h,Y1
	DO    N7,>black
 iterate: 
	MPY   X0,X0,A
	ASL   A
	MPY   Y0,Y0,B
	ASL   B
	ASL   B     X0,X:(R7)
	ADDL  B,A   Y:(R6),X0
	ASR   A
	SUB   X0,A  X:(R7),X0
	JGE   >pixel
	MPY   X0,X0,A
	ASL   A
	SUBL  B,A
	SUB   X1,A
	MPY   Y0,X0,B
 	ASL   B
	ASL   B
	ASL   B     A1,X0
	SUB   Y1,B
 	MOVE  B1,Y0
 black: 
	MOVE  #<0,X0
	MOVE  X0,Y:(R5)+
	JMP   >gegend
 pixel:	MOVEC LC,A	
	ASL   A
	ASL   A
	ASL   A
	ASL   A
	ASL   A
	ASL   A 
	MOVEC LC,X0
	ADD   X0,A
	ROL   A
	ROL   A
	ROL   A
	ROL   A
	ROL   A
	ROL   A 
	ROL   A
	MOVE  A,Y:(R5)+
 	ENDDO
 gegend: 
	MOVE  X:(R2),A
 	MOVE  Y:(R1),Y0
 	ADD   Y0,A
 	MOVE  A,X:<x1h
 gegendx: 
 	DO    X:<width,>rausdamit
 xmit1:	JCLR  #1,X:<<HSR,xmit1
	MOVEP Y:(R5)+,X:<<HRX
 rausdamit: 
 	JMP   <main_loop

