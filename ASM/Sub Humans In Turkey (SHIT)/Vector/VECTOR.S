        
        opt O1+,O2+,OW-,T+

halfmeg equ     1       ;halfmeg = 0 ; 1 meg or more = 1

;start of prog
;exec rest in supervisor mode
;

        move.l a7,a6
        move.l 4(a6),a6
        pea $200
        pea (a6)
        pea $4a0000
        trap #1
        lea 12(sp),sp


        clr.l   -(a7)
        move.w  #32,-(a7)
        trap    #1
        add.w   #6,a7

        move.l  d0,oldstack
        lea     stack+2048(pc),a7

        bsr     main_program

        bsr     disable.lowborder

        move.l  save_118,$118

        pea     enablemouse(pc)
        move.w  #1,-(sp)
        move.w  #25,-(sp)
        trap    #14
        addq.l  #8,a7
        dc.w    $a009

        move.w  cur_rez,-(sp)
        move.l  oldscbase,-(sp)
        move.l  oldscbase,-(sp)
        move.w  #5,-(sp)
        trap    #14
        add.l   #12,sp

        move.w  sav_484,$484.w
        movem.l sav_cols,d0-d7
        movem.l d0-d7,$ff8240

        move.w  #$2700,sr
        move.l  #$a0a0000,$ff8800
        move.l  #$9090000,$ff8800
        move.l  #$8080000,$ff8800
        clr.l   $4d2
        clr.l   $4d6
        move.w  #$2300,sr
        move.l  oldstack,-(sp)
        move.w  #$20,-(sp)
        trap    #1
        addq.l  #6,sp

        pea     env
        pea     com
        move.l  file,-(sp)
        move.w  #0,-(sp)
        move.w  #$4b,-(sp)
        trap    #1
        add.l   #16,sp

        clr.w   -(a7)
        trap    #1

;
;main program start
;
;
;
main_program
        pea     disablemouse(pc)        ;disable mouse
        move.w  #0,-(sp)                ;
        move.w  #25,-(sp)               ;
        trap    #14                     ;
        addq.l  #8,a7                   ;
        dc.w    $a00a
        
        move.w  #4,-(sp)                ;store current rez
        trap    #14                     ;
        add.w   #2,sp                   ;
        move.w  d0,cur_rez              ;

        move.w  #2,-(sp)
        trap    #14
        addq.l  #2,sp
        move.l  d0,oldscbase
        
        move.w  #0,-(sp)                ;set low rez
        move.l  scrbase,-(sp)
        move.l  scrbase,-(sp)
        move.w  #5,-(sp)                ;
        trap    #14                     ;
        add.w   #12,sp                  ;
        
        movem.l $ffff8240.w,d0-d7       ;save colour registers
        movem.l d0-d7,sav_cols
        
        lea     balls+2,a0
        movem.l (a0),d0-d7              ;put new colours in regs.
        movem.l d0-d7,$ffff8240.w
        movem.l d0-d7,old_colour
        

        move.w  #$ffff,-(a7)
        move.w  #$ffff,-(a7)
        move.w  #35,-(a7)
        trap    #14
        add.w   #6,a7

        move.w  #20,-(a7)
        move.w  #4,-(a7)
        move.w  #3,-(a7)
        trap    #13
        add.w   #6,a7
        
        move.w  $484,sav_484
        clr.w   $484

        move.l  $118,save_118
;       move.l  #key_int,$118

        move.l  a0,a1                   ;blank low border
        move.l  scrbase,a1
        move.l  oldbase,a2
        add.l   #200*160,a1             ;
        add.l   #200*160,a2
        move    #47*40,d0               ;
.loop1  clr.l   (a1)+                   ;
        clr.l   (a2)+
        dbf     d0,.loop1               ;

        move.l  $462,d0                 ;wait on vblank
.wait2  cmp.l   $462,d0                 ;
        beq.s   .wait2                  ;


do_rotation
        lea     space,a0
        move.w  #$4000,d0
.loop1  clr.l   (a0)+
        dbf     d0,.loop1
        bsr     make_16
        bsr     set_up_message

        lea     balls+34,a0
        move.l  scrbase,a1
        move.l  oldbase,a2
        move.w  #$1f3f,d0
.loop   clr.l   (a1)+
        clr.l   (a2)+
        dbf     d0,.loop

play_music
        bsr     enable.lowborder        ;init HBL & VBL routines

        move.l  #1,d0
        jsr     music1
        move.l  #vbl1,$4d2


        move.l  a0,a1                   ;blank low border
        move.l  scrbase,a1
        add.l   #200*160,a1             ;
        move    #47*40,d0               ;
.loop1  clr.l   (a1)+                   ;
        dbf     d0,.loop1               ;

        bra     code_start


make_16 
        moveq.l #0,d0
        moveq.l #0,d1
        moveq.l #0,d2
        moveq.l #0,d3
        moveq.l #0,d4
        moveq.l #0,d5
        moveq.l #0,d6
        moveq.l #0,d7
        lea     space,a3
        move.l  #0,rotate
.ml1    lea     balls+34,a2
        move.l  d0,d1
        lsl.l   #3,d1
        add.l   d1,a2
        move.w  rotate,d5
        bsr.s   make_char_16
        addq.w  #1,d0
        cmp.w   #16,d0
        bne.s   .ml1
        moveq.l #0,d0
        addq.w  #1,rotate
        cmp.w   #16,rotate
        bne.s   .ml1
        rts

make_char_16
        moveq   #15,d1
.mc1    moveq   #3,d2
.mc2    clr.l   d4
        move.w  (a2)+,d4
        swap    d4
        lsr.l   d5,d4
        move.w  d4,8(a3)
        swap    d4
        or.w    d4,(a3)+
        dbf     d2,.mc2
        lea     152(a2),a2
        lea     8(a3),a3
        dbf     d1,.mc1
        rts

;       d0 sprite #
;       d1 x position
;       d2 y position
plot_sprite
        movem.l d0-a6,-(a7)
;       lea     $200000,a5
        lea     space,a0
        subq.w  #1,d0
        lsl.l   #8,d0
        add.w   d0,a0
        move.l  scrbase,a1
        move.l  d2,d3
        lsl.l   #5,d2
        lsl.l   #7,d3
        add.l   d2,d3
        add.l   d3,a1
        move.l  d1,d2
        and.l   #$fff0,d2
        lsr     #1,d2
        add.w   d2,a1
        and.l   #$f,d1
        moveq.l #12,d3
        lsl.l   d3,d1
        add.l   d1,a0
        rept    8
        movem.w (a0),d0-d3
        or.w    d2,d3
        or.w    d1,d3
        or.w    d0,d3
        move.l  d3,d4
        swap    d3
        move.w  d4,d3
        not.l   d3
        and.l   d3,(a1)
        and.l   d3,4(a1)
        movem.w 8(a0),d0-d3
        or.w    d2,d3
        or.w    d1,d3
        or.w    d0,d3
        move.l  d3,d4
        swap    d3
        move.w  d4,d3
        not.l   d3
        and.l   d3,8(a1)
        and.l   d3,12(a1)
        movem.w 16(a0),d0-d3
        or.w    d2,d3
        or.w    d1,d3
        or.w    d0,d3
        move.l  d3,d4
        swap    d3
        move.w  d4,d3
        not.l   d3
        and.l   d3,160(a1)
        and.l   d3,164(a1)
        movem.w 24(a0),d0-d3
        or.w    d2,d3
        or.w    d1,d3
        or.w    d0,d3
        move.l  d3,d4
        swap    d3
        move.w  d4,d3
        not.l   d3
        and.l   d3,168(a1)
        and.l   d3,172(a1)
        movem.l (a0),d0-d7
        or.l    d0,(a1)
        or.l    d1,4(a1)
        or.l    d2,8(a1)
        or.l    d3,12(a1)
        or.l    d4,160(a1)
        or.l    d5,164(a1)
        or.l    d6,168(a1)
        or.l    d7,172(a1)
        lea     32(a0),a0
        lea     320(a1),a1
        endr
        movem.l (a7)+,d0-a6
.end    rts


****************************************************
**  The following variables should be             **
**  set up too ;-                                 **
**  centx, centy, centz     centre of rotation    **
**  rotx, roty, rotz,       angle of rotation     **
**  transx, transy, transz  translation of point  **
****************************************************
 
makerot
        movem.l d0-d7/a0-a6,-(a7)       * Save registers

matinit
        move.w  #0,d1                   * Initialise matrix
        move.w  #16384,d2               * Sin(90)
        move.w  d2,matrix11     
        move.w  d1,matrix12             * 1  0  0
        move.w  d1,matrix13             * 0  1  0
        move.w  d1,matrix21             * 0  0  1
        move.w  d2,matrix22
        move.w  d1,matrix23     
        move.w  d1,matrix31     
        move.w  d1,matrix32
        move.w  d2,matrix33


