*
* The STOS loader program, commented and labeled
* by Anthony Jacques (jacquesa@cs.man.ac.uk).
*
* Original code by Francois Lionet, and others at
* Jawx / Mandarin Software.
*
* Modifications made by Anthony Jacques:
*   - Extra OS version support
*   - Support for Falcon screen modes 
*   - This is now determined by _MCH cookie, so no confusion with Magic 4/5
*   - OS version detection routine cleaned up
*   - TOS version number now displays correct number.
*
* Known bugs:
*   - On my Falcon, I get 4 bombs on exiting. This
*     seems to be caused by the Vsetscreen call. (why?)
*     The good news is this is non-fatal.
*   - STOS doesn't like MultiTOS. I dont think it is
*     this module, but who knows?
*
* Recent changes:
*   - Added tables for TOS 3.01 and 3.06 (from STOSfix1.1)
*   - Added code for correcting table on unrecognised TOS version.

  output d:\stos\basic207.tos

  bra	start 

* Here are all the TOS tables for TOS's
* 1.00, 1.01, 1.02, 1.04, 1.06, 1.62, 2.05, 2.06
* 3.01, 3.06, 4.01, 4.02, 4.04, 4.96. 
* 1.0 is the default.
* 3.05 included, but invalid. (copied from 3.06)

* the number of tables - 1
NUM_OSVERS	equ	14

* selected if users OS is not this one.
defaultTOS:
  dc.b      $01,$00       OS version number
*                         This I believe the values are. (from BASICMJH)
TOStables:
  dc.l      $000026E0     GCURX (current mouse X)           - Line A
  dc.l      $00000E09     kbdvbase() + $3D  (wrong)
  dc.l      $000DB000     IORec()
  dc.l      $00268600     DEV_TAB (45 words of v_opnwk)     - Line A
  dc.l      $00274800     SIZE_TAB (15 words of dev coords) - Line A
  dc.l      $000DDC00     kbdvbase() + $10  (wrong)
  dc.l      $00000E44     kbdvbase() + $78  (wrong)

  dc.b      $01,$01
  dc.l      $000026E0
  dc.l      $00000E09
  dc.l      $00000DB0
  dc.l      $00002686
  dc.l      $00002746
  dc.l      $00000DDC
  dc.l      $00000E44 

  dc.b      $01,$02
  dc.l      $00002740
  dc.l      $00000E4F
  dc.l      $00000C76
  dc.l      $000026E6
  dc.l      $000027A8
  dc.l      $00000E22
  dc.l      $00000E8A

  dc.b      $01,$04
  dc.l      $00002882
  dc.l      $00000E6B
  dc.l      $00000C92
  dc.l      $00002828
  dc.l      $000028EA
  dc.l      $00000E3E
  dc.l      $00000EA6

  dc.b      $01,$06
  dc.l      $000028C2
  dc.l      $00000EAB
  dc.l      $00000CD2
  dc.l      $00002868
  dc.l      $0000292A
  dc.l      $00000E7E
  dc.l      $00000EE6

  dc.b      $01,$62
  dc.l      $000028C2
  dc.l      $00000EAB
  dc.l      $00000CD2
  dc.l      $00002868
  dc.l      $0000292A
  dc.l      $00000E7E
  dc.l      $00000EE6

  dc.b      $02,$05
  dc.l      $00002476
  dc.l      $00000EAB
  dc.l      $00000CCE
  dc.l      $0000241C
  dc.l      $000024DE
  dc.l      $00000E7E
  dc.l      $00000EE6

  dc.b      $02,$06
  dc.l      $000026AA
  dc.l      $000010B7
  dc.l      $00000ED8
  dc.l      $00002650
  dc.l      $00002712
  dc.l      $00001088
  dc.l      $000010F2

  dc.b      $03,$01       NOT confirmed correct.
  dc.l      $00003596
  dc.l      $00000F0F
  dc.l      $00000D32
  dc.l      $0000353C
  dc.l      $000035FE
  dc.l      $00000EE2
  dc.l      $00000F4A 

  dc.b      $03,$05       NOT correct (probably).
  dc.l      $000037C0
  dc.l      $000010A7
  dc.l      $00000ECA
  dc.l      $00003766
  dc.l      $00003828
  dc.l      $0000107A
  dc.l      $000010E2 

  dc.b      $03,$06       NOT confirmed correct.
  dc.l      $000037C0
  dc.l      $000010A7
  dc.l      $00000ECA
  dc.l      $00003766
  dc.l      $00003828
  dc.l      $0000107A
  dc.l      $000010E2     + 2? (MJH says yes, but writes no)

  dc.b      $04,$01
  dc.l      $00003C2C
  dc.l      $00001175
  dc.l      $00000F96
  dc.l      $00003BD2
  dc.l      $00003C94
  dc.l      $00001146
  dc.l      $000011BC

  dc.b      $04,$02
  dc.l      $00003C2C
  dc.l      $00001175
  dc.l      $00000F96
  dc.l      $00003BD2
  dc.l      $00003C94
  dc.l      $00001146
  dc.l      $000011BC

  dc.b      $04,$04
  dc.l      $00003C2C
  dc.l      $00001175
  dc.l      $00000F96
  dc.l      $00003BD2
  dc.l      $00003C94
  dc.l      $00001146
  dc.l      $000011BC

  dc.b      $04,$92
  dc.l      $000040E0
  dc.l      $00001175
  dc.l      $00000F96
  dc.l      $00004086
  dc.l      $00004148
  dc.l      $00001146
  dc.l      $000011BC

