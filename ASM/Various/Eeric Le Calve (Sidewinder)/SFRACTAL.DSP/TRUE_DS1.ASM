*by le calve eric (sidewinder)
*and christophe planty (tom awauk/typlan)

PBC     equ     $ffe0
HSR     equ     $ffe9
HTX     equ     $ffeb

        org     p:$0
        jmp     start

        org     P:$2000

start   movep   #1,X:PBC           ;CONFIGURATION POUR PORT host

        jclr    #0,X:HSR,start     ;ATTEND QUE LE BIT 0 PASSE A 1
                                   ;SA VE DIRE DSP PRET A RECEVOIR 
        move    X:HTX,X0           ;RECUPER DATA ENVOYE PAR 68030

start2  movep   #1,X:PBC           ;CONFIGURATION POUR PORT host

        jclr    #0,X:HSR,start2    ;ATTEND QUE LE BIT 0 PASSE A 1
                                   ;SA VE DIRE DSP PRET A RECEVOIR 
        move    X:HTX,Y0           ;RECUPER DATA ENVOYE PAR 68030

	MPY	X0,Y0,A		   ;D4=D3*D2
	ASR	A

xmit    jclr    #1,X:HSR,xmit      ;ATTEND QUE LE BIT 1 PASSE A 1
                                   ;SA VE DIRE 68030 PRET A RECEVOIR

        move    A0,X:HTX            ;ENVOIE DONNE VERS 68030
                                   ;LE 68030 RECUPERE LA DONNE 
                                   ;A L'ADRESSE FFFFA204
        jmp     start
        end
