                bra     main
        
showblock:      
                move.l  physaddr(pc),a0
                lea     spriteblock,a1
                add.l   offset(pc),a1
                move.l  width(pc),d0
                move.l  height(pc),d1
                subq.l  #1,d1
                subq.l  #1,d0
                move.l  d0,spar1
omsb1:          move.l  a0,a2
                move.l  spar1(pc),d0
omsb2:          
                move.b  (a1)+,d2
                move.b  d2,(a2)+
                move.b  (a1)+,d2
                move.b  d2,(a2)+
                move.b  (a1)+,d2
                move.b  d2,(a2)+
                move.b  (a1)+,d2
                move.b  d2,(a2)+
                move.b  (a1)+,d2
                move.b  d2,(a2)+
                move.b  (a1)+,d2
                move.b  d2,(a2)+
                move.b  (a1)+,d2
                move.b  d2,(a2)+
                move.b  (a1)+,d2
                move.b  d2,(a2)+
                dbra    d0,omsb2
                clr.l   (a2)+
                clr.l   (a2)+
                lea     160(a0),a0
                dbra    d1,omsb1
                moveq   #19,d0
omsb3:          clr.l   (a0)+
                dbra    d0,omsb3
                rts

spar1:          dc.l    0


editor:         move.l  #1,width
                move.l  #1,height
                move.l  #0,offset
ome1:           bsr     showblock
                move.w  #2,-(sp)
                move.w  #2,-(sp)
                trap    #13
                addq.l  #4,sp
                cmp.w   #52,d0
                bne     forbie1
; left
                subq.l  #2,offset
forbie1:        cmp.w   #54,d0
                bne     forbie2
; right
                addq.l  #2,offset
forbie2:        cmp.w   #50,d0
                bne     forbie3
; down
                move.l  width,d1
                lsl.l   #3,d1
                add.l   d1,offset
forbie3:        cmp.w   #56,d0
                bne     forbie4
; up
                move.l  width,d1
                lsl.l   #3,d1
                sub.l   d1,offset
forbie4:        cmp.w   #40,d0
                bne     forbie5
; left parant
                sub.l   #1,width
forbie5:        cmp.w   #41,d0
                bne     forbie6
; right parant
                add.l   #1,width
forbie6:        
                cmp.w   #43,d0
                bne     forbie20
; plus
                addq.l  #1,height
forbie20:       cmp.w   #45,d0
                bne     forbie21
;minus
                subq.l  #1,height
forbie21:



                cmp.w   #32,d0
                bne     forbie7
; space
                bsr     paster
forbie7:        tst.l   width
                bgt     forbie9
                move.l  #1,width
forbie9:        tst.l   offset
                bpl     forbie10
                move.l  #0,offset
forbie10:       tst.l   height
                bgt     forbie22
                move.l  #1,height
forbie22:       

;forbie14:       cmp.w   #83,d0
;                bne     forbie15
;                jsr     savelevel
;forbie15:       cmp.w   #76,d0
;                bne     forbie16
;                jsr     loadlevel
;                jsr     newbackground
;forbie16:       cmp.w   #27,d0
;                bne     forbie17
;                move.l  scrollposx,d1
;                add.l   #19,d1
;                mulu    #24,d1
;                move.l  posy,d2
;                lsl.l   #1,d2
;                add.l   d2,d1
;                movea.l #level,a1
;                adda.l  d1,a1
;                moveq.l #0,d1
;                move.l  posy,d1
;                lsl.l   #1,d1
;                movea.l #backgrounds,a0
;                move.w  (a0,d1.w),d1
;                move.w  d1,(a1)
;forbie17:       cmp.w   #90,d0
;                bne     forbie18
;                jsr     newbackground
forbie18:       cmp.w   #81,d0
                bne     ome1
                rts     


pasteblock:     move.l  physaddr(pc),a1
                lea     pic(pc),a0
                move.l  #999,d0
ompb1:          movem.l (a0)+,d1-d7/a2
                movem.l d1-d7/a2,(a1)
                lea     32(a1),a1
                dbra    d0,ompb1
                move.l  xpos,d0
                lsl.l   #3,d0
                move.l  ypos,d1
                mulu    #160,d1
                add.l   d0,d1
                move.l  physaddr(pc),a1
                add.l   d1,a1
                lea     spriteblock,a0
                add.l   offset(pc),a0
                move.l  width,d0
                subq.l  #1,d0
                move.l  height,d1
                subq.l  #1,d1
                move.l  d0,spar1
ompb2:          move.l  a1,a2
                move.l  spar1(pc),d0
ompb3:          move.l  (a0)+,(a2)+
                move.l  (a0)+,(a2)+
                dbra    d0,ompb3
                lea     160(a1),a1
                dbra    d1,ompb2
                moveq   #0,d0
                rts
                

getpic:         lea     pic(pc),a1
                move.l  physaddr(pc),a0
                move.l  #999,d0
omgp1:          movem.l (a0)+,d1-d7/a2
                movem.l d1-d7/a2,(a1)
                lea     32(a1),a1
                dbra    d0,omgp1
                rts



paster:         move.l  #0,xpos
                move.l  #0,ypos
omp1:           bsr     pasteblock
                move.w  #2,-(sp)
                move.w  #2,-(sp)
                trap    #13
                addq.l  #4,sp
                cmp.w   #52,d0
                bne     forbip1
; left
                subq.l  #1,xpos
