*************************************************************************
* HCOPY_LP.S      - HP2934A HARDCOPY DRIVER
*
* (C)opyright 1986 by Michael Marxmeier
*
* Version @, 14.05.86
* Anpassung an HP2686A (LaserJet+) 14.08.86 jÅ/mm
* OUTPUT TO CENTRONICS             06.02.87 jÅ/mm
*
* ***********************************************************************

* FÅr Erweiterungen sind an den mit @@@ markierten Stellen ent-
* sprechende énderungen einzufÅgen.
* Beim Aufruf von pr_str steht in d3 die Anzahl der zu druckenden
* Zeichen -1. Der Init und Reset-String kînnen beliebig erweitert
* werden.
*
* öbersetzung mit BATCH.TTP, AS HCOPY

*************************************************************************
*
* System links
*

gemdos    = 1                           * gemdos trap #
devout    = 5                           * centronics =5 ,aux = 4
super     = $20                         * to/from supervisor mode
keep      = $31                         * keep process

xbios     = 14                          * xbios trap #
physbase  = 2                           * get physical base

nvbls     = $454                        * no of vbl entries
_vblqueque = $456                       * ptr to vbl queque table
_dumpflg  = $4ee                        * dump flag


*************************************************************************
*
* Install
*

          .text

*** Calculate program size

          move.l    4(sp),a0            * base page address
          move.l    #$100,d6            * Base page size
          add.l     12(a0),d6           * + text segment
          add.l     20(a0),d6           * + data segment
          add.l     28(a0),d6           * + bss segment

*** Install vector

          clr.l     -(sp)               * use user stack
          move      #super,-(sp)        * to supervisor mode
          trap      #gemdos
          add.l     #6,sp               * clean up stack

          move.l    d0,-(sp)            * save old supervisor stack
*
          move.l    _vblqueque,a0       * vbl queque table
          move      nvbls,d0            * vbl table entries

looktab:  tst.l     (a0)                * entry available
          beq       gotit               * yes
          add.l     #4,a0               * next location
          dbra      d0,looktab          * until complete table

          clr       -(sp)               * nothing available
          trap      #gemdos             * quit program
*

gotit:    move.l    #vbl,(a0)           * install pntr

          move      #super,-(sp)        * from supervisor mode
          trap      #gemdos
          add.l     #6,sp               * clean up stack

*** Quit

          clr       -(sp)               * no error
          move.l    d6,-(sp)            * bytes to keep
          move      #keep,-(sp)         * keep process
          trap      #gemdos             * to system and never back


*************************************************************************
*
* Vbl entry
*

vbl:      tst       _dumpflg            * hardcopy ?
          beq       dump                * yes
          rts

*** Init printer

dump:     move      #27,d3              * init printer
          lea       init,a3
          bsr       pr_str
          tst       d0                  * error
          beq       stop                * stop the dump

*** Init hardcopy
          
          move      #physbase,-(sp)     * get physical screen page
          trap      #xbios
          add.l     #2,sp

          move.l    d0,a4               * for later usage
          move      #399,d4             * scan lines

*** Do hardcopy
          
do_scan:  tst       _dumpflg            * stop dump
          bne       stop                * yes
*
          move      #10,d3              * init scan line
          lea       prefix,a3
          bsr       pr_str
          tst       d0                  * error
          beq       stop                * stop the dump

          move      #79,d3              * print line
          move.l    a4,a3
          bsr       pr_str
          tst       d0                  * error
          beq       stop                * stop the dump
*
          move      #3,d3               * end scan line
          lea       endfix,a3
          bsr       pr_str
*
          add.l     #80,a4
          dbra      d4,do_scan          * next scan line

*** Stop the printer

stop:     move      #12,d3              * reset printer
          lea       reset,a3
          bsr       pr_str

          move      #$ffff,_dumpflg     * clear dumpflag
          rts                           * d o n e

*** Print string
*   a3 = start adr
*   d3 = cnt -1
*

pr_str:   move.b    (a3)+,d0            * get byte
          and       #$ff,d0             * mask byte
          move      d0,-(sp)            * to aux
          move      #devout,-(sp)
          trap      #gemdos
          add.l     #4,sp

          tst       d0                  * error
          beq       pr_ret              * dont print 

          dbra      d3,pr_str
pr_ret:   rts

*************************************************************************
*
* Constants
*

          .data

init:     .dc.b    $1b,"&a10la10R",$1b,"*c1920a2bP",$1b,"*t100R"
prefix:   .dc.b    $1b,"*r1A",$1b,"*b80W"
endfix:   .dc.b    $1b,"*rB"
reset:    .dc.b    $1b,"*c1920a2bP",$1b,"E"


          .end
