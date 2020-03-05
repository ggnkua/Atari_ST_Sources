	    output	m9.dat
	    
	    move.l	sp,sav_sp
	    
	    cmp.w	#1,d0
	    beq.b	setup

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
	    
waitt       move.w	#37,-(sp)
	    trap	#14
	    addq.l	#2,sp
	    subq.w	#1,_vbl_
	    bne.b	waitt	
	    
	    bra		yeah	     
_vbl_	    dc.w	32
;------------------------------------                        
setup	    lea.l	DSPbin.start(pc),a0
	    moveq 	#(DSPbin.end-DSPbin.start)/3,d1
            moveq	#6,d0
            trap	#4


	    lea pic,a0
	    lea out,a1
	    lea out2,a3
	    moveq #0,d0
	    move.w #256-1,d6
sec 	    move.w #256-1,d7
fir 	    move.w (a0)+,d0
 	    ;and.w #%1111011111011110,d0
 	    ;lsr.w #1,d0
 	    ;------------------
 	    move.w d0,d1
 	    move.w d0,d3 	    
 	    and.w #%011111,d0 	    
 	    lsr.w #5,d1
 	    and.w #%111111,d1 	    
 	    lsr.w #8,d3
 	    lsr.w #3,d3
 	    and.w #%011111,d3
 	    ;------------------
 	    
 	    addq.l #1,a1
 	    move.b d0,(a1)+
 	    move.b d1,(a1)+
 	    move.b d3,(a1)+
 	    
 	    addq.l #1,a3 	    
 	    move.b d0,(a3)+ 	     	     	    
 	    move.b d1,(a3)+
 	    move.b d3,(a3)+
 	    
            dbf    d7,fir
            dbf d6,sec 
;--------------------------------------------------                                
	    lea offs,a1
	    lea offs2,a2
	    lea light,a0
	    move.w #320*200-1,d7
ddd	    move.b (a0)+,d0
            lsr.b #1,d0
            move.w (a1)+,(a2)+
            move.w d0,(a2)+            
            dbf d7,ddd	  
;--------------------------------------------------                                   
	    move.l	sav_sp,sp
	    rts
;--------------------------------------------------                                    
yeah
            moveq #0,d0
            moveq #0,d4
            lea sinus2+2(pc),a1           
            lea sinus+2(pc),a0           
            lea sinus3+2,a2
            move.w pointer(pc),d0
            move.w pointer2(pc),d4
            
            moveq #0,d1
            move.b (a1,d0.w),d1           
            lsr.b #1,d1            
            
            cmp.b #100,d1
            blt.b lo
            moveq #100,d1
lo          move.w d1,ly                        
            
            moveq #0,d1
            move.b (a0,d0.w),d1           
            lsr.b #2,d1
            move.w d1,lx
            moveq #0,d0
            move.b (a2,d4.w),d0
            move.w d0,li 
            ;-----------------------
            addq.w #4,pointer
            and.w #$ff,pointer
            add.w #8,pointer2
            and.w #$ff,pointer2
;------------------------------------                                    
;     Tu jest glowna procedura....
;
;
;------------------------------------                                    
	    move.l scren_p,a0
	    sub.l	#12,a0
	    lea    offs2,a1
	    lea    out+256*4*128,a2
	  
	    
	    move.l aaa,d0
	    lsl.l #2,d0
	    add.l  d0,a2
	    moveq #0,d0
	    moveq  #0,d1
	    moveq  #0,d2
	    move.w ly,d1
	    mulu   #320*4,d1
	    move.w lx,d2
	    ;lsl.w  #2,d2
	    mulu #4,d2
	    add.w  d2,d1
	    lea    (a1,d1.l),a1
	    
		
            ;--------------------------------
            move.l	#$123456,$ffffa204.w
            ;--------------------------------
            move.w li(pc),d0	    
	    lsr.w	#2,d0 	
	    add.w	#60,d0
	    move.w	d0,$ffffa206.w
	    	                
            lea		$fffffa204.w,a6
            lea		$fffffa206.w,a4
	    lea		$fffffa207.w,a5
	    moveq	#0,d3
	    moveq   #50*2-1,d6	    
line	    move.w  #192-1,d7
mk_tunn    
            move.w 	(a1)+,d5 	  	    
 	    move.w 	(a1)+,(a4)
 	    move.l 	(a2,d5.w*4),(a6)    	     	    
 	    nop
 	    nop 	     	    
	    move.w	(a4),d0
            move.w 	d0,(a0)+ 
            move.w 	d0,(a0)+  	    
 	    dbf 	d7,mk_tunn 
 	    
 	    add.l #320*4-192*4,a1       
 	    
 	    dbf d6,line 


	    move.l scren_p,d0
            move.l scren_l,scren_p
            move.l d0,scren_l
            lsr.w #8,d0
            move.l d0,$ffff8200.w                   
            
            add.l #258+8,aaa
            and.l #$ffff,aaa
            
            moveq	#4,d0
            trap	#4
            
            cmp.w	#35,d0
            bgt.b	clre
            
            cmp.b #1,$ffffffc02.w
            bne yeah
            
            
;------------------------------------               
exit        move.l	sav_sp,sp          
            rts
;-------------------------------           
clre	    move.l	scren_p(pc),a0
	    move.w	#384*2*100/4/16-1,d7
	    moveq	#0,d0
do_it	    rept	16
	    move.l	d0,(a0)+	    
            endr
            dbf		d7,do_it
            
            move.l 	scren_p,d0
            lsr.w 	#8,d0
            move.l 	d0,$ffff8200.w                   
key         cmp.b	#1,$fffffc02
            bne		key 
	    bra		exit
;---------------------------------------------------------------------------	    
mode        dc.w 0   
;---------------------------------------------------------------------------
aaa 	    ds.l 1
sav_sp	    ds.l 1
pointer	    dc.w 1
pointer2    dc.w 1
lx	    ds.w 1
ly	    ds.w 1	    
li	    ds.w 1
scren_l     dc.l $3ca000
scren_p     dc.l $3ca000-256*150*2 
DSPbin.start  
       incbin d:\light_05.p56
DSPbin.end       
sinus2  incbin d:\sinus\a_sin.prg   
sinus3  incbin d:\sinus\a_sin.prg   
sinus  incbin d:\sinus\b_sin.prg   
offs	    incbin d:\hohoho\stargate.dat
pic         incbin d:\hohoho\mess2.565
light       incbin d:\f1.img
	    section bss
steps_blue  ds.w 256*2
steps_red   ds.w 256*2
steps_green ds.w 256*2 
            
out 	    ds.l 256*256
out2 	    ds.l 256*256                
offs2 	    ds.b 320*200*3