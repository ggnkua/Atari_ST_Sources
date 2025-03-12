
;---------- Peripherie --------------------

PBC			equ $ffe0
HCR			equ $ffe8
HSR			equ $ffe9
HRX			equ $ffeb
HTX			equ $ffeb

PCC			equ $ffe1
PCDDR		equ $ffe3
PCD			equ $ffe5
CRA			equ $ffec
CRB			equ $ffed
SSISR		equ $ffee
TX			equ $ffef
RX			equ $ffef
BCR			equ $fffe
IPR			equ $ffff


;load P56-Files, Ende mit -1 ( $ffffff )

			org p:0

			move	#start,x0   		;Start des zu verschiebenden Prg
			move	x0,r2               ;in r2 merken
			move	#ende,a             ;Ende des zu v. Prg
			sub		x0,a				;Laenge
			move	#$7c00+start,r0  	;Ziel
			do		a,copy
			movem	p:(r2)+,x0        	;Quelle
			movem	x0,p:(r0)+          ;-> Ziel
copy		jmp		$7c00+start        	;verschobenes Prg anspringen

;Dieses Programm steht ab $7c00+start
			
start		movep	#1,x:PBC			;Host an

            move	#0,r0
            clr		a
            rep		#$40
            move	a,p:(r0)+			;Execptions loeschen

read		jsr		read_host+$7c00		;Address Space
			move	#-1,a
			cmp		x0,a				;= -1 ?
			jeq		0					;start DSP - Programm
			move	x0,x1
			jsr		read_host+$7c00		;Load address
			move	x0,r0
			jsr		read_host+$7c00		;Block-Size

			do		x0,read_data+$7c00
			jsr		read_host+$7c00		;Daten
			clr		a
			cmp		x1,a	#>1,a		;P-Memory ?
			jne		no_p+$7c00			;nein
			move	x0,p:(r0)+
			jmp		do_end+$7c00

no_p		cmp		x1,a	#>2,a		;X:Memory ?
			jne		no_x+$7c00			;nein
			move	x0,x:(r0)+			;write to X:Memory
			jmp		do_end+$7c00
			
no_x		cmp		x1,a				;Y:Memory ?
			jne		do_end+$7c00		;nein
			move	x0,y:(r0)+			;write to Y:Memory
do_end		nop
read_data
			nop
			jmp		read+$7c00

read_host	jclr	#0,X:HSR,read_host+$7c00
			movep	x:HRX,x0
			rts
ende
