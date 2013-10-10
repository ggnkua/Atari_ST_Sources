tab_buf	equ	$70000

buf1	equ	tab_buf+160*24*0

buf2	equ	tab_buf+160*24*1

buf3	equ	tab_buf+160*24*2

buf4	equ	tab_buf+160*24*3

tab_st	equ	tab_buf+160*24*4

st1	equ	tab_st+8*24*0

st2	equ	tab_st+8*24*1

st3	equ	tab_st+8*24*2

st4	equ	tab_st+8*24*3

degas1	equ	$68000

degas2	equ	$70000

music	equ	$4f34c

coldec	equ	$68000+88*160

lettre	equ	$78000-320

filedat	equ	$4f2aa-28

longdat	equ	50000

musicgo	equ	filedat+28

tf0	equ	filedat+$2170

tf1	equ	filedat+$21de

tf2	equ	filedat+$224c

tf3	equ	filedat+$22ba

col2	equ	filedat+$2328

pic1	equ	filedat+$23d8

pic2	equ	filedat+$31a6

reserv	move.l	sp,pile
	movea.l	$04(sp),a5
	move.l	$08(a5),begin
	lea	data,a0
	lea	filedat-28,a1
	lea	longdat,a2
	bsr	load
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack
	movem.l	buffer,d0-d7
	movem.l	d0-d7,$ff8240
	dc.w	$a00a
	move.b	#$12,$fffc02
	clr.w	-(sp)
	move.l	#$78000,-(sp)
	move.l	#$78000,-(sp)
	move.w	#$05,-(sp)
	trap	#14
	lea	12(sp),sp
	lea	degas1,a3
	lea	pic1+34,a5
	bsr	compact
	lea	degas2,a3
	lea	pic2+34,a5
	bsr	compact
	movea.l	#degas2,a0
	movea.l	#$78000+35*160,a1
	move.w	#20*123-1,d0
	
dp	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbf	d0,dp
	movea.l	#col2,a0
	movea.l	#coldec,a1
	bsr	decom
	bsr	razbuf
	bsr	table
	bsr	detour
	move.b	#$06,$4f317
	jsr	musicgo
	
debut	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	cmpi.b	#' ',d0
	bne	debut
	
fin	lea	$4CE,a1
	lea	buffer,a0
	move.l	(a0)+,$452
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)
	move.l	(a0)+,$502
	move.l	(a0)+,$70
	move.l	(a0)+,$118
	move.l	(a0)+,$120
	lea	$fffa00,a1
	move.b	(a0)+,$07(a1)
	move.b	(a0)+,$09(a1)
	move.b	(a0)+,$0f(a1)
	move.b	(a0)+,$13(a1)
	move.b	(a0)+,$1b(a1)
	move.b	(a0)+,$21(a1)
	move.b	#$07,$ff8800
	ori.b	#$3f,$ff8802
	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#$05,-(sp)
	trap	#14
	adda.l	#12,sp
	dc.w	$a009
	move.b	#$08,$fffc02
	
reloc	move.l	#fblock-dblock,d0
	movea.l	#$70000,a0
	movea.l	#dblock,a1
	
dsds	move.b	(a1)+,(a0)+
	dbf	d0,dsds
	jmp	$70000

loading	equ	$20000

longexe	equ	90000

dblock	lea	soft(pc),a0
	movea.l	#loading,a1
	movea.l	#longexe,a2
	jsr	load(pc)
	move.l	begin(pc),a6
	movea.l	loading+02,a0
	adda.l	loading+06,a0
	move.l	a6,d1
	move.l	#loading+28,d2
	movea.l	d2,a2
	movea.l	d2,a3
	adda.l	a0,a3
	move.l	(a3)+,d0
	beq	reloc3
	clr.l	-4(a3)
	
reloc1	adda.l	d0,a2
	moveq	#0,d0
	add.l	d1,(a2)
	
reloc2	move.b	(a3),d0
	beq	reloc3
	clr.b	(a3)+
	cmp.b	#1,d0
	bne	reloc1
	adda.l	#254,a2
	bra	reloc2
	
