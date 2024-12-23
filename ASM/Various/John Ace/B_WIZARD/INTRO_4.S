;* SCROLL ROUTINE NUMBER 2 *
;*   WRITTEN BY JOHN ACE   *
;* Contact address :       *
;* JOHN ACE                *
;* KAPODISTRIOU 59         *
;* 152 37 FILOTHEI         *
;* ATHENS                  *
;* GREECE                  *
;  WARNING !!!!! . Change lines 199/773/837 accordingly .
;
;

	clr -(sp)
	move #32,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,old_sp
	
	move #4,-(sp)
	trap #14
	addq.l #2,sp

	move d0,old_rez

	move #3,-(sp)
	trap #14
	addq.l #2,sp

	move.l d0,old_xb3

	move #2,-(sp)
	trap #14
	addq.l #2,sp

	move.l d0,old_xb2

	move.l #whole+255,wholescr
	and.l #$ffffff00,wholescr

	lea $ff8240,a0
	lea old_pal,a1
	moveq #7,d0
black:
	move.l (a0),(a1)+
	clr.l (a0)+
	dbra d0,black

	clr -(sp)
	move.l wholescr,-(sp)
	move.l wholescr,-(sp)
	move #5,-(sp)
	trap #14
	lea 12(sp),sp

	dc.w $a00a

	bsr mouse_off

;
	move.l wholescr,a0
	lea pict2+34,a1
	move #7999,d0
copy1:
	move.l (a1)+,(a0)+
	dbra d0,copy1

;	bsr fill_screen
;	bsr fill2

        move.l $44e,scrollba  ; screen address
        add.l #200*160,scrollba ; on lines 167-199 on screen
create:
     moveq #5,d0       ;We have six lines in the charset
     lea tabelle,a0
     move.l #picture+34,d2
spalte:
     move   #9,d1      ;and 10 columns
zeile:
     move.l d2,(a0)+    ;we create a table with
     add.l #16,d2     ;pointers to the invidual characters
     dbf d1,zeile    ;(These are 32 pixels wide = $10)
     add.l #32*160-160,d2  ;(and 32 pixels in height)
     dbf d0,spalte

      move #32,zanz ;the number of lines


;------- HBL ON -------
	move.l $114,old114

 move.l $120,oldtb             ;save all registers
 move.l $118,oldkey
 move.l $118,newkey2+2
 move.l $70,old4
 move.l $70,new4b+2
 move.b $fffa07,old07
 move.b $fffa09,old09
 move.b $fffa0b,old0b
 move.b $fffa0d,old0d
 move.b $fffa0f,old0f
 move.b $fffa11,old11
 move.b $fffa13,old13
 move.b $fffa15,old15
 move.b $fffa1b,old1b
 move.b $fffa21,old21

 move.l #contr,a0
 and.b  #$df,$fffa09
 and.b  #$fe,$fffa07
 move.b (a0)+,d0
 cmp.b  #21,d0
 bne    exit
 move.l #newtb,$120            ;install new vectors
 move.l #new4,$70
 move.l #newkey,$118
	MOVE.L #count_em,$114

 or.b   #1,$fffa07               ;allow timer b interrupt
 or.b   #1,$fffa13

	lea pict2+2,a0
	move #7,d0
	lea $ff8240,a1
lp1	move.l (a0)+,(a1)+
	dbra d0,lp1

exc	lea $fffc00,a0
	btst #7,(a0)
	beq.s exc
	cmp.b #$39,2(a0)
	bne.s exc

 move.w sr,-(sp)
 move.w #$2700,sr
 move.b contr+1,d0
 cmp.b  #4,d0
 bne    noex
 move.b old07,$fffa07            ;restore all registers
 move.b old09,$fffa09
 move.b old0b,$fffa0b
 move.b old0d,$fffa0d
 move.b old0f,$fffa0f
 move.b old11,$fffa11
 move.b old13,$fffa13
 move.b old15,$fffa15
 move.b old1b,$fffa1b
 move.b old21,$fffa21

 move.l oldtb,$120             ;restore vectors
 move.l oldkey,$118
 move.l old4,$70
 move.l old114,$114
noex:
 move.w (sp)+,sr
exit:

	bsr mouse_on
	
        movem.l (a0),d0-d7
        movem.l d0-d7,(a1)
        move.w old_rez,-(sp)     ;set resolution
        move.l old_xb2,-(sp)
        move.l old_xb3,-(sp)
        move.w #5,-(sp)
        trap   #14
        add.l  #12,sp

        lea old_pal,a0       ;set palette
        lea $ff8240,a1

	MOVE keys,d7
	tst d7
	beq.s skip_3
	move.l old114,$bc

