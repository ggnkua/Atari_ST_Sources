	    output	m7.dat
	    
	    move.l	sp,sav_sp
	    
	    cmp.w	#1,d0
	    beq		table
	    
	    
	    lea         $3ca000,a0
	    moveq	#0,d0
	    move.w	#384*2*100/4/16-1,d7
clr_scr	    rept	16
	    move.l	d0,(a0)+     
	    endr
	    dbf		d7,clr_scr
	    
	    move.l 	#$3ca000,d0
            lsr.w 	#8,d0
            move.l 	d0,$ffff8200.w                               
            
            bclr	#0,$fffffa13.w	   	    
	   	
	    move.w	#37,-(sp)
	    trap	#14
	    addq.l	#2,sp
	    	    
	    moveq	#5,d0
	    trap	#4
	    
	    bset	#0,$fffffa13.w
	    
	    bra		yeah
;-----------------------------------	    	    
table	    

	    lea.l	DSPbin.start(pc),a0
	    moveq 	#(DSPbin.end-DSPbin.start)/3,d1
            moveq	#6,d0
            trap	#4


            lea sin1(pc),a0
            move.w #256*4+10,d7
corect_1    move.b (a0),d0
            move.b 1(a0),(a0)
            move.b d0,1(a0)
            addq.w #2,a0
            dbf d7,corect_1                                                
	    
	    lea 	pic,a0
	    lea 	out,a1
	    lea 	out2,a3
	    moveq 	#0,d0
	    move.w 	#256-1,d6
sec 	    move.w 	#256-1,d7
fir 	    move.w 	(a0)+,d0
 	    not.w	d0
 	    move.w 	d0,(a1)+
 	    move.w 	d0,(a3)+
 	    move.w 	d0,(a1)+
 	    move.w 	d0,(a3)+
            dbf    	d7,fir
            dbf 	d6,sec 
;--------------------------------------------------                                   
            lea 	offs+32*2+(320*2*10)(pc),a0
            lea 	to_rot,a1
            move.w 	#200-1,d6
line2       move.w	#256-1,d7
pixel 	    move.w      (a0)+,(a1)+
            dbf 	d7,pixel            
            add.l 	#320*2-256*2,a0
            dbf 	d6,line2
;--------------------------------------------------                                   	    
	    move.l	sav_sp,sp
	    rts
;--------------------------------------------------                                    
yeah
            moveq 	#0,d0
            lea 	sinus2+2(pc),a1           
            lea 	sinus+2(pc),a0           
            move.b 	pointer+1(pc),d0
            moveq 	#0,d1
            move.b 	(a1,d0.w),d1           
            lsr.b 	#1,d1            
            and.w 	#$ff,d1
            cmp.b 	#100,d1
            blt.b 	lo
            moveq 	#100,d1
lo          move.w 	d1,ly                                    
            moveq 	#0,d1
            move.b 	(a0,d0.w),d1           
            lsr.b 	#1,d1	
            move.w 	d1,lx
;----------------------------------------------------------               
            addq.w 	#1,pointer
            and.w 	#$ff,pointer
;----------------------------------------------------------               
szer        equ 383/2
wys         equ 100+1 0/2
;----------------------------------------------------------            
            move.w #200,skala               ;zoom is const             
licz_kont:  addq.w #6,kont 
            and.w #$1ff,kont 
            move.w kont,d7
            moveq.l #0,d1
            move.w skala,d1
      ;licz ddx                              ;calc some rot&zoom 
            lea cos1(pc),a0                  ;deltas
            move.l d1,d0
            muls (a0,d7.w),d0
            divs #256,d0
            move.w d0,ddx 
      ;licz ddy            
            lea sin1(pc),a0
            move.l d1,d0
            muls (a0,d7.w),d0 
            divs #256,d0
            move.w d0,ddy             
      ;licz d2x            
            lea cos2(pc),a0
            move.l d1,d0
            muls (a0,d7.w),d0 
            divs #256,d0
            move.w d0,d2x                        
      ;licz d2y            
            lea sin3(pc),a0
            move.l d1,d0
            muls (a0,d7.w),d0             
            divs #256,d0
            move.w d0,d2y  
      ;licz i     
            moveq  #0,d0
            moveq  #0,d1 
            move.w ddx,d0
            muls #szer/2,d0
            move.w d2x,d1
            muls #wys/2,d1                                   
            add.l d1,d0
            move.l x,d1
            sub.l d0,d1
            divs #1,d1
            move.w d1,i 
      ;licz j     
            moveq.l #0,d0
            moveq.l #0,d1 
            move.w ddy,d0
            muls #szer/2,d0
            move.w d2y,d1
            muls #wys/2,d1                                   
            add.l d1,d0
            move.l y,d1
            sub.l d0,d1            
            move.w d1,j
      ;drawing:            
            move.l scren_p(pc),a1               
            lea $ffffffa206.w,a3                                            
            move.w i(pc),d0                  ;send data to dsp
            bsr send_w                                               
            move.w j(pc),d0
            bsr send_w                                                                       
            move.w ddx(pc),d0            
            bsr send_w                         
            move.w ddy(pc),d0             
            bsr send_w                         
            move.w d2x(pc),d0
            bsr send_w                        
            move.w d2y(pc),d0
            bsr send_w            	    