reloc3	lea	-$100(a6),a6
	move.l	loading+2,$c(a6)
	move.l	loading+6,$14(a6)
	move.l	loading+10,$1c(a6)
	move.l	$8(a6),$10(a6)
	move.l	$c(a6),d0
	add.l	d0,$10(a6)
	move.l	$10(a6),$18(a6)
	move.l	$14(a6),d0
	add.l	d0,$18(a6)
	movea.l	#loading+28,a0
	movea.l	a0,a1
	adda.l	#longexe,a1
	movea.l	begin(pc),a2
	
rel1	move.l	(a0)+,(a2)+
	cmpa.l	a0,a1
	bge	rel1
	move.b	#3,$484
	move.l	stack(pc),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	pile(pc),sp
	move.l	begin(pc),a0
	suba.l	#$100,a0
	move.l	a0,4(sp)
	jmp	$100(a0)
	
begin	dc.l	0

pile	dc.l	0

stack	dc.l	0

load	move.w	#0,-(sp)
	move.l	a0,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bpl	read
	
error	clr.l	-(sp)
	trap	#1
	
read	move.w	d0,d3
	move.l	a1,-(sp)
	move.l	a2,-(sp)
	move.w	d3,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	adda.l	#12,sp
	
close	move.w	d3,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	rts
	
soft	dc.b	"HELICO.SPR",0
	even
	
data	dc.b	"DATA.MDK",0
	even
	
fblock

razbuf	movea.l	#tab_buf,a0
	moveq	#0,d1
	move.w	#16128/16-1,d0
	
razbu1	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbf	d0,razbu1
	rts
	
table	movea.l	#degas2+126*160,a0
	movea.l	#lettre,a2
	moveq	#2,d0
	
ta2	movea.l	a0,a3
	moveq	#19,d1
	
ta1	move.l	a0,(a2)+
	adda.l	#8,a0
	dbra	d1,ta1
	movea.l	a3,a0
	adda.l	#25*160,a0
	dbf	d0,ta2
	rts
	
detour	move.w	sr,-(sp)
	ori.w	#$700,sr
	lea	$4ce,a0
	lea	buffer,a1
	move.l	$452,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)+
	move.l	$502,(a1)+
	move.l	$70,(a1)+
	move.l	$118,(a1)+
	move.l	$120,(a1)+
	lea	$fffa00,a0
	move.b	$07(a0),(a1)+
	move.b	$09(a0),(a1)+
	move.b	$0f(a0),(a1)+
	move.b	$13(a0),(a1)+
	move.b	$1b(a0),(a1)+
	move.b	$21(a0),(a1)+
	move.l	$118,acia1+2
	move.l	#acia,$118
	move.l	$70,vbl1+2
	move.l	#vbl,$70
	andi.b	#$de,$fffa07
	andi.b	#$cf,$fffa09
	move.l	#hbl_1,$120
	ori.b	#1,$fffa07
	ori.b	#1,$fffa13
	move.l	#scroll,$4ce
	move.l	#mdk,$4d2
	move.l	#roule,$4d6
	move.w	(sp)+,sr
	rts
	
buffer	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	
acia	move.w	#$2500,sr

acia1	jmp	$00000000

vbl	clr.b	$fffa1b
	move.b	#1,$fffa21
	move.b	#8,$fffa1b
	move.l	#hbl_1,$120
	clr.b	$fffa0f
	
vbl1	jmp	$00000000

hbl_1	movem.l	d0/d1/a4-a6,-(sp)
	move.w	#$2700,sr
	movea.w	#$fa00,a6
	clr.b	$1b(a6)
	move.b	#laps1,$21(a6)
	move.b	#8,$1b(a6)
	movea.w	#$8240,a4
	movea.l	#cola,a5
	moveq	#5,d0
	
hbl_10	move.b	$21(a6),d1

