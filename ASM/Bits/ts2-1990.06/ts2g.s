* HERMANN SAMSO, finales de junio
* Intro ts numero 2.
* Utiliza:-letras1.ts
*	  -logo1.ts
*	  -music6.s y music6.bin
* Hecho a partir de:hblvbl2.s y h_scrl_3.s
 	move.l	a7,sa7
 	
	move.l	a7,a5
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$500,d0
	
	move.l	d0,d1
	add.l	a5,d1
	and.l	#-2,d1
	move.l	d1,a7
	move.l	a5,areasav
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp
	
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
		
	move.l	d0,savesp

* Salva physbase
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,pbase
	
* Salva logical base
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,lbase
	
* Setscreen
	move.w	#0,-(sp)
	move.l	#$78000,-(sp)
	move.l	#$78000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	dc.w	$a00a	;quita cursor raton
	
	move.l	#$78000+$37a0,punpan
	
* Ocupa espacio para los trolls
	
	move.l	#90000,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,trolls
	move.l	d0,ptrolls
	add.l	#5320,ptrolls

* Copia el troll 15 veces...	
	lea	spri,a0
	movea.l	d0,a1
	move.w	#95-1,d1
cop1a	move.w	#12-1,d0
cop1b	move.l	(a0)+,(a1)+
	dbra	d0,cop1b
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	dbra	d1,cop1a
	
	move.w	#1,d0
cop2	movea.l	trolls,a0
	movea.l	a0,a1
	move.w	d0,d1
	mulu.w	#5320,d1
	adda.l	d1,a1
	move.w	#1330-1,d1
cop3	move.l	(a0)+,(a1)+
	dbra	d1,cop3
	add.w	#1,d0	
	cmp	#16,d0
	beq	no3
	bra	cop2

 * ... y las rota segun la tabla 'rot'
no3	move.w	#1,d1
	lea	rot,a1
bclc	add.w	#1,d1
	cmp.w	#18,d1
	beq	no4
	movea.l	trolls,a0
	move.w	d1,d0
	mulu.w	#5320,d0
	adda.l	d0,a0
	suba.l	#2,a0
	clr.l	d4
	move.b	(a1)+,d4
	move.w	#95-1,d3
bclf	move.w	#24-1,d0
bcla	move.w	-8(a0),d2
	swap	d2
	move.w	(a0),d2
	ror.l	d4,d2
	move.w	d2,(a0)
	suba.l	#2,a0
	dbra	d0,bcla
	
	move.w	#4-1,d0
bclb	move.w	(a0),d2
	lsr.w	d4,d2
	move.w	d2,(a0)
	suba.l	#2,a0
	dbra	d0,bclb
	
	dbra	d3,bclf
	bra	bclc
no4	clr.w	d1
	
* rut pa comprobar si los trolls estan bien rotados
;bcle	movea.l	trolls,a1
;	move.w	d1,d2
;	mulu.w	#5320,d2
;	adda.l	d2,a1
;	movea.l	#$fc1a0,a0
;	move.w	#95-1,d0	
;bcld	movem.l	(a1)+,d2-d7/a3
;	adda.l	#28,a0
;	movem.l	d2-d7/a3,-(a0)
;	movem.l	(a1)+,d2-d7/a3
;	adda.l	#56,a0
;	movem.l	d2-d7/a3,-(a0)
;	adda.l	#160-28,a0
;key2	tst.b	$fffc02	;quita
;	beq	key2	;q
;	dbra	d0,bcld
;	
;	add.b	#1,d1
;	cmp.b	#16,d1
;	bne	bcle

	bsr	clspan	;borra pantalla	
			
* Salva paleta
	lea	$fff8240,a0
	lea	pal,a1 
	rept	8
	move.l	(a0)+,(a1)+
	endr

* Pone new palette
	move.l	#newpal,-(sp)
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	
* Runea una vez dirpix para el start of vbl
* y cambia el jmp a jaja por el de key
	bra	dirpix
jaja	move.l	#key,nosta+2

* Pone hbls y vbls
	
	move.w	sr,ssr
