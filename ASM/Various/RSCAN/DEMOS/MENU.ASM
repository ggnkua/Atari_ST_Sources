            text
gemdos      equ      1
gem         equ      2
bios        equ      13
xbios       equ      14
            move.l   a7,a5
            move.l   #nstack,a7
            move.l   4(a5),a5
            move.l   $c(a5),d0
            add.l    $14(a5),d0
            add.l    $1c(a5),d0
            add.l    #$100,d0
            move.l   d0,-(sp)
            move.l   a5,-(sp)
            move.w   d0,-(sp)
            move.w   #$4a,-(sp)
            trap     #gemdos
            add.l    #12,sp
            clr.l    ap1resv
            clr.l    ap2resv
            clr.l    ap3resv
            clr.l    ap4resv
            move.w   #10,opcode
            clr.w    sintin
            move.w   #1,sintout
            clr.w    saddrin
            clr.w    saddrout
            jsr      aes
            move.w   #77,contrl
            clr.w    contrl+2
            move.w   #5,contrl+4
            clr.w    contrl+6
            clr.w    contrl+8
            jsr      aes
            move.w   intout,grhandle
            move.w   #100,contrl
            clr.w    contrl+2
            move.w   #11,contrl+6
            move.w   #9,d0
            lea.l    intin,a0
init_loop:  move.w   #1,(a0)+
            dbra     d0,init_loop
            move.w   #2,intin+20
            move.w   grhandle,contrl+12
            move.l   #vdipb,d1
            moveq.l  #$73,d0
            trap     #gem
mainprg:    bsr      mouse_off
            bsr      mouse_set
            bsr      menu_bar
            bsr      mouse_on
evnt_loop:  bsr      evnt_multi
            jsr      aes
            move.w   buffer+6,intin
            bsr      menu_normal
            cmpi.w   #$15,buffer+8
            beq      exit
            bra      evnt_loop

*
*           Start of subroutines
*
*
*           Start of AES subroutines
*
evnt_multi: move.w   #25,contrl
            move.w   #16,contrl+2
            move.w   #7,contrl+4
            move.w   #1,contrl+6
            clr.w    contrl+8
            move.w   #18,intin
            move.w   #2,intin+2
            move.w   #1,intin+4
            move.w   #1,intin+6
            move.l   #buffer,addrin
            rts
menu_bar:   move.l   #tree_0,addrin
            move.w   #30,contrl
            move.w   #1,intin
            bra      m_2
menu_off:   move.w   #30,contrl
            move.l   #tree_0,addrin
            clr.w    intin
            bra      m_2
menu_icheck:move.l   #tree_0,addrin
            move.w   buffer+8,intin
            move.w   #1,intin+2
            move.w   #31,contrl
            move.w   #2,contrl+2
            bra      m_2
menu_normal:move.w   #33,contrl
            move.w   #2,contrl+2
            move.l   #tree_0,addrin
            move.w   #1,intin+2
            bra      m_2
mouse_on:   move.w   #257,intin
            bra      m_0
mouse_off:  move.w   #256,intin
            bra      m_0
mouse_set:  clr.w    intin
m_0:        move.w   #78,contrl
m_1:        move.w   #1,contrl+2
m_2:        move.w   #1,contrl+4
m_3:        move.w   #1,contrl+6
m_4:        clr.w    contrl+8
aes:        move.l   #aespb,d1
            move.l   #$c8,d0
            trap     #gem
            rts
exit:       clr.w    -(sp)
            trap     #gemdos
            data
vdipb:      dc.l     contrl,intin,ptsin,intout,ptsout
aespb:      dc.l     contrl,global,intin,intout,addrin,addrout

tree_0:     dc.w     -1,1,7,$19,0,0,0,0,0,0,$280,$190
            dc.w     7,2,2,$14,0,0,0,$1100,0,0,$280,$12
            dc.w     1,3,6,$19,0,0,0,0,$10,0,$f8,$13
            dc.w     4,-1,-1,$20,0,0
            dc.l     title_1
            dc.w     0,0,$30,$13,5,-1,-1,$20,0,0
            dc.l     title_2
            dc.w     $30,0,$30,$13,6,-1,-1,$20,0,0
            dc.l     title_3
            dc.w     $60,0,$50,$13,2,-1,-1,$20,0,0
            dc.l     title_4
            dc.w     $b0,0,$48,$13,0,8,$1f,$19,0,0,0,0,0,$13,280,$130,$11,9
            dc.w     $10,$14,0,0,$ff,$1100,$10,0,$a0,$80,$a,-1,-1,$1c,0,0
            dc.l     tm1_1
            dc.w     0,0,$a0,$10,$b,-1,-1,$1c,0,8
            dc.l     tm1_2
            dc.w     0,$10,$a0,$10,$c,-1,-1,$1c,0,0
            dc.l     tm1_3
            dc.w     0,$20,$a0,$10,$d,-1,-1,$1c,0,0
            dc.l     tm1_4
            dc.w     0,$30,$a0,$10,$e,-1,-1,$1c,0,0
            dc.l     tm1_5
            dc.w     0,$40,$a0,$10,$f,-1,-1,$1c,0,0
            dc.l     tm1_6
            dc.w     0,$50,$a0,$10,$10,-1,-1,$1c,0,0
            dc.l     tm1_7
            dc.w     0,$60,$a0,$10,8,-1,-1,$1c,0,0
            dc.l     tm1_8
            dc.w     0,$70,$a0,$10,$16,$12,$15,$14,0,0,$ff,$1100,$40,0,$68,$40
            dc.w     $13,-1,-1,$1c,0,0
            dc.l     tm2_1
            dc.w     0,$00,$68,$10,$14,-1,-1,$1c,0
