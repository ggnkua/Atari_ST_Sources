;bzf,bze must be defined as bzf= 2^bze
;This version does X,Y,Z in the grid..
bzp     equ     bzf+1           ;no. of points..
;########################################################
dogrid
     move.w     #bzp-1,d0       ;no. of points -1 for dbra..
     lea        grid(pc),a2
blp  lea        beza(pc),a0
     lea        bez1(pc),a1
     jsr        dobez
     move.l     d7,0(a1)        ;x,y
     move.w     d6,4(a1)        ;z
     lea        bezb(pc),a0
     jsr        dobez
     move.l     d7,6(a1)        ;x,y
     move.w     d6,10(a1)       ;z
     lea        bezc(pc),a0
     jsr        dobez
     move.l     d7,12(a1)       ;x,y
     move.w     d6,16(a1)       ;z
     move.w     d0,-(sp)
     move.w     #bzp-1,d0       ;no. of points -1 for dbra
blq  lea        bez1(pc),a0
     bsr        dobez
     move.l     d7,(a2)+       ;x,y
     move.w     d6,(a2)+       ;z
     dbra       d0,blq
     move.w     (sp)+,d0
     dbra       d0,blp
     rts
;#################################
drawgrid
        lea     grid(pc),a2
        lea     6*bzp+grid(pc),a3     (6= x,y,z) 4 for x,y
        move.l  #bzf-1,d0  ;32 squares -1 for dbra
dglp    move.l  #bzf-1,d1
dglq    move.l  d1,d2
        lsl.l   #bze,d2   ;vert. offset
        add.l   d1,d2     ;+point 
        add.l   d0,d2
        add.l   d2,d2    ;\
        move.l  d2,d3    ; | *6 bytes/ vertice..
        add.l   d2,d2    ; | for x,y,z
        add.l   d3,d2    ;/
        lea     poly(pc),a6
        move.w  #3,2(a6)             ;no. of verts -1
        move.l  0(a2,d2.l),4(a6)     ;v1
        move.w  4(a2,d2.l),8(a6)     ;now have z in here
        move.l  6(a2,d2.l),10(a6)    ;v2
        move.w 10(a2,d2.l),14(a6)    ;z again
        move.l  6(a3,d2.l),16(a6)    ;v3
        move.w 10(a3,d2.l),20(a6)    ;z once more
        move.l  0(a3,d2.l),22(a6)    ;v4
        move.w  4(a3,d2.l),26(a6)    ;z the last time
        movem.l d0-d7/a0-a6,-(sp)
        jsr     planeset
        movem.l (sp)+,d0-d7/a0-a6
        dbra    d1,dglq
        dbra    d0,dglp
;       rts				;comment for no sides..
;###########################################    
dosides movem.l d0-d7/a0-a6,-(sp)
        lea     poly(pc),a6
        move.w  #bzp-1,2(a6)    ;no. of verts.
        lea     4(a6),a0
        lea     grid(pc),a2
        add.l   #6*bzp,a2
        move.w  #bzp-1,d0
bzmlp   move.w  -(a2),d1
        move.w  -(a2),d2
        move.w  -(a2),(a0)+
        move.w  d2,(a0)+
        move.w  d1,(a0)+
        dbra    d0,bzmlp
        jsr     planeset
        lea     poly(pc),a6
        move.w  #bzp-1,2(a6)    ;no. of verts.
        lea     4(a6),a0
        add.l   #6*bzp,a0
        lea     grid(pc),a2
        add.l   #6*bzp*bzp,a2
        move.w  #bzp-1,d0
bzmlq   move.w  -(a2),-(a0)
        move.w  -(a2),-(a0)
        move.w  -(a2),-(a0)
        dbra    d0,bzmlq
        jsr     planeset
        lea     poly(pc),a6
        move.w  #bzp-1,2(a6)    ;no. of verts.
        lea     4(a6),a0
        lea     grid(pc),a2
        move.w  #bzp-1,d0