;----------------------------------------------------------               
	    move.l 	scren_p(pc),a0
	    lea    	to_rot+(256*2*100),a1
	    lea    	out+256*4*128,a2
	    lea 	$fffffa206.w,a5
	    move.l 	aaa(pc),d0	    
	    lsl.l 	#2,d0
	    add.l  	d0,a2
	    moveq 	#0,d0
	    moveq  	#0,d1
	    moveq  	#0,d2
	    moveq   	#50*2-1,d6	    
line	    move.w  	#192/8-1,d7
mk_tunn     rept 	8 
            move.w 	(a5),d1
            move.w 	(a1,d1.w*2),d0
 	    move.l 	(a2,d0.w*4),(a0)+
 	    endr  
 	    dbf 	d7,mk_tunn 
 	    ;add.l 	a3,a1       
 	    dbf 	d6,line 
;----------------------------------------------------------               	    
	    move.l	poin2(pc),a0
	    move.w	(a0)+,d2
	    cmp.w	#$ffff,d2
	    bne.b	jabol
	    move.l	#$ffff,old_adr
jabol	    moveq	#4,d0
	    trap	#4
	    
	    cmp.w	d2,d1
	    blt.b	oldee
	
	    move.w	(a0)+,old_adr
	    
	    move.l	a0,poin2
	
oldee	    cmp.w	#$ffff,old_adr 	   	    
	    beq.b	skip_me_beaby
	    move.w	old_adr(pc),d0
	    jsr		([tab_adr,d0.w*4])
skip_me_beaby
;----------------------------------------------------------               	    
            add.l 	#4*3,aaa
            and.l 	#$ffff,aaa            
            
            move.l	poi(pc),a0
            
            move.w	(a0)+,d2
            cmp.w	#$ffff,d2
            beq		exit
            move.w	(a0)+,d3
            
            moveq	#4,d0
            trap	#4
            
            cmp.w	d2,d0
            blt.b	keep_t
            cmp.w	d3,d1
            blt.b	keep_t
            
            add.w	#1,scan
            move.l	a0,poi
            
keep_t      sub.l	a2,a2
	    move.w	scan(pc),d4
again	    move.l	scren_p(pc),a0
	    add.l	a2,a0
	    
	    beq.b	trte	   
	    
	    moveq	#100-1,d6	    
	    move.l	#(384*2)-(384*2/5),a1
	    moveq	#0,d0 
	    
linew	    move.w	#384*2/5-1,d7
pix_it	    move.b	d0,(a0)+
	    dbf		d7,pix_it
	    add.l	a1,a0 	     
	    dbf		d6,linew
	    
	    add.l	#384*2/5,a2
	    
	    subq.w	#1,d4
	    bne.b	again 
            
;----------------------------------------------------------               	                
trte        move.l	scren_p,d0
            move.l 	scren_l,scren_p
            move.l 	d0,scren_l
            lsr.w 	#8,d0
            move.l 	d0,$ffff8200.w                               
            
            cmp.b 	#1,$ffffffc02.w
            bne 	yeah                        
;----------------------------------------------------------                                     
exit	    move.l	sav_sp(pc),sp
	    rts
;----------------------------------------------------------                                               
send_w      ext.l d0
            move.l d0,-2(a3)
            rts   
;----------------------------------------------------------                                               
des1	    move.l	scren_p(pc),a0
	    move.l	#%11110111110111101111011111011110,d1
	    move.l	#384*2-384,a1
	    moveq	#50-1,d7
des1_lin    rept	96
	    move.l	(a0),d0
	    and.l	d1,d0
	    lsr.l	d0
	    move.l	d0,(a0)+	    	
	    endr
	    add.l	a1,a0
	    dbf		d7,des1_lin
	    sub.l	a1,a0
	    moveq	#50-1,d7