conv_state: dc.w     8
            dc.l     tm2_2
            dc.w     0,$10,$68,$10,$15,-1,-1,$1c,0,8
            dc.l     tm2_3
            dc.w     0,$20,$68,$10,$11,-1,-1,$1c,0,0
            dc.l     tm2_4
            dc.w     0,$30,$68,$10,$1f,$17,$1e,$14,0,0,$ff,$1100,$70,0,$a8,$80
            dc.w     $18,-1,-1,$1c,0
an_select1: dc.w     4
            dc.l     tm3_1
            dc.w     0,$00,$a8,$10,$19,-1,-1,$1c,0
an_select2: dc.w     0
            dc.l     tm3_2
            dc.w     0,$10,$a8,$10,$1a,-1,-1,$1c,0
an_select3: dc.w     0
            dc.l     tm3_3
            dc.w     0,$20,$a8,$10,$1b,-1,-1,$1c,0
an_select4: dc.w     0
            dc.l     tm3_4
            dc.w     0,$30,$a8,$10,$1c,-1,-1,$1c,0
an_select5: dc.w     0
            dc.l     tm3_5
            dc.w     0,$40,$a8,$10,$1d,-1,-1,$1c,0,8
            dc.l     tm3_6
            dc.w     0,$50,$a8,$10,$1e,-1,-1,$1c,0
tree_state: dc.w     0
            dc.l     tm3_7
            dc.w     0,$60,$a8,$10,$16,-1,-1,$1c,0
depth_state:dc.w     0
            dc.l     tm3_8
            dc.w     0,$70,$a8,$10,7,$20,$2a,$14,0,0,$ff,$1100,$c0,0,$88,$b0
            dc.w     $21,-1,-1,$1c,0
draw_state: dc.w     8
            dc.l     tm4_1
            dc.w     0,$00,$88,$10,$22,-1,-1,$1c,0
form_state: dc.w     8
            dc.l     tm4_2
            dc.w     0,$10,$88,$10,$23,-1,-1,$1c,0
menu_state: dc.w     8
            dc.l     tm4_3
            dc.w     0,$20,$88,$10,$24,-1,-1,$1c,0,8
            dc.l     tm4_4
            dc.w     0,$30,$88,$10,$25,-1,-1,$1c,0
next_state: dc.w     8
            dc.l     tm4_5
            dc.w     0,$40,$88,$10,$26,-1,-1,$1c,0
prev_state: dc.w     8
            dc.l     tm4_6
            dc.w     0,$50,$88,$10,$27,-1,-1,$1c,0,8
            dc.l     tm4_7
            dc.w     0,$60,$88,$10,$28,-1,-1,$1c,0
print_state:dc.w     8
            dc.l     tm4_8
            dc.w     0,$70,$88,$10,$29,-1,-1,$1c,0,0
            dc.l     tm4_9
            dc.w     0,$80,$88,$10,$2a,-1,-1,$1c,0,8
            dc.l     tm4_10
            dc.w     0,$90,$88,$10,$1f,-1,-1,$1c,$20
tree_statei:dc.w     8
            dc.l     tm4_11
            dc.w     0,$a0,$88,$10

title_1:    dc.b     ' Desk',0
title_2:    dc.b     ' File',0
title_3:    dc.b     ' Settings',0
title_4:    dc.b     ' Options ',0
tm1_1:      dc.b     '  About RSCAN...',0
tm1_2:      dc.b     '--------------------',0
tm1_3:      dc.b     'Desk Accessory 1',0
tm1_4:      dc.b     'Desk Accessory 2',0
tm1_5:      dc.b     'Desk Accessory 3',0
tm1_6:      dc.b     'Desk Accessory 4',0
tm1_7:      dc.b     'Desk Accessory 5',0
tm1_8:      dc.b     'Desk Accessory 6',0

tm2_1:      dc.b     '  Load',0
tm2_2:      dc.b     '  Convert',0
tm2_3:      dc.b     '-------------',0
tm2_4:      dc.b     '  Quit',0

tm3_1:      dc.b     '   Object_type',0
tm3_2:      dc.b     '   Object_flag',0
tm3_3:      dc.b     '   Object_state',0
tm3_4:      dc.b     '   Obj_specification',0
tm3_5:      dc.b     '   Coordinates',0
tm3_6:      dc.b     '---------------------',0
tm3_7:      dc.b     '   Tree',0
tm3_8:      dc.b     '   Depth',0

tm4_1:      dc.b     ' Obj_draw',0
tm4_2:      dc.b     ' Form_do',0
tm4_3:      dc.b     ' Menu_bar',0
tm4_4:      dc.b     '-----------------',0
tm4_5:      dc.b     ' ',2,'  Next',0
tm4_6:      dc.b     ' ',1,'  Previous',0
tm4_7:      dc.b     '-----------------',0
tm4_8:      dc.b     ' Print',0
tm4_9:      dc.b     ' Redraw menu_bar',0
tm4_10:     dc.b     '-----------------',0
tm4_11:     dc.b     ' Tree & Depth',0
            bss
even
contrl:
opcode:     ds.w     1
sintin:     ds.w     1
sintout:    ds.w     1
saddrin     ds.w     1
saddrout:   ds.l     1
            ds.w     5
global:
apversion:  ds.w     1
acount:     ds.w     1
apid:       ds.w     1
apprivate:  ds.l     1
apptree:    ds.l     1
ap1resv:    ds.l     1
ap2resv:    ds.l     1
ap3resv:    ds.l     1
ap4resv:    ds.l     1
intin:      ds.w     128
ptsin:      ds.w     128
intout:     ds.w     128
ptsout:     ds.w     128
addrin:     ds.w     128
addrout:    ds.w     128
buffer:     ds.w     16
grhandle:   ds.w     1
nstack:     ds.l     1
            ds.w     20
            end
