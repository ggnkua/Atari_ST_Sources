	    output	m3.dat	
;--------------------------------------------------            
	    move.l	sp,sav_sp
	    tst.w	d0
	    beq.b	yeah2
;------------------------------------                        
            lea		to_c,a0
            move.w	#256-1,d7 
do_it_now   clr.l	(a0)+
	    dbf	d7,do_it_now            
;------------------------------------                                    
            lea   white,a0
            moveq #0,d0
            moveq #0,d4
            moveq #0,d5
            moveq #64-1,d7
green_pal   move.w d4,d1 
            move.w d0,d2
            move.w d0,d3
            lsl.w  #5,d1
            lsl.w  #8,d2
            lsl.w  #3,d2             
            or.w   d1,d3
            or.w   d2,d3                                    
            move.w d3,(a0)+
            addq.w #1,d4 
            not.b  d5
            bne.b  half
            addq.w #1,d0                             
            move.w d3,(a0)+
half        dbf    d7,green_pal            
            
            move.w #182*2,d7
rep         move.w d3,(a0)+
            move.w d3,(a0)+
            dbf d7,rep
;------------------------------------------------                                    
	    lea light,a0
	    move.w #320*200-1,d7
ddd	    move.b (a0),d0
            lsr.b #1,d0
            move.b d0,(a0)+
            dbf d7,ddd	
            rts  
;--------------------------------------------------                                   
yeah2		moveq 		#5,d0
           	move.w 		#40,d1
          	trap 		#3

yeah
	    moveq #0,d0
            moveq #0,d4
            lea sinus2+2(pc),a1           
            lea sinus+2(pc),a0           
            move.b pointer+1(pc),d0
            move.b pointer2+1(pc),d4
            moveq #0,d1
            move.b (a1,d0.w),d1           
            lsr.b #1,d1            
            and.w #$ff,d1
            cmp.b #100,d1
            blt.b lo
            moveq #100,d1
lo          move.w d1,ly                        
            moveq #0,d1
            move.b (a0,d0.w),d1           
            lsr.b #2,d1
            move.w d1,lx
            moveq #0,d0
            ;-----------------------
            addq.w #1,pointer
            and.w #$ff,pointer
;------------------------------------                                    

	    move.l scren_p,a0
	    lea    light,a4
	  
	    move.w li(pc),d0	    
	    lea    white,a5
	    lea    (a5,d0.w),a5
	    
	    moveq  #0,d1
	    moveq  #0,d2
	    move.w ly,d1
	    mulu   #320,d1
	    move.w lx,d2
	    lsl.w  d2
	    add.w  d2,d1
	    add.l  d1,a4
	    move.l #320-192,a6
	    moveq #0,d2
		
	    moveq   #50*2-1,d6	    
line	    move.w  #192-1,d7
mk_tunn    
 	    move.b (a4)+,d2
 	    move.l (a5,d2.w*4),d4

            move.l d4,(a0)+ 
 	    dbf d7,mk_tunn 
 	    add.l a6,a4
 	    dbf d6,line 
;------------------------------------               
	    
	    tst.b	count
	    beq.b	skip_dip
	    tst.w	event
	    beq	end
	    subq.w	#1,event
	    
skip_dip    move.w	li,d0
	    add.w	#512,d0
	    sub.w	#8*2+16,d0
	    bmi.b	over
	    sub.w	#512,d0
	    move.w	d0,li
	    bra		not_now
over	    move.w 	#-512,li
	   
not_now	    
            tst.b	flag
            bne.b	nope
           
	    move.l	point(pc),a0
	    move.w	(a0),d2
	    
	    
	    moveq	#4,d0
	    trap	#4
	    
	    cmp.w	#56,d1
	    bne		wwe
	    st.b	count    
wwe	    cmp.w	d2,d1
	    blt.b	nope

            move.w	2(a0),li
            ;add.w	d2,li
            
            cmp.w	#56,d2
            bne.b	nope2
            
            st.b	flag
            
nope2       addq.l	#4,point

nope	    move.l scren_p,d0
            move.l scren_l,scren_p
            move.l d0,scren_l
            lsr.w #8,d0
            move.l d0,$ffff8200.w                   
            
            
            cmp.b #1,$ffffffc02.w
            bne yeah                        
;------------------------------------               
end         move.l	sav_sp,sp
            rts          
;-------------------------------           
mode        dc.w 0   
;---------------------------------------------------------------------------
aaa 	    ds.l 1
sav_sp      ds.l 1
pointer	    dc.w 1
pointer2    dc.w 1
lx	    ds.w 1
ly	    ds.w 1	
flag	    dc.b 0
count	    dc.b 0
	    even  
event	    dc.w 15	      
li	    dc.w -512
point	    dc.l	tab
tab	    dc.w	40,0-64
	    dc.w	48,64-64
	    dc.w	56,0-64 
	    dc.w	0,0,0,0
scren_l     dc.l 	$3ca000
scren_p     dc.l 	$3ca000-256*152*2 	    
sinus2  incbin d:\sinus\e_sin.prg   
sinus3  incbin d:\sinus\a_sin.prg   
sinus  incbin d:\sinus\k_sin.prg   
light       incbin d:\f2.img
	    section bss
to_c        ds.l 256
white	    ds.l 256*4