;	move.w	#$2400,sr
	jsr	wvbl
	move.l	$70,svbl+2
	move.l	#vbl,$70
	move.l	$118,skm+2
	move.l	#km,$118
	move.l	$120,shbl
	move.l	#hbl,$120
	move.b	$fffffa09,sa09
	move.b	$fffffa07,sa07
	move.b	$fffffa13,sa13
	move.b	$fffffa21,sa21
	move.b	$fffffa1b,sa1b
	and.b	#$df,$fffffa09
	and.b	#$fe,$fffffa07
	or.b	#1,$fffffa07
	or.b	#1,$fffffa13
	move.w	#$25,-(sp)
	trap	#13
	addq.l	#2,sp
	move.b	#0,$fffffa1b
	move.b	#8,$fffffa1b
	move.b	#2,$fffffa21
	
	bsr	muzz

* rut infinita que comprueba teclas
key1	clr.b	d0
	move.b	$fffc02,d0
key	btst	#0,flag
	bne	dirpix
	cmp.b	$fffc02,d0
	beq	key
	move.b	$fffc02,d0
	cmp.b	#2,d0
	beq	velo1
	cmp.b	#3,d0 
	beq	velo2
	cmp.b	#4,d0
	beq	velo3
	cmp.b	#5,d0
	beq	chgdwf1
	cmp.b	#6,d0
	beq	chgdwf2
	cmp.b	#7,d0
	beq	chgdwf3
	cmp.b	#$14,d0
	beq	end
	cmp.b	#$ff,d0
	beq	end
	cmp.b	#$39,d0
	beq	end
;	cmp.b	#5,d0
;	beq	velo4
	bra	key1
* cambia speed in next vbl
velo1	move.b	#1,velos
	bra	key1
velo2	move.b	#2,velos
	bra	key1
velo3	move.b	#4,velos
	bra	key1
;velo4	move.b	#8,velos
;	bra	key1
* cambia senos dwarfes en next vbl
chgdwf1	bset	#0,flgsndw	
	bra	key1
chgdwf2	bset	#1,flgsndw
	bra	key1
chgdwf3	bset	#2,flgsndw
	bra	key
		
* Pues KM (Que conio sera?)
km	move.w	#$2500,sr
skm	jmp	$0

* Rut de HBL
hbl	move.w	coltbl1,$ff8242
hbl2	move.w	coltbl2,$ff8240
	add.w	#2,hbl+4
	add.w	#2,hbl2+4
	bclr	#0,$fffffa0f.w
        rte       



* Ruts de VBL	
vbl	lea	coltbl1,a0
	move.l	a0,hbl+2
	lea	coltbl2,a0
	move.l	a0,hbl2+2
	clr.w	$ff8240

	movem.l	d0-d7/a0-a6,-(sp)
* A partir de aqui se encuentra la rutina del troll
sprite	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	moveq.l	#0,d7
	
* borra el rastro del troll
	movea.l	punpan,a0	;borra troll
	move.w	#5-1,d0
clr1	
	rept	19
	adda.w	#28,a0
	movem.l	d1-d7,-(a0)
	adda.w	#56,a0
	movem.l	d1-d7,-(a0)
	adda.w	#160-28,a0	
	endr
	dbra	d0,clr1
* clr rastro dwarfs
	lea	pdwrf,a0
	move.w	#9-1,d0
cllr	move.l	(a0)+,a1
	adda.w	#4,a1
	rept	16
	move.l	d6,(a1)
	adda.l	#160,a1 
	endr
	dbra	d0,cllr
* Cambio de seno de dwarfs?	
	btst	#0,flgsndw
	beq	to
	bra	dwsen1	
to	btst	#1,flgsndw
	beq	too
	bra	dwsen2
too	btst	#2,flgsndw
	beq	tooo
	bra	dwsen3
tooo

*Finalmente copia el troll a pantalla
*y actualiza punpan y ptrolls segun
* a0 y a1, respectivamente
troll	movea.l	sa0,a0
	movea.l	sa1,a1
	move.l	a0,punpan
	move.w	#5-1,d0	
