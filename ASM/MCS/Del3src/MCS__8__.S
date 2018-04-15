  
DEBUT:    
          clr.l   -(a7) 
          move.w  #$20,-(a7) ;Super   
          trap    #1 ;GEMDOS
          addq.l  #6,a7
          lea     $B7000,a7 
	
          move.b  #2,$FFFF820A          ; 50Hz
          dc.w    $A00A 
          move.b  #$12,$FFFC02

          lea     $FFFF8240,a1
          moveq   #7,d0 
ERASE:    clr.l   (a1)+ 
          dbf     d0,ERASE
	move.w #0,-(a7)
	move.l	SCREEN1,-(A7)
	move.l	SCREEN1,-(A7)
	MOVE.W	#5,-(A7)
	TRAP #14
	ADD.L #12,A7

 	  move.l  SCREEN1,d0 
          lsr.w   #8,d0 
          move.b  d0,$FFFF8203
          swap    d0
          move.b  d0,$FFFF8201
        bsr   errpic

          move    #$2700,sr 
          move.l  $70,OLD_70
          move.l  $118,OLD_118 
          move.b  $FFFA07,OLD_07
          move.b  $FFFA09,OLD_09
          clr.b   $FFFA07 
          clr.b   $FFFA09 
          move.l  #HBL_1,$118
;          bsr     PLAY_MUSIC
gizmo:
         move.l    #VBL_1,$70 
	  move	     #$2300,sr
KEY2	  cmp.b     #$39,$fffc02
	  beq	     FIN
	  cmp.w     #1,flag
	  bne       KEY2
	  move.l    #$ff8240+2,a0
	  clr.w	    (a0)+
key1	  cmp.b    #$39,$fffc02
	  beq	    FIN
	  cmp.w    #-1,flag
	  bne	    key1
FIN      move      #$2700,sr 
          clr.w     $FF820E 
          clr.w     $FF8264 
          clr.w     $FF820C 
          clr.l     $4D2
          move.l    OLD_70,$70
          move.l    OLD_118,$118 
          move.b    OLD_07,$FFFA07
          move.b    OLD_09,$FFFA09
          move      #$2300,sr
          lea       $FF8240,a1
          moveq     #7,d0 
;L10260    clr.l    (a0)+,(a1)+ 
          ;dbf       d0,L10260 
	move.w #0,-(a7)
	move.l	SCREEN1,-(A7)
	move.l	SCREEN1,-(A7)
	MOVE.W	#5,-(A7)
	TRAP #14
	ADD.L #12,A7
	   pea		txt
	   move.w #9,-(a7)
	   trap #1
	   add.l	#6,a7
          dc.w      $A009 
          move.b    #8,$FFFC02
          clr.l     -(a7) 
          trap      #1
txt	dc.b $1b,"E",$d,$a,$d,$a,$d,$a,$d,$a,$d,$a,$d,$a,$d,$a,$d,$a
	dc.b "               Please Load",$d,$a
	dc.b "               I'm Waiting",0
	even

OLD_07:     ds.b   1
OLD_09:     ds.b   1
key:        dc.b   0
flag:	    dc.w   0
handle:	    dc.w   0
plus_moins: dc.l 160
         even
;*************************************************

VBL_1:
	  movem.l   d0-d7/a0-a7,-(sp)
	  add.w     #1,timer
	  cmp.w     #5,timer
	  beq	     met_f_i
	  cmp.w     #10,timer
	  beq	     met_f_o
	  cmp.w     #11,timer
	  bne	     retour
	  move.w    #0,timer
	  cmp.l     #7*1760,compteur
	  beq	     end_vbl1
	  lea	     image,a0
	  add.l     compteur,a0
	  MOVE.L    SCREEN1,A1
	  ADD.l     #15200,a1
	  move.w    #799,d0
cop:	  move.w    (a0)+,(a1)+
	  dbf	     d0,cop
	  add.l     #11*160,compteur
retour:
	  movem.l   (sp)+,d0-d7/a0-a7
          rte
met_f_i:
	  move.l    #fade_in,$70
	  movem.l   (sp)+,d0-d7/a0-a7
          rte
met_f_o:	
	  move.l    #fade_out,$70
	  movem.l   (sp)+,d0-d7/a0-a7
          rte
fade_out:
	movem.l	d0-d7/a0-a7,-(sp)
	cmp.w	#32,f_o_c
	beq	ret_f_o
	add.w	#2,f_o_c
	lea	fade_out_colors,a0
	add.w	f_o_c,a0
	move.w	(a0),$ff8240+30
	movem.l	(sp)+,d0-d7/a0-a7
	rte
