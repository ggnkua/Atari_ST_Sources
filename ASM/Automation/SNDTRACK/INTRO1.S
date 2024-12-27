; Coding by TBE

; Remember that key depress routines must be set up twice for
; ST's and STE's

MVOL	EQU $80
FREQ	EQU 2				
	IFEQ FREQ
PARTS	EQU 5-1				
LEN	EQU 25
INC	EQU $023BF313			
	ELSEIF
	IFEQ FREQ-1
PARTS	EQU 5-1				
LEN	EQU 50
INC	EQU $011DF989			
	ELSEIF
	IFEQ FREQ-2
PARTS	EQU 5-1				
LEN	EQU 100
INC	EQU $008EFB4E			
	ELSEIF
	IFEQ FREQ-3
PARTS	EQU 5-1				
LEN	EQU 200
INC	EQU $00477CEC			
	ELSEIF
	FAIL
	END
	ENDC
	ENDC
	ENDC
	ENDC

scraddr	equ	$70000
start: 	move.l	a7,a5
	move.l	#ustk,a7
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#$c,sp		; Reserve memory

	clr.l   -(sp)		; Supervisor
	move.w  #$20,-(sp)
	trap    #1
	move.l  d0,savereg

	move.l  #scraddr,a7

	move.l  #moff,-(sp)		; Bye-Bye mouse
	clr.w   -(sp)
	move.w  #25,-(sp)
	trap    #14
	addq.l  #8,sp

	dc.w	$a00a               

	move.w  #4,-(sp)        ; Whic resolution ?
	trap    #14
	addq.l  #2,sp
	move.w  d0,oldrez

	move.l  $44e.w,oldscr	; Old screen address
	move.l  #scraddr,screen3  

	movem.l $ffff8240.w,d0-d7	; Old palette
	movem.l d0-d7,oldpal

	move.b  #$02,$ffff820a.w
        
	move.w	$4.w,d0	; Reset Address
	cmp.w	#$e0,d0	; Lazy Bastard !! If it's $E0... = STE !!
	beq	go	; STE Soundtracker
	bra	go2	; ST Chip Music

desky1
	bsr	musoff
	bsr	exit2
	rts
desky2 
	bsr	exit2
	rts

exit2   bsr     hbloff
        movem.l oldpal,d0-d7
        movem.l d0-d7,$ffff8240.w
        move.w  oldrez,-(sp)
        move.l  oldscr,-(sp)
        move.l  oldscr,-(sp)
        move.w  #5,-(sp)
        trap    #14
        add.l   #12,sp
        move.l  #mon,-(sp)
        clr.w   -(sp)
        move.w  #25,-(sp)
        trap    #14
        addq.l  #8,sp
        dc.w	$a009         
        move.l  savereg,-(sp)
        move.w  #$20,-(sp)
        trap    #1
        addq.l  #6,sp
        clr.l   -(sp)
        trap    #1

oldrez:  dc.w 0
oldscr:  dc.l 0
savereg: dc.l 0
screen3:  dc.l 0
oldpal:  dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	even
mon:  dc.b $08
moff: dc.b $12
	even
runprog
	move.l	d0,d0store
        bsr     hbloff
        movem.l oldpal,d0-d7
        movem.l d0-d7,$ffff8240.w
        move.w  oldrez,-(sp)
        move.l  oldscr,-(sp)
        move.l  oldscr,-(sp)
        move.w  #5,-(sp)
        trap    #14
        add.l   #12,sp

        move.l  #mon,-(sp)
        clr.w   -(sp)
        move.w  #25,-(sp)
        trap    #14
        addq.l  #8,sp
        dc.w	$a009         
        move.l  savereg,-(sp)
        move.w  #$20,-(sp)
        trap    #1
        addq.l  #6,sp

	move.l	d0store,d0
	sub.w	#'1',d0
	asl.w	#2,d0
	lea	fnamelkp,a0
	add.w	d0,a0
	pea	env
	pea	com
	move.l	(a0),-(sp)
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
bra1	bra	bra1

