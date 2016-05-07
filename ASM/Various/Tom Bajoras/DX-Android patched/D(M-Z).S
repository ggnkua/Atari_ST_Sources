;*****************************************************************************;
;    data module  Copyright 1986 Tom Bajoras
;    this module contains only data declarations for
;    constants starting with letters M-Z
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 SECTION _MERGED,data

;***************************************************
;   Every data label must be declared global    *
;***************************************************

 XDEF xmax
 XDEF ymax
 XDEF nmline
 XDEF ncline
 XDEF menuflg
 XDEF nmenu
 XDEF menufmt
 XDEF menuhed
 XDEF menuphed
 XDEF mhedlen
 XDEF menuhedl
 XDEF menu1
 XDEF menu2
 XDEF menu3
 XDEF menu4
 XDEF menu5
 XDEF menu6
 XDEF menu7
 XDEF menu8
 XDEF nmencol1
 XDEF nmencol2
 XDEF menuprp
 XDEF mprlen
 XDEF menulen
 XDEF maxfile
 XDEF maxbank
 XDEF maxmidi
 XDEF maxslot
 XDEF mencol1x
 XDEF mencol2x
 XDEF mencol3x
 XDEF menmargn
 XDEF messss
 XDEF messsl
 XDEF messs2
 XDEF messsl2
 XDEF versmess
 XDEF versmesl
 XDEF reason
 XDEF reasonl
 XDEF prompt
 XDEF promptl
 XDEF wkbnx
 XDEF strtmes
 XDEF strtmesl
 XDEF startmon
 XDEF startcol
 XDEF parmess
 XDEF parmesl
 XDEF parmes2
 XDEF parmes2l
 XDEF parminfo
 XDEF val_lrc
 XDEF val_md
 XDEF val_cfq1
 XDEF val_cfq2
 XDEF val_dtn
 XDEF val_sync
 XDEF val_wave
 XDEF val_tr
 XDEF val_prt1
 XDEF val_prt2
 XDEF val_mw
 XDEF val_bp
 XDEF prttabl

;***************************************************
;   end of global statements        *
;***************************************************

;  screen size (text)
xmax   dc.b    80   ; number of text columns per screen
ymax   dc.b    25   ; number of text rows per screen

;  partition each menu screen into 2 or 3 areas:
;     top -- menu area
;     middle -- information area
;     bottom -- scrolling area
;     nmline = 4 + # rows in menu
;     ncline + nmline = 21 for menus 1-4  = 15 for menu 7
;         = 20 for menu 6
;         = 17 for menu 5
;         = 24 for menu 8
nmline    dc.b     9,8,9,9,8,7,7,9
ncline    dc.b    12,13,12,12,9,13,8,15
;  nmencol rules:  (1) 2-column menu: # items in 1st column >= in 2nd column
;         (2) 3-column menu: 1st and 2nd columns have same # items
;          while 3rd column has <= that #
nmencol1  dc.b    4,3,4,4,3,2,2,4  ; itemx at bottom of 1st column
nmencol2  dc.b    9,7,0,9,7,5,5,9  ; itemx at bottom of 2nd column
nmenu     dc.b    14,7,4,9,11,8,8,14     ; # menu items - 1
menufmt   dc.b    3,2,1,2,3,3,3,3   ; # of menu columns
menuflg   dc.b    1,1,1,1,1,1,1,1,1,1  ; =0 to turn off a function key

;  menu headings
menuhed   dc.b   "F1  Filexxxxxxxxxxxx"
    dc.b   "F2  Editxxxxxxxxxxxx"
    dc.b   "F3  Indexxxxxxxxxxxx"
    dc.b   "F4  Catalogxxxxxxxxx"
    dc.b   "F5  Bankxxxxxxxxxxxx"
    dc.b   "F6  Utilityxxxxxxxxx"
    dc.b   "F7  Edit Bankxxxxxxx"
    dc.b   "F8  Androidxxxxxxxxx"
    dc.b   "F9  Tones xxxxxxxxxx"
    dc.b   "F10 Quitxxxxxxxxxxxx"
menuhedl  dc.b    8,8,9,11,8,11,13,11,9,8

menuphed  dc.b   "file menuxxxxxxx"    ; used in menu prompts
    dc.b   "edit menuxxxxxxx"
    dc.b   "index menuxxxxxx"
    dc.b   "catalog menuxxxx"
    dc.b   "bank menuxxxxxxx"
    dc.b   "utility menuxxxx"
    dc.b   "edit bank menu x"
    dc.b   "android menuxxxx"
mhedlen   dc.b    9,9,10,12,9,12,14,12   ; # of chars in menu headings

; menu items
menu1     dc.b   "Initialize WS xxxxxx"
    dc.b   "Name WS xxxxxxxxxxxx"
    dc.b   "Read a File to WS xx"
    dc.b   "Write WS to a File x"
    dc.b   "Synth Voice to WS  x"
    dc.b   "Synth F-pars to WS x"
    dc.b   "Send WS to Synth xxx"
    dc.b   "Lock a File xxxxxxxx"
    dc.b   "Unlock a File xxxxxx"
    dc.b   "Erase a File xxxxxxx"
    dc.b   "Replace WS to File x"
    dc.b   "Rename a File xxxxxx"
    dc.b   "Lock all Files xxxxx"
    dc.b   "Unlock all Files xxx"
    dc.b   "File to Synth xxxxxx"