copy2	
	rept	19
	movem.l	(a1)+,d2-d7/a3
	adda.w	#28,a0
	movem.l	d2-d7/a3,-(a0)
	movem.l	(a1)+,d2-d7/a3
	adda.w	#56,a0
	movem.l	d2-d7/a3,-(a0)
	adda.w	#160-28,a0
	endr
	dbra	d0,copy2
	move.l	a1,ptrolls	
	
* calcula dirs dwarfs
dar	lea	lastp,a0
	movea.l	a0,a1
	suba.l	#4,a1
	
	rept	5
	move.l	-(a1),-(a0)
	add.l	#8,(a0)
	endr
	move.l	-(a1),-(a0)
	add.l	#16,(a0)
	
	rept	2
	move.l	-(a1),-(a0)
	add.l	#8,(a0)
	endr
	
	movea.l	psndwf,a0
	move.w	(a0)+,d0
	cmp.w	#$1234,d0
	bne	nono
	movea.l	ppsndwf,a0
	move.w	(a0)+,d0
nono	move.l	a0,psndwf
	muls.w	#160,d0
	btst	#15,d0
	beq	suma
	not.w	d0
	add.w	#1,d0
	sub.w	d0,2(a1)
	bra	clr12
suma	add.w	d0,2(a1)
	
* borra 1er y 2o plano, pa que no se mezclen dwarfs y trolls
clr12
	lea	pdwrf,a0
	moveq.l	#0,d6
	move.w	#9-1,d0
clllr	move.l	(a0)+,a1
	rept	16
	move.l	d6,(a1)
	adda.l	#160,a1 
	endr
	dbra	d0,clllr

* PONE DWARFS
pon	lea	pdwrf,a6
	lea	dwarfs,a0

	move.w	#9-1,d0	
repe	movea.l	(a6)+,a1
	adda.w	#4,a1
	rept	16
	move.l	(a0)+,(a1)
	adda.w	#160,a1
	endr
	dbra	d0,repe

*a partir de aqui va la rut de scroll
scroll	moveq.l	#0,d0
	moveq.l	#0,d4	
	moveq.w	#0,d6
	moveq.w	#0,d5
	move.b	velo,d4	;calcula el numero de veces que hay que repetir
	move.b	velo,d5	;la rutina para que se escrolee una letra(segun cont1). esto depende
	move.b	#16,d6	;del numero de pixs. que se corran de una sola vez
	divu.w	d5,d6
	move.w	#1,d3
	
bcl5	cmp.b	cont1,d6
	bne	no1
	
	move.b	velos,d0
	move.b	d0,velo
	moveq.w	#0,d6
	moveq.w	#0,d5
	move.b	velo,d4	;calcula el numero de veces que hay que repetir
	move.b	velo,d5	;la rutina para que se escrolee una letra(segun cont1). esto depende
	move.b	#16,d6	;del numero de pixs. que se corran de una sola vez
	divu.w	d5,d6
	
	move.b	#0,cont1
	movea.l	ptext,a0
	move.b	(a0)+,d0
	cmp.b	#50,d0
	bne	no2
	lea	text,a0
	move.b	(a0)+,d0
no2	move.l	a0,ptext
	lea	letras,a3
	lea	letra,a2
	mulu.w	#32,d0
	adda.l	d0,a3
	
bcl4	rept	8
	move.l	(a3)+,(a2)+
	endr

no1		
	lea	letra,a2
	movea.l	#$78000+$7300,a0

	move.w	#19-1,d2
bcl2	rept	4
	move.w	8(a0),d0
	swap	d0
	move.w	(a0),d0	
	rol.l	d4,d0
	move.w	d0,(a0)
	adda.w	#160,a0
	
	move.w	8(a0),d0
	swap	d0
	move.w	(a0),d0	
	rol.l	d4,d0
	move.w	d0,(a0)
	adda.w	#160,a0

	move.w	8(a0),d0
	swap	d0
	move.w	(a0),d0	
	rol.l	d4,d0
	move.w	d0,(a0)
	adda.w	#160,a0
	
	move.w	8(a0),d0
	swap	d0
	move.w	(a0),d0
	rol.l	d4,d0
	move.w	d0,(a0)
	adda.w	#160,a0
	endr
	
	suba.w	#2560-8,a0
	 
	dbra	d2,bcl2
		
	move.w	#8-1,d1
