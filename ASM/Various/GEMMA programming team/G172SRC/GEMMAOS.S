*
* The STOS loader program, commented and labeled
* by Anthony Jacques (jacquesa@cs.man.ac.uk)
* and Paul Jones (paulat.jones@zetnet.co.uk).
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
* Additional by Paul Jones:
*   - When exiting on Falcon resolutions does not crash.
*   - STOS doesn't assume it has all available memory. Mfree all memory 
*     apart from 100000 bytes, then allocate memory for STOS with malloc.
*     STOS 'free' command returns 600000 on my machine, malloc -1 (largest 
*     block of memory is over a meg _without_ the GEMMA acc!!!
*   - STOS now works in MultiTOS, and with GEMMA!...
*
* Known bugs:
*   - When quit, system colours appear darker on Falcons when in a ST
*     compatable mode (!)
*
* Recent changes:
*   - Added tables for TOS 3.01 and 3.06 (from STOSfix1.1)
*   - Added code for correcting table on unrecognised TOS version.

  output c:\basic208.prg

aes	macro	aes_number
	move	#\1,d0
	lea.l	control(pc),a1
	move.w	d0,(a1)+			store the op code
	sub.w	#10,d0
	mulu	#3,d0			size is the priority, not speed
	lea.l	gem_ctrl_list(pc),a0
	add.w	d0,a0			points to the entry
	moveq	#0,d0
	move.b	(a0)+,d0
	move.w	d0,(a1)+		do control1
	move.b	(a0)+,d0
	move.w	d0,(a1)+		and control2
	move.b	(a0)+,d0
	move.w	d0,(a1)+		and control3
	clr.w	(a1)			assumes control4=0 (all except RSRC_GADDR)
	lea.l	aes_params(pc),a2
* aes_params	dc.l	control,global,int_in,int_out,addr_in,addr_out

	lea.l	control(pc),a4
	move.l	a4,(a2)
	lea.l	global(pc),a4
	move.l	a4,4(a2)
	lea.l	int_in(pc),a4
	move.l	a4,8(a2)
	lea.l	int_out(pc),a4
	move.l	a4,12(a2)
	lea.l	addr_in(pc),a4
	move.l	a4,16(a2)
	lea.l	addr_out(pc),a4
	move.l	a4,20(a2)

	move.l	a2,d1
	move.w	#200,d0			function number
	trap	#2
*	moveq.l	#0,d2
*	move.l	d0,d3
*	lea	int_out-DATA(a3),a0
*	move.l	(a0),-(a6)		usually a returned value
	endm

  bra	start 

* Here are all the TOS tables for TOS's
* 1.00, 1.01, 1.02, 1.04, 1.06, 1.62, 2.05, 2.06
* 3.01, 3.06, 4.01, 4.02, 4.04, 4.96. 
* 1.0 is the default.
* 3.05 included, but invalid. (copied from 3.06)

aes_params	ds.l	6
control		ds.w	5
global		ds.w	14
int_in		ds.w	16
int_out		ds.w	7
addr_in		ds.l	3
addr_out	ds.l	1
gemma		dc.b	0,4,"1.65"
mystore		ds.l	1
x_out		ds.l	1
y_out		ds.l	1
w_out		ds.l	1
h_out		ds.l	1
button		ds.l	1
kstate		ds.l	1
key_pressed	ds.l	1
gotclicks	ds.l	1
addr		ds.l	1
oldsp		ds.l	1
newsp		ds.l	1

mupb		ds.l	1

dump1		ds.w	1
dump2		ds.l	1
dump3		ds.l	1
dump4		ds.l	1

param		ds.l	4

* the number of tables - 1
NUM_OSVERS	equ	14

* selected if users OS is not this one.
defaultTOS:
  dc.b      $01,$00       OS version number
*                         This I believe the values are. (from BASICMJH)
TOStables:
  dc.l      $000026E0     GCURX (current mouse X)           - Line A
* 8
  dc.l      $00000E09     kbdvbase() + $3D  (wrong)
* 16  
  dc.l      $000DB000     IORec()
* 24
  dc.l      $00268600     DEV_TAB (45 words of v_opnwk)     - Line A
* 32
  dc.l      $00274800     SIZE_TAB (15 words of dev coords) - Line A
* 40  
  dc.l      $000DDC00     kbdvbase() + $10  (wrong)
* 44
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
  ds.w      104   * 104

* GEMDOS _DTA structure (written to by fsfirst etc)
FILEINFO:   ds.w      13  
filelength  ds.l      1   
filename:   ds.b      20  

freemem:    ds.l      1   
oldlogic:   ds.l      1   
oldphysic:  ds.l      1		* added by PJ
supdump:    ds.l      1		* added by PJ
shifter:    ds.l      1		* added by PJ
bootrez:    dc.w      0 
oldfalcmode dc.w      0
filehandle  dc.w      0 
osver       ds.w      1		* added by Anthony
mchcook     dc.l      0
L000A:      ds.l      1   
paletteST:  ds.w      16

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
*windowlib:  dc.b      'TRAPS.PRG',$00
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

	move.l	4(a7),a3	* find basepage
*	lea.l	baspage(pc),a2
*	move.l	a3,(a2)
*	move.l	a3,300008
	move.l	#100000,-(sp)	* how much to keep 
	move.l	a3,-(sp)	* start of address to keep
	move.w	#0,-(sp)
	move.w	#$4A,-(sp)	* mskrink
	trap	#1
	add.l	#12,sp

*	cmp.w	#0,d0
*	bne	quitprog

* Get everything for gemsys NOW!
* superexec the code!

  clr.l     L000A 
  movea.l   4(sp),a0
  lea       128(a0),a0
  tst.b     (a0)
  beq.s     L001D 
  addq.l    #1,a0 
  move.l    a0,L000A

* the above checks for a command line (.BAS files are loaded).

L001D:
  move.w    #3,-(sp) 	;LOGBASE
  trap      #$E 
  addq.l    #2,sp 
  move.l    d0,oldlogic

  move.w    #2,-(sp)	; PHYSBASE (added by Paul)
  trap      #$E
  addq.l    #2,sp
  move.l    d0,oldphysic

*	movem.l	d0-d7/a0-a5,-(sp)

	pea	startit(pc)
	move.w	#$26,-(sp)
	trap	#14
	add.l	#6,sp

*	bsr	startit


  pea       inittabs(pc) ; this runs some code below (in supervisor mode)
  move.w    #$26,-(sp) 	; sets up the first TOStable to be one to use
  trap      #$E 	; also init's trap 6 with some odd code. (what is it?)
  addq.l    #6,sp 

*	pea	gemosalert2(pc)
*	move.w	#$13C,-(sp)
*	trap	#1
*	addq.l	#6,sp



*	jmp	inittabs(pc)

  move.l    mchcook(pc),d0
  cmpi.l    #$30000,d0       $30000=Falcon, $20000=TT, $10000=STe, $10010=Mste $10008=STBook, 0=STfm
  blt.s     notfalcinit

  move.w    #-1,-(sp)			* get current screen res
  move.w    #88,-(sp)
  trap      #14
  addq.l    #4,sp
  lea       oldfalcmode(pc),a0
  move.w    d0,(a0)

*	pea	gemosalert2(pc)
*	move.w	#$13C,-(sp)
*	trap	#1
*	addq.l	#6,sp


  move.w    bootrez(pc),-(sp)		* go into STOS's bootres
  move.l    #-1,-(sp)
  move.l    #-1,-(sp)
  move.w    #5,-(sp)
  trap      #14
  lea       12(sp),sp

*	pea	gemosalert2(pc)
*	move.w	#$13C,-(sp)
*	trap	#1
*	addq.l	#6,sp

	move.l	#200,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,a6
	lea	gembuffer(pc),a0
	move.l	a6,(a0)


notfalcinit:
  lea       TOStables(pc),a5
  movea.l   12(a5),a0 
  moveq     #44,d0 

*	pea	gemosalert2(pc)
*	move.w	#$13C,-(sp)
*	trap	#1
*	addq.l	#6,sp

** somewhere
** this is trying to copy the tables to address 0
** which give a bus error (stack pointer, program counter etc)
** overwritten! a6=0

*	move.l	#1474160,a6
*	lea.l	baspage(pc),a6
*	move.l	(a6),a5
*	add.l	#1112,a5
*	move.l	a5,a6

*	move.l	mintcook(pc),a0
*	move.l	a0,d0

*	move.l	a6,d0
*	tst.l	d0
*	beq	my2

*	cmp.l	#0,a6
*	beq	my4

*	lea	freemem(pc),a2
*	move.l	(a2),a6

L001E:
  move.w    (a0)+,(a6)+ 
  dbf       d0,L001E

* copies 44 bytes from tostables+12 to a6 (which is??)

* here

*	pea	gemosalert2(pc)
*	move.w	#$13C,-(sp)
*	trap	#1
*	addq.l	#6,sp

  movea.l   16(a5),a0 
  moveq     #11,d0
L001F:
  move.w    (a0)+,(a6)+ 
  dbf       d0,L001F

* copies 11 bytes from tostables+16 (a0) to a6

*	pea	gemosalert2(pc)
*	move.w	#$13C,-(sp)
*	trap	#1
*	addq.l	#6,sp

  movea.l   0(a5),a0
  move.l    (a0),(a6)+
*  move.l    #THEEND,freemem

* copies the TOS version (?), tostable to a6

* Create new freemem address

	move.l	#240000,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	lea.l	freemem(pc),a5
	move.l	d0,(a5)
	lea.l	freemem2(pc),a5
	move.l	d0,(a5)


*	pea	gemosalert2(pc)
*	move.w	#$13C,-(sp)
*	trap	#1
*	addq.l	#6,sp

my2

	lea	gembuffer(pc),a0
	move.l	a6,100(a0)


*	pea	gemosalert2(pc)
*	move.w	#$13C,-(sp)
*	trap	#1
*	addq.l	#6,sp

  bsr       setfileinfo 
  clr.w     -(sp)
  pea       path(pc) 
  move.w    #$47,-(sp) 	;DGETPATH 
  trap      #1
  addq.l    #8,sp 
  tst.w     d0
  bne       quitcleanly 

**** 9
*	pea	gemosalert2(pc)
*	move.w	#$13C,-(sp)
*	trap	#1
*	addq.l	#6,sp


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

*** 10
*	pea	gemosalert2(pc)
*	move.w	#$13C,-(sp)
*	trap	#1
*	addq.l	#6,sp


  bsr       fileexists 

** 11
*	pea	gemosalert2(pc)
*	move.w	#$13C,-(sp)
*	trap	#1
*	addq.l	#6,sp

	cmp.l	#0,a6
	beq	my3
	
	move.l	#-1,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp

my3

  bne       nopic 		* if doesn't exist, clear screen

** 12 (yeah!)
*	pea	gemosalert2(pc)
*	move.w	#$13C,-(sp)
*	trap	#1
*	addq.l	#6,sp

*  bsr       openfile 		* load file to logic - $8000
*  movea.l   oldlogic(pc),a0
*  suba.l    #$8000,a0 
*  move.l    #32034,d0 
*  bsr       readbytes 
*  bsr       closefile 
*  move.w    #-1,(sp)		* flags there is a picture
*  move.w    #-1,(sp)

*  dc.b      $a0,$0A 	* line A (dunno what though?) look up.

* Hides mouse!!! See SALAD document

*	pea	gemosalert2(pc)
*	move.w	#$13C,-(sp)
*	trap	#1
*	addq.l	#6,sp

*  lea       bootrez(pc),a0
*  tst.w     (a0)
*  beq       in_stlow 
*  cmpi.w    #2,bootrez
*  beq       in_stlow 
*  clr.w     -(sp)	switch to ST Low
*  move.l    #-1,-(sp) 
*  move.l    #-1,-(sp) 
*  move.w    #5,-(sp) 	;SETSCREEN
*  trap      #$E 
*  lea       12(sp),sp
in_stlow:

  lea       cls(pc),a0
  bsr       print 

*  move.l    oldlogic(pc),-(sp) 
*  subi.l    #$7FFE,(sp) 
*  move.w    #6,-(sp) 	;SETPALLETE 
*  trap      #$E 
*  addq.l    #6,sp 
*  moveq     #1,d6 

*	pea	gemosalert2(pc)
*	move.w	#$13C,-(sp)
*	trap	#1
*	addq.l	#6,sp

* screen stretch routine. (you know the one...)
*L0026:
*  movea.l   oldlogic(pc),a2
*  movea.l   a2,a3 
*  adda.l    #$3DE0,a2 
*  adda.l    #$3E80,a3 
*  movea.l   a2,a0 
*  movea.l   a3,a1 
*  suba.l    #$7FDE,a0 
*  suba.l    #$7FDE,a1 
*  moveq     #$63,d7 
*  addq.w    #1,d6 
*  cmp.w     #$64,d6 
*  bhi       loadtraps 		* jump out if done it more than $64 times
*  moveq     #$32,d5 
*L0027:
*  ADD.w     d6,d5 
*  cmp.w     #$64,d5 
*  bcs.s     L0029 
*  subi.w    #$64,d5 
*  movem.l   a0-a3,-(sp) 
*
*  moveq     #9,d0 
*L0028:
*  move.l    (a0)+,(a2)+ 
*  move.l    (a0)+,(a2)+ 
*  move.l    (a0)+,(a2)+ 
*  move.l    (a0)+,(a2)+ 
*  move.l    (a1)+,(a3)+ 
*  move.l    (a1)+,(a3)+ 
*  move.l    (a1)+,(a3)+ 
*  move.l    (a1)+,(a3)+ 	* inner copy loop (1 line?)
*  dbf       d0,L0028
*
*  movem.l   (sp)+,a0-a3 
*  suba.l    #$a0,a2 
*  adda.l    #$a0,a3 
*L0029:
*  suba.l    #$a0,a0 
*  adda.l    #$a0,a1 
*  dbf       d7,L0027		* outer loop (1 screen?)
*  bra       L0026

nopic:
  dc.b      $a0,$0A 
  lea       cls(pc),a0
  bsr       print 
my4
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
*	move.l	a0,freemem

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

	  lea.l	gembuffer(pc),a6
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
* Supermode, oldphysic, sshiftmd and usermode by Paul Jones

  move.l    mchcook(pc),d0
  cmp.l     #$30000,d0
  blt.s     notfalcquit

  clr.l     -(sp)
  move.w    #$20,-(sp)
  trap      #1			* supervisor mode (for setting res and setting sshiftmd)
  addq.l    #6,sp
  lea.l     mystack(pc),a0
  move.l    d0,(a0)

  move.w    oldfalcmode(pc),-(sp) 
  move.w    #3,-(sp)			3=extended mode
  move.l    oldphysic(pc),-(sp)
  move.l    oldlogic(pc),-(sp)
  move.w    #5,-(sp)    VSETSCREEN
  trap      #14
  adda.l    #14,sp

  lea.l     shifter(pc),a0
  move.w    (a0),$44c			* reset old shifter status

  lea.l     mystack(pc),a0
  move.l    (a0),-(sp)

  move.w    #$20,-(sp)
  trap      #1			* back to user mode
  addq.l    #6,sp

  bra.s     inoldmode

notfalcquit:

  clr.l     -(sp)
  move.w    #$20,-(sp)
  trap      #1			* supervisor mode (for setting res and setting sshiftmd)
  addq.l    #6,sp
  lea.l     mystack(pc),a0
  move.l    d0,(a0)

  move.w    bootrez(pc),-(sp) 
  move.l    oldlogic(pc),-(sp) 
  move.l    oldlogic(pc),-(sp) 
  move.w    #5,-(sp) 	;SETSCREEN
  trap      #14 
  lea       12(sp),sp

  lea.l     shifter(pc),a0
  move.w    (a0),$44c	* reset old shifter status

  lea.l     mystack(pc),a0
  move.l    (a0),-(sp)
*  clr.l     -(sp)
  move.w    #$20,-(sp)
  trap      #1			* back to user mode
  addq.l    #6,sp



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

* restore ST palette
  pea.l     paletteST(pc) 
  move.w    #6,-(sp) 	;SETPALLETE 
  trap      #14 
  addq.l    #6,sp 

* restore TT palette

*	lea	$FF8400.l,a0	* TT palette
*	lea	paletteTT(pc),a1
*	move.w	#254,d0
*copyttpalb:
*	move.w	(a1)+,(a0)+		* r
*	move.w	(a1)+,(a0)+		* g
*	move.w	(a1)+,(a0)+		* b
*	dbf	d0,copyttpalb

*	lea	$FF9800.l,a0	* Falcon030 "VIDEL" palette
*	lea	paletteFlc(pc),a1
*	move.w	#254,d0
*copyfalcpalb:
*	move.w	(a1)+,(a0)+		* r
*	move.w	(a1)+,(a0)+		* g
*	move.w	(a1)+,(a0)+		* b
*	dbf	d0,copyfalcpalb


*	lea	palette(pc),a0
*	move	#255,d0
*	move	#0,d1
*copymypal:

*	move.w	#14,contrl
*	move.w  #0,contrl1
*	move.w	#0,contrl2
*	move.w	#4,contrl3
*	move.w	#0,contrl4
*	move.w  #0,contrl5
*	move.w	#1,contrl6

*	move.w	d1,intin
*	move.w	(a0)+,intin+2
*	move.w	(a0)+,intin+4
*	move.w	(a0)+,intin+6

*	bsr	call_vdi

 *	add	#1,d1
*	cmp	d0,d1
*	bne	copymypal

* Copied system colours

  move.w    #$25,-(sp) 	;VSYNC
  trap      #14 
  addq.l    #2,sp 

* de-alocate work space

	lea.l	freemem2(pc),a0
	move.l	(a0),-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp

* and quit...

*  clr.w     -(sp) 	;PTERM0
quitprog
	move.w	#0,-(sp)
	move.w	#$4c,-(sp)	* PTERM (quit)
	trap	#1

****** 
* (ran in supervisor mode)

inittabs:

	lea.l	shifter(pc),a0
	move.w	$44c,(a0)

	lea	$FF8240.l,a0	* ST palette
	lea	paletteST(pc),a1
	moveq	#$F,d0
copypal:
	move.w	(a0)+,(a1)+
	dbf	d0,copypal

*	move.l	$ff8400,a0
*	lea.l	paletteTT(pc),a1
*	move.w	#254,d0
*copyttpal:
*	move.w	(a0)+,(a1)+	* r
*	move.w	(a0)+,(a1)+	* g
*	move.w	(a0)+,(a1)+	* b
*	dbf	d0,copyttpal

*	move.l	$FF9800,a0	* Falcon030 "VIDEL" palette
*	lea.l	paletteFlc(pc),a1
*	move.w	#254,d0
*copyfalcpal:
*	move.w	(a0)+,(a1)+	* r
*	move.w	(a0)+,(a1)+	* g
*	move.w	(a0)+,(a1)+	* b
*	dbf	d0,copyfalcpal

* 	movem.l	(sp)+,d0-d7/a0-a5

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

startit:

	movem.l	a0-a6/d0-d6,-(sp)	* save registers

	lea.l	gembuffer(pc),a0

	move.l	a0,-(sp)

****
* get _VDO cookie
	move.l    $5a0,d0
	tst.l     d0
	beq.s     .nocook       No cookie jar = plain ST.
	move.l    d0,a0
	move.l    #'_VDO',d0

.nextcook
	tst       (a0)
	beq.s     .nocook       No _VDO cookie = plain ST.
	move.l    (a0)+,d1
	cmp.l     d0,d1
	beq.s     .fndcook
	addq.l    #4,a0
	bra.s     .nextcook

.fndcook
	lea       vdocook(pc),a6
	move.l    (a0),d0
	move.l    d0,(a6)
.nocook

	move.l	(sp)+,a0

	move.l	vdocook(pc),d0		* VDO type
	move.l	d0,56(a0)

*	move.l	#0,-(sp)
*	move.w	#$20,-(sp)
*	trap	#1
*	add.l	#6,sp

	lea.l	gemmaosver(pc),a1
	move.l	a1,(a0)			* OS version
	lea.l	gemmaosby(pc),a1
	move.l	a1,4(a0)		* by

	move.l	a0,-(sp)
	move.w	#$22,-(sp)
	trap	#14
	add.l	#2,sp
	move.l	(sp)+,a0

	move.l	d0,72(a0)
	add.l	#16,d0			* kbdvbase+16
	move.l	d0,a1
	move.l	(a1),8(a0)

	move.l	$456,a1

	move.l	(a1)+,12(a0)		* VBL1
	move.l	(a1)+,16(a0)		*    2
	move.l	(a1)+,20(a0)		*    3
	move.l	(a1)+,24(a0)		*    4
	move.l	(a1)+,28(a0)		*    5
	move.l	(a1)+,32(a0)		*    6
	move.l	(a1)+,36(a0)		*    7

	lea.l	vdocook(pc),a1
	move.l	(a1),d0
	cmp.l	#$30000,d0
	bne	next1

	move.l	a0,-(sp)
	move.w	#-1,-(sp)		* vsetmode -1
	move.w	#$58,-(sp)
	trap	#14
	add.l	#4,sp
	move.l	(sp)+,a0

	move.l	d0,40(a0)

next1	move.l	a0,-(sp)		* logbase
	move.w	#3,-(sp)
	trap	#14
	add.l	#2,sp
	move.l	(sp)+,a0

	move.l	d0,44(a0)

	move.l	a0,-(sp)
	move.w	#2,-(sp)		* physbase
	trap	#14
	add.l	#2,sp
	move.l	(sp)+,a0

	move.l	d0,48(a0)

*	move.l	#0,-(sp)
*	move.w	#$20,-(sp)
*	trap	#1
*	add.l	#6,sp

	move.w	($44c),54(a0)		* (SHIFTMD)+2

	move.l	a0,-(sp)

****
* get MiNT cookie (not part of the start up... but hey!) :-)
	move.l    $5a0,d0
	tst.l     d0
	beq.s     .nomintcook       No cookie jar = plain ST.
	move.l    d0,a0
	move.l    #'MiNT',d0