menu2     dc.b   "Set Edit Monitoring "
    dc.b   "Undo all Editing  xx"
    dc.b   "Save Editing to WS x"
    dc.b   "Numerical Edit xxxxx"
    dc.b   "Operator EG editxx x"
    dc.b   "KB Scaling Edit xxxx"
    dc.b   "Output Levels Edit x"
    dc.b   "View Operator EG's x"
menu3     dc.b   "Edit Index xxxxxxxxx"
    dc.b   "Copy Index  xxxxxxxx"
    dc.b   "Swap Indexes xxxxxxx"
    dc.b   "Erase an Index xxxxx"
    dc.b   "Erase all Indexes xx"
menu4     dc.b   "One File xxxxxxxxxxx"
    dc.b   "By Prefix xxxxxxxxxx"
    dc.b   "By Suffix xxxxxxxxxx"
    dc.b   "By Infix xxxxxxxxxxx"
    dc.b   "All Files xxxxxxxxxx"
    dc.b   "All Locked Files xxx"
    dc.b   "All Indexed Files xx"
    dc.b   "All Unlocked Files x"
    dc.b   "All Unindexed Files "
    dc.b   "By Revision #(s) xxx"
menu5     dc.b   "Initialize WB xxxxxx"
    dc.b   "Read a Bank to WB xx"
    dc.b   "Write WB to a Bank x"
    dc.b   "Execute Workbank xxx"
    dc.b   "Synth Voices to WB x"
    dc.b   "Synth F-pars to WB x"
    dc.b   "WB Voices to Synth x"
    dc.b   "WB F-pars to Synth x"
    dc.b   "List a Bank  xxxxxxx"
    dc.b   "Erase a Bank xxxxxxx"
    dc.b   "Rename a Bank xxxxxx"
    dc.b   "Bank to Synth xxxxxx"
menu6     dc.b   "Change Data Disks xx"
    dc.b   "Set MIDI Channel # x"
    dc.b   "Set WS Monitoring xx"
    dc.b   "Catalog Synth xxxxxx"
    dc.b   "Erase all Files xxxx"
    dc.b   "Erase all Banks xxxx"
    dc.b   "Set up DX7 xxxxxxxxx"
    dc.b   "Set Test Tones xxxxx"
    dc.b   "MIDI Thru on/off xxx"
menu7     dc.b   "WS to WB slot  xxxxx"
    dc.b   "WB slot to WS  xxxxx"
    dc.b   "Synth to WB slot xxx"
    dc.b   "WB slot to Synth xxx"
    dc.b   "WB slot to WB slot x"
    dc.b   "Swap two WB slots xx"
    dc.b   "Mix WB and a Bank xx"
    dc.b   "Name WB slot xxxxxxx"
    dc.b   "Find Matches xxxxxxx"
menu8     dc.b   "Android-1 WS xxxxxxx"
    dc.b   "Android-1 WB xxxxxxx"
    dc.b   "Android-2 WS xxxxxxx"
    dc.b   "Android-2 WB xxxxxxx"
    dc.b   "Compare WS/ file xxx"
    dc.b   "Compare WS/ WB slot "
    dc.b   "Glide WS to file xxx"
    dc.b   "Glide WS to WB slotx"
    dc.b   "Average WS/ file xxx"
    dc.b   "Average WS/ WB slot "
    dc.b   "Distort WS xxxxxxxxx"
    dc.b   "Quick Load xxxxxxxxx"
    dc.b   "Android-1 18 Banks x"
    dc.b   "Android-2 18 Banks x"
    dc.b   "Set Distort/Android "
;  number of characters in each menu item
;  there must be 20 for each menu,even if there are less than 20 items
;  for that menu
menulen   dc.b   13,7,17,18,17,18,16,11,13,12,18,13      ;1
    dc.b   14,16,13,0,0,0,0,0
    dc.b   19,16,18,14,16,15,18,18,0,0,0,0,0,0,0,0,0,0,0,0   ;2
    dc.b   10,10,12,14,17,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0   ;3
    dc.b    8,9,9,8,9,16,17,18,19,16,0,0,0,0,0,0,0,0,0,0     ;4
    dc.b   13,17,18,16,18,18,18,18,11,12,13,13,0,0,0,0,0,0,0,0  ;5
    dc.b   17,18,17,13,15,15,10,14,16,0,0,0,0,0,0,0,0,0,0,0  ;6
    dc.b   13,13,16,16,18,17,17,12,12,0,0,0,0,0,0,0,0,0,0,0  ;7
    dc.b   12,12,12,12,16,19,16,19,16,19,10,10      ;8
    dc.b   18,18,19,0,0,0,0

;  text needed by getmenu to generate menu prompts
menuprp   dc.b   "Select from  xxxxxxxxxxxxxxxxxx"
    dc.b   ", function key to change menus:"
mprlen    dc.b    11,31   ; number of characters in each of above

; limits
maxfile   dc.w    1032 ; number of files per disk
maxbank   dc.b    18   ; number of banks per disk
maxmidi   dc.b    16   ; highest selectable MIDI channel
maxslot   dc.b    32   ; # of synth slots

