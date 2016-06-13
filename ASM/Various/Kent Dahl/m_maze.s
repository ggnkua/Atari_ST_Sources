******************
*   MAGIC MAZE
*  By:Kent "CODEMAN" Dahl
*  Coding project. Started:July 93
*
*
wall equ 5
l_b_size equ 14500    ;Level_Buffer_SIZE

 move.l #0,-(sp)    ;Enter Supervisor mode
 move #20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,save_usp

 move.l #old_pal,a3   ;Save the old palette
 clr d3
read_again:move #-1,-(sp)
 move d3,-(sp)
 move #7,-(sp)
 trap #14
 addq.l #6,sp
 move d0,(a3)+
 addq #1,d3
 cmpi.b #16,d3
 bne read_again

 move #2,-(sp)   ;Get physical screen address
 trap #14
 addq.l #2,sp
 move.l d0,scr_addr

 move.l #palette,a0    ;Set the game palette
 bsr set_pal

 move.l #set_up,a0
 bsr cconws
 bsr get_key

* Game initialize
 clr.w level
 clr.l score

* Level initialize
new_level:
 move.l #l_addrs,a0
 move.w level,d0
 asl #2,d0
 move.l 0(a0,d0.w),d7
 cmp.l #0,d7
 beq game_end
 move.l d7,a0
 move.l #lev_buff,a1
 move #l_b_size,d7
 subq #1,d7
z1: move.b (a0)+,(a1)+
 dbra d7,z1

 move.l #cls_str,a0
 bsr cconws
 clr.b keys
 move.l #lev_buff,a0   ;Set variables to initial
 move.b 8(a0),x_pos
 move.b 9(a0),y_pos
 move.b #1,direction

mainloop:
 bsr redraw

loop:
 bsr get_key

 cmp.b #27,d0
 beq exit

 swap d0
 move.b x_pos,d5
 move.b y_pos,d6
 cmp.b #$48,d0
 bne x1
 move #0,d7
 subq.b #1,d6
 bra motion
x1:cmp.b #$50,d0
 bne x2
 move #1,d7
 addq.b #1,d6
 bra motion
x2:cmp.b #$4d,d0
 bne x3
 move #2,d7
 addq.b #1,d5
 bra motion
x3:cmp.b #$4b,d0
 bne x4
 move #3,d7
 subq.b #1,d5
 bra motion
x4:

 bra loop

exit:
 move.l #old_pal,a0     ;Set the old palette
 bsr set_pal

 move.l #reset_,a0
 bsr cconws

 move.l save_usp,-(sp)  ;Return to user mode
 move #20,-(sp)
 trap #1
 addq.l #6,sp

 clr -(sp)        ;Terminate program
 trap #1
 addq.l #2,sp

motion:
 move.b direction,d1
 cmp.b d7,d1
 beq do_motion
 move.b d7,direction
 bra mainloop

do_motion:

 bsr read_pos
 tst.b d7      ;If nothin is there, just move
 beq granted

 cmp.b #1,d7 ;If chest
 beq chest
 cmp.b #2,d7 ;If key
 beq key
 cmp.b #3,d7 ;If goal
 beq goal
 cmp.b #4,d7 ;If locked door
 beq locked

not_grant:bra loop

granted:move.b d5,x_pos
 move.b d6,y_pos
 bra mainloop

* These bits of code determin what to do when an object is in front
* of the player,trying to move
chest:
 add.l #50,score
 move.b #0,d7
 bsr set_pos
 bra granted

key:addq.b #1,keys
 move.b #0,d7
 bsr set_pos
 bra granted

goal:
 move.w lev_buff+6,d7  ;Add bonus
 mulu #100,d7
 add.l d7,score
 move.l #cls_str,a0
 bsr cconws
 move.l #goal_s1,a0
 bsr cconws
 move.l score,d0
 move #8,d1
 move.l #buffer,a0
 bsr num_char
 clr.b buffer+9
 bsr cconws
 bsr get_key
 addq.w #1,level
 bra new_level

locked:
 move.b keys,d0
 cmp.b #0,d0
 ble not_grant
 subq.b #1,keys
 move.b #0,d7
 bsr set_pos
 bra granted

game_end:
 bra exit


*** S U B R O U T I N E S ***

