	; (c) Gen Wax DeadHeart
	; 13-IX-93
	; rotation d'un vecteur V 1.00008
	; optimisation du calcul de l'offset (c) Gen [5 Heures]
	; version > 2700 pts avec couleurs
	; max = 2900 en VGA (60 Hz)

x_max_p	equ	320
y_max_p	equ 	200
;nb_bits_per_pix equ	4

nb_points	equ	2500
rayon	equ	100

	include "ioequ.asm"

	org	p:$0
	jmp	start

	org	P:$200

start:	AND	#$F3,MR		; bits 2 & 3 : no scale
	AND	#$BF,CCR		; no limit

	movep	#1,X:PBC		; configure for host port

; On calcule quelques constantes li‚es au nombre de couleurs affichables
host4:	jclr	#0,X:HSR,host4
	movep	X:HTX,A
	move	A1,Y:nb_plan
	move	#>4,X0
	move	#>2,X1
	cmp	X0,A
	jeq	couleurs_16
	move	#>8,X0
	move	#>3,X1
;	cmp	X0,A
;	jeq	pas_16_couleurs
couleurs_16:
	move	X1,Y:nb_plan_2

	move	#>x_max_p,X1
	mpy	X0,X1,A
	rep	#4
	asr	A
	move	A0,Y:nb_oc_li

; On se fait une petite table d'offset et de motif
; pour x_pixel -> offset + motif pixel
; Non optimis‚
	move	#$ffff,M0
	move	#16-1,M1
	move	#$ffff,M2
	move	#tab_off,R0
	move	#table,R1
	move	#tab_off+x_max_p,R2
	clr A
	move	Y:nb_plan,A
	asl	A
	move	A1,X0		; 4 plans de 2 octets en 16 couleurs
	clr	A
	do	#x_max_p/16,all_mapp
	do	#16,one_mapp
	move	A,X:(R0)+		; offset
	move	Y:(R1)+,X1		; motif du pixel pour un plan
	move	X1,X:(R2)+
one_mapp:
	add	X0,A
all_mapp:

; On se fait une autre table pour la couleur en fonction du z
	move	#$ffff,M0
	move	#tab_coul,R0
	move	#>2,X0		; distance de plan … plan (2 octets)
; on divise le diametre en 4 (4 plans)
	move	Y:nb_plan,Y0
	move	Y:nb_plan_2,Y1
	move	#>rayon*2,A1
	rep	Y1
	asr	A
	move	A1,Y1
	clr	A
	do	Y0,all_coul
	do	Y1,one_coul
	move	A,X:(R0)+
one_coul:
	add	X0,A
all_coul:

; On re‡oit en premier tous les points
	move	#vector,R0
	move	#>nb_points*3,X0
	do	X0,receive_vector
host2:	jclr	#0,X:HSR,host2
	movep	X:HTX,Y:(R0)+
receive_vector:

redo:
; On re‡oit les valeurs des cosinus et sinus pour les 3 angles … chaque tour
	move	#$ffff,M0
	move	#val_cos,R0
	do	#6,receive_cosi
host1:	jclr	#0,X:HSR,host1	; wait for data from host
	movep	X:HTX,Y:(R0)+
receive_cosi:

	jsr	make_matrice
	jsr	frac2int
	jsr	rotationne
	jsr	calc_offset

	move	#$ffff,M0
	move	#rotated,R0
	move	#>nb_points*2,X0

	do	X0,send_result
host3:	jclr	#1,X:HSR,host3
	movep	X:(R0)+,X:HTX
send_result:
	jmp	redo

; Construction de la matrice de rotation (3 angles) … partir des valeurs
; des cosinus et sinus envoy‚s par le programme 68030.
; Non optimis‚.

make_matrice:

; c(b)*c(g)
	move Y:val_cos+2,X0	; c(b)
	move Y:val_cos+4,Y0	; c(g)
	mpyr X0,Y0,A
	move A1,X:matrix
; -c(b)*s(g)
	move Y:val_cos+2,X0	; c(b)
	move Y:val_cos+5,Y1	; s(g)
	mpyr -X0,Y1,A
	move A1,X:matrix+1
; s(b)
	move Y:val_cos+3,X0	; s(b)
	move X0,X:matrix+2

; c(a)*s(g)+s(a)*s(b)*c(g)
	move Y:val_cos+1,Y1	; s(a)
	move Y:val_cos+3,X1	; s(b)
	move Y:val_cos+4,Y0	; c(g)
	mpyr Y1,X1,A
	move A1,X0
	mpy X0,Y0,A
	move Y:val_cos,Y0	; c(a)
	move Y:val_cos+5,Y1	; s(g)
	macr Y0,Y1,A
	move A1,X:matrix+3

; c(a)*c(g)-s(a)*s(b)*s(g)
	move Y:val_cos+1,Y1	; s(a)
	move Y:val_cos+3,X1	; s(b)
	move Y:val_cos+5,Y0	; s(g)
	mpyr Y1,X1,A
	move A1,X0
	mpy -X0,Y0,A
	move Y:val_cos,Y0	; c(a)
	move Y:val_cos+4,Y1	; c(g)
	macr Y0,Y1,A
	move A1,X:matrix+4

; -s(a)*c(b)
	move Y:val_cos+1,Y1	; s(a)
	move Y:val_cos+2,X1	; c(b)
	mpyr -Y1,X1,A
	move A1,X:matrix+5

