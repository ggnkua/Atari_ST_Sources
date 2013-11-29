;*****************************************************************************;
;    data module (part 1)    Copyright 1986 Tom Bajoras
;    this module contains only data declarations for
;    constants starting with letters A-L
;*****************************************************************************;

 .data

;***************************************************
;   Every data label must be declared global	   *
;***************************************************

 .global ascif1
 .global ascif9
 .global ascif10
 .global ascibs
 .global ascicr
 .global ascidel
 .global ascilef
 .global ascirit
 .global asciup
 .global ascidwn
 .global ascisp
 .global asciy
 .global ascin
 .global ascih
 .global ascii
 .global ascil
 .global asciper
 .global asci9
 .global asci0
 .global ascia
 .global ascib
 .global ascic
 .global asciline
 .global ascibsl
 .global asciast
 .global ascihelp
 .global ascihome
 .global asciesc
 .global asciundo
 .global asciins
 .global ascitab
 .global ascidash
 .global ascilpr
 .global ascirpr
 .global asciplus
 .global ascis
 .global asciw
 .global asciless
 .global ascie
 .global ascimlef
 .global ascimrit
 .global asciu
 .global ascid
 .global ascip
 .global ascix
 .global asciz
 .global ascim
 .global ascir

 .global color1a
 .global color1b
 .global color2
 .global colorbw
 .global cbakgnd
 .global cecho
 .global cprompt
 .global ccurmen
 .global cmenu
 .global cmenkey
 .global cmenhed
 .global cmessge
 .global coutlne
 .global cstart
 .global catfmt
 .global catmess
 .global catmesl
 .global lprime
 .global initname
 .global and1name
 .global and2name
 .global initsnd
 .global bankkey
 .global bankkeyn
 .global indmess
 .global indmesl
 .global bnkmess
 .global bnkmesl
 .global dxosid
 .global dxmess1
 .global dxmess2
 .global dxmess3
 .global infomess
 .global infomesl
 .global editmess
 .global editmesl
 .global cursinfo
 .global cursinf2
 .global dummycol
 .global avname
 .global glname
 .global distname
 .global dxsetup
 .global dxsetl
 .global dxunset
 .global dxunl
 .global disttabl

;***************************************************
;   end of global statements					   *
;***************************************************

;  ascii table used by getkey (ascii extensions)
;  order of table doesn't matter, except ascif1 must be first.
ascif1  	.byte $10,$3B   			; column 1 is byte returned by getkey
ascif2  	.byte $11,$3C   			; column 2 is byte returned by rawcin
ascif3  	.byte $12,$3D
ascif4  	.byte $13,$3E
ascif5  	.byte $14,$3F
ascif6  	.byte $15,$40
ascif7  	.byte $16,$41
ascif8  	.byte $17,$42
ascif9  	.byte $18,$43
ascif10 	.byte $19,$44
ascihelp	.byte $8A,$62
asciundo	.byte $8B,$61
asciins 	.byte $8C,$52
asciup  	.byte $8D,$48
ascihome	.byte $8E,$47
ascilef 	.byte $8F,$4B
ascidwn 	.byte $90,$50
ascirit 	.byte $91,$4D
ascimlef	.byte $92,$74
ascimrit	.byte $93,$75
			.byte  0,0  		; indicates end of ascii table

;  standard ascii's
asciesc 	.byte $1B
ascibs  	.byte $08
ascitab 	.byte $09
ascicr  	.byte $0D
ascidel 	.byte $7F
ascisp  	.byte $20
asciw   	.byte $57
ascie   	.byte $45
asciy   	.byte $59
ascii   	.byte $49
ascia   	.byte $41
ascis   	.byte $53
ascih   	.byte $48
ascil   	.byte $4C
ascic   	.byte $43
ascib   	.byte $42
ascin   	.byte $4E
ascidash	.byte $2D
asciplus	.byte $2B
ascilpr 	.byte $28
ascirpr 	.byte $29
asciast 	.byte $2A
asciper 	.byte $2E
asciless	.byte $3C
asciline	.byte $5F
ascibsl 	.byte $5C
asci9   	.byte $39
asci0   	.byte $30
asciu   	.byte $55
ascid   	.byte $44
ascip   	.byte $50
ascix   	.byte $58
asciz   	.byte $5A
ascim   	.byte $4D
ascir   	.byte $52

