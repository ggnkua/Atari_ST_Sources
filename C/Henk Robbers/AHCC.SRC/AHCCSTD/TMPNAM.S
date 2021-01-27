*	Created by TT-Digger v7.1
*	Wed Sep 19 10:56:06 2007

*	TT-Digger v7

	ds.b	11960
.ENDMOD
.MODULE L11960

	move	51(a1,d3*2),d0		      ; 30061 3233	     0123
	move	55(a5,d3*8),d2		      ; 32065 3637	     4567
	move	$41424344.l,d4		      ; 34071 41424344	     89ABCD
	dc	17734			      ; 42506 		     EF
tmpnam:
	pea	(a3)			      ; 44123 		     HS
	pea	(a2)			      ; 44122 		     HR
	movea.l	a0,a3			      ; 23110 		     &H
	lea 	T20008.l,a2		      ; 42771 00004E28	     E   N(
L11988:
	lea 	4(a2),a0		      ; 40752 0004	     A   
	moveq	#3,d2			      ; 72003 		     t 
	move	T20006.l,d0		      ; 30071 00004E26	     09  N&
L12000:
	move.b	d0,d1			      ; 11000 		       
	and.b	#15,d1			      ; C1074 000F	      <  
	move.b	L11960(pc,d1),(a0)+	      ; 10373 10D0	         
	lsr	#4,d0			      ; E4110 		      H
	dbf	d2,L12000		      ; 50712 FFF2	     Q   
	addq	#1,T20006.l		      ; 51171 00004E26	     Ry  N&
	beq.s	L12060			      ; 63444 		     g$
	clr.l	-(a7)			      ; 41247 		     B 
	pea	(a2)			      ; 44122 		     HR
	move	#67,-(a7)	; Fattrib     ; 37474 0043	     ?< C
	trap	#1		; Gemdos      ; 47101 		     NA
	lea 	10(a7),a7		      ; 47757 000A	     O   
	tst	d0			      ; 45100 		     J@
	bge.s	L11988			      ; 66312 		     l 
	movea.l	a2,a0			      ; 20112 		      J
	move.l	a3,d0			      ; 20013 		       
	beq.s	L12054			      ; 63406 		     g 
	movea.l	a3,a0			      ; 20113 		      K
L12050:
	move.b	(a2)+,(a3)+		      ; 13332 		       
	bne.s	L12050			      ; 63374 		     f 
L12054:
	movea.l	(a7)+,a2		      ; 22137 		     $_
	movea.l	(a7)+,a3		      ; 23137 		     &_
	rts				      ; 47165 		     Nu

L12060:
	suba.l	a0,a0			      ; 90710 		       
	bra.s	L12054			      ; 60366 		     ` 


