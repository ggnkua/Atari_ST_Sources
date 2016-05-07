;*****************************************************************************;
;    data module (part 1)    Copyright 1986 Tom Bajoras
;    this module contains only data declarations for
;    constants starting with letters A-L
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 SECTION _MERGED,data

;***************************************************
;   Every data label must be declared global    *
;***************************************************

  XDEF ascif1
  XDEF ascif9
  XDEF ascif10
  XDEF ascibs
  XDEF ascicr
  XDEF ascidel
  XDEF ascilef
  XDEF ascirit
  XDEF asciup
  XDEF ascidwn
  XDEF ascisp
  XDEF asciy
  XDEF ascin
  XDEF ascih
  XDEF ascii
  XDEF ascil
  XDEF asciper
  XDEF asci9
  XDEF asci0
  XDEF ascia
  XDEF ascib
  XDEF ascic
  XDEF asciline
  XDEF ascibsl
  XDEF asciast
  XDEF ascihelp
  XDEF ascihome
  XDEF asciesc
  XDEF asciundo
  XDEF asciins
  XDEF ascitab
  XDEF ascidash
  XDEF ascilpr
  XDEF ascirpr
  XDEF asciplus
  XDEF ascis
  XDEF asciw
  XDEF asciless
  XDEF ascie
  XDEF ascimlef
  XDEF ascimrit
  XDEF asciu
  XDEF ascid
  XDEF ascip
  XDEF ascix
  XDEF asciz
  XDEF ascim
  XDEF ascir

  XDEF color1a
  XDEF color1b
  XDEF color2
  XDEF colorbw
  XDEF cbakgnd
  XDEF cecho
  XDEF cprompt
  XDEF ccurmen
  XDEF cmenu
  XDEF cmenkey
  XDEF cmenhed
  XDEF cmessge
  XDEF coutlne
  XDEF cstart
  XDEF catfmt
  XDEF catmess
  XDEF catmesl
  XDEF lprime
  XDEF initname
  XDEF and1name
  XDEF and2name
  XDEF initsnd
  XDEF bankkey
  XDEF bankkeyn
  XDEF indmess
  XDEF indmesl
  XDEF bnkmess
  XDEF bnkmesl
  XDEF dxosid
  XDEF dxmess1
  XDEF dxmess2
  XDEF dxmess3
  XDEF infomess
  XDEF infomesl
  XDEF editmess
  XDEF editmesl
  XDEF cursinfo
  XDEF cursinf2
  XDEF dummycol
  XDEF avname
  XDEF glname
  XDEF distname
  XDEF dxsetup
  XDEF dxsetl
  XDEF dxunset
  XDEF dxunl
  XDEF disttabl

;***************************************************
;   end of global statements        *
;***************************************************

;  ascii table used by getkey (ascii extensions)
;  order of table doesn't matter, except ascif1 must be first.
ascif1   dc.b $10,$3B      ; column 1 is byte returned by getkey
ascif2   dc.b $11,$3C      ; column 2 is byte returned by rawcin
ascif3   dc.b $12,$3D
ascif4   dc.b $13,$3E
ascif5   dc.b $14,$3F
ascif6   dc.b $15,$40
ascif7   dc.b $16,$41
ascif8   dc.b $17,$42
ascif9   dc.b $18,$43
ascif10  dc.b $19,$44
ascihelp dc.b $8A,$62
asciundo dc.b $8B,$61
asciins  dc.b $8C,$52
asciup   dc.b $8D,$48
ascihome dc.b $8E,$47
ascilef  dc.b $8F,$4B
ascidwn  dc.b $90,$50
ascirit  dc.b $91,$4D
ascimlef dc.b $92,$74
ascimrit dc.b $93,$75
 dc.b  0,0    ; indicates end of ascii table

;  standard ascii's
asciesc  dc.b $1B
ascibs   dc.b $08
ascitab  dc.b $09
ascicr   dc.b $0D
ascidel  dc.b $7F
ascisp   dc.b $20
asciw    dc.b $57
ascie    dc.b $45
asciy    dc.b $59
ascii    dc.b $49
ascia    dc.b $41
ascis    dc.b $53
ascih    dc.b $48
ascil    dc.b $4C
ascic    dc.b $43
ascib    dc.b $42
ascin    dc.b $4E
ascidash dc.b $2D
asciplus dc.b $2B
ascilpr  dc.b $28
ascirpr  dc.b $29
asciast  dc.b $2A
asciper  dc.b $2E
asciless dc.b $3C
asciline dc.b $5F
ascibsl  dc.b $5C
asci9    dc.b $39
asci0    dc.b $30
asciu    dc.b $55
ascid    dc.b $44
ascip    dc.b $50
ascix    dc.b $58
asciz    dc.b $5A
ascim    dc.b $4D
ascir    dc.b $52