L0002:		* lookup table (includes extension COLDSTART addresses)
  ds.w      104   

* GEMDOS _DTA structure (written to by fsfirst etc)
FILEINFO:   ds.w      13  
filelength  ds.l      1   
filename:   ds.b      20  

freemem:    ds.l      1   
oldlogic:   ds.l      1   
bootrez:    dc.w      0 
oldfalcmode dc.w      0
filehandle  dc.w      0 
osver       ds.w      1		* added by Anthony
mchcook     dc.l      0
L000A:      ds.l      1   
palette:    ds.w      16  
L000C:      ds.w      60  
cls:        dc.b      27,'f',$00 
STOSpath:   dc.b      '\STOS',$00	(appended onto current path)
path:       ds.b      64
newpath:    ds.b      64

* Some filenames
Lowpic:     dc.b      'PIC.PI1',$00 
Hipic:      dc.b      'PIC.PI3',$00 
spritelib:  dc.b      'SPRIT???.BIN',$00 
windowlib:  dc.b      'WINDO???.BIN',$00
floatlib:   dc.b      'FLOAT???.BIN',$00 
musiclib:   dc.b      'MUSIC???.BIN',$00
basiclib:   dc.b      'BASIC???.BIN',$00 
extnfilter: dc.b      '*.EX'
extnletter: dc.b      $00,$00 

* prompts at startup (Esc+Ynn sets position)
* version number set to correct number on startup. (new: 3/1/97 AJ)
lowprompt:  dc.b      27,'Y70','Tos '
lowtosver:  dc.b      '1.62',$00
hiprompt:   dc.b      27,'Y7D','Tos '
hitosver:   dc.b      '1.62',$00 


*****************************

	even

start:
  clr.l     L000A 
  movea.l   4(sp),a0
  lea       128(a0),a0
  tst.b     (a0)
  beq.s     L001D 
  addq.l    #1,a0 
  move.l    a0,L000A
L001D:
  move.w    #3,-(sp) 	;LOGBASE
  trap      #$E 
  addq.l    #2,sp 
  move.l    d0,oldlogic

  pea       inittabs(pc) ; this runs some code below (in supervisor mode)
  move.w    #$26,-(sp) 	; sets up the first TOStable to be one to use
  trap      #$E 	; also init's trap 6 with some odd code. (what is it?)
  addq.l    #6,sp 

  lea       L000C(pc),a6
  move.w    #4,-(sp) 	;GETREZ 
  trap      #$E 
  addq.l    #2,sp 
  move.w    d0,bootrez


  move.l    mchcook(pc),d0
  cmpi.l    #$30000,d0       $30000=Falcon, $20000=TT, $10000=STe, $10010=Mste $10008=STBook, 0=STfm
  blt.s     notfalcinit

  move.w    #-1,-(sp)
  move.w    #88,-(sp)
  trap      #14
  addq.l    #4,sp
  lea       oldfalcmode(pc),a0
  move.w    d0,(a0)

  move.w    bootrez(pc),-(sp)
  move.l    #-1,-(sp)
  move.l    #-1,-(sp)
  move.w    #5,-(sp)
  trap      #14
  lea       12(sp),sp

