;*****************************************************************************;
;   bss module bss source file    Copyright 1986 Tom Bajoras
;   module bss contains only variable declarations
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 SECTION _MERGED,bss

;**********************************************************
;   Every variable label must be declared global    *
;**********************************************************

  XDEF x1
  XDEF x2
  XDEF x3
  XDEF x4
  XDEF x5
  XDEF y1
  XDEF y2
  XDEF wkspace
  XDEF wksname
  XDEF edspace
  XDEF wkbank
  XDEF wkbname
  XDEF wwkbank
  XDEF wwkbname
  XDEF midich
  XDEF midichs
  XDEF qustat
  XDEF muteflag
  XDEF cursory
  XDEF filebuf
  XDEF diskbuf
  XDEF indbuf1
  XDEF indbuf2
  XDEF namebuf
  XDEF synbuf
  XDEF catbuf
  XDEF fileflg
  XDEF fillock
  XDEF indflg
  XDEF filenam
  XDEF nbanks
  XDEF bankflg
  XDEF banknam
  XDEF bslotnm
  XDEF bnamflg
  XDEF nfiles
  XDEF nfillok
  XDEF nfilind
  XDEF lowascii
  XDEF ofstaddr
  XDEF fontaddr
  XDEF formleng
  XDEF formhigh
  XDEF vdiaddr
  XDEF colorsav
  XDEF bwflag
  XDEF scrarray
  XDEF colarray
  XDEF menuaddr
  XDEF lastmenu
  XDEF lastbank
  XDEF midiaddr
  XDEF kbaddr
  XDEF revtabl
  XDEF startrez
  XDEF startpal
  XDEF startimg
  XDEF monws
  XDEF monedit
  XDEF invtext
  XDEF forceinv
  XDEF ghostch
  XDEF noblank
  XDEF mousvec
  XDEF vblsave
  XDEF prtargs
  XDEF toneflag
  XDEF testones
  XDEF tonestat
  XDEF allowlc
  XDEF allowms
  XDEF edmenflg
  XDEF thruflag
  XDEF txatten
  XDEF currdrv

;**********************************************************
;   end of global statements         *
;**********************************************************

;  argument passing area
;   x1-x5 for input arguments, y1-y2 for output arguments
x1   ds.l   1
x2   ds.l   1
x3   ds.l   1
x4   ds.l   1
x5   ds.l   1
y1   ds.l   1
y2   ds.l   1

;  workspace and its name
wkspace  ds.l   40
wksname  ds.b   10

;  editspace (shares workspace name)
edspace  ds.b   160

;  workbank and 1 name for each slot
wkbank   ds.b   5120
wkbname  ds.b   320

;  alias workbank and alias workbank names
wwkbank  ds.b   5120
wwkbname ds.b   320

;  info for synth communications
midich   ds.b   1    ; midi channel for all synth communicating
midichs  ds.b   18   ; midi channels for quick-send function
qustat   ds.b   18   ; yes/no flags for quick-send function
muteflag ds.b   1    ; each bit = 1 for op on, = 0 for op off

;  current line for screen i/o
cursory  ds.b   1

;  buffers
filebuf  ds.w   2048 ; buffer for disk file i/o and listfil
diskbuf  ds.b   8192 ; buffer for disk i/o (8K for initdsc)
indbuf1  ds.b   128  ; buffer for disk index i/o
indbuf2  ds.b   128
namebuf  ds.b   10   ; buffer for screen i/o
synbuf   ds.b   4108 ; buffer for synth i/o (slightly oversized)
catbuf   ds.b   2375 ; buffer for catalog output page

;  area for startup screen file (must be contiguous)
startrez ds.w   1     ; resolution
startpal ds.w   16   ; color palette
startimg ds.b   10000    ; bit map will overwrite info tables
         ; but that's ok (saves 22000 bytes)
;  info tables
fileflg  ds.b   1032 ; file existence flags
fillock  ds.b   1032 ; file lock flags
indflg   ds.b   1032 ; file indexed flags
filenam  ds.b   10752   ; file names (only 10320 bytes used)
nbanks   ds.b   1    ; # of banks on disk
bankflg  ds.b   18   ; bank existence flags
bslotnm  ds.b   6144 ; names of all bank slots (only 5760 used)
banknam  ds.b   512  ; names of banks (only 180 bytes used)
bnamflg  ds.b   18   ; bank named flags
nfiles   ds.w   1    ; # of files on disk
nfillok  ds.w   1    ; # of locked files on disk
nfilind  ds.w   1    ; # of indexed files on disk
revtabl  ds.b   1536 ; revision table (only 1032 bytes used)

;  area used by A-line routines
lowascii ds.w   1    ; lowest ascii code in selected font
ofstaddr ds.l   1    ; address of character offset table
fontaddr ds.l   1    ; address of selected font
formleng ds.w   1    ; # of bytes per line in font
formhigh ds.w   1    ; number of scan lines in font
vdiaddr  ds.l   1    ; address of vdi argument passing area

;  screen attributes save area
colorsav ds.w   16   ; save colors
bwflag   ds.w   1    ; =1 for color, =2 for b/w

;  screen character and color image arrays
scrarray ds.b   2000
colarray ds.b   2000

;  array of menu addresses
menuaddr ds.l   8   ; pointers to menu1,menu2,etc.

;  array of most recently selected menu items
lastmenu ds.b   8
;  most  recently selected bank
lastbank ds.b   1

;  pointer to midi and kb input records
midiaddr ds.l   1
kbaddr   ds.l   1

;   edit- and ws- monitoring flags
;   monedit = 0,1,2 with/without/only f-pars
;   monws = 0,1 on/off
monedit  ds.b   1
monws    ds.b   1

invtext  ds.b   1    ; invert color 2 flag (0=no, 1=yes)
forceinv ds.b   1    ; invert all colors flag (0=no, 1=yes)
ghostch  ds.b   1    ; =1 character won't show up in hardtext
noblank  ds.b   1    ; =1 supress blank5 in outpar routines
mousvec  ds.l   1    ; pointer to mouse handler
vblsave  ds.l   1    ; address of vbl handler replaced by prt_off
prtargs  ds.w   15   ; argument-passing area for hardcopy
testones ds.b   16   ; array of test tones for sendtone
tonestat ds.b   16   ; =0 note muted, =1 note not muted
toneflag ds.b   1    ; =0 note on / =1 note off, for sendtone
allowlc  ds.b   1    ; =0 getkey converts lower case to upper
allowms  ds.b   1    ; =0 getkey ignores mouse buttons
edmenflg ds.b   1    ; =0 edmenu2 puts up menu p.1, else p.2
thruflag ds.b   1    ; =0 midi thru off, =1 midi thru on
txatten  ds.b   1    ; = 1-7 attenuation for TX bulk function
currdrv  ds.w   1    ; = 0/1, drive # for data disk i/o
