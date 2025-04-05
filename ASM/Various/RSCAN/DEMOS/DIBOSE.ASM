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
*
*           Start of mainprogram
*
mainprg:    bsr      mouse_off
            bsr      mouse_set
            bsr      mouse_on
draw_typpan:move.l   #tree_0,obj_adress
            clr.w    xcoord
            clr.w    ycoord
            move.w   #640,width
            move.w   #$60,heigth
            bsr      obj_draw
            clr.w    xcoord
            move.w   #$60,ycoord
            move.w   #$1d0,width
            move.w   #$1d0,work_w
            move.w   #$e7,heigth
            move.w   #$e7,work_h
            move.l   #source_tree,obj_adress
            bsr      obj_draw
evnt_loop:  bsr      evnt_multi
            bsr      aes
            cmpi.w   #10,intout
            bne      evnt_loop

draw_work:  move.l   #tree_1,obj_adress
            clr.w    xcoord
            clr.w    ycoord
            clr.w    ok_butt1
            clr.w    ca_butt1
            move.w   #640,width
            move.w   #400,heigth
            bsr      obj_draw
            move.w   #$29,edit_index
            bsr      form_do
            move.w   #2,intin
            bsr      form_dial
            move.w   #3,intin
            bsr      form_dial
            tst.w    ok_butt1
            bne      term
            bra      draw_typpan

*
*           Start of AES routines
*
evnt_multi: move.w   #25,contrl
            move.w   #16,contrl+2
            move.w   #7,contrl+4
            move.w   #1,contrl+6
            clr.w    contrl+8
            move.w   #14,intin
            move.w   #2,intin+2
            move.w   #1,intin+4
            move.w   #1,intin+6
            clr.w    intin+8
            clr.w    intin+10
            clr.w    intin+12
            move.w   #640,intin+14
            move.w   #$60,intin+16
            clr.w    intin+18
            clr.w    intin+20
            move.w   #$61,intin+22
            move.w   work_w,intin+24
            move.w   work_h,intin+26
            rts
obj_draw:   clr.w    intin
            move.w   #42,contrl
            move.w   #6,contrl+2
            move.w   #3,intin+2
            move.w   xcoord,intin+4
            move.w   ycoord,intin+6
            move.w   width,intin+8
            move.w   heigth,intin+10
            move.l   obj_adress,addrin
            bra      m_2
form_do:    move.w   #50,contrl
            move.w   edit_index,intin
            move.l   obj_adress,addrin
            bra      m_1
form_dial:  move.w   #51,contrl
            move.w   #9,contrl+2
            clr.w    intin+2
            move.w   #19,intin+4
            move.w   #16,intin+6
            move.w   #16,intin+8
            move.w   xcoord,intin+10
            move.w   ycoord,intin+12
            move.w   width,intin+14
            move.w   heigth,intin+16
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
term:       clr.w    -(sp)
            trap     #gemdos
            data
vdipb:      dc.l     contrl,intin,ptsin,intout,ptsout
aespb:      dc.l     contrl,global,intin,intout,addrin,addrout
tree_0:     dc.w     -1,1,$15,$14,0,0,1,$1100,0,0,640,$60
            dc.w     4,2,3,$1c,0,0
            dc.l     tb1
            dc.w     8,10,$100,16
            dc.w     3,-1,-1,$1c,0,0
            dc.l     tb2
            dc.w     $88,0,$30,16
            dc.w     1,-1,-1,$1a,1,0
            dc.l     tb3
            dc.w     $c0,0,$40,16
            dc.w     8,5,7,$1c,0,0
            dc.l     tb4
            dc.w     8,$24,$128,16
            dc.w     6,-1,-1,$1d,8,0
            dc.l     ted_tb1
            dc.w     $88,0,$30,16
            dc.w     7,-1,-1,$1e,8,0
            dc.l     ted_tb2
            dc.w     $c0,0,$40,16
            dc.w     4,-1,-1,$15,0,0
            dc.l     ted_tb3
            dc.w     $108,0,$20,16
            dc.w     $c,9,$b,$1c,0,0
            dc.l     tb5
            dc.w     8,$40,$128,16
            dc.w     $a,-1,-1,$14,0,0,$ff,$1100,$088,0,$30,16
            dc.w     $b,-1,-1,$19,0,0,$ff,$1100,$0c0,0,$40,16
            dc.w     $8,-1,-1,$1b,0,0,$41ff,$1100,$108,0,$20,16
            dc.w     $13,$d,$12,$14,0,0,1,$1100,$140,0,$98,$60
            dc.w     $e,-1,-1,$1a,$15,0
            dc.l     tb6
            dc.w     8,16,$40,16
            dc.w     $f,-1,-1,$1a,$15,0
            dc.l     tb7
            dc.w     8,40,$40,16
            dc.w     $10,-1,-1,$1a,$15,0
            dc.l     tb8
            dc.w     8,64,$40,16
            dc.w     $11,-1,-1,$1a,$15,0
            dc.l     tb9
            dc.w     80,16,$40,16
            dc.w     $12,-1,-1,$1a,$15,0
            dc.l     tb10
            dc.w     80,40,$40,16
            dc.w     $0c,-1,-1,$1a,$15,0
            dc.l     tb11
            dc.w     80,64,$40,16
            dc.w     $14,-1,-1,$1c,0,0
            dc.l     tb12
            dc.w     $210,$10,48,16
            dc.w     $15,-1,-1,$1c,0,0
            dc.l     tb13
            dc.w     $1f8,$28,96,16
            dc.w     0,-1,-1,$1c,$20,0
            dc.l     tb14
            dc.w     $1e8,$40,128,16