notfalcinit:
  lea       TOStables(pc),a5
  movea.l   12(a5),a0 
  moveq     #44,d0 
L001E:
  move.w    (a0)+,(a6)+ 
  dbf       d0,L001E

  movea.l   16(a5),a0 
  moveq     #11,d0
L001F:
  move.w    (a0)+,(a6)+ 
  dbf       d0,L001F

  movea.l   0(a5),a0
  move.l    (a0),(a6)+
  move.l    #THEEND,freemem
  bsr       setfileinfo 
  clr.w     -(sp)
  pea       path(pc) 
  move.w    #$47,-(sp) 	;DGETPATH 
  trap      #1
  addq.l    #8,sp 
  tst.w     d0
  bne       quitcleanly 

  lea       path(pc),a0
  lea       newpath(pc),a1
L0020:
  move.b    (a0)+,(a1)+ 
  bne.s     L0020 

  lea       path(pc),a0
  tst.b     (a0)
  bne.s     endslash 
  move.b    #'\',(a0)+
  clr.b     (a0)
endslash:
  subq.l    #1,a1 
  lea       STOSpath(pc),a0
copypath:
  move.b    (a0)+,(a1)+ 
  bne.s     copypath 
  lea       newpath(pc),a0
  bsr       setpath 
  bne       closeandquit 
  clr.w     -(sp) 	* flags there is no pic (changed if found)
  cmpi.w    #2,bootrez
  beq.s     usehipic 
  lea       Lowpic(pc),a0
  bra.s     uselowpic 
usehipic:
  lea       Hipic(pc),a0
uselowpic:

  bsr       fileexists 
  bne       nopic 		* if doesn't exist, clear screen

  bsr       openfile 		* load file to logic - $8000
  movea.l   oldlogic(pc),a0
  suba.l    #$8000,a0 
  move.l    #32034,d0 
  bsr       readbytes 
  bsr       closefile 
  move.w    #-1,(sp)		* flags there is a picture

  dc.b      $a0,$0A 	* line A (dunno what though?) look up.

  lea       bootrez(pc),a0
  tst.w     (a0)
  beq       in_stlow 
  cmpi.w    #2,bootrez
  beq       in_stlow 
  clr.w     -(sp)	switch to ST Low
  move.l    #-1,-(sp) 
  move.l    #-1,-(sp) 
  move.w    #5,-(sp) 	;SETSCREEN
  trap      #$E 
  lea       12(sp),sp
in_stlow:

  lea       cls(pc),a0
  bsr       print 

  move.l    oldlogic(pc),-(sp) 
  subi.l    #$7FFE,(sp) 
  move.w    #6,-(sp) 	;SETPALLETE 
  trap      #$E 
  addq.l    #6,sp 
  moveq     #1,d6 

* screen stretch routine. (you know the one...)
L0026:
  movea.l   oldlogic(pc),a2
  movea.l   a2,a3 
  adda.l    #$3DE0,a2 
  adda.l    #$3E80,a3 
  movea.l   a2,a0 
  movea.l   a3,a1 
  suba.l    #$7FDE,a0 
  suba.l    #$7FDE,a1 
  moveq     #$63,d7 
  addq.w    #1,d6 
  cmp.w     #$64,d6 
  bhi       loadtraps 		* jump out if done it more than $64 times
  moveq     #$32,d5 
L0027:
  ADD.w     d6,d5 
  cmp.w     #$64,d5 
  bcs.s     L0029 
  subi.w    #$64,d5 
  movem.l   a0-a3,-(sp) 

  moveq     #9,d0 
L0028:
  move.l    (a0)+,(a2)+ 
  move.l    (a0)+,(a2)+ 
  move.l    (a0)+,(a2)+ 
  move.l    (a0)+,(a2)+ 
  move.l    (a1)+,(a3)+ 
  move.l    (a1)+,(a3)+ 
  move.l    (a1)+,(a3)+ 
  move.l    (a1)+,(a3)+ 	* inner copy loop (1 line?)
  dbf       d0,L0028

  movem.l   (sp)+,a0-a3 
  suba.l    #$a0,a2 
  adda.l    #$a0,a3 
L0029:
  suba.l    #$a0,a0 
  adda.l    #$a0,a1 
  dbf       d7,L0027		* outer loop (1 screen?)
  bra       L0026