go
	bsr	scroller
	jsr	mus
	bsr	put_screen
          bsr       hblon
	bsr	test2
	rts

go2
	bsr	scroller
	move	#1,d0
	move	mus_c,d0		
	jsr	mus1
	bsr	put_screen
          bsr       hblon
	bsr	test3

test2
	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	beq	test2

	cmp.b	#'1',d0
	beq	desky1
	cmp.b	#'2',d0
	beq	turnoff
	bra	test2
	rts
test3
	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	beq	test3

	cmp.b	#'1',d0
	beq	desky2
	cmp.b	#'2',d0
	beq	runprog
	bra	test3
	rts

turnoff
	bsr	musoff
	bsr	runprog
	rts

d0store	dc.l	0
env	dc.l	0
com	dc.l	0
fnamelkp	dc.l	fname1
	dc.l	fname2
	
fname1	dc.b	'\file1.ts',0
fname2	dc.b	'\file2.ts',0
	even		
	even
hblon:
        move.l  $120.w,oldtb    
        move.l  $70.w,old4
        move.l  $70.w,new4b+2
        move.b  $fffffa07.w,old07
        move.b  $fffffa09.w,old09
        move.b  $fffffa0f.w,old0f
        move.b  $fffffa11.w,old11
        move.b  $fffffa1b.w,old1b
        and.b   #$df,$fffa09    
        and.b   #$fe,$fffa07    
        move.l  #newtb,$120.w
        move.l  #new4,$70.w
        or.b    #1,$fffffa07.w  
        or.b    #1,$fffffa13.w
        rts

hbloff:
        move.w  sr,-(sp)
        move.w  #$2700,sr
        move.b  old07(pc),$fffffa07.w    
        move.b  old09(pc),$fffffa09.w
        move.b  old0f(pc),$fffffa0f.w
        move.b  old11(pc),$fffffa11.w
        move.b  old1b(pc),$fffffa1b.w
        move.l  oldtb,$120.w             
        move.l  old4,$70.w
        move.l	$456,a0
        clr.l	12(a0)
        clr.l	16(a0)
        clr.l	20(a0)
        move.w  (sp)+,sr
        rts

old4:  dc.l 0
oldtb: dc.l 0
old07: dc.b 0
old09: dc.b 0
old0f: dc.b 0
old11: dc.b 0
old1b: dc.b 0
	even

new4:
        clr.b   $fffffa1b.w
        move.b  #199,$fffffa21.w
        move.b  #8,$fffffa1b.w
new4b:
        jmp     $000000

newtb:
        clr.b   $fffffa1b.w     
        movem.l d0-d1/a0-a1,-(sp)
        move.w  #$fa21,a1
        move.b  #200,(a1)
        move.b  #8,$fffffa1b.w

        move.b  (a1),d0
wait:                           
        cmp.b   (a1),d0
        beq     wait
                                
        clr.b   $ffff820a.w     

        moveq   #3,d0
nopi2:                          
        nop
        dbf     d0,nopi2
                                
        move.b  #2,$ffff820a.w  

        movem.l (sp)+,d0-d1/a0-a1
        bclr    #0,$fffffa0f.w  
        rte

scroller
	clr.l	d6
	move.w	#0,lcurr
	move.l	#text,a6
	lea	buffer,a5
	move.w	lcurr,d6
	add.l	d6,a6
	move.b	(a6),d6
	and.l	#$ff,d6
	sub.b	#32,d6   
	asl.w	#7,d6    
	lea	font,a4
	add.l	d6,a4
	move.w	#63,d7   
loop1	move.w	(a4)+,(a5)+
	dbra	d7,loop1

	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,sav_phys

	clr.w	-(sp)
	move.l	screen3,-(sp)
	move.l	screen3,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#$c,sp
	rts

put_screen
	lea	savpal,a1
	lea	$ff8240,a0
	move.w	#$f,d0