.nextmintcook
	tst       (a0)
	beq.s     .nomintcook       No _VDO cookie = plain ST.
	move.l    (a0)+,d1
	cmp.l     d0,d1
	beq.s     .fndmintcook
	addq.l    #4,a0
	bra.s     .nextmintcook

.fndmintcook
	lea       mintcook(pc),a6
	move.l    (a0),d0
	move.l    d0,(a6)
.nomintcook

	move.l	(sp)+,a0

	clr.l	d0
	move.l	a0,-(sp)
	move.w	#4,-(sp)
	trap	#14
	add.l	#2,sp
	move.l	(sp)+,a0

	move.l	d0,60(a0)		* GETREZ

	move.l	($ff8260),64(a0)	* ST SHIFT

	lea	vdocook(pc),a1
	move.l	(a1),d0
	cmp.l	#$30000,d0
	bne	next2

	move.l	($ff8266),68(a0)	* Falcon SPSHIFT

* store colours
next2

	move.l	($ff8260),72(a0)

	lea.l	int_in(pc),a1
	move.w	#0,(a1)		* handle
	move.w	#4,2(a1)	* sort=workxywh
*	aes	104		* wind_get
	lea.l	int_out(pc),a1
*	move.l	(sp)+,a0
*	move.w	2(a1),82(a0)	* (xout)+2
*	move.w	4(a1),86(a0)	* (yout)+2
*	move.w	6(a1),90(a0)	* (wout)+2
*	move.w	8(a1),94(a0)	* (hout)+2

