
*** Interrogation de la SOURIS ***

*** DROITE=COORD, 2=QUITTER ***


	SECTION TEXT

TOUCHE	MACRO	
	move	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM
		
CCONOUT    MACRO     $\1
           move.w    \1,-(sp)   ;\1=Caractäre Ö afficher
           move.w    #2,-(sp)
           trap      #1
           addq.l    #4,sp
	ENDM

	move.l	#0,-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	move.l	d0,SSP
	
	cmpi	#$0e96,$fc001e	;TOS blitter ?
	bne	NOBLIT
	move.l	#$2740,KDB
	jmp	PRINCIPAL
	
NOBLIT	move.l	#$26e0,KDB

PRINCIPAL	
	move.l	KDB,a1
	move.b	7(a1),d0		;Gauche=%01
		   		;Droite=%10  ,2=%11
	
	cmpi.b	#%11,d0		;2 = quitter
	beq	FIN
				
	btst	#1,d0		;diff de %...0.  = Bouton DROIT
	beq	PRINCIPAL				

	CCONOUT   #27
           CCONOUT   #'E'
          
	move	(a1),d0
	jsr	BINAIRE
	
	move	2(a1),d0
	jsr	BINAIRE
	
	jmp	PRINCIPAL
	
	
FIN	move.l	SSP,-(sp)	
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr	-(sp)
	trap	#1

         
BINAIRE   movem.l   d0-d7/a0-a6,-(sp)
          move      d0,d1
          move      #31,d3

LOOK      move      #'0',d0
          lsl.l     #1,d1

          bcc       ZERO
          move      #'1',d0
ZERO      CCONOUT   d0
          dbf       d3,LOOK
          CCONOUT   #10
          CCONOUT   #13
          movem.l   (sp)+,d0-d7/a0-a6
          rts

	
	SECTION	BSS
	
KDB	ds.l	1
SSP	ds.l	1

	END
