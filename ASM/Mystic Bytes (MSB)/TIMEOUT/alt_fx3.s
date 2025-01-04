            output	m5.dat
            
            
            move.l	sp,sav_sp
            
            cmp.w	#1,d0
            beq.b	prep

            bra		yeah
;------------------------------------                        
prep	    
	    lea.l	DSPbin.start(pc),a0
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
 	    not.w	d0
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
ts	    lea offs,a1
	    lea offs2,a2
	    lea light,a0
	    move.w #320*200-1,d7
ddd	    move.b (a0)+,d0
            lsr.b  #1,d0
            move.w (a1)+,(a2)+
            move.w d0,(a2)+            
            dbf d7,ddd	  
            
            move.l	sav_sp,sp
	    rts
;--------------------------------------------------                                   
yeah
            moveq #0,d0
            moveq #0,d4
            lea sinus2+2(pc),a1           
            lea sinus+2(pc),a0           
            move.b pointer+1(pc),d0
            
            ;lsr.b d0
            moveq #0,d1
            move.b (a1,d0.w),d1           
            lsr.b #1,d1            
            and.w #$ff,d1
            ;add.w #20-2,d1
            
            cmp.b #100,d1
            blt.b lo
            moveq #100,d1
lo          move.w d1,ly                        
            
            moveq #0,d1
            move.b (a0,d0.w),d1           
            lsr.b #2,d1
            ;and.w  #$ff,d1
            move.w d1,lx
            ;-----------------------
            addq.w #3,pointer
            and.w #$ff,pointer
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
            move.w 	li(pc),d0
            move.w	d0,$ffffa206.w
	    	                
            lea		$fffffa204.w,a6
            lea		$fffffa206.w,a4
	    lea		$fffffa207.w,a5
	    moveq	#0,d3
	    moveq   	#50*2-1,d6	    
line	    move.w  	#192-1,d7
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
 	    
 	    add.l 	#320*4-192*4,a1       
 	    
 	    dbf 	d6,line 
;-------------------------------------------
	    moveq	#4,d0
	    trap	#4
	    
	    cmp.w	#18,d0
	    bne.b	music_not

	    cmp.w	#30,d1
	    blt.b	music_not

	    move.w	#150,li
	    
	    cmp.w	#45,d1
	    bgt.b	darknes


music_not   subq.w	#1,int_int
	    bne.b	yeep_jeep
	    
	    move.w	#130,li
	    move.w	#10,int_int
	    bra.b	ok_kej		
	    
yeep_jeep   sub.w	#8,li
	    bpl.b	ok_kej
	    move.w	#0,li
ok_kej	    
;-------------------------------------------
	    move.l scren_p,d0
            move.l scren_l,scren_p
            move.l d0,scren_l
            lsr.w #8,d0
            move.l d0,$ffff8200.w                   
            
            add.l #256+4,aaa
            and.l #$ffff,aaa
            
            cmp.b #1,$ffffffc02.w
            bne yeah
            
exit            
;------------------------------------               
	    move.l	sav_sp,sp
	    rts                      	
;-------------------------------           
darknes     
	    
	    
	    move.l scren_p,d0
            move.l scren_l,scren_p
            move.l d0,scren_l
            lsr.w #8,d0
            move.l d0,$ffff8200.w                   
            
            
            move.l	scren_l(pc),a0
            move.l	(a0),d0
            
around             
            move.l	scren_p(pc),a0
            move.w	d0,d1
            move.w	d0,d2
            
            and.w	#%11111,d0
            lsr.w	#5,d1
            and.w	#%111111,d1
            lsr.w	#8,d2
            lsr.w	#3,d2
            
            subq.w	#1,d0
            subq.w	#2,d1
            subq.w	#1,d2
            bmi.b	jezz             

	    lsl.w	#5,d1
	    lsl.w	#8,d2
	    lsl.w	#3,d2
	    or.w	d1,d0
	    or.w	d2,d0
	    
	    move.w	d0,d1
	    
	    swap.w	d0
	    move.w	d1,d0
	    
	    move.w	#384*100/2/32-1,d7
deep	    rept	32
            move.l	d0,(a0)+
	    endr 
	    dbf		d7,deep	    
	    
	    move.l scren_p,d1
            move.l scren_l,scren_p
            move.l d1,scren_l
            lsr.w #8,d1
            move.l d1,$ffff8200.w                   
            
	    
	    bra		around 
jezz        
            move.l scren_p,d1
            move.l scren_l,scren_p
            move.l d1,scren_l
            lsr.w #8,d1
            move.l d1,$ffff8200.w                   

            move.l	scren_p(pc),a0                 	      	
	    move.w	#384*100/2/32-1,d7
	    moveq	#0,d0
deep2	    rept	32
            move.l	d0,(a0)+
	    endr 
	    dbf		d7,deep2	    
	    
	    move.l scren_p,d1
            move.l scren_l,scren_p
            move.l d1,scren_l
            lsr.w #8,d1
            move.l d1,$ffff8200.w                   
 	  
 	    bra	 exit
 
;-------------------------------           
mode        dc.w 0   
;---------------------------------------------------------------------------
aaa 	    ds.l 1
sav_sp	    ds.l	1
pointer	    dc.w 1
pointer2    dc.w 1
	    ds.w	2
int_int     dc.w 1
lx	    ds.w 1
ly	    ds.w 1	    
	    ds.w	10
li	    dc.w 100
scren_l     dc.l $3ca000
scren_p     dc.l $3ca000-256*152*2 
DSPbin.start  
       incbin d:\light_05.p56
DSPbin.end       
sinus2  incbin d:\sinus\e_sin.prg   
sinus3  incbin d:\sinus\a_sin.prg   
sinus  incbin d:\sinus\k_sin.prg   
offs	    incbin d:\ra.dat
pic         incbin d:\hohoho\mess2.565
light       incbin d:\f2.img
	    section bss
out 	    ds.l 256*256
out2 	    ds.l 256*256                
offs2 	    ds.b 320*200*3