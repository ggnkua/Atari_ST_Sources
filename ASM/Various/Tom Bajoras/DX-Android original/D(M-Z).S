;*****************************************************************************;
;    data module  Copyright 1986 Tom Bajoras
;    this module contains only data declarations for
;    constants starting with letters M-Z
;*****************************************************************************;

 .data

;***************************************************
;   Every data label must be declared global	   *
;***************************************************

 .global xmax
 .global ymax
 .global nmline
 .global ncline
 .global menuflg
 .global nmenu
 .global menufmt
 .global menuhed
 .global menuphed
 .global mhedlen
 .global menuhedl
 .global menu1
 .global menu2
 .global menu3
 .global menu4
 .global menu5
 .global menu6
 .global menu7
 .global menu8
 .global nmencol1
 .global nmencol2
 .global menuprp
 .global mprlen
 .global menulen
 .global maxfile
 .global maxbank
 .global maxmidi
 .global maxslot
 .global mencol1x
 .global mencol2x
 .global mencol3x
 .global menmargn
 .global messss
 .global messsl
 .global messs2
 .global messsl2
 .global versmess
 .global versmesl
 .global reason
 .global reasonl
 .global prompt
 .global promptl
 .global wkbnx
 .global strtmes
 .global strtmesl
 .global startmon
 .global startcol
 .global parmess
 .global parmesl
 .global parmes2
 .global parmes2l
 .global parminfo
 .global val_lrc
 .global val_md
 .global val_cfq1
 .global val_cfq2
 .global val_dtn
 .global val_sync
 .global val_wave
 .global val_tr
 .global val_prt1
 .global val_prt2
 .global val_mw
 .global val_bp
 .global prttabl

;***************************************************
;   end of global statements					   *
;***************************************************

;  screen size (text)
xmax		.byte   	80  	; number of text columns per screen
ymax		.byte   	25  	; number of text rows per screen

;  partition each menu screen into 2 or 3 areas:
;     top -- menu area
;     middle -- information area
;     bottom -- scrolling area
;     nmline = 4 + # rows in menu
;     ncline + nmline = 21 for menus 1-4  = 15 for menu 7
;   				  = 20 for menu 6
;   				  = 17 for menu 5
;   				  = 24 for menu 8
nmline  	.byte   	 9, 8, 9, 9, 8, 7, 7, 9
ncline  	.byte   	12,13,12,12, 9,13, 8,15
;  nmencol rules:  (1) 2-column menu: # items in 1st column >= in 2nd column
;   			   (2) 3-column menu: 1st and 2nd columns have same # items
;   				   while 3rd column has <= that #
nmencol1	.byte   	4, 3, 4, 4, 3, 2, 2, 4  ; itemx at bottom of 1st column
nmencol2	.byte   	9, 7, 0, 9, 7, 5, 5, 9  ; itemx at bottom of 2nd column
nmenu   	.byte   	14,7,4,9,11,8,8,14     ; # menu items - 1
menufmt 	.byte   	3,2,1,2,3,3,3,3 		; # of menu columns
menuflg 	.byte   	1,1,1,1,1,1,1,1,1,1 	; =0 to turn off a function key

;  menu headings
menuhed 	.ascii  	"F1  Filexxxxxxxxxxx"
			.ascii  	"F2  Editxxxxxxxxxxx"
			.ascii  	"F3  Indexxxxxxxxxxx"
			.ascii  	"F4  Catalogxxxxxxxx"
			.ascii  	"F5  Bankxxxxxxxxxxx"
			.ascii  	"F6  Utilityxxxxxxxx"
			.ascii  	"F7  Edit Bankxxxxxx"
			.ascii  	"F8  Androidxxxxxxxx"
			.ascii  	"F9  Tones xxxxxxxxx"
			.ascii  	"F10 Quitxxxxxxxxxxx"
menuhedl	.byte   	8,8,9,11,8,11,13,11,9,8

menuphed	.ascii  	"file menuxxxxxx"   	; used in menu prompts
			.ascii  	"edit menuxxxxxx"
			.ascii  	"index menuxxxxx"
			.ascii  	"catalog menuxxx"
			.ascii  	"bank menuxxxxxx"
			.ascii  	"utility menuxxx"
			.ascii  	"edit bank menu "
			.ascii  	"android menuxxx"
mhedlen 	.byte   	9,9,10,12,9,12,14,12   ; # of chars in menu headings

; menu items
menu1   	.ascii  	"Initialize WS xxxxx"
			.ascii  	"Name WS xxxxxxxxxxx"
			.ascii  	"Read a File to WS x"
			.ascii  	"Write WS to a File "
			.ascii  	"Synth Voice to WS  "
			.ascii  	"Synth F-pars to WS "
			.ascii  	"Send WS to Synth xx"
			.ascii  	"Lock a File xxxxxxx"
			.ascii  	"Unlock a File xxxxx"
			.ascii  	"Erase a File xxxxxx"
			.ascii  	"Replace WS to File "
			.ascii  	"Rename a File xxxxx"
			.ascii  	"Lock all Files xxxx"
			.ascii  	"Unlock all Files xx"
			.ascii  	"File to Synth xxxxx"
