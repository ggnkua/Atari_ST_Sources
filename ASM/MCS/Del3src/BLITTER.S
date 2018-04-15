	* My First BOBs   demo    By Axel F.
	* Move the mouse
	* If you want a picture behind the bobs
	* remove all => ;

	*			Axel F.	24/5/90

		opt d+
start:
	move.l #$f7000,-(sp)
	move.w #$20,-(sp)
	trap #01
	lea 4(sp),sp	
	DC.W	$A00A
	bclr.b #0,$484
	move.w #2,-(a7)
	trap #14
	addq.l #2,a7
	move.l d0,ecran
	move.w #0,-(a7)
	move.l #$f8000,-(a7)
	move.l #$f8000,-(a7)
	move.w #5,-(a7)
	trap #14
	add.l #12,a7
	lea	palette,a0
	lea	$ff8240,a1
	rept 8
	move.l (a0)+,(a1)+
	endr
	bsr blit_it
	MOVE.W X2S,XS
	MOVE.W Y2S,YS
	MOVE.L	#FOND2,DEST
	bsr blit_it
	MOVE.L	#FOND3,DEST
	bsr blit_it
	MOVE.L	#FOND4,DEST
	bsr blit_it
	MOVE.L	#FOND5,DEST
	bsr blit_it
	MOVE.L	#FOND6,DEST
	bsr blit_it
	
	move.l	#prog,$4d2
cont	nop
	tst.w KM
	beq cont
	move.l	#0,$4d2
	dc.w $A009
	clr.w -(a7)
	trap #1

prog 	
	MOVE.W #$742,$FF8240
wait	
	MOVE.W	Y4S,D3
	MOVE.W	X4S,D2		
	LEA	FOND4,A1
	BSR	RESTITU
	MOVE.W	Y3S,D3
	MOVE.W	X3S,D2		
	LEA	FOND3,A1
	BSR	RESTITU		
	MOVE.W	Y2S,D3
	MOVE.W	X2S,D2		
	LEA	FOND2,A1
	BSR	RESTITU
	MOVE.W	Y1S,D3
	MOVE.W	X1S,D2		
	LEA	FOND1,A1
	BSR	RESTITU

	;MOVE.W	X4,D0
	;MOVE.W	Y4,D1		
	;LEA	FOND4,A1
	;BSR	SFOND
	;MOVE.W	X3,D0
	;MOVE.W	Y3,D1		
	;LEA	FOND3,A1
	;BSR	SFOND
	;MOVE.W	X2,D0
	;MOVE.W	Y2,D1		
	;LEA	FOND2,A1
	;BSR	SFOND
	;MOVE.W	X1,D0
	;MOVE.W	Y1,D1		
	;LEA	FOND1,A1
	;BSR	SFOND

	MOVE.W	X4,D0
	MOVE.W	Y4,D1
	MOVE.W	X4S,D2		
	MOVE.W	Y4S,D3
	LEA	FOND4,A1
	LEA	SPRITE,A0
	BSR	AFFSPRITE
	MOVE.W	X3,D0
	MOVE.W	Y3,D1
	MOVE.W	X3S,D2		
	MOVE.W	Y3S,D3
	LEA	FOND3,A1
	LEA	SPRITE,A0
	BSR	AFFSPRITE
	MOVE.W	X2,D0
	MOVE.W	Y2,D1
	MOVE.W	X2S,D2		
	MOVE.W	Y2S,D3
	LEA	FOND2,A1
	LEA	SPRITE,A0
	BSR	AFFSPRITE
	MOVE.W	X1,D0
	MOVE.W	Y1,D1	
	MOVE.W	X1S,D2
	MOVE.W	Y1S,D3	
	LEA	SPRITE,A0
	LEA	FOND1,A1
	BSR	AFFSPRITE
	MOVE.W	X4,X4S
	MOVE.W	Y4,Y4S
	MOVE.W	X3,X3S
	MOVE.W	Y3,Y3S
	MOVE.W	X2,X2S
	MOVE.W	Y2,Y2S
	MOVE.W	X1,X1S
	MOVE.W	Y1,Y1S
	LEA	XX3,A0
	MOVE.W 18(A0),X4
	MOVE.W 16(A0),18(A0)
	MOVE.W 14(A0),16(A0)
	MOVE.W 12(A0),14(A0)
	MOVE.W 10(A0),12(A0)
	MOVE.W 8(A0),10(A0)
	MOVE.W 6(A0),8(A0)
	MOVE.W 4(A0),6(A0)
	MOVE.W 2(A0),4(A0)
	MOVE.W (A0),2(A0)
	LEA	YY3,A1
	MOVE.W 18(A1),Y4
	MOVE.W 16(A1),18(A1)
	MOVE.W 14(A1),16(A1)
	MOVE.W 12(A1),14(A1)
	MOVE.W 10(A1),12(A1)
	MOVE.W 8(A1),10(A1)
	MOVE.W 6(A1),8(A1)
	MOVE.W 4(A1),6(A1)
	MOVE.W 2(A1),4(A1)
	MOVE.W (A1),2(A1)
	MOVE.W	X3,(A0)
	MOVE.W	Y3,(A1)
	LEA	XX2,A0
	MOVE.W 18(A0),X3
	MOVE.W 16(A0),18(A0)
	MOVE.W 14(A0),16(A0)
	MOVE.W 12(A0),14(A0)
	MOVE.W 10(A0),12(A0)
	MOVE.W 8(A0),10(A0)
	MOVE.W 6(A0),8(A0)
	MOVE.W 4(A0),6(A0)
	MOVE.W 2(A0),4(A0)
	MOVE.W (A0),2(A0)
	LEA	YY2,A1
	MOVE.W 18(A1),Y3
	MOVE.W 16(A1),18(A1)
	MOVE.W 14(A1),16(A1)
	MOVE.W 12(A1),14(A1)
	MOVE.W 10(A1),12(A1)
	MOVE.W 8(A1),10(A1)
	MOVE.W 6(A1),8(A1)
	MOVE.W 4(A1),6(A1)
	MOVE.W 2(A1),4(A1)
	MOVE.W (A1),2(A1)
	MOVE.W	X2,(A0)
	MOVE.W	Y2,(A1)
	LEA	XX1,A0
	MOVE.W 18(A0),X2
	MOVE.W 16(A0),18(A0)
	MOVE.W 14(A0),16(A0)
	MOVE.W 12(A0),14(A0)
	MOVE.W 10(A0),12(A0)
	MOVE.W 8(A0),10(A0)
	MOVE.W 6(A0),8(A0)
	MOVE.W 4(A0),6(A0)
	MOVE.W 2(A0),4(A0)
	MOVE.W (A0),2(A0)
	LEA	YY1,A1
	MOVE.W 18(A1),Y2
	MOVE.W 16(A1),18(A1)
	MOVE.W 14(A1),16(A1)
	MOVE.W 12(A1),14(A1)
	MOVE.W 10(A1),12(A1)
	MOVE.W 8(A1),10(A1)
	MOVE.W 6(A1),8(A1)
	MOVE.W 4(A1),6(A1)
	MOVE.W 2(A1),4(A1)
	MOVE.W (A1),2(A1)
	MOVE.W	X1,(A0)
	MOVE.W	Y1,(A1)
