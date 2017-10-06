********************************************
**   STOS MAESTRO Extension Source code   **
**                                        **
**  (C)  New Dimensions / Mandarin  1989  **
**                                        **
**    Written By Jon Wheatman,  11/2/89   **
******************************************** LAST MOD:20/3/89
 
* Thank you for your listing and be sure I'll never show it
* to anybody (as for you with Stos basic!)
* I corrected the errors and title messages, please copy them 
* to your extenstion .EXD file.


******* You can take off all the "dummy" key word from your list
* but do not take them off the JUMP list!
        dc.b $80                	;Important!
tokens: dc.b "sound init",$80       	;EVEN tokens are INSTRUCTIONS
	dc.b "sample",$81
	dc.b "samplay",$82
	dc.b "samplace",$83
	dc.b "samspeed manual",$84
	dc.b "samspeed auto",$86
	dc.b "samspeed",$88 
	dc.b "samstop",$8a
	dc.b "samloop off",$8c
	dc.b "samloop on",$8e
	dc.b "samdir forward",$90
	dc.b "samdir backward",$92
	dc.b "samsweep on",$94
	dc.b "samsweep off",$96
	dc.b "samraw",$98
	dc.b "samrecord",$9a
	dc.b "samcopy",$9c
	dc.b "sammusic",$9e
	dc.b "samthru",$a0
	dc.b "sambank",$a2
	dc.b 0                  ;END of the table

welcome:dc.b 10,"STOS Maestro Commands Installed V2",0
        dc.b 10,"STOS Maestro V2 Install‚",0
        dc.b 0

myerrors:
	dc.b "Memory Bank does not contain sample data",0
	dc.b "Cette banque ne contient pas de donn‚es digitalis‚es",0
	dc.b "Sample not found in bank",0
	dc.b "Son digitalis‚ introuvable dans cette banque",0
	dc.b "Sample rate out of range ( 5 - 22 Khz )",0
	dc.b "Frequence d'‚chantillonage hors normes ( 5 - 22 Khz )",0
	dc.b "Sample does not contain its play speed",0
	dc.b "Le son digitalis‚ n'inclus pas sa fr‚quence",0
	dc.b "End address must be higher than start address",0
	dc.b "L'adresse de fin doit etre sup‚rieure a celle de d‚but",0
	DC.B "Memory bank out of range",0
	dc.b "Mauvais num‚ro de banque",0 