tree_1:     dc.w     -1,1,1,$14,0,0,0,$1141,0,0,640,400
            dc.w     0,2,$3d,$14,0,$10,2,$1100,$38,$20,$210,$150
            dc.w     $b,3,$a,$14,0,$20,$ff,$1141,8,16,$168,$50
            dc.w     4,-1,-1,$1a,1,0
            dc.l     wb1
            dc.w     8,16,$50,16
            dc.w     5,-1,-1,$1a,1,0
            dc.l     wb2
            dc.w     $60,16,$50,16
            dc.w     6,-1,-1,$1a,1,0
            dc.l     wb3
            dc.w     $b8,16,$50,16
            dc.w     7,-1,-1,$1a,1,0
            dc.l     wb4
            dc.w     $110,16,$50,16
            dc.w     8,-1,-1,$1a,1,0
            dc.l     wb5
            dc.w     8,48,$50,16
            dc.w     9,-1,-1,$1a,1,0
            dc.l     wb6
            dc.w     $60,48,$50,16
            dc.w     $a,-1,-1,$1a,1,0
            dc.l     wb7
            dc.w     $b8,48,$50,16
            dc.w     2,-1,-1,$1a,1,0
            dc.l     wb8
            dc.w     $110,48,$50,16
            dc.w     $12,$c,$11,$14,0,$20,$ff,$1141,8,$70,$110,$50
            dc.w     $d,-1,-1,$1a,1,0
            dc.l     wb9
            dc.w     8,16,$50,16
            dc.w     $e,-1,-1,$1a,1,0
            dc.l     wb10
            dc.w     $60,16,$50,16
            dc.w     $f,-1,-1,$1a,1,0
            dc.l     wb11
            dc.w     $b8,16,$50,16
            dc.w     $10,-1,-1,$1a,1,0
            dc.l     wb12
            dc.w     8,48,$50,16
            dc.w     $11,-1,-1,$1a,1,0
            dc.l     wb13
            dc.w     $60,48,$50,16
            dc.w     $b,-1,-1,$1a,1,0
            dc.l     wb14
            dc.w     $b8,48,$50,16
            dc.w     $16,$13,$15,$14,0,$20,$ff,$1141,$120,$70,$50,$50
            dc.w     $14,-1,-1,$1a,0,0
            dc.l     wb15
            dc.w     0,0,$50,16
            dc.w     $15,-1,-1,$1a,$11,0
            dc.l     wb16
            dc.w     8,$18,$40,16
            dc.w     $12,-1,-1,$1a,$11,0
            dc.l     wb17
            dc.w     8,$30,$40,16
            dc.w     $1a,$17,$19,$1c,0,0
            dc.l     wb18
            dc.w     $178,16,$90,16
            dc.w     $18,-1,-1,$1b,$11,0,$4cff,$1100,$48,0,$18,16
            dc.w     $19,-1,-1,$1b,$11,0,$4dff,$1100,$60,0,$18,16
            dc.w     $16,-1,-1,$1b,$11,0,$52ff,$1100,$79,0,$18,16
            dc.w     $1d,$1b,$1c,$1c,0,0
            dc.l     wb19
            dc.w     $178,$30,$88,16
            dc.w     $1c,-1,-1,$1b,$11,0,$53ff,$1100,$48,0,$20,16
            dc.w     $1a,-1,-1,$1b,$11,0,$4cff,$1100,$68,0,$20,16
            dc.w     $20,$1e,$1f,$1c,0,0
            dc.l     wb20
            dc.w     $178,$50,$88,16
            dc.w     $1f,-1,-1,$1b,$11,0,$54ff,$1100,$48,0,$20,16
            dc.w     $1d,-1,-1,$1b,$11,0,$52ff,$1100,$68,0,$20,16
            dc.w     $23,$21,$22,$1c,0,0
            dc.l     wb21
            dc.w     $178,$70,$88,16
            dc.w     $22,-1,-1,$1b,$11,0,$42ff,$1100,$48,0,$20,16
            dc.w     $20,-1,-1,$1b,$11,0,$57ff,$1100,$68,0,$20,16
            dc.w     $26,$24,$25,$1c,0,0
            dc.l     wb22
            dc.w     $178,$90,$88,16
            dc.w     $25,-1,-1,$1b,$11,0,$42ff,$1100,$48,0,$20,16
            dc.w     $23,-1,-1,$1b,$11,0,$57ff,$1100,$68,0,$20,16
            dc.w     $29,$27,$28,$1c,0,0
            dc.l     wb23
            dc.w     $178,$b0,$88,16
            dc.w     $28,-1,-1,$1b,$11,0,$42ff,$1100,$48,0,$20,16
            dc.w     $26,-1,-1,$1b,$11,0,$57ff,$1100,$68,0,$20,16
            dc.w     $2a,-1,-1,$1d,8,0
            dc.l     ted_wb1
            dc.w     8,$d0,96,16
            dc.w     $2b,-1,-1,$1d,8,0
            dc.l     ted_wb2
            dc.w     $80,$d0,$70,16
            dc.w     $34,$2c,$33,$1c,0,0
            dc.l     wb24
            dc.w     $100,$d0,$100,16
            dc.w     $2d,-1,-1,$1b,$11,0,1,$1101,$40,0,$18,16
            dc.w     $2e,-1,-1,$1b,$11,0,1,$1111,$58,0,$18,16
            dc.w     $2f,-1,-1,$1b,$11,0,1,$1121,$70,0,$18,16
            dc.w     $30,-1,-1,$1b,$11,0,1,$1131,$88,0,$18,16
            dc.w     $31,-1,-1,$1b,$11,0,1,$1141,$a0,0,$18,16
            dc.w     $32,-1,-1,$1b,$11,0,1,$1151,$b8,0,$18,16
            dc.w     $33,-1,-1,$1b,$11,0,1,$1161,$d0,0,$18,16
            dc.w     $2b,-1,-1,$1b,$11,0,1,$1171,$e8,0,$18,16
            dc.w     $35,-1,-1,$1c,0,0
            dc.l     wb25
            dc.w     8,$f0,$50,16
            dc.w     $36,-1,-1,$1d,8,0
            dc.l     ted_wb3
            dc.w     $60,$f0,$140,16
            dc.w     $37,-1,-1,$1c,0,0
            dc.l     wb26
            dc.w     8,$100,$50,16
            dc.w     $38,-1,-1,$1d,8,0
            dc.l     ted_wb4
            dc.w     $60,$100,$140,16
            dc.w     $39,-1,-1,$1c,0,0
            dc.l     wb27
            dc.w     8,$110,$50,16
            dc.w     $3a,-1,-1,$1d,8,0
            dc.l     ted_wb5
            dc.w     $60,$110,$140,16
            dc.w     $3b,-1,-1,$1c,0,0
            dc.l     wb28
            dc.w     8,$120,$50,16
            dc.w     $3c,-1,-1,$1d,8,0
            dc.l     ted_wb6
            dc.w     $60,$120,$140,16
            dc.w     $3d,-1,-1,$1a,7