* Copy few exception vectors, STOS overwrites some of them.

	move.l	#$8,a2
	move.l	#100,d1
	move.l	a0,a3
	add.l	d1,a3

bit	move.l	(a2)+,a1
	move.l	a1,(a3)+
	cmp	#$28,a2
	bne	bit

	move.l	$400,(a3)+	* etv_timer
	move.l	$404,(a3)+	* etv_critic
	move.l	$40C,(a3)+	* etv_term



	movem.l	(sp)+,a0-a6/d0-d6	* restore registers

*	pea	gemosalert1(pc)
*	move.w	#$13C,-(sp)
*	trap	#1
*	addq.l	#6,sp

	rts

mystack		ds.l	1
freemem2	ds.l	1
vdocook		ds.l	1
gembuffer	ds.l	1000
gemmaosver	dc.b	"1.72",0
gemmaosby	dc.b	"Paul Jones and Anthony Jacques 1997",13,10,"(paulat.jones@zetnet.co.uk), (jacquesa@zetnet.co.uk)",0
gemosalert1	dc.b	"[1][ Set bits ][ OK ]",0
gemosalert2	dc.b	"[1][ Screen ][ OK ]",0
baspage		ds.l	1
colstore	ds.w	256
current_handle	ds.w	1
mintcook	ds.l	1