;  color palettes
colorbw   dc.w    $000,$777,$777,$777,$777,$777,$777,$777
    dc.w    $777,$777,$777,$777,$777,$777,$777,$777
color1a   dc.w    $000,$777,$700,$070,0,0,0,0,0,0,0,0,0,0,0,0
color1b   dc.w    $000,$777,$706,$070,0,0,0,0,0,0,0,0,0,0,0,0
color2    dc.w    $013,$505,$700,$775,0,0,0,0,0,0,0,0,0,0,0,0  ; 2
    dc.w    $000,$077,$700,$077,0,0,0,0,0,0,0,0,0,0,0,0  ; 3
    dc.w    $555,$400,$300,$000,0,0,0,0,0,0,0,0,0,0,0,0  ; 4
    dc.w    $531,$770,$000,$200,0,0,0,0,0,0,0,0,0,0,0,0  ; 5
    dc.w    $300,$660,$731,$444,0,0,0,0,0,0,0,0,0,0,0,0  ; 6
    dc.w    $222,$777,$642,$770,0,0,0,0,0,0,0,0,0,0,0,0  ; 7
    dc.w    $020,$070,$777,$642,0,0,0,0,0,0,0,0,0,0,0,0  ; 8
    dc.w    $202,$660,$707,$555,0,0,0,0,0,0,0,0,0,0,0,0  ; 9
    dc.w    $000,$077,$700,$606,0,0,0,0,0,0,0,0,0,0,0,0  ;10
    dc.w    $004,$777,$077,$703,0,0,0,0,0,0,0,0,0,0,0,0  ;11unused
    dc.w    $002,$777,$600,$070,0,0,0,0,0,0,0,0,0,0,0,0  ;12
    dc.w    $222,$076,$600,$777,0,0,0,0,0,0,0,0,0,0,0,0  ;13
    dc.w    $000,$770,$077,$707,0,0,0,0,0,0,0,0,0,0,0,0  ;14
;  inverted b/w color palette for hardcopying
dummycol  dc.w   $777,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

;  names for color registers
cbakgnd  dc.b    0    ; background screen color
cecho    dc.b    3    ; color for echoing user input
cprompt  dc.b    2    ; color for any prompt
ccurmen  dc.b    3    ; color for most recently selected menu item
cmenu    dc.b    1    ; color for other menu items
cmenkey  dc.b    3    ; color for menu keys
cmenhed  dc.b    3    ; color for menu heading
cmessge  dc.b    1    ; color for all other text
coutlne  dc.b    3    ; color for dividing lines
cstart   dc.b    2    ; color for text on startup screen

;  initsound*
initsnd  dc.b    99,99,99,99,99,99,99,0,0,0,0,0,0,0,0,0,99,0,1,0,7
   dc.b    99,99,99,99,99,99,99,0,0,0,0,0,0,0,0,0,99,0,1,0,7
   dc.b    99,99,99,99,99,99,99,0,0,0,0,0,0,0,0,0,99,0,1,0,7
   dc.b    99,99,99,99,99,99,99,0,0,0,0,0,0,0,0,0,99,0,1,0,7
   dc.b    99,99,99,99,99,99,99,0,0,0,0,0,0,0,0,0,99,0,1,0,7
   dc.b    99,99,99,99,99,99,99,0,0,0,0,0,0,0,0,0,99,0,1,0,7
   dc.b    99,99,99,99,50,50,50,50,31,0,1,35,0,0,0,0,0,0
   dc.b    24,0,2,0,1,0,0,0,0,0,0,0,0,0,0,0

;  # columns in catalog output
catfmt   dc.b    3