left_out2:
	move d7,-(sp)
	trap #15
	move (sp)+,d7
	dbf d7,left_out2

skip_3: move.l old_sp,-(sp)    ;supervisor off
        move #32,-(sp)
        trap   #1
        addq.l #6,sp

        clr.l -(sp)             ;terminate
        trap  #1


        text

new4:                           ;new level 4 interrupt
	move.l d0,-(sp)

	clr.b $fffa1b
	nop
	nop
	move #$588,d0
same	dbf d0,same
	CLR.b $ff820a
	move #14,d0
same2	dbf d0,same2
	move.b #2,$ff820a
	move.l (sp)+,d0
	movem.l d0-a6,-(sp)
	move old,$ff8240
	move.b colors+3,$fffa21          ;set dats register
	move.b #8,$fffa1b               ;start timer
	move colors,old
	move #$700,oldz                 ; $700->RGB of color 4


	move #4,count
	move.b #2,$ff820a

	bsr scroll1

	move.l $44e,d1
	add.l #12600,d1

	lea $ff8205,a0
check:
	moveq #0,d0
	move.b 2(a0),d0
	add d0,d0
	add d0,d0
	add d0,d0
	add d0,d0
	add d0,d0
	add d0,d0
	add d0,d0
	add d0,d0
	move.b 4(a0),d0
	swap d0
	move.b (a0),d0
	swap d0
	cmp.l d1,d0
	blt.s check

	move.l old114,$114

	move keys,d7
	clr keys

	move.l #count_em,$114

	move.l old114,$bc
	move #$2600,sr

left_out:
	move d7,-(sp)
	trap #15
	move (sp)+,d7
	dbf d7,left_out

	movem.l (sp)+,d0-a6
	rte

new4b:
 jmp    $000000             ;; (((( ALWAYS SAVE REGISTERS!!!))))


newkey:                         ;keyboard don't disturb!!!
	rte
newkey2:
 jmp    $000000

count_em:
	move #$2500,sr
	addq #1,keys
	rte


newtb:
	clr.b $fffa1b	
	move d0,-(sp)

	move old(pc),$ff8240
	move oldz(pc),$ff8248
	move.l a0,-(sp)
	move count(pc),d0
	lea colors(pc),a0
	move 4(a0,d0.w),old
	move.b 3(a0,d0.w),$fffa21
	lea charpal(pc),a0

	move (a0,d0.w),oldz
	move.b #8,$fffa1b

	addq #4,count
	move.l (sp)+,a0
	move (sp)+,d0

 bclr    #0,$fffa0f              ;end of interrupt
 rte

rotate_logo:

;--------- scroll/distort logo -------

	movem.l d0-a6,-(sp)

	move #79,d7
	lea pic1d,a0
	lea logo1+8,a1
copy_first:
	moveq #11,d6
in1:
	move.l (a0),(a1)
	addq.l #8,a0
	addq.l #8,a1
	dbra d6,in1
	lea 64(a0),a0
	dbra d7,copy_first

	lea logos+4,a2
	lea logos,a3
	
	moveq #6,d4
outer:
	move.l (a3)+,a4
	move.l (a2)+,a1
	
	move.l a4,a0

	moveq #14,d6
	moveq #79,d7
vertical:
	moveq #11,d5
loop1a:

	move (a4),d0
	swap d0
	move 8(a4),d0
	ror.l d6,d0
	move d0,(a1)

	move 2(a4),d0
	swap d0
	move 10(a4),d0
	ror.l d6,d0
	move d0,2(a1)

	addq.l #8,a4
	addq.l #8,a1

	dbra d5,loop1a
	

	dbra d7,vertical
	dbra d4,outer

	movem.l (sp)+,d0-a6
	rts

fill_screen:
	movem.l d0-a6,-(sp)

	move.l wholescr,a1
	move #4999,d0
fill:
	addq.l #4,a1

	move #%1100110011001100,(a1)+
	move #%0000000000000000,(a1)+
	addq.l #4,a1

	move #%0100100100100100,(a1)+
	move #%0010010010010010,(a1)+
	dbra d0,fill


	movem.l (sp)+,d0-a6
	rts

mouse_off:

	move #$22,-(sp)
	trap #14
	addq.l #2,sp

	move.l d0,a6
	move.l a6,old_2

	move.l 16(a6),old_mouse
