; Calcul d'une fractale de Mandelbrot.
; Attend 4 parametres du port HOST :
;	- xinc : partie réelle de l'incrément horizontal
;	- yinc : partie imaginaire de l'incrément horizontal
;	- xcnt : partie réelle du point central
;	- ycnt : partie imaginaire du point central

; Renvoie xres*yres valeurs.

; algo de Mandelbrot :
; z_0 = 0
; z_(n+1) = z_ný + c

; si z := a + ib ; zý = (aý-bý) + i(2ab)
debug	equ	0
nit	equ	61


	nolist
	include	'ioequ.asm'
	list

host_r	MACRO	dest
	jclr	#M_HRDF,x:M_HSR,*	; Attente de l'autorisation de lecture
	movep	x:M_HRX,dest		; Lecture de la donnee
	ENDM

host_w	MACRO	srce
	if	!debug
	jclr	#M_HTDE,x:M_HSR,*	; Attend la possibilite de transmission
	endif
	movep	srce,x:M_HTX
	ENDM

i_nit	equ	51
i_xres	equ	160
i_yres	equ	100
i_xcnt	equ	$08<<18		; -0.5 / 2
i_ycnt	equ	$00<<18		; +0.0 / 2
i_xinc	equ	($30<<18)/i_xres	; 3.0 / xres
i_yinc	equ	$0<<18		; 0.0


	ORG	p:$0
	jmp	<start

	ORG	p:$60

start
; init des registres d'adresse
	move	#<xinc,r1	; adr de l'incr‚ment x vers le point suivant sur la mˆme ligne
	move	#<xnext,r2	; adr du 1er point sur la ligne suivante
	move	#<yorg,r4	; svg du yc pour la pr‚cision
	move	#<yinc,r5
	move	#<ynext,r6

	andi	#%11110011,mr	; Vire le scaling mode
	ori	#%00000100,mr	; Scaling down

	host_r	a		; Horizontal resolution
	host_r	y:yres
	move	a1,x:<xres
	move	a,x:<xloops

main_loop
	andi	#%11110011,mr	; Vire le scaling mode
	ori	#%00000100,mr	; Scaling down

; R‚cup‚ration des donn‚es en entr‚e tous les x/y en format / 2
	IF	debug

	move	#i_xorg/2,x1
	move	#i_yorg/2,y1
	move	#i_xinc,x0
	move	x0,x:(r1)
	move	#i_yinc,y0
	move	y0,y:(r5)

	ELSE

	move	#<buffer,r3
	host_r	x:(r3)+
	host_r	x:(r3)+
	host_r	x:(r3)+
	host_r	x:(r3)+

	move	#<buffer,r3

	move	x:<xres,x0
	move	x:(r3)+,a		; inc x / 2
	move	a,x1	y:yres,y0	; inc x / 4, xres
	mpy	x0,x1,a	x1,x:(r1)	; inc x * xrez / 4, inc x / 4
	asr	a			; inc x * xrez/2 / 4
	move	a0,x0

	move	x:(r3)+,a
	move	a,y1		; inc y / 4
	mpy	y0,x1,a	y1,y:(r5)	; inc x * yrez / 4, inc y / 4
	asr	a
	move	a0,y0

	move	x:(r3)+,a
	sub	x0,a
	move	a,x1	; xc au format / 4 (scaling down)

	move	x:(r3)+,a
	add	y0,a
	move	a,y1	; yc au format / 4 (scaling down)

	ENDIF

	andi	#%11110011,mr	; Vire le scaling mode
	ori	#%00001000,mr	; Scaling up

	move	x1,x:(r2)	y1,y:(r6)

	do	y:<yres,boucle_y
; Nouvelles coordonn‚es (tout au format / 4)
	move	x:(r2),x1	y:(r6),y1

; Calcul du prochain point c … la ligne suivante.
	tfr	x1,a	y:(r5),y0	; xc/4, inc y/4
	add	y0,a	x:(r1),x0	y:(r6),b	; xc ult‚rieur, inc x / 4, yc / 4
	sub	x0,b	a1,x:(r2)	; yc ult‚rieur
	move	b1,y:(r6)

	move	#<buffer,r3
	do	x:<xloops,boucle_x
	do	#<2,pixel_loop

;	move	y1,y:(r4)	x0,x:(r3)	; Sauvegarde de yc/4, previous pixel
;	tfr	x1,b	y1,a	; xc/4, yc/4
;	asr	a	b,x0	; yc/8, xn/2
;	move	y1,b		; yn/4
;	tfr	x1,a	a1,y1	; xc/4, yc/8

	move	y1,y:(r4)	x0,x:(r3)	; Sauvegarde de yc/4, previous pixel
	clr	b	y1,a	; xc/4, yc/4
	asr	a	b,x0	; yc/8, xn/2
	tfr	x1,a	a1,y1	; xc/4, yc/8

	andi	#%10111111,ccr	; Efface le bit de limiting

	do	#nit,boucle_it
; L'it‚ration proprement dite :
; x1, y1 = xc/4, yc/8
; x0 = xn/2
; a = xc/4 aussi
; b = yn/4
	mac	x0,x0,a		b,y0	; (xný+xc) / 4		# yn / 2
	jls	<stop			; Limiting ? (=> divergence)
	macr	-y0,y0,a	y1,b	; (xný-yný+xc) / 4	# yc / 8
	macr	x0,y0,b		a,x0	; (xn.yn+yc/2) / 4	# x(n+1) / 2
	asl	b		x1,a	; y(n+1) / 4		# xc / 4
boucle_it
; Pas de divergence
	clr	a
	jmp	<xout
stop	movec	lc,a	; colour = loop counter
	enddo
xout

; Nouvelles coordonn‚es de c
	tfr	x1,b	x:(r1),x0	y:(r4),y1	; xc, inc x, yc
	add	x0,b	y:(r5),y0	; nouveau xc, inc y
	tfr	y1,b	b1,x1		; yc, xc
	add	y0,b	a1,x0		; yc, current pixel
	move	b1,y1			; yc
pixel_loop
	move	x:(r3),a0
	move	#>$20,y0
	mac	x0,y0,a
	move	a0,x:(r3)+

boucle_x
	move	#<buffer,r3
	do	x:<xloops,boucle_x2
	host_w	x:(r3)+
boucle_x2
	nop
boucle_y
	jmp	<main_loop


	ORG	x:$0
xres	ds	1	; Horizontal resolution
xloops	ds	1	; X res / 2
temppix	ds	1	; temporary 1-pixel value
xinc	ds	1	; incrément horizontal de c
xnext	ds	1	; coordonnée x du point de départ sur la prochaine ligne
buffer	ds	512	; buffer de transfert DSP<=>CPU

	ORG	y:$0
yres	ds	1	; Vertical resolution
yorg	ds	1	; coordonnée du point de départ (c) de l'algo
yinc	ds	1	; incrément vertical de c
ynext	ds	1	; coordonnée y du point de départ sur la prochaine ligne