;  catmess(0) is word after "cannot" or before "aborted" for catalog menu
;  other catmess strings are headings for catalog output pages
catmess   dc.b   "Catalog  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;0
    dc.b   "Catalog all files: xxxxxxxxxxxxxxxxxxxx"   ;1
    dc.b   "Catalog locked files: xxxxxxxxxxxxxxxxx"   ;2
    dc.b   "Catalog unlocked files: xxxxxxxxxxxxxxx"   ;3
    dc.b   "Catalog indexed files:  xxxxxxxxxxxxxxx"   ;4
    dc.b   "Catalog unindexed files:  xxxxxxxxxxxxx"   ;5
    dc.b   "Catalog files, prefix =  xxxxxxxxxxxxxx"   ;6
    dc.b   "Catalog files, suffix =  xxxxxxxxxxxxxx"   ;7
    dc.b   "Catalog one file: xxxxxxxxxxxxxxxxxxxxx"   ;8
    dc.b   "Catalog files, infix = xxxxxxxxxxxxxxxx"   ;9
    dc.b   "Catalog files, revision(s) = xxxxxxxxxx"   ;10

catmesl  dc.b    7,18,21,23,22,24,23,23,17,22,28

;  largest prime # less than maxfile used by hashfil routine
;  note: lprime MUST be < maxfile
lprime    dc.w    1031

;  names for init ws, init wb, android sounds
initname  dc.b   "----------"
and1name  dc.b   "Android-1 "
and2name  dc.b   "Android-2 "

;  bank keys -- same as on the DX7
bankkey   dc.b   "1234567890ABCDEFGHIJKLMNOPQRSTUV"
;  bank keys -- numerical
bankkeyn  dc.b   "( 1) ( 2) ( 3) ( 4) ( 5) ( 6) ( 7) ( 8) "
    dc.b   "( 9) (10) (11) (12) (13) (14) (15) (16) "
    dc.b   "(17) (18) (19) (20) (21) (22) (23) (24) "
    dc.b   "(25) (26) (27) (28) (29) (30) (31) (32) "

;  text for index pages
indmess   dc.b   "CREATE INDEX FOR  xxxxxxxxxxxxxxxxxxxxx "   ;0
    dc.b   "EDIT INDEX FOR  xxxxxxxxxxxxxxxxxxxxxxx "   ;1
    dc.b   "Menu:  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;2 unused
    dc.b   "[Help] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx "    ;3
    dc.b   " -- hardcopy screen  xxxxxxxxxxxxxxxxxx "   ;4
    dc.b   "arrows, [Tab], [cr] xxxxxxxxxxxxxxxxxxx "   ;5
    dc.b   " -- move cursor  xxxxxxxxxxxxxxxxxxxxxx "   ;6
    dc.b   "[bs] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;7
    dc.b   " -- delete character, leave space xxxxx "   ;8
    dc.b   "[Clr/Home] xxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;9
    dc.b   " -- erase entire index  xxxxxxxxxxxxxxx "   ;10
    dc.b   "[Undo] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;11
    dc.b   " -- start over xxxxxxxxxxxxxxxxxxxxxxxx "   ;12
    dc.b   "[Esc] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;13
    dc.b   " -- finish  xxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;14
    dc.b   "Enter text using printable keys.  xxxxx "   ;15
    dc.b   "Disk i/o error! xxxxxxxxxxxxxxxxxxxxxxx "   ;16
    dc.b   "Any key to return to index menu. xxxxxx "   ;17
    dc.b   "[Delete] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;18
    dc.b   " -- delete character, close space xxxxx "   ;19
    dc.b   "[Insert] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;20
    dc.b   " -- insert character xxxxxxxxxxxxxxxxxx "   ;21

;   number of characters in each indmess string
indmesl  dc.b    16,14,5,6,19,19,15,4,33,10
   dc.b    22,6,14,5,10,32,15,32,8,33
   dc.b    8,20