bcl3	move.w	(a2),d0
	swap	d0
	move.w	(a0),d0
	rol.l	d4,d0
	move.w	d0,(a0)
	adda.w	#160,a0
	move.w	(a2),d0
	lsl.l	d4,d0
	move.w	d0,(a2)+
	
	move.w	(a2),d0
	swap	d0
	move.w	(a0),d0
	rol.l	d4,d0
	move.w	d0,(a0)
	adda.w	#160,a0
	move.w	(a2),d0
	lsl.l	d4,d0
	move.w	d0,(a2)+	
	dbra	d1,bcl3
	
	add.b	#1,cont1
	dbra	d3,bcl5
	
	
	bset	#0,flag
	movem.l	(sp)+,a0-a6/d0-d7
svbl	jmp	$0
	rte	

wvbl	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	rts

* El Retorno (del Jedi, colega...)			
end	clr.l	$4d6
	jsr	wvbl	
	move.w	ssr,sr
	move.l	skm+2,$118
	move.l	svbl+2,$70
	move.l	shbl,$120
	move.b	sa09,$fffffa09
	move.b	sa07,$fffffa07
	move.b	sa13,$fffffa13
	move.b	sa1b,$fffffa1b
	move.b	sa21,$fffffa21
	jsr	wvbl
	move.l	#$4ce+4,a0
	rept	7
	clr.l	(a0)+
	endr
	jsr	wvbl

	bsr	clspan	;borra	pantalla

* delvuelve lbase y pbase, setscreen
	move.w	#-1,-(sp)
	move.l	pbase,-(sp)
	move.l	lbase,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	
*devuelve paleta
	lea	$fff8240,a0
	lea	pal,a1
	rept	8
	move.l	(a1)+,(a0)+
	endr
	
* Devuelve memoria reservada de los trolls y del programa
	move.l	trolls,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	areasav,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp

* Modo usuario
	move.l	savesp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
			
* Pone cursor del mouse
	dc.w	$a009

* Quita sonido
	MOVE.L	#SOUND1,A1
	MOVE.L	A1,-(SP)
	MOVE.W	#32,-(SP)
	TRAP	#14
	ADD.W	#6,SP

;* EXECute programm
;	pea	env
;	pea	com
;	pea	fil
;	move.w	#0,-(sp)
;	move.w	#$4b,-(sp)
;	trap	#1
;	add.l	#16,sp

;env	dc.w	0
;com	dc.b	0
;fil	dc.b	'a:\simcity.prg',0
;	dc.w	0	
	
* Acaba programa
	clr.w	-(sp)
	trap	#1
	
* Borra pantalla
clspan	lea	$78000,a0
	move.l	#7999,d0
cls	clr.l	(a0)+
	dbra	d0,cls
	rts	
	
	even

sa0	dc.l	0
sa1	dc.l	0
areasav	dc.l	0
savesp	dc.l	0
hndl	dc.w	0
sasize	dc.w	0
pbase	dc.l	0
lbase	dc.l	0
punpan	dc.l	0
pdwrf	dc.l	$7ab48,$7ab48,$7ab48,$7ab48,$7ab48,$7ab48,$7ab48,$7ab48,$7ab48
lastp
ptrolls	dc.l	0
trolls	dc.l	0
letra	ds.l	8	
pal	ds.l	8
sa7	dc.l	0
ssr	dc.l	0
shbl	dc.l	0
newpal	dc.w	$000,$700,$000,$111,$245,$245,$134,$023
	dc.w	$134,$631,$411,$311,$356,$500,$356,$777
