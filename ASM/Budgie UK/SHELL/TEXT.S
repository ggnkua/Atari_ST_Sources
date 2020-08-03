* this source file CANNOT be assembled on its own.
* it is merely part of 'shell.s' which calls it.
high_scores 
	DC.W 28,26,24,12,10,8,6,4  \to skip,adda.w 16
	DC.W 0,1,2,3,4,5,6,7 \to skip, adda.w 16
	DC.B "JACK KNIFE...",10,13,0
	DC.B "CLIVE CLUTCH.",10,13,0
	DC.B "ERIC BODGE...",10,13,0
	DC.B "PETER PIT....",10,13,0
	DC.B "FLAT TYRE....",10,13,0
	DC.B "BOB CARR.....",10,13,0
	DC.B "PAUL POSITION",10,13,0
	DC.B "SHARP BEND...",10,13,0 
	dc.b ".............",10,13,0
hi_160	ds.b 400
	DC.B 0 end of table	next section was overwritten by hi_scores.asc!
	even
rules_1	
	dc.b "             FINAL    LAP       ",13,10
	dc.b "             ------------       ",13,10
	dc.b "Press HELP or F/KEYS any time.          ",10,10,13
	dc.b "To restart a new HI-SCORE table, just   ",10,13
	dc.b "delete the file marked HISCORES.ASC     ",10,13
	dc.b "A new one will be created automatically.",10,13
	dc.b "Alternatively, press F9...              ",10,10,13
	dc.b "This disk is protected against possible ",13,10
	dc.b "viruses.                                ",10,13
	dc.b "The program reads the boot sector at the",10,13
	dc.b "beginning of each game and expects to   ",10,13
	dc.b "find certain bytes (ex: Budgie).        ",10,13
	dc.b "If these bytes are missing, a virus has ",10,13
	dc.b "probably taken hold of the boot sector. ",10,13
	dc.b "Never mind, it will be erradicated      ",10,13
	dc.b "automatically.                          ",10,13
	dc.b "Do not use commercial protectors, as we ",10,13
	dc.b "will merely treat them as another virus.",10,10,13
	dc.b "Happy driving!   ",10,13,0
	
*---------------
the_credits
	dc.b 27,"E",27,"b",7,10,13	
	dc.b "Coding :          Camy Maertens",10,10,13
	dc.b "Thanks to            Simon Rush",10,13
	dc.b "                   Gary Wheaton",10,13
	dc.b "                   Gareth Pople",10,13
	dc.b "              and  Jim Holmwood",10,10,13
	dc.b "      for many useful routines.",10,10,10,13
	dc.b 27,"b",4  was 8
check1	dc.b 189," June   1989         BUDGIE UK",10,13  ****
	dc.b "  All marketing rights         ",10,13
	dc.b "             strictly reserved.",10,10,10,10,10,10,13
	dc.b 27,"b",7
check2	dc.b "        A BUDGIE UK production.",10,13,0 ****
**** leave these check lines alone..particularly the letter B.



source	dc.b 27,"E",27,"b",6,10,13
	dc.b "                               ",10,10,13	
	dc.b "The SHELL is written in Assembler, ",10,13
	dc.b "using",10,13
	dc.b "HISOFT's  DEVPAC 2.",10,10,10,13
	dc.b "Source code available to",10,13
	dc.b "68000 Programmers",10,13
	dc.b "and all Budgie UK members.",10,10,13
	dc.b "       BUDGIE  UK",10,13
	dc.b "5, Minster Close, Rayleigh, Essex, UK",13,10,0



options DC.B 27,"Y",33,32 
	DC.B "F1-F10  Messages",10,13
	dc.b "Help/Enter   HELP",10,13
	dc.b "V       S/W scroll",10,13
	dc.b "H       toggle 50/60 Hz",10,13
	dc.b "P       Pause then press 1-6",10,13
	dc.b "C       Slow motion",10,13
	dc.b "X       Erase screen",10,13
	dc.b "L       Load PI1",10,13
	dc.b "*       Debug",10,13
	dc.b "D       Dump screen",10,13
	dc.b "M       Music   ",10,13
	dc.b "UP/DOWN H/W scroll   ESC  quit",0
	EVEN


