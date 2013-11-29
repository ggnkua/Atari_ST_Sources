;*****************************************************************************;
;   bss module bss source file    Copyright 1986 Tom Bajoras
;   module bss contains only variable declarations
;*****************************************************************************;

 .bss

;**********************************************************
;   Every variable label must be declared global		  *
;**********************************************************

 .global x1
 .global x2
 .global x3
 .global x4
 .global x5
 .global y1
 .global y2
 .global wkspace
 .global wksname
 .global edspace
 .global wkbank
 .global wkbname
 .global wwkbank
 .global wwkbname
 .global midich
 .global midichs
 .global qustat
 .global muteflag
 .global cursory
 .global filebuf
 .global diskbuf
 .global indbuf1
 .global indbuf2
 .global namebuf
 .global synbuf
 .global catbuf
 .global fileflg
 .global fillock
 .global indflg
 .global filenam
 .global nbanks
 .global bankflg
 .global banknam
 .global bslotnm
 .global bnamflg
 .global nfiles
 .global nfillok
 .global nfilind
 .global lowascii
 .global ofstaddr
 .global fontaddr
 .global formleng
 .global formhigh
 .global vdiaddr
 .global colorsav
 .global bwflag
 .global scrarray
 .global colarray
 .global menuaddr
 .global lastmenu
 .global lastbank
 .global midiaddr
 .global kbaddr
 .global revtabl
 .global startrez
 .global startpal
 .global startimg
 .global monws
 .global monedit
 .global invtext
 .global forceinv
 .global ghostch
 .global noblank
 .global mousvec
 .global vblsave
 .global prtargs
 .global toneflag
 .global testones
 .global tonestat
 .global allowlc
 .global allowms
 .global edmenflg
 .global thruflag
 .global txatten
 .global currdrv

;**********************************************************
;   end of global statements							  *
;**********************************************************

;  argument passing area
;   x1-x5 for input arguments, y1-y2 for output arguments
x1  	.space  	4
x2  	.space  	4
x3  	.space  	4
x4  	.space  	4
x5  	.space  	4
y1  	.space  	4
y2  	.space  	4

;  workspace and its name
wkspace 	.space  	160
wksname 	.space  	10

;  editspace (shares workspace name)
edspace 	.space  	160

;  workbank and 1 name for each slot
wkbank  	.space  	5120
wkbname 	.space  	320

;  alias workbank and alias workbank names
wwkbank 	.space  	5120
wwkbname	.space  	320

;  info for synth communications
midich  	.space  	1   	; midi channel for all synth communicating
midichs 	.space  	18  	; midi channels for quick-send function
qustat  	.space  	18  	; yes/no flags for quick-send function
muteflag	.space  	1   	; each bit = 1 for op on, = 0 for op off

;  current line for screen i/o
cursory 	.space  	1

;  buffers
filebuf 	.space  	4096	; buffer for disk file i/o and listfil
diskbuf 	.space  	8192	; buffer for disk i/o (8K for initdsc)
indbuf1 	.space  	128 	; buffer for disk index i/o
indbuf2 	.space  	128
namebuf 	.space  	10  	; buffer for screen i/o
synbuf  	.space  	4108	; buffer for synth i/o (slightly oversized)
catbuf  	.space  	2375	; buffer for catalog output page

;  area for startup screen file (must be contiguous)
startrez	.space  	2   		; resolution
startpal	.space  	32  		; color palette
startimg	.space  	10000   	; bit map will overwrite info tables
									; but that's ok (saves 22000 bytes)
;  info tables
fileflg 	.space  	1032	; file existence flags
fillock 	.space  	1032	; file lock flags
indflg  	.space  	1032	; file indexed flags
filenam 	.space  	10752   ; file names (only 10320 bytes used)
nbanks  	.space  	1   	; # of banks on disk
bankflg 	.space  	18  	; bank existence flags
bslotnm 	.space  	6144	; names of all bank slots (only 5760 used)
banknam 	.space  	512 	; names of banks (only 180 bytes used)
bnamflg 	.space  	18  	; bank named flags
nfiles  	.space  	2   	; # of files on disk
nfillok 	.space  	2   	; # of locked files on disk
nfilind 	.space  	2   	; # of indexed files on disk
revtabl 	.space  	1536	; revision table (only 1032 bytes used)

;  area used by A-line routines
lowascii	.space  	2   	; lowest ascii code in selected font
ofstaddr	.space  	4   	; address of character offset table
fontaddr	.space  	4   	; address of selected font
formleng	.space  	2   	; # of bytes per line in font
formhigh	.space  	2   	; number of scan lines in font
vdiaddr 	.space  	4   	; address of vdi argument passing area

;  screen attributes save area
colorsav	.space  	32  	; save colors
bwflag  	.space  	2   	; =1 for color, =2 for b/w

;  screen character and color image arrays
scrarray	.space  	2000
colarray	.space  	2000

;  array of menu addresses
menuaddr	.space  	32  	; pointers to menu1,menu2,etc.

;  array of most recently selected menu items
lastmenu	.space  	8
;  most  recently selected bank
lastbank	.space  	1

;  pointer to midi and kb input records
midiaddr	.space  	4
kbaddr  	.space  	4

;   edit- and ws- monitoring flags
;   monedit = 0,1,2 with/without/only f-pars
;   monws = 0,1 on/off
monedit 	.space  	1
monws   	.space  	1

invtext 	.space  	1   	; invert color 2 flag (0=no, 1=yes)
forceinv	.space  	1   	; invert all colors flag (0=no, 1=yes)
ghostch 	.space  	1   	; =1 character won't show up in hardtext
noblank 	.space  	1   	; =1 supress blank5 in outpar routines
mousvec 	.space  	 4  	 ; pointer to mouse handler
vblsave 	.space  	4   	; address of vbl handler replaced by prt_off
prtargs 	.space  	30  	; argument-passing area for hardcopy
toneflag	.space  	1   	; =0 note on / =1 note off, for sendtone
testones	.space  	16  	; array of test tones for sendtone
tonestat	.space  	16  	; =0 note muted, =1 note not muted
allowlc 	.space  	1   	; =0 getkey converts lower case to upper
allowms 	.space  	1   	; =0 getkey ignores mouse buttons
edmenflg	.space  	1   	; =0 edmenu2 puts up menu p.1, else p.2
thruflag	.space  	1   	; =0 midi thru off, =1 midi thru on
txatten 	.space  	1   	; = 1-7 attenuation for TX bulk function
currdrv 	.space  	2   	; = 0/1, drive # for data disk i/o