ptext	dc.l	text
coltbl1	dc.w	$000,$000,$000,$100,$200,$300,$400,$500,$600,$700
	dc.w	$710,$720,$730,$740,$750,$760,$770,$670,$570,$470
	dc.w	$370,$270,$170,$070,$071,$072,$073,$074,$075,$076
	dc.w	$077,$067,$057,$047,$037,$027,$017,$007,$107,$207
	dc.w	$307,$407,$507,$607,$707,$706,$705,$704,$703,$702
	dc.w	$701,$700,$710,$720,$730,$740,$750,$760,$770,$670
	dc.w	$570,$470,$370,$270,$170,$070,$071,$072,$073,$074
	dc.w	$075,$076,$077,$067,$057,$047,$037,$027,$017,$007
	dc.w	$107,$207,$307,$407,$507,$607,$707,$706,$705,$704
	dc.w	$000,$000,$111,$222,$333,$444,$333,$222,$111,$000
coltbl2	dc.w	$100,$200,$300,$400,$500,$500,$400,$300,$200,$100
	dc.w	$030,$040,$050,$060,$070,$070,$060,$050,$040,$030
	dc.w	$303,$404,$505,$606,$707,$707,$606,$505,$404,$303
	dc.w	$003,$004,$005,$006,$007,$007,$006,$005,$004,$003
	dc.w	$020,$030,$040,$050,$060,$060,$050,$040,$030,$020
	dc.w	$300,$400,$500,$600,$700,$700,$600,$500,$400,$300
	dc.w	$220,$330,$440,$550,$660,$660,$550,$440,$330,$220
	dc.w	$202,$303,$404,$505,$606,$606,$505,$404,$303,$202
	dc.w	$002,$003,$004,$005,$006,$006,$005,$004,$003,$002
	dc.w	$000,$333,$444,$555,$666,$777,$666,$555,$444,$000
	
cont3	dc.w	0
cont4	dc.w	0	;contador sprite horizontal
sa09	dc.b	0
sa07	dc.b	0
sa13	dc.b	0
sa21	dc.b	0
sa1b	dc.b	0
sa01	dc.b	0
rot	dc.b	3,6,9,12,15,2,5,8,11,14,1,4,7,10,13
* seno del troll
sintbl	dc.b	7,7,7,7,7,6,6,6,5,5,5,4,4,3,3,2,2,1,1,0,0,1,1,2,2,3,3,4,4,5,5,5,6,6,6,7,7,7,7,7
* seno de dwarfs

	even
ppsndwf	dc.l	sndwf1
psndwf	dc.l	sndwf1
sndwf1	dc.w	0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1
	dc.w	0,0,0,-1,-1,-1,-2,-2,-2,-3,-3,-3,-4,-4,-4,-5,-5,-5,-5,-5,-5,-4,-4,-4,-3,-3,-3,-2,-2,-2,-1,-1,-1,$1234
sndwf2	dc.w	0,0,1,1,2,2,3,3,4,4,5,5,5,6,6,6,6,7,7,7,7
	dc.w	-7,-7,-7,-7,-6,-6,-6,-6,-5,-5,-5,-4,-4,-3,-3,-2,-2,-1,-1,0,0,$1234
sndwf3	rept	18
	dc.w	0,1,2,5,2,1,0,0,-1,-2,-5,-2,-1,0
	endr
	dc.w	$1234