forbip1:        cmp.w   #54,d0
                bne     forbip2
; right
                addq.l  #1,xpos
forbip2:        cmp.w   #50,d0
                bne     forbip3
; down
                addq.l  #1,ypos
forbip3:        cmp.w   #56,d0
                bne     forbip4
; up
                subq.l  #1,ypos
forbip4:        
                cmp.w   #32,d0
                bne     forbip7
                bsr     getpic
; space
forbip7:        
                tst.l   xpos
                bpl     forbip9
                move.l  #0,xpos
forbip9:        tst.l   ypos
                bpl     forbip10
                move.l  #0,ypos
forbip10:       move.l  xpos,d1
                add.l   width,d1
                cmp.l   #20,d1
                blt     forbip11
                subq.l  #1,xpos
forbip11:       move.l  ypos,d1
                add.l   height,d1
                cmp.l   #200,d1
                blt     forbip12
                subq.l  #1,ypos
forbip12:

forbip18:       cmp.w   #81,d0
                bne     omp1
                moveq   #0,d0
                move.l  physaddr(pc),a0
                moveq   #0,d1
                move.l  #7999,d0
omp2:           move.l  d1,(a0)+
                dbra    d0,omp2
                rts     


xpos:           dc.l    0
ypos:           dc.l    0




loadfil:        move.w  #0,-(sp)
                move.l  d0,-(sp)
                move.w  #$3d,-(sp)
                trap    #1
                addq.l  #8,sp
                move.w  d0,handle
                move.l  d1,-(sp)
                move.l  d2,-(sp)
                move.w  handle,-(sp)
                move.w  #$3f,-(sp)
                trap    #1
                add.l   #12,sp
                move.l  d0,-(sp)
                move.w  handle,-(sp)
                move.w  #$3e,-(sp)
                trap    #1
                addq.l  #4,sp
                move.l  (sp)+,d0
                rts


savefil:        move.w  #0,-(sp)
                move.l  d0,-(sp)
                move.w  #$3c,-(sp)
                trap    #1
                addq.l  #8,sp
                move.w  d0,handle
                move.l  d1,-(sp)
                move.l  d2,-(sp)
                move.w  handle,-(sp)
                move.w  #$40,-(sp)
                trap    #1
                add.l   #12,sp
                move.w  handle,-(sp)
                move.w  #$3e,-(sp)
                trap    #1
                addq.l  #4,sp
                rts


loadfils:       
                move.l  #spritname,d0
                move.l  #spriteblock,d1
                move.l  #$7FFFFFFF,d2
                bsr     loadfil
                rts

initvars:
                move.w  #4,-(sp)
                trap    #14
                addq.l  #2,sp
                move.w  d0,oldres
                move.w  #2,-(sp)
                trap    #14
                addq.l  #2,sp
                move.l  d0,physaddr
                move.w  #0,-(sp)
                move.l  physaddr,-(sp)
                move.l  physaddr,-(sp)
                move.w  #5,-(sp)
                trap    #14
                adda.l  #12,sp
                move.l  #spalette,a0
                movem.l $ff8240,d0-d4/d6-d7/a1
                movem.l d0-d4/d6-d7/a1,(a0)
                move.l  #palette,a0
                movem.l (a0),d0-d4/d6-d7/a1
                movem.l d0-d4/d6-d7/a1,$ff8240
                move.l  physaddr,oldphys


                lea     tab160(pc),a0
                moveq   #0,d0
                move.l  #199,d1
ommt160:        move.l  d0,(a0)+
                dbra    d1,ommt160
                rts

restorestatus:
                move.w  oldres,-(sp)
                move.l  oldphys,-(sp)
                move.l  oldphys,-(sp)
                move.w  #5,-(sp)
                trap    #14
                add.l   #12,sp

                move.l  #$ff8240,a0
                move.l  #spalette,a2
                movem.l (a2),d0-d7
                movem.l d0-d7,(a0)





                rts


main:           
                move.l  a7,oldstck
                move.l  #ustck,a7
                move.l  #0,-(sp)
                move.w  #$20,-(sp)
                trap    #1
                addq.l  #6,sp
                move.l  d0,savestck

                bsr     initvars
                bsr     loadfils
                bsr     editor
                bsr     restorestatus

                move.l  savestck,-(sp)
                move.w  #$20,-(sp)
                trap    #1
                addq.l  #6,sp
                move.l  oldstck,a7
                illegal

handle:         dc.l    0
physaddr:       dc.l    0
savestck:       dc.l    0
oldstck:        dc.l    0
stck:           blk.l   100
ustck:          dc.l    0
                        
tab160:         blk.l   200,0
width:          dc.l    0
height:         dc.l    0
offset:         dc.l    0
oldphys:        dc.l    0
oldres:         dc.l    0

spritname:      dc.b    '\r_type.tbr\sprites.dat',0
palette:        dc.w    $000,$222,$555,$777,$200,$500,$733,$020
                dc.w    $422,$070,$457,$005,$027,$530,$333,$770

                dc.w    $000,$110,$220,$330,$440,$550,$660,$770
                dc.w    $771,4772,$773,$774,$775,$776,$777,$777
                dc.w    0,$111,$222,$333,$444,$010,$020
                dc.w    $300,$510,$630,$550,$003,$007,$227,$000,$777
spalette:       blk.l   8,0

bpic:           blk.b   128,0
pic:            blk.l   8000,0
spriteblock:    dc.l    10000