zrotate
        move.w  rotz,d0
        beq     yrotate
        jsr     sincos
        move.w  d1,sinz
        move.w  d2,cosz
        move.w  d1,d3
        move.w  d2,d4
        muls    matrix11,d2
        muls    matrix12,d1
        sub.l   d1,d2
        lsl.l   #2,d2
        swap    d2
        move.w  d2,rotx11
        move.w  d3,d1
        move.w  d4,d2
        muls    matrix21,d2
        muls    matrix22,d1
        sub.l   d1,d2
        lsl.l   #2,d2
        swap    d2
        move.w  d2,rotx21
        move.w  d3,d1
        move.w  d4,d2
        muls    matrix31,d2
        muls    matrix32,d1
        sub.l   d1,d2
        lsl.l   #2,d2
        swap    d2
        move.w  d2,rotx31
        move.w  d3,d1
        move.w  d4,d2
        muls    matrix11,d1
        muls    matrix12,d2
        add.l   d1,d2
        lsl.l   #2,d2
        swap    d2
        move.w  d2,rotx12
        move.w  d3,d1
        move.w  d4,d2
        muls    matrix21,d1
        muls    matrix22,d2
        add.l   d1,d2
        lsl.l   #2,d2
        swap    d2
        move.w  d2,rotx22
        muls    matrix31,d3
        muls    matrix32,d4
        add.l   d3,d4
        lsl.l   #2,d4
        swap    d4
        move.w  d4,rotx32
        move.w  matrix13,rotx13
        move.w  matrix23,rotx23
        move.w  matrix33,rotx33
        move.l  #8,d7
        move.l  #rotx11,a1
        move.l  #matrix11,a2
        
zrotlop1
        move.w  (a1)+,(a2)+
        dbra    d7,zrotlop1

yrotate
        move.w  roty,d0
        beq     xrotate
        jsr     sincos
        move.w  d1,siny
        move.w  d2,cosy
        move.w  d1,d3
        move.w  d2,d4
        muls    matrix11,d2
        muls    matrix13,d1
        add.l   d1,d2
        lsl.l   #2,d2
        swap    d2
        move.w  d2,rotx11
        move.w  d3,d1
        move.w  d4,d2
        muls    matrix21,d2
        muls    matrix23,d1
        add.l   d1,d2
        lsl.l   #2,d2
        swap    d2
        move.w  d2,rotx21
        move.w  d3,d1
        move.w  d4,d2
        muls    matrix31,d2
        muls    matrix33,d1
        add.l   d1,d2
        lsl.l   #2,d2
        swap    d2
        move.w  d2,rotx31
        neg.w   d3
        move.w  d3,d1
        move.w  d4,d2
        move.w  matrix12,rotx12
        move.w  matrix22,rotx22
        move.w  matrix32,rotx32
        muls    matrix11,d1
        muls    matrix13,d2
        add.l   d1,d2
        lsl.l   #2,d2
        swap    d2
        move.w  d2,rotx13
        move.w  d3,d1
        move.w  d4,d2
        muls    matrix21,d1
        muls    matrix23,d2
        add.l   d1,d2
        lsl.l   #2,d2
        swap    d2
        move.w  d2,rotx23
        muls    matrix31,d3
        muls    matrix33,d4
        add.l   d3,d4
        lsl.l   #2,d4
        swap    d4
        move.w  d4,rotx33
        move.l  #8,d7
        move.l  #rotx11,a1
        move.l  #matrix11,a2
        
yrotlop1
        move.w  (a1)+,(a2)+
        dbra    d7,yrotlop1

xrotate
        move.w  rotx,d0
        beq     makerotend
        jsr     sincos
        move.w  d1,sinx
        move.w  d2,cosx
        move.w  d1,d3
        move.w  d2,d4
        move.w  matrix11,rotx11
        move.w  matrix21,rotx21
        move.w  matrix31,rotx31
        muls    matrix12,d2
        muls    matrix13,d1
        sub.l   d1,d2
        lsl.l   #2,d2
        swap    d2
        move.w  d2,rotx12
        move.w  d3,d1
        move.w  d4,d2
        muls    matrix22,d2
        muls    matrix23,d1
        sub.l   d1,d2
        lsl.l   #2,d2
        swap    d2
        move.w  d2,rotx22
        move.w  d3,d1
        move.w  d4,d2
        muls    matrix32,d2
        muls    matrix33,d1
        sub.l   d1,d2
        lsl.l   #2,d2
        swap    d2
        move.w  d2,rotx32
        move.w  d3,d1
        move.w  d4,d2
        muls    matrix12,d1
        muls    matrix13,d2
        add.l   d1,d2
        lsl.l   #2,d2
        swap    d2
        move.w  d2,rotx13
        move.w  d3,d1
        move.w  d4,d2
        muls    matrix22,d1
        muls    matrix23,d2
        add.l   d1,d2
        lsl.l   #2,d2
        swap    d2
        move.w  d2,rotx23
        muls    matrix32,d3
        muls    matrix33,d4
        add.l   d3,d4
        lsl.l   #2,d4
        swap    d4
        move.w  d4,rotx33
        move.l  #rotx11,a1
        move.l  #matrix11,a2
        move.l  #9,d7
        subq.l  #1,d7
        
rotxlop1
        move.w  (a1)+,(a2)+
        dbra    d7,rotxlop1
makerotend
        movem.l (a7)+,d0-d7/a0-a6       * Restore Registers
        rts
        
****************************************************
**  Pass X,Y and Z coords of point to be rotated  **
**  in d0-d2, the rotated values are returned in  **
**  d0-d2 also. Ensure that makerot has been done **
**  first !!!                                     **
****************************************************
        
rotate_axis
        movem.l d3-d7/a0-a6,-(a7)       * Save out registers
        sub.w   centx,d0                * Add Pre- offset
        sub.w   centy,d1
        sub.w   centz,d2
        move.w  d0,d4                   * Back up X,Y,Z coords
        move.w  d1,d5   
        move.w  d2,d6

        muls    matrix11,d0     * Calculate new X coord
        muls    matrix21,d1
        muls    matrix31,d2
        add.l   d0,d1
        add.l   d1,d2
        lsl.l   #2,d2
        swap    d2
        add.w   centx,d2                * Add Post- offset      
        add.w   transx,d2               * Apply X translate
        move.w  d2,-(a7)                * Stack new X

        move.w  d4,d0           * Reload X,Y,Z values
        move.w  d5,d1
        move.w  d6,d2

        muls    matrix12,d0     * Matrix mult for new Y
        muls    matrix22,d1
        muls    matrix32,d2
        add.l   d0,d1
        add.l   d1,d2
        lsl.l   #2,d2
        swap    d2
        add.w   centy,d2                * Add Post- offset
        add.w   transy,d2               * Apply Y translate
        move.w  d2,-(a7)                * Stack new Y

        muls    matrix13,d4     * Matrix mult for new Z
        muls    matrix23,d5
        muls    matrix33,d6
        add.l   d4,d5
        add.l   d5,d6
        lsl.l   #2,d6
        swap    d6
        add.w   centz,d6                * Add Post- offset
        add.w   transz,d6               * Apply Z translate
        move.w  d6,d2           * 
        move.w  (a7)+,d1                * Restore Y and X from stack
        move.w  (a7)+,d0

        movem.l (a7)+,d3-d7/a0-a6       * Pull back registers
        rts


sincos: tst.w   d0
        bpl     noaddi
        add.w   #360,d0
        
noaddi: move.l  #sintab,a1
        move.l  d0,d2
        lsl.w   #1,d0
        move.w  0(a1,d0.w),d1
        cmp.w   #270,d2
        blt     plus9
        sub.w   #270,d2
        bra     sendsin
        
plus9:  add.w   #90,d2

sendsin:        lsl.w   #1,d2
        move.w  0(a1,d2.w),d2
        rts

MOVE_MESSAGE
                move.w  PAUSE,d0
                tst.w   d0
                beq.s   mo_me_1
                
                subq.w  #1,d0
                move.w  d0,PAUSE
                bra     move_it         Move the Message
mo_me_1
                move.l  TEXT_POSITION,a0
                lea     LETTER_DATA,a1
mo_me_2
                clr.l   d0
                move.b  (a0)+,d0
                tst.w   d0
                beq.s   pause1
                cmp.b   #1,d0
                bne.s   change_it       Change the Message
reset_message
                lea     message,a0
                move.l  a0,TEXT_POSITION
                bra.s   mo_me_2

pause1          
                move.b  (a0)+,d0
                move.w  d0,PAUSE
                move.l  a0,TEXT_POSITION
                rts
change_it                       *       Now we must change the movement
                                *       variables for the new positions
                sub.w   #64,d0
                lsl.w   #5,d0
                lea     TEXT_DATA,a2
                add.l   d0,a2
                move.l  a2,(a1)+
                
                move.w  #7,d7
mo_me_3
                move.w  4(a1),d0        Old X
                move.w  6(a1),d1        Old Y
                move.w  (a2)+,d2        New X
                move.w  (a2)+,d3        New Y
                
                sub.w   d0,d2           U
                sub.w   d1,d3           V
                
                move.l  #0,a3
                move.l  a3,a4
                move.l  a3,a5
                move.l  a3,a6
                
                tst.w   d2
                beq.s   mo_me_5
                bpl.s   mo_me_4
                move.w  #-1,a3          d1x
                neg.w   d2              m
                bra.s   mo_me_5
mo_me_4
                move.w  #1,a3           d1x