a	equ.b	0
b	equ.b	1
c	equ.b	2
d	equ.b	3
e	equ.b	4
f	equ.b	5
g	equ.b	6
h	equ.b	7
i	equ.b	8
j	equ.b	9
k	equ.b	10
l	equ.b	11
m	equ.b	12
n	equ.b	13
o	equ.b	14
p	equ.b	15
q	equ.b	16
r	equ.b	17
s	equ.b	18
t	equ.b	19
u	equ.b	20
v	equ.b	21
w	equ.b	22
x	equ.b	23
y	equ.b	24
z	equ.b	25
a1	equ.b	26
a2	equ.b	27
a3	equ.b	28
a4	equ.b	29
a5	equ.b	30
a6	equ.b	31
a7	equ.b	32
a8	equ.b	33
a9	equ.b	34
a0	equ.b	35
aa	equ.b	36
ab	equ.b	37
ac	equ.b	38
ad	equ.b	39
ae	equ.b	40
af	equ.b	41
ag	equ.b	42
text    dc.b    a5,aa,aa,aa,ag,a4,aa,aa,aa,ag,a3,aa,aa,aa,ag,a2,aa,aa,aa
        dc.b    ag,a1,aa,aa,aa,ag,a0,aa,aa,aa,ag,ag,ag,ag,ag,ag,ag,ag,ag
        dc.b    ag,ag,ag,ag,ag,ag,ag,ag,ag
        dc.b    t,h,e,ag,s,p,a,c,e,w,a,l,k,e,r,ag,ab,r,i,d,i,n,g,ag,t,h,e
        dc.b    ag,c,y,b,e,r,s,p,a,c,e,ac,ag,p,r,o,u,d,l,y,ag,p,r,e,s,e,n,t,s
        dc.b    ag,ag,ag,ag,ag,ag,ag,ag,ag
        dc.b    t,h,e,ag,a1,s,t,ag,i,n,t,r,o,ag,b,y,ag,t,h,e,ag,b,e,a,s,t,s,ag
        dc.b    c,r,e,w,ag,ab,t,b,c,ac
        dc.b    ag,ag,ag,ag,ag,ag,ag,ag,ag,ag,ag
        dc.b    p,r,e,s,s,ag,k,e,y,s,ag,a1,ag,t,o,ag,a3,ag,t,o,ag,c,h,a,n,g,e,ag
        dc.b    t,h,e,ag,s,p,e,e,d,ag,o,f,ag,t,h,e,ag,s,c,r,o,l,l,ag,a,n,d,ag
        dc.b    k,e,y,s,ag,a4,ag,t,o,ag,a6,ag,t,o,ag,c,h,a,n,g,e,ag,t,h,e,ag
        dc.b    s,i,n,e,ag,w,a,v,e,s,ag,o,f,ag,t,h,e,ag,s,p,r,i,t,e,s,ag
        dc.b    t,h,e,ag,b,e,a,s,t,s,ag,c,r,e,w,ag,i,s,ag,c,o,m,p,o,s,s,e,d,ag
        dc.b    b,y,ag,t,h,e,ag,s,p,a,c,e,w,a,l,k,e,r
        dc.b    ag,ag,ag,ag,ag,ag,ag,ag,ag,ag,ag
        dc.b    e,n,d,e,r,ag,w,i,g,g,i,n
        dc.b    ag,ag,ag,ag,ag,ag,ag,ag,ag,ag,ag
        dc.b    t,e,r,m,i,n,a,t,o,r,ag,a1,a0,a0,a0,aa
        dc.b    ag,ag,ag,ag,ag,ag,ag,ag,ag,ag,ag
        dc.b    t,h,i,s,ag,i,n,t,r,o,ag,w,a,s,ag,c,r,e,a,t,e,d,ag
        dc.b    i,n,ag,a1,a9,a9,a0
        dc.b    ag,ag,ag,ag,ag,ag,ag,ag,ag,ag,ag,ag,ag
        dc.b    s,a,l,u,t,e,s,ag,t,o,ag,a,l,l,ag,r,e,m,a,i,n,i,n,g,ag
        dc.b    c,r,e,w,s,ag,ag,ag,b,a,c,k,ag,f,r,o,m,ag,a2,a0,a0,a3,ag,ag
        dc.b    ag,ag,ag,ag,ag,ag,ag,ag,ag,ag,ag,ag
        dc.b    l,e,t,s,ag,d,o,ag,t,h,e,ag,t,i,m,e,ag,w,a,r,p,aa,aa,aa,aa
        dc.b    aa,aa,aa,aa,aa,aa,ag,aa,ag,aa,ag,aa,ag,aa
        dc.b    ag,ag,aa,ag,ag,aa,ag,ag,aa,ag,ag,aa,ag,ag,ag,aa,ag,ag,ag,aa
	dc.b	50

***************************************
*       UN DISPARO		      *
***************************************
SOUND1:
	DC.B	0,0,1,0,2,0,3,0,4,0,5,0
	DC.B	6,15
	DC.B	7,199
	DC.B	8,16
	DC.B	9,16
	DC.B	10,16
	DC.B	11,0
	DC.B	12,16
	DC.B	13,0
	DC.B	130,25


	DC.B	8,0,9,0
	DC.B	130,50


	dc.l	0

