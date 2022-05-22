sqsz	equ	257
Fuzz	equ	0	;Fuzz ratio ( 0..prime)
H	equ	4	;max. height differential for corners..
elev	equ	4000	;offset (random doesn't like zero)
sealev	equ	3980	;sea level
start	equ	122	;seed value/number of piccys.. ( <prime)
ht1	equ	5	;these are offsets from sea-level
ht2	equ	10
ht3	equ	15
ht4	equ	20
ht5	equ	25
ht6	equ	30
ht7	equ	35
ht8	equ	40
ht9	equ	45
ht10	equ	50
ht11	equ	55
ht12	equ	60
ht13	equ	70
ht14	equ	80
;shift	equ	2	;2 = 1 col for 4 grades.. (0..8 only)
empty	equ	-$1234
;###########################
sqrnd	macro
        jsr     gaddr
        move.w	#H,d0
        jsr	rand
        sub.w	#H/2,d0
        add.w   #elev,d0
        move.w  d0,(a0)
	endm        
;########################### CONTROL PROGRAM..
		dc.w	$a00a	;turn mouse off
tosuper         clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.w  #6,SP
                move.l  D0,oldsp
;###########################
                movea.l $44e,A0
                move.l	a0,scrn
                move.w  #1999,D0
                moveq   #0,D1
clean:          move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                dbra    D0,clean

                move.w  #37,-(SP)	;vblank..
                trap    #14
                addq.w  #2,SP
                clr.b   $FFFF8260.w	;lo resolution
                lea     $FFFF8240.w,A0
                move.w  #$0,(A0)+      ; 0
                move.w  #$020,(A0)+    ; 1
                move.w  #$030,(A0)+    ; 2
                move.w  #$050,(A0)+    ; 3
	        move.w  #$070,(A0)+    ; 4
                move.w  #$370,(A0)+    ; 5
                move.w  #$770,(A0)+    ; 6
                move.w	#$773,(a0)+
                move.w  #$662,(A0)+    ; 7
                move.w  #$542,(A0)+    ; 8
		move.w	#$342,(a0)+    ; 9
                move.w  #$333,(A0)+    ; 10
                move.w  #$444,(A0)+    ; 11	
                move.w  #$555,(A0)+    ; 13	
                move.w  #$777,(A0)+    ; 14	
                move.w  #$025,(A0)+    ; 15	

;###########################
	move.w	#start,d7
mnlp	move.w	d7,-(sp)
	ext.l	d7
	move.l	d7,seed
	jsr	fractal
        jsr     drawit
        move.w	(sp)+,d7
        move.w	#$00ff,-(sp)
        move.w	#6,-(sp)
        trap	#1
        addq	#4,sp
        tst.w	d0
        bne	quit
        dbra	d7,mnlp
;############################
quit:

flush:          btst    #0,$FFFFFC00.w
                beq.s   fl_done
                move.b  $FFFFFC02.w,D0
                bra.s   flush
fl_done:
		move.w	#7,-(sp)
		trap	#1
		addq	#2,sp


                move.w  #$00,$FFFF8240.w
                move.w  #$47,$FFFF8242.w
                move.w  #$47,$FFFF8244.w
                move.w  #$77,$FFFF8246.w

                move.l  oldsp(PC),-(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.w  #6,SP

		dc.w	$a009	;turn mouse on..
                clr.w   -(SP)
                trap    #1
;############################
fractal
        move.w   #sqsz-1,d4	;set x to max-1 for dbra
frlp    move.w   #sqsz-1,d5	;same for y
frlq    jsr      gaddr  	;get the address
        move.w	 #empty,(a0)	;reset this cell
        dbra     d5,frlq
        dbra     d4,frlp	;..etc for entire grid..
;###
        clr.w    d4		;
        clr.w    d5		;one corner..
	sqrnd
        move.w   #sqsz-1,d5
        sqrnd
        move.w   d5,d4
        sqrnd
        clr.w    d5
	sqrnd
;now four corners are set
	move.w	 #sqsz-1,d3	;length is set 
        clr.w    d1
        clr.w    d2		;set to 0,0
;###############################
recurse ;3 inputs- d1,d2,d3     ;d4/d5 used to access array.
        movem.w d1-d3,-(sp)     ;d1=x, d2=y
        cmp.w   #1,d3		;this is dropout..
        ble     rex
        move.w  d3,d7           ;d7 = distance
        lsr.w   #1,d3           ;d3 = half-dist
s1
        move.w  d3,d4
        clr.w   d5
        jsr     bit
        cmp.w	#empty,(a0)
        bne.s   s2
        move.l  a0,a1
        move.w  d1,d4
        move.w  d2,d5
        jsr     gaddr
        move.w  (a0),d6
        move.w  d7,d4
        clr.w   d5
        jsr     adran
s2        
        clr.w   d4
        move.w  d3,d5
        jsr     bit
        cmp.w	#empty,(a0)
        bne.s   s3
        move.l  a0,a1
        move.w  d1,d4
        move.w  d2,d5
        jsr     gaddr
        move.w  (a0),d6
        clr.w   d4
        move.w  d7,d5
        jsr     adran
s3
        move.w   d3,d4
        move.w   d7,d5
        jsr      bit
        cmp.w	 #empty,(a0)
        bne.s   s4
        move.l  a0,a1
        clr.w   d4
        move.w  d7,d5
        jsr     bit
        move.w  (a0),d6
        move.w   d7,d4 
        move.w   d7,d5
        jsr     adran
s4
       move.w   d7,d4
        move.w   d3,d5
        jsr     bit
        cmp.w	#empty,(a0)
        bne.s   sx
        move.l  a0,a1
        move.w  d7,d4
        clr.w   d5
        jsr     bit
        move.w  (a0),d6
        move.w   d7,d4 
        move.w   d7,d5
        jsr     adran
sx
       clr.w   d4
        move.w  d3,d5
        jsr     bit
        move.w  (a0),d6
        move.w  d7,d4
        move.w  d3,d5
        jsr     bit
        add.w   (a0),d6
        move.w  d3,d4
        clr.w   d5
        jsr     bit
        add.w   (a0),d6
        move.w  d3,d4
        move.w  d7,d5
        jsr     bit
        add.w   (a0),d6
        lsr.w   #2,d6
        move.w  d3,d4
        move.w  d3,d5
        jsr     bit
        move.l  a0,a1
        jsr     adres
;#########################
        bsr     recurse
        add.w   d3,d1
        bsr     recurse
        add.w   d3,d2
        bsr     recurse
        sub.w   d3,d1
        bsr     recurse 
;#########################
rex     movem.w (sp)+,d1-d3
        rts
;################################
adran   jsr     bit
        add.w   (a0),d6
        lsr.w   #1,d6		        ;average of two midpoints..
;##### below = rnd(halfd)-halfd/2
adres   
	move.w  d3,d0		;put 1/2d into d0
        move.w  d3,d4
        lsr.w   #1,d4
        jsr	rand
        sub.w   d4,d0
        add.w   d0,d6

	ifne	Fuzz
	move.w	#Fuzz,d0
	jsr	rand
	sub.w	#Fuzz/2,d0		;for good measure
	add.w	d0,d6			;Fuzz alters the D somehow..
	endc

        move.w  d6,(a1)
        rts
;####################################
bit     add.w   d1,d4
        add.w   d2,d5
        jmp     gaddr
;#####################################
drawit  
        move.w  #196,d5 ;y-count 
slp     move.w  #sqsz-2,d4 ;x-count 
tlp
        jsr     colour
        move.w	d4,d6
        move.w	d5,d7
	add.w	#33,d4
	add.w	#1,d5	;screen offsets..
;do plot routine..	
	move.l	scrn(pc),a0
	lsl.w	#5,d5	
	move.w	d5,d1
	lsl.w	#2,d5	
	add.w	d1,d5	;*160 altogether..
	lea	0(a0,d5.w),a0	;y offset..
	move.w	d4,d5		;save	lobits..
	and.w	#$fff0,d5
	asr.w	#1,d5
	lea	0(a0,d5.w),a0	;x offset +8 (for -(a0) later)
 	and.w	#15,d4
	eor.w	#15,d4		;the pixel        
	moveq	#0,d5
	bset	d4,d5		;this is 000010000 etc
	swap	d5
	bset	d4,d5		;in long now
	or.l	d5,0(a0)	;place pixel
	or.l	d5,4(a0)	;in all planes..
	not.w	d5
;	my idea haha..
pl1	
	btst	#0,d0
	bne.s	pl2	
	and.w	d5,0(a0)
pl2	
	btst	#1,d0
	bne.s	pl3	
	and.w	d5,2(a0)
pl3	
	btst	#2,d0
	bne.s	pl4	
	and.w	d5,4(a0)
pl4	
	btst	#3,d0
	bne.s	pldun	
	and.w	d5,6(a0)
pldun	
;my idea done..
        move.w	d6,d4
        move.w	d7,d5
        dbra    d4,tlp
        dbra    d5,slp
        rts
;###################################
colour  movem.l     d4-d5,-(sp)		;D4,D5 Points to relevant square
	addq	#1,d4
	addq	#1,d5	  ;because of dbra..
        jsr     gaddr      ;d4,d5	;get the address in a0
        move.w  (a0),d0
	moveq	#1,d1
	subq    #1,d4
	blt.s	offsc    
	jsr	gaddr
	move.w	(a0),d1
	cmp.w	d1,d0
	bge.s	offsc
	clr.w	d1	;needs a shade
offsc   sub.w	#sealev-1,d0 
        bge.s	nundr
        move.w	#15,d0
	move.w	#1,d1	;can't shade the sea!!
        bra	cdunn
nundr	
nh1	cmp.w	#ht1,d0
	bgt.s	nh2
	move.w	#1,d0
	bra	cdunn
nh2	
	cmp.w	#ht2,d0
	bgt.s	nh3
	move.w	#2,d0
	bra	cdunn
nh3	
	cmp.w	#ht3,d0
	bgt.s	nh4
	move.w	#3,d0
	bra	cdunn
nh4	
	cmp.w	#ht4,d0
	bgt.s	nh5
	move.w	#4,d0
	bra.s	cdunn
nh5	
	cmp.w	#ht5,d0
	bgt.s	nh6
	move.w	#5,d0
	bra.s	cdunn
nh6	
	cmp.w	#ht6,d0
	bgt.s	nh7
	move.w	#6,d0
	bra.s	cdunn
nh7	
	cmp.w	#ht7,d0
	bgt.s	nh8
	move.w	#7,d0
	bra.s	cdunn
nh8	
	cmp.w	#ht8,d0
	bgt.s	nh9
	move.w	#8,d0
	bra.s	cdunn
nh9	
	cmp.w	#ht9,d0
	bgt.s	nh10
	move.w	#9,d0
	bra.s	cdunn
nh10	
	cmp.w	#ht10,d0
	bgt.s	nh11
	move.w	#10,d0
	bra.s	cdunn
nh11	
	cmp.w	#ht11,d0
	bgt.s	nh12
	move.w	#11,d0
	bra.s	cdunn
nh12	
	cmp.w	#ht12,d0
	bgt.s	nh13
	move.w	#12,d0
	bra.s	cdunn
nh13	
	cmp.w	#ht13,d0
	bgt.s	nh14
	move.w	#13,d0
	bra.s	cdunn
nh14	move.w	#14,d0
	bra.s	cdunn
outb	moveq	#1,d0
cdunn   tst.w	d1
	bne.s	nosh
	lea	shades,a0
	add.w	d0,d0
	move.w	0(a0,d0.w),d0
nosh	movem.l (sp)+,d4-d5        
        rts
;####################################
colsort
        jsr     gaddr
        clr.w   d0
        move.w  (a0),d0
        add.w   d0,d3
col2    rts
;####################################
gaddr  ;input  d4=x,d5=y    -must be < sqsz+1  (0-sqsz
       ;output a0, all preserved.
     and.l	#$ffff,d5
     move.w     d0,-(sp)
     lea	sq(pc),a0
     move.l	d5,d0
     add.l	d0,d0
     lsl.l	#8,d0
     add.l	d5,d0
     add.l	d5,d0		;257
     lea	0(a0,d0.l),a0
     moveq	#0,d0
     move.w	d4,d0
     add.l	d0,d0
     lea	0(a0,d0.l),a0	;x-pos
     move.w    (sp)+,d0
     rts     
;########################################
rand    ;input d0, output d0, uses data: prime,seed
        movem.l d1-d7/a0,-(sp)  ;save registers
        move.l  prime,d2        ;prime is a prime number (10037) in D2
        move.l  d2,d4           ;put prime into user register       D4
        and.l   #$ffff,d0       ;cut max. down to one word.         D0
        move.l  d0,d1           ;put max into user                  ..
        add.w   #1,d1           ;D1 is Max+1                        ..
        tst.w   d1              ;If this is zero, then exit         ..
        beq.s   xit             
        divu    d1,d4           ;Prime/(Max+1)                      D4
        swap    d4              ;Prime MOD (Max+1)                  ..
        and.l   #$ffff,d4       ;rubbish the division bit           ..
        move.l  d2,d3
        sub.l   d4,d3           ;Limit:= Prime-(Prime MOD (max+1))  D3
        move.l  seed,d4         ;Get seed into D4                   D4
lp1     move.w  #6,d7           ;Put count into D7                  D7
lp2     lsl.l   #1,d4           ;Seed:=Seed*2                       D4
        cmp.l   d4,d2           ;If (Prime-Seed) 
        bge.s   ok              ;               >= Zero  THEN branch
        sub.l   d2,d4           ;       ELSE Seed:=Seed-Prime       D4
ok      dbra    d7,lp2          ;loop D7                            D7
        cmp.l   d4,d3           ;IF (Limit-Seed)                    D3
        blt.s   lp1             ;               < zero Then again   
        lea     seed,a0         ;Save Seed                          A0
        move.l  d4,(a0)         ;                                   D4
        divu    d1,d4           ;seed:= seed/(max+1)
        swap    d4              ;Seed:= seed MOD (max+1)
        move.w  d4,d0
xit     movem.l (sp)+,d1-d7/a0
        rts
;###############################
seed    dc.l    start
prime   dc.l    10037
shades	dc.w	0,0,1,2,3,4,5,8
	dc.w	9,10,2,15,11,12,13,15
;########################################
	section	BSS
scrn	ds.l	1
oldsp	ds.l	1
sq      ds.w    (sqsz+1)*(sqsz+1)         ;note WORD size..
;#########################################
        end