;  text for bank pages
bnkmess   dc.b   "Bank  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  "   ;0
    dc.b   "Any key to return to bank menu xxxxxxx  "   ;1
    dc.b   "Execute Workbank xxxxxxxxxxxxxxxxxxxxx  "   ;2
    dc.b   "1-9,0,A-V to send a WB slot to synth x  "   ;3
    dc.b   "[cr] to return to bank menu xxxxxxxxxx  "   ;4
    dc.b   "Any other key to return to bank menu xx "   ;5
    dc.b   "Bank Names xxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;6
    dc.b   "(no name) xxxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;7
    dc.b   "[sp] or synth 'yes' to step forward xxx "   ;8
    dc.b   "[bs] or synth 'no' to step backward xxx "   ;9
    dc.b   "Execute with function parameters xxxxxx "   ;10
    dc.b   "Execute without function parameters xxx "   ;11
    dc.b   "Execute only function parameters xxxxxx "   ;12
    dc.b   "Type [Esc] to change this. xxxxxxxxxxxx "   ;13
    dc.b   "Menu: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;14
    dc.b   "Mix Workbank and a Bank xxxxxxxxxxxxxxx "   ;15
    dc.b   "Workbank xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;16
    dc.b   "1-9,0,A-V to select workbank slot xxxxx "   ;17
    dc.b   "[cr] to return to edit bank menu xxxxxx "   ;18
    dc.b   "1-9,0,A-V to select bank slot xxxxxxxxx "   ;19
    dc.b   "[cr] to de-select workbank slot xxxxxxx "   ;20
    dc.b   "right arrow: copy WB slot to bank slot  "   ;21
    dc.b   "left arrow: copy bank slot to WB slot xx"   ;22
    dc.b   "up or down arrow: swap WB/bank slots xxx"   ;23
    dc.b   "Disk i/o error! xxxxxxxxxxxxxxxxxxxxxxxx"   ;24
    dc.b   "Any key to return to edit bank menu xxxx"   ;25
    dc.b   "[Esc] to abort xxxxxxxxxxxxxxxxxxxxxxxxx"   ;26

;   # of characters in each bnkmess string
bnkmesl  dc.b     4,30,16,36,27,36,10,9,35,35
   dc.b    32,35,32,26,5,23,8,33,32,29
   dc.b    31,38,37,36,15,35,14

  EVEN

;   string written to disk to identify it as a valid data disk
dxosid    dc.b   "DXOS"
;   pseudo-file directory for data disk  --  use Pascal form
dxmess1   dc.b   8,'DX-Andrd'
dxmess2   dc.b   4,'data'
dxmess3   dc.b   4,'disk'
;  text used for "info bars"
infomess  dc.b   "Workspace Name: xxxxxxxxx"   ;0
    dc.b   "Workspace monitoring xxxx"   ;1
    dc.b   "on. xxxxxxxxxxxxxxxxxxxxx"   ;2
    dc.b   "off. xxxxxxxxxxxxxxxxxxxx"   ;3
    dc.b   "Files Used: xxxxxxxxxxxxx"   ;4
    dc.b   "Files Unused: xxxxxxxxxxx"   ;5
    dc.b   "Files Locked: xxxxxxxxxxx"   ;6
    dc.b   "Files Unlocked: xxxxxxxxx"   ;7
    dc.b   "Edit monitoring xxxxxxxxx"   ;8
    dc.b   "with f-pars.   xxxxxxxxxx"   ;9
    dc.b   "without f-pars. xxxxxxxxx"   ;10
    dc.b   "only f-pars.   xxxxxxxxxx"   ;11
    dc.b   "Current Midi Ch: xxxxxxxx"   ;12
    dc.b   "Files Indexed: xxxxxxxxxx"   ;13
    dc.b   "Files Unindexed: xxxxxxxx"   ;14
    dc.b   "MIDI Thru: xxxxxxxxxxxxxx"   ;15
infomesl dc.b    15,20,4,4,11,13,13,15,15,15
   dc.b    15,15,16,14,16,10