cconws:
 move.l a0,-(sp)   ;Cconws , write string to screen
 move #9,-(sp)
 trap #1
 addq.l #6,sp
 rts

set_pal:move.l a0,-(sp)  ;Set palette
 move #6,-(sp)
 trap #14
 addq.l #6,sp
 rts

get_key:move #8,-(sp)   ;Get key press
 trap #1
 addq.l #2,sp
 rts

vsync:move #37,-(sp)
 trap #14
 addq.l #2,sp
 rts


* READ_POS , returns block value
* In:D5= X coord, D6= Y coord
* Out:D7= Block Value
read_pos:
 movem.l d3-d6/a0,-(sp)
 move.l #lev_buff,a0       ;get addr of level data
 clr d2
 move.b 4(a0),d4     ;Get width of labyrint
 move.b 5(a0),d3     ;Get depth --"--
 cmp.b d4,d5         ;If the position isn't within the maze width
 bge read_pos2       ;and depth, set it to a normal block(Wall)
 tst.b d5
 bmi read_pos2
 bra read_pos1
read_pos2:
 move.b #wall,d7
 bra read_pos3
read_pos1:
 cmp.b d3,d6
 bge read_pos2
 tst.b d6
 bmi read_pos2
 mulu d4,d6        ;If pos is within the limits,calculate and find
 add d6,d5         ;the block value
 move.b 16(a0,d5.w),d7  ;Get block value
read_pos3:
 movem.l (sp)+,d3-d6/a0
 rts

set_pos:movem.l d4-d7/a0,-(sp)
 move.l #lev_buff,a0
 clr d4
 move.b 4(a0),d4
 mulu d4,d6
 add d6,d5
 move.b d7,16(a0,d5.w)
 movem.l (sp)+,d4-d7/a0
 rts


** Simple screen block, or sprite, commands, by K Dahl
**  designed for LOW res
** PUT_SPR, puts a screen block on a screen position
**  Color 0 will be transparent
**In: D0:X coord/16, D1:Y coord, D2:Width/16 -1, D3:Depth -1
**    A0:Sprite data, A1:Screen addr
*put_spr:movem.l d0-d7/a0-a6,-(sp)
* mulu #160,d1 ;Find start addr of place on screen
* lsl.w #3,d0
* add d0,d1
* lea 0(a1,d1.w),a2  ;Stick it in A2
*put_spr1: lea 160(a2),a3 ;Save position for next scan line
* move d2,d4
*put_spr2:
* movem.l d0-d7,-(sp)
* clr d7 ;get mask
* or (a0)+,d7 ;for all 4 planes
* or (a0)+,d7
* or (a0)+,d7
* or (a0)+,d7
* suba #8,a0 ;reset A0
* not d7     ;Change mask so that AND D7,D1 clears bits where sprite
*            ;will be,and not the background
* move #3,d6
*put_spr3:
* move (a0)+,d0 ;Sprite bit
* move (a2),d1  ;screen bit
* and d7,d1  ;clear bits where sprite will be
* or d0,d1  ;put the sprite bits in
* move d1,(a2)+
* dbra d6,put_spr3 ;Do with all 4 planes
* movem.l (sp)+,d0-d7
* dbra d4,put_spr2
* move.l a3,a2
* dbra d3,put_spr1
* movem.l (sp)+,d0-d7/a0-a6
* rts

** GET_BLK, gets a block from a screen position
**In: D0:X coord/16, D1:Y coord, D2:Width/16 -1, D3:Depth -1
**    A0:Sprite data, A1:Screen addr
*get_blk:movem.l d0-d7/a0-a6,-(sp)
* mulu #160,d1 ;Find start addr of place on screen
* lsl.w #3,d0
* add d0,d1
* lea 0(a1,d1.w),a2  ;Stick it in A2
*get_blk1: lea 160(a2),a3 ;Save position for next scan line
* move d2,d4
*get_blk2:
* move.l (a2)+,(a0)+ ; 2 planes
* move.l (a2)+,(a0)+ ;+2 planes = 4 planes
* dbra d4,get_blk2
* move.l a3,a2
* dbra d3,get_blk1
* movem.l (sp)+,d0-d7/a0-a6
* rts