;	move.l #skip,16(a6)

	move.l #-1,-(sp)
	move.l #-1,-(sp)
	clr -(sp)
	clr -(sp)
	trap #14
	lea 12(sp),sp

	
	rts

mouse_on:

	move.l old_mouse,-(sp)
	pea para
	move #1,-(sp)
	clr -(sp)
	trap #14
	lea 12(sp),sp

	rts

scroll1:            

        clr.l d2
	move nr,d2
	addq #1,nr
;	tst stopflag
;	beq.s th2
;	subq #1,stopflag
;	subq #1,nr
;	bra bak

th2
	move.l scrollba,scrollbase
	sub.l #160*31,scrollbase

	move.l phase_s,a0
	move.l (a0)+,d0
	add.l d0,scrollbase
	divu #160,d0
	addq #4,d0
	move.w d0,change

	cmp.l #end_1,a0
	blt.s skip    ;10/8
	lea moves,a0  ;12c
	bra nxx       ;10c  ; case 1: 8+10+12=30
skip:
	cmp.l d0,d0       ; case 2: 10+6+4+10=30
	nop
	bra nxx
	
nxx	move.l a0,phase_s
	
	     and   #7,nr           ;that is used as buffer pointer
                            ;15, because of the 32 pixels width
	add d2,d2
	add d2,d2
     lea irqtab,a4
     move.l  (a4,d2.w),a2    ;one routine for each buffer
     jmp     (a2)
        rts

no109:                   ;Routine for buffer 1 and 9
     lea blocks+$0000,a6   ;Display buffer 0
     bsr    show
     lea blocks+$2000,a6   ;Shift buffer 1
     lea puff+$100,a5    ;Pointer to data-add-on buffer
     bra    delay_1

no210:                   ;analog to no109
     lea blocks+$2000,a6
     bsr    show
     lea blocks+$4000,a6
     lea puff+$200,a5
     bra    delay_1

no311:
     lea blocks+$4000,a6
     bsr    show
     lea blocks+$6000,a6
     lea puff+$300,a5
     bra    delay_1

no8:
     move.w #8,teil      ;Second half of the 32 pixels
     lea blocks+$6000,a6
     bsr    show
     bsr    addpuff      ;Prepare data-add-on buffer
     lea blocks+$0000,a6
     lea puff,a5
	bra delay_2

no0:
     lea blocks+$6000,a6
     bsr    show
     lea txt,a0          ;Pointer to txt start
     lea tabelle,a1       ;Pointer to conversion table
	lea translation,a2
	
     clr  teil              ;Left half of 32 pixels
nochmal:
        move.w zeiger,d0         ;Counter in the txt
	clr d1
        move.b (a0,d0.w),d1     ;Next character
	sub.b #32,d1
	move.b (a2,d1.w),d1

noeffect:
rr1:     cmp.b  #$40,d1           ;End found
     bne.s    noch2
     clr  zeiger            ;Start from beginning again
        move.w zeiger,d0         ;Counter in the txt
	clr d1
        move.b (a0,d0.w),d1     ;Next character
	sub.b #32,d1
	move.b (a2,d1.w),d1
	bra noc2            ; case 1: 8+24+14+8+14+10=78c      
noch2:
	move.l noc2,noc2
	move.l noc2,noc2    ; 72c
	cmp.l d0,d0         ; 78c

noc2    ext.w  d1                ;Else, get pointer to character
	add d1,d1
	add d1,d1
 
     move.l (a1,d1.w),zeichen1
	
     addq.w #1,zeiger
     move.w zeiger,d0         ;Pointer to next character
notex:
     move.b (a0,d0.w),d1
	sub.b #32,d1

	move.b (a2,d1.w),d1

rr2     cmp.b  #$40,d1           ;End found
     bne.s    noch3
        move.b (a0),d1           ;Then scroll in first character
	move.b (a2,d1.w),d1      ; case 1: 8+8+14+10=40c
	bra noc3

noch3:   ; case 2 = 10+6+4+10+10=40c
	cmp.l d0,d0
	nop
	bra daa1
daa1	bra noc3


noc3    ext.w  d1
	add d1,d1
	add d1,d1

     move.l (a1,d1.w),zeichen2

     bsr addpuff                ;Prepare data-add-on buffer
     lea blocks+$0000,a6        ;Scroll block 1
     lea puff,a5

linksw:
     move.w zanz,d0           ;Number of lines
     subq.w #1,d0             ;As dbf counter