getcols	move.w	(a0)+,(a1)+
	dbra	d0,getcols
	lea	screen,a1
	add.l	#2,a1
	lea	$ff8240,a0
	move.w	#$f,d0
setpal	move.w	(a1)+,(a0)+
	dbra	d0,setpal
	
	lea	screen,a0
	add.l	#34,a0
	lea	scraddr,a1
	move.w	#$7d00-1,d0
putpic	move.b	(a0)+,(a1)+
	dbra	d0,putpic


	lea	scraddr+$7d00,a0
	move.w	#$7d00-1,d0
clear	clr.w	(a0)+
	dbra	d0,clear

	rts

sav_phys	ds.l	1
		
handle	dc.w	0
new_rez	dc.w	0
	
mus_c	dc.w	1           

pause	move.w	#$c,d3
bwait	move.w	#$d000,d4
wait2	nop
	dbra	d4,wait2
	dbra	d3,bwait
pause2	move.w	#$10,d3     
wait3	move.w	#$ffff,d4
wait4	nop
	dbra	d4,wait4
	dbra	d3,wait3
	rts

clrsnd	
	move.l	#$0000000,$456.w
	move.l 	#$8080000,$ff8800
	move.l	#$9090000,$ff8800
	move.l 	#$a0a0000,$ff8800
	rts
mus	

	move.l	$456.w,a0	
	move.w	#16,pixels
	move.l	#lscroll,16(a0)
	move.l	16(a0),20(a0)
	pea	muson
	move.w	#$26,-(sp)
	trap	#14			
	addq.w	#6,sp
	
	rts

mus1	
	move.l	$456.w,a0	
	move.l	#music2+8,12(a0)	
	move.w	#16,pixels
	move.l	#lscroll,16(a0)
	move.l	16(a0),20(a0)
	move	mus_c,d0	
	jmp	music2
	rts

lscroll
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#15,d0
	move.l	#scraddr+(210*$a0),a1
	move.l	#buffer,a2
scroll	
	cmp.w	#0,pixels
	beq	getnextchar
scrollit
	roxl.w	(a2)
	roxl.w	$98-000(a1)
	roxl.w	$90-160(a1)
	roxl.w	$88-320(a1)
	roxl.w	$80-480(a1)
	roxl.w	$78-640(a1)
	roxl.w	$70-480(a1)
	roxl.w	$68-320(a1)
	roxl.w	$60-160(a1)
	roxl.w	$58-000(a1)
	roxl.w	$50+160(a1)
	roxl.w	$48+320(a1)
	roxl.w	$40+480(a1)
	roxl.w	$38+320(a1)
	roxl.w	$30+160(a1)
	roxl.w	$28+000(a1)
	roxl.w	$20-160(a1)
	roxl.w	$18-320(a1)
	roxl.w	$10-480(a1)
	roxl.w	$8-320(a1)
	roxl.w	$0-160(a1)

	add.l	#$a0,a1
	add.l	#8,a2
	dbra	d0,scrollit
	subq.w	#1,pixels
	movem.l	(sp)+,d0-d7/a0-a6
	rts

getnextchar
	clr.l	d0
	add.w	#1,lcurr
	move.l	#text,a0
	lea	buffer,a1
	move.w	lcurr,d0
	add.l	d0,a0
	clr.l	d0
	move.b	(a0),d0
	and.l	#$ff,d0
	cmp.b	#$ff,d0
	beq	looper
	sub.b	#32,d0
	asl.w	#7,d0
	lea	font,a0
	add.l	d0,a0
	move.w	#63,d0
loop2	move.w	(a0)+,(a1)+
	dbra	d0,loop2

	move.w	#16,pixels

	move.l	#scraddr+(210*$a0),a1
	lea	buffer,a2
	move.w	#15,d0
	bra	scrollit

looper
	move.w	#-1,lcurr
	bra	getnextchar
	