;  menu column coordinates
mencol1x  dc.b    4    ; used by 3-column menus
mencol2x  dc.b    32   ; used by 1- and 3-column menus
mencol3x  dc.b    61   ; used by 3-column menus
menmargn  dc.b    11   ; added to mencol1x to get 1st column in
        ; 2-column menu,subtracted from mencol3x
        ; to get 2nd column in 2-column menu

;  message area
messss    dc.b   "Bad name.  Try again.  xxxxxxxxxxxxxxxxx"    ;0
    dc.b   "Bad number.  Try again.  xxxxxxxxxxxxxxx"    ;1
    dc.b   "Replace it? (y/n)  xxxxxxxxxxxxxxxxxxxxx"    ;2
    dc.b   "aborted.  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"    ;3
    dc.b   "Cannot  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"    ;4
    dc.b   "Try again. xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"    ;5
    dc.b   "Are you sure? (y/n) xxxxxxxxxxxxxxxxxxxx"    ;6
    dc.b   "File already on disk. xxxxxxxxxxxxxxxxxx"    ;7
    dc.b   "Disk drive error.  Format disk? (y/n) xx"    ;8
    dc.b   "Erase all files? xxxxxxxxxxxxxxxxxxxxxxx"    ;9
    dc.b   "Formatting failed.  Disk drive error. xx"    ;10
    dc.b   "File already indexed.  xxxxxxxxxxxxxxxxx"    ;11
    dc.b   "Erase all banks?  xxxxxxxxxxxxxxxxxxxxxx"    ;12
    dc.b   "File not indexed. xxxxxxxxxxxxxxxxxxxxxx"    ;13
    dc.b   "Create index? (y/n)  xxxxxxxxxxxxxxxxxxx"    ;14
    dc.b   "Synth i/o problem! xxxxxxxxxxxxxxxxxxxxx"    ;15
    dc.b   "No files found.  Try again. xxxxxxxxxxxx"    ;16
    dc.b   "Name not found.  Try again. xxxxxxxxxxxx"    ;17
    dc.b   "Bad prefix.  Try again. xxxxxxxxxxxxxxxx"    ;18
    dc.b   "Bad suffix.  Try again. xxxxxxxxxxxxxxxx"    ;19
    dc.b   "Type any key for more. xxxxxxxxxxxxxxxxx"    ;20
    dc.b   "Any other key to return to catalog menu "    ;21
    dc.b   "Any other key to return to index menu  x"    ;22
    dc.b   "Save editing? (y/n)  xxxxxxxxxxxxxxxxxxx"    ;23
    dc.b   "[help] to hardcopy this screen xxxxxxxxx"    ;24
    dc.b   "Catalog aborted.  xxxxxxxxxxxxxxxxxxxxxx"    ;25
    dc.b   "Cannot catalog.  xxxxxxxxxxxxxxxxxxxxxxx"    ;26
    dc.b   "Bank already on disk. xxxxxxxxxxxxxxxxxx"    ;27
    dc.b   "Erase all indexes? (y/n) xxxxxxxxxxxxxxx"    ;28
    dc.b   "QUIT? (y/n) xxxxxxxxxxxxxxxxxxxxxxxxxxxx"    ;29
    dc.b   "[cr] to return to catalog menu  xxxxxxxx"    ;30
    dc.b   "[cr] to return to index menu  xxxxxxxxxx"    ;31
    dc.b   "Any other key for more xxxxxxxxxxxxxxxxx"    ;32
    dc.b   "Changing disks may cause loss of data! x"    ;33
    dc.b   "Synth i/o error:  bad data format. xxxxx"    ;34
    dc.b   "Display Workspace / Screen 1: xxxxxxxxxx"    ;35
    dc.b   "Synth input aborted. xxxxxxxxxxxxxxxxxxx"    ;36
    dc.b   "Change disks? (y/n) xxxxxxxxxxxxxxxxxxxx"    ;37
    dc.b   "[a] with, [b] without, [c] only F-pars x"    ;38
    dc.b   "[y] default F-pars, [n] keep old ones  x"    ;39
    dc.b   "Display Workspace / Screen 2: xxxxxxxxxx"    ;40
    dc.b   "Quitting may cause loss of data! xxxxxxx"    ;41
    dc.b   "Formatting failed. Bad sector(s) found.x"    ;42
    dc.b   "Try again? (y/n) xxxxxxxxxxxxxxxxxxxxxxx"    ;43
    dc.b   "Replace index? (y/n)  xxxxxxxxxxxxxxxxxx"    ;44
    dc.b   "Remove data disk; type any key. xxxxxxxx"    ;45
    dc.b   "Bad infix.  Try again.  xxxxxxxxxxxxxxxx"    ;46
    dc.b   "Insert new data disk; type any key. xxxx"    ;47
    dc.b   "FORMATTING DISK xxxxxxxxxxxxxxxxxxxxxxxx"    ;48
    dc.b   "Please wait... xxxxxxxxxxxxxxxxxxxxxxxxx"    ;49
    dc.b   "return to main menu xxxxxxxxxxxxxxxxxxxx"    ;50
    dc.b   "# of parameters different: xxxxxxxxxxxxx"    ;51