;  color palettes
colorbw 	.word   	$000,$777,$777,$777,$777,$777,$777,$777
			.word   	$777,$777,$777,$777,$777,$777,$777,$777
color1a 	.word   	$000,$777,$700,$070,0,0,0,0,0,0,0,0,0,0,0,0
color1b 	.word   	$000,$777,$706,$070,0,0,0,0,0,0,0,0,0,0,0,0
color2  	.word   	$013,$505,$700,$775,0,0,0,0,0,0,0,0,0,0,0,0 	; 2
			.word   	$000,$077,$700,$077,0,0,0,0,0,0,0,0,0,0,0,0 	; 3
			.word   	$555,$400,$300,$000,0,0,0,0,0,0,0,0,0,0,0,0 	; 4
			.word   	$531,$770,$000,$200,0,0,0,0,0,0,0,0,0,0,0,0 	; 5
			.word   	$300,$660,$731,$444,0,0,0,0,0,0,0,0,0,0,0,0 	; 6
			.word   	$222,$777,$642,$770,0,0,0,0,0,0,0,0,0,0,0,0 	; 7
			.word   	$020,$070,$777,$642,0,0,0,0,0,0,0,0,0,0,0,0 	; 8
			.word   	$202,$660,$707,$555,0,0,0,0,0,0,0,0,0,0,0,0 	; 9
			.word   	$000,$077,$700,$606,0,0,0,0,0,0,0,0,0,0,0,0 	;10
			.word   	$004,$777,$077,$703,0,0,0,0,0,0,0,0,0,0,0,0  ;11unused
			.word   	$002,$777,$600,$070,0,0,0,0,0,0,0,0,0,0,0,0 	;12
			.word   	$222,$076,$600,$777,0,0,0,0,0,0,0,0,0,0,0,0 	;13
			.word   	$000,$770,$077,$707,0,0,0,0,0,0,0,0,0,0,0,0 	;14
;  inverted b/w color palette for hardcopying
dummycol	.word   $777,0,0,0,  0,0,0,0,  0,0,0,0,  0,0,0,0

;  names for color registers
cbakgnd 	.byte   	0   	; background screen color
cecho   	.byte   	3   	; color for echoing user input
cprompt 	.byte   	2   	; color for any prompt
ccurmen 	.byte   	3   	; color for most recently selected menu item
cmenu   	.byte   	1   	; color for other menu items
cmenkey 	.byte   	3   	; color for menu keys
cmenhed 	.byte   	3   	; color for menu heading
cmessge 	.byte   	1   	; color for all other text
coutlne 	.byte   	3   	; color for dividing lines
cstart  	.byte   	2   	; color for text on startup screen

;  initsound*
initsnd 	.byte   	99,99,99,99,99,99,99,0,0,0,0,0,0,0,0,0,99,0,1,0,7
			.byte   	99,99,99,99,99,99,99,0,0,0,0,0,0,0,0,0,99,0,1,0,7
			.byte   	99,99,99,99,99,99,99,0,0,0,0,0,0,0,0,0,99,0,1,0,7
			.byte   	99,99,99,99,99,99,99,0,0,0,0,0,0,0,0,0,99,0,1,0,7
			.byte   	99,99,99,99,99,99,99,0,0,0,0,0,0,0,0,0,99,0,1,0,7
			.byte   	99,99,99,99,99,99,99,0,0,0,0,0,0,0,0,0,99,0,1,0,7
			.byte   	99,99,99,99,50,50,50,50,31,0,1,35,0,0,0,0,0,0
			.byte   	24,0,2,0,1,0,0,0,0,0,0,0,0,0,0,0

;  # columns in catalog output
catfmt  	.byte   	3

;  catmess(0) is word after "cannot" or before "aborted" for catalog menu
;  other catmess strings are headings for catalog output pages
catmess 	.ascii  	"Catalog  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;0
			.ascii  	"Catalog all files: xxxxxxxxxxxxxxxxxxxx"   ;1
			.ascii  	"Catalog locked files: xxxxxxxxxxxxxxxxx"   ;2
			.ascii  	"Catalog unlocked files: xxxxxxxxxxxxxxx"   ;3
			.ascii  	"Catalog indexed files:  xxxxxxxxxxxxxxx"   ;4
			.ascii  	"Catalog unindexed files:  xxxxxxxxxxxxx"   ;5
			.ascii  	"Catalog files, prefix =  xxxxxxxxxxxxxx"   ;6
			.ascii  	"Catalog files, suffix =  xxxxxxxxxxxxxx"   ;7
			.ascii  	"Catalog one file: xxxxxxxxxxxxxxxxxxxxx"   ;8
			.ascii  	"Catalog files, infix = xxxxxxxxxxxxxxxx"   ;9
			.ascii  	"Catalog files, revision(s) = xxxxxxxxxx"   ;10