menu2   	.ascii  	"Set Edit Monitoring"
			.ascii  	"Undo all Editing  x"
			.ascii  	"Save Editing to WS "
			.ascii  	"Numerical Edit xxxx"
			.ascii  	"Operator EG editxx "
			.ascii  	"KB Scaling Edit xxx"
			.ascii  	"Output Levels Edit "
			.ascii  	"View Operator EG's "
menu3   	.ascii  	"Edit Index xxxxxxxx"
			.ascii  	"Copy Index  xxxxxxx"
			.ascii  	"Swap Indexes xxxxxx"
			.ascii  	"Erase an Index xxxx"
			.ascii  	"Erase all Indexes x"
menu4   	.ascii  	"One File xxxxxxxxxx"
			.ascii  	"By Prefix xxxxxxxxx"
			.ascii  	"By Suffix xxxxxxxxx"
			.ascii  	"By Infix xxxxxxxxxx"
			.ascii  	"All Files xxxxxxxxx"
			.ascii  	"All Locked Files xx"
			.ascii  	"All Indexed Files x"
			.ascii  	"All Unlocked Files "
			.ascii  	"All Unindexed Files"
			.ascii  	"By Revision #(s) x "
menu5   	.ascii  	"Initialize WB xxxxx"
			.ascii  	"Read a Bank to WB x"
			.ascii  	"Write WB to a Bank "
			.ascii  	"Execute Workbank xx"
			.ascii  	"Synth Voices to WB "
			.ascii  	"Synth F-pars to WB "
			.ascii  	"WB Voices to Synth "
			.ascii  	"WB F-pars to Synth "
			.ascii  	"List a Bank  xxxxxx"
			.ascii  	"Erase a Bank xxxxxx"
			.ascii  	"Rename a Bank xxxxx"
			.ascii  	"Bank to Synth xxxxx"
menu6   	.ascii  	"Change Data Disks x"
			.ascii  	"Set MIDI Channel # "
			.ascii  	"Set WS Monitoring x"
			.ascii  	"Catalog Synth xxxxx"
			.ascii  	"Erase all Files xxx"
			.ascii  	"Erase all Banks xxx"
			.ascii  	"Set up DX7 xxxxxxxx"
			.ascii  	"Set Test Tones xxxx"
			.ascii  	"MIDI Thru on/off xx"
menu7   	.ascii  	"WS to WB slot  xxxx"
			.ascii  	"WB slot to WS  xxxx"
			.ascii  	"Synth to WB slot xx"
			.ascii  	"WB slot to Synth xx"
			.ascii  	"WB slot to WB slot "
			.ascii  	"Swap two WB slots x"
			.ascii  	"Mix WB and a Bank x"
			.ascii  	"Name WB slot xxxxxx"
			.ascii  	"Find Matches xxxxxx"
menu8   	.ascii  	"Android-1 WS xxxxxx"
			.ascii  	"Android-1 WB xxxxxx"
			.ascii  	"Android-2 WS xxxxxx"
			.ascii  	"Android-2 WB xxxxxx"
			.ascii  	"Compare WS/ file xx"
			.ascii  	"Compare WS/ WB slot"
			.ascii  	"Glide WS to file xx"
			.ascii  	"Glide WS to WB slot"
			.ascii  	"Average WS/ file xx"
			.ascii  	"Average WS/ WB slot"
			.ascii  	"Distort WS xxxxxxxx"
			.ascii  	"Quick Load xxxxxxxx"
			.ascii  	"Android-1 18 Banks "
			.ascii  	"Android-2 18 Banks "
			.ascii  	"Set Distort/Android"
;  number of characters in each menu item
;  there must be 20 for each menu, even if there are less than 20 items
;  for that menu
menulen 	.byte   13, 7,17,18,17,18,16,11,13,12,18,13 					;1
			.byte   14,16,13,0,0,0,0,0
			.byte   19,16,18,14,16,15,18,18,0,0,0,0,0,0,0,0,0,0,0,0 		;2
			.byte   10,10,12,14,17,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0			;3
			.byte    8,9,9,8,9,16,17,18,19,16,0,0,0,0,0,0,0,0,0,0   		;4
			.byte   13,17,18,16,18,18,18,18,11,12,13,13,0,0,0,0,0,0,0,0 	;5
			.byte   17,18,17,13,15,15,10,14,16,0,0,0,0,0,0,0,0,0,0,0		;6
			.byte   13,13,16,16,18,17,17,12,12,0,0,0,0,0,0,0,0,0,0,0		;7
			.byte   12,12,12,12,16,19,16,19,16,19,10,10 					;8
			.byte   18,18,19,0,0,0,0

;  text needed by getmenu to generate menu prompts
menuprp 	.ascii  	"Select from  xxxxxxxxxxxxxxxxx"
			.ascii  	", function key to change menus:"
mprlen  	.byte   	11,31   ; number of characters in each of above

; limits
maxfile 	.word   	1032	; number of files per disk
maxbank 	.byte   	18  	; number of banks per disk
maxmidi 	.byte   	16  	; highest selectable MIDI channel
maxslot 	.byte   	32  	; # of synth slots

