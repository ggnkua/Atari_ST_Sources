* DEGAS PICTURE VIEWER, any resolution

* Please note there is no file error checking

gemdos          equ     1     
xbios           equ     14

mshrink         equ     $4a
supexec         equ     $26
setpalette      equ     $6
fopen           equ     $3D
fclose          equ     $3E
fread           equ     $3f
crawcin         equ     $7
pterm           equ     $4c

color0  equ     $ffff8240           ; hardware colour register

* standard GEM header
       
        move.l  a7,a5
        move.l  #ustk,a7
        move.l  4(a5),a5
        move.l  12(a5),d0
        add.l   20(a5),d0
        add.l   28(a5),d0
        add.l   #$100,d0
        move.l  d0,-(sp)
        move.l  a5,-(sp)
        clr.w   -(sp)
        move    #mshrink,-(sp)          ; return excess memory 
        trap    #gemdos
        add.l   #12,sp

* save desktop palette, execute subroutine in super mode

        move.l  #savecolors,-(sp)
        move    #supexec,-(sp)
        trap    #xbios
        addq    #6,sp

* get screen resolution
        move.w  #4,-(sp)
        trap    #xbios
        addq.l  #2,sp
        move    d0,res          ; 0= LOW, 1=MED, 2=HIGH

* get actual screen address, phys base
        move.w  #2,-(sp)
        trap    #xbios
        addq.l  #2,sp
        move.l  d0,screen     


* get DEGAS pic
        move.l  #pic_name,a0
        move.l  #0,d5
        jsr     openfl

        
* get pic pallette
        move.l  #pichead,-(sp)
        move.l  #34,-(sp)               ; size of pichead buffer
        move.w  handle,-(sp)
        move.w  #fread,-(sp)
        trap    #gemdos
        add.l   #12,sp

* check are we in the correct res, first
        move    pichead,d0
        cmp     res,d0
        bne     exit1

* check to see if file is compresssed
        cmp.b   #$80,pichead            ; is it compressed
        beq     exit1                   ; yes


* use new palette if there is one
        move.l  #pichead+2,a0
        cmpi.l  #0,(a0)
        beq     no_pal
        
        move.l  a0,-(sp)
        move.w  #setpalette,-(sp)
        trap    #xbios
        addq.l  #6,sp


no_pal
        
* read the file into screen area

        move.l  screen,-(sp)
        move.l  #32000,-(sp)    ; screen always occupies 32K
        move.w  handle,-(sp)
        move.w  #fread,-(sp)
        trap    #gemdos
        add.l   #12,sp

exit1
        jsr     closfl


* keep the picture on screen until we press a key

        move    #crawcin,-(sp)        ;  no echo
        trap    #gemdos
        addq.l  #2,sp


* restore the desktop palette, execute subroutine in super mode
        move.l  #restorecolors,-(sp)
        move    #supexec,-(sp)
        trap    #xbios
        addq    #6,sp   

* exit cleanly
        move    #38,-(sp)       ; can be any value here
        move.w  #$4c,-(sp)      ; pterm
        trap    #gemdos         

savecolors
        lea     color0,a0
        lea     dpalette,a1
        move    #16-1,d0
savec   move    (a0)+,(a1)+
        dbra    d0,savec
        rts
        
restorecolors
        lea     dpalette,a0
        lea     color0,a1
        move    #16-1,d0
restc   move    (a0)+,(a1)+
        dbra    d0,restc
        rts


openfl  move.w  d5,-(sp)        ; set file attribute
        move.l  a0,-(sp)        ; address of filename 
        move.w  #fopen,-(sp)    ; open function number
        trap    #gemdos         ; hello GEMDOS
        addq.l  #8,sp
        move.w  d0,handle
        rts

* Close a file

closfl  move.w  handle,-(sp)
        move.w  #fclose,-(sp)
        trap    #gemdos
        addq.l  #4,sp
        rts

        ds.l    250
ustk    ds.l    1

res             ds.w    1
dpalette        ds.w    16
handle          ds.w    1
pichead         ds.w    17
screen          ds.l    1

pic_name        dc.b    "D:\CLIP_ART\JACQUE.PI3",0  ; path and name of your 
* file goes here. Can be .PI1, .PI2, .PI3

