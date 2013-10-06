;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routine de face personnelle ; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 lea.l 12(sp),sp
 pea routine
 move.w #$26,-(sp)
 trap #14
 addq.l #6,sp
 clr -(sp)
 trap #1

routine
 clr.w $ffff8240.w
 move.w #$720,$ffff8242.w
 move.w #$777,$ffff8246.w

prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 clr.w $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

; efface ancienne face

 lea.l clr_buf,a0
fin_reg move.l #clr_buf2,d1
 moveq.w #0,d0
clr_face
 movem.l (a0)+,a1-a6
 move.w d0,(a1)
 move.w d0,(a2)
 move.w d0,(a3)
 move.w d0,(a4)
 move.w d0,(a5)
 move.w d0,(a6)
 cmp.l d1,a0
 blo.s clr_face

; prepare le tableau

 lea.l table,a0
 move.w #160,d0
 move.w #50,d1
 move.w #80,d2
 move.w #150,d3
 bsr line

 lea.l table,a0
 move.w #80,d0
 move.w #150,d1
 move.w #240,d2
 move.w #150,d3
 bsr line

 lea.l table,a0
 move.w #240,d0
 move.w #150,d1
 move.w #160,d2
 move.w #50,d3
 bsr line

; addq.w #1,x1+2
; addq.w #1,x2+2

; trace la face

 lea.l $1f8000,a6
 lea.l table,a0
 move.w #199,d7
fill_face
 move.w (a0)+,d0
 cmp.w #$ffff,d0
 beq.s fill_face2
 move.w (a0),d1
 move.l a6,a1
 bsr fill_line
fill_face2
 addq.w #2,a0
 lea.l $a0(a6),a6
 dbf d7,fill_face

; efface le tableau

 lea.l table,a0
 move.w #199,d0
 move.l #$ffffffff,d1
clr_table
 move.l d1,(a0)+
 dbf d0,clr_table

 cmpi.b #$36,$fffffc02.w
 bne.s no_shift
 move.w #$027,$ffff8240.w
no_shift
 bra prog

fill_line
 move.w #$ffff,d0
 move.w #$ffff,d1
 move.w #$ffff,d2
 bsr fill_code
 rts

fill_code
 or.w d0,(a1)
 addq.w #8,a1
 rept 19
 move.w d1,(a1)
 addq.w #8,a1
 endr
 rts

line
 cmp.w d1,d3
 bhi.s ok_y
 exg d0,d2
 exg d1,d3
ok_y
 sub.w d0,d2
 sub.w d1,d3

 move.w d3,d6
 mulu.w #4,d1
 add.w d1,a0
 cmp.w #$ffff,(a0)
 beq.s ok_tab
 addq.w #2,a0
 cmp.w #$ffff,(a0)
 beq.s ok_tab
 rts
ok_tab 

 tst.w d3
 bne.s ok_trace
 move.w d0,(a0)+
 add.w d0,d2		Retrouve X2
 move.w d2,(a0)
 rts
ok_trace

 moveq.w #1,d4
 tst.w d2
 bpl.s ok_x
 move.w #$111,$ffff8240.w 
 neg.w d4
 neg.w d2
ok_x

 cmp.w d2,d3
 blo.s line_x

line_y
 cmp.w d2,d3
 beq diagonale

 swap d2
 divu.w d3,d2
 moveq.w #0,d7
line_y2
 move.w d0,(a0)
 addq.l #4,a0
 add.w d2,d7
 bcc.s line_y3
 add.w d4,d0
line_y3
 dbf d6,line_y2
 rts

line_x
 swap d3
 divu.w d2,d3
 moveq.w #0,d7
line2 
 move.w d0,(a0)
 add.w d4,d0
 add.w d3,d7
 bcc.s line2
 addq.l #4,a0
 dbf d6,line2
 rts

diagonale
 move.w d3,d6
 mulu.w #4,d1
 add.w d1,a0
 cmp.w #$ffff,(a0)
 beq.s ok_tab3
 addq.w #2,a0
 cmp.w #$ffff,(a0)
 beq.s ok_tab3
 rts
ok_tab3
diago1
 move.w d0,(a0)
 add.w d4,d0
 addq.l #4,a0
 dbf d6,diago1
 rts

end
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
 rts

table
 dcb.w 200*2,$ffff

clr_buf
 dcb.l 600,$1f8000
clr_buf2
 dcb.l 10,$1f8000

pix_debut 
n set 0
 rept 20
 dc.w n,$ffff,n,32767,n,16383,n,8191
 dc.w n,4095,n,2047,n,1023,n,511,n,255
 dc.w n,127,n,63,n,31,n,15,n,7,n,3,n,1
n set n+8
 endr

pix_fin
n set 0
 rept 20
 dc.w n,32768,n,49152,n,57344,n,61440
 dc.w n,63488,n,64512,n,65024,n,65280
 dc.w n,65408,n,65472,n,65504,n,65520
 dc.w n,65528,n,65532,n,65534,n,65535
n set n+8
 endr