muson	bsr	vol			
	bsr	incrcal			
	jsr	init			
	jsr	prepare			
	move	#$2700,sr
	bset	#5,$FFFFFA07.w
	bset	#5,$FFFFFA13.w
	clr.b	$FFFFFA19.w
	move.b	#1,$FFFFFA1F.w
	move.b	#8,$FFFFFA19.w
	move.l	$0134.w,oldtima
	move.l	#stereo,$0134.w
	move.b	#FREQ,$FFFF8921.w		
	lea	$FFFF8907.w,a0
	move.l	#sample1,d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)
	move.l	#sample1+LEN*2,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)
	move.b	#3,$FFFF8901.w		
	move	#$2300,sr
	rts

musoff	move	#$2700,sr
	clr.b	$FFFFFA19.w		
	move.l	oldtima(pc),$0134.w	
	bclr	#5,$FFFFFA07.w
	bclr	#5,$FFFFFA13.w
	clr.b	$FFFF8901.w		
	move	#$2300,sr
	rts

oldtima	DC.L 0

vol	moveq	#64,d0
	lea	vtabend(pc),a0
.ploop	move.w	#255,d1
.mloop	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL,d2		
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop
	rts

vtab	DS.B 65*256
vtabend
incrcal	lea	stab(pc),a0
	move.w	#$30,d1
	move.w	#$039F-$30,d0
	move.l	#INC,d2
recalc	swap	d2
	moveq	#0,d3
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	swap	d4
	swap	d2
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	move.l	d4,(a0)+
	addq.w	#1,d1
	dbra	d0,recalc
	rts
itab	DS.L $30
stab	DS.L $03A0-$30
stereo	move	#$2500,sr
	bclr	#5,$FFFFFA0F.w
	movem.l	d0-a6,-(sp)
	move.l	samp1(pc),d0
	move.l	samp2(pc),samp1
	move.l	d0,samp2
	lea	$FFFF8907.w,a0
	move.l	samp1(pc),d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)
	move.l	samp1(pc),d0
	add.l	#LEN*2,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)
	subq.w	#1,count1
	bpl.s	.nomus
	move.w	#PARTS,count1
	bsr	music
.nomus	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq	#0,d0
	moveq	#0,d4
v1	movea.l	wiz2lc(pc),a0
	move.w	wiz2pos(pc),d0
	move.w	wiz2frc(pc),d1
	move.w	aud2per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2
	movea.w	2(a5,d7.w),a4
	move.w	aud2vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2
	movea.l	wiz3lc(pc),a1
	move.w	wiz3pos(pc),d4
	move.w	wiz3frc(pc),d5
	move.w	aud3per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5
	move.w	aud3vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3
	movea.l	samp1(pc),a6
	moveq	#0,d3
	REPT LEN
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	ENDR
	cmp.l	wiz2len(pc),d0
	blt.s	.ok2
	sub.w	wiz2rpt(pc),d0
.ok2	move.w	d0,wiz2pos
	move.w	d1,wiz2frc
	cmp.l	wiz3len(pc),d4
	blt.s	.ok3
	sub.w	wiz3rpt(pc),d4
.ok3	move.w	d4,wiz3pos
	move.w	d5,wiz3frc
	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq	#0,d0
	moveq	#0,d4
v2	movea.l	wiz1lc(pc),a0
	move.w	wiz1pos(pc),d0
	move.w	wiz1frc(pc),d1
	move.w	aud1per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2
	movea.w	2(a5,d7.w),a4
	move.w	aud1vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2
	movea.l	wiz4lc(pc),a1
	move.w	wiz4pos(pc),d4
	move.w	wiz4frc(pc),d5
	move.w	aud4per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5
	move.w	aud4vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3
	movea.l	samp1(pc),a6
	moveq	#0,d3
	REPT LEN
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	addq.w	#2,a6
	ENDR
	cmp.l	wiz1len(pc),d0
	blt.s	.ok1
	sub.w	wiz1rpt(pc),d0
.ok1	move.w	d0,wiz1pos
	move.w	d1,wiz1frc
	cmp.l	wiz4len(pc),d4
	blt.s	.ok4
	sub.w	wiz4rpt(pc),d4