mo_me_5
                tst.w   d3
                beq.s   mo_me_7
                bpl.s   mo_me_6
                move.w  #-1,a4          d1y
                neg.w   d3              n
                bra.s   mo_me_7
mo_me_6
                move.w  #1,a4           d1y
mo_me_7
                cmp.w   d2,d3
                blt.s   mo_me_8         If m>n then jump, else
                move.w  a4,a6           d2y
                exg     d2,d3           swap (m,n)
                bra.s   mo_me_9
mo_me_8
                move.w  a3,a5           d2x
mo_me_9
                move.w  d2,d4
                lsr.w   #1,d4           s
                
                *       Store the stuff away, now !
                
                move.w  d4,(a1)+
                move.w  d2,(a1)+
                addq.l  #4,a1
                move.w  d3,(a1)+
                move.w  d2,(a1)+
                move.w  a3,(a1)+
                move.w  a4,(a1)+
                move.w  a5,(a1)+
                move.w  a6,(a1)+
                
                dbf     d7,mo_me_3
                bra     mo_me_2
                
move_it
                lea     LETTER_DATA,a0
                move.w  #31,d7
mo_me_10
                addq.l  #4,a0
                move.w  #7,d6
mo_me_11
                movem.w (a0),d0-d5/a1-a4
                tst.w   d1
                beq.s   mo_me_next
                
                subq.w  #1,d1           Let i=i-1
                add.w   d4,d0           s=s+n
                cmp.w   d0,d5
                bge.s   mo_me_12        If s<m then jump, else
                
                sub.w   d5,d0           s=s-m
                add.w   a1,d2           x=x+d1x
                add.w   a2,d3           y=y+d1y
                bra.s   mo_me_14
mo_me_12
                add.w   a3,d2           x=x+d2x
                add.w   a4,d3           y=y+d2y
mo_me_14
                movem.w d0-d5/a1-a4,(a0)
mo_me_next
                lea     20(a0),a0
                
                dbf     d6,mo_me_11
                dbf     d7,mo_me_10
                rts


DRAW_MESSAGE
                move.l  #$003c0003,MESS_X_COORD
                lea     LETTER_DATA,a0
                move.w  #19,d6
dr_me_1
                move.w  #3,d7
dr_me_2
                move.w  8(a0),d0
                move.w  10(a0),d1
                lea     20(a0),a0
                move.w  8(a0),d2
                move.w  10(a0),d3
                lea     20(a0),a0
                
                add.w   MESS_X_COORD,d0
                add.w   MESS_X_COORD,d2
                add.w   MESS_Y_COORD,d1
                add.w   MESS_Y_COORD,d3
                
                movem.l d6-d7/a0,-(a7)
                bsr     DRAW_A_LINE
                movem.l (a7)+,d6-d7/a0
                
                dbf     d7,dr_me_2
                
                add.w   #10,MESS_X_COORD
                addq.l  #4,a0
                dbf     d6,dr_me_1
                rts
                
DRAW_A_LINE
                cmp.w   d1,d3
                beq     DRAW_HORIZONTAL
                cmp.w   d0,d2
                beq     DRAW_VERTICAL

                move.w  d0,d5
                move.w  d1,d6
                ext.l   d5
                ext.l   d6
                lsl.w   #1,d6
                lea     SCREEN_Y_TABLE,a0
                move.l  #0,a1
                move.w  (a0,d6),a1
                move.l  scrbase,a0
                add.l   a1,a0
                and.l   #$fffffff0,d5
                lsr.w   #1,d5
                add.l   d5,a0
                move.w  d0,d5
                eor.w   #$0f,d5
                and.w   #$0f,d5
                clr.w   d6
                bset    d5,d6
                move.w  d6,d7           OR Mask
                not.w   d6              AND Mask

                sub.w   d0,d2           u
                sub.w   d1,d3           v

                move.l  #0,a1
                move.l  #0,a2
                move.l  #0,a3
                move.l  #0,a4
                
                tst.w   d2
                bpl.s   .dr_1
                beq.s   .dr_2
                move.w  #-1,a1          d1x
                neg.w   d2              M
                bra.s   .dr_2
.dr_1
                move.w  #1,a1           d1x
.dr_2
                tst.w   d3
                bpl.s   .dr_3
                beq.s   .dr_4
                move.w  #-1,a2          d1y
                neg.w   d3              N
                bra.s   .dr_4
.dr_3
                move.w  #1,a2           d1y
.dr_4
                cmp.w   d2,d3
                blt.s   .dr_5
                move.w  a2,a4           d2y
                exg     d2,d3
                bra.s   .dr_6
.dr_5
                move.w  a1,a3           d2x
.dr_6 
                move.w  d2,d0
                lsr.w   #1,d0           S
                move.w  d2,d1           I

*               d0: S, d1: I, d2: M, d3: N, d6:AND Mask, d7:OR Mask
*               a0: Screen, a1: d1x, a2:d1y, a3:d2x, a5:d2y
.dr_7
*               PLOT THE POINT

                and.w   d6,(a0)
                or.w    d7,2(a0)
                or.w    d7,4(a0)
                or.w    d7,6(a0)

                add.w   d3,d0
                cmp.w   d0,d2
                bgt.s   .dr_8
        
                sub.w   d2,d0
                
                cmp.w   #0,a1
                beq.s   .dr_A5
                bmi.s   .dr_A6
                ror.w   #1,d6
                ror.w   #1,d7
                bcc.s   .dr_A5
                addq.l  #8,a0
                bra.s   .dr_A5
.dr_A6
                rol.w   #1,d6
                rol.w   #1,d7
                bcc.s   .dr_A5
                subq.l  #8,a0
.dr_A5
                cmp.w   #0,a2
                beq.s   .dr_A3
                bmi.s   .dr_A8
                lea     160(a0),a0
                bra.s   .dr_A3
.dr_A8
                lea     -160(a0),a0
                bra.s   .dr_A3
.dr_8
                cmp.w   #0,a3
                beq.s   .dr_A1
                bmi.s   .dr_A2
                ror.w   #1,d6
                ror.w   #1,d7
                bcc.s   .dr_A3
                addq.l  #8,a0
                bra.s   .dr_A3
.dr_A2
                rol.w   #1,d6
                rol.w   #1,d7
                bcc.s   .dr_A3
                subq.l  #8,a0
                bra.s   .dr_A3
.dr_A1
                cmp.w   #0,a4
                bmi.s   .dr_A4
                lea     160(a0),a0
                bra.s   .dr_A3
.dr_A4
                lea     -160(a0),a0
.dr_A3
                dbf     d1,.dr_7        
                rts

DRAW_HORIZONTAL
                cmp.w   d0,d2
                bne.s   .dr_h_1
                rts
.dr_h_1
                bgt.s   .dr_h_2
                exg     d0,d2
.dr_h_2
                move.w  d0,d5
                move.w  d1,d6
                ext.l   d5
                ext.l   d6
                lsl.w   #1,d6
                lea     SCREEN_Y_TABLE,a0
                move.l  #0,a1
                move.w  (a0,d6),a1
                move.l  scrbase,a0
                add.l   a1,a0
                and.l   #$fffffff0,d5
                lsr.w   #1,d5
                add.l   d5,a0

                move.w  d2,d3
                move.w  d0,d6
                
                and.w   #$fff0,d6
                lsr.w   #4,d6
                and.w   #$fff0,d2
                lsr.w   #4,d2
                
                sub.w   d6,d2

                lea     PIXEL_TABLE_LEFT,a1
                and.w   #$000f,d0
                lsl.w   #1,d0
                move.w  (a1,d0),d0
                lea     PIXEL_TABLE_RIGHT,a1
                and.w   #$000f,d3
                lsl.w   #1,d3
                move.w  (a1,d3),d3

                tst     d2
                bne.s   .dr_h_7
                
                and.w   d0,d3
                move.w  d3,d6
                move.w  d3,d7
                not.w   d7
                bra.s   .dr_h_m_1
.dr_h_7
                subq.w  #1,d2
                bne.s   .dr_h_8
                
                move.w  d0,d6
                move.w  d0,d7
                not.w   d7
                bsr     .dr_h_m_1
                
                move.w  d3,d6
                move.w  d3,d7
                not.w   d7
                bra.s   .dr_h_m_1
.dr_h_8
                move.w  d0,d6
                move.w  d0,d7
                not.w   d7
                bsr     .dr_h_m_1

                subq.w  #1,d2
                move.w  #$ffff,d6
                clr.w   d7
.dr_h_9
                bsr     .dr_h_m_1
                dbf     d2,.dr_h_9
                
                move.w  d3,d6
                move.w  d3,d7
                not.w   d7

.dr_h_m_1       
                and.w   d7,(a0)+                
                or.w    d6,(a0)+                
                or.w    d6,(a0)+                
                or.w    d6,(a0)+                
                rts

DRAW_VERTICAL
                cmp.w   d1,d3
                bgt.s   .dr_v_1
                exg     d1,d3