* PUT_BLK, puts a block onto a screen position
* Color 0 will NOT be transparent
*In: D0:X coord/16, D1:Y coord, D2:Width/16 -1, D3:Depth -1
*    A0:Sprite data, A1:Screen addr
put_blk:movem.l d0-d7/a0-a6,-(sp)
 mulu #160,d1 ;Find start addr of place on screen
 lsl.w #3,d0
 add d0,d1
 lea 0(a1,d1.w),a2  ;Stick it in A2
put_blk1: lea 160(a2),a3 ;Save position for next scan line
 move d2,d4
put_blk2:
 move.l (a0)+,(a2)+ ; 2 planes
 move.l (a0)+,(a2)+ ;+2 planes = 4 planes
 dbra d4,put_blk2
 move.l a3,a2
 dbra d3,put_blk1
 movem.l (sp)+,d0-d7/a0-a6
 rts

* REDRAW , redraw screen
redraw:movem.l d0-d7/a0-a6,-(sp)

 bsr vsync
 move.l scr_addr,a6

 clr d5      ;Loop going from -4 to 4 in both X and Y
redraw1:
 clr d6
redraw2:
 movem.l d5-d6,-(sp)
 subq #4,d5
 subq #4,d6
 clr d0
 move.b x_pos,d0
 add d0,d5
 move.b y_pos,d0
 add d0,d6
 bsr read_pos
 addq #4,d7
 movem.l (sp)+,d5-d6
 sub #8,sp
 bsr place

 movem.l (sp)+,d5-d6  ;Loop end
 cmp #8,d6
 beq redraw3
 addq #1,d6
 bra redraw2
redraw3:
 cmp #8,d5
 beq redraw4
 addq #1,d5
 bra redraw1
redraw4:

 move #4,d5      ;Place player sprite
 move #4,d6
 move.b direction,d7
 bsr place

 movem.l (sp)+,d0-d7/a0-a6
 rts

* PLACE ,places a 16x16 sprite on screen
* D5=X/16  D6=Y/16  D7=Sprite
place:move d5,d0
 asl #4,d6
 move d6,d1
 clr d2
 move #15,d3
 move.l scr_addr,a1
 move.l #sprites,a0
 and #$ff,d7
 asl #7,d7
 lea 0(a0,d7.w),a0
 bsr put_blk
 rts

* NUM_CHAR ,In:D0= Number, D1= Num. of digits ,A0= Where to put string
num_char:
 movem.l d0-d3/a0,-(sp)
 lea 1(a0,d1.w),a0
num_char1:
 move d0,d3
 clr d0
 swap d1
 divu #10,d1
 move d0,d2
 move d3,d0
 divu #10,d0
 swap d0
 addi.b #$30,d0
 cmpi #$30,d0
 blt num_char2
 cmpi #$39,d0
 bgt num_char2
 move.b d0,-(a0)
num_char2: move d2,d0
 swap d0
 dbra d1,num_char1
 movem.l (sp)+,d0-d3/a0
 rts


*** D A T A
palette:dc.w $0,$333,$555,$0,$330,$3,$5,$7     ;The palette
  dc.w $550,$300,$500,$700,$770,$30,$50,$777

* Addresses of the levels
l_addrs:dc.l xyz_lev0,xyz_lev0,xyz_lev1
 dc.l 0


even
xyz_lev0:
 dc.b 0,0,0,0,18,8,0,15,0,0,0,0,0,0,0,0

 dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.b 0,5,9,10,10,10,10,10,11,4,8,0,8,9,10,10,11,0
 dc.b 0,8,1,0,0,0,0,0,0,0,7,0,6,1,0,8,0,0
 dc.b 0,7,0,0,0,0,0,0,0,0,7,0,0,0,0,7,0,5
 dc.b 0,7,0,0,0,0,0,1,0,1,6,9,10,11,0,7,0,0
 dc.b 2,6,0,8,9,10,10,10,10,10,11,1,0,0,0,6,5,0
 dc.b 5,3,4,7,2,0,0,5,0,0,0,9,10,10,10,11,0,0
 dc.b 9,10,11,6,5,5,0,0,0,5,0,0,0,0,0,0,0,5