des1_linh   rept	96
	    move.l	(a0),d0
	    and.l	d1,d0
	    lsr.l	d0
	    move.l	d0,(a0)+	    	
	    endr
	    add.l	a1,a0
	    dbf		d7,des1_linh
	    rts		
;----------------------------------------------------------                                               
des2	    move.l	scren_p(pc),a0
	    move.l	#%11110111110111101111011111011110,d1
	    move.l	#384*2-384,a1
	    add.l	a1,a0
	    moveq	#50-1,d7
des2_lin    rept	96
	    move.l	(a0),d0
	    and.l	d1,d0
	    lsr.l	d0
	    move.l	d0,(a0)+	    	
	    endr
	    add.l	a1,a0
	    dbf		d7,des2_lin
	    sub.l	a1,a0
	    moveq	#50-1,d7
des2_linh   rept	96
	    move.l	(a0),d0
	    and.l	d1,d0
	    lsr.l	d0
	    move.l	d0,(a0)+	    	
	    endr
	    add.l	a1,a0
	    dbf		d7,des2_linh
	    rts			    	
;----------------------------------------------------------                                               
des3	    move.l	scren_p(pc),a0
	    move.l	#%11110111110111101111011111011110,d1
	    move.l	#384*2-384,a1
	    add.l	a1,a0
	    moveq	#100-1,d7
des3_lin    rept	96
	    move.l	(a0),d0
	    and.l	d1,d0
	    lsr.l	d0
	    move.l	d0,(a0)+	    	
	    endr
	    add.l	a1,a0
	    dbf		d7,des3_lin
	    rts		
;----------------------------------------------------------
des4	    move.l	scren_p(pc),a0
	    move.l	#%11110111110111101111011111011110,d1
	    move.l	#384*2-384,a1
	    moveq	#100-1,d7
des4_lin    rept	96
	    move.l	(a0),d0
	    and.l	d1,d0
	    lsr.l	d0
	    move.l	d0,(a0)+	    	
	    endr
	    add.l	a1,a0
	    dbf		d7,des4_lin
	    rts			    	    	    		    
;----------------------------------------------------------                                               
mode        dc.w 	0   
aaa 	    ds.l 	1	
sav_sp	    ds.l	1
poi	    dc.l	music
poin2	    dc.l	music2
pointer	    dc.w 	1
scan	    dc.w	0
lx	    ds.w 	1
ly	    ds.w 	1	    
kont        dc.w 	0
x           dc.l 	32687
y           dc.l 	0	
j           dc.w 	0
i           dc.w 	0	
ddx         dc.w 	0	
old_adr	    dc.w	$ffff
ddy         dc.w 	0
d2x         dc.w 	0
d2y         dc.w 	0
skala       dc.w 	00         
scren_l     dc.l 	$3ca000
scren_p     dc.l 	$3ca000-256*152*2 
tab_adr	    dc.l	des1
	    dc.l	des2
	    dc.l	des3
	    dc.l	des4
;-------------------------------------------------
music	    dc.w	$18,$30
	    dc.w	$18,$34
	    dc.w	$18,$37
	    dc.w	$18,$3a
	    dc.w	$19,$0
	    dc.w	$ffff,$ffff
;-------------------------------------------------
music2	    rept	3
	    dc.w	00,0
	    dc.w	04,1
	    dc.w	10,2
	    dc.w	14,3
	    dc.w	20,0
	    dc.w	26,1
	    dc.w	32,2
	    dc.w	36,3
	    dc.w	42,0
	    dc.w	46,1
	    dc.w	52,2
	    dc.w	58,3
	    endr
	    dc.w	$ffff,$ffff
;-------------------------------------------------
DSPbin.start  
       incbin d:\bump!!.p56
DSPbin.end       
sin1  incbin d:\rot_sins\sin1.dat
sin3  incbin d:\rot_sins\sin2.dat
cos1  incbin d:\rot_sins\cos1.dat
cos2  incbin d:\rot_sins\cos2.dat            
sinus2      incbin 	d:\sinus\a_sin.prg   
sinus  	    incbin 	d:\sinus\k_sin.prg   
offs	    incbin 	d:\hohoho\stargate.dat
pic         incbin 	d:\hohoho\mess2.565
	    section 	bss
out 	    ds.l 	256*256
out2 	    ds.l 	256*256                
to_rot      ds.w  	256*256