;  menu column coordinates
mencol1x	.byte   	4   	; used by 3-column menus
mencol2x	.byte   	32  	; used by 1- and 3-column menus
mencol3x	.byte   	61  	; used by 3-column menus
menmargn	.byte   	11  	; added to mencol1x to get 1st column in
								; 2-column menu, subtracted from mencol3x
								; to get 2nd column in 2-column menu

;  message area
messss  	.ascii  	"Bad name.  Try again.  xxxxxxxxxxxxxxxx"   	;0
			.ascii  	"Bad number.  Try again.  xxxxxxxxxxxxxx"   	;1
			.ascii  	"Replace it? (y/n)  xxxxxxxxxxxxxxxxxxxx"   	;2
			.ascii  	"aborted.  xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   	;3
			.ascii  	"Cannot  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   	;4
			.ascii  	"Try again. xxxxxxxxxxxxxxxxxxxxxxxxxxxx"   	;5
			.ascii  	"Are you sure? (y/n) xxxxxxxxxxxxxxxxxxx"   	;6
			.ascii  	"File already on disk. xxxxxxxxxxxxxxxxx"   	;7
			.ascii  	"Disk drive error.  Format disk? (y/n) x"   	;8
			.ascii  	"Erase all files? xxxxxxxxxxxxxxxxxxxxxx"   	;9
			.ascii  	"Formatting failed.  Disk drive error. x"   	;10
			.ascii  	"File already indexed.  xxxxxxxxxxxxxxxx"   	;11
			.ascii  	"Erase all banks?  xxxxxxxxxxxxxxxxxxxxx"   	;12
			.ascii  	"File not indexed. xxxxxxxxxxxxxxxxxxxxx"   	;13
			.ascii  	"Create index? (y/n)  xxxxxxxxxxxxxxxxxx"   	;14
			.ascii  	"Synth i/o problem! xxxxxxxxxxxxxxxxxxxx"   	;15
			.ascii  	"No files found.  Try again. xxxxxxxxxxx"   	;16
			.ascii  	"Name not found.  Try again. xxxxxxxxxxx"   	;17
			.ascii  	"Bad prefix.  Try again. xxxxxxxxxxxxxxx"   	;18
			.ascii  	"Bad suffix.  Try again. xxxxxxxxxxxxxxx"   	;19
			.ascii  	"Type any key for more. xxxxxxxxxxxxxxxx"   	;20
			.ascii  	"Any other key to return to catalog menu"   	;21
			.ascii  	"Any other key to return to index menu  "   	;22
			.ascii  	"Save editing? (y/n)  xxxxxxxxxxxxxxxxxx"   	;23
			.ascii  	"[help] to hardcopy this screen xxxxxxxx"   	;24
			.ascii  	"Catalog aborted.  xxxxxxxxxxxxxxxxxxxxx"   	;25
			.ascii  	"Cannot catalog.  xxxxxxxxxxxxxxxxxxxxxx"   	;26
			.ascii  	"Bank already on disk. xxxxxxxxxxxxxxxxx"   	;27
			.ascii  	"Erase all indexes? (y/n) xxxxxxxxxxxxxx"   	;28
			.ascii  	"QUIT? (y/n) xxxxxxxxxxxxxxxxxxxxxxxxxxx"   	;29
			.ascii  	"[cr] to return to catalog menu  xxxxxxx"   	;30
			.ascii  	"[cr] to return to index menu  xxxxxxxxx"   	;31
			.ascii  	"Any other key for more xxxxxxxxxxxxxxxx"   	;32
			.ascii  	"Changing disks may cause loss of data! "   	;33
			.ascii  	"Synth i/o error:  bad data format. xxxx"   	;34
			.ascii  	"Display Workspace / Screen 1: xxxxxxxxx"   	;35
			.ascii  	"Synth input aborted. xxxxxxxxxxxxxxxxxx"   	;36
			.ascii  	"Change disks? (y/n) xxxxxxxxxxxxxxxxxxx"   	;37
			.ascii  	"[a] with, [b] without, [c] only F-pars "   	;38
			.ascii  	"[y] default F-pars, [n] keep old ones  "   	;39
			.ascii  	"Display Workspace / Screen 2: xxxxxxxxx"   	;40
			.ascii  	"Quitting may cause loss of data! xxxxxx"   	;41
			.ascii  	"Formatting failed. Bad sector(s) found."   	;42
			.ascii  	"Try again? (y/n) xxxxxxxxxxxxxxxxxxxxxx"   	;43
			.ascii  	"Replace index? (y/n)  xxxxxxxxxxxxxxxxx"   	;44
			.ascii  	"Remove data disk; type any key. xxxxxxx"   	;45
			.ascii  	"Bad infix.  Try again.  xxxxxxxxxxxxxxx"   	;46
			.ascii  	"Insert new data disk; type any key. xxx"   	;47
			.ascii  	"FORMATTING DISK xxxxxxxxxxxxxxxxxxxxxxx"   	;48
			.ascii  	"Please wait... xxxxxxxxxxxxxxxxxxxxxxxx"   	;49
			.ascii  	"return to main menu xxxxxxxxxxxxxxxxxxx"   	;50
			.ascii  	"# of parameters different: xxxxxxxxxxxx"   	;51