; s(a)*s(g)-c(a)*s(b)*c(g)
	move Y:val_cos,Y0	; c(a)
	move Y:val_cos+3,X0	; s(b)
	move Y:val_cos+4,X1	; c(g)
	mpyr Y0,X0,A
	move A1,Y0
	mpy -X1,Y0,A
	move Y:val_cos+1,Y1	; s(a)
	move Y:val_cos+5,X1	; s(g)
	macr Y1,X1,A
	move A1,X:matrix+6

; s(a)*c(g)+c(a)*s(b)*s(g)
	move Y:val_cos,Y0	; c(a)
	move Y:val_cos+3,X0	; s(b)
	move Y:val_cos+5,X1	; s(g)
	mpyr X0,X1,A
	move A1,X0
	mpy X0,Y0,A
	move Y:val_cos+1,Y1	; s(a)
	move Y:val_cos+4,X1	; c(g)
	macr Y1,X1,A
	move A1,X:matrix+7

; c(a)*c(b)
	move Y:val_cos,Y0	; c(a)
	move Y:val_cos+2,X0	; c(b)
	mpyr X0,Y0,A
	move A1,X:matrix+8
	rts

; Multiplication matrice * vecteur
; Optimis‚ 1 fois
rotationne:	move	#matrix,R0
	move	#9-1,M0	; donc adresse sur un multiple de 16

	move	#vector,R4
	move	#$ffff,M4
	move	#-2,N4
	move	#rotated,R5
	move	#$ffff,M5

	move	X:(R0)+,Y0	; matrice
	move	Y:(R4)+,X0	; vecteur

	do	#nb_points,all_vectors

	mpy	X0,Y0,A	X:(R0)+,X0	Y:(R4)+,Y0
	mac	X0,Y0,A	X:(R0)+,X0	Y:(R4)+N4,Y0
	macr	X0,Y0,A	X:(R0)+,X0	Y:(R4)+,Y0

	clr	A	A1,X:(R5)+
	mac	X0,Y0,A	X:(R0)+,X0	Y:(R4)+,Y0
	mac	X0,Y0,A	X:(R0)+,X0	Y:(R4)+N4,Y0
	macr	X0,Y0,A	X:(R0)+,X0	Y:(R4)+,Y0

	clr	A	A1,X:(R5)+
	mac	X0,Y0,A	X:(R0)+,X0	Y:(R4)+,Y0
	mac	X0,Y0,A	X:(R0)+,X0	Y:(R4)+,Y0
	macr	X0,Y0,A	X:(R0)+,X0	Y:(R4)+,Y0

	move	A1,X:(R5)+
all_vectors:
	rts

frac2int:	move	#matrix,R5
	move	#$ffff,M5

	do	#9,all_frac2int
	move	X:(R5),A
	rep #8
	asr A
	move	A1,X:(R5)+
all_frac2int:
	rts

calc_offset:
	move	#tab_off+x_max_p+x_max_p/2,R0	; table des motifs (centr‚)
	move	#tab_off+x_max_p/2,R1		; table des offsets (centr‚)
	move	#y_c,R2		; table des constantes
	move	#tab_coul+rayon,R3	; table des couleurs en f. de z (centr‚)

	move	#rotated,R5		; lecture vecteur
	move	#rotated,R6		; ecriture offset, motif

	move	#$ffff,M0
	move	#$ffff,M1
	move	#2-1,M2
	move	#$ffff,M3

	move	#$ffff,M5
	move	#$ffff,M6

	move	X:(R5)+,N1		; N1=x
	do	#nb_points,calc_all_off

	move	X:(R5)+,B	Y:(R2)+,Y0	; B=y, Y0=y_max_p/2
	add	Y0,B	X:(R5)+,N3	; B=y+y_max_p/2 N3=z

	move	B,X0	Y:(R2)+,Y0	; X0=y+y_max_p/2, Y0=nb_oc_li (160 en 16 coleurs)

	mpy	X0,Y0,B	X:(R1+N1),A	; B=offset y, A=offset x
	move	B0,B1		; B1=(y+y_max_p/2)*nb_oc_li*2 (*2 car B0 dans B1)

	addr	A,B	N1,N0	; B=offset plan, N0=offset motif
;********
	move	X:(R3+N3),A		; A=offset couleur
	add	A,B	X:(R5)+,N1	; B=offset ‚cran, N1=x suivant
;********
	move	X:(R0+N0),X0	; X0=motif
	move	B1,X:(R6)+		; on stocke l'offset relatif
	move	X0,X:(R6)+		; motif du pixel

calc_all_off:
	nop
	nop
	rts

start_vector	equ	$1c00

	org	Y:start_vector-$100
val_cos:	bsc	6,0


	org	Y:start_vector-$100+$20
y_c	dc	y_max_p/2
nb_oc_li	dc	x_max_p*4/8
nb_plan	dc	4
nb_plan_2	dc	2

	org	Y:((start_vector-$100+$20+4)/16)*16+16
table:	dc	$008000
	dc	$004000
	dc	$002000
	dc	$001000
	dc	$000800
	dc	$000400
	dc	$000200
	dc	$000100
	dc	$000080
	dc	$000040
	dc	$000020
	dc	$000010
	dc	$000008
	dc	$000004
	dc	$000002
	dc	$000001

	org	Y:start_vector
vector:	bsc	3*nb_points,0

	org	X:$200
matrix:	bsc	9,0	; adresse multiple d'au moins 9

tab_off:	bsc	x_max_p*2,0
tab_coul:	bsc	rayon*2,0

rotated:	bsc	3*nb_points,0

save_x	bsc	1,0
	end start
