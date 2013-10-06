********** FIRE **************

calc_firepal:   

* 32*3 + 8 = 104 colors

                lea     fire_pal,A0

                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D2

* Anstieg Blau

                moveq   #8-1,D4
loop1:
                bsr.s   rgb_convert
                move.w  D3,(A0)+

                addq.w  #2,D2
                dbra    D4,loop1

* Anstieg rot, Abfall blau

                moveq   #8-1,D4
loop2:
                bsr.s   rgb_convert
                move.w  D3,(A0)+

                addq.w  #1,D0
                subq.w  #2,D2
                dbra    D4,loop2

* Anstieg rot

                moveq   #24-1,D4
loop3:
                bsr.s   rgb_convert
                move.w  D3,(A0)+

                addq.w  #1,D0
                dbra    D4,loop3

* Anstieg gruen (->gelb)

		moveq	#31,d0
		moveq	#0,d1
		moveq	#0,d2

                moveq   #32-1,D4
loop4:
                bsr.s   rgb_convert
                move.w  D3,(A0)+

                addq.w  #1,D1
                dbra    D4,loop4

* Anstieg blau (->weiss)

	      	moveq	#31,d0
	      	moveq	#31,d1
	      	moveq	#0,d2			
                moveq   #32-1,D4
loop5:
                bsr.s   rgb_convert
                move.w  D3,(A0)+

                addq.w  #1,D2
                dbra    D4,loop5

	      	moveq	#31,d0
	      	moveq	#31,d1
	      	moveq	#31,d2

                
	      	move.w   #152-1,D4
loop6:
                bsr.s   rgb_convert
                move.w  d3,(A0)+
                dbra    D4,loop6
                rts

* in:
* d0 = red
* d1 = green
* d2 = blue

* out:
* d3 = falcon true color word

rgb_convert:
                movem.l D0-D2,-(SP)

                lsl.w   #8,D0
                lsl.w   #3,D0

                lsl.w   #6,D1

                or.w    D0,D1
                or.w    D1,D2
                move.w  D2,D3

                movem.l (SP)+,D0-D2
                rts

                

********** 1st Fire Calculation routine ***********
* lame Falcon

calc_fire:    
* a5 = screen address

                movea.l source_fire,A0
                movea.l destination_fire,A1

                lea     fire_wide+1(A0),A0
                lea     fire_wide(A1),A1
               
		lea	divtable,a3
                lea     fire_pal,A4
                adda.l  #wohin,A5
		lea	mask,a6

                moveq   #fire_high-1-1-1-4,D7
                moveq   #0,D1
		moveq	#2,d2

		move.w	#$0020,d5

* a0= source buffer
* a1= dest. buffer

fire_loop3:
                moveq   #(fire_wide/2)-1,D6

fire_loop2:
         
	        moveq   #0,D0
                move.b  -2(A0),D0      	 	* links
                move.b  (A0)+,D1        	* rechts
                add.w   D1,D0
                move.b  fire_wide-1-1(A0),D1 	* oben
                add.w   D1,D0
                move.b  -1-1-1+fire_wide(A0),D1 	* links unten
                add.w   D1,D0
                move.b  -1-1-1-fire_wide(A0),D1 	* rechts oben
                add.w   D1,D0

****** write color value *********

		move.w	0(a3,d0.w*2),d0		* divu div & correct -1
                move.b  D0,(A1)+
	      	
		cmp.w	(a6)+,d5
*tst.w   (a6)+
	      	bne.s 	no_fire_1  
	      	
		move.w  0(a4,d0.w*2),(a5)

no_fire_1	adda.w	d2,a5

	        moveq   #0,D0
                move.b  -2(A0),D0      	 		* links
                move.b  (A0)+,D1        		* rechts
                add.w   D1,D0
                move.b  fire_wide-1-1(A0),D1 		* oben
                add.w   D1,D0
                move.b  -1-1-1+fire_wide(A0),D1 	* links unten
                add.w   D1,D0
                move.b  -1-1-1-fire_wide(A0),D1 	* rechts oben
                add.w   D1,D0

****** write color value *********

		move.w	0(a3,d0.w*2),d0		* divu div & correct -1
                move.b  D0,(A1)+
	      	
		cmp.w	(a6)+,d5
		*tst.w   (a6)+
	      	bne.s 	no_fire_2  
	      	
		move.w  0(a4,d0.w*2),(a5)

no_fire_2	adda.w	d2,a5

		dbra    D6,fire_loop2

                lea     640-fire_wide*2(A5),A5
                dbra    D7,fire_loop3

********* not visible area ( 4 Lines ) **********

		moveq	#4-1,d7
fire_loop3v:
                moveq   #(fire_wide/2)-1,D6

fire_loop2v:
         
	        moveq   #0,D0
                move.b  -2(A0),D0      	 	* links
                move.b  (A0)+,D1        	* rechts
                add.w   D1,D0
                move.b  fire_wide-1-1(A0),D1 	* oben
                add.w   D1,D0
                move.b  -1-1-1+fire_wide(A0),D1 	* links unten
                add.w   D1,D0
                move.b  -1-1-1-fire_wide(A0),D1 	* rechts oben
                add.w   D1,D0

****** write color value *********

		move.w	0(a3,d0.w*2),d0		* divu div & correct -1
                move.b  D0,(A1)+

	        moveq   #0,D0
                move.b  -2(A0),D0      	 		* links
                move.b  (A0)+,D1        		* rechts
                add.w   D1,D0
                move.b  fire_wide-1-1(A0),D1 		* oben
                add.w   D1,D0
                move.b  -1-1-1+fire_wide(A0),D1 	* links unten
                add.w   D1,D0
                move.b  -1-1-1-fire_wide(A0),D1 	* rechts oben
                add.w   D1,D0

****** write color value *********

		move.w	0(a3,d0.w*2),d0		* divu div & correct -1
                move.b  D0,(A1)+
	      	
		dbra    D6,fire_loop2v

                dbra    D7,fire_loop3v
                rts


scroll_fire:    

                lea     fire_buffer_1,A0
                lea     fire_buffer_2,A1

                tst.w   index
                bpl.s   its_ok
                exg     A0,A1
its_ok:
                move.l  A0,source_fire
                move.l  A1,destination_fire

                lea     fire_wide(A0),A1

                moveq   #fire_high-1-1,D0

copy_fire:
                REPT fire_wide/4
                move.l  (A1)+,(A0)+
                ENDR

                dbra    D0,copy_fire

                rts
                


renew_fire:     
                	movea.l source_fire,A0
                	lea     fire_wide*(fire_high-1)(A0),A0

                
                moveq   #fire_wide-1,D7
insert:                
	      bsr     random 

	      *divu    #128,d0
	      *swap    d0

	      *sub.b	#20,d0  	

                move.b  d0,(A0)+

                dbra    D7,insert
                rts
                
clear_gap:      

                movea.l source_fire,A0
                moveq   #0,D0
                moveq   #fire_high-1,D1
clear_rand:     move.b  D0,(A0)
                move.b  D0,fire_wide-1(A0)
                lea     fire_wide(A0),A0
                dbra    D1,clear_rand
                rts

***************************************