;   # of characters in each message
messsl  	.byte   	21,23,17, 8, 6,10,19,21,37,16
			.byte   	37,21,16,17,19,18,27,27,23,23
			.byte   	22,39,37,19,30,16,15,21,18,11
			.byte   	30,28,22,38,34,30,20,19,38,37
			.byte   	30,32,39,16,20,31,22,35,15,14
			.byte   	19,26

versmess	.ascii  	"DX-Android 12/03/86 xxxxxxxxxxxxxxxxxxx"   	; 0
			.ascii  	"by Tom Bajoras xxxxxxxxxxxxxxxxxxxxxxxx"   	; 1
			.ascii  	"Hybrid Arts, Inc. xxxxxxxxxxxxxxxxxxxxx"   	; 2
versmesl	.byte   	19,14,17

;   text for catalog synth output page
messs2  	.ascii  	"Synth Internal Memory Catalog xxxxxxxx "
			.ascii  	"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  ; unused
			.ascii  	"Any other key to return to utility menu"
;   # of characters in each messs2 string
messsl2 	.byte   	29,36,39

;   text used by cannot routine
;   x'd out ones are no longer needed and can be replaced by new ones
reason  	.ascii  	"No banks named."   				; 0
			.space  	24
			.ascii  	"Bank not named."   				; 1
			.space  	24
			.ascii  	"xxxxxxxxxxxxxxxx"  				; 2
			.space  	23
			.ascii  	"Disk is blank."					; 3
			.space  	25
			.ascii  	"Disk not blank."   				; 4
			.space  	24
			.ascii  	"Disk drive error." 				; 5
			.space  	22
			.ascii  	"Disk not a valid data disk."   	; 6
			.space  	12
			.ascii  	"No files on disk." 				; 7
			.space  	22
			.ascii  	"All files already locked." 		; 8
			.space  	14
			.ascii  	"File not found."   				; 9
			.space  	24
			.ascii  	"File already locked."  			; 10
			.space  	19
			.ascii  	"No files locked."  				; 11
			.space  	23
			.ascii  	"File not locked."  				; 12
			.space  	23
			.ascii  	"File already on disk." 			; 13
			.space  	18
			.ascii  	"File locked."  					; 14
			.space  	27
			.ascii  	"All files locked." 				; 15
			.space  	22
			.ascii  	"Name not found."   				; 16
			.space  	24
			.ascii  	"Duplicate name found." 			; 17
			.space  	18
			.ascii  	"Cannot read disk." 				; 18
			.space  	22
			.ascii  	"All files indexed."				; 19
			.space  	21
			.ascii  	"Disk already empty."   			; 20
			.space  	20
			.ascii  	"At least one file locked." 		; 21
			.space  	14
			.ascii  	"No banks on disk." 				; 22
			.space  	22
			.ascii  	"Cannot write to disk." 			; 23
			.space  	18
			.ascii  	"Bank empty."   					; 24
			.space  	28
			.ascii  	"Bad sector(s) found."  			; 25
			.space  	19
			.ascii  	"All files already locked." 		; 26
			.space  	14
			.ascii  	"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx."   ; 27unused
			.space  	5
			.ascii  	"No files indexed." 				   ; 28
			.space  	22
			.ascii  	"File not indexed." 				   ; 29
			.space  	22
			.ascii  	"Disk full."						   ; 30
			.space  	29
			.ascii  	"File is at revision 255."  		   ; 31
			.space  	15
;   number of characters in each reason string
reasonl 	.byte   	40

;   text used by getit, getyn, getslot
prompt  	.ascii  	"Enter name, [cr] to abort: xxxxxxxxxxx "     ;0
			.ascii  	"Enter infix, [cr] to abort: xxxxxxxxxxx"     ;1
			.ascii  	"Enter MIDI ch # (1-16), [cr] to abort: "     ;2
			.ascii  	"Enter file name, [cr] to abort: xxxxxxx"     ;3
			.ascii  	"Enter old file name, [cr] to abort: xxx"     ;4
			.ascii  	"Enter new file name, [cr] to abort: xxx"     ;5
			.ascii  	"Enter bank # (1-18), [cr] to abort: xxx"     ;6
			.ascii  	"Enter from file name, [cr] to abort:  x"     ;7
			.ascii  	"Enter to file name, [cr] to abort:  xxx"     ;8
			.ascii  	"2nd WB slot (1-9,0,A-V), [cr] to abort:"     ;9
			.ascii  	"Enter prefix, [cr] to abort:  xxxxxxxxx"     ;10
			.ascii  	"Enter suffix, [cr] to abort:  xxxxxxxxx"     ;11
			.ascii  	"Enter 1st file name, [cr] to abort: xxx"     ;12
			.ascii  	"Enter 2nd file name, [cr] to abort: xxx"     ;13
			.ascii  	"Enter bank name, [cr] for no name: xxxx"     ;14
			.ascii  	"WB slot (1-9,0,A-V), [cr] to abort:  xx"     ;15
			.ascii  	"From WB slot (1-9,0,A-V),[cr] to abort:"     ;16
			.ascii  	"To WB slot (1-9,0,A-V), [cr] to abort: "     ;17
			.ascii  	"1st WB slot (1-9,0,A-V), [cr] to abort:"     ;18
			.ascii  	"Enter from rev (0-255), [cr] to abort: "     ;19
			.ascii  	"Enter to rev (0-255), [cr] to abort: xx"     ;20
			.ascii  	"Enter # of steps (1-16), [cr] to abort:"     ;21
			.ascii  	"Enter synth slot (1-32), [cr] to abort:"     ;22
			.ascii  	"Enter attenuation (1-7), [cr] to abort:"     ;23
			.ascii  	"Enter max differ (0-159),[cr] to abort:"     ;24

