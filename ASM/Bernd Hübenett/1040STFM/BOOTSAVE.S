cnecin    equ 8
logbase   equ 3
cconws    equ 9
rwabs     equ 4
fcreate   equ 60
fwrite    equ 64
fclose    equ 62


          .DCB.w 128,$4e71
          move.l    4(sp),d0
          move.l    d0,tpa_adr

          move.l    #0,-(sp)
          move.w    #$20,-(sp)
          trap      #1
          addq.l    #6,sp

          move.l    $432,d0
          move.l    d0,tpa_adr


          move.l    #0,-(sp)
          move.w    #$20,-(sp)
          trap      #1
          addq.l    #6,sp

          move.l    #text1,d0
          bsr       print

          move.w    #0,-(sp)  ; Laufwerk A
          move.w    #0,-(sp)  ; Logischer Sektor 0
          move.w    #1,-(sp)  ; Anzahl der Sektoren = 1
          move.l    tpa_adr,-(sp)
          move.w    #2,-(sp)  ; Sektor lesen
          move.w    #rwabs,-(sp)
          trap      #13
          lea.l     $e(sp),sp

          movea.l   tpa_adr,a0
          jmp       (a0)

          move.l    #text3,d0
          bsr       print

          clr.w     -(sp)
          trap      #1


print:              ; move.l    d0,-(sp)
          ; move.w    #cconws,-(sp)
          ; trap      #1
          ; addq.l    #6,sp

          move.w    #cnecin,-(sp)
          trap      #1
          addq.l    #2,sp
          rts       

          .DATA 
text1:    .DC.b 10,13
          .DC.b " Dieses Program lÑdt den BOOTSEKTOR",10,13
          .DC.b " von einer Diskette und speichert ihn",10,13
          .DC.b " als FILE auf einer anderen Diskette",10,13
          .DC.b " DISKETTE mit dem zu ladenden Bootsektor einlegen",10,13
          .DC.b " und dann bitte Taste drÅcken",10,13,0
          .EVEN 
text2:    .DC.b 10,13
          .DC.b " -- Ladevorgang beendet --",10,13
          .DC.b " Bitte die Sicherungsdiskette einlegen",10,13
          .DC.b " und dann bitte Taste drÅcken",10,13,0
          .EVEN 
text3:    .DC.b 10,13
          .DC.b " -- Sicherungsvorgang beendet --",10,13
          .DC.b "  OK, dann ab nach Hause",10,13,0
          .EVEN 
name:     .DC.b "boot.hex",0
          .EVEN 
          .BSS 
handle:   .DS.w 1
buffer:   .DS.b 1024
          .EVEN 
tpa_adr:  .DS.l 1
          .END 