catmesl 	.byte   	7,18,21,23,22,24,23,23,17,22,28

;  largest prime # less than maxfile used by hashfil routine
;  note: lprime MUST be < maxfile
lprime  	.word   	1031

;  names for init ws, init wb, android sounds
initname	.ascii  	"----------"
and1name	.ascii  	"Android-1 "
and2name	.ascii  	"Android-2 "

;  bank keys -- same as on the DX7
bankkey 	.ascii  	"1234567890ABCDEFGHIJKLMNOPQRSTUV"
;  bank keys -- numerical
bankkeyn	.ascii  	"( 1) ( 2) ( 3) ( 4) ( 5) ( 6) ( 7) ( 8)"
			.ascii  	"( 9) (10) (11) (12) (13) (14) (15) (16)"
			.ascii  	"(17) (18) (19) (20) (21) (22) (23) (24)"
			.ascii  	"(25) (26) (27) (28) (29) (30) (31) (32)"

;  text for index pages
indmess 	.ascii  	"CREATE INDEX FOR  xxxxxxxxxxxxxxxxxxxx "   ;0
			.ascii  	"EDIT INDEX FOR  xxxxxxxxxxxxxxxxxxxxxx "   ;1
			.ascii  	"Menu:  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;2 unused
			.ascii  	"[Help] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx "    ;3
			.ascii  	" -- hardcopy screen  xxxxxxxxxxxxxxxxx "   ;4
			.ascii  	"arrows, [Tab], [cr] xxxxxxxxxxxxxxxxxx "   ;5
			.ascii  	" -- move cursor  xxxxxxxxxxxxxxxxxxxxx "   ;6
			.ascii  	"[bs] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;7
			.ascii  	" -- delete character, leave space xxxx "   ;8
			.ascii  	"[Clr/Home] xxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;9
			.ascii  	" -- erase entire index  xxxxxxxxxxxxxx "   ;10
			.ascii  	"[Undo] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;11
			.ascii  	" -- start over xxxxxxxxxxxxxxxxxxxxxxx "   ;12
			.ascii  	"[Esc] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;13
			.ascii  	" -- finish  xxxxxxxxxxxxxxxxxxxxxxxxxx "   ;14
			.ascii  	"Enter text using printable keys.  xxxx "   ;15
			.ascii  	"Disk i/o error! xxxxxxxxxxxxxxxxxxxxxx "   ;16
			.ascii  	"Any key to return to index menu. xxxxx "   ;17
			.ascii  	"[Delete] xxxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;18
			.ascii  	" -- delete character, close space xxxx "   ;19
			.ascii  	"[Insert] xxxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;20
			.ascii  	" -- insert character xxxxxxxxxxxxxxxxx "   ;21

;   number of characters in each indmess string
indmesl 	.byte   	16,14, 5, 6,19,19,15, 4,33,10
			.byte   	22, 6,14, 5,10,32,15,32, 8,33
			.byte   	 8,20