;   # of characters in each prompt string
promptl 	.byte   	26,27,38,31,35,35,35,36,34,39
			.byte   	28,28,35,35,34,35,39,38,39,38
			.byte   	36,39,39,39,39

;   x-coords for w.b. slot names in menu 7 workbank area and execbnk
wkbnx   	.byte   	8,29,50,71

;  text for startup
strtmes 	.ascii  	"Insert data disk; type a key.  xxxxxxxx"   ;0
			.ascii  	"[cr] to abort. xxxxxxxxxxxxxxxxxxxxxxxx"   ;1
			.ascii  	"Not a valid data disk. Format it? (y/n)"   ;2
			.ascii  	"Disk drive error.  Check:  xxxxxxxxxxxx"   ;3
			.ascii  	"   Disk drive power on?  xxxxxxxxxxxxxx"   ;4
			.ascii  	"   Disk drive connected?  xxxxxxxxxxxxx"   ;5
			.ascii  	"   Disk in drive?  xxxxxxxxxxxxxxxxxxxx"   ;6
			.ascii  	"Try again:  xxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;7
			.ascii  	"   Disk formatted?  xxxxxxxxxxxxxxxxxxx"   ;8
			.ascii  	"DX-Android   Copyright 1986 Tom Bajoras"   ;9
			.ascii  	"[a] re-try, [b] format disk, [c] quitxx"   ;10
strtmesl	.byte   	29,14,39,25,23,24,17,10,18,39,37

;  name of startup screen files
startmon	.ascii  	"DVM"   ; monochrome file
startcol	.ascii  	"DVC"   ; color file

;  table of printer types for hardcopy
prttabl 	.word   	0,2,1,-1,3,-1,-1,-1

;  names of parameters for numerical editing (screen 1)
parmess:
	.ascii  "  R1  R2  R3  R4  L1  L2  L3  L4KBRT CFQ FFQ DTNMODE LEV"
	.ascii  "VEL AMS  BP  LC  LD  RC  RD"
parmesl 	.byte   	4

;  names of parameters for numerical editing (scren 2)
parmes2 	.ascii  	"Pitch EG:xxxxx"	;0
			.ascii  	"R1=xxxxxxxxxxx"	;1
			.ascii  	"R2=xxxxxxxxxxx"	;2
			.ascii  	"R3=xxxxxxxxxxx"	;3
			.ascii  	"R4=xxxxxxxxxxx"	;4
			.ascii  	"L1=xxxxxxxxxxx"	;5
			.ascii  	"L2=xxxxxxxxxxx"	;6
			.ascii  	"L3=xxxxxxxxxxx"	;7
			.ascii  	"L4=xxxxxxxxxxx"	;8
			.ascii  	"Controllers:xx"	;9
			.ascii  	"MWxxxxxxxxxxxx"	;10
			.ascii  	"FCxxxxxxxxxxxx"	;11
			.ascii  	"BCxxxxxxxxxxxx"	;12
			.ascii  	"ATxxxxxxxxxxxx"	;13
			.ascii  	"Range:xxxxxxxx"	;14
			.ascii  	"Assign:xxxxxxx"	;15
			.ascii  	"OpSync=xxxxxxx"	;16
			.ascii  	"TR=xxxxxxxxxxx"	;17
			.ascii  	"AL=xxxxxxxxxxx"	;18
			.ascii  	"FB=xxxxxxxxxxx"	;19
			.ascii  	"LFO:xxxxxxxxxx"	;20
			.ascii  	"SPD=xxxxxxxxxx"	;21
			.ascii  	"DLY=xxxxxxxxxx"	;22
			.ascii  	"PMD=xxxxxxxxxx"	;23
			.ascii  	"SYNC=xxxxxxxxx"	;24
			.ascii  	"AMD=xxxxxxxxxx"	;25
			.ascii  	"PMS=xxxxxxxxxx"	;26
			.ascii  	"WAVE=xxxxxxxxx"	;27
			.ascii  	"PbRange=xxxxxx"	;28
			.ascii  	"Step=xxxxxxxxx"	;29
			.ascii  	"Mono=xxxxxxxxx"	;30
			.ascii  	"Portamento:xxx"	;31
			.ascii  	"Time=xxxxxxxxx"	;32
			.ascii  	"Glis=xxxxxxxxx"	;33
			.ascii  	"MD=xxxxxxxxxxx"	;34

parmes2l	.byte   	9, 3,3,3,3,3,3,3,3,12
			.byte   	2, 2,2,2,6,7,7,3,3, 3
			.byte   	4, 4,4,4,5,4,4,5,8, 5
			.byte   	5,11,5,5,3

