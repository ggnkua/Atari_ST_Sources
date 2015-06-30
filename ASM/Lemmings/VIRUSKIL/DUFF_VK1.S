***************************************************************************
* LEMMINGS Anti-Virus Bootsector Installer                                *
***************************************************************************
* Some ideas taken from Medway Boys Virus Killer IV.                      *
* Additional ideas added by Info Freako.                                  *
* Nice colours thought up by Info Freako.                                 *
* Nicely ripped off by Neuromancer of Hysteria !!!!                       *
***************************************************************************
* This is OFFICIAL RELEASE version 1.0a                                   *
***************************************************************************

start
  move.w    #4,-(a7) 			* getrez
  trap      #14 
  addq.l    #2,a7 
  move.w    d0,old_rez 
  move.w    #1,-(a7)
  move.l    #-1,-(a7) 
  move.l    #-1,-(a7) 
  move.w    #5,-(a7) 	  		* setscreen
  trap      #14 
  lea       12(a7),a7 
  clr.l     -(a7) 
  move.w    #32,-(a7) 			* super
  trap      #1
  addq.l    #6,a7 
  move.l    d0,old_stack
  move.l    #info,-(a7) 
  move.w    #9,-(a7) 			* cconws
  trap      #1
  addq.l    #6,a7 
scan
  move.w    #8,-(a7) 			* cnecin
  trap      #1
  addq.l    #2,a7 
  cmp.b     #49,d0
  beq.s     booty 
  cmp.b     #32,d0
  bne.s     scan
  move.w    old_rez,-(a7)
  move.l    #-1,-(a7) 
  move.l    #-1,-(a7) 
  move.w    #5,-(a7) 			* setscreen
  trap      #14 
  lea       12(a7),a7 
  move.l    old_stack,-(a7) 
  move.w    #32,-(a7) 	 		* super
  trap      #1
  addq.l    #6,a7 
  clr.w     -(a7) 			* pterm0
  trap      #1
booty
  lea       boot_code(pc),a6
  bsr.s     read
  bsr       exec
  bsr       write 
  bra.s     scan
read
  move.w    #1,-(a7)
  move.w    #0,-(a7)
  move.w    #0,-(a7)
  move.w    #1,-(a7)
  move.w    #0,-(a7)
  move.l    #0,-(a7)
  pea       buffer(pc)
  move.w    #8,-(a7) 	 		* floprd
  trap      #14 
  lea       20(a7),a7 
  lea       buffer(pc),a0 
  move.w    #24604,(a0) 
  lea       30(a0),a0 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  move.l    (a6)+,(a0)+ 
  rts 
exec
  move.w    #1,-(a7)
  move.w    #-1,-(a7) 
  move.l    #-1,-(a7) 
  pea       buffer(pc)
  move.w    #18,-(a7) 			* protobt
  trap      #14 
  lea       14(a7),a7 
  rts 
write
  move.w    #1,-(a7)
  move.w    #0,-(a7)
  move.w    #0,-(a7)
  move.w    #1,-(a7)
  move.w    #0,-(a7)
  move.l    #0,-(a7)
  pea       buffer(pc)
  move.w    #9,-(a7) 			* flopwr
  trap      #14 
  lea       20(a7),a7 
  rts 
boot_code
  lea       -32192.W,a6 
  move.w    #$777,30(a6)		* 1st TEXT COLOUR
  lea       prot_text(pc),a0
  bsr       print_text
  movea.l   1070.W,a0 
  cmpa.l    #4194300,a0 
  ble.s     virus_check1
  lea       -4(a0),a0 
virus_check1
  movea.l   a0,a1 
  cmpi.l    #303182934,(a1)+
  beq.s     print_reset_res 
  lea       -512(a0),a0 
  cmpa.l    #0,a0 
  bgt.s     virus_check1
  cmpi.l    #826366246,1062.W 
  beq.s     print_reset_change 
  move.w    #$060,(a6)			* CLEAN BACK COLOUR
  lea       mess_virus_free(pc),a0
  bsr.s     print_text
  move.l    #327680,d0
pause
  subq.l    #1,d0 
  bne.s     pause 
  move.l    #641466368,320.W
exit1
  move.w    #$777,(a6)			* WHITE BACK - EXIT
  move.w    #$000,30(a6)		* BLACK TEXT - EXIT 
  rts 
print_reset_change
  move.w    #$711,(a6)			* RESET VEC CHANG - BACK
  lea       mess_reset_change(pc),a0 
  bsr.s     print_text
  clr.w     d7
  bra.s     print_options 
print_reset_res
  movea.l   a0,a5 
  move.w    #$711,(a6)			* RESET RES PROG - BACK
  move.w    #1,d7 
  lea       mess_reset_res(pc),a0 
  bsr.s     print_text
print_options
  lea       mess_options(pc),a0
  bsr.s     print_text
check_keys
  move.w    #7,-(a7) 			* crawcin
  trap      #1
  addq.l    #2,a7 
  swap      d0
  cmpi.b    #59,d0
  beq.s     exit1 
  cmpi.b    #60,d0
  bne.s     check_keys
  clr.l     1062.W
  clr.l     1066.W
  cmp.w     #0,d0 
  beq.s     exit1 
  clr.l     (a5)+ 
  movea.l   4.W,a0
  jmp       (a0)
print_text
  move.l    a0,-(a7)
  move.w    #9,-(a7) 			* cconws
  trap      #1
  addq.l    #6,a7 
  rts 
*************1234567890123456789012345678901234567890**********************
prot_text
  dc.b      '             DUFF SOFTWARE',13,10
  dc.b      '             ÿÿÿÿÿÿÿÿÿÿÿÿÿ',13,10,13,10
  dc.b      '         STOS Development Disk',13,10,13,10,13,10,13,10,13,10,13,10,0
mess_virus_free
  dc.b      "           No Virus in Memory",0
mess_reset_change
  dc.b      '          Reset Vector Changed',13,10,13,10
  dc.b	    '             POSSIBLE VIRUS!',0 
mess_reset_res
  dc.b      '      Reset Resident Program Found',13,10,13,10 
  dc.b      '             POSSIBLE VIRUS!',0
mess_options
  dc.b      $1B,'Y,,',' F1 - Ignore'
  dc.b	    $1B,'Y.,',' F2 - Restore',0,0
***************************************************************************
info
  dc.b      '                          LEMMINGS Bootsector Installer.',13,10
  dc.b	    '                          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~',13,10,13,10
  dc.b	    '                               Coded By Info Freako',13,10
  dc.b	    '                               ~~~~~~~~~~~~~~~~~~~~',13,10,13,10
  dc.b	    '               Press     1: Install Anti Virus Bootsector',13,10
  dc.b	    '                     Space: Exit to desktop',13,10,13,10,13,10
  dc.b	    '          There are no safety checks so do NOT touch the keyboard',13,10
  dc.b	    '                          while the disk drive light is on.',13,10,0,0
old_rez
  dc.b      $00,$00 
old_stack:
  dcb.w     2,0 
buffer
  dcb.w     256,0 
zuend: 	    end