.ok4	move.w	d4,wiz4pos
	move.w	d5,wiz4frc
	movem.l	(sp)+,d0-a6
	rte
count1	DC.W PARTS
wiz1lc	DC.L sample1
wiz1len	DC.L 0
wiz1rpt	DC.W 0
wiz1pos	DC.W 0
wiz1frc	DC.W 0
wiz2lc	DC.L sample1
wiz2len	DC.L 0
wiz2rpt	DC.W 0
wiz2pos	DC.W 0
wiz2frc	DC.W 0
wiz3lc	DC.L sample1
wiz3len	DC.L 0
wiz3rpt	DC.W 0
wiz3pos	DC.W 0
wiz3frc	DC.W 0
wiz4lc	DC.L sample1
wiz4len	DC.L 0
wiz4rpt	DC.W 0
wiz4pos	DC.W 0
wiz4frc	DC.W 0
aud1lc	DC.L dummy
aud1len	DC.W 0
aud1per	DC.W 0
aud1vol	DC.W 0
	DS.W 3
aud2lc	DC.L dummy
aud2len	DC.W 0
aud2per	DC.W 0
aud2vol	DC.W 0
	DS.W 3
aud3lc	DC.L dummy
aud3len	DC.W 0
aud3per	DC.W 0
aud3vol	DC.W 0
	DS.W 3
aud4lc	DC.L dummy
aud4len	DC.W 0
aud4per	DC.W 0
aud4vol	DC.W 0
dmactrl	DC.W 0
dummy	DC.L 0
samp1	DC.L sample1
samp2	DC.L sample2
sample1	DS.W LEN
sample2	DS.W LEN

prepare	lea	workspc,a6
	movea.l	samplestarts(pc),a0
	movea.l	end_of_samples(pc),a1
tostack	move.w	-(a1),-(a6)
	cmpa.l	a0,a1			
	bgt.s	tostack
	lea	samplestarts(pc),a2
	lea	data1(pc),a1		
	movea.l	(a2),a0			
	movea.l	a0,a5			
	moveq	#30,d7
roop	move.l	a0,(a2)+		
	tst.w	$2A(a1)
	beq.s	samplok			
	tst.w	$2E(a1)			
	bne.s	repne			
repeq	move.w	$2A(a1),d0		
	move.w	d0,d4
	subq.w	#1,d0
	movea.l	a0,a4
fromstk	move.w	(a6)+,(a0)+		
	dbra	d0,fromstk
	bra.s	rep
repne	move.w	$2E(a1),d0
	move.w	d0,d4
	subq.w	#1,d0
	movea.l	a6,a4
get1st	move.w	(a4)+,(a0)+		
	dbra	d0,get1st
	adda.w	$2A(a1),a6		
	adda.w	$2A(a1),a6
rep	movea.l	a0,a5
	moveq	#0,d1
toosmal	movea.l	a4,a3
	move.w	$30(a1),d0
	subq.w	#1,d0
moverep	move.w	(a3)+,(a0)+		
	addq.w	#2,d1
	dbra	d0,moverep
	cmp.w	#320,d1			
	blt.s	toosmal
	move.w	#320/2-1,d2
last320	move.w	(a5)+,(a0)+		
	dbra	d2,last320
done	add.w	d4,d4
	move.w	d4,$2A(a1)		
	move.w	d1,$30(a1)		
	clr.w	$2E(a1)
samplok	lea	$1E(a1),a1
	dbra	d7,roop
	cmp.l	#workspc,a0
	bgt.s	.nospac
	rts
.nospac	illegal
end_of_samples	DC.L 0
init	lea	data1(pc),a0
	lea	$03B8(a0),a1
	moveq	#$7F,d0
	moveq	#0,d1
loop	move.l	d1,d2
	subq.w	#1,d0