;   # of characters in each message
messsl    dc.b    21,23,17,8,6,10,19,21,37,16
    dc.b    37,21,16,17,19,18,27,27,23,23
    dc.b    22,39,37,19,30,16,15,21,18,11
    dc.b    30,28,22,38,34,30,20,19,38,37
    dc.b    30,32,39,16,20,31,22,35,15,14
    dc.b    19,26

versmess  dc.b   "DX-Android 12/03/86 xxxxxxxxxxxxxxxxxxxx"    ; 0
    dc.b   "by Tom Bajoras xxxxxxxxxxxxxxxxxxxxxxxxx"    ; 1
    dc.b   "Hybrid Arts,Inc. xxxxxxxxxxxxxxxxxxxxxx"    ; 2
versmesl  dc.b    19,14,17

;   text for catalog synth output page
messs2    dc.b   "Synth Internal Memory Catalog xxxxxxxxx "
    dc.b   "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  ; unused
    dc.b   "Any other key to return to utility menu "
;   # of characters in each messs2 string
messsl2   dc.b    29,36,39

;   text used by cannot routine
;   x'd out ones are no longer needed and can be replaced by new ones
reason    dc.b   "No banks named."       ; 0
   ds.b   25
    dc.b   "Bank not named."       ; 1
   ds.b   25
    dc.b   "xxxxxxxxxxxxxxxx"      ; 2
   ds.b   24
    dc.b   "Disk is blank."     ; 3
   ds.b   26
    dc.b   "Disk not blank."       ; 4
   ds.b   25
    dc.b   "Disk drive error."     ; 5
   ds.b   23
    dc.b   "Disk not a valid data disk."    ; 6
   ds.b   13
    dc.b   "No files on disk."     ; 7
   ds.b   23
    dc.b   "All files already locked."   ; 8
   ds.b   15
    dc.b   "File not found."       ; 9
   ds.b   25
    dc.b   "File already locked."     ; 10
   ds.b   20
    dc.b   "No files locked."      ; 11
   ds.b   24
    dc.b   "File not locked."      ; 12
   ds.b   24
    dc.b   "File already on disk."    ; 13
   ds.b   19
    dc.b   "File locked."       ; 14
   ds.b   28
    dc.b   "All files locked."     ; 15
   ds.b   23
    dc.b   "Name not found."       ; 16
   ds.b   25
    dc.b   "Duplicate name found."    ; 17
   ds.b   19
    dc.b   "Cannot read disk."     ; 18
   ds.b   23
    dc.b   "All files indexed."    ; 19
   ds.b   22
    dc.b   "Disk already empty."      ; 20
   ds.b   21
    dc.b   "At least one file locked."   ; 21
   ds.b   15
    dc.b   "No banks on disk."     ; 22
   ds.b   23
    dc.b   "Cannot write to disk."    ; 23
   ds.b   19
    dc.b   "Bank empty."        ; 24
   ds.b   29
    dc.b   "Bad sector(s) found."     ; 25
   ds.b   20
    dc.b   "All files already locked."   ; 26
   ds.b   15
    dc.b   "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx."   ; 27unused
   ds.b   6
    dc.b   "No files indexed."        ; 28
   ds.b   23
    dc.b   "File not indexed."        ; 29
   ds.b   23
    dc.b   "Disk full."         ; 30
   ds.b   30
    dc.b   "File is at revision 255."       ; 31
   ds.b   16
;   number of characters in each reason string
reasonl   dc.b    40

;   text used by getit,getyn,getslot
prompt    dc.b   "Enter name,  [cr] to abort: xxxxxxxxxxx "     ;0
    dc.b   "Enter infix,  [cr] to abort: xxxxxxxxxxx"     ;1
    dc.b   "Enter MIDI ch # (1-16),  [cr] to abort: "     ;2
    dc.b   "Enter file name,  [cr] to abort: xxxxxxx"     ;3
    dc.b   "Enter old file name,  [cr] to abort: xxx"     ;4
    dc.b   "Enter new file name,  [cr] to abort: xxx"     ;5
    dc.b   "Enter bank # (1-18),  [cr] to abort: xxx"     ;6
    dc.b   "Enter from file name,  [cr] to abort:  x"     ;7
    dc.b   "Enter to file name,  [cr] to abort:  xxx"     ;8
    dc.b   "2nd WB slot (1-9,0,A-V),  [cr] to abort:"     ;9
    dc.b   "Enter prefix,  [cr] to abort:  xxxxxxxxx"     ;10
    dc.b   "Enter suffix,  [cr] to abort:  xxxxxxxxx"     ;11
    dc.b   "Enter 1st file name,  [cr] to abort: xxx"     ;12
    dc.b   "Enter 2nd file name,  [cr] to abort: xxx"     ;13
    dc.b   "Enter bank name,  [cr] for no name: xxxx"     ;14
    dc.b   "WB slot (1-9,0,A-V),  [cr] to abort:  xx"     ;15
    dc.b   "From WB slot (1-9,0,A-V), [cr] to abort:"     ;16
    dc.b   "To WB slot (1-9,0,A-V),  [cr] to abort: "     ;17
    dc.b   "1st WB slot (1-9,0,A-V),  [cr] to abort:"     ;18
    dc.b   "Enter from rev (0-255),  [cr] to abort: "     ;19
    dc.b   "Enter to rev (0-255),  [cr] to abort: xx"     ;20
    dc.b   "Enter # of steps (1-16),  [cr] to abort:"     ;21
    dc.b   "Enter synth slot (1-32),  [cr] to abort:"     ;22
    dc.b   "Enter attenuation (1-7),  [cr] to abort:"     ;23
    dc.b   "Enter max differ (0-159), [cr] to abort:"     ;24