SS	JSR	MOUSE
	JSR	TESTBORDS
	MOVE.W #0,$FF8240
	RTS
WW DC.W 0

AFFSPRITE
	MOVE.L	A0,SOURCE
	MOVE.W	#16,LS
	MOVE.W	#0,XS
	MOVE.W	#1,YS
	MOVE.L	img,DEST
	MOVE.W	#160,LD
	MOVE.W D0,XD
	MOVE.W D1,YD
	MOVE.B #6,FONC
	bsr blit_it
	rts
RESTITU
	MOVE.L A1,SOURCE
	MOVE.W	#16,LS
	MOVE.W	#0,XS
	MOVE.W	#0,YS
	MOVE.L	img,DEST
	MOVE.W	#160,LD
	MOVE.W	D2,XD
	MOVE.W	D3,YD
	MOVE.B #3,FONC
	bsr blit_it	
	RTS
SFOND	MOVE.L	img,SOURCE
	MOVE.W	#160,LS
	MOVE.W D0,XS
	MOVE.W	D1,YS
	MOVE.L	A1,DEST
	MOVE.W	#0,XD
	MOVE.W	#0,YD
	MOVE.W	#16,LD
	MOVE.B #3,FONC
	bsr blit_it
	RTS

MOUSE	LEA	$EA0,A0		;lecture coords
	CLR.W	D0
	CLR.W	D1
	CLR.W	D2
	MOVE.B	(A0),D0
	MOVE.B	1(A0),D1
	MOVE.B	2(A0),D2	
	CLR.B	1(A0)
	CLR.B	2(A0)
	SUB.W	#$F8,D0
	EXT	D1
	EXT	D2
	MOVE.W	D0,KM
	LSL	#1,D1
	LSL	#1,D2
	ADD.W	D1,X1
	ADD.W	D2,Y1
	RTS