hbl_11	cmp.b	$21(a6),d1
	beq	hbl_11
	nop
	nop
	nop
	nop
	move.w	(a5)+,(a4)
	dbf	d0,hbl_10
	lea	couleur,a5
	movem.l	(a5)+,d0-d1
	movem.l	d0-d1,12(a4)
	movem.l	(a5)+,d0-d1
	movem.l	d0-d1,20(a4)
	movem.l	(sp)+,d0/d1/a4-a6
	move.l	#hbl_1a,$120
	move.w	#$2200,sr
	move.b	#0,$fffa0f
	rte
	
couleur	dc.w	$111,$222,$333,$444,$555,$666,$777,$000

hbl_1a	movem.l	d0-d3/a4-a6,-(sp)
	move.w	#$2700,sr
	movea.w	#$fa00,a6
	clr.b	$1b(a6)
	move.b	#laps2,$21(a6)
	move.b	#8,$1b(a6)
	movea.w	#$8240,a4
	movea.l	#colb,a5
	moveq	#5,d0
	
hbl_10a	move.b	$21(a6),d1

hbl_11a	cmp.b	$21(a6),d1
	beq	hbl_11a
	nop
	nop
	nop
	nop
	move.w	(a5)+,(a4)
	dbf	d0,hbl_10a
	lea	colc,a5
	movem.l	(a5)+,d0-d3
	movem.l	d0-d3,(a4)
	movem.l	(a5)+,d0-d3
	movem.l	d0-d3,16(a4)
	movem.l	(sp)+,d0-d3/a4-a6
	move.l	#hbl_2,$120
	move.w	#$2200,sr
	bclr	#0,$fffa0f
	rte
	
laps1	equ	29

laps2	equ	128

cola	dc.w	$405,$506,$707,$506,$405,$102

colb	dc.w	$405,$506,$707,$506,$405,$550

colc	dc.w	$000,$333,$444,$666,$777,$743,$732,$521
	dc.w	$760,$270,$061,$037,$507,$707,$111,$222
	
hbl_2	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$2700,sr
	movea.w	#$fa00,a6
	clr.b	$1b(a6)
	move.b	#42,$21(a6)
	move.b	#8,$1b(a6)
	movea.w	#$8240,a5
	movea.l	ptcol2,a4
	moveq	#40,d0
	
hbl_21	movem.l	(a4),d1-d5
	move.w	20(a4),d6
	move.b	$21(a6),d7
	
hbl_22	cmp.b	$21(a6),d7
	beq	hbl_22
	nop
	nop
	nop
	cmpi.w	#000,(a4)
	beq	hbl_23
	movem.l	d1-d5,(a5)
	move.w	d6,20(a5)
	adda.l	#22,a4
	dbf	d0,hbl_21
	move.w	#$2200,sr
	movem.l	(sp)+,d0-d7/a0-a6
	rte
	
hbl_23	movea.l	#col3,a3
	movem.l	(a3),d1-d6
	movem.l	d1-d6,(a5)
	addq.l	#2,a4
	dbf	d0,hbl_21
	move.w	#$2200,sr
	movem.l	(sp)+,d0-d7/a0-a6
	rte
	
col3	dc.w	$000,$000,$000,$000,$027,$057,$777,$666
	dc.w	$760,$750,$741,$530,$310,$200,$111,$222
	
mdk	move.w	temps,d0
	beq	mdk1
	subq.w	#1,temps
	rts
        
mdk1	subq.w	#1,fois
	bne	mdk3
	move.w	#200,temps
	move.w	#18,fois
	movea.l	admek1,a0
	cmpa.l	#degas1+160*66,a0
	bne	mdk2
	move.l	#degas1,admek1
	move.l	#degas1,admek
	rts

mdk2	addi.l	#160*22,admek1
	move.l	admek1,admek
	rts
	
mdk3	bsr	decband
	movea.l	admek1,a0
	adda.l	#112,a0
	cmpa.l	admek,a0
	beq	mdk4
	movea.l	#$78000+160*7+152,a0
	movea.l	admek,a1
	moveq	#21,d0

mdk5	move.l	(a1),(a0)
	move.l	4(a1),4(a0)
	adda.l	#160,a0
	adda.l	#160,a1
	dbf	d0,mdk5
	addi.l	#8,admek

mdk4	rts