;   info about w.s./e.s. parameters -- 2nd word of each is filled in by
;   initpri (for parameters marked by *)
;   low mark, high mark, # of chars, ptr to non-numeric data
parminfo	.byte   	0,99,2,10,0,0,0,0    ;  op 6 eg r1
			.byte   	0,99,2,10,0,0,0,0    ;  op 6 eg r2
			.byte   	0,99,2,10,0,0,0,0    ;  op 6 eg r3
			.byte   	0,99,2,10,0,0,0,0    ;  op 6 eg r4
			.byte   	0,99,2,10,0,0,0,0    ;  op 6 eg l1
			.byte   	0,99,2,10,0,0,0,0    ;  op 6 eg l2
			.byte   	0,99,2,10,0,0,0,0    ;  op 6 eg l3
			.byte   	0,99,2,10,0,0,0,0    ;  op 6 eg l4
			.byte   	0,99,4,12,0,0,0,0    ;  op 6 bp
			.byte   	0,99,2,10,0,0,0,0    ;  op 6 ld
			.byte   	0,99,2,10,0,0,0,0    ;  op 6 rd
			.byte   	0, 3,2,1,0,0,0,0	 ;  op 6 lc *
			.byte   	0, 3,2,1,0,0,0,0	 ;  op 6 rc *
			.byte   	0, 7,1,1,0,0,0,0	 ;  op 6 kbrt
			.byte   	0, 3,1,1,0,0,0,0	 ;  op 6 ams
			.byte   	0, 7,1,1,0,0,0,0	 ;  op 6 vel
			.byte   	0,99,2,10,0,0,0,0    ;  op 6 level
			.byte   	0, 1,2,1,0,0,0,0	 ;  op 6 mode *
			.byte   	0,31,4,5,0,0,0,0	 ;  op 6 cfq *
			.byte   	0,99,4,10,0,0,0,1    ;  op 6 ffq
			.byte   	0,14,2,1,0,0,0,0	 ;  op 6 dtn *

			.byte   	0,99,2,10,0,0,0,0    ;  op 5 eg r1
			.byte   	0,99,2,10,0,0,0,0    ;  op 5 eg r2
			.byte   	0,99,2,10,0,0,0,0    ;  op 5 eg r3
			.byte   	0,99,2,10,0,0,0,0    ;  op 5 eg r4
			.byte   	0,99,2,10,0,0,0,0    ;  op 5 eg l1
			.byte   	0,99,2,10,0,0,0,0    ;  op 5 eg l2
			.byte   	0,99,2,10,0,0,0,0    ;  op 5 eg l3
			.byte   	0,99,2,10,0,0,0,0    ;  op 5 eg l4
			.byte   	0,99,4,12,0,0,0,0    ;  op 5 bp
			.byte   	0,99,2,10,0,0,0,0    ;  op 5 ld
			.byte   	0,99,2,10,0,0,0,0    ;  op 5 rd
			.byte   	0, 3,2,1,0,0,0,0	 ;  op 5 lc *
			.byte   	0, 3,2,1,0,0,0,0	 ;  op 5 rc *
			.byte   	0, 7,1,1,0,0,0,0	 ;  op 5 kbrt
			.byte   	0, 3,1,1,0,0,0,0	 ;  op 5 ams
			.byte   	0, 7,1,1,0,0,0,0	 ;  op 5 vel
			.byte   	0,99,2,10,0,0,0,0    ;  op 5 level
			.byte   	0, 1,2,1,0,0,0,0	 ;  op 5 mode *
			.byte   	0,31,4,5,0,0,0,0	 ;  op 5 cfq *
			.byte   	0,99,4,10,0,0,0,1    ;  op 5 ffq
			.byte   	0,14,2,1,0,0,0,0	 ;  op 5 dtn *

			.byte   	0,99,2,10,0,0,0,0    ;  op 4 eg r1
			.byte   	0,99,2,10,0,0,0,0    ;  op 4 eg r2
			.byte   	0,99,2,10,0,0,0,0    ;  op 4 eg r3
			.byte   	0,99,2,10,0,0,0,0    ;  op 4 eg r4
			.byte   	0,99,2,10,0,0,0,0    ;  op 4 eg l1
			.byte   	0,99,2,10,0,0,0,0    ;  op 4 eg l2
			.byte   	0,99,2,10,0,0,0,0    ;  op 4 eg l3
			.byte   	0,99,2,10,0,0,0,0    ;  op 4 eg l4
			.byte   	0,99,4,12,0,0,0,0    ;  op 4 bp
			.byte   	0,99,2,10,0,0,0,0    ;  op 4 ld
			.byte   	0,99,2,10,0,0,0,0    ;  op 4 rd
			.byte   	0, 3,2,1,0,0,0,0	 ;  op 4 lc *
			.byte   	0, 3,2,1,0,0,0,0	 ;  op 4 rc *
			.byte   	0, 7,1,1,0,0,0,0	 ;  op 4 kbrt
			.byte   	0, 3,1,1,0,0,0,0	 ;  op 4 ams
			.byte   	0, 7,1,1,0,0,0,0	 ;  op 4 vel
			.byte   	0,99,2,10,0,0,0,0    ;  op 4 level
			.byte   	0, 1,2,1,0,0,0,0	 ;  op 4 mode *
			.byte   	0,31,4,5,0,0,0,0	 ;  op 4 cfq *
			.byte   	0,99,4,10,0,0,0,1    ;  op 4 ffq
			.byte   	0,14,2,1,0,0,0,0	 ;  op 4 dtn *

			.byte   	0,99,2,10,0,0,0,0    ;  op 3 eg r1
			.byte   	0,99,2,10,0,0,0,0    ;  op 3 eg r2
			.byte   	0,99,2,10,0,0,0,0    ;  op 3 eg r3
			.byte   	0,99,2,10,0,0,0,0    ;  op 3 eg r4
			.byte   	0,99,2,10,0,0,0,0    ;  op 3 eg l1
			.byte   	0,99,2,10,0,0,0,0    ;  op 3 eg l2
			.byte   	0,99,2,10,0,0,0,0    ;  op 3 eg l3
			.byte   	0,99,2,10,0,0,0,0    ;  op 3 eg l4
			.byte   	0,99,4,12,0,0,0,0    ;  op 3 bp
			.byte   	0,99,2,10,0,0,0,0    ;  op 3 ld
			.byte   	0,99,2,10,0,0,0,0    ;  op 3 rd
			.byte   	0, 3,2,1,0,0,0,0	 ;  op 3 lc *
			.byte   	0, 3,2,1,0,0,0,0	 ;  op 3 rc *
			.byte   	0, 7,1,1,0,0,0,0	 ;  op 3 kbrt
			.byte   	0, 3,1,1,0,0,0,0	 ;  op 3 ams
			.byte   	0, 7,1,1,0,0,0,0	 ;  op 3 vel
			.byte   	0,99,2,10,0,0,0,0    ;  op 3 level
			.byte   	0, 1,2,1,0,0,0,0	 ;  op 3 mode *
			.byte   	0,31,4,5,0,0,0,0	 ;  op 3 cfq *
			.byte   	0,99,4,10,0,0,0,1    ;  op 3 ffq
			.byte   	0,14,2,1,0,0,0,0	 ;  op 3 dtn *

			.byte   	0,99,2,10,0,0,0,0    ;  op 2 eg r1
			.byte   	0,99,2,10,0,0,0,0    ;  op 2 eg r2
			.byte   	0,99,2,10,0,0,0,0    ;  op 2 eg r3
			.byte   	0,99,2,10,0,0,0,0    ;  op 2 eg r4
			.byte   	0,99,2,10,0,0,0,0    ;  op 2 eg l1
			.byte   	0,99,2,10,0,0,0,0    ;  op 2 eg l2
			.byte   	0,99,2,10,0,0,0,0    ;  op 2 eg l3
			.byte   	0,99,2,10,0,0,0,0    ;  op 2 eg l4
			.byte   	0,99,4,12,0,0,0,0    ;  op 2 bp
			.byte   	0,99,2,10,0,0,0,0    ;  op 2 ld
			.byte   	0,99,2,10,0,0,0,0    ;  op 2 rd
			.byte   	0, 3,2,1,0,0,0,0	 ;  op 2 lc *
			.byte   	0, 3,2,1,0,0,0,0	 ;  op 2 rc *
			.byte   	0, 7,1,1,0,0,0,0	 ;  op 2 kbrt
			.byte   	0, 3,1,1,0,0,0,0	 ;  op 2 ams
			.byte   	0, 7,1,1,0,0,0,0	 ;  op 2 vel
			.byte   	0,99,2,10,0,0,0,0    ;  op 2 level
			.byte   	0, 1,2,1,0,0,0,0	 ;  op 2 mode *
			.byte   	0,31,4,5,0,0,0,0	 ;  op 2 cfq *
			.byte   	0,99,4,10,0,0,0,1    ;  op 2 ffq
			.byte   	0,14,2,1,0,0,0,0	 ;  op 2 dtn *

			.byte   	0,99,2,10,0,0,0,0    ;  op 1 eg r1
			.byte   	0,99,2,10,0,0,0,0    ;  op 1 eg r2
			.byte   	0,99,2,10,0,0,0,0    ;  op 1 eg r3
			.byte   	0,99,2,10,0,0,0,0    ;  op 1 eg r4
			.byte   	0,99,2,10,0,0,0,0    ;  op 1 eg l1
			.byte   	0,99,2,10,0,0,0,0    ;  op 1 eg l2
			.byte   	0,99,2,10,0,0,0,0    ;  op 1 eg l3
			.byte   	0,99,2,10,0,0,0,0    ;  op 1 eg l4
			.byte   	0,99,4,12,0,0,0,0    ;  op 1 bp
			.byte   	0,99,2,10,0,0,0,0    ;  op 1 ld
			.byte   	0,99,2,10,0,0,0,0    ;  op 1 rd
			.byte   	0, 3,2,1,0,0,0,0	 ;  op 1 lc *
			.byte   	0, 3,2,1,0,0,0,0	 ;  op 1 rc *
			.byte   	0, 7,1,1,0,0,0,0	 ;  op 1 kbrt
			.byte   	0, 3,1,1,0,0,0,0	 ;  op 1 ams
			.byte   	0, 7,1,1,0,0,0,0	 ;  op 1 vel
			.byte   	0,99,2,10,0,0,0,0    ;  op 1 level
			.byte   	0, 1,2,1,0,0,0,0	 ;  op 1 mode *
			.byte   	0,31,4,5,0,0,0,0	 ;  op 1 cfq *
			.byte   	0,99,4,10,0,0,0,1    ;  op 1 ffq
			.byte   	0,14,2,1,0,0,0,0	 ;  op 1 dtn *

			.byte   	0,99,2,10,0,0,0,0    ; pitch eg r1
			.byte   	0,99,2,10,0,0,0,0    ; pitch eg r2
			.byte   	0,99,2,10,0,0,0,0    ; pitch eg r3
			.byte   	0,99,2,10,0,0,0,0    ; pitch eg r4
			.byte   	0,99,2,10,0,0,0,0    ; pitch eg l1
			.byte   	0,99,2,10,0,0,0,0    ; pitch eg l2
			.byte   	0,99,2,10,0,0,0,0    ; pitch eg l3
			.byte   	0,99,2,10,0,0,0,0    ; pitch eg l4
			.byte   	0,31,2,5,0,0,0,0	; alg
			.byte   	0, 7,1,1,0,0,0,0	; fb
			.byte   	0, 1,3,1,0,0,0,0	; op sync   *
			.byte   	0,99,2,10,0,0,0,0    ; lfo speed
			.byte   	0,99,2,10,0,0,0,0    ; lfo delay
			.byte   	0,99,2,10,0,0,0,0    ; lfo pmd
			.byte   	0,99,2,10,0,0,0,0    ; lfo amd
			.byte   	0, 1,3,1,0,0,0,0	; lfo sync  *
			.byte   	0, 5,3,1,0,0,0,0	; lfo wave   *
			.byte   	0, 7,1,1,0,0,0,0	; lfo pms
			.byte   	0,48,3,12,0,0,0,0    ; transpose   *
			.byte   	0, 1,3,1,0,0,0,0	; mono/poly 	*
			.byte   	0,12,2,1,0,0,0,0	; pb range
			.byte   	0,12,2,1,0,0,0,0	; pb step
			.byte   	0, 1,10,1,0,0,0,0   ; port mode *
			.byte   	0, 1,3,1,0,0,0,0	; gliss *
			.byte   	0,99,2,10,0,0,0,0    ; port time
			.byte   	0,99,2,10,0,0,0,0    ; mw range
			.byte   	0, 7,3,1,0,0,0,0	; mw assign *
			.byte   	0,99,2,10,0,0,0,0    ; fc range
			.byte   	0, 7,3,1,0,0,0,0	; fc assign *
			.byte   	0,99,2,10,0,0,0,0    ; bc range
			.byte   	0, 7,3,1,0,0,0,0	; bc assign *
			.byte   	0,99,2,10,0,0,0,0    ; at range
			.byte   	0, 7,3,1,0,0,0,0	; at assign *