TESTBORDS	MOVE.W	X1,D0
	CMP.W	#0,D0
	BGT	HORIZON
	CLR.W	D0
	BRA	SCRIN
HORIZON	CMP.W	#319-32,D0
	BLT	SCRIN
	MOVE.W	#319-31,D0
SCRIN	MOVE.W	D0,X1
	MOVE.W	Y1,D0
	CMP.W	#0,D0
	BGT	VERTIC
	CLR.W	D0
	BRA	SCRIN2
VERTIC	CMP.W	#200-32,D0
	BLT	SCRIN2
	MOVE.W	#200-31,D0
SCRIN2	MOVE.W	D0,Y1
	RTS
KM	DC.W 0
LOAD	;MOVE.W	#0,-(SP)
	;MOVE.L	#IMG,-(SP)
	;MOVE.W	#$3D,-(SP)
	;TRAP	#1
	;ADDQ.L	#8,SP

      
READ	;MOVE.W	D0,D3
	;MOVE.L	#$f8000-128,-(SP)
	;MOVE.L	#$fffff,-(SP)
	;MOVE.W	D3,-(SP)
	;MOVE.W	#$3F,-(SP)
	;TRAP	#1
	;ADDA.L	#12,SP

CLOSE	;MOVE.W	D3,-(SP)
	;MOVE.W	#$3E,-(SP)
	;TRAP	#1	
	;ADDQ.L	#4,SP
	;RTS
IMG 	DC.B 'IMAGE.NEO',0
	EVEN
BLITTER        equ       $FF8A00
demiteinte     equ       0         
Src_Xinc       equ       32        
Src_Yinc       equ       34        
Src_Addr       equ       36        
Endmask1       equ       40        
Endmask2       equ       42        
Endmask3       equ       44        
Dst_Xinc       equ       46        
Dst_Yinc       equ       48        
Dst_Addr       equ       50        
largeur        equ       54        
hauteur        equ       56        
HOP            equ       58        
OP             equ       59        
Line_Num       equ       60        
Oblique        equ       61        
fHOP_Source   	equ       1
fHOP_demiteinte  	equ       0
fObliqueFXSR      	equ       7
fObliqueNFSR      	equ       6
fLineBusy      	equ       7
fLineHog       	equ       6
fLineSmudge    	equ       5
mHOP_Source    	equ       $02
mHOP_demiteinte  	equ       $01
mObliqueFXSR      	equ       $80
mObliqueNFSR      	equ       $40
mLineBusy      	equ       $80
mLineHog       	equ       $40
mLineSmudge    	equ       $20
lf_endmask
     dc.w      $FFFF
rt_endmask
     dc.w      $7FFF,$3FFF,$1FFF,$0FFF,$07FF,$03FF,$01FF			
     dc.w      $00FF,$007F,$003F,$001F,$000F,$0007,$0003,$0001,0			
blit_it:
	movem.l a0-a6/d0-d7,-(a7)
     lea       BLITTER,a5       
     lea	 PARA,a4
     move.w    WIDTH(a4),d6
     subq.w    #1,d6            
     move.w    SRC_XMIN(a4),d0  
     move.w    d0,d1            
     add.w     d6,d1            
     move.w    DST_XMIN(a4),d2  
     move.w    d2,d3            
     add.w     d6,d3            
     moveq     #$0F,d6          
     move.w    d2,d4            
     and.w     d6,d4            
     add.w     d4,d4            
     move.w    lf_endmask(pc,d4.w),d4
     move.w    d3,d5            
     and.w     d6,d5            
     add.w     d5,d5            
     move.w    rt_endmask(pc,d5.w),d5
     not.w     d5               
     move.w    d2,d7            
     and.w     d6,d7            
     and.w     d0,d6            
     sub.w     d6,d7            
     clr.w     d6               
     addx.w    d6,d6            
     lsr.w     #4,d0            
     lsr.w     #4,d1            
     sub.w     d0,d1            
     lsr.w     #4,d2            
     lsr.w     #4,d3            
     sub.w     d2,d3            
     bne       set_endmasks     
     and.w     d5,d4            
     addq.w    #4,d6            
set_endmasks:
     move.w    d4,Endmask1(a5)  
     move.w    #$FFFF,Endmask2(a5)
     move.w    d5,Endmask3(a5)  
     cmp.w     d1,d3            
     bne       set_count        
     addq.w    #2,d6            