ok_butt1:   dc.w     0
            dc.l     ok_butt
            dc.w     $1c0,$100,$40,16
            dc.w     1,-1,-1,$1a,$25
ca_butt1:   dc.w     0
            dc.l     ca_butt
            dc.w     $1c0,$120,$40,16

source_tree:dc.w     -1,-1,-1,$14,$20,$10,2,$1100,3,$63,$1ca,$e0


*
*           Start of TEDINFO structs
*
ted_tb1:    dc.l     tedt1,tedp1,tedv1
            dc.w     3,0,0,-1,0,0,7,2
ted_tb2:    dc.l     tedt2,tedp2,tedv2
            dc.w     3,0,0,-1,0,-1,9,3
ted_tb3:    dc.l     tedt3,tedp3,tedv3
            dc.w     3,0,0,-1,0,0,5,0
ted_wb1:    dc.l     tedt4,tedp4,tedv4
            dc.w     3,0,0,-1,0,0,2,13
ted_wb2:    dc.l     tedt5,tedp5,tedv5
            dc.w     3,0,0,-1,0,0,4,15
ted_wb3:    dc.l     tedt6,tedp6,tedv6
            dc.w     3,0,0,-1,0,0,41,41
ted_wb4:    dc.l     tedt7,tedp7,tedv6
            dc.w     3,0,0,-1,0,0,41,41