lop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	loop
	dbra	d0,lop2
	addq.b	#1,d2
	lea	samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$043C,d2
	add.l	a0,d2
	movea.l	d2,a2
	moveq	#$1E,d0
lop3	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	add.l	d1,d1
	adda.l	d1,a2
	adda.l	#$1E,a0
	dbra	d0,lop3
	move.l	a2,end_of_samples	
	rts
music	lea	data1(pc),a0
	addq.w	#$01,counter
	move.w	counter(pc),d0
	cmp.w	speed(pc),d0
	blt.s	nonew
	clr.w	counter
	bra	getnew
nonew	lea	voice1(pc),a4
	lea	aud1lc(pc),a3
	bsr	checkcom
	lea	voice2(pc),a4
	lea	aud2lc(pc),a3
	bsr	checkcom
	lea	voice3(pc),a4
	lea	aud3lc(pc),a3
	bsr	checkcom
	lea	voice4(pc),a4
	lea	aud4lc(pc),a3
	bsr	checkcom
	bra	endr
arpeggio
	moveq	#0,d0
	move.w	counter(pc),d0
	divs	#$03,d0
	swap	d0
	tst.w	d0
	beq.s	arp2
	cmp.w	#$02,d0
	beq.s	arp1
	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	bra.s	arp3
arp1	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	bra.s	arp3
arp2	move.w	$10(a4),d2
	bra.s	arp4
arp3	add.w	d0,d0
	moveq	#0,d1
	move.w	$10(a4),d1
	lea	periods(pc),a0
	moveq	#$24,d4
