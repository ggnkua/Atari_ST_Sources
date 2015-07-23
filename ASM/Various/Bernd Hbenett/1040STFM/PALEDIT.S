zeilen    equ 1
hbivec    equ $120
vbivec    equ $70
mkbvec    equ $118
iera      equ $fffa07
ierb      equ $fffa09
isra      equ $fffa0f
imra      equ $fffa13
tbcr      equ $fffa1b
tbdr      equ $fffa21
super     equ 32
fopen     equ 61
fread     equ 63
fclose    equ 62
logbase   equ 3
vsync     equ 37

start:    lea.l     farbtab,a0
          clr.w     d0
ci_loop:  move.w    d0,d1
          move.w    d0,d2
          move.w    d0,d3
          andi.w    #%0000000000000111,d1
          andi.w    #%0000000000111000,d2
          andi.w    #%0000000111000000,d3
          lsl.w     #1,d2
          lsl.w     #2,d3
          or.w      d2,d1
          or.w      d3,d1
          move.w    d1,(a0)+
          addq.w    #1,d0
          cmpi.w    #512,d0
          bcs.s     ci_loop

          pea       0
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          move.l    d0,ssp
          movem.l   $ff8240,d0-d7
          movem.l   d0-d7,oldpal
          move.b    $ff8260,res
          move.b    $ff820a,sync
          movem.l   black,d0-d7
          movem.l   d0-d7,$ffff8240
          .DC.w $a00a
          move.w    #vsync,-(sp)
          trap      #14
          addq.l    #2,sp
          move.b    #0,$ff8260
          move.b    #2,$ff820a
          move.w    #logbase,-(sp)
          trap      #14
          addq.l    #2,sp
          move.l    d0,old_adr

          move.w    #2,-(sp)
          pea       name
          move.w    #fopen,-(sp)
          trap      #1
          addq.l    #8,sp
          move.w    d0,handle
          move.l    #schrott,-(sp)
          move.l    #128,-(sp)
          move.w    handle,-(sp)
          move.w    #fread,-(sp)
          trap      #1
          lea.l     $c(sp),sp
          move.l    old_adr,-(sp)
          move.l    #32000,-(sp)
          move.w    handle,-(sp)
          move.w    #fread,-(sp)
          trap      #1
          lea.l     $c(sp),sp
          move.w    handle,-(sp)
          move.w    #fclose,-(sp)
          trap      #1
          addq.l    #4,sp
          movem.l   schrott+4,d0-d7
          movem.l   d0-d7,$ff8240

          move.l    old_adr,d0
          movea.l   d0,a0
          move.w    #20,d0
xxxx:     adda.l    #160,a0
          dbf       d0,xxxx








          lea.l     charac,a4
          lea.l     adresse,a5
wait:     move.w    #2,-(sp)
          move.w    #2,-(sp)
          trap      #13
          addq.l    #4,sp
          swap.w    d0
          moveq.l   #0,d1
looop:    move.b    0(a4,d1.w),d2
          cmp.b     d0,d2
          beq       change
          addq.w    #1,d1
          cmpi.w    #3,d1
          beq       wait
          jmp       looop
change:   lsl.w     #2,d1
          movea.l   0(a5,d1.w),a6
          jmp       (a6)
down:     move.b    #1,pointer
          jmp       wait
up:       move.b    #0,pointer
          jmp       wait

get_out:  movem.l   oldpal,d0-d7
          movem.l   d0-d7,$ffff8240
          move.w    #vsync,-(sp)
          trap      #14
          addq.l    #2,sp
          move.b    sync,$ff820a
          move.b    res,$ff8260
          move.l    ssp,-(sp)
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          clr.w     -(sp)
          trap      #1



          .DATA 
pointer:  .DC.b 0
counter:  .DC.b 0
          .EVEN 
black:    .DC.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
          .DC.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
name:     .DC.b "MENUE_II.NEO",0
          .EVEN 

          ; --ACHTUNG-- DIE CHARAC ZEICHEN TABELLE
          ; ENTHŽLT KEINE ASCII-CODES SONDERN DIE SCANCODES DER TASTEN

charac:   .DC.b 46,72,80
          .EVEN 
adresse:  .DC.l get_out,up,down

          .BSS 
sync:     .DS.b 1
res:      .DS.b 1
          .EVEN 
oldpal:   .DS.l 8
          .DS.l 100
ssp:      .DS.l 1
savereg:  .DS.l 10
tab:      .DS.w 1
farbtab:  .DS.w 512
tab1:     .DS.w 1
tab2:     .DS.w 1
old_adr:  .DS.l 1
handle:   .DS.w 1
schrott:  .DS.b 128
          .EVEN 
speicher: .DS.w 1000
          .END 

