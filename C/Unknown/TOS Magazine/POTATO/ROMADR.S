	.globl	rom_adr				; Aufruf
	.globl  romsel				; aktuelle adresse
	
rom_adr:	lea     $fb0000,A0              ; ROM-Basis
                tst.b   (A0)                    ; ROM Auswahlsequenz:
                tst.b   $561c(A0)
                tst.b   $561c(A0)
                tst.b   $560c(A0)
                tst.b   $561c(A0)
                tst.b   $1414(A0)
                tst.b   $4600(A0)
                tst.b   $1414(A0)
		move	4(a7),D0
		move	d0,romsel
		lsl	#1,d0
		tst.b	0(a0,d0)		; Auswahl
		rts
		
romsel:		ds.w	1		