cursor_loc10 DC.B 27,"Y",42,32,0  10 down
cursor_loc16 DC.B 27,"Y",48,32,0  16 down
confirm	DC.B 27,"Y",33,32
	dc.b "RESET high scores TABLE",10,10,13
	dc.b 27,"p","  confirm  ",27,"q"," Y/N",10,13,0
prompt	  DC.B 27,"Y",33,32
	dc.b "Load DEGAS file:",10,13
	dc.b "Enter File name",10,13
	dc.b "ex: que*.pi1",10,13,0
	even
*----------*
license
	dc.b "Budgie products are LICENCEWARE.",10,13
	dc.b "--------------------------------",10,10,13
	dc.b "It means that only Licensed Distributors",10,13
	dc.b "are allowed to sell our titles.",10,13
	dc.b "The end user is authorized",10,13
	dc.b "to copy this program or even give",10,13
	dc.b "it away if he wishes.",10,10,13
	dc.b "The price of this Program is pitched",10,13
	dc.b "at or slightly above PD levels.",10,13
	dc.b "Royalties are collected from the",10,13
	dc.b "Licensees and forwarded to all  ",10,13
	dc.b "our authors.",10,10,13
	dc.b "A list of Licensed Distributors",10,13
	dc.b "is available from Budgie UK.",10,10,13
	dc.b "Copyright and full marketing rights",10,13
	dc.b "are held by Budgie UK",10,13,0
	even

stick_forward dc.b "stick forward!",10,13,0
	even

desert_island
	dc.b " Everyone has his own idea as to which",10,13
	dc.b "his all-time favourite games are.",10,13
	dc.b "If I were stranded on a desert island,",10,13
	dc.b "with my computers and a generator,",10,13
	dc.b "(another dumb assumption...)",10,13
	dc.b "these would be my 10 desert island",10,13
	dc.b "disks:",10,10,13,0
desert1	dc.b "International Soccer (C64)",10,13
	dc.b "Last Starfighter (Atari 800)",10,13
	dc.b "Arkanoid (Atari ST)",10,13
	dc.b "Cyclons (C64)",10,13
	dc.b "Leaderboard Executive (C64)",10,13
	dc.b "Flight Simulator II (Atari ST)",10,13
	dc.b "Psion Chess (Atari ST)",10,13
	dc.b "River Raid (Atari 800)",10,13
	dc.b "International Karate + (Atari ST)",10,13
	dc.b "Speed King (C64)",10,10,13,0
desert2	dc.b "Imagine the horror of leaving out",10,13
	dc.b "Boulderdash, Zolyx, Crazy Cars II,",10,13
	dc.b "Buggy Boy, ace, Beach Head, Pitstop II,",10,13
	dc.b "Drop Zone, Snapper, BBC Tennis,etc..",0



mess_1	dc.b "***************",10,13
	dc.b "BUDGIE UK",10,13
	dc.b "5 Minster Close",10,13
	dc.b "Rayleigh  Essex",10,13
	dc.b "SS6 8SF",10,13
	dc.b "United Kingdom",10,13
	dc.b "***************",10,13,0

mess_2	dc.b "     BUDGIE UK ",10,10,13
	dc.b 27,"b",6
	dc.b "    Licenceware ",10,10,13
	dc.b "The fairer face of PD.",10,10,13
	dc.b "------------------------",10,13,0

mess_3	dc.b "BUDGIE UK now accounts for more",10,13
	dc.b "than 55% of the ENTIRE budget",10,13
	dc.b "production on the Atari ST !!!",10,10,13
	dc.b "            ***",10,13
	dc.b "If you have a game you want to share",10,13
	dc.b "with your fellow ST ers, contact",10,13
	dc.b "BUDGIE UK for help, advice and",10,13
	dc.b "exchange of routines.",10,13
	dc.b "More than one hundred machine code",10,13
	dc.b "routines available to members!",10,13
	dc.b "We will particularly favour",10,13
	dc.b "programs written in 68000 code",10,13 
	dc.b "  (NO more STOS PLEASE ....)",10,10,13
	dc.b 27,"b",4
	dc.b ">>ALL AUTHORS RECEIVE ROYALTIES.<<",10,10,13
	dc.b "----------------------------------",10,13,0