bzmlr   move.w  0(a2),(a0)+
        move.w  2(a2),(a0)+
        move.w  4(a2),(a0)+
        lea     6*bzp(a2),a2
        dbra    d0,bzmlr
        jsr     planeset



        lea     poly(pc),a6
        move.w  #bzp-1,2(a6)    ;no. of verts.
        lea     4(a6),a0
        add.l   #6*bzp,a0
        lea     grid(pc),a2
        lea     6*bzf(a2),a2
        move.w  #bzp-1,d0
bzmls   move.w  4(a2),-(a0)
        move.w  2(a2),-(a0)
        move.w  0(a2),-(a0)
        lea     6*bzp(a2),a2
        dbra    d0,bzmls
        jsr     planeset
        movem.l (sp)+,d0-d7/a0-a6
        rts
;#######################################################
;NOW THE BEZIER FUNCTION (LINEAR)
;#######################################################
;Input:
;    0 T0: fraction, 0 - 31 (fixed point- $20 = 1)
;      A0: X',Y',X",Y",X'",Y"',Denominator(eg 16=4,32=5) (word array)
;          0  2  4   6  8  10  12
;Otput:
;      D7: X(HIword),Y(LOword)
;      D6: Z(LOword)
;Used:
;      d0,d1,d2,d3,d4,d5,d6,d7,a0,a1
;wasted: d1,d2,d3,d4,d5,d6,d7,a1 
;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
;```````````````````````````````````````
dobez   movem.l d0-d5/a0-a6,-(sp)
        move.w  d0,d1
        add.w   d0,d0
        add.w   d1,d0
        add.w   d0,d0
        lea     bztab(pc),a1
        lea     0(a1,d0.w),a1
        move.w  (a1)+,d2
        move.w  (a1)+,d1
        move.w  (a1)+,d0
;the stuff above this gets i^2,j^2,2ij in d1,d2,d0 resp.

     move.w    #2*bze,d3             ;double divisor

     move.w    (a0),d4     
     move.w    6(a0),d5
     move.w    12(a0),d6    ;this puts x0,x1,x2 in d4,5,6 resp.

     muls      d1,d4
     muls      d0,d5
     muls      d2,d6       ;i^2*x0, 2ij*x1, j^:*x2 in d4,5,6 resp. 
     lsr.l     d3,d4
     lsr.l     d3,d5
     lsr.l     d3,d6       ;perform the division

     move.l    d4,d7
     add.l     d5,d7
     add.l     d6,d7      ;X in d7 (d4+d5+d6)->d7
     swap      d7         ;In D7 HIGH

     move.w    2(a0),d4
     move.w    8(a0),d5
     move.w    14(a0),d6    ;this puts y0,y1,y2 in d<,=,6 resp. 

     muls      d1,d4
     muls      d0,d5
     muls      d2,d6        ;same again, but y
     lsr.l     d3,d4
     lsr.l     d3,d5
     lsr.l     d3,d6        ;perform the division

     add.l    d4,d6
     add.l    d5,d6         ;y in d6
     move.w   d6,d7         ;now in d7 LOW

     move.w    4(a0),d4
     move.w    10(a0),d5
     move.w    16(a0),d6    ;this puts z0,z1,z2 in d<,=,6 resp. 

     muls      d1,d4
     muls      d0,d5
     muls      d2,d6        ;same again, but z
     lsr.l     d3,d4
     lsr.l     d3,d5
     lsr.l     d3,d6        ;perform the division

     add.l     d4,d6
     add.l     d5,d6        ;z in d6

     movem.l   (sp)+,d0-d5/a0-a6
     rts
;########################################
bztab
bz      set   bzf 
count   set   0
        rept  bzp
        dc.w  count*count,(bz-count)*(bz-count),2*count*(bz-count)
count   set   count+1
        endr
bez1    ds.w    3*3
grid    ds.w    bzp*(bzp+1)*3    ;3 for x,y,z        
; THE ABOVE IS ALL ESSENTIAL TO BEZIER FN        