ret_f_o:
	move.w	#0,f_o_c
	move.l	#VBL_1,$70
	movem.l	(sp)+,d0-d7/a0-a7
	rte
fade_in:
	movem.l	d0-d7/a0-a7,-(sp)
	cmp.w	#32,f_i_c
	beq	ret_f_i
	add.w	#2,f_i_c
	lea	fade_in_colors,a0
	add.w	f_i_c,a0
	move.w	(a0),$ff8240+30
	movem.l	(sp)+,d0-d7/a0-a7
	rte
ret_f_i:
	move.w	#0,f_i_c
	move.l	#VBL_1,$70
	movem.l	(sp)+,d0-d7/a0-a7
	rte
end_vbl1:
;         lea	newslt+2,a0
;         lea     $FF8240,a1
;         moveq   #7,d0 
;MET_PAL2:move.l  (a0)+,(a1)+ 
;         dbf     d0,MET_PAL2
	lea	filename,a0
	move.l	SCREEN2,A1
	SUB.L	#34,A1
	MOVE.L	#32034/4,D0
COP	MOVE.L	(A0)+,(A1)+
	DBF	D0,COP

	  move.l  SCREEN2,d0 
          lsr.w   #8,d0 
          move.b  d0,$FFFF8203
          swap    d0
          move.b  d0,$FFFF8201

	 MOVE.L	SCREEN2,A0
         SUB.L	 #32,a0
         lea     $FF8240,a1
         moveq   #7,d0 
MET_PAL2:move.l  (a0)+,(a1)+ 
         dbf     d0,MET_PAL2
		
	  move.l 	#mouche,d0
	  LEA		$FF8901,A0
	  MOVEP.L	D0,(A0)
	  move.l     	#mouche_end,d0
	  MOVEP.L	D0,12(A0)
         move.w  #$54a,d0    ;faible volume
         bsr     PLAY_SAMP
         move.w  #$507,d0    
         bsr     PLAY_SAMP
         move.w  #$48c,d0    ;aigu maxi
         bsr     PLAY_SAMP
         move.w  #$44c,d0    ;grave maxi
         bsr     PLAY_SAMP
         move.w  #$82,$FFFF8920        
	  move.w  #3,$FFFF8900          
	  move.l	#mouche_vbl,$70
	  movem.l	(sp)+,d0-d7/a0-a7
          rte
   	  
mouche_vbl:
          movem.l	d0-d7/a0-a7,-(sp)
	  move.w	#1,flag
	  lea	old_tab,a0
	  move.l old_ad,a1
	  move.w (a0)+,(a1)+
	  move.w (a0)+,(a1)+
	  move.w (a0)+,(a1)+
	  move.w (a0),(a1)
	  cmp.l	#4280,pointeur
	  beq	met_bouge_o_vbl
	  lea	trajectoire,a0
	  add.l	pointeur,a0
	  cmp.w	#-1,(a0)
	  beq		clafin
	  move.l	SCREEN2,a1
	  add.w 	(a0)+,a1
	  move.l	a1,old_ad
	  lea		old_tab,a2
	  move.w	(a1)+,(a2)+
	  move.w	(a1)+,(a2)+
	  move.w	(a1)+,(a2)+
	  move.w	(a1),(a2)
	  sub.w	#6,a1
	  move.w	(a0),d0
	  or.w	d0,(a1)+
	  or.w	d0,(a1)+
	  or.w	d0,(a1)+
	  or.w	d0,(a1)
	  add.l	#8,pointeur
	  CMP.W	#1,NOSOUND
	  BEQ	ss
	  cmp.w 	#2,NOSOUND
	  beq	sf
	  cmp.w	#3,NOSOUND
	  beq	sf
	  move.l	16(a0),a1
	  move.l	(a0),a0
	  cmp.l	a0,a1
	  bne		ss
	  move.b  #0,$ffff8901
	  bra	sf
ss	  move.b  #3,$FFFF8901          
	  add.w	#1,grave
         cmp.w	#26,grave
	  bne		sf
	  move.w	#0,grave
	  lea		grtab,a0
	  add.w	#2,grav
	  add.w	grav,a0
	  cmp.l	#-1,(a0)
	  bne		sz
	  move.w	#0,grav
	  lea		grtab,a0
