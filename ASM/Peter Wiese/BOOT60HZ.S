************************************
*         BOOT60HZ.PRG             *
*       Copyright 1987 by          *
*         Peter Wiese              *
*        4530 Ibbenb≈ren           *
* Markt & Technik Happy-Computer   *
*          ST-Magazin 2            *
************************************

          move.l    #ausg,-(sp)
          move.w    #9,-(sp)
          trap      #1
          addq.l    #6,sp
          move.w    #7,-(sp)
          trap      #1
          addq.l    #2,sp

          move.w    #1,-(sp)            *sectors
          move.w    #0,-(sp)            *side
          move.w    #0,-(sp)            *track
          move.w    #1,-(sp)            *sector
          move.w    #0,-(sp)            *laufwerk
          clr.l     -(sp)
          move.l    #puffer,-(sp)       *puffer
          move.w    #8,-(sp)
          trap      #14
          add.l     #20,sp

          move.w    #$601c,puffer
          move.l    #$423900ff,puffer+30
          move.l    #$820a4e75,puffer+34

          move.w    #1,-(sp)            *ausf≈hrbarkeit
          move.w    #-1,-(sp)           *disktyp
          move.l    #-1,-(sp)           *serial no.
          move.l    #puffer,-(sp)
          move.w    #18,-(sp)
          trap      #14
          add.l     #14,sp

          move.w    #1,-(sp)            *sectors
          move.w    #0,-(sp)            *side
          move.w    #0,-(sp)            *track
          move.w    #1,-(sp)            *sector
          move.w    #0,-(sp)            *laufwerk
          clr.l     -(sp)
          move.l    #puffer,-(sp)       *puffer
          move.w    #9,-(sp)
          trap      #14
          add.l     #20,sp

          clr.w     -(sp)
          trap      #1

ausg:     dc.b      'Zu modifizierende Disk in Laufwerk A',13,10
          dc.b      'einlegen',0

.even

puffer:   ds.b      1

.end