.dr_v_1
                move.w  d0,d5
                move.w  d1,d6
                ext.l   d5
                ext.l   d6
                lsl.w   #1,d6
                lea     SCREEN_Y_TABLE,a0
                move.l  #0,a1
                move.w  (a0,d6),a1
                move.l  scrbase,a0
                add.l   a1,a0
                and.l   #$fffffff0,d5
                lsr.w   #1,d5
                add.l   d5,a0

                eor.w   #$0f,d0
                and.w   #$0f,d0
                clr.w   d6
                bset    d0,d6
                move.w  d6,d7           OR Mask
                not.w   d7              AND Mask

                sub.w   d1,d3           Height
.dr_v_m_1
                and.w   d7,(a0)+
                or.w    d6,(a0)+
                or.w    d6,(a0)+
                or.w    d6,(a0)+
                lea     152(a0),a0
                dbf     d3,.dr_v_m_1
                rts

SET_UP_MESSAGE
                lea     LETTER_DATA,a0
                move.l  #31,d0
se_up_me_1
                lea     TEXT_DATA,a1
                move.l  a1,(a0)+
                moveq.l #7,d1
se_up_me_2
                clr.l   (a0)+
                move.l  (a1)+,(a0)+
                clr.l   (a0)+
                clr.l   (a0)+
                clr.l   (a0)+
                dbf     d1,se_up_me_2
                dbf     d0,se_up_me_1
                rts

first_node
        lea     blank_node,a0
        move.l  a0,next_node
        move.w  d2,(a0)
        move.w  d3,2(a0)
        move.w  d0,4(a0)
        move.w  d1,6(a0)
        move.l  #0,8(a0)
        move.l  #0,12(a0)
        add.l   #16,next_node
        rts
add_node
        lea     blank_node,a0
loopz   move.l  next_node,a1
        cmp.w   (a0),d2
        blt     go_left
        move.l  12(a0),d7
        cmp.l   #0,d7
        beq     fill_right
        move.l  d7,a0
        bra     loopz
go_left
        move.l  8(a0),d7
        cmp.l   #0,d7
        beq     fill_left
        move.l  d7,a0
        bra     loopz
fill_left
        move.w  d2,(a1)
        move.w  d3,2(a1)
        move.w  d0,4(a1)
        move.w  d1,6(a1)
        move.l  next_node,8(a0)
        add.l   #16,next_node
        rts
fill_right
        move.w  d2,(a1)
        move.w  d3,2(a1)
        move.w  d0,4(a1)
        move.w  d1,6(a1)
        move.l  next_node,12(a0)
        add.l   #16,next_node
        rts
        

*********************
* Routine read tree *
*********************
read_tree
        move.l  (a7)+,save_return_addr
        move.l  12(a7),a0       ;get address of current node
        bra     hq
read_loop
        move.l  12(a7),a0       ;get address of current node
        move.l  12(a0),d0       ;get address of right node
        cmp.l   (a7),d0         ;compare with last node
        beq     back_up_tree    ;go back a level
hq      move.l  8(a0),d0        ;get address of left node
        cmp.l   (a7),d0         ;compare with last node
        beq     maybe_right     ;try right
        cmp.l   #0,d0           ;if left node is zero check right
        beq     maybe_right     ;try right
        move.l  8(a0),-(a7)     ;move address of left node to stack
        move.l  a0,-(a7)
        move.l  a0,-(a7)        ;move address of current node to stack
        move.l  a0,-(a7)        ;mode address of last node to stack
        bra     read_loop       ;call routine again
maybe_right
        move.l  12(a0),d0       ;get address of right node
        cmp.l   (a7),d0         ;compare with last node
        beq     back_up_tree    ;go back a level
        cmp.l   #0,d0           ;if right node is zero  
        beq     write_num       ;print number and go back a level
        move.w  2(a0),d0                ;get number
        cmp.w   #1,bnum
        beq     .n
        move.w  bnum,d0
.n      move.w  4(a0),d1
        move.w  6(a0),d2
        ext.l   d0
        ext.l   d1
        ext.l   d2
        bsr     plot_sprite     ;call print routine
        move.l  12(a0),-(a7)    ;move address of right node to stack
        move.l  a0,-(a7)
        move.l  a0,-(a7)        ;move address of current node to stack
        move.l  a0,-(a7)        ;mode address of last node to stack
        bra     read_loop       ;call routine again
back_up_tree
        move.l  8(a7),d0        ;get parent address
        cmp.l   #0,d0           ;is parent 0
        beq     lexit           ;get out
        add.l   #16,a7          ;wipe off current node info
        move.l  a0,(a7)         ;overwrite last node address
        bra     read_loop       ;call routine again
write_num
        move.w  2(a0),d0                ;get number
        cmp.w   #1,bnum
        beq     .n
        move.w  bnum,d0
.n      move.w  4(a0),d1
        move.w  6(a0),d2
        ext.l   d0
        ext.l   d1
        ext.l   d2
        bsr     plot_sprite     ;call print routine
        bra     back_up_tree    
lexit   move.l  save_return_addr,-(a7)
        rts                             

key_int
        move.b  $fffffc02.w,store_key
        bclr.b  #6,$fffffa11.w
        rte
ssss
code_start
scr_loop
        addq.w  #1,loopcount
        cmp.w   #1,loopcount
        bne     .x1
        move.w  #4,bnum
        bra     .x7
.x1     cmp.w   #6,loopcount
        bne     .x2
        move.w  #3,bnum
        bra     .x7
.x2     cmp.w   #11,loopcount
        bne     .x3
        move.w  #2,bnum
        bra     .x7
.x3     cmp.w   #16,loopcount
        bne     .x4
        move.w  #1,bnum
        bra     .x7
.x4     cmp.w   #200,loopcount
        bne     .x5
        move.w  #2,bnum
        bra     .x7
.x5     cmp.w   #205,loopcount
        bne     .x6
        move.w  #3,bnum
        bra     .x7
.x6     cmp.w   #210,loopcount
        bne     .xx
        move.w  #4,bnum
        bra     .x7
.xx     cmp.w   #215,loopcount
        bne     .xy
        move.w  #6,bnum
        bra     .x7
.xy     cmp.w   #250,loopcount
        bne     .x7
        move.w  #0,loopcount
        addq.w  #1,loopc2
        cmp.w   #1,loopc2
        bne     .l1
        lea     point_table_man,a0
        bra     .p1
.l1     cmp.w   #2,loopc2
        bne     .l2
        lea     point_table_egb,a0
        bra     .p1
.l2     cmp.w   #3,loopc2
        bne     .l3
        lea     point_table_new,a0
        bra     .p1
.l3     cmp.w   #4,loopc2
        bne     .l4
        lea     point_table_xer,a0
        bra     .p1
.l4     cmp.w   #5,loopc2
        bne     .l5
        lea     point_table_sat,a0
        bra     .p1
.l5     cmp.w   #6,loopc2
        bne     .l6
        lea     point_table_cube,a0
        bra     .p1
.l6     cmp.w   #7,loopc2
        bne     .l7
        lea     point_table_star,a0
        bra     .p1
.l7     cmp.w   #8,loopc2
        bne     .l8
        lea     point_table_arn,a0
        bra     .p1
.l8     cmp.w   #9,loopc2
        bne     .x7
        move.w  #0,loopc2
        lea     point_table,a0
.p1
        move.l  a0,ptable
.x7
scr_end 
        add.w   #4,rotz
        cmp.w   #360,rotz
        blt     .next
        move.w  #0,rotz
.next   
        add.w   #6,rotx
        cmp.w   #360,rotx
        blt     .next2
        move.w  #0,rotx
.next2  
        add.w   #8,roty
        cmp.w   #360,roty
        blt     .x
        move.w  #0,roty
.x      move.w  #160,centx
        move.w  #110,centy
        move.w  #70,centz
        bsr     makerot
dopoints
        lea     blank_node,a0
        move.w  #511,d0
.loop1  clr.l   (a0)+
        dbf     d0,.loop1
        moveq.l #0,d0
        moveq.l #0,d1
        moveq.l #0,d2
        moveq.l #0,d3
;       lea     point_table,a0
        move.l  ptable,a0
        move.w  (a0)+,d0
        move.w  (a0)+,d1
        move.w  (a0)+,d2
        move.w  (a0)+,d3
        bsr     rotate_axis
        ext.l   d0
        ext.l   d1
        ext.l   d2
        ext.l   d3
        move.l  a0,-(a7)
        bsr     first_node
        move.l  (a7)+,a0
        moveq.l #0,d0
        moveq.l #0,d1
        moveq.l #0,d2
        moveq.l #0,d3
.loop   move.w  (a0)+,d0
        cmp.w   #$ffff,d0
        beq     .end
        move.w  (a0)+,d1
        move.w  (a0)+,d2
        move.w  (a0)+,d3
        bsr     rotate_axis
        ext.l   d0
        ext.l   d1
        ext.l   d2
        ext.l   d3
        move.l  a0,-(a7)
        bsr     add_node
        move.l  (a7)+,a0
        bra     .loop
.end
        move.l  #blank_node,-(a7)
        move.l  #0,-(a7)
        move.l  #0,-(a7)
        move.l  #0,-(a7)
        bsr     read_tree
        add.w   #16,a7

message_bit
        bsr     draw_message
        bsr     move_message
.getkey move.l  #$600ff,-(a7)   
        trap    #1              
        addq    #4,a7   
        tst.w   d0      
        beq     .next
        cmp.b   #$20,d0
        bne     .next
        bra     exit