decband	moveq	#21,d0
	movea.l	#$78000+7*160,a6

decban1	movem.l	8(a6),d1-d7/a0-a4 
	movem.l	d1-d7/a0-a4,0(a6) 
	movem.l	$38(a6),d1-d7/a0-a4
	movem.l	d1-d7/a0-a4,$30(a6) 
	movem.l	$68(a6),d1-d7/a0-a4 
	movem.l	d1-d7/a0-a4,$60(a6)
	movem.l	$98(a6),d1-d2
	movem.l	d1-d2,$90(a6)
	adda.l	#$a0,a6
	dbf	d0,decban1
	rts

fois	dc.w	18

temps	dc.w	0

admek	dc.l	degas1

admek1	dc.l	degas1

roule	subq.w	#1,tempo
	bne	roule1
	move.w	#3,tempo
	addi.l	#282,ptcol2
	movea.l	ptcol2,a0
	cmpi.w	#$FFFF,(a0)
	bne	roule1
	move.l	#coldec,ptcol2

roule1	rts

tempo	dc.w	3      

ptcol2	dc.l	coldec

scroll	move.w	branch,D2     
	addq.w	#1,branch     
	cmpi.w	#3,d2         
	bne	scroll1        
	clr.w	branch         

scroll1	asl.w	#2,d2          
	movea.l	#adresse,a2   
	movea.l	0(a2,d2.w),a2 
	jmp	(A2)              

ad1	movea.l	#buf4,a6    
	bsr	scroh
	movea.l	#buf3,a6    
	movea.l	#st3,a5
	bra	scrolh

ad2	movea.l	#buf3,a6
	bsr	scroh
	movea.l	#buf2,a6
	movea.l	#st2,a5
	bra	scrolh

ad3	movea.l	#buf2,a6
	bsr	scroh
	movea.l	#buf1,a6
	movea.l	#st1,a5
	bra	scrolh

ad4	movea.l	#buf1,a6    
	bsr	scroh
	movea.l	#texte,a0     
	movea.l	#lettre,a1     

scrolh1	move.w	cmpt_lt,d0 
	move.b	0(a0,d0.w),d1 
	cmpi.b	#52,d1       
	bne	scrolh2       
	clr.w	cmpt_lt      
	bra	scrolh1          

scrolh2	ext.w	d1             
	asl.w	#2,d1          
	move.l	0(a1,d1.w),mem1
	addq.w	#1,cmpt_lt     
	move.w	cmpt_lt,d0
	move.b	0(a0,d0.w),d1   
	cmpi.b	#52,d1         
	bne	scrolh3         
	move.b	(a0),d1         

scrolh3	ext.w	d1               
	asl.w	#2,d1
	move.l	0(a1,d1.w),mem2 
	bsr	masque     
	movea.l	#buf4,a6 
	movea.l	#st4,a5       

scrolh	moveq	#23,d0      

scrolh4	movem.l	8(a6),d1-d7/a0-a4 
	movem.l	d1-d7/a0-a4,0(a6) 
	movem.l	$38(a6),d1-d7/a0-a4
	movem.l	d1-d7/a0-a4,$30(a6) 
	movem.l	$68(a6),d1-d7/a0-a4 
	movem.l	d1-d7/a0-a4,$60(a6)
	movem.l	$98(a6),d1-d2
	movem.l	d1-d2,$90(a6)
	adda.l	#$98,a6
	move.l	(a5)+,(a6)+   
	move.l	(a5)+,(a6)+   
	dbf	d0,scrolh4
	rts

masque	movem.l	d0-d6/a0-a2,-(sp)
	move.l	mem1,d4      
	move.l	mem2,d5      

masq1	moveq	#23,d0       
	move.l	d5,a1        
	movea.l	#st1,a0      

masq2	move.l	0(a1),(a0)+  
	move.l	4(a1),(a0)+  
	adda.l	#160,a1
	dbf	d0,masq2
	moveq	#3,d2          
	moveq	#4,d3          
	moveq	#12,d6         