nopic:
  dc.b      $a0,$0A 
  lea       cls(pc),a0
  bsr       print 

* run all the .BIN files (which install themselves in the traps)
loadtraps:
  lea       spritelib(pc),a0
  bsr       loadfile 
  lea       TOStables(pc),a3
  jsr       (a0)
  move.l    a0,freemem

  lea       windowlib(pc),a0
  bsr       loadfile 
  lea       TOStables(pc),a3
  jsr       (a0)
  move.l    a0,freemem

  lea       floatlib(pc),a0
  bsr       loadfileignore
  bne.s     loadmusic 
  lea       TOStables(pc),a3
  jsr       (a0)

loadmusic:
  lea       musiclib(pc),a0
  bsr       loadfile 
  lea       TOStables(pc),a3
  jsr       (a0)
  move.l    a0,freemem


* loop round, loading any .EX[A-Z] files 
  clr.w     d7
  lea       L0002(pc),a6
loadextns:
  move.b    d7,extnletter
  addi.b    #'A',extnletter
  lea       extnfilter(pc),a0
  bsr       fileexists 
  bne.s     nextextn 

  lea       extnfilter(pc),a0
  bsr       loadfile 
  movem.l   a6/d6-d7,-(sp)
  lea       TOStables(pc),a3
  jsr       (a0)		* call extension INIT routine
  move.l    a0,freemem

  movem.l   (sp)+,a6/d6-d7
  move.w    d7,d6 
  lsl.w     #2,d6 		* multiply [0-25] by 4 (offset into table)
  move.l    a1,0(a6,d6.w) 	* store extension COLDBOOT routines in table
nextextn:
  addq.w    #1,d7 
  cmp.w     #26,d7 
  bcs.s     loadextns 

  tst.w     (sp)+ 		* flag set above (pic file exists)
  beq.s     nopicfile 

  move.w    osver(pc),d0
  moveq.w   #0,d1         * set the prompt to show your TOS version
  move.w    d0,d1         * Added by Anthony Jacques
  lsr.w     #8,d1
  addi.b    #'0',d1
  lea       lowtosver(pc),a0
  move.b    d1,(a0)
  lea       hitosver(pc),a0
  move.b    d1,(a0)
  move.b    d0,d1
  and.b     #$F0,d1
  lsr.b     #4,d1
  addi.b    #'0',d1
  lea       lowtosver(pc),a0
  move.b    d1,2(a0)
  lea       hitosver(pc),a0
  move.b    d1,2(a0)
  move.b    d0,d1
  and.b     #$F,d1
  addi.b    #'0',d1
  lea       lowtosver(pc),a0
  move.b    d1,3(a0) 
  lea       hitosver(pc),a0
  move.b    d1,3(a0)

  lea       lowprompt(pc),a0
  cmpi.w    #2,bootrez
  bne.s     lowtostext 
  lea       hiprompt(pc),a0
lowtostext:

  bsr       print 
nopicfile:

* load the editor
  lea       basiclib(pc),a0
  bsr       loadfile 
  move.l    a0,-(sp)

* set path to initial path (ie. not in STOS\)
  lea       path(pc),a0
  bsr       setpath 
  movea.l   (sp)+,a6

* wait for a Vsync before going
  move.w    #$25,-(sp) 	;VSYNC
  trap      #$E 
  addq.l    #2,sp 

* clear the screen (fill with colour 0)
  movea.l   oldlogic(pc),a0
  move.w    #7999,d0 	(8000*4=32000)
clslp:
  clr.l     (a0)+ 
  dbf       d0,clslp

  lea       bootrez(pc),a0
  cmpi.w    #2,(a0)
  beq.s     hieditor 

* jump to medium
  move.w    #1,-(sp)
  move.l    #-1,-(sp) 
  move.l    #-1,-(sp) 
  move.w    #5,-(sp) 	;SETSCREEN
  trap      #$E 
  lea       12(sp),sp

* run the editor itself
hieditor:
  lea       L0002(pc),a0
  lea       TOStables(pc),a3
  movea.l   L000A(pc),a4
  clr.l     d0
  jsr       (a6)

* interpeter finished - lets quit.
  bra       quitcleanly 

closeandquit:
  bsr       closefile 
  lea       path(pc),a0
  bsr       setpath 