.next   move.l  scrbase,a5
        move.l  a5,a6
        add.l   #32000+45*160,a6
        rept    40
        movem.l (a5),d0-a4
        movem.l d0-a4,(a6)
        movem.l 52(a5),d0-a4
        movem.l d0-a4,52(a6)
        movem.l 104(a5),d0-a4
        movem.l d0-a4,104(a6)
        lea     800(a5),a5
        lea     -160(a6),a6
        endr
        bsr     wait_vbl
        move.l  scrbase,a6
        movem.l (a6),d0-a5
        rept    206
        movem.l d0-a5,(a6)
        movem.l d0-a5,56(a6)
        movem.l d0-a3,112(a6)
        lea     160(a6),a6
        endr
end_end
        bra     scr_loop
        
exit    rts

wait_vbl
        move.l  scrbase,tembase
        move.l  oldbase,scrbase
        move.l  tembase,oldbase
        move.l  oldbase,d0
        lsr.w   #8,d0
        move.l  d0,$ffff8200.w
;       not.w   $ff8240
        move.l  $462,d0
.wait   cmp.l   $462,d0
        beq     .wait
;       not.w   $ff8240
        rts


vbl1    movem.l d0-d7/a0-a6,-(a7)
        jsr     music1+8
        movem.l (a7)+,d0-d7/a0-a6
        rts
vbl.vec equ     $70
hbl.vec equ     $120
tmrb.ctl equ    $fffa1b
tmrb.dat equ    $fffa21
mfp.ier equ     $fffa07
mfp.imr equ     $fffa13

enable.lowborder
        move.w  sr,-(sp)
        move.w  #$2700,sr
        move.l  #$fffffa00,a0           Preserve and set IMR and IER
        movep.w 7(a0),d0
        move.w  d0,lb.old.ier
        movep.w $13(a0),d0
        move.w  d0,lb.old.imr
        move.w  #$140,d0
        movep.w d0,7(a0)
        movep.w d0,$13(a0)
        move.l  #service.one,hbl.vec    Set up hbl vector
        move.l  vbl.vec,lb.old.vbl      Preserve old vbl vector
        move.l  #vsync.serv,vbl.vec
        move.b  $ffff8260.w,lb.old.vmode        Preserve old mode
        rte                             Restores sr as well!
disable.lowborder
        move.l  #$fffffa00,a0
        move.w  lb.old.ier,d0
        movep.w d0,7(a0)
        move.w  lb.old.imr,d0
        movep.w d0,$13(a0)
        move.b  lb.old.vmode,$ffff8260.w
        move.l  lb.old.vbl,vbl.vec
        rts
vsync.serv
        movem.l a0/a1/d2-d3,-(sp)
        move.w  #$2200,sr
        clr.b   tmrb.ctl
        move.l  #service.one,hbl.vec
        move.b  #198,tmrb.dat
        move.b  #8,tmrb.ctl
        lea     old_colour(pc),a0
        move.w  #$8240,a1
        rept    8
        move.l  (a0)+,(a1)+
        endr
        movem.l (sp)+,a0/a1/d2-d3
        move.l  lb.old.vbl,-(sp)
        rts
service.one
        clr.b   tmrb.ctl
        bclr.b  #0,$fffffa0f.w
        move.w  #$2200,sr
        move.l  #service.two,hbl.vec
        move.b  #1,tmrb.dat
        move.b  #8,tmrb.ctl
        st      lb.semaphore
.loop   tst.b   lb.semaphore
        bne.s   .loop
        rte
        
service.two
        clr.b   tmrb.ctl
        move.l  d0,-(sp)
        move.w  #$26,d0
.lp1    dbf     d0,.lp1
        move.b  #0,$ffff820a.w
        move.w  #$1,d0
.loop   dbf     d0,.loop
        move.b  #2,$ffff820a.w
        move.l  #service.three,hbl.vec
        move.w  #31,d0
.do     dbf     d0,.do
        move.b  #1,tmrb.dat
        move.b  #8,tmrb.ctl
        move.w  #0,$ffff8240.w
        sf      lb.semaphore
        bclr.b  #0,$fffffa0f.w
        move.l  (sp)+,d0
        rte
        
service.three
        movem.l d0/a0/a1,-(a7)
        clr.b   tmrb.ctl
        rept    62
        nop
        endr
        lea     pic+2,a0
        lea     $ffff8240.w,a1
        rept    8
        move.l  (a0)+,(a1)+
        endr
        move.w  #$002,$ffff8240.w
        sf      lb.semaphore
        bclr.b  #0,$fffffa0f.w
        movem.l (a7)+,d0/a0/a1
        rte

point_table_egb
        dc.w    90,60,100,15
        dc.w    90,70,100,15
        dc.w    90,80,100,15
        dc.w    90,90,100,15
        dc.w    90,100,100,15
        dc.w    100,60,100,15
        dc.w    100,80,100,15
        dc.w    100,100,100,15
        dc.w    110,60,100,15
        dc.w    110,80,100,15
        dc.w    110,100,100,15
        dc.w    140,60,100,15
        dc.w    140,70,100,15
        dc.w    140,80,100,15
        dc.w    140,90,100,15
        dc.w    140,100,100,15
        dc.w    150,60,100,15
        dc.w    150,100,100,15
        dc.w    160,60,100,15
        dc.w    160,80,100,15
        dc.w    160,90,100,15
        dc.w    160,100,100,15
        dc.w    190,60,100,15
        dc.w    190,70,100,15
        dc.w    190,80,100,15
        dc.w    190,90,100,15
        dc.w    190,100,100,15
        dc.w    200,60,100,15
        dc.w    206,80,100,15
        dc.w    200,100,100,15
        dc.w    210,60,100,15
        dc.w    210,70,100,15
        dc.w    210,90,100,15
        dc.w    210,100,100,15

        dc.w    $ffff,0,0,1

point_table_cube
        dc.w    140,80,100,8
        dc.w    150,80,100,8
        dc.w    160,80,100,8
        dc.w    170,80,100,8
        dc.w    180,80,100,8
        dc.w    140,90,100,8
        dc.w    180,90,100,8
        dc.w    140,100,100,8
        dc.w    180,100,100,8
        dc.w    140,110,100,8
        dc.w    180,110,100,8
        dc.w    140,120,100,8
        dc.w    180,120,100,8
        dc.w    140,130,100,8
        dc.w    150,130,100,8
        dc.w    160,130,100,8
        dc.w    170,130,100,8
        dc.w    180,130,100,8

        dc.w    140,80,110,8
        dc.w    180,80,110,8
        dc.w    140,130,110,8
        dc.w    180,130,110,8

        dc.w    140,80,120,8
        dc.w    180,80,120,8
        dc.w    140,130,120,8
        dc.w    180,130,120,8

        dc.w    140,80,130,8
        dc.w    180,80,130,8
        dc.w    140,130,130,8
        dc.w    180,130,130,8

        dc.w    140,80,140,8
        dc.w    150,80,140,8
        dc.w    160,80,140,8
        dc.w    170,80,140,8
        dc.w    180,80,140,8
        dc.w    140,90,140,8
        dc.w    180,90,140,8
        dc.w    140,100,140,8
        dc.w    180,100,140,8
        dc.w    140,110,140,8
        dc.w    180,110,140,8
        dc.w    140,120,140,8
        dc.w    180,120,140,8
        dc.w    140,130,140,8
        dc.w    150,130,140,8
        dc.w    160,130,140,8
        dc.w    170,130,140,8
        dc.w    180,130,140,8
        dc.w    $ffff,0,0,1

point_table_sat
        dc.w    220,100,80,1
        dc.w    230,100,80,1
        dc.w    240,100,80,1
        dc.w    250,100,80,1
        dc.w    230,90,90,5
        dc.w    240,90,90,5
        dc.w    220,100,90,1
        dc.w    230,100,90,1
        dc.w    240,100,90,1
        dc.w    250,100,90,1
        dc.w    230,110,90,5
        dc.w    240,110,90,5
        dc.w    230,90,100,5
        dc.w    240,90,100,5
        dc.w    220,100,100,1
        dc.w    230,100,100,1
        dc.w    240,100,100,1
        dc.w    250,100,100,1
        dc.w    230,110,100,5
        dc.w    240,110,100,5
        dc.w    220,100,110,1
        dc.w    230,100,110,1
        dc.w    240,100,110,1
        dc.w    250,100,110,1

        dc.w    100,100,80,5
        dc.w    110,100,80,5
        dc.w    120,100,80,5
        dc.w    130,100,80,5
        dc.w    110,90,90,1
        dc.w    120,90,90,1
        dc.w    100,100,90,5
        dc.w    110,100,90,5
        dc.w    120,100,90,5
        dc.w    130,100,90,5
        dc.w    110,110,90,1
        dc.w    120,110,90,1
        dc.w    110,90,100,1
        dc.w    120,90,100,1
        dc.w    100,100,100,5
        dc.w    110,100,100,5
        dc.w    120,100,100,5
        dc.w    130,100,100,5
        dc.w    110,110,100,1
        dc.w    120,110,100,1
        dc.w    100,100,110,5
        dc.w    110,100,110,5
        dc.w    120,100,110,5
        dc.w    130,100,110,5
        dc.w    $ffff,0,0,1