even
xyz_lev1:
 dc.b 0,0,0,0,32,14,0,50,0,0,0,0,0,0,0,0
 dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0
 dc.b 0,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,0,7,0,8,0
 dc.b 0,8,3,4,4,0,0,0,4,1,1,1,1,8,0,0,0,0,5,1,2,5,5,5,5,5,5,0,7,0,7,0
 dc.b 0,7,4,8,8,0,5,5,5,5,5,5,1,7,0,8,8,0,5,0,0,0,0,0,0,0,5,0,7,0,7,0
 dc.b 0,7,4,6,6,1,0,1,8,1,1,1,1,6,0,7,7,0,5,5,4,5,5,5,5,0,5,0,7,0,7,0
 dc.b 0,7,0,0,1,8,8,0,7,4,5,5,5,5,0,6,6,0,0,0,0,0,0,0,5,0,0,0,6,0,7,0
 dc.b 0,7,5,8,0,6,7,0,6,0,0,0,0,0,0,0,0,8,5,0,5,8,8,0,0,5,5,5,0,0,7,0
 dc.b 0,7,0,7,2,1,7,1,0,5,5,5,5,5,0,8,0,7,0,0,0,6,6,5,0,0,0,0,0,5,7,0
 dc.b 0,7,0,7,8,4,6,5,0,0,0,5,0,0,0,7,0,7,0,5,0,0,0,0,5,5,5,5,5,0,7,0
 dc.b 0,6,0,6,6,4,0,0,5,5,4,5,0,5,5,7,0,7,0,5,5,5,5,0,0,0,5,0,0,0,7,0
 dc.b 0,4,0,0,0,5,0,0,0,0,0,4,0,0,0,6,0,6,0,5,2,2,4,0,5,0,0,0,8,0,7,0
 dc.b 0,8,8,8,0,0,0,5,2,5,8,0,5,5,0,0,0,0,0,5,5,5,5,5,1,5,5,5,7,0,7,0
 dc.b 0,6,6,6,5,5,5,2,5,2,6,0,5,5,5,5,5,5,5,5,0,0,0,0,0,0,0,0,6,0,6,0
 dc.b 0,0,0,0,0,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,5,5,0,0,0,5,0,0,0,0,0



