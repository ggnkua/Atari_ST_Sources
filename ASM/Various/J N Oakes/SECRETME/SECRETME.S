* SECRETME.S This example shows the construction of a simple dialog 
* box by hand, and how to display it on screen.This has been adapted
* from GEM4.S for which I left a message for you lot to find, by working
* out what to alter to display the message.

gemdos    equ  1

* header
        move.l  a7,a5
        move.l  #ustk,a7
        move.l  4(a5),a5
        move.l  12(a5),d0
        add.l   20(a5),d0
        add.l   28(a5),d0
        add.l   #$100,d0
        move.l  d0,-(sp)
        move.l  a5,-(sp)
        clr.w  -(sp)
        move    #$4a,-(sp)
        trap    #gemdos
        add.l   #12,sp

        bsr     form_cent     ; get centred coordinates 
        bsr     obdraw        ; put dialog box on screen
        bsr     f_do          ; handle interaction
        
* pterm -exit cleanly
        move    #0,-(sp)
        move    #$4c,-(sp)
        trap    #gemdos      

form_cent:
        move.l  #form_center,aespb      ; get coords of centered tree
        move.l  #parent,addrin
        bsr     aes
        movem.w intout+2,d0-d3          ; returned in intout+2
        rts     

obdraw:
        move    #0,intin       ; index of first object
        move    #1,intin+2     ; depth
        move    d0,intin+4     ; x coord 
        move    d1,intin+6     ; y coord
        move    d2,intin+8     ; width
        move    d3,intin+10    ; height
        move.l  #parent,addrin ; address of parent dialog box tree
        move.l  #object_draw,aespb
        bsr     aes
        rts

f_do:   move.l  #form_do,aespb  
        clr.w   intin           ; No editable text field
        move.l  #parent,addrin
        bsr     aes
        rts     

* AES subroutine
aes:    move.l  #aespb,d1
        move.l  #$c8,d0
        trap    #2
        rts

        
        ds.l    256
ustk:   ds.l    1

        
text1:  dc.b    ' HELLO YOU FOUND ME ',0 

text2:  dc.l    texty,textt2,textt2
        dc.w    3,0,2,$11f0,0,3,5,0    
        
texty:  dc.b    'BYE!',0
        
textt2: dc.b    0
               
* GEM arrays

contrl: ds.w    12
intin:  ds.w    128
intout: ds.w    128
global: ds.w    16

addrin: ds.w    128
addrout:ds.w    128
        
aespb:  dc.l    contrl,global,intin,intout,addrin,addrout

form_center:    dc.w    54,0,5,1,0 
object_draw:    dc.w    42,6,1,1,0
form_do:        dc.w    50,1,2,1,0

* dialog box tree
parent:  
        dc.w    -1,1,2,20,0,16          ; g_box
        dc.l    $33333333
        dc.w    50,80,550,350

        dc.w    2,-1,-1,28,0,0          ; g_string, title string
        dc.l    text1
        dc.w    200,30,5,1
       
        dc.w    0,-1,-1,22,7+32,0          ; g_boxtext, boxed exit button
        dc.l    text2
        dc.w    200,175,150,25