point_table_new
        dc.w    40,80,100,1
        dc.w    48,80,100,1
        dc.w    56,80,100,1
        dc.w    64,80,100,1
        dc.w    72,80,100,1
        dc.w    64,90,100,1
        dc.w    56,100,100,1
        dc.w    48,110,100,1
        dc.w    40,120,100,1
        dc.w    48,120,100,1
        dc.w    56,120,100,1
        dc.w    64,120,100,1
        dc.w    72,120,100,1

        dc.w    88,80,100,1
        dc.w    96,80,100,1
        dc.w    104,80,100,1
        dc.w    112,80,100,1
        dc.w    120,80,100,1
        dc.w    104,90,100,1
        dc.w    104,100,100,1
        dc.w    104,110,100,1
        dc.w    88,120,100,1
        dc.w    96,120,100,1
        dc.w    104,120,100,1
        dc.w    112,120,100,1
        dc.w    120,120,100,1

        dc.w    136,80,100,1
        dc.w    144,80,100,1
        dc.w    152,80,100,1
        dc.w    160,80,100,1
        dc.w    136,90,100,1
        dc.w    168,90,100,1
        dc.w    136,100,100,1
        dc.w    168,100,100,1
        dc.w    136,110,100,1
        dc.w    144,110,100,1
        dc.w    152,110,100,1
        dc.w    160,110,100,1
        dc.w    136,120,100,1
        dc.w    136,120,100,1

        dc.w    176,80,100,1
        dc.w    184,80,100,1
        dc.w    192,80,100,1
        dc.w    200,80,100,1
        dc.w    176,90,100,1
        dc.w    208,90,100,1
        dc.w    176,100,100,1
        dc.w    208,100,100,1
        dc.w    176,110,100,1
        dc.w    184,110,100,1
        dc.w    192,110,100,1
        dc.w    200,110,100,1
        dc.w    176,120,100,1
        dc.w    176,120,100,1

        dc.w    224,80,100,1
        dc.w    256,80,100,1
        dc.w    224,90,100,1
        dc.w    256,90,100,1
        dc.w    224,100,100,1
        dc.w    232,100,100,1
        dc.w    240,100,100,1
        dc.w    248,100,100,1
        dc.w    256,100,100,1
        dc.w    256,110,100,1
        dc.w    256,120,100,1
        dc.w    248,120,100,1
        dc.w    240,120,100,1
        dc.w    232,120,100,1
        dc.w    224,120,100,1
        dc.w    $ffff,0,0,0



point_table_star
        dc.w    160,100,60,5
        dc.w    160,90,70,1
        dc.w    150,100,70,1
        dc.w    160,100,70,1
        dc.w    170,100,70,1
        dc.w    160,110,70,1
        dc.w    160,80,80,1
        dc.w    160,90,80,1
        dc.w    140,100,80,1
        dc.w    150,100,80,1
        dc.w    160,100,80,1
        dc.w    170,100,80,1
        dc.w    180,100,80,1
        dc.w    160,110,80,1
        dc.w    160,120,80,1

        dc.w    160,70,90,1
        dc.w    160,80,90,1
        dc.w    160,90,90,1
        dc.w    130,100,90,1
        dc.w    140,100,90,1
        dc.w    150,100,90,1
        dc.w    160,100,90,1
        dc.w    170,100,90,1
        dc.w    180,100,90,1
        dc.w    190,100,90,1
        dc.w    160,110,90,1
        dc.w    160,120,90,1
        dc.w    160,130,90,1

        dc.w    160,60,100,5
        dc.w    160,70,100,1
        dc.w    160,80,100,1
        dc.w    160,90,100,1
        dc.w    120,100,100,5
        dc.w    130,100,100,1
        dc.w    140,100,100,1
        dc.w    150,100,100,1
        dc.w    160,100,100,1
        dc.w    170,100,100,1
        dc.w    180,100,100,1
        dc.w    190,100,100,1
        dc.w    200,100,100,5
        dc.w    160,110,100,1
        dc.w    160,120,100,1
        dc.w    160,130,100,1
        dc.w    160,140,100,5

        dc.w    160,70,110,1
        dc.w    160,80,110,1
        dc.w    160,90,110,1
        dc.w    130,100,110,1
        dc.w    140,100,110,1
        dc.w    150,100,110,1
        dc.w    160,100,110,1
        dc.w    170,100,110,1
        dc.w    180,100,110,1
        dc.w    190,100,110,1
        dc.w    160,110,110,1
        dc.w    160,120,110,1
        dc.w    160,130,110,1

        dc.w    160,80,120,1
        dc.w    160,90,120,1
        dc.w    140,100,120,1
        dc.w    150,100,120,1
        dc.w    160,100,120,1
        dc.w    170,100,120,1
        dc.w    180,100,120,1
        dc.w    160,110,120,1
        dc.w    160,120,120,1

        dc.w    160,90,130,1
        dc.w    150,100,130,1
        dc.w    160,100,130,1
        dc.w    170,100,130,1
        dc.w    160,110,130,1

        dc.w    160,100,140,5
        dc.w    $ffff,0,0,1
        
point_table_xer
        dc.w    90,70,100,1
        dc.w    150,70,100,1
        dc.w    160,70,100,1
        dc.w    170,70,100,1
        dc.w    180,70,100,1
        dc.w    190,70,100,1
        dc.w    200,70,100,1
        dc.w    100,80,100,1
        dc.w    140,80,100,1
        dc.w    205,80,100,1
        dc.w    110,90,100,1
        dc.w    130,90,100,1
        dc.w    205,90,100,1
        dc.w    120,100,100,1
        dc.w    130,100,100,1
        dc.w    140,100,100,1
        dc.w    150,100,100,1
        dc.w    160,100,100,1
        dc.w    170,100,100,1
        dc.w    180,100,100,1
        dc.w    190,100,100,1
        dc.w    200,100,100,1
        dc.w    110,110,100,1
        dc.w    130,110,100,1
        dc.w    190,110,100,1
        dc.w    100,120,100,1
        dc.w    140,120,100,1
        dc.w    200,120,100,1
        dc.w    90,130,100,1
        dc.w    150,130,100,1
        dc.w    160,130,100,1
        dc.w    170,130,100,1
        dc.w    210,130,100,1
        dc.w    $ffff,0,0,1

point_table
        dc.w    150,80,100,1
        dc.w    160,80,100,1
        dc.w    170,80,100,1
        dc.w    160,80,90,5
        dc.w    160,80,110,5
        
        dc.w    150,90,100,1
        dc.w    160,90,100,1
        dc.w    170,90,100,1
        dc.w    160,90,90,5
        dc.w    160,90,110,5
        
        dc.w    150,100,100,1
        dc.w    160,100,100,1
        dc.w    170,100,100,1
        dc.w    160,100,90,5
        dc.w    160,100,110,5 
        
        dc.w    148,110,100,1
        dc.w    160,110,100,1
        dc.w    172,110,100,1
        dc.w    160,110,88,5
        dc.w    160,110,112,5
        
        dc.w    145,120,100,1
        dc.w    160,120,100,1
        dc.w    175,120,100,1
        dc.w    160,120,85,5
        dc.w    160,120,115,5
        
        dc.w    137,130,100,1
        dc.w    160,130,100,1
        dc.w    183,130,100,1
        dc.w    160,130,77,5
        dc.w    160,130,123,5
        
        dc.w    127,140,100,1
        dc.w    160,140,100,1
        dc.w    193,140,100,1
        dc.w    160,140,67,5
        dc.w    160,140,133,5
        dc.w    $ffff,0,0,0



point_table_man
        dc.w    160,60,100,1

        dc.w    150,70,100,1
        dc.w    170,70,100,1
        dc.w    160,70,90,15

        dc.w    160,80,100,1

        dc.w    160,90,100,1

        dc.w    140,100,100,1
        dc.w    150,100,100,1
        dc.w    160,100,100,1
        dc.w    170,100,100,1
        dc.w    180,100,100,1
        dc.w    140,100,90,14
        dc.w    180,100,90,14

        dc.w    160,110,100,1

        dc.w    160,120,100,1

        dc.w    150,130,100,1
        dc.w    170,130,100,1

        dc.w    140,140,100,1
        dc.w    180,140,100,1

        dc.w    130,150,100,1
        dc.w    190,150,100,1
        dc.w    130,150,90,14
        dc.w    190,150,90,14
        dc.w    $ffff,0,0,1