masq3	movea.l	#tab1,a0     
	movea.l	0(a0,d6.w),a0 
	movea.l	d4,a1         
	movea.l	d5,a2         
	moveq	#23,d0        

masq4	move.w	0(a1),d1
	swap	d1
	move.w	0(a2),d1
	rol.l	d3,d1
	swap	d1
	move.w	d1,(a0)+
	move.w	2(a1),d1
	swap	d1
	move.w	2(a2),d1
	rol.l	d3,d1
	swap	d1
	move.w	d1,(a0)+
	move.w	4(a1),d1
	swap	d1
	move.w	4(a2),d1
	rol.l	d3,d1
	swap	d1
	move.w	d1,(a0)+
	move.w	6(a1),d1
	swap	d1
	move.w	6(a2),d1
	rol.l	d3,d1
	swap	d1
	move.w	d1,(a0)+
	lea	160(a1),a1        
	lea	160(a2),a2        
	dbf	d0,masq4
	addq.l	#4,d3        
	subq.l	#4,d6        
	subq.l	#1,d2        
	bne	masq3
	movem.l	(sp)+,d0-d6/a0-a2
	rts

scroh	movea.l	#$78000+160*167,a5      
	moveq	#23,d0         

scro1	movem.l	$00(a6),d1-d7/a0-a4  
	movem.l	d1-d7/a0-a4,$00(a5)
	movem.l	$30(a6),d1-d7/a0-a4
	movem.l	d1-d7/a0-a4,$30(a5)
	movem.l	$60(a6),d1-d7/a0-a4
	movem.l	d1-d7/a0-a4,$60(a5)
	movem.l	$90(a6),d1-d4
	movem.l	d1-d4,$90(a5)
	lea	160(a5),a5
	lea	160(a6),a6
	dbf	d0,scro1
	rts
	
compact	move.l	#199,d4
	movea.l	#6,a0
	moveq	#4,d6
	moveq	#40,d7

compac1	clr.b	d1
	movea.l	a3,a4

compac3	move.l	a4,-(sp)
	clr.b	d3

compac2	move.b	(a5)+,d0
	tst.b	d0
	bmi	compac6
	addq.b	#1,d0

compac4	move.b	(a5)+,(a4)+
	addq.b	#1,d3
	move.l	a4,d5
	btst	#0,d5
	bne	compac8
	adda.l	a0,a4

compac8	subq.b	#1,d0
	bne	compac4
	bra	compac7

compac6	neg.b	d0
	addq.b	#1,d0
	move.b	(a5)+,d2

compac5	move.b  d2,(a4)+
	addq.b	#1,d3
	move.l	a4,d5
	btst	#0,d5
	bne	compac9
	adda.l	a0,a4

compac9	subq.b	#1,d0
	bne	compac5

compac7	cmp.b	d7,d3
	bne	compac2
	movea.l	(sp)+,a4
	addq.l	#2,a4
	addq.b	#1,d1
	cmp.b	d6,d1
	bne	compac3
	adda.l	#160,a3
	dbf	d4,compac1              
	rts

decom	moveq	#0,d0
	move.b	(a0)+,d0
	bne	decom1
	move.b	(a0)+,d0
	subq.w	#1,d0

decom6	clr.w	(a1)+
	dbf	d0,decom6
	bra	decom

decom1	cmpi.b	#$FF,d0
	beq	decom3
	movea.l	#tf0,a2
	move.b	#$f0,d1

decom2	cmp.b	d0,d1
	beq	decom4
	addq.w	#1,d1
	adda.l	#5*11*2,a2
	bra	decom2

decom4	moveq	#10,d0

decom5	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.w	(a2)+,(a1)+
	dbf	d0,decom5 
	bra	decom       

decom3	move.w	#$FFFF,(a1)
	rts
	
cmpt_lt	dc.w	0000

branch	dc.w	0000

mem1	dc.l	0000

mem2	dc.l	0000

tab1	dc.l	st1
	dc.l	st2
	dc.l	st3
	dc.l	st4
		
adresse	dc.l	ad4
	dc.l	ad1
	dc.l	ad2
	dc.l	ad3
		
texte	incbin	texte.mdk