ted_wb5:    dc.l     tedt8,tedp8,tedv6
            dc.w     3,0,0,-1,0,0,41,41
ted_wb6:    dc.l     tedt9,tedp9,tedv6
            dc.w     3,0,0,-1,0,0,41,41
*
*           Start of tedptext
*
tedt1:      dc.b     0,0
tedt2:      dc.b     0,0,0
tedt3:      dc.b     'TEXT',0
tedt4:      dc.b     '@',0
tedt5:      dc.b     '@__',0
tedt6:      dc.b     '@_______________________________________',0
tedt7:      dc.b     '@_______________________________________',0
tedt8:      dc.b     '@_______________________________________',0
tedt9:      dc.b     '@_______________________________________',0
*
*           Start of tedptmp
*
tedp1:      dc.b     'FTXT:_',0
tedp2:      dc.b     'FBTXT:__',0
tedp3:      dc.b     0
tedp4:      dc.b     'character: _',0
tedp5:      dc.b     'thickness: ___',0
tedp6:      dc.b     '________________________________________',0
tedp7:      dc.b     '________________________________________',0
tedp8:      dc.b     '________________________________________',0
tedp9:      dc.b     '________________________________________',0
*
*           Start of tedval
*
tedv1:      dc.b     'X',0
tedv2:      dc.b     'XX',0
tedv3:      dc.b     'XX',0
tedv4:      dc.b     'X',0
tedv5:      dc.b     '999',0
tedv6:      dc.b     'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',0
*
*           Start of text
*
tb1:        dc.b     'String_Objects :',0
tb2:        dc.b     'STRING',0
tb3:        dc.b     'BUTTON',0
tb4:        dc.b     'TEDINFO_Objects:',0
tb5:        dc.b     'BOX_Objects    :          IBOX',0
tb6:        dc.b     'Load',0
tb7:        dc.b     'Save',0
tb8:        dc.b     'Quit',0
tb9:        dc.b     'Open',0
tb10:       dc.b     'Close',0
tb11:       dc.b     'Delete',0
tb12:       dc.b     'DIBOSE',0
tb13:       dc.b     'A Dialogbox-',0
tb14:       dc.b     'construction Set',0
wb1:        dc.b     'SELECTABLE',0
wb2:        dc.b     'DEFAULT',0
wb3:        dc.b     'EXIT',0
wb4:        dc.b     'EDITABLE',0
wb5:        dc.b     'RBUTTON',0
wb6:        dc.b     'LASTOB',0,0,0,0
wb7:        dc.b     'TOUCHEXIT',0
wb8:        dc.b     'HIDETREE',0
wb9:        dc.b     'SELECTED',0
wb10:       dc.b     'CROSSED',0
wb11:       dc.b     'CHECKED',0
wb12:       dc.b     'DISABLED',0
wb13:       dc.b     'OUTLINED',0
wb14:       dc.b     'SHADOWED',0
wb15:       dc.b     'Border',0
wb16:       dc.b     'INSIDE',0
wb17:       dc.b     'OUTSIDE',0
wb18:       dc.b     'te_just:',0
wb19:       dc.b     'te_font:',0
wb20:       dc.b     'wr_mode:',0
wb21:       dc.b     'B_color:',0
wb22:       dc.b     'T_color:',0
wb23:       dc.b     'F_color:',0
wb24:       dc.b     'shade:',0
wb25:       dc.b     'string   :',0
wb26:       dc.b     'te_ptext :',0
wb27:       dc.b     'te_ptmplt:',0
wb28:       dc.b     'te_pvalid:',0
ok_butt:    dc.b     'OK',0
ca_butt:    dc.b     'CANCEL',0
xcoord:     dc.w     0
ycoord:     dc.w     0
width:      dc.w     0
heigth:     dc.w     0
x_drag:     dc.w     0
y_drag:     dc.w     0
w_drag:     dc.w     0
h_drag:     dc.w     0
work_w:     dc.w     640
work_h:     dc.w     303
edit_index: dc.w     0
obj_number: dc.w     0
obj_adress: dc.l     0
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
grhandle:   ds.w     1
nstack:     ds.l     1
            ds.w     20
            end