;   # of characters in each prompt string
promptl   dc.b    26,27,38,31,35,35,35,36,34,39
    dc.b    28,28,35,35,34,35,39,38,39,38
    dc.b    36,39,39,39,39

;   x-coords for w.b. slot names in menu 7 workbank area and execbnk
wkbnx     dc.b    8,29,50,71

;  text for startup
strtmes   dc.b   "Insert data disk; type a key.  xxxxxxxxx"   ;0
    dc.b   "[cr] to abort. xxxxxxxxxxxxxxxxxxxxxxxxx"   ;1
    dc.b   "Not a valid data disk. Format it? (y/n) "   ;2
    dc.b   "Disk drive error.  Check:  xxxxxxxxxxxxx"   ;3
    dc.b   "   Disk drive power on?  xxxxxxxxxxxxxxx"   ;4
    dc.b   "   Disk drive connected?  xxxxxxxxxxxxxx"   ;5
    dc.b   "   Disk in drive?  xxxxxxxxxxxxxxxxxxxxx"   ;6
    dc.b   "Try again:  xxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;7
    dc.b   "   Disk formatted?  xxxxxxxxxxxxxxxxxxxx"   ;8
    dc.b   "DX-Android   Copyright 1986 Tom Bajorasx"   ;9
    dc.b   "[a] re-try,[b] format disk,[c] quitxxxxx"   ;10
strtmesl  dc.b    29,14,39,25,23,24,17,10,18,39,37

;  name of startup screen files
startmon  dc.b   "DVM",0   ; monochrome file
startcol  dc.b   "DVC",0   ; color file

;  table of printer types for hardcopy
prttabl   dc.w    0,2,1,-1,3,-1,-1,-1

;  names of parameters for numerical editing (screen 1)
parmess:
  dc.b  "  R1  R2  R3  R4  L1  L2  L3  L4KBRT CFQ FFQ DTNMODE LEV"
  dc.b  "VEL AMS  BP  LC  LD  RC  RD"
parmesl   dc.b    4

;  names of parameters for numerical editing (screen 2)
parmes2   dc.b   "Pitch EG:xxxxxx" ;0
    dc.b   "R1=xxxxxxxxxxxx" ;1
    dc.b   "R2=xxxxxxxxxxxx" ;2
    dc.b   "R3=xxxxxxxxxxxx" ;3
    dc.b   "R4=xxxxxxxxxxxx" ;4
    dc.b   "L1=xxxxxxxxxxxx" ;5
    dc.b   "L2=xxxxxxxxxxxx" ;6
    dc.b   "L3=xxxxxxxxxxxx" ;7
    dc.b   "L4=xxxxxxxxxxxx" ;8
    dc.b   "Controllers:xxx" ;9
    dc.b   "MWxxxxxxxxxxxxx" ;10
    dc.b   "FCxxxxxxxxxxxxx" ;11
    dc.b   "BCxxxxxxxxxxxxx" ;12
    dc.b   "ATxxxxxxxxxxxxx" ;13
    dc.b   "Range:xxxxxxxxxx" ;14
    dc.b   "Assign:xxxxxxx" ;15
    dc.b   "OpSync=xxxxxxxx" ;16
    dc.b   "TR=xxxxxxxxxxxx" ;17
    dc.b   "AL=xxxxxxxxxxxx" ;18
    dc.b   "FB=xxxxxxxxxxxx" ;19
    dc.b   "LFO:xxxxxxxxxxx" ;20
    dc.b   "SPD=xxxxxxxxxxx" ;21
    dc.b   "DLY=xxxxxxxxxxx" ;22
    dc.b   "PMD=xxxxxxxxxxx" ;23
    dc.b   "SYNC=xxxxxxxxxx" ;24
    dc.b   "AMD=xxxxxxxxxxx" ;25
    dc.b   "PMS=xxxxxxxxxxx" ;26
    dc.b   "WAVE=xxxxxxxxxx" ;27
    dc.b   "PbRange=xxxxxxx" ;28
    dc.b   "Step=xxxxxxxxxx" ;29
    dc.b   "Mono=xxxxxxxxxx" ;30
    dc.b   "Portamento:xxxx" ;31
    dc.b   "Time=xxxxxxxxxx" ;32
    dc.b   "Glis=xxxxxxxxxx" ;33
    dc.b   "MD=xxxxxxxxxxxx" ;34

parmes2l  dc.b    9,3,3,3,3,3,3,3,3,12
    dc.b    2,2,2,2,6,7,7,3,3,3
    dc.b    4,4,4,4,5,4,4,5,8,5
    dc.b    5,11,5,5,3

    EVEN

