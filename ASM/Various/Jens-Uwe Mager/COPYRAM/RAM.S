*
* ram.s
*
* ramdisk for atari 520 st+
* written nov 85 by Jens-Uwe Mager
*

blocks    =         512                 ;groesse in 1 Kbyte blocks

* offsets in die base-page

prglen    =         $c
datalen   =         $14
bsslen    =         $1c
cmdlin    =         $80

* atari globals

hdv_bpb   =         $472
hdv_rw    =         $476
hdv_media =         $47e

drvbits   =         $4c2

xbios     =         14
tos       =         1

keepterm  =         $31
supexec   =         38

          .text

          move.l    4(sp),a6            ;adresse base page
          pea       vecinit
          move.w    #supexec,-(sp)
          trap      #xbios
          addq.l    #6,sp
          move.l    bsslen(a6),d1
          moveq     #9,d0               ;bsslen div 512
          lsr.l     d0,d1               ;nr blocks
          sub.w     datrec,d1           ;nr dataenbloecke
          lsr.w     #1,d1               ;nr datencluster
          move.w    d1,numcl
          move.l    prglen(a6),d0
          add.l     datalen(a6),d0
          add.l     bsslen(a6),d0
          add.l     #256,d0
          clr.w     -(sp)               ;exit code
          move.l    d0,-(sp)            ;laenge
          move.w    #keepterm,-(sp)
          trap      #tos

vecinit:  move.l    hdv_rw,oldrw+2
          move.l    #rw,hdv_rw
          move.l    hdv_bpb,oldbpb+2
          move.l    #bpb,hdv_bpb
          move.l    hdv_media,oldmedia+2
          move.l    #media,hdv_media
          move.l    drvbits,d0
          move.l    d0,d2
          moveq     #0,d1
drvlp:    lsr.l     #1,d0
          bcc.s     drvfnd
          addq.w    #1,d1
          bra.s     drvlp
drvfnd:   bset      d1,d2
          move.l    d2,drvbits
          move.w    d1,drive
          rts

rw:       move.w    drive,d0
          cmp.w     14(sp),d0
          bne       oldrw
          lea       rambase,a0
          move.l    6(sp),a1            ;tos buffer
          moveq     #0,d0
          move.w    12(sp),d1           ;start block
          moveq     #9,d0               ; * 512
          asl.l     d0,d1
          add.l     d1,a0
          move.w    10(sp),d0           ;nr of blocks
          move.l    a1,d2
          btst      #0,d2
          bne.s     bytes
          asl.l     #7,d0               ;blocks -> longs
          btst      #0,5(sp)            ;rwflg
          bne.s     lwords
          exg       a0,a1
lwords:   move.l    (a1)+,(a0)+
          subq.l    #1,d0
          bne.s     lwords
          rts
bytes:    moveq     #9,d1
          asl.l     d1,d0               ;blocks -> bytes
          btst      #0,5(sp)            ;rwflg
          bne.s     bytes1
          exg       a0,a1
bytes1:   move.b    (a1)+,(a0)+
          subq.l    #1,d0
          bne.s     bytes1
          rts

oldrw:    jmp       -1

bpb:      move.w    drive,d0
          cmp.w     4(sp),d0
          bne.s     oldbpb
          move.l    #mybpb,d0
          rts

oldbpb:   jmp       -1

media:    move.w    drive,d0
          cmp.w     4(sp),d0
          bne.s     oldmedia
          moveq     #0,d0
          rts

oldmedia: jmp       -1

          .data
drive:    dc.w      0
mybpb:    dc.w      512
clsiz:    dc.w      2
clsizb:   dc.w      1024
rdlen:    dc.w      7
fsiz:     dc.w      5
fatrec:   dc.w      6
datrec:   dc.w      18
numcl:    dc.w      351

          .bss
rambase   ds.b      blocks*1024

          .end