; text used for editors
editmess  dc.b   "Numerical edit / screen 1: xxxxxxxxxxxxx"   ; 0
    dc.b   "(edited version) xxxxxxxxxxxxxxxxxxxxxxx"   ; 1
    dc.b   "Menu: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 2
    dc.b   "arrows xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 3
    dc.b   "move cursor xxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 4
    dc.b   "[+][-] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 5
    dc.b   "step data entry xxxxxxxxxxxxxxxxxxxxxxxx"   ; 6
    dc.b   "u-n-d xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 7
    dc.b   "undo all editing xxxxxxxxxxxxxxxxxxxxxxx"   ; 8
    dc.b   "[s] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 9
    dc.b   "go to screen 2 xxxxxxxxxxxxxxxxxxxxxxxxx"   ;10
    dc.b   "[w] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;11
    dc.b   "arrows, mouse xxxxxxxxxxxxxxxxxxxxxxxxxx"   ;12
    dc.b   "[Help] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;13
    dc.b   "hardcopy screen xxxxxxxxxxxxxxxxxxxxxxxx"   ;14
    dc.b   "[0]-[9] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;15
    dc.b   "direct data entry xxxxxxxxxxxxxxxxxxxxxx"   ;16
    dc.b   "[cr] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;17
    dc.b   "go to edit menu xxxxxxxxxxxxxxxxxxxxxxxx"   ;18
    dc.b   "[del] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;19
    dc.b   "unedit parameter xxxxxxxxxxxxxxxxxxxxxxx"   ;20
    dc.b   "Algorithm: xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;21
    dc.b   "(original version) xxxxxxxxxxxxxxxxxxxxx"   ;22
    dc.b   "[e] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;23
    dc.b   "[-][+], mouse xxxxxxxxxxxxxxxxxxxxxxxxxx"   ;24
    dc.b   "original to synth xxxxxxxxxxxxxxxxxxxxxx"   ;25
    dc.b   "edited to synth xxxxxxxxxxxxxxxxxxxxxxxx"   ;26
    dc.b   "unedit this screenxxxxxxxxxxxxxxxxxxxxxx"   ;27
    dc.b   "Edit levels & vel sens for: xxxxxxxxxxxx"   ;28
    dc.b   "Numerical edit / screen 2: xxxxxxxxxxxxx"   ;29
    dc.b   "go to screen 1 xxxxxxxxxxxxxxxxxxxxxxxxx"   ;30
    dc.b   "operator xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;31
    dc.b   "levels xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;32
    dc.b   "vel sens xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;33
    dc.b   "EDITED xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;34
    dc.b   "ORIGINAL xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;35
    dc.b   "Edit keyboard scaling for: xxxxxxxxxxxxx"   ;36
    dc.b   "Edit operator EG for: xxxxxxxxxxxxxxxxxx"   ;37
    dc.b   "original / operator xxxxxxxxxxxxxxxxxxxx"   ;38
    dc.b   "BP=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;39
    dc.b   "LD=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;40
    dc.b   "RD=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;41
    dc.b   "LC=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;42
    dc.b   "RC=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;43
    dc.b   "[sp]xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;44
    dc.b   "next operator xxxxxxxxxxxxxxxxxxxxxxxxxx"   ;45
      ; the next message is part of copy-protection
    dc.b   "[t] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;46
    dc.b   "test tones on/offxxxxxxxxxxxxxxxxxxxxxxx"   ;47unused
    dc.b   "[Tab][bs] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;48
    dc.b   "tab up/down xxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;49
    dc.b   "display original xxxxxxxxxxxxxxxxxxxxxxx"   ;50
    dc.b   "display edited xxxxxxxxxxxxxxxxxxxxxxxxx"   ;51
    dc.b   "[p] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;52
    dc.b   "list other commands xxxxxxxxxxxxxxxxxxxx"   ;53
    dc.b   "[*] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;54
    dc.b   "mark column xxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;55
    dc.b   "[esc][c] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;56
    dc.b   "copy eg xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;57
    dc.b   "[x] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;58
    dc.b   "exchange eg's xxxxxxxxxxxxxxxxxxxxxxxxxx"   ;59
    dc.b   "[esc][a] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;60
    dc.b   "copy column xxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;61
    dc.b   "[z] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;62
    dc.b   "exchange columns xxxxxxxxxxxxxxxxxxxxxxx"   ;63
    dc.b   "[m] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;64
    dc.b   "mute/un-mute operator xxxxxxxxxxxxxxxxxx"   ;65

editmesl dc.b    26,16,5,6,11,6,15,5,16,3
   dc.b    14,3,13,6,15,7,17,4,15,5
   dc.b    16,10,18,3,13,17,15,18,27,26
   dc.b    14,8,6,8,6,8,26,21,19,3
   dc.b    3,3,3,3,4,13,3,17,9,11
   dc.b    16,14,3,19,3,11,8,7,3,13
   dc.b    8,11,3,16,3,21