contrl		ds.w	1
contrl1		ds.w	1
contrl2		ds.w	1
contrl3		ds.w	1
contrl4		ds.w	1
contrl5		ds.w	1
contrl6		ds.w	1
contrl7		ds.w	1
contrl8		ds.w	1
contrl9		ds.w	1
contrl10	ds.w	1
contrl11	ds.w	1

intin		ds.w	128
intout		ds.w	128
ptsin		ds.w	128
ptsout		ds.w	128

global2		ds.w	14

vdi_params	dc.l	contrl,intin,ptsin,intout,ptsout

gem_ctrl_list
	dc.b	0,1,0	10	appl_init
	dc.b	2,1,1	11	appl_read
	dc.b	2,1,1	12	appl_write
	dc.b	0,1,1	13	appl_find
	dc.b	2,1,1	14	appl_tplay
	dc.b	1,1,1	15	appl_record
	dc.b	0,0,0	16*
	dc.b	0,0,0	17*
	dc.b	1,3,1	18	appl_search (4.0)
	dc.b	0,1,0	19	appl_exit
	dc.b	0,1,0	20	evnt_keybd
	dc.b	3,5,0	21	evnt_button
	dc.b	5,5,0	22	evnt_mouse
	dc.b	0,1,1	23	evnt_mesag
	dc.b	2,1,0	24	evnt_timer
	dc.b	16,7,1	25	evnt_multi
	dc.b	2,1,0	26	evnt_dclick
	dc.b	0,0,0	27*
	dc.b	0,0,0	28*
	dc.b	0,0,0	29*
	dc.b	1,1,1	30	menu_bar
	dc.b	2,1,1	31	menu_icheck
	dc.b	2,1,1	32	menu_ienable
	dc.b	2,1,1	33	menu_tnormal
	dc.b	1,1,2	34	menu_text
	dc.b	1,1,1	35	menu_register
	dc.b	2,1,2	36	menu_popup (3.3)
	dc.b	2,1,2	37	menu_attach (3.3)
	dc.b	3,1,1	38	menu_istart (3.3)
	dc.b	1,1,1	39	menu_settings (3.3)
	dc.b	2,1,1	40	objc_add
	dc.b	1,1,1	41	objc_delete
	dc.b	6,1,1	42	objc_draw
	dc.b	4,1,1	43	objc_find
	dc.b	1,3,1	44	objc_offset
	dc.b	2,1,1	45	objc_order
	dc.b	4,2,1	46	objc_edit
	dc.b	8,1,1	47	objc_change
	dc.b	4,3,0	48	objc_sysvar
	dc.b	0,0,0	49*
	dc.b	1,1,1	50	form_do
	dc.b	9,1,0	51	form_dial
	dc.b	1,1,1	52	form_alert
	dc.b	1,1,0	53	form_error
	dc.b	0,5,1	54	form_center
	dc.b	3,3,1	55	form_keybd
	dc.b	2,2,1	56	form_button
	dc.b	0,0,0	57*
	dc.b	0,0,0	58*
	dc.b	0,0,0	59*
	dc.b	0,0,0	60*
	dc.b	0,0,0	61*
	dc.b	0,0,0	62*
	dc.b	0,0,0	63*
	dc.b	0,0,0	64*
	dc.b	0,0,0	65*
	dc.b	0,0,0	66*
	dc.b	0,0,0	67*
	dc.b	0,0,0	68*
	dc.b	0,0,0	69*
	dc.b	4,3,0	70	graf_rubberbox
	dc.b	8,3,0	71	graf_dragbox
	dc.b	6,1,0	72	graf_movebox
	dc.b	8,1,0	73	graf_growbox
	dc.b	8,1,0	74	graf_shrinkbox
	dc.b	4,1,1	75	graf_watchbox
	dc.b	3,1,1	76	graf_slidebox
	dc.b	0,5,0	77	graf_handle
	dc.b	1,1,1	78	graf_mouse
	dc.b	0,5,0	79	graf_mkstate
	dc.b	0,1,1	80	scrp_read
	dc.b	0,1,1	81	scrp_write
	dc.b	0,0,0	82*
	dc.b	0,0,0	83*
	dc.b	0,0,0	84*
	dc.b	0,0,0	85*
	dc.b	0,0,0	86*
	dc.b	0,0,0	87*
	dc.b	0,0,0	88*
	dc.b	0,0,0	89*
	dc.b	0,2,2	90	fsel_input
	dc.b	0,2,3	91	fsel_exinput
	dc.b	0,0,0	92*
	dc.b	0,0,0	93*
	dc.b	0,0,0	94*
	dc.b	0,0,0	95*
	dc.b	0,0,0	96*
	dc.b	0,0,0	97*
	dc.b	0,0,0	98*
	dc.b	0,0,0	99*
	dc.b	5,1,0	100	wind_create
	dc.b	5,1,0	101	wind_open
	dc.b	1,1,0	102	wind_close
	dc.b	1,1,0	103	wind_delete
	dc.b	2,5,0	104	wind_get
	dc.b	6,1,0	105	wind_set
	dc.b	2,1,0	106	wind_find
	dc.b	1,1,0	107	wind_update
	dc.b	6,5,0	108	wind_calc
	dc.b	0,0,0	109	wind_new
	dc.b	0,1,1	110	rsrc_load
	dc.b	0,1,0	111	rsrc_free
	dc.b	2,1,0	112 ** Control(4)=1 ** rsrc_gaddr
	dc.b	2,1,1	113	rsrc_saddr
	dc.b	1,1,1	114	rsrc_obfix
	dc.b	0,0,0	115	rsrc_rcfix (4.0)
	dc.b	0,0,0	116*
	dc.b	0,0,0	117*
	dc.b	0,0,0	118*
	dc.b	0,0,0	119*
	dc.b	0,1,2	120	shel_read
	dc.b	3,1,2	121	shel_write
	dc.b	1,1,1	122	shel_get
	dc.b	1,1,1	123	shel_put
	dc.b	0,1,1	124	shel_find
	dc.b	0,1,3	125	shel_envrn
	dc.b	0,0,0	126*
	dc.b	0,0,0	127*
	dc.b	0,0,0	128*
	dc.b	0,0,0	129*
	dc.b	1,5,0	130*	appl_getinfo (4.0)



THEEND
	END