quitcleanly:
* restore screen, and screen-mode
  move.l    mchcook(pc),d0
  cmp.l     #$30000,d0
  blt.s     notfalcquit

  move.w    oldfalcmode(pc),-(sp) 
  move.w    #3,-(sp)			3=extended mode
  move.l    oldlogic(pc),-(sp)
  move.l    oldlogic(pc),-(sp)
  move.w    #5,-(sp)    VSETSCREEN
  trap      #14
*  lea.l     14(sp),sp
  adda.l    #14,sp

  bra.s     inoldmode

notfalcquit:
  move.w    bootrez(pc),-(sp) 
  move.l    oldlogic(pc),-(sp) 
  move.l    oldlogic(pc),-(sp) 
  move.w    #5,-(sp) 	;SETSCREEN
  trap      #14 
  lea       12(sp),sp

inoldmode:
* do something to TOStables (copy from backup?)
  lea       L000C(pc),a6
  lea       TOStables(pc),a5
  movea.l   12(a5),a0 
  moveq     #$2C,d0 
L0035:
  move.w    (a6)+,(a0)+ 
  dbf       d0,L0035
  movea.l   16(a5),a0 
  moveq     #$B,d0
L0036:
  move.w    (a6)+,(a0)+ 
  dbf       d0,L0036
  movea.l   0(a5),a0
  move.l    (a6)+,(a5)

* restore palette
  pea       palette(pc) 
  move.w    #6,-(sp) 	;SETPALLETE 
  trap      #14 
  addq.l    #6,sp 
  move.w    #$25,-(sp) 	;VSYNC
  trap      #14 
  addq.l    #2,sp 

* and quit...

  clr.w     -(sp) 	;PTERM0
  trap      #1

****** 

inittabs:

  lea       $FF8240.l,a0	* st palette
  lea       palette(pc),a1
  moveq     #$F,d0
copypal:
  move.w    (a0)+,(a1)+ 	* copy palette
  dbf       d0,copypal

****
* get _MCH cookie
  move.l    $5a0,d0
  tst.l     d0
  beq.s     .nocook       No cookie jar = plain ST.
  move.l    d0,a0
  move.l    #'_MCH',d0

.nextcook
  tst       (a0)
  beq.s     .nocook       No _MCH cookie = plain ST.
  move.l    (a0)+,d1
  cmp.l     d0,d1
  beq.s     .fndcook
  addq.l    #4,a0
  bra.s     .nextcook

.fndcook
  lea       mchcook(pc),a6
  move.l    (a0),d0
  move.l    d0,(a6)
.nocook

********** Get OS version VERY dirty method ************
* install own bus error handler.
* read from 192k ROM space. If causes a bus error, read from 512k ROM space.
* re-install old bus-error handler
*
* code replaced with a clean version.
* (get ROM space address from _sysbase and look 2 above)

  move.l    $4f2,a0
  move.w    2(a0),d0
  lea       osver(pc),a0
  move.w    d0,(a0)

****
*
* Now set up look-up-tables. Look up in known TOS versions.
* If not found, use default.
* whatever, patch some of the addresses to known values.
* (will eventually replace tables completely when all addresses known)

  lea       defaultTOS(pc),a0
  move      #NUM_OSVERS,d1
findtablp:
  cmp.w     (a0)+,d0		* search for OS ver, else skip 28 more bytes
  beq.s     foundtab 
  adda.w    #28,a0 
  dbf       d1,findtablp
  lea       TOStables(pc),a0	* if failed, restore default table

foundtab:

* set TOS table to correct values.

  movea.l   a0,a6
  dc.b      $a0,$00		* line-a init

  move.l    a0,d0  		GCURX
  subi.l    #$25a,d0
  move.l    d0,(a6)
 
  move.l    a0,d0		DEV_TAB
  subi.l    #$2b4,d0
  move.l    d0,12(a6) 

  move.l    a0,d0 		SIZ_TAB
  subi.l    #$1f2,d0
  move.l    d0,16(a6) 

  move.w    #1,-(sp)
  move.w    #14,-(sp) 	;IOREC 
  trap      #14
  addq.l    #4,sp
  move.l    d0,8(a6)
  movea.l   a6,a0

  lea       TOStables(pc),a2
  moveq     #6,d0 
copytab:
  move.l    (a0)+,(a2)+ 	* copy 24 bytes to first table
  dbf       d0,copytab

  move.l    #trap6hand,d0 	* install trap 6 handler
  move.l    d0,$98.l
  rts 

