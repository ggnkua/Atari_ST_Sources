cnecin    equ 8
fopen     equ 61
fread     equ 63
fclose    equ 62
logbase   equ 3

start:    move.w    #logbase,-(sp)
          trap      #14
          addq.l    #2,sp
          move.l    d0,scr
oeffnen:  move.w    #2,-(sp)
          pea       name
          move.w    #fopen,-(sp)
          trap      #1
          addq.l    #8,sp
          move.w    d0,handle
schrott:  move.l    vorspann,-(sp)
          move.l    #34,-(sp)
          move.w    handle,-(sp)
          move.w    #fread,-(sp)
          trap      #1
          lea.l     $c(sp),sp
read_out: move.l    scr,-(sp)
          move.l    #32000,-(sp)
          move.w    handle,-(sp)
          move.w    #fread,-(sp)
          trap      #1
          lea.l     $c(sp),sp
shut_dat: move.w    handle,-(sp)
          move.w    #fclose,-(sp)
          trap      #1
          addq.l    #4,sp
wait_key: move.w    #cnecin,-(sp)
          trap      #1
          addq.l    #2,sp
          clr.w     -(sp)
          trap      #1
          .EVEN 
          .DATA 
name:     .DC.b "bild.deg"
          .BSS 
vorspann: .DS.b 34
handle:   .DS.w 1
scr:      .DS.l 1
          .END 

