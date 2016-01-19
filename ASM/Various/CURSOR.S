e	equ	$1b
u	equ	'A'
d	equ	'B'
r	equ	'C'
l	equ	'D'
c	equ	'E'
h	equ	'H'
sd	equ	'I'
cd	equ	'J'
cr	equ	'K'
i	equ	'L'
dl	equ	'M'
xy	equ	'Y'
ccol	equ	'b'
bcol	equ	'c'
cto	equ	'd'
show	equ	'e'
hide	equ	'f'
savecur	equ	'j'
setcur	equ	'k'
cline	equ	'l'
cl	equ	'o'
revon	equ	'p'
revoff	equ	'q'
flowon	equ	'v'
flowoff	equ	'w'
end	equ	$ff

print	move.l	mytextto,a0
	move.b	(a0),d0
	cmp.b	#$ff,d0
	beq.s	exit
	cmp.b	#$fe,d0
	bne.s	okay
	move.l	#$1,slowd	
	addq.l	#1,a0
	move.l	a0,mytextto

	move.b	(a0),d0
okay	move.w	d0,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	move.l	mytextto,a0
	addq	#1,a0
	move.l	a0,mytextto
	move.l	slowd,d0
.1	subq.l	#1,d0
	bne.s	.1
	bra.s	print
slowd	dc.l	$2000
exit	move.l	#$3000,d0
.1	subq.l	#1,d0
	bne.s	.1
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	clr.w	-(sp)
	trap	#1	
oldsp	dc.l	0
char	ds.w	1
mytextto	dc.l	mytext

mytext	dc.b	e,show,e,c,e,bcol,2
	dc.b	' Fast typing by J.F.B. Yep!.. . . . .           '	dc.b	e,'p'
	dc.b	'SHIT CAPSLOCKS STUCK     '
	dc.b	e,l,e,l,e,l,e,l,e,l,e,l,e,l,e,l,e,l,e,l
	dc.b	e,l,e,l,e,l,e,l,e,l,e,l,e,l,e,l,e,l,e,l
	dc.b	e,l,e,l,e,l,e,l,e,l,e,bcol,2
	dc.b	' ERROR now rectified..  '
	dc.b	e,bcol,0,e,d,e,d
	dc.b	e,r,e,r,e,r,e,r,e,r,e,r,e,r,e,r,e,r
	dc.b	' Now continuing in error free mode  ..  '
	dc.b	e,xy,38,35
	dc.b	'Mega slaggings go to STEW..  '
	dc.b	e,xy,38,35,'Only joking  !!!!!!!!!!!   '
	dc.b	e,xy,40,35,'Wonder how the  '
	dc.b	e,ccol,1,' MEGA CREW ',e,ccol,3,' are doing ???'
	dc.b	e,xy,42,35,'Rasterman and......  '
	dc.b	e,xy,43,52,'  The Kidknapper......  '
	dc.b	e,d,e,d,e,d,e,d,e,d,e,d,e,d
	dc.b	e,l,e,l,e,l,e,l,e,l,e,l,e,l,e,l,e,l,e,l
	dc.b	e,l,e,l,e,l,e,l,e,l,e,l,e,l,e,l,e,l,e,l
	dc.b	e,l,e,l,e,l,e,l,e,l,e,l,e,l,e,l,e,l,e,l
	dc.b	e,bcol,1,'           '	
	dc.b	e,l,e,l,e,l,e,l,e,l,e,l,e,d,'  ',e,d,e,l,e,l,'  '
	dc.b	e,d,e,l,e,l,'  ',e,d,e,l,e,l,'  ',e,d,e,l,e,l,'  '
	dc.b	e,d,e,l,e,l,'  ',e,l,e,l,e,l,e,l,e,l,e,l,'    ',e,l,e,l,e,l
	dc.b	e,l,e,u,'  '
	dc.b	e,bcol,0	
	dc.b	e,hide	
	dc.b	end	
*********************************************************
*  e , u , d , r , l , c , h
*  sd , cd , cr , i	
*  dl , xy , ccol , bcol , cto	
*  show , hide , savecur , setcur , cline	
*  cl , revon , revoff , flowon , flowoff
*  end	
*********************************************************