flag	dc.b	0
flgsndw	dc.b	0	
cont1	dc.b	16
cont2	dc.b	0
cont5	dc.b	0	;contador de hbls
velo	dc.b	1
velos	dc.b	1
;prog	dc.b	'a:\trailbla.zer\trail.img',0
	even
muzz	lea	muzzak,a0
	movea.l	#$720c0,a1
	move.w	#(5500/4)-1,d0
copy3	move.l	(a0)+,(a1)+
	dbra	d0,copy3
	move.l	#$72254,$4d6	;aqui cuelgo rut
	rts
;img	dc.b	'c:\TBC\TS2\title.pi1',0
letras	incbin	'c:\TBC\TS2\letras1.ts'
spri	incbin	'c:\TBC\TS2\logo3.ts'
muzzak  incbin  'c:\TBC\TS2\music6.bin'
dwarfs	incbin	'c:\TBC\TS2\dwarfs1.ts'
	
	even
* Aqui salta desde el vbl pa cambiar senos de dwarves
dwsen1	move.l	#sndwf1,a1
	move.l	#$7ab48,d0
	bsr	dwsnrut
	bclr	#0,flgsndw
	bra	troll
dwsen2	move.l	#sndwf2,a1
	move.l	#$7ab48,d0
	bsr	dwsnrut
	bclr	#1,flgsndw
	bra	troll	
dwsen3	move.l	#sndwf3,a1
	move.l	#$7ab48,d0
	bsr	dwsnrut
	bclr	#2,flgsndw
	bra	troll
		
dwsnrut	lea	ppsndwf,a0
	move.l	a1,(a0)+
	move.l	a1,(a0)
	lea	pdwrf,a0
	rept	9
	move.l	d0,(a0)+
	endr
	rts


* Despues calcula lo que sube o baja y actualiza
* a0, que lleva el PUNtero a PANtalla
dirpix	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	punpan,a0
	lea	sintbl,a1
	
	cmp.b	#40,cont3
	bne	no5
	clr.b	cont3
no5	clr.l	d0
	move.b	cont3,d0
	adda.l	d0,a1
	move.b	(a1),d0
	mulu.w	#160,d0
	add.b	#1,cont3
	
	movea.l	trolls,a2
	movea.l	ptrolls,a1
	cmp.b	#20,cont3
	bgt	bajar
	suba.l	d0,a0
	bra	no6
bajar	adda.l	d0,a0

*Ahora calcula pa izquierda o derecha
*, actualiza a0 solo cuando es necesario
*(esto es cuando hay que pasar a la siguiente word)

no6	add.w	#1,cont4
	cmp.w	#75,cont4
	bgt	moveri
	move.w	#6,d0
	mulu.w	#5320,d0
	add.l	a2,d0
	cmp.l	d0,a1
	beq	no6x
	move.w	#11,d0
	mulu.w	#5320,d0
	add.l	a2,d0
	cmp.l	d0,a1
	beq	no6x
	move.w	#16,d0
	mulu.w	#5320,d0
	add.l	a2,d0
	cmp.l	d0,a1
	bne	copy
	movea.l	trolls,a1
no6x	adda.l	#8,a0
	bra	copy
moveri	cmp.w	#150,cont4
	bne	no7
	clr.w	cont4
no7	suba.l	#10640,a1
	move.w	#5,d0
	mulu.w	#5320,d0
	add.l	a2,d0
	cmp.l	d0,a1
	beq	no8
	move.w	#10,d0
	mulu.w	#5320,d0
	add.l	a2,d0
	cmp.l	d0,a1
	beq	no8
	move.l	a2,d0
	sub.l	#5320,d0
	cmp.l	d0,a1
	bne	copy
	move.w	#15,d0
	mulu.w	#5320,d0
	add.l	a2,d0
	movea.l	d0,a1
no8	suba.l	#8,a0

copy	move.l	a0,sa0
	move.l	a1,sa1
	
	bclr	#0,flag
	movem.l	(sp)+,d0-d7/a0-a6
nosta	jmp	jaja	;esta dir es cambiada por key

	