;   text for non-numerical parameter values

val_lrc 	.ascii  	"-L-E+E+L"
val_md  	.ascii  	"FRFF"
val_cfq1	.ascii  	".5 1 2 3 4 5 6 7 8"
	.ascii  "910111213141516171819202122232425262728293031"
val_cfq2	.ascii  	"_...__..___.____"
val_dtn 	.ascii  	"-7-6-5-4-3-2-1 0+1+2+3+4+5+6+7"
val_sync	.ascii  	"off on"
val_wave	.ascii  	"TRI-SW+SWSQRSINS/H"
val_tr  	.ascii  	"C1 C#1D1 D#1E1 F1 F#1G1 G#1A1 A#1B1"
			.ascii  	"C2 C#2D2 D#2E2 F2 F#2G2 G#2A2 A#2B2"
			.ascii  	"C3 C#3D3 D#3E3 F3 F#3G3 G#3A3 A#3B3"
			.ascii  	"C4 C#4D4 D#4E4 F4 F#4G4 G#4A4 A#4B4 C5 "
val_prt1	.ascii  	"FINGERED  FULL-TIME "
val_prt2	.ascii  	"KEY-RETAINKEY-FOLLOW"
val_mw  	.ascii  	" X   P A  APE  E PEA EAP"
val_bp  .ascii  "A -1A#-1B -1C 0 C#0 D 0 D#0 E 0 F 0 F#0 G 0 G#0 A 0 A#0 B 0"
		.ascii  "C 1 C#1 D 1 D#1 E 1 F 1 F#1 G 1 G#1 A 1 A#1 B 1"
		.ascii  "C 2 C#2 D 2 D#2 E 2 F 2 F#2 G 2 G#2 A 2 A#2 B 2"
		.ascii  "C 3 C#3 D 3 D#3 E 3 F 3 F#3 G 3 G#3 A 3 A#3 B 3"
		.ascii  "C 4 C#4 D 4 D#4 E 4 F 4 F#4 G 4 G#4 A 4 A#4 B 4"
		.ascii  "C 5 C#5 D 5 D#5 E 5 F 5 F#5 G 5 G#5 A 5 A#5 B 5"
		.ascii  "C 6 C#6 D 6 D#6 E 6 F 6 F#6 G 6 G#6 A 6 A#6 B 6"
		.ascii  "C 7 C#7 D 7 D#7 E 7 F 7 F#7 G 7 G#7 A 7 A#7 B 7 C 8"
