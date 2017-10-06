PBC     equ     $ffe0
HSR     equ     $ffe9
HTX     equ     $ffeb

        org     p:$0
        jmp     start

        org     P:$2000

start	movep   #1,X:PBC	; XC
	jclr    #0,X:HSR,start
	move    X:HTX,X0
	move	X0,x:$0

start3	movep   #1,X:PBC	; YC
	jclr    #0,X:HSR,start3
	move    X:HTX,X0
	move	X0,x:$1



strt
	movep   #1,X:PBC	;CONFIGURATION POUR PORT host

	jclr    #0,X:HSR,strt	;ATTEND QUE LE BIT 0 PASSE A 1
				;SA VE DIRE DSP PRET A RECEVOIR 
	move    X:HTX,X0	;RECUPER DATA ENVOYE PAR 68030

start2	movep   #1,X:PBC	;CONFIGURATION POUR PORT host

	jclr    #0,X:HSR,start2    ;ATTEND QUE LE BIT 0 PASSE A 1
                                   ;SA VE DIRE DSP PRET A RECEVOIR 
	move    X:HTX,Y0           ;RECUPER DATA ENVOYE PAR 68030






	MPY	X0,Y0,A		;d4=old2*old3

	REP	#$9
	ASR	A

	
	MOVE	A0,X:$4		;stocke d4


	clr	A
	MPY	X0,X0,A		;D2=D2*D2
	ASR	A

	MPY	Y0,Y0,B		;d3=d3*d3
	ASR	B

	MOVE	A0,X:$2		;D2
	MOVE	B0,X:$6		;D3


	MOVE	X:$2,X0

	MOVE	X:$6,A1
	ADD	X0,A	; add d2,d5
	MOVE	A1,X:$5


	MOVE	X:$6,B1
	SUB	X0,B	; sub d2,d3
	REP	#$9
	ASR	B
	move	X:$0,X0	; xc
	add	X0,B
	move	B1,X:$3 
	

;;

	
xmit	jclr    #1,X:HSR,xmit      ;ATTEND QUE LE BIT 1 PASSE A 1
                                   ;SA VE DIRE 68030 PRET A RECEVOIR

	MOVE	X:$3,B0
        move    B0,X:HTX	; ENVOIE DONNE VERS 68030
                                   ;LE 68030 RECUPERE LA DONNE 
                                   ;A L'ADRESSE FFFFA204

xmit2	jclr    #1,X:HSR,xmit2
	MOVE	X:$4,B0
	move	B0,X:HTX	;

xmit3    jclr    #1,X:HSR,xmit3

	move	X:$5,B0
	MOVE	B0,X:HTX	;

        jmp     start
        end