set_count:
     move.w    d3,d4
     addq.w    #1,d4            
     move.w    d4,largeur(a5)   
     move.l    SRC_BASE(a4),a0  
     move.w    SRC_YMIN(a4),d4  
     move.w    SRC_NXLN(a4),d5  
     mulu      d5,d4            
     add.l     d4,a0            
     move.w    SRC_NXWD(a4),d4  
     move.w    d4,Src_Xinc(a5)  
     mulu      d4,d0            
     add.l     d0,a0            
     mulu      d4,d1            
     sub.w     d1,d5            
     move.w    d5,Src_Yinc(a5)  
     move.l    DST_BASE(a4),a1  
     move.w    DST_YMIN(a4),d4  
     move.w    DST_NXLN(a4),d5  
     mulu      d5,d4            
     add.l     d4,a1            
     move.w    DST_NXWD(a4),d4  
     move.w    d4,Dst_Xinc(a5)  
     mulu      d4,d2            
     add.l     d2,a1            
     mulu      d4,d3            
     sub.w     d3,d5            
     move.w    d5,Dst_Yinc(a5)  
     and.b     #$0F,d7          	       
     or.b      Oblique_flags(pc,d6.w),d7  
     move.b    d7,Oblique(a5)      	
     move.b    #mHOP_Source,HOP(a5)	
     move.b	 FONC,d6
     move.b    d6,OP(a5)        		
     lea       Line_Num(a5),a2  		
     move.b    #6,d2    		;partage ou occupation du bus
     move.w    PLANES(a4),d7    		
     bra       begin
Oblique_flags:
     dc.b      mObliqueNFSR        
     dc.b      mObliqueFXSR        
     dc.b      0                   
     dc.b      mObliqueNFSR+mObliqueFXSR 
     dc.b      0                
     dc.b      mObliqueFXSR     
     dc.b      0                
     dc.b      0                
next_plane:
     move.l    a0,Src_Addr(a5)  		
     move.l    a1,Dst_Addr(a5)  		
     move.w    HEIGHT(a4),hauteur(a5)	
     move.b    #mLineBusy,(a2)  		
     add.w     SRC_NXPL(a4),a0  		
     add.w     DST_NXPL(a4),a1  		
restart:
     bset.b    d2,(a2)          
     nop                        
     bne       restart          
begin:
     dbra      d7,next_plane    
	movem.l (a7)+,a0-a6/d0-d7
     rts
ecran	dc.l 0
SPRITE	
	incbin	ball1.z
	even
SRC_BASE       equ       0
SRC_NXWD       equ       4
SRC_NXLN       equ       6
SRC_NXPL       equ       8
SRC_XMIN       equ      10
SRC_YMIN       equ      12
DST_BASE       equ      14
DST_NXWD       equ      18
DST_NXLN       equ      20
DST_NXPL       equ      22
DST_XMIN       equ      24
DST_YMIN       equ      26
WIDTH          equ      28
HEIGHT         equ      30
PLANES         equ      32
PARA	
SOURCE	dc.l	$f8000
	dc.w	8
LS	dc.w   160
	dc.w   2
XS	dc.w  	0
YS	dc.w	100

DEST	dc.l	FOND1
	dc.w	8
LD	dc.w	16
	dc.w	2
XD	dc.w	0
YD	dc.w	0

X	dc.w	32
Y	dc.w	29
PLAN	dc.w	3
FONC	dc.b	3
	even
FOND1	ds.l	512/4
FOND2	ds.l	512/4
FOND3	ds.l	512/4
FOND4	ds.l	512/4
FOND5	ds.l	512/4
FOND6	ds.l	512/4
MASK	ds.l	512/4
X1	DC.W	0
Y1	DC.W	100
X2	DC.W	0
Y2	DC.W	100
X3	DC.W	0
Y3	DC.W	100
X4	DC.W	0
Y4	DC.W	100
X5	DC.W	0
Y5	DC.W	100
X6	DC.W	0
Y6	DC.W	100
X1S	DC.W	0
Y1S	DC.W	100
X2S	DC.W	0
Y2S	DC.W	100
X3S	DC.W	0
Y3S	DC.W	100
X4S	DC.W	0
Y4S	DC.W	100
X5S	DC.W	0
Y5S	DC.W	100
X6S	DC.W	0
Y6S	DC.W	100

palette dc.w $0,$777,$666,$555,$444,$333,$222,$111,$766,$755,$643,$210,$020,$710,$140,$557
img	dc.l	$f8000
XX1	DC.W 0,0,0,0,0,0,0,0,0,0
YY1	DC.W 100,100,100,100,100,100,100,100,100,100
XX2	DC.W 0,0,0,0,0,0,0,0,0,0
YY2	DC.W 100,100,100,100,100,100,100,100,100,100
XX3	DC.W 0,0,0,0,0,0,0,0,0,0
YY3	DC.W 100,100,100,100,100,100,100,100,100,100
end