sz	  moveq	#0,d0
	  move.w	(a0),d0
	  bsr PLAY_SAMP
	  bra	sf
sr	  
	  move.w #3,NOSOUND 
clafin	  move.w #-1,flag     
sf       movem.l	(sp)+,d0-d7/a0-a7
          rte
NOSOUND	DC.W	0
grave		dc.w   0
grav		dc.w   0
grtab		dc.w $446,$446,$447,$448,$44b,$448,$447,$449,$44a,$44b,$44c
		dc.w $44b,$44a,$449,$442,$445,$446,$443,$447,$448,$447,$446
		dc.w -1
met_bouge_o_vbl:
	  add.l	#4,pointeur
	  move.l #bouge_o_vbl,$70
          bsr       CUT_MUSIC
	MOVE.W #1,NOSOUND
	  movem.l (sp)+,d0-d7/a0-a7
          rte
bouge_o_vbl:
	movem.l	d0-d7/a0-a7,-(sp)
	add.w	#1,count_o_o
	cmp.w	#2,count_o_o
	bne	ret_o_o
	move.w	#0,count_o_o
	lea	O2+34,a0
	add.l	#4,point_som
	lea	som_mvtb,a1
	add.l	point_som,a1
	cmp.l	#-1,(a1)
	bne	nosom
	move.l	#sanszo_vbl,$70
	bra ret_o_o
nosom	add.l	(a1),a0
	move.w	#95,d0
	MOVE.L	SCREEN2,A1
	add.l	#648,a1
met_o:  
	rept 12
	move.l	(a0)+,(a1)+
	endr
	add.l	#112,a0
	add.l	#112,a1
	dbf	d0,met_o		
ret_o_o:
	movem.l	(sp)+,d0-d7/a0-a7
	rte

sanszo_vbl:
	movem.l	d0-d7/a0-a7,-(sp)
	lea	sanszo_buff,a0
	move.l	SCREEN2,a1
	add.l	#648,a1
	move.w	#103,d0
sans_cop:
	rept 12
	move.l	(a0)+,(a1)+
	endr
	add.l	#112,a1
	dbf	d0,sans_cop
	move.l	#fall_o_vbl,$70
	movem.l	(sp)+,d0-d7/a0-a7
	rte 

fall_o_vbl:
	movem.l	d0-d7/a0-a7,-(sp)
;	restore  old 'O' underground
;	add.w	#1,count_fall2
;	cmp.w	#20,count_fall2
;	bne finix3
; 
;	move.w	#0,count_fall2

	lea	fall_buffer,a0
	move.l	(a0)+,a1
	move.w	#87,d0
retsto: rept 10
	move.l	(a0)+,(a1)+
	endr
	add.l	#120,a1
	dbf	d0,retsto	
;save and put new 'o'
	move.w	#87,d0
	MOVE.L	SCREEN2,A1
	ADD.l	#648,a1
	add.l	fall,a1
	add.l	#160*8,fall
	lea	fall_o_car,a0
	lea	fall_o_msk,a3
	lea	fall_buffer,a2
	move.l	a1,(a2)+	
met_fall_o:  
	rept 10
	move.l	(a1),(a2)+  ;save
	move.l	(a0)+,d1    ;put
	move.l	(a3)+,d2
	and.l	d2,(a1)
	or.l	d1,(a1)+
	endr
	add.l	#120,a1
	dbf	d0,met_fall_o			
put_s:  move.l	SCREEN2,A0
	add.l   #5*160,a0
	lea	S_FONT,A1
	lea     S_MASK,A2
	move.w	#90,d0
put_s_loop:
	rept 10
        move.l	(a2)+,d1 
	AND.L	d1,(A0)
	move.l	(a1)+,d1
	OR.l	d1,(a0)+
	endr
	add.l	#120,a0	 
	addq.l	#4,a1
	dbf	d0,put_s_loop
	
finix3:	add.w	#1,count_fall
	cmp.w	#50,count_fall
	bne	rte_fal
	  move.l  	#casse,d0
	  LEA		$FF8901,A0
	  MOVEP.L	D0,(A0)
	  move.l      #casse_end,d0
	  MOVEP.L	D0,12(A0)
         move.w  #$551,$FFFF8922     ;fort volume
         bsr     PLAY_SAMP
         move.w  #$511,$FFFF8922     
         bsr     PLAY_SAMP
         move.w  #$48c,$FFFF8922     ;aigu maxi
         bsr     PLAY_SAMP
         move.w  #$446,$FFFF8922     ;grave med
         bsr     PLAY_SAMP
         move.w  #$82,$FFFF8920        
	  move.w  #1,$FFFF8900          
	  move.w #2,NOSOUND
	move.l	#mouche_vbl,$70
	lea	old_tab,a0
	clr.l	(a0)+
	clr.l	(a0)