zeilen:
     movem.l 8(a6),d1-d7/a0-a4     ;16 pixels to the left
     movem.l d1-d7/a0-a4,(a6)      ;scroll
     movem.l 56(a6),d1-d7/a0-a4
     movem.l d1-d7/a0-a4,48(a6)
     movem.l 104(a6),d1-d7/a0-a4
     movem.l d1-d7/a0-a4,96(a6)
     add.l  #144,a6
     move.l 8(a6),(a6)+
     move.l 8(a6),(a6)+
     move.l (a5)+,(a6)+            ;Merge data-add-on buffer
     move.l (a5)+,(a6)+
     dbf   d0,zeilen

bak	

off:
	rts

delay_1:

	bra.s linksw

delay_2:
	bra linksw


;Display ready buffer on the screen
show:

     move.l scrollbase,a5
	moveq #19,d0
	lea -160(a5),a5
cl	clr 4(a5)
	addq.l #8,a5

	dbra d0,cl


     move.w zanz,d0
     subq.w #1,d0

		
szeilen:
	move (a6),4+0(a5)
	move 8(a6),4+8(a5)
	move 16(a6),4+16(a5)
	move 24(a6),4+24(a5)
	move 32(a6),4+32(a5)
	move 40(a6),4+40(a5)
	move 48(a6),4+48(a5)
	move 56(a6),4+56(a5)
	move 64(a6),4+64(a5)
	move 72(a6),4+72(a5)
	move 80(a6),4+80(a5)
	move 88(a6),4+88(a5)
	move 96(a6),4+96(a5)
	move 104(a6),4+104(a5)
	move 112(a6),4+112(a5)
	move 120(a6),4+120(a5)
	move 128(a6),4+128(a5)
	move 136(a6),4+136(a5)
	move 144(a6),4+144(a5)
	move 152(a6),4+152(a5)

        lea 160(a6),a6
	lea 160(a5),a5

     dbf     d0,szeilen

     rts

;Prepare data-add-on buffer
addpuff:
     movem.l d0-d7/a0/a1,-(sp)
     move.w  zanz,d7
     subq.w  #1,d7             ;Line number as dbf
     move.w  teil,d6
     moveq   #8,d5
     move.l  zeichen1,d4
     cmp.w   #8,d6
     bne     puffer0  
     move.l  zeichen2,d5   ; 8+20+8+4=40c
     sub.l   d4,d5
	bra.s pfu0

puffer0:                      ;buffer 0 is never shifted
	bra ddd1   ; 10+10+10+10=40c
ddd1	bra ddd2
ddd2	bra pfu0
	

pfu0     move.w d7,d0
     lea puff,a0
     move.l d4,a1
puff0b:                       ;only left or right half of 32
     move.w 0(a1,d6.w),(a0)  ;pixels copied
	addq.l #8,a0

     add.l  #160,a1
     dbf    d0,puff0b

     move.w #6,d2            ;7 buffers, each 2 pixels
puff1a:
     move.w d2,d0
     move.w d2,d3
	add d3,d3

	add d0,d0

     lea puffer,a0
     move.l 0(a0,d0.w),a0     ;Buffer address to A0
     move.l d4,a1             ;Character address to A1
     move.w d7,d0             ;Line number to D0

puff1b:

     move.w 0(a1,d5.l),d1     ;Shift plane 0
     swap   d1
     move.w 0(a1,d6.w),d1
     rol.l  d3,d1
     move.w d1,(a0)+
     addq.l #6,a0


     add.l  #160,a1
     dbf    d0,puff1b         ;All lines

     subq.w #2,d2
     bne    puff1a            ;All 7 buffers

     movem.l (sp)+,d0-d7/a0/a1

     rts
fill2:
	move.l wholescr,a0
	move #7999,d0
fl:
	move.l #$12345678,(a0)+
	dbra d0,fl
	rts


        bss
	even
lines	ds.l 1
screen	ds.l 1
oldrez  ds.w 1
oldssp  ds.l 1
savepal ds.w 16
scrollbase ds.l 1
blocks  ds.b $2000*4
puff    ds.b $400
tabelle ds.l 64
stopflag	ds.w 1
old_mouse	ds.l 1
old_2		ds.l 1
keys		ds.w 1
old114		ds.l 1
key		ds.w 1
wholescr	ds.l 1
old_rez  ds.w 1
old_sp   ds.l 1
old_xb2	 ds.l 1
old_xb3  ds.l 1
old_pal  ds.l 8
handle	 ds.w 1
left_word	ds.w 1
left_word2	ds.w 1
logo_phase	ds.w 1
pic1c		ds.b 34
logo_v		ds.w 1
scrollba	ds.l 1