;  text for bank pages
bnkmess 	.ascii  	"Bank  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  "   ;0
			.ascii  	"Any key to return to bank menu xxxxxx  "   ;1
			.ascii  	"Execute Workbank xxxxxxxxxxxxxxxxxxxx  "   ;2
			.ascii  	"1-9,0,A-V to send a WB slot to synth   "   ;3
			.ascii  	"[cr] to return to bank menu xxxxxxxxx  "   ;4
			.ascii  	"Any other key to return to bank menu x "   ;5
			.ascii  	"Bank Names xxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;6
			.ascii  	"(no name) xxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;7
			.ascii  	"[sp] or synth 'yes' to step forward xx "   ;8
			.ascii  	"[bs] or synth 'no' to step backward xx "   ;9
			.ascii  	"Execute with function parameters xxxxx "   ;10
			.ascii  	"Execute without function parameters xx "   ;11
			.ascii  	"Execute only function parameters xxxxx "   ;12
			.ascii  	"Type [Esc] to change this. xxxxxxxxxxx "   ;13
			.ascii  	"Menu: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;14
			.ascii  	"Mix Workbank and a Bank xxxxxxxxxxxxxx "   ;15
			.ascii  	"Workbank xxxxxxxxxxxxxxxxxxxxxxxxxxxxx "   ;16
			.ascii  	"1-9,0,A-V to select workbank slot xxxx "   ;17
			.ascii  	"[cr] to return to edit bank menu xxxxx "   ;18
			.ascii  	"1-9,0,A-V to select bank slot xxxxxxxx "   ;19
			.ascii  	"[cr] to de-select workbank slot xxxxxx "   ;20
			.ascii  	"right arrow: copy WB slot to bank slot "   ;21
			.ascii  	"left arrow: copy bank slot to WB slot x"   ;22
			.ascii  	"up or down arrow: swap WB/bank slots xx"   ;23
			.ascii  	"Disk i/o error! xxxxxxxxxxxxxxxxxxxxxxx"   ;24
			.ascii  	"Any key to return to edit bank menu xxx"   ;25
			.ascii  	"[Esc] to abort xxxxxxxxxxxxxxxxxxxxxxxx"   ;26

;   # of characters in each bnkmess string
bnkmesl 	.byte   	 4,30,16,36,27,36,10, 9,35,35
			.byte   	32,35,32,26, 5,23, 8,33,32,29
			.byte   	31,38,37,36,15,35,14

;   string written to disk to identify it as a valid data disk
dxosid  	.ascii  	"DXOS"
;   pseudo-file directory for data disk  --  use Pascal form
dxmess1 	.ascii  	'DxEditor'
dxmess2 	.ascii  	'data'
dxmess3 	.ascii  	'disk'
;  text used for "info bars"
infomess	.ascii  	"Workspace Name: xxxxxxxx"  	;0
			.ascii  	"Workspace monitoring xxx"  	;1
			.ascii  	"on. xxxxxxxxxxxxxxxxxxxx"  	;2
			.ascii  	"off. xxxxxxxxxxxxxxxxxxx"  	;3
			.ascii  	"Files Used: xxxxxxxxxxxx"  	;4
			.ascii  	"Files Unused: xxxxxxxxxx"  	;5
			.ascii  	"Files Locked: xxxxxxxxxx"  	;6
			.ascii  	"Files Unlocked: xxxxxxxx"  	;7
			.ascii  	"Edit monitoring xxxxxxxx"  	;8
			.ascii  	"with f-pars.   xxxxxxxxx"  	;9
			.ascii  	"without f-pars. xxxxxxxx"  	;10
			.ascii  	"only f-pars.   xxxxxxxxx"  	;11
			.ascii  	"Current Midi Ch: xxxxxxx"  	;12
			.ascii  	"Files Indexed: xxxxxxxxx"  	;13
			.ascii  	"Files Unindexed: xxxxxxx"  	;14
			.ascii  	"MIDI Thru: xxxxxxxxxxxxx"  	;15

infomesl	.byte   	15,20, 4, 4,11,13,13,15,15,15
			.byte   	15,15,16,14,16,10