* trap 6 handler
trap6hand:
  cmp.b     #$C,d0
  beq.s     L003F 
  moveq     #0,d0 
  moveq     #0,d1 
  rte 

* trap 6, when d0 = $c
L003F:
  move.b    #$30,(a0) 
  move.b    #$2E,1(a0)
  move.b    #$30,2(a0)
  clr.b     3(a0) 
  rte 

* sets the OS _DTA structure to space alocated above
setfileinfo:
  move.l    a0,-(sp)
  pea       FILEINFO(pc) 
  move.w    #$1A,-(sp) 	;DSETDTA
  trap      #1
  addq.l    #6,sp 
  movea.l   (sp)+,a0
  rts 

* sets the path to that given in a0
setpath:
  move.l    a0,-(sp)
  move.w    #$3B,-(sp) 	;DSETPATH 
  trap      #1
  addq.l    #6,sp 
  tst.w     d0
  rts 

* sets the condition codes depending on whether the given file exists
fileexists:
  clr.w     -(sp) 
  move.l    a0,-(sp)
  move.w    #$4E,-(sp) 	;FSFIRST
  trap      #1
  addq.l    #8,sp 
  lea       filename(pc),a0
  tst.w     d0
  rts 

* opens a file, putting the handle in 'filehandle'
openfile:
  clr.w     -(sp) 
  move.l    a0,-(sp)
  move.w    #$3D,-(sp) 	;FOPEN
  trap      #1
  addq.l    #8,sp 
  tst.w     d0
  bmi       closeandquit 
  move.w    d0,filehandle
  rts 

* reads the complete contents of the open file (assumes it was the last file searched for)
readfile:
  move.l    filelength,d0

* reads d0 bytes from the current file
readbytes:
  move.l    a0,-(sp)
  move.l    d0,-(sp)
  move.w    filehandle(pc),-(sp) 
  move.w    #$3F,-(sp) 	;FREAD
  trap      #1
  lea       12(sp),sp
  tst.l     d0
  bmi       closeandquit 
  rts 

* closes the currently open file
closefile:
  move.w    filehandle(pc),-(sp) 
  move.w    #$3E,-(sp) 	;FCLOSE 
  trap      #1
  addq.l    #4,sp 
  rts 

* prints some text to the screen
print:
  move.l    a0,-(sp)
  move.w    #9,-(sp) 	;CCONWS 
  trap      #1
  addq.l    #6,sp 
  rts 

* load file (returning mem addr in a0)
loadfile:
  bsr       loadfileignore 
  bne       closeandquit 
  rts 

* loads file ignoring error (returns -ive error but doesn't quit)
loadfileignore:
  movem.l   a1-a3/d1-d3,-(sp) 
  bsr       setfileinfo 
  bsr       fileexists 
  bne       returnerror 
  move.l    freemem(pc),d3
  add.l     filelength(pc),d3
  addi.l    #60000,d3 
  cmp.l     oldlogic(pc),d3
  bcc       closeandquit 
  bsr       openfile 
  movea.l   freemem(pc),a0
  bsr       readfile 
  bsr       closefile 
  movea.l   freemem(pc),a1
  move.l    2(a1),d0
  add.l     6(a1),d0
  andi.l    #$FFFFFF,d0 
  adda.w    #$1C,a1 
  movea.l   a1,a2 
  move.l    a2,d2 
  adda.l    d0,a1 
  clr.l     d0
  tst.l     (a1)
  beq.s     L004D 
  adda.l    (a1)+,a2
  bra.s     L004B 
L004A:
  move.b    (a1)+,d0
  beq.s     L004D 
  cmp.b     #1,d0 
  beq.s     L004C 
  adda.w    d0,a2 
L004B:
  add.l     d2,(a2) 
  bra.s     L004A 
L004C:
  adda.w    #$FE,a2 
  bra.s     L004A 
L004D:
  movea.l   freemem(pc),a0
  move.l    a0,d0 
  add.l     filelength(pc),d0
  btst      #0,d0 
  beq.s     L004E 
  addq.l    #1,d0 
L004E:
  move.l    d0,freemem
  movem.l   (sp)+,a1-a3/d1-d3 
  moveq     #0,d0 
  rts 
returnerror:
  movem.l   (sp)+,a1-a3/d1-d3 
  moveq     #1,d0 
  rts 

THEEND
	END