even
sprites:
 dc.l $0000ffff,$00000000,$f81effff,$f81ef81e,$8002fffd,$80008000
 dc.l $8002fffd,$80008000,$f00a8ff1,$80048004,$0000ffff,$181c0000
 dc.l $c003ffff,$f81fc003,$0002ffff,$7c3a0002,$0002ffff,$6e7a0002
 dc.l $80037ffe,$6ffa0002,$0000ffff,$6ff80000,$d006dfff,$fffef006
 dc.l $8002fffd,$8ff88000,$8002fffd,$87f88000,$8002fffd,$83f08000
 dc.l $fe1e81e1,$80608000,$0000ffff,$00000000,$fa1efdff,$f81ef81e
 dc.l $81c2fc3d,$82008200,$8182fdbd,$82408240,$f00e8e71,$81808180
 dc.l $0000ffff,$18180000,$c003ffff,$f81fc003,$0000ffff,$7c3e0000
 dc.l $0000fff9,$6e7e0006,$80037ffe,$6ffa0002,$0000ffff,$6ff80000
 dc.l $90069fff,$fffef006,$8002fffd,$8ff88000,$8002fffd,$87f88000
 dc.l $8202fdfd,$81f08000,$fe1e81e1,$80e08000,$0000ffff,$00000000
 dc.l $fc1effff,$fc1efc1e,$8022fffd,$80008000,$8042ffdd,$80208020
 dc.l $f80e8781,$80708070,$017cfffc,$01ff0003,$e5fdfffd,$e7ffe003
 dc.l $2ffadfff,$0ffa0002,$2ff2dfff,$0ff20002,$eff31ffe,$0ff20002
 dc.l $1ff0ffff,$1ff00000,$fffeffff,$fffee01e,$9fe2fffd,$9fe08000
 dc.l $bfe2fffd,$bfe08000,$ffc2fffd,$ffc08000,$fffeffc1,$ffc00040
 dc.l $0000ffff,$00000000,$f83effff,$f83ef83e,$8402fffd,$80008000
 dc.l $8202fbfd,$84008400,$f01e81e1,$8e008e00,$38c03fff,$f8c0c000
 dc.l $b8e3bfff,$f9e3c003,$39f2dfff,$19f20002,$2bf2dfff,$0bf20002
 dc.l $ebf31ffe,$0bf20002,$07d8ffff,$07f80000,$ff9eff9f,$fffef866
 dc.l $87fafffd,$87f88000,$87fefffd,$87fc8000,$83feffff,$83fe8000
 dc.l $ffff81ff,$81ff8000,$0000ffff,$00000000,$fe7effff,$fe7efe7e
 dc.l $8242fdfd,$80408040,$8242fdfd,$80408040,$fe7e81c1,$80408040
 dc.l $0000ffff,$00000000,$e7f3ffff,$e7f3e7f3,$2412dfef,$04020402
 dc.l $2412dfef,$04020402,$e7f31c0e,$04020402,$0000ffff,$00000000
 dc.l $fe7effff,$fe7efe7e,$8242fdfd,$80408040,$8242fdfd,$80408040
 dc.l $8242fdfd,$80408040,$fe7e81c1,$80408040,$0000ffff,$00000000
 dc.l $fe7effff,$fe7efe7e,$8002c001,$bffca004,$83c083c1,$e3c6fffe
 dc.l $824083c1,$c242fe7e,$01800180,$c183ffff,$bffd8c01,$cc03b3fd
 dc.l $1b0adf4b,$23be1c42,$19f0bbf1,$5d9e276c,$251c67de,$992dfef2
 dc.l $00008001,$7ffe7ffe,$80008001,$dffae006,$8002c001,$aff4b00c
 dc.l $8002c001,$aff4b00c,$8242fdfd,$80408040,$fe7e81c1,$80408040
 dc.l $0000ffff,$00000000,$fe7effff,$fe7efe7e,$8242fdfd,$80408040
 dc.l $8242fdfd,$80408040,$fe7081c1,$804c804e,$0000ffe4,$0012001b
 dc.l $e7e0ffe4,$e7f2e7fb,$00000004,$fff2fffb,$00000004,$0012fffb
 dc.l $83e00004,$68127c1b,$0000abf1,$400c540e,$ba7ebbff,$fa7efe7e
 dc.l $8242fdfd,$80408040,$8242fdfd,$80408040,$8242fdfd,$80408040
 dc.l $fe7e81c1,$80408040,$1818fc3f,$3b5c0180,$bc3cfc3f,$ff7e8190
 dc.l $7c3efc3f,$ff7f2190,$f81ffc3f,$ff7f4188,$f5aff81f,$fbdf4180
 dc.l $6246fdbf,$73ce03c0,$fc3f03c0,$07e0ffff,$0810f7ef,$0ff0ffff
 dc.l $f81ff7ef,$0ff0ffff,$fc3f03c0,$07e0ffff,$6246fdbf,$73ce03c0
 dc.l $f5affc3f,$ffff45a0,$f81ffc3f,$ff7f4188,$7c3efc3f,$ff7f2190
 dc.l $bc3cfc3f,$ff7e8190,$dc3ab81d,$bb5c8180,$00000000,$ffffffff
 dc.l $00000000,$8001fffe,$00000000,$8001fffe,$00000000,$8001fffe
 dc.l $00000000,$8ff1f01e,$00000000,$8811f7fe,$01800180,$8811f67e
 dc.l $03c003c0,$8811f43e,$01800180,$8811f67e,$01800180,$8811f67e
 dc.l $00000000,$8811f7fe,$00000000,$8ff1f7fe,$00000000,$8001fffe
 dc.l $00000000,$8001fffe,$00000000,$8001fffe,$00000000,$ffff8000
 dc.l $00000000,$ffffffff,$00000000,$8001fffe,$00000000,$8001fffe
 dc.l $00000000,$8001fffe,$00000000,$8ff1f01e,$00000000,$8811f7fe
 dc.l $00000000,$8811f7fe,$00000000,$8811f7fe,$00000000,$8811f7fe
 dc.l $00000000,$8811f7fe,$00000000,$8811f7fe,$00000000,$8ff1f7fe
 dc.l $00000000,$8001fffe,$00000000,$8001fffe,$00000000,$8001fffe
 dc.l $00000000,$ffff8000,$00000000,$f7eff830,$00000000,$f42ffbf0
 dc.l $00000000,$f42ffbf0,$00000000,$f7effbf0,$00000000,$f00ffff0
 dc.l $00000000,$f7eff830,$00000000,$f42ffbf0,$00000000,$f42ffbf0
 dc.l $00000000,$f7effbf0,$00000000,$f00ffff0,$00000000,$f00ffff0
 dc.l $00000000,$ff8ffff0,$00000000,$f00ffff0,$00000000,$e007fff8
 dc.l $00000000,$c003fffc,$00000000,$8001fffe,$00000000,$f7eff830
 dc.l $00000000,$f42ffbf0,$00000000,$f42ffbf0,$00000000,$f7effbf0
 dc.l $00000000,$f00ffff0,$00000000,$f7eff830,$00000000,$f42ffbf0
 dc.l $00000000,$f42ffbf0,$00000000,$f7effbf0,$00000000,$f00ffff0
 dc.l $00000000,$f7eff830,$00000000,$f42ffbf0,$00000000,$f42ffbf0
 dc.l $00000000,$f7effbf0,$00000000,$f00ffff0,$00000000,$f00ffff0
 dc.l $0000e007,$00081ff0,$c002c003,$d00efff2,$80008001,$b00efff0
 dc.l $00000000,$700ffff0,$00000000,$f00ffff0,$00000000,$f7eff830
 dc.l $00000000,$f42ffbf0,$00000000,$f42ffbf0,$00000000,$f7effbf0
 dc.l $00000000,$f00ffff0,$00000000,$f7eff830,$00000000,$f42ffbf0
 dc.l $00000000,$f42ffbf0,$00000000,$f7effbf0,$00000000,$f00ffff0
 dc.l $00000000,$f00ffff0,$00000000,$ffffffff,$00000000,$ffffffff
 dc.l $00000000,$ffffffff,$00000000,$ffffffff,$00000000,$f000ffff
 dc.l $00000000,$f1effe31,$00000000,$f129fef7,$00000000,$f129fef7
 dc.l $00000000,$f129fef7,$00000000,$f129fef7,$00000000,$f1effef7
 dc.l $00000000,$f000ffff,$00000000,$effff000,$00000000,$dfffe000
 dc.l $00000000,$bfffc000,$00000000,$7fff8000,$00000000,$ffffffff
 dc.l $00000000,$ffffffff,$00000000,$ffffffff,$00000000,$ffffffff
 dc.l $00000000,$0000ffff,$00000000,$3defc631,$00000000,$2529def7
 dc.l $00000000,$2529def7,$00000000,$2529def7,$00000000,$2529def7
 dc.l $00000000,$3defdef7,$00000000,$0000ffff,$00000000,$ffff0000
 dc.l $00000000,$ffff0000,$00000000,$ffff0000,$00000000,$ffff0000
 dc.l $00000000,$fffeffff,$00000000,$fffdfffe,$00000000,$fffbfffc
 dc.l $00000000,$fff7fff8,$00000000,$000ffff0,$00000000,$f78f18f0
 dc.l $00000000,$948f7bf0,$00000000,$948f7bf0,$00000000,$948f7bf0
 dc.l $00000000,$948f7bf0,$00000000,$f78f7bf0,$00000000,$000ffff0
 dc.l $00000000,$ffff0000,$00000000,$ffff0000,$00000000,$ffff0000
 dc.l $00000000,$00000000,$00000000,$00000000,$00000000,$00000000


set_up:dc.b 27,"f",27,"E",27,"b",2,10,10,"*** Magic Maze ***",13,10
 dc.b " By Kent Dahl",0

cls_str:dc.b 27,"E",0

goal_s1:dc.b " * Congratulations! *",13,10,"  Level completed.",13,10
 dc.b 10," Your total score:",0


reset_:dc.b 27,"E",27,"b",0,0

status:dc.b 27,"Y",20,1,"Score:"
 ds.b 9
 dc.b 0



*** B S S - Block Storage Section
 .bss
save_usp:ds.l 1

x_pos:ds.b 1      ;X position of player
y_pos:ds.b 1      ;Y position of player
direction:ds.b 1    ;Facing direction of the player (0-3)
even
old_pal:ds.w 16
level:ds.w 1      ;To hold level number
scr_addr:ds.l 1   ;To hold address of physical screen
keys:ds.b 1      ;Keys collected
score:ds.l 1     ;Score
buffer:ds.b 20

lev_buff:ds.b l_b_size  ;Buffer to hold level data. Num. of bytes should
  ;be at least  (Max.length * Max.width + 16)