; text used for editors
editmess	.ascii  	"Numerical edit / screen 1: xxxxxxxxxxxx"   ; 0
			.ascii  	"(edited version) xxxxxxxxxxxxxxxxxxxxxx"   ; 1
			.ascii  	"Menu: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 2
			.ascii  	"arrows xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 3
			.ascii  	"move cursor xxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 4
			.ascii  	"[+][-] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 5
			.ascii  	"step data entry xxxxxxxxxxxxxxxxxxxxxxx"   ; 6
			.ascii  	"u-n-d xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 7
			.ascii  	"undo all editing xxxxxxxxxxxxxxxxxxxxxx"   ; 8
			.ascii  	"[s] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 9
			.ascii  	"go to screen 2 xxxxxxxxxxxxxxxxxxxxxxxx"   ;10
			.ascii  	"[w] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;11
			.ascii  	"arrows, mouse xxxxxxxxxxxxxxxxxxxxxxxxx"   ;12
			.ascii  	"[Help] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;13
			.ascii  	"hardcopy screen xxxxxxxxxxxxxxxxxxxxxxx"   ;14
			.ascii  	"[0]-[9] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;15
			.ascii  	"direct data entry xxxxxxxxxxxxxxxxxxxxx"   ;16
			.ascii  	"[cr] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;17
			.ascii  	"go to edit menu xxxxxxxxxxxxxxxxxxxxxxx"   ;18
			.ascii  	"[del] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;19
			.ascii  	"unedit parameter xxxxxxxxxxxxxxxxxxxxxx"   ;20
			.ascii  	"Algorithm: xxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;21
			.ascii  	"(original version) xxxxxxxxxxxxxxxxxxxx"   ;22
			.ascii  	"[e] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;23
			.ascii  	"[-][+], mouse xxxxxxxxxxxxxxxxxxxxxxxxx"   ;24
			.ascii  	"original to synth xxxxxxxxxxxxxxxxxxxxx"   ;25
			.ascii  	"edited to synth xxxxxxxxxxxxxxxxxxxxxxx"   ;26
			.ascii  	"unedit this screenxxxxxxxxxxxxxxxxxxxxx"   ;27
			.ascii  	"Edit levels & vel sens for: xxxxxxxxxxx"   ;28
			.ascii  	"Numerical edit / screen 2: xxxxxxxxxxxx"   ;29
			.ascii  	"go to screen 1 xxxxxxxxxxxxxxxxxxxxxxxx"   ;30
			.ascii  	"operator xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;31
			.ascii  	"levels xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;32
			.ascii  	"vel sens xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;33
			.ascii  	"EDITED xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;34
			.ascii  	"ORIGINAL xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;35
			.ascii  	"Edit keyboard scaling for: xxxxxxxxxxxx"   ;36
			.ascii  	"Edit operator EG for: xxxxxxxxxxxxxxxxx"   ;37
			.ascii  	"original / operator xxxxxxxxxxxxxxxxxxx"   ;38
			.ascii  	"BP=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;39
			.ascii  	"LD=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;40
			.ascii  	"RD=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;41
			.ascii  	"LC=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;42
			.ascii  	"RC=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;43
			.ascii  	"[sp]xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;44
			.ascii  	"next operator xxxxxxxxxxxxxxxxxxxxxxxxx"   ;45
						; the next message is used in copy-protection:
			.ascii  	"[t] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;46
			.ascii  	"test tones on/offxxxxxxxxxxxxxxxxxxxxxx"   ;47unused
			.ascii  	"[Tab][bs] xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;48
			.ascii  	"tab up/down xxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;49
			.ascii  	"display original xxxxxxxxxxxxxxxxxxxxxx"   ;50
			.ascii  	"display edited xxxxxxxxxxxxxxxxxxxxxxxx"   ;51
			.ascii  	"[p] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;52
			.ascii  	"list other commands xxxxxxxxxxxxxxxxxxx"   ;53
			.ascii  	"[*] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;54
			.ascii  	"mark column xxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;55
			.ascii  	"[esc][c] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;56
			.ascii  	"copy eg xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;57
			.ascii  	"[x] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;58
			.ascii  	"exchange eg's xxxxxxxxxxxxxxxxxxxxxxxxx"   ;59
			.ascii  	"[esc][a] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;60
			.ascii  	"copy column xxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;61
			.ascii  	"[z] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;62
			.ascii  	"exchange columns xxxxxxxxxxxxxxxxxxxxxx"   ;63
			.ascii  	"[m] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;64
			.ascii  	"mute/un-mute operator xxxxxxxxxxxxxxxxx"   ;65

editmesl	.byte   	26,16, 5, 6,11, 6,15, 5,16, 3
			.byte   	14, 3,13, 6,15, 7,17, 4,15, 5
			.byte   	16,10,18, 3,13,17,15,18,27,26
			.byte   	14, 8, 6, 8, 6, 8,26,21,19, 3
			.byte   	 3, 3, 3, 3, 4,13, 3,17, 9,11
			.byte   	16,14, 3,19, 3,11, 8, 7, 3,13
			.byte   	8, 11, 3,16, 3,21