point_table_arn
        dc.w    90,70,100,1
        dc.w    100,70,100,1
        dc.w    110,70,100,1
        dc.w    80,80,100,1
        dc.w    120,80,100,1
        dc.w    80,90,100,5
        dc.w    120,90,100,5
        dc.w    80,100,100,1
        dc.w    90,100,100,1
        dc.w    100,100,100,1
        dc.w    110,100,100,1
        dc.w    120,100,100,1
        dc.w    80,110,100,1
        dc.w    120,110,100,1
        dc.w    80,120,100,1
        dc.w    120,120,100,1

        dc.w    140,70,100,1
        dc.w    150,70,100,1
        dc.w    160,70,100,1
        dc.w    130,80,100,1
        dc.w    170,80,100,1
        dc.w    130,90,100,5
        dc.w    170,90,100,5
        dc.w    130,100,100,1
        dc.w    140,100,100,1
        dc.w    150,100,100,1
        dc.w    160,100,100,1
        dc.w    130,110,100,1
        dc.w    158,110,100,1
        dc.w    130,120,100,1
        dc.w    165,120,100,1

        dc.w    180,70,100,1
        dc.w    220,70,100,1
        dc.w    180,80,100,1
        dc.w    188,80,100,1
        dc.w    220,80,100,1
        dc.w    180,90,100,5
        dc.w    196,90,100,5
        dc.w    220,90,100,5
        dc.w    180,100,100,1
        dc.w    204,100,100,1
        dc.w    220,100,100,1
        dc.w    180,110,100,1
        dc.w    212,110,100,1
        dc.w    220,110,100,1
        dc.w    180,120,100,1
        dc.w    220,120,100,1
        dc.w    220,120,100,1

        dc.w    $ffff,0,0,1

point_tabl
        dc.w    160,100,100,1
        dc.w    160,110,100,8
        dc.w    160,118,100,9
        dc.w    160,124,100,10
        dc.w    160,128,100,11
        dc.w    160,130,100,12
        dc.w    160,132,100,13

        dc.w    $ffff,0,0,1


 
message
        DC.B    'SUB@HUMANS@IN@TURKEY',0,100
        DC.B    '@PRESENT@A@NEW@INTRO',0,50
        DC.B    '@@@PROGRAMMED@BY@@@@',0,50
        DC.B    '@@@@EgGgBg@@AND@@@@@',0,50
        DC.B    'THE@TITANIUM@HAMSTER',0,50
        DC.B    '@@@@@@@@@@@@@@@@@@@@',0,150
        DC.B    '@@@@HEY@LOST@BOYS@@@',0,50
        DC.B    '@WATCH@AS@THE@BALLS@',0,50
        DC.B    '@ROTATE@ROUND@TO@THE',0,50
        DC.B    '@BACK@AND@NOT@JUST@@',0,50
        DC.B    '@SUDDENLY@DISAPPEAR@',0,50
        DC.B    '@AND@NOW@hhhhhhh@@@@',0,50
        DC.B    '@GREETINGS@ARE@SENT@',0,50
        DC.B    '@@TO@THE@FOLLOWING@@',0,50
        DC.B    '@@@@@@THE@BBC@@@@@@@',0,50
        DC.B    '@@@THE@REPLICANTS@@@',0,50
        DC.B    '@@@@@@SUPERIOR@@@@@@',0,50
        DC.B    '@@@@@@@@ELITE@@@@@@@',0,50
        DC.B    '@@@POMPEY@PIRATES@@@',0,50
        DC.B    '@@@@@AUTOMATION@@@@@',0,50
        DC.B    '@@@THE@LOST@BOYS@@@@',0,50
        DC.B    '@@@THE@CAREBEARS@@@@',0,50
        DC.B    '@@THE@OVERLANDERS@@@',0,50
        DC.B    '@@@@DELTA@FORCE@@@@@',0,50
        DC.B    '@@@THE@LIGHT@TEAM@@@',0,50
        DC.B    '@@@@INNER@CIRCLE@@@@',0,50
        DC.B    '@@@CAPED@CRUSADER@@@',0,50
        DC.B    '@@NAPALM@SOLDIERS@@@',0,50
        DC.B    '@@@@@@@LYNX@@@@@@@@@',0,50
        DC.B    '@@@@AND@ALL@OTHER@@@',0,50
        DC.B    '@@@@@@DEMO@CREWS@@@@',0,50
        DC.B    '@@@@@@@@@@@@@@@@@@@@',0,50
        DC.B    '@@OKgggg@THATS@IT@@@',0,50
        DC.B    '@@@@@@LETS@WRAP@@@@@',0,50
        dc.b    1,1
        
        even

stack           ds.b    2048
enablemouse     dc.b    $80,$01
sav_cols        ds.w    16
lb.old.vbase    dc.l    0
lb.old.vbl      dc.l    0
lb.old.ier      dc.w    0
lb.old.imr      dc.w    0
lb.old.vmode    dc.b    0
lb.semaphore    dc.b    0
        even
old_colour      ds.l    8
 ifeq halfmeg
scrbase         dc.l    $76000
oldbase         dc.l    $6A000
 endc
 ifne halfmeg
scrbase         dc.l    $f6000
oldbase         dc.l    $eA000
 endc
tembase         dc.l    0
temp_char       dc.w    26
curr_char       dc.w    0
scroll_speed    dc.w    1
old_speed       dc.w    0
bounce_speed    dc.w    2
bounce_ctr      dc.w    0
bounce_on       dc.w    1
xpos            dc.w    0
ypos            dc.w    0
scr_pos         dc.w    0
mus_add         dc.l    0
rotate          dc.w    0
sprite_num      dc.w    0
ptable          dc.l    point_table
loopcount       dc.w    0
loopc2          dc.w    0
bnum            dc.w    0
text_pos        dc.l    0
temp_scr        dc.l    0
scr1            dc.l    0
scr2            dc.l    0
scr3            dc.l    0
scr4            dc.l    0
curr_add        dc.l    0
put_add         dc.l    0
cur_rez         dc.w    0
disablemouse    dc.b    $12
        even
file            dc.l    0
oldscbase       dc.l    0
oldstack        dc.l    0
sav_484         dc.w    0
savea0          dc.l    0
savea5          dc.l    0
vbl_count       dc.w    1
mess_flag       dc.w    1
store_mess      dc.l    0
store_key       dc.b    0
save_118        dc.l    0
y_pos           dc.w    0
base            dc.l    0
save_return_addr
                dc.l    0                   
next_node       dc.l    0
blank_node      ds.l    512

matrix11:       ds.w    1
matrix12:       ds.w    1
matrix13:       ds.w    1
matrix21:       ds.w    1
matrix22:       ds.w    1
matrix23:       ds.w    1
matrix31:       ds.w    1
matrix32:       ds.w    1
matrix33:       ds.w    1

xoffs:  ds.w    1
yoffs:  ds.w    1
zoffs:  ds.w    1

offx:   ds.w    1
offy:   ds.w    1
offz:   ds.w    1

sinx:   ds.w    1
siny:   ds.w    1
sinz:   ds.w    1
        
cosx:   ds.w    1
cosy:   ds.w    1
cosz:   ds.w    1

transx: dc.w    0
transy: dc.w    0
transz: dc.w    0

rotx:   dc.w    0
roty:   dc.w    0
rotz:   dc.w    0

centx:  dc.w    0
centy:  dc.w    0
centz:  dc.w    150
        
rotx11: dc.w    16384
rotx12: dc.w    0
rotx13: dc.w    0
rotx21: dc.w    0
rotx22: dc.w    16384
rotx23: dc.w    0
rotx31: dc.w    0
rotx32: dc.w    0
rotx33: dc.w    16384

sintab: dc.w    0,286,572,857,1143,1428,1713,1997,2280
        dc.w    2563,2845,3126,3406,3686,3964,4240,4516
        dc.w    4790,5063,5334,5604,5872,6138,6402,6664
        dc.w    6924,7182,7438,7692,7943,8192,8438,8682
        dc.w    8923,9162,9397,9630,9860,10087,10311,10531
        dc.w    10749,10963,11174,11381,11585,11786,11982,12176
        dc.w    12365,12551,12733,12911,13085,13255,13421,13583
        dc.w    13741,13894,14044,14189,14330,14466,14598,14726
        dc.w    14849,14962,15082,15191,15296,15396,15491,15582
        dc.w    15668,15749,15826,15897,15964,16026,16083,16135
        dc.w    16182,16225,16262,16294,16322,16344,16362,16374
        dc.w    16382,16384
        
        dc.w    16382,16374,16362,16344,16322,16294,16262,16225
        dc.w    16182
        dc.w    16135,16083,16026,15964,15897,15826,15749,15668
        dc.w    15582,15491,15396,15296,15191,15082,14962,14849
        dc.w    14726,14598,14466,14330,14189,14044,13894,13741
        dc.w    13853,13421,13255,13085,12911,12733,12551,12365
        dc.w    12176,11982,11786,11585,11381,11174,10963,10749
        dc.w    10531,10311,10087,9860,9630,9397,9162,8923
        dc.w    8282,8438,8192,7943,7692,7438,7182,6924
        dc.w    6664,6402,6138,5872,5604,5334,5063,4790
        dc.w    4516,4240,3964,3686,3406,3126,2845,2563
        dc.w    2280,1997,1713,1428,1143,857,572,286,0
        
        
        dc.w    -286,-572,-857,-1143,-1428,-1713,-1997,-2280
        dc.w    -2563,-2845,-3126,-3406,-3686,-3964,-4240,-4516
        dc.w    -4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
        dc.w    -6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682
        dc.w    -8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
        dc.w    -10749,-10963,-11174,-11381,-11585,-11786,-11982
        dc.w    -12176
        dc.w    -12365,-12551,-12733,-12911,-13085,-13255,-13421
        dc.w    -13583
        dc.w    -13741,-13894,-14044,-14189,-14330,-14466,-14598
        dc.w    -14726
        dc.w    -14849,-14962,-15082,-15191,-15296,-15396,-15491
        dc.w    -15582
        dc.w    -15668,-15749,-15826,-15897,-15964,-16026,-16083
        dc.w    -16135
        dc.w    -16182,-16225,-16262,-16294,-16322,-16344,-16362
        dc.w    -16374,-16382,-16384

        
        dc.w    -16382,-16374,-16362,-16344,-16322,-16294,-16262
        dc.w    -16225,-16182
        dc.w    -16135,-16083,-16026,-15964,-15897,-15826,-15749
        dc.w    -15668
        dc.w    -15582,-15491,-15396,-15296,-15191,-15082,-14962
        dc.w    -14849
        dc.w    -14726,-14598,-14466,-14330,-14189,-14044,-13894
        dc.w    -13741
        dc.w    -13853,-13421,-13255,-13085,-12911,-12733,-12551
        dc.w    -12365
        dc.w    -12176,-11982,-11786,-11585,-11381,-11174,-10963
        dc.w    -10749
        dc.w    -10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
        dc.w    -8282,-8438,-8192,-7943,-7692,-7438,-7182,-6924
        dc.w    -6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
        dc.w    -4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
        dc.w    -2280,-1997,-1713,-1428,-1143,-857,-572,-286,0
        even