;  data needed by numerical (parametric) editor
cursinfo:
 dc.b   6,5,105,12,5,84,18,5,63,24,5,42,30,5,21,36,5,0
 dc.b   6,6,106,12,6,85,18,6,64,24,6,43,30,6,22,36,6,1
 dc.b   6,7,107,12,7,86,18,7,65,24,7,44,30,7,23,36,7,2
 dc.b   6,8,108,12,8,87,18,8,66,24,8,45,30,8,24,36,8,3
 dc.b   6,9,109,12,9,88,18,9,67,24,9,46,30,9,25,36,9,4
 dc.b   6,10,110,12,10,89,18,10,68,24,10,47,30,10,26,36,10,5
 dc.b   6,11,111,12,11,90,18,11,69,24,11,48,30,11,27,36,11,6
 dc.b   6,12,112,12,12,91,18,12,70,24,12,49,30,12,28,36,12,7
 dc.b   6,13,118,12,13,97,18,13,76,24,13,55,30,13,34,36,13,13
 dc.b   6,14,123,12,14,102,18,14,81,24,14,60,30,14,39,36,14,18
 dc.b   6,15,124,12,15,103,18,15,82,24,15,61,30,15,40,36,15,19
 dc.b   6,16,125,12,16,104,18,16,83,24,16,62,30,16,41,36,16,20
 dc.b   6,17,122,12,17,101,18,17,80,24,17,59,30,17,38,36,17,17
 dc.b   6,18,121,12,18,100,18,18,79,24,18,58,30,18,37,36,18,16
 dc.b   6,19,120,12,19,99,18,19,78,24,19,57,30,19,36,36,19,15
 dc.b   6,20,119,12,20,98,18,20,77,24,20,56,30,20,35,36,20,14
 dc.b   6,21,113,12,21,92,18,21,71,24,21,50,30,21,29,36,21,8
 dc.b   6,22,116,12,22,95,18,22,74,24,22,53,30,22,32,36,22,11
 dc.b   6,23,114,12,23,93,18,23,72,24,23,51,30,23,30,36,23,9
 dc.b   6,24,117,12,24,96,18,24,75,24,24,54,30,24,33,36,24,12
 dc.b   6,25,115,12,25,94,18,25,73,24,25,52,30,25,31,36,25,10

cursinf2:
 dc.b    9,5,126,17,5,127,25,5,128,33,5,129
 dc.b    9,6,130,17,6,131,25,6,132,33,6,133
 dc.b    9,11,151,17,11,153,25,11,155,33,11,157
 dc.b    9,12,152,17,12,154,25,12,156,33,12,158
 dc.b    9,15,136,17,15,144,25,15,134,34,15,135
 dc.b    9,19,137,17,19,138,25,19,139,34,19,141
 dc.b    9,20,140,17,20,143,26,20,142,33,20,$FF
 dc.b    9,22,146,18,22,147,27,22,145,33,22,$FF
 dc.b    9,25,150,18,25,149,26,25,148,33,25,$FF

avname    dc.b  "Average **"
glname    dc.b  "Glide ****"
distname  dc.b  "Distort **"

;  code to set up dx7:
;      press function button
;      release function button
;      battery check (in case current f-par is midich)
;      midich
;      sys info unavail
;      yes (sys info avail)
;      midi transmit prompt
;      internal memory protection
;      no (int mem prot off)
;      internal (go to normal play mode)
dxsetup  dc.b   $F0,$43,$10,$08,$27,$01,$F7
   dc.b   $F0,$43,$10,$08,$27,$00,$F7
   dc.b   $F0,$43,$10,$08,13,$01,$F7
   dc.b   $F0,$43,$10,$08,$07,$01,$F7
   dc.b   $F0,$43,$10,$08,$07,$01,$F7
   dc.b   $B0,$60,$7F
   dc.b   $F0,$43,$10,$08,$07,$01,$F7
   dc.b   $F0,$43,$10,$08,$21,$01,$F7
   dc.b   $B0,$61,$7F
   dc.b   $F0,$43,$10,$08,$25,$01,$F7
dxsetl    dc.w   61        ; # bytes in dxsetup - 1
;  code to un-set up dx7:
;      press function button
;      release function button
;      battery check
;      internal (go to normal play mode)
dxunset  dc.b   $F0,$43,$10,$08,$27,$01,$F7
   dc.b   $F0,$43,$10,$08,$27,$00,$F7
   dc.b   $F0,$43,$10,$08,13,$01,$F7
   dc.b   $F0,$43,$10,$08,$25,$01,$F7
dxunl     dc.w   27        ; # bytes in dxunset - 1
;  distort flags (=1 means distort this parameter,=0 means don't)
disttabl dc.b   1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,0,1,0,1,0,1,1
   dc.b     1,1,1,1,1,1,0,0,0,0,0,0,1,1,0,1,0,1,0,1
   dc.b   1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,0,1,0,1,0,1,1
   dc.b     1,1,1,1,1,1,0,0,0,0,0,0,1,1,0,1,0,1,0,1
   dc.b   1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,0,1,0,1,0,1,1
   dc.b     1,1,1,1,1,1,0,0,0,0,0,0,1,1,0,1,0,1,0,1
   dc.b    0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1
   dc.b    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