rte_fal:
	movem.l	(sp)+,d0-d7/a0-a7
	rte



HBL_1:
          bclr.b  #6,$FFFA11
          rte 
        even

fall:	dc.l	0
old_ad:	dc.l	$78000
old_tab:	ds.w	10
old_sr: dc.w    0
loupox: dc.w 37
count_fall:dc.w 0
count_fall2:dc.w 0
count_o:dc.w 0
count_o_o:dc.w	0
point_som:dc.l 0
som_mvtb:	 rept 3
		 dc.l 0,0,0,48,48,48,96,96,15360,15360,15408,15408
		 dc.l 15456,15456,15456,15408,15360,15360,96,96,48,48,48
	        endr
		 dc.l -1

S_BASE_HI:      DC.B 0
S_BASE_MID:     DC.B 0
S_BASE_LOW:     DC.B 0
f_o_c:	dc.w	0
f_i_c:	dc.w    0
        EVEN
scr_base:       dc.l    0
timer:	dc.w  0
compteur:	dc.l 0
pointeur:	dc.l 0
        even
;*************************************************

 
CUT_MUSIC:         clr.b   $FF8901               ; CUT OFF DMA SOUND
                   rts 

PLAY_SAMPLES:     move.w  #$4E8,d0
                  bsr     PLAY_SAMP
                  move.w  #$554,d0
                  bsr     PLAY_SAMP
                  move.w  #$514,d0
                  bsr     PLAY_SAMP
                  move.w  #$48C,d0
                  bsr     PLAY_SAMP
                  move.w  #$44C,d0
                  bsr     PLAY_SAMP
                  move.w  #$401,d0
                  bsr     PLAY_SAMP
                  rts 

PLAY_SAMP:        move.w  #$7FF,$FFFF8924  ;    MASK PROCESSEUR SON
                  cmpi.w  #$7FF,$FFFF8924  ;    PRET A RECEVOIR ??
                  bne.s   PLAY_SAMP       
                  move.w  d0,$FFFF8922     ;    REGLAGE VOLUME + FILTRES
                  rts 

frame:	dc.l 0
frame_end: dc.l 0


SCREEN1: DC.L  $F8000
SCREEN2: DC.L  $F0000
lignes: dc.w    184

OLD_PAL:  DS.W   16


NEW_PAL:  DC.W $000,$111,$222,$333,$444,$555,$666,$777
          DC.W $777,$666,$555,$444,$333,$222,$111,$000

OLD_70:         DC.L 0

RAM_H3:         DC.L 0

OLD_118:        DC.L 0

TIMER:         dc.w    0
L28E58:         dc.w 100
fade_out_colors:
	dc.w	$fff,$777,$eee,$666,$ddd,$555,$ccc,$444
	dc.w    $bbb,$333,$aaa,$222,$999,$111,$888,$000
fade_in_colors:
	dc.w	$000,$888,$111,$999,$222,$aaa,$333,$bbb
	dc.w	$444,$ccc,$555,$ddd,$666,$eee,$777,$fff

PAL_2:   DC.W    $777,$777,$777,$777,$777,$777,$777,$777
         DC.W    $500,$550,$500,$555,$500,$500,$505,$050

        even
errpic:
        move.l  SCREEN1,a0
	move.w	#16000,d0
put_word:
	clr.w	(a0)+
	dbra	d0,put_word
        rts
offset: dc.l    98
image: 
        incbin text.z
        even
trajectoire:
	incbin curve.dat
	dc.l	-1

filename:	incbin new*.pi1
O2:	incbin NEWSLT.PI1
O2END
fall_o_car:	;ds.b 2816
	incbin o.blk
	even
fall_o_msk:
	incbin o.msk
	even
S_FONT:	INCBIN	S.BLK
	EVEN
S_MASK: INCBIN S.MSK
	EVEN
sanszo_buff:	incbin sanszo.blk
	even
fall_buffer:	dc.l	$78000
 	ds.l	400
casse:  incbin casse.pcm
	even
shit:  incbin *.spl
casse_end:
	even
mouche:	incbin mouche1.pcm
mouche_end: 
	even