;   info about w.s./e.s. parameters -- 2nd word of each is filled in by
;   initpri (for parameters marked by *)
;   low mark,high mark,# of chars,ptr to non-numeric data
parminfo  dc.b    0,99,2,10,0,0,0,0    ;  op 6 eg r1
    dc.b    0,99,2,10,0,0,0,0    ;  op 6 eg r2
    dc.b    0,99,2,10,0,0,0,0    ;  op 6 eg r3
    dc.b    0,99,2,10,0,0,0,0    ;  op 6 eg r4
    dc.b    0,99,2,10,0,0,0,0    ;  op 6 eg l1
    dc.b    0,99,2,10,0,0,0,0    ;  op 6 eg l2
    dc.b    0,99,2,10,0,0,0,0    ;  op 6 eg l3
    dc.b    0,99,2,10,0,0,0,0    ;  op 6 eg l4
    dc.b    0,99,4,12,0,0,0,0    ;  op 6 bp
    dc.b    0,99,2,10,0,0,0,0    ;  op 6 ld
    dc.b    0,99,2,10,0,0,0,0    ;  op 6 rd
    dc.b    0,3,2,1,0,0,0,0  ;  op 6 lc *
    dc.b    0,3,2,1,0,0,0,0  ;  op 6 rc *
    dc.b    0,7,1,1,0,0,0,0  ;  op 6 kbrt
    dc.b    0,3,1,1,0,0,0,0  ;  op 6 ams
    dc.b    0,7,1,1,0,0,0,0  ;  op 6 vel
    dc.b    0,99,2,10,0,0,0,0    ;  op 6 level
    dc.b    0,1,2,1,0,0,0,0  ;  op 6 mode *
    dc.b    0,31,4,5,0,0,0,0  ;  op 6 cfq *
    dc.b    0,99,4,10,0,0,0,1    ;  op 6 ffq
    dc.b    0,14,2,1,0,0,0,0  ;  op 6 dtn *

    dc.b    0,99,2,10,0,0,0,0    ;  op 5 eg r1
    dc.b    0,99,2,10,0,0,0,0    ;  op 5 eg r2
    dc.b    0,99,2,10,0,0,0,0    ;  op 5 eg r3
    dc.b    0,99,2,10,0,0,0,0    ;  op 5 eg r4
    dc.b    0,99,2,10,0,0,0,0    ;  op 5 eg l1
    dc.b    0,99,2,10,0,0,0,0    ;  op 5 eg l2
    dc.b    0,99,2,10,0,0,0,0    ;  op 5 eg l3
    dc.b    0,99,2,10,0,0,0,0    ;  op 5 eg l4
    dc.b    0,99,4,12,0,0,0,0    ;  op 5 bp
    dc.b    0,99,2,10,0,0,0,0    ;  op 5 ld
    dc.b    0,99,2,10,0,0,0,0    ;  op 5 rd
    dc.b    0,3,2,1,0,0,0,0  ;  op 5 lc *
    dc.b    0,3,2,1,0,0,0,0  ;  op 5 rc *
    dc.b    0,7,1,1,0,0,0,0  ;  op 5 kbrt
    dc.b    0,3,1,1,0,0,0,0  ;  op 5 ams
    dc.b    0,7,1,1,0,0,0,0  ;  op 5 vel
    dc.b    0,99,2,10,0,0,0,0    ;  op 5 level
    dc.b    0,1,2,1,0,0,0,0  ;  op 5 mode *
    dc.b    0,31,4,5,0,0,0,0  ;  op 5 cfq *
    dc.b    0,99,4,10,0,0,0,1    ;  op 5 ffq
    dc.b    0,14,2,1,0,0,0,0  ;  op 5 dtn *

    dc.b    0,99,2,10,0,0,0,0    ;  op 4 eg r1
    dc.b    0,99,2,10,0,0,0,0    ;  op 4 eg r2
    dc.b    0,99,2,10,0,0,0,0    ;  op 4 eg r3
    dc.b    0,99,2,10,0,0,0,0    ;  op 4 eg r4
    dc.b    0,99,2,10,0,0,0,0    ;  op 4 eg l1
    dc.b    0,99,2,10,0,0,0,0    ;  op 4 eg l2
    dc.b    0,99,2,10,0,0,0,0    ;  op 4 eg l3
    dc.b    0,99,2,10,0,0,0,0    ;  op 4 eg l4
    dc.b    0,99,4,12,0,0,0,0    ;  op 4 bp
    dc.b    0,99,2,10,0,0,0,0    ;  op 4 ld
    dc.b    0,99,2,10,0,0,0,0    ;  op 4 rd
    dc.b    0,3,2,1,0,0,0,0  ;  op 4 lc *
    dc.b    0,3,2,1,0,0,0,0  ;  op 4 rc *
    dc.b    0,7,1,1,0,0,0,0  ;  op 4 kbrt
    dc.b    0,3,1,1,0,0,0,0  ;  op 4 ams
    dc.b    0,7,1,1,0,0,0,0  ;  op 4 vel
    dc.b    0,99,2,10,0,0,0,0    ;  op 4 level
    dc.b    0,1,2,1,0,0,0,0  ;  op 4 mode *
    dc.b    0,31,4,5,0,0,0,0  ;  op 4 cfq *
    dc.b    0,99,4,10,0,0,0,1    ;  op 4 ffq
    dc.b    0,14,2,1,0,0,0,0  ;  op 4 dtn *

    dc.b    0,99,2,10,0,0,0,0    ;  op 3 eg r1
    dc.b    0,99,2,10,0,0,0,0    ;  op 3 eg r2
    dc.b    0,99,2,10,0,0,0,0    ;  op 3 eg r3
    dc.b    0,99,2,10,0,0,0,0    ;  op 3 eg r4
    dc.b    0,99,2,10,0,0,0,0    ;  op 3 eg l1
    dc.b    0,99,2,10,0,0,0,0    ;  op 3 eg l2
    dc.b    0,99,2,10,0,0,0,0    ;  op 3 eg l3
    dc.b    0,99,2,10,0,0,0,0    ;  op 3 eg l4
    dc.b    0,99,4,12,0,0,0,0    ;  op 3 bp
    dc.b    0,99,2,10,0,0,0,0    ;  op 3 ld
    dc.b    0,99,2,10,0,0,0,0    ;  op 3 rd
    dc.b    0,3,2,1,0,0,0,0  ;  op 3 lc *
    dc.b    0,3,2,1,0,0,0,0  ;  op 3 rc *
    dc.b    0,7,1,1,0,0,0,0  ;  op 3 kbrt
    dc.b    0,3,1,1,0,0,0,0  ;  op 3 ams
    dc.b    0,7,1,1,0,0,0,0  ;  op 3 vel
    dc.b    0,99,2,10,0,0,0,0    ;  op 3 level
    dc.b    0,1,2,1,0,0,0,0  ;  op 3 mode *
    dc.b    0,31,4,5,0,0,0,0  ;  op 3 cfq *
    dc.b    0,99,4,10,0,0,0,1    ;  op 3 ffq
    dc.b    0,14,2,1,0,0,0,0  ;  op 3 dtn *

    dc.b    0,99,2,10,0,0,0,0    ;  op 2 eg r1
    dc.b    0,99,2,10,0,0,0,0    ;  op 2 eg r2
    dc.b    0,99,2,10,0,0,0,0    ;  op 2 eg r3
    dc.b    0,99,2,10,0,0,0,0    ;  op 2 eg r4
    dc.b    0,99,2,10,0,0,0,0    ;  op 2 eg l1
    dc.b    0,99,2,10,0,0,0,0    ;  op 2 eg l2
    dc.b    0,99,2,10,0,0,0,0    ;  op 2 eg l3
    dc.b    0,99,2,10,0,0,0,0    ;  op 2 eg l4
    dc.b    0,99,4,12,0,0,0,0    ;  op 2 bp
    dc.b    0,99,2,10,0,0,0,0    ;  op 2 ld
    dc.b    0,99,2,10,0,0,0,0    ;  op 2 rd
    dc.b    0,3,2,1,0,0,0,0  ;  op 2 lc *
    dc.b    0,3,2,1,0,0,0,0  ;  op 2 rc *
    dc.b    0,7,1,1,0,0,0,0  ;  op 2 kbrt
    dc.b    0,3,1,1,0,0,0,0  ;  op 2 ams
    dc.b    0,7,1,1,0,0,0,0  ;  op 2 vel
    dc.b    0,99,2,10,0,0,0,0    ;  op 2 level
    dc.b    0,1,2,1,0,0,0,0  ;  op 2 mode *
    dc.b    0,31,4,5,0,0,0,0  ;  op 2 cfq *
    dc.b    0,99,4,10,0,0,0,1    ;  op 2 ffq
    dc.b    0,14,2,1,0,0,0,0  ;  op 2 dtn *

    dc.b    0,99,2,10,0,0,0,0    ;  op 1 eg r1
    dc.b    0,99,2,10,0,0,0,0    ;  op 1 eg r2
    dc.b    0,99,2,10,0,0,0,0    ;  op 1 eg r3
    dc.b    0,99,2,10,0,0,0,0    ;  op 1 eg r4
    dc.b    0,99,2,10,0,0,0,0    ;  op 1 eg l1
    dc.b    0,99,2,10,0,0,0,0    ;  op 1 eg l2
    dc.b    0,99,2,10,0,0,0,0    ;  op 1 eg l3
    dc.b    0,99,2,10,0,0,0,0    ;  op 1 eg l4
    dc.b    0,99,4,12,0,0,0,0    ;  op 1 bp
    dc.b    0,99,2,10,0,0,0,0    ;  op 1 ld
    dc.b    0,99,2,10,0,0,0,0    ;  op 1 rd
    dc.b    0,3,2,1,0,0,0,0  ;  op 1 lc *
    dc.b    0,3,2,1,0,0,0,0  ;  op 1 rc *
    dc.b    0,7,1,1,0,0,0,0  ;  op 1 kbrt
    dc.b    0,3,1,1,0,0,0,0  ;  op 1 ams
    dc.b    0,7,1,1,0,0,0,0  ;  op 1 vel
    dc.b    0,99,2,10,0,0,0,0    ;  op 1 level
    dc.b    0,1,2,1,0,0,0,0  ;  op 1 mode *
    dc.b    0,31,4,5,0,0,0,0  ;  op 1 cfq *
    dc.b    0,99,4,10,0,0,0,1    ;  op 1 ffq
    dc.b    0,14,2,1,0,0,0,0  ;  op 1 dtn *

    dc.b    0,99,2,10,0,0,0,0    ; pitch eg r1
    dc.b    0,99,2,10,0,0,0,0    ; pitch eg r2
    dc.b    0,99,2,10,0,0,0,0    ; pitch eg r3
    dc.b    0,99,2,10,0,0,0,0    ; pitch eg r4
    dc.b    0,99,2,10,0,0,0,0    ; pitch eg l1
    dc.b    0,99,2,10,0,0,0,0    ; pitch eg l2
    dc.b    0,99,2,10,0,0,0,0    ; pitch eg l3
    dc.b    0,99,2,10,0,0,0,0    ; pitch eg l4
    dc.b    0,31,2,5,0,0,0,0 ; alg
    dc.b    0,7,1,1,0,0,0,0 ; fb
    dc.b    0,1,3,1,0,0,0,0 ; op sync   *
    dc.b    0,99,2,10,0,0,0,0    ; lfo speed
    dc.b    0,99,2,10,0,0,0,0    ; lfo delay
    dc.b    0,99,2,10,0,0,0,0    ; lfo pmd
    dc.b    0,99,2,10,0,0,0,0    ; lfo amd
    dc.b    0,1,3,1,0,0,0,0 ; lfo sync  *
    dc.b    0,5,3,1,0,0,0,0 ; lfo wave   *
    dc.b    0,7,1,1,0,0,0,0 ; lfo pms
    dc.b    0,48,3,12,0,0,0,0    ; transpose   *
    dc.b    0,1,3,1,0,0,0,0 ; mono/poly  *
    dc.b    0,12,2,1,0,0,0,0 ; pb range
    dc.b    0,12,2,1,0,0,0,0 ; pb step
    dc.b    0,1,10,1,0,0,0,0   ; port mode *
    dc.b    0,1,3,1,0,0,0,0 ; gliss *
    dc.b    0,99,2,10,0,0,0,0    ; port time
    dc.b    0,99,2,10,0,0,0,0    ; mw range
    dc.b    0,7,3,1,0,0,0,0 ; mw assign *
    dc.b    0,99,2,10,0,0,0,0    ; fc range
    dc.b    0,7,3,1,0,0,0,0 ; fc assign *
    dc.b    0,99,2,10,0,0,0,0    ; bc range
    dc.b    0,7,3,1,0,0,0,0 ; bc assign *
    dc.b    0,99,2,10,0,0,0,0    ; at range
    dc.b    0,7,3,1,0,0,0,0 ; at assign *

