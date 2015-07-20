          ;Dieses Program setzt ein DEGAS-Bild aus
          ;  1. Bild im SCREEN-FORMAT (32000 Bytes)
          ;  2. Farbtabelle (32 Bytes)
          ;zusammen.Es ensteht eine *.PI1 Datei
          ; -> Low Resolution DEGAS-PIC

cnecin    equ 8
fread     equ 63
fclose    equ 62
fcreate   equ 60
fopen     equ 61
fwrite    equ 64

oeffnen:  move.w    #2,-(sp)
          pea       name_1
          move.w    #fopen,-(sp)
          trap      #1
          addq.l    #8,sp
          move.w    d0,handle_1

          move.w    #2,-(sp)
          pea       name_2
          move.w    #fopen,-(sp)
          trap      #1
          addq.l    #8,sp
          move.w    d0,handle_2

lesen:    move.l    #farbtab,-(sp)
          move.l    #32,-(sp)
          move.w    handle_1,-(sp)
          move.w    #fread,-(sp)
          trap      #1
          lea.l     $c(sp),sp

          move.l    #bild,-(sp)
          move.l    #32000,-(sp)
          move.w    handle_2,-(sp)
          move.w    #fread,-(sp)
          trap      #1
          lea.l     $c(sp),sp

schliess: move.w    handle_1,-(sp)
          move.w    #fclose,-(sp)
          trap      #1
          addq.l    #4,sp

          move.w    handle_2,-(sp)
          move.w    #fclose,-(sp)
          trap      #1
          addq.l    #4,sp

          move.b    #0,null
          move.b    #0,kennung          ; LOW Resolution

make_dat: move.w    #0,-(sp)
          pea       name_3
          move.w    #fcreate,-(sp)
          trap      #1
          addq.l    #8,sp
          move.w    d0,handle_3

writedat: move.l    #null,-(sp)
          move.l    #32034,-(sp)
          move.w    handle_3,-(sp)
          move.w    #fwrite,-(sp)
          trap      #1
          lea.l     $c(sp),sp

shutdat:  move.w    handle_3,-(sp)
          move.w    #fclose,-(sp)
          trap      #1
          addq.l    #4,sp
          clr.w     -(sp)
          trap      #1


          .DATA 
name_1:   .DC.b "color.dat",0
name_2:   .DC.b "hard.scr",0
name_3:   .DC.b "picture.pi1",0
          .EVEN 
          .BSS 
handle_1: .DS.w 1
handle_2: .DS.w 1
handle_3: .DS.w 1
null:     .DS.b 1
kennung:  .DS.b 1
farbtab:  .DS.b 32
bild:     .DS.b 32000
          .END 