logo1	ds.b 96*80
logo2	ds.b 96*80
logo3	ds.b 96*80
logo4	ds.b 96*80
logo5	ds.b 96*80
logo6	ds.b 96*80
logo7	ds.b 96*80
logo8	ds.b 96*80

pic1d    ds.l 8000
whole	 ds.b 32000+8000+8000+256

	DATA
	EVEN

count	 ds.w 1
old	 ds.w 1
oldz     ds.w 1

logos:	dc.l logo1,logo2,logo3,logo4,logo5,logo6,logo7,logo8

colors:
	dc.w 0,4,0,145,0

change	dc.w 4

	dc.w $020,1,$030,1,$040,1,$050,1
	dc.w $050,1,$040,1,$030,1,$020,1,0,1
	dc.w $711,3,$722,3,$733,3,$744,3,$745,3,$746,3,$747,3
	dc.w $647,3,$547,3,$447,3,$337,3,$227,3,$117,3
	dc.w $020,1,$030,1,$040,1,$050,1
	dc.w $050,1,$040,1,$030,1,$020,1,0,1
	dc.w 0,200,0 
vertic:
	dc.w 160,320,480,800,960,960,960,800,480,320,160,160,0,0,0,160

phase_s	dc.l moves

para	dc.b 0,0,1,1

	even

	dc.w 2,1,$003,1,$004,1,$005,1,$006,1,$007,1
	dc.w $117,1,$227,1,$337,1,$447,1,$557,1,$667,1
	dc.w $557,1,$447,1,$337,1,$227,1,$117,1,$007,1
	dc.w $006,1,$005,1,$004,1,$003,1,$002,1
	dc.w $500,2,$400,3,$300,4,$200,5,$100,6

	dc.w 0,68                  
	dc.w $100,6,$200,5,$300,4,$400,3,$500,2

 	dc.w $002,1,$003,1,$004,1,$005,1,$006,1,$007,1
	dc.w $117,1,$227,1,$337,1,$447,1,$557,1,$667,1
	dc.w $557,1,$447,1,$337,1,$227,1,$117,1,$007,1
	dc.w $006,1,$005,1,$004,1,$003,1,$002,1
	dc.w 0

charpal:
	dc.w $700,$700,$700      ; change these!
	dc.l $700,$700,$700,$700 ; RGB for color 4
	dc.l $700,$700,$700,$700
	dc.l $700

	dc.l $400
	dc.l $500,$600,$700,$710,$720,$730,$740,$750,$760,$770
	dc.w $771,$772,$773,$772,$771,$770,$760,$750,$740,$730,$720
	dc.w $710,$700,$600,$500,$400

contr: dc.b 21,4,15,06
old4: dc.l 0
oldtb: dc.l 0
oldkey: dc.l 0
old07: dc.b 0
old09: dc.b 0
old0b: dc.b 0
old0d: dc.b 0
old0f: dc.b 0
old11: dc.b 0
old13: dc.b 0
old15: dc.b 0
old1b: dc.b 0
old21: dc.b 0

pic1	dc.b "A:\*.pi1",0

	even

nr: dc.w 0
zanz: dc.l 0
teil: dc.l 0
zeiger:dc.w 0
zeichen1:dc.l 0
zeichen2:dc.l 0

puffer: dc.l puff,puff+$100,puff+$200,puff+$300

     
irqtab: dc.l no0,no109,no210,no311
        dc.l no8,no109,no210,no311,scroll1

moves 	dc.l 0,160,320,480,640,800,960,1120,1280,1440,1600
	dc.l 1760,1920,2080,2240,2400,2560,2720,2880,3040
	dc.l 3200,3040,2880,2720,2560,2400,2240,2080,1920
	dc.l 1760,1600,1440,1280,1120,960,800,640,480,320,160
end_1:  dc.l 0


txt   dc.b " " ; space
 ; your text:
	dc.b " HI,GUYS! BLA BLA BLA BLAAA! BLABLABLA!      "
	DC.B " ... AND NOW, LET'S WRAP AROUND! .....      "
	DC.B "              **"

	even


picture:
        incbin "00000000.pi1"  ; get picture with characters, file
                               ; must be on this disk.
pict2 	incbin "00000000.pi1"  ; background picture
 
translation:    ; offset = 32
	dc.b 36,40,42,36,36,36,36,45,43,44,$40,36,37,41,38,47
	dc.b 26,27,28,29,30,31,32,33,34,35,39,36,36,36,36,46,36
	dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
	dc.b 19,20,21,22,23,24,25,36
	dc.b 36,36,36,36,36,36,36,36