;   text for non-numerical parameter values

val_lrc   dc.b   "-L-E+E+L"
val_md    dc.b   "FRFF"
val_cfq1  dc.b   ".5 1 2 3 4 5 6 7 8"
  dc.b  "910111213141516171819202122232425262728293031"
val_cfq2  dc.b   "_...__..___.____"
val_dtn   dc.b   "-7-6-5-4-3-2-1 0+1+2+3+4+5+6+7"
val_sync  dc.b   "off on"
val_wave  dc.b   "TRI-SW+SWSQRSINS/H"
val_tr    dc.b   "C1 C#1D1 D#1E1 F1 F#1G1 G#1A1 A#1B1"
    dc.b   "C2 C#2D2 D#2E2 F2 F#2G2 G#2A2 A#2B2"
    dc.b   "C3 C#3D3 D#3E3 F3 F#3G3 G#3A3 A#3B3"
    dc.b   "C4 C#4D4 D#4E4 F4 F#4G4 G#4A4 A#4B4 C5 "
val_prt1  dc.b   "FINGERED  FULL-TIME "
val_prt2  dc.b   "KEY-RETAINKEY-FOLLOW"
val_mw    dc.b   " X   P A  APE  E PEA EAP"
val_bp   dc.b  "A -1A#-1B -1C 0 C#0 D 0 D#0 E 0 F 0 F#0 G 0 G#0 A 0 A#0 B 0"
   dc.b  "C 1 C#1 D 1 D#1 E 1 F 1 F#1 G 1 G#1 A 1 A#1 B 1"
   dc.b  "C 2 C#2 D 2 D#2 E 2 F 2 F#2 G 2 G#2 A 2 A#2 B 2"
   dc.b  "C 3 C#3 D 3 D#3 E 3 F 3 F#3 G 3 G#3 A 3 A#3 B 3"
   dc.b  "C 4 C#4 D 4 D#4 E 4 F 4 F#4 G 4 G#4 A 4 A#4 B 4"
   dc.b  "C 5 C#5 D 5 D#5 E 5 F 5 F#5 G 5 G#5 A 5 A#5 B 5"
   dc.b  "C 6 C#6 D 6 D#6 E 6 F 6 F#6 G 6 G#6 A 6 A#6 B 6"
   dc.b  "C 7 C#7 D 7 D#7 E 7 F 7 F#7 G 7 G#7 A 7 A#7 B 7 C 8"