;  data needed by numerical (parametric) editor
cursinfo:
	.byte   6, 5,105,12, 5, 84,18, 5,63,24, 5,42,30, 5,21,36, 5, 0
	.byte   6 ,6,106,12, 6, 85,18, 6,64,24, 6,43,30, 6,22,36, 6, 1
	.byte   6, 7,107,12, 7, 86,18, 7,65,24, 7,44,30, 7,23,36, 7, 2
	.byte   6, 8,108,12, 8, 87,18, 8,66,24, 8,45,30, 8,24,36, 8, 3
	.byte   6, 9,109,12, 9, 88,18, 9,67,24, 9,46,30, 9,25,36, 9, 4
	.byte   6,10,110,12,10, 89,18,10,68,24,10,47,30,10,26,36,10, 5
	.byte   6,11,111,12,11, 90,18,11,69,24,11,48,30,11,27,36,11, 6
	.byte   6,12,112,12,12, 91,18,12,70,24,12,49,30,12,28,36,12, 7
	.byte   6,13,118,12,13, 97,18,13,76,24,13,55,30,13,34,36,13,13
	.byte   6,14,123,12,14,102,18,14,81,24,14,60,30,14,39,36,14,18
	.byte   6,15,124,12,15,103,18,15,82,24,15,61,30,15,40,36,15,19
	.byte   6,16,125,12,16,104,18,16,83,24,16,62,30,16,41,36,16,20
	.byte   6,17,122,12,17,101,18,17,80,24,17,59,30,17,38,36,17,17
	.byte   6,18,121,12,18,100,18,18,79,24,18,58,30,18,37,36,18,16
	.byte   6,19,120,12,19, 99,18,19,78,24,19,57,30,19,36,36,19,15
	.byte   6,20,119,12,20, 98,18,20,77,24,20,56,30,20,35,36,20,14
	.byte   6,21,113,12,21, 92,18,21,71,24,21,50,30,21,29,36,21, 8
	.byte   6,22,116,12,22, 95,18,22,74,24,22,53,30,22,32,36,22,11
	.byte   6,23,114,12,23, 93,18,23,72,24,23,51,30,23,30,36,23, 9
	.byte   6,24,117,12,24, 96,18,24,75,24,24,54,30,24,33,36,24,12
	.byte   6,25,115,12,25, 94,18,25,73,24,25,52,30,25,31,36,25,10

cursinf2:
	.byte    9, 5,126,17, 5,127,25, 5,128,33, 5,129
	.byte    9, 6,130,17, 6,131,25, 6,132,33, 6,133
	.byte    9,11,151,17,11,153,25,11,155,33,11,157
	.byte    9,12,152,17,12,154,25,12,156,33,12,158
	.byte    9,15,136,17,15,144,25,15,134,34,15,135
	.byte    9,19,137,17,19,138,25,19,139,34,19,141
	.byte    9,20,140,17,20,143,26,20,142,33,20,$FF
	.byte    9,22,146,18,22,147,27,22,145,33,22,$FF
	.byte    9,25,150,18,25,149,26,25,148,33,25,$FF

avname  	.ascii  "Average **"
glname  	.ascii  "Glide ****"
distname	.ascii  "Distort **"

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
dxsetup 	.byte   $F0,$43,$10,$08,$27,$01,$F7
			.byte   $F0,$43,$10,$08,$27,$00,$F7
			.byte   $F0,$43,$10,$08,13, $01,$F7
			.byte   $F0,$43,$10,$08,$07,$01,$F7
			.byte   $F0,$43,$10,$08,$07,$01,$F7
			.byte   $B0,$60,$7F
			.byte   $F0,$43,$10,$08,$07,$01,$F7
			.byte   $F0,$43,$10,$08,$21,$01,$F7
			.byte   $B0,$61,$7F
			.byte   $F0,$43,$10,$08,$25,$01,$F7
dxsetl  	.word   61  						; # bytes in dxsetup - 1
;  code to un-set up dx7:
;      press function button
;      release function button
;      battery check
;      internal (go to normal play mode)
dxunset 	.byte   $F0,$43,$10,$08,$27,$01,$F7
			.byte   $F0,$43,$10,$08,$27,$00,$F7
			.byte   $F0,$43,$10,$08,13, $01,$F7
			.byte   $F0,$43,$10,$08,$25,$01,$F7
dxunl   	.word   27  						; # bytes in dxunset - 1
;  distort flags (=1 means distort this parameter, =0 means don't)
disttabl	.byte   1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,0,1,0,1,0,1,1
			.byte     1,1,1,1,1,1,0,0,0,0,0,0,1,1,0,1,0,1,0,1
			.byte   1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,0,1,0,1,0,1,1
			.byte     1,1,1,1,1,1,0,0,0,0,0,0,1,1,0,1,0,1,0,1
			.byte   1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,0,1,0,1,0,1,1
			.byte     1,1,1,1,1,1,0,0,0,0,0,0,1,1,0,1,0,1,0,1
			.byte   	0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1
			.byte   	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
