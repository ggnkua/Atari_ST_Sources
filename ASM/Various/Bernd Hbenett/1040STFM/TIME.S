          ;Taktzyklen nur fÅr den eigentlichen StrahlrÅcklauf
          ;in LOWRES (320 x 200 x 4)
          ;10  x NOP = 40 Taktzyklen
          ;
          ;+   40  x 244 = 9760 Taktzyklen
          ;+   243 x dbf = 2430+12 Taktzyklen
          ;                ------------------
          ; Insgesamt    = 12202 Taktzyklen
          ;                ================
          ;
          ;Anmerkung : Durch das RTE am Ende der VBI-Routine
          ;            werden Alle weitern VBI-Routinen
          ;            des Betriebssystems abgehÑngt.

cnecin    equ 8
logbase   equ 3
super     equ 32
vsync     equ 37
vbivec    equ $70
hbivec    equ $120
iera      equ $fffa07
ierb      equ $fffa09
isra      equ $fffa0f
imra      equ $fffa13
tbcr      equ $fffa1b
tbdr      equ $fffa21

start:    pea       0
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          move.l    d0,ssp
          move.w    #logbase,-(sp)
          trap      #14
          addq.l    #2,sp
          move.l    d0,oldscr
          movea.l   d0,a0
          move.w    #7999,d0
erase:    move.l    #0,(a0)+
          dbf       d0,erase
          movem.l   $ff8240,d0-d3/a0-a3
          movem.l   d0-d3/a0-a3,oldtab
          move.w    #$0000,$ff8240
          move.l    vbivec,oldvbi+2
          move.l    #hbi,hbivec
          move.l    #vbi,vbivec
          andi.b    #$df,ierb
          ori.b     #1,iera
          ori.b     #1,imra
          move.w    #cnecin,-(sp)
          trap      #1
          addq.l    #2,sp
          move.l    oldvbi+2,vbivec
          andi.b    #$fe,iera
          ori.b     #$20,ierb
          move.w    #vsync,-(sp)
          trap      #14
          addq.l    #2,sp
          movem.l   oldtab,d0-d3/a0-a3
          movem.l   d0-d3/a0-a3,$ff8240
          move.l    ssp,-(sp)
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          clr.w     -(sp)
          trap      #1

vbi:      move.b    #0,tbcr
          move.w    #$0777,$ff8240
          move.l    d0,savereg
          move.w    #243,d0
waste:    nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          dbf       d0,waste
          move.w    #$0000,$ff8240
          addi.l    #1,count_v
          move.b    #1,tbdr
          move.b    #8,tbcr
          move.l    savereg,d0
          rte       
oldvbi:   jmp       $ffffffff ;abhÑngen aller VBI-Routinen

hbi:      addi.l    #1,count_h
          andi.b    #$fe,isra
          rte       


          .DATA 
count_v:  .DC.l 0
count_h:  .DC.l 0

          .BSS 
ssp:      .DS.l 1
oldtab:   .DS.l 8
oldscr:   .DS.l 1
savereg:  .DS.l 10

          .END 