arploop	move.w	0(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	arp4
	addq.l	#2,a0
	dbra	d4,arploop
	rts
arp4	move.w	d2,$06(a3)
	rts
getnew	lea	data1+$043C(pc),a0
	lea	-$043C+$0C(a0),a2
	lea	-$043C+$03B8(a0),a1
	moveq	#0,d0
	move.l	d0,d1
	move.b	songpos(pc),d0
	move.b	0(a1,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	pattpos(pc),d1
	clr.w	dmacon
	lea	aud1lc(pc),a3
	lea	voice1(pc),a4
	bsr.s	playvoice
	lea	aud2lc(pc),a3
	lea	voice2(pc),a4
	bsr.s	playvoice
	lea	aud3lc(pc),a3
	lea	voice3(pc),a4
	bsr.s	playvoice
	lea	aud4lc(pc),a3
	lea	voice4(pc),a4
	bsr.s	playvoice
	bra	setdma
playvoice
	move.l	0(a0,d1.l),(a4)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$02(a4),d2
	and.b	#$F0,d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$F0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	setregs
	moveq	#0,d3
	lea	samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$01,d2
	asl.l	#2,d2
	mulu	#$1E,d4
	move.l	0(a1,d2.l),$04(a4)
	move.w	0(a2,d4.l),$08(a4)
	move.w	$02(a2,d4.l),$12(a4)
	move.w	$04(a2,d4.l),d3
	tst.w	d3
	beq.s	noloop
	move.l	$04(a4),d2
	add.w	d3,d3
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$04(a2,d4.l),d0
	add.w	$06(a2,d4.l),d0
	move.w	d0,8(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
	bra.s	setregs
noloop	move.l	$04(a4),d2
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
setregs	move.w	(a4),d0
	and.w	#$0FFF,d0
	beq	checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$03,d0
	bne.s	setperiod
	bsr	setmyport
	bra	checkcom2
setperiod
	move.w	(a4),$10(a4)
	andi.w	#$0FFF,$10(a4)
	move.w	$14(a4),d0
	move.w	d0,dmactrl
	clr.b	$1B(a4)
	move.l	$04(a4),(a3)
	move.w	$08(a4),$04(a3)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	move.w	$14(a4),d0
	or.w	d0,dmacon
	bra	checkcom2
setdma	move.w	dmacon(pc),d0
	btst	#0,d0			
	beq.s	wz_nch1			
	move.l	aud1lc(pc),wiz1lc	
	moveq	#0,d1			
	moveq	#0,d2			
	move.w	aud1len(pc),d1		
	move.w	voice1+$0E(pc),d2	
	add.l	d2,d1			
	move.l	d1,wiz1len		
	move.w	d2,wiz1rpt		
	clr.w	wiz1pos			
wz_nch1	btst	#1,d0			
	beq.s	wz_nch2			
	move.l	aud2lc(pc),wiz2lc	
	moveq	#0,d1			
	moveq	#0,d2			
	move.w	aud2len(pc),d1		
	move.w	voice2+$0E(pc),d2	
	add.l	d2,d1			
	move.l	d1,wiz2len		
	move.w	d2,wiz2rpt		
	clr.w	wiz2pos			
wz_nch2	btst	#2,d0			
	beq.s	wz_nch3			
	move.l	aud3lc(pc),wiz3lc	
	moveq	#0,d1			
	moveq	#0,d2			
	move.w	aud3len(pc),d1		
	move.w	voice3+$0E(pc),d2	
	add.l	d2,d1			
	move.l	d1,wiz3len		
	move.w	d2,wiz3rpt		
	clr.w	wiz3pos			
wz_nch3	btst	#3,d0			
	beq.s	wz_nch4			
	move.l	aud4lc(pc),wiz4lc	
	moveq	#0,d1			
	moveq	#0,d2			
	move.w	aud4len(pc),d1		
	move.w	voice4+$0E(pc),d2	
	add.l	d2,d1			
	move.l	d1,wiz4len		
	move.w	d2,wiz4rpt		
	clr.w	wiz4pos			
wz_nch4	addi.w	#$10,pattpos
	cmpi.w	#$0400,pattpos
	bne.s	endr
nex	clr.w	pattpos
	clr.b	break
	addq.b	#1,songpos
	andi.b	#$7F,songpos
	move.b	songpos(pc),d1
	cmp.b	data1+$03B6(pc),d1
	bne.s	endr
	move.b	data1+$03B7(pc),songpos
endr:	tst.b	break
	bne.s	nex
	rts
setmyport
	move.w	(a4),d2
	and.w	#$0FFF,d2
	move.w	d2,$18(a4)
	move.w	$10(a4),d0
	clr.b	$16(a4)
	cmp.w	d0,d2
	beq.s	clrport
	bge.s	rt
	move.b	#$01,$16(a4)
	rts

clrport	clr.w	$18(a4)
rt	rts
myport	move.b	$03(a4),d0
	beq.s	myslide
	move.b	d0,$17(a4)
	clr.b	$03(a4)
myslide	tst.w	$18(a4)
	beq.s	rt
	moveq	#0,d0
	move.b	$17(a4),d0
	tst.b	$16(a4)
	bne.s	mysub
	add.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)
myok	move.w	$10(a4),$06(a3)
	rts
mysub	sub.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	blt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)
	move.w	$10(a4),$06(a3)
	rts
vib	move.b	$03(a4),d0
	beq.s	vi
	move.b	d0,$1A(a4)
vi	move.b	$1B(a4),d0
	lea	sin(pc),a1
	lsr.w	#$02,d0
	and.w	#$1F,d0
	moveq	#0,d2
	move.b	0(a1,d0.w),d2
	move.b	$1A(a4),d0
	and.w	#$0F,d0
	mulu	d0,d2
	lsr.w	#$06,d2
	move.w	$10(a4),d0
	tst.b	$1B(a4)
	bmi.s	vibmin
	add.w	d2,d0
	bra.s	vib2
vibmin	sub.w	d2,d0
vib2	move.w	d0,$06(a3)
	move.b	$1A(a4),d0
	lsr.w	#$02,d0
	and.w	#$3C,d0
	add.b	d0,$1B(a4)
	rts
nop:	move.w	$10(a4),$06(a3)
	rts
checkcom
	move.w	$02(a4),d0
	and.w	#$0FFF,d0
	beq.s	nop
	move.b	$02(a4),d0
	and.b	#$0F,d0
	tst.b	d0
	beq	arpeggio
	cmp.b	#$01,d0
	beq.s	portup
	cmp.b	#$02,d0
	beq	portdown
	cmp.b	#$03,d0
	beq	myport
	cmp.b	#$04,d0
	beq	vib
	cmp.b	#$05,d0
	beq	port_toneslide
	cmp.b	#$06,d0
	beq	vib_toneslide
	move.w	$10(a4),$06(a3)
	cmp.b	#$0A,d0
	beq.s	volslide
	rts
volslide
	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	voldown
	add.w	d0,$12(a4)
	cmpi.w	#$40,$12(a4)
	bmi.s	vol2
	move.w	#$40,$12(a4)
vol2	move.w	$12(a4),$08(a3)
	rts
voldown	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	sub.w	d0,$12(a4)
	bpl.s	vol3
	clr.w	$12(a4)
vol3	move.w	$12(a4),$08(a3)
	rts
portup	moveq	#0,d0
	move.b	$03(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$71,d0
	bpl.s	por2
	andi.w	#$F000,$10(a4)
	ori.w	#$71,$10(a4)
por2	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts
port_toneslide
	bsr	myslide
	bra.s	volslide
vib_toneslide
	bsr	vi
	bra.s	volslide
portdown
	clr.w	d0
	move.b	$03(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$0358,d0
	bmi.s	por3
	andi.w	#$F000,$10(a4)
	ori.w	#$0358,$10(a4)
por3	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts
checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$0D,d0
	beq.s	pattbreak
	cmp.b	#$0B,d0
	beq.s	posjmp
	cmp.b	#$0C,d0
	beq.s	setvol
	cmp.b	#$0F,d0
	beq.s	setspeed
	rts
pattbreak
	st	break
	rts
posjmp	move.b	$03(a4),d0
	subq.b	#$01,d0
	move.b	d0,songpos
	st	break
	rts
setvol	moveq	#0,d0
	move.b	$03(a4),d0
	cmp.w	#$40,d0
	ble.s	vol4
	move.b	#$40,$03(a4)
vol4	move.b	$03(a4),$09(a3)
	move.b	$03(a4),$13(a4)
	rts
setspeed
	cmpi.b	#$1F,$03(a4)
	ble.s	sets
	move.b	#$1F,$03(a4)
sets	move.b	$03(a4),d0
	beq.s	rts2
	move.w	d0,speed
	clr.w	counter
rts2	rts
sin	DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18

periods	DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
	DC.W $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$FE
	DC.W $F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F,$87
	DC.W $7F,$78,$71,$00,$00

speed	DC.W $06
counter	DC.W $00
songpos	DC.B $00
break	DC.B $00
pattpos	DC.W $00

dmacon		DC.W $00
samplestarts	DS.L $1F

voice1	DS.W 10
	DC.W $01
	DS.W 3
voice2	DS.W 10
	DC.W $02
	DS.W 3
voice3	DS.W 10
	DC.W $04
	DS.W 3
voice4	DS.W 10
	DC.W $08
	DS.W 3

data1:	INCBIN 	EXECZZ.MOD		; ITS THE MODULE!
	DS.B	16384			; Module's buffer size
workspc	DS.W	1
	
	section	data
music2	incbin	hb1.mus			; Soundchip Muzak
screen	incbin	pictures.pi1\toilet26.pi1	; Degas Picture
savpal	ds.w	16
fbuff	ds.b	16
count	ds.b	1
lcurr	dc.w	0
pixels	dc.w	0
	even
text
	DC.B	"            YO MIKEY!       HERE'S THE CODE I PROMISED...."
	DC.B	"  I HOPE THAT YOU CAN MAKE SOME USE OF IT.      BYE!    "
	DC.B	"                              "
	DC.B	$FF
	ds.l      200
ustk	ds.l	1	
font	incbin	font16.tbe		; The scroll font
	even
key	dc.w	0
	section	bss
buffer	ds.w	64