SCREEN_Y_TABLE
                dc.w    0,160,320,480,640,800,960,1120,1280,1440,1600,1760,1920,2080,2240
                dc.w    2400,2560,2720,2880,3040,3200,3360,3520,3680,3840,4000,4160,4320,4480,4640
                dc.w    4800,4960,5120,5280,5440,5600,5760,5920,6080,6240,6400,6560,6720,6880,7040
                dc.w    7200,7360,7520,7680,7840,8000,8160,8320,8480,8640,8800,8960,9120,9280,9440
                dc.w    9600,9760,9920,10080,10240,10400,10560,10720,10880,11040,11200,11360,11520,11680,11840
                dc.w    12000,12160,12320,12480,12640,12800,12960,13120,13280,13440,13600,13760,13920,14080,14240
                dc.w    14400,14560,14720,14880,15040,15200,15360,15520,15680,15840,16000,16160,16320,16480,16640
                dc.w    16800,16960,17120,17280,17440,17600,17760,17920,18080,18240,18400,18560,18720,18880,19040
                dc.w    19200,19360,19520,19680,19840,20000,20160,20320,20480,20640,20800,20960,21120,21280,21440
                dc.w    21600,21760,21920,22080,22240,22400,22560,22720,22880,23040,23200,23360,23520,23680,23840
                dc.w    24000,24160,24320,24480,24640,24800,24960,25120,25280,25440,25600,25760,25920,26080,26240
                dc.w    26400,26560,26720,26880,27040,27200,27360,27520,27680,27840,28000,28160,28320,28480,28640
                dc.w    28800,28960,29120,29280,29440,29600,29760,29920,30080,30240,30400,30560,30720,30880,31040
                dc.w    31200,31360,31520,31680,31840
TEXT_DATA
                dc.w    0,7,0,7,0,7,0,7,0,7,0,7,0,7,0,7         Spc
                dc.w    0,7,4,0,4,0,9,7,9,7,0,4,0,4,9,4         A
                dc.w    2,0,2,7,3,7,7,4,7,4,3,0,7,4,3,4         B
                dc.w    6,0,1,4,6,0,1,4,1,4,6,7,1,4,6,7         C
                dc.w    2,0,6,4,6,4,2,7,2,7,2,0,2,7,2,0         D
                dc.w    7,0,2,4,2,4,7,7,2,4,7,4,2,4,7,4         E
                dc.w    1,0,6,0,1,0,1,7,1,4,4,4,1,4,4,4         F
                dc.w    6,0,1,4,1,4,6,7,6,7,6,4,6,4,5,4         G
                dc.w    1,0,1,7,6,0,6,7,1,4,6,4,1,4,6,4         H
                dc.w    1,0,6,0,1,7,6,7,4,0,4,7,4,0,4,7         I
                dc.w    5,0,5,5,5,5,4,7,4,7,3,5,4,7,3,5         J
                dc.w    2,0,2,7,7,0,2,4,2,4,7,7,2,4,7,7         K
                dc.w    2,0,2,7,2,0,2,7,2,7,7,7,2,7,7,7         L
                dc.w    1,0,1,7,1,0,4,4,4,4,7,0,7,0,7,7         M
                dc.w    1,0,1,7,1,0,7,7,7,7,7,0,7,0,7,7         N
                dc.w    4,0,7,4,7,4,4,7,4,7,1,4,1,4,4,0         O
                dc.w    2,0,2,7,2,0,6,3,6,3,2,4,6,3,2,4         P
                dc.w    4,0,7,4,7,4,4,7,4,0,1,4,1,4,6,9         Q
                dc.w    2,0,2,7,2,0,6,3,6,3,2,4,2,4,7,6         R
                dc.w    7,0,1,3,1,3,7,4,7,4,1,7,7,4,1,7         S
                dc.w    1,0,7,0,4,0,4,7,1,0,7,0,4,0,4,7         T
                dc.w    1,0,1,7,1,7,7,7,7,7,7,0,7,7,7,0         U
                dc.w    1,0,4,7,1,0,4,7,4,7,7,0,4,7,7,0         V
                dc.w    1,0,1,7,1,7,4,4,4,4,7,7,7,7,7,0         W
                dc.w    1,0,7,7,1,0,7,7,1,7,7,0,1,7,7,0         X
                dc.w    1,0,4,3,1,7,7,0,1,7,7,0,1,7,7,0         Y
                dc.w    1,0,7,0,7,0,1,7,1,7,7,7,1,7,7,7         Z
                dc.w    4,0,7,4,7,4,4,7,4,7,1,4,1,4,4,0         0
                dc.w    4,0,3,2,4,0,4,7,4,0,4,7,4,0,4,7         1
                dc.w    1,2,4,0,4,0,7,3,7,3,1,7,1,7,7,7         2
                dc.w    1,0,7,0,7,0,4,4,4,4,7,6,7,6,1,7         3
                dc.w    4,0,0,4,0,4,6,4,4,0,4,7,4,0,4,7         4
                dc.w    1,0,7,0,1,0,1,3,1,3,7,5,7,5,1,7         5
                dc.w    4,0,1,4,1,4,6,4,6,4,4,7,4,7,1,4         6
                dc.w    1,0,7,0,1,0,7,0,7,0,1,7,3,4,5,4         7
                dc.w    1,0,7,0,7,0,1,7,1,7,7,7,7,7,1,0         8
                dc.w    4,0,1,4,1,4,7,4,4,0,7,4,7,4,4,7         9
                dc.w    9,0,7,4,7,4,9,7,9,0,7,4,7,4,9,7         (
                dc.w    1,0,3,4,3,4,1,7,1,0,3,4,3,4,1,7         )
                dc.w    1,6,2,6,2,6,2,7,2,7,1,7,1,7,1,6         .
                dc.w    2,6,3,6,3,6,2,8,2,8,3,6,3,6,2,6         ,
                dc.w    7,0,0,7,7,0,0,7,7,0,0,7,7,0,0,7         /
PIXEL_TABLE_LEFT
                dc.w    %1111111111111111
                dc.w    %0111111111111111
                dc.w    %0011111111111111
                dc.w    %0001111111111111
                dc.w    %0000111111111111
                dc.w    %0000011111111111
                dc.w    %0000001111111111
                dc.w    %0000000111111111
                dc.w    %0000000011111111
                dc.w    %0000000001111111
                dc.w    %0000000000111111
                dc.w    %0000000000011111
                dc.w    %0000000000001111
                dc.w    %0000000000000111
                dc.w    %0000000000000011
                dc.w    %0000000000000001
PIXEL_TABLE_RIGHT
                dc.w    %1000000000000000
                dc.w    %1100000000000000
                dc.w    %1110000000000000
                dc.w    %1111000000000000
                dc.w    %1111100000000000
                dc.w    %1111110000000000
                dc.w    %1111111000000000
                dc.w    %1111111100000000
                dc.w    %1111111110000000
                dc.w    %1111111111000000
                dc.w    %1111111111100000
                dc.w    %1111111111110000
                dc.w    %1111111111111000
                dc.w    %1111111111111100
                dc.w    %1111111111111110
                dc.w    %1111111111111111

MESS_X_COORD    dc.w    0
MESS_Y_COORD    dc.w    0
env             dc.l    0
com             dc.l    0
file1           dc.b "RABBITS.PRG",0
file2           dc.b "CAT.PRG",0
file3           dc.b "COHORT.PRG",0,0

        *        abcdefghijklmnopqrstuvwxyz0123456789().,/
        *       -----------------------------------------
        *       @ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_'abcdefghi
        *       -----------------------------------------
        
PAUSE           dc.w    0
TEXT_POSITION   dc.l    message
LETTER_DATA
                ds.b    5400



music1          incbin  vector.jh
endmus
pic             
balls           incbin  vector.pi1
space           ds.b    32128
