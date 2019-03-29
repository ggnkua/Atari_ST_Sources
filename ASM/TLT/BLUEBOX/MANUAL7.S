TSC Multi-Frequency Dialer v7.1 - The Bluebox Program for Atari ST/STE.
=======================================================================

Yeah, we finally made it!!!! Zaphod Beeblebrox of Omnichron is proud to
present you version v7.1 of The Syndicate Multi-Frequency Dialer. In diz
version, you've got everything you ever wanted, even the possibility to
define break frequencies and timing for new countries, with possibility
to save config for 40 countries, timing in step of 5 ms..... The BRK
screen doesn't need much explanation, just remember that you *MUST*
enter FOUR digits ALWAYS. I.e 200 is 0200 and 20 is 0020 and so on, coz
the ASCII to HEX converter routine will fuckup if you enter anything
else than four digits. The countryname can be 15 letters long......
The rest is up 2 you, call any of our HQ's if u need help.... But if
you're not in the ST elite, then fuck off and don't bother me......
Version v7.1 of the MF dialer can handle DTMF "Touch Tone" dialing,
CCITT #4, CCITT Systems #5 and CCITT #5 -R2-. CCITT #5 is the most widely
used system for trunkline signalling, but as some places might employ
older systems, I included CCITT #4 as well. The MF v7.1 can also handle
the tones used by some payfones in US and Denmark (They sure as hell work
in more countries, but I know fer sure that they DO work in US and
Denmark!!). At the back of this file I will list all the frequencies
used in TSC MF Dialer v7.1........ v7.1 also has GEM-fileselector support
and capability to send an Hayes AT answer sequence to the modem at the
baudrate used when you enetered the MF dialer. In order to use that
function, you will have to use this setup in the modems nonvoilatile
memory (if u don't know what that is, read your manual!!!). If you
use this sequence, the modem will work great for connecting to most
US boards and other cool plazes. The Syndicate rulez. I have now recieved
my US Robotics 14400 HST/V42bis, and we ARE BACK IN BUSINESS!!!!!!
Beeblebrox Industries Unlimited - The Cutting Edge of phreaking/hacking
on the ST/STE in Sweden!!!! Sorry for having to release a new version soo
soon, but I forgot to reset the STE dma, and it might give strange results
if ya used the DMA sound before you ran TSC MF dialer. But that's fixed now,
as well as the missing parts of diz manual.....

	AT&C1
	ATX3
	ATB1
	AT&D2
	AT&G2
	AT&W

First of all, mega-fuckings to the lamer who spread the earlier version
of this program, that's why this much-better version is released at all,
coz I thought that if someone was going to spread it, I might as well do
it myself!!!!! Here's a short preface of the commands in TSC MF v7.1:

	
	Keyboard codez for Whitebox DTMF mode:
	======================================

	0-9, * and # - Normal numbers to dial on normal fones.
	ABCD - Silverbox/Whitebox tones, don't know what they're for.


	Keyboard codez for CCITT v4 mode:
	=================================

	0-9 - Normal Digits for Fone Numbers.
	A - KP1
	B - KP2
	C - ST (End of Pulsing).
	D - Code 11
	E - Code 12
	F - Space I
	G - Space II
	H - DHLS
	I - Ihes (Incomming Call Half-Echo Supressor).
	L - Clear Forward
	M - Xfer Forward


	Keyboard codez for CCITT v5/R1 & v5 -R2- mode:
	==============================================

	A - KP1 (KP2E in -R2-)
	B - KP2
	C - ST
	D - Code 11
	E - Code 12
	H - DHLS
	/ - 60 ms pause.
	T - Seize trunkline.
	0-9 - Normal digits for fone numbers.


	Additional tones for Redbox & Greenbox: (In Redbox & Greenbox mode!).
	=====================================================================

	Greenbox Tones:
	===============

	A - Alert MF Detectors.
	C - Coin Collect.
	R - Coin Return.
	B - Ringback.

	Redbox Tones:
	=============

	N - Nickel
	D - Dime
	Q - Quarter
	
	
	The Function key commands in TSC MF Dialer v7.1.
	================================================
	
	 F1 - Redial Last number entered manually with F3.
	 F2 - Dials the number highlighted in the dial directory,
	      using the dial method selected with F4 or F5.
	     
	 F3 - Enter number to dial manually. The method used is the
	      last one selected with F4 & F5.
	     
	 F4 - Step forward in the tone tables.
	 F5 - Step backward in the tone tables.
	 F6 - Enter a new number in the dial directory. First enter 
	     the normal routing as if you were calling normally. Then
	     enter the Bluebox tones in this format:
	     TB+COUNTRY+0+AREA+NUMBER+ST+DHLS. If you're dialing in the
	     same country as the seized trunkline, use a KP1 instead of
	     KP2, in other words, substitute the "B" for an "A".

	 F7 - Delete entry from dial directory.
	 F8 - Load dial-directory.
	 F9 - Save dial-directory.
        F10 - Enable loaded STE Custom dialing set.
	ESC - Quit program.

   Shift-F1 - Redial last manual number without break tones.
   Shift-F2 - Dial higlighted number in the dial directory
              using tones selected with F4 & F5 without break tones.

	Tab - Enter Break Frequency Construction Kit.
  Backspace - Enter tone Q/W Timing Editor.
     Insert - Go Forward in Break Frequency List.
   Clr Home - Go Backwards in Break Frequency List.
       Undo - Enter mini-terminal.
       Help - Send ATD command to modem at current baudrate.
          + - Raise volume.
          - - Lower volume.
          * - Toggle Pink Noise On/OFF. (May disturb anti BB filters!!).
          Z - Send break tone #1 manually.
          X - Send break tone #2 manually.

List of frequencies used in TSC MF Dialer v7.1:
===============================================

Here is a complete list of all frequencies used for the different signal
systems used in the TSC MF Dialer v7.1. Here's a list of what the different
columns are for: 

	1. YM2149 Freq. register channel 1 low byte.
	2. YM2149 Freq. register channel 1 high byte.
	3. YM2149 Freq. register channel 2 low byte.
	4. YM2149 Freq. register channel 2 high byte.
	5. Tone duration, how long the freq. is. (Offset in table!!).
	6. Length of silence period until next tone.
	7. Number of times to repeat tone -1 (DBRA LOOP).
	8. End-of Signal Marker.


                 1  2  3  4  5   6  7
		=== = === = === === ==
whitetab:
	dc.b	'Whitebox DTMF.     ',0
	dc.b	094,0,133,0,000,001,00,-1	; 0941 Hz & 1336 Hz = 0
 	dc.b	103,0,179,0,000,001,00,-1	; 0697 Hz & 1209 Hz = 1
	dc.b	094,0,179,0,000,001,00,-1	; 0697 Hz & 1336 Hz = 2
	dc.b	085,0,179,0,000,001,00,-1	; 0697 Hz & 1477 Hz = 3
	dc.b	103,0,162,0,000,001,00,-1	; 0770 Hz & 1209 Hz = 4	
	dc.b	094,0,162,0,000,001,00,-1	; 0770 Hz & 1336 Hz = 5
	dc.b	085,0,162,0,000,001,00,-1	; 0770 Hz & 1477 Hz = 6
	dc.b	103,0,147,0,000,001,00,-1	; 0852 Hz & 1209 Hz = 7
	dc.b	094,0,147,0,000,001,00,-1	; 0852 Hz & 1336 Hz = 8
	dc.b	085,0,147,0,000,001,00,-1	; 0852 Hz & 1477 Hz = 9
	dc.b	103,0,133,0,000,001,00,-1	; 0941 Hz & 1209 Hz = *
	dc.b	085,0,133,0,000,001,00,-1	; 0941 Hz & 1477 Hz = #
	dc.b	076,0,179,0,000,001,00,-1	; 0697 Hz & 1644 Hz = A
	dc.b	076,0,162,0,000,001,00,-1	; 0770 Hz & 1644 Hz = B
	dc.b	076,0,147,0,000,001,00,-1	; 0852 Hz & 1644 Hz = C
	dc.b	076,0,133,0,000,001,00,-1	; 0941 Hz & 1644 Hz = D

ccittv4:
	dc.b	'Bluebox CCITT #4.  ',0
	dc.b	061,0,000,0,018,019,00,052,0,000,0,018,019,00,061,0,000,0,018,019,00,052,0,000,0,018,019,00,-1 ; = 0
	dc.b	052,0,000,0,018,019,00,052,0,000,0,018,019,00,052,0,000,0,018,019,00,061,0,000,0,018,019,00,-1 ; = 1
	dc.b	052,0,000,0,018,019,00,052,0,000,0,018,019,00,061,0,000,0,018,019,00,052,0,000,0,018,019,00,-1 ; = 2
	dc.b	052,0,000,0,018,019,00,052,0,000,0,018,019,00,061,0,000,0,018,019,00,061,0,000,0,018,019,00,-1 ; = 3
	dc.b	052,0,000,0,018,019,00,061,0,000,0,018,019,00,052,0,000,0,018,019,00,052,0,000,0,018,019,00,-1 ; = 4
	dc.b	052,0,000,0,018,019,00,061,0,000,0,018,019,00,052,0,000,0,018,019,00,061,0,000,0,018,019,00,-1 ; = 5
	dc.b	052,0,000,0,018,019,00,061,0,000,0,018,019,00,061,0,000,0,018,019,00,052,0,000,0,018,019,00,-1 ; = 6
	dc.b	052,0,000,0,018,019,00,061,0,000,0,018,019,00,061,0,000,0,018,019,00,061,0,000,0,018,019,00,-1 ; = 7
	dc.b	061,0,000,0,018,019,00,052,0,000,0,018,019,00,052,0,000,0,018,019,00,052,0,000,0,018,019,00,-1 ; = 8
	dc.b	061,0,000,0,018,019,00,052,0,000,0,018,019,00,052,0,000,0,018,019,00,061,0,000,0,018,019,00,-1 ; = 9
	dc.b	061,0,000,0,018,019,00,052,0,000,0,018,019,00,061,0,000,0,018,019,00,061,0,000,0,018,019,00,-1 ; = Code 11 (D).
	dc.b	061,0,000,0,018,019,00,061,0,000,0,018,019,00,052,0,000,0,018,019,00,052,0,000,0,018,019,00,-1 ; = Code 12 (E).
	dc.b	061,0,000,0,018,019,00,061,0,000,0,018,019,00,052,0,000,0,018,019,00,061,0,000,0,018,019,00,-1 ; = Space I (F)
	dc.b	061,0,000,0,018,019,00,061,0,000,0,018,019,00,061,0,000,0,018,019,00,052,0,000,0,018,019,00,-1 ; = Ihes (I).
	dc.b	052,0,000,0,018,019,00,052,0,000,0,018,019,00,052,0,000,0,018,019,00,052,0,000,0,018,019,00,-1 ; = Space II (G).
	dc.b	061,0,000,0,018,019,00,061,0,000,0,018,019,00,061,0,000,0,018,019,00,061,0,000,0,018,019,00,-1 ; = E.O.P (C).
	dc.b	061,0,052,0,012,013,00,061,0,000,0,014,015,00,-1					   ; = KP1 (A).
	dc.b	061,0,052,0,012,013,00,052,0,000,0,014,015,00,-1					   ; = KP2 (B).
	dc.b	061,0,052,0,012,013,00,061,0,000,0,016,017,00,-1					   ; = Clear Forward (L).
	dc.b	061,0,052,0,012,013,00,052,0,000,0,016,017,00,-1					   ; = Xfer Forward (M).
	dc.b	068,0,000,0,010,011,00,-1								   ; = DHLS (H).
	
ccittv5:
	dc.b	'Bluebox CCITT #5.  ',0
	dc.b	096,0,083,0,004,005,00,-1	; 1300 Hz & 1500 Hz = 0
 	dc.b	179,0,139,0,004,005,00,-1	; 0700 Hz & 0900 Hz = 1
	dc.b	179,0,114,0,004,005,00,-1	; 0700 Hz & 1100 Hz = 2
	dc.b	139,0,114,0,004,005,00,-1	; 0900 Hz & 1100 Hz = 3
	dc.b	179,0,096,0,004,005,00,-1	; 0700 Hz & 1300 Hz = 4	
	dc.b	139,0,096,0,004,005,00,-1	; 0900 Hz & 1300 Hz = 5
	dc.b	114,0,096,0,004,005,00,-1	; 1100 Hz & 1300 Hz = 6
	dc.b	179,0,083,0,004,005,00,-1	; 0700 Hz & 1500 Hz = 7
	dc.b	139,0,083,0,004,005,00,-1	; 0900 Hz & 1500 Hz = 8
	dc.b	114,0,083,0,004,005,00,-1	; 1100 Hz & 1500 Hz = 9
	dc.b	179,0,074,0,002,003,00,-1	; 0700 Hz & 1700 Hz = C.11 (D)
	dc.b	139,0,074,0,002,003,00,-1	; 0900 Hz & 1700 Hz = C.12 (E)
	dc.b	114,0,074,0,002,003,00,-1	; 1100 Hz & 1700 Hz = KP1 (A)
        dc.b	096,0,074,0,002,003,00,-1	; 1300 Hz & 1700 Hz = KP2 (B)
	dc.b	083,0,074,0,002,003,00,-1	; 1500 Hz & 1700 Hz = ST (C)
	dc.b	068,0,000,0,010,011,00,-1	; 1850 Hz = Disable Hold (H)

ccittv52:
	dc.b	'Bluebox CCITT #5 R2',0
	dc.b	072,0,067,0,008,009,00,-1	; 1740 Hz & 1860 Hz = 0
 	dc.b	091,0,083,0,008,009,00,-1	; 1380 Hz & 1500 Hz = 1
	dc.b	091,0,077,0,008,009,00,-1	; 1380 Hz & 1620 Hz = 2
	dc.b	083,0,077,0,008,009,00,-1	; 1500 Hz & 1620 Hz = 3
	dc.b	091,0,072,0,008,009,00,-1	; 1380 Hz & 1740 Hz = 4	
	dc.b	063,0,072,0,008,009,00,-1	; 1980 Hz & 1740 Hz = 5
	dc.b	077,0,072,0,008,009,00,-1	; 1620 Hz & 1740 Hz = 6
	dc.b	091,0,067,0,008,009,00,-1	; 1380 Hz & 1860 Hz = 7
	dc.b	083,0,067,0,008,009,00,-1	; 1500 Hz & 1860 Hz = 8
	dc.b	077,0,067,0,008,009,00,-1	; 1620 Hz & 1860 Hz = 9
	dc.b	091,0,063,0,006,007,00,-1	; 1380 Hz & 1980 Hz = KP2E (A)
        dc.b	083,0,063,0,006,007,00,-1	; 1500 Hz & 1980 Hz = KP2  (B)
	dc.b	067,0,063,0,006,007,00,-1	; 1860 Hz & 1980 Hz = ST (C)
	dc.b	068,0,000,0,010,011,00,-1	; 1850 Hz = Disable Hold (H)

rgtab:
	dc.b	'Redbox & Greenbox. ',0
	dc.b	057,0,074,0,012,007,00,-1	; 2200 Hz & 1700 Hz = Nickle (N)
	dc.b	057,0,074,0,012,012,01,-1	; 2200 Hz & 1700 Hz = Dime (D)
	dc.b	057,0,074,0,006,006,04,-1	; 2200 Hz & 1700 Hz = Quarter (Q)
	dc.b	139,0,083,0,017,007,00,-1	; 0900 Hz & 1500 Hz = MF Alert. (A)
	dc.b	179,0,114,0,179,007,00,-1	; 0700 Hz & 1100 Hz = Coin Collect. (C)
	dc.b	114,0,074,0,179,007,00,-1	; 1100 Hz & 1700 Hz = Coin Return. (R)
	dc.b	179,0,074,0,179,007,00,-1	; 0700 Hz & 1700 Hz = Ringback. (B)

breaktab:
	dc.b	'Nippon         ',0
	dc.b	052,0,048,0,23,119	; Nippon Break Tones. (CCITT #5).
	dc.b	052,0,000,0,23,119	; 2400 & 2600 Hz, 120 ms.
					; Pause 600 ms, 2400 Hz, 120 ms.

	dc.b	'United States  ',0
	dc.b	052,0,048,0,35,07	; U.S.A Break Tones. (CCITT #5).
	dc.b	052,0,000,0,15,119	; 2400 & 2600 Hz, 180 ms.
					; 2400 Hz, 80 ms.

How to create STE dialing sets & break frequencies:
===================================================

As you've probably already seen, there are two other programs coming with
MF v7.1. CALCBRK2.PRG and CALAC_SPL.PRG. These are for making your own
dialing sets and STE break configurations. Do not try these if you do not
know what you are up to, this is for advanced users only. But here is how
they work anyway. When you first load any of these proggys, you will be
prompted to enter base frequency. The STE has 4 base frequencies, below
is a list of what they are, and their corresponding DMA speed values.
(You will require these when compiling the break freq files later on!!).

STE Sample Speed:       DMA Value:         Max Freq:
-----------------       ----------         ---------
    6258 Hz               128+0             6258/2
   12517 Hz               128+1             12517/2
   25033 Hz               128+2             25033/2
   50066 Hz               128+3             50066/2

After that, you have to choose the frequencies you want to have in that
sample. The freqs may now be highter than the base-freq/2, or else you'll
end up loosing accuracy... If you just want one freq, enter the same freq 
on both prompts. Then you have to enter the length of the sample in milli-
seconds. Then it will save two files, with the extensions .CLR and .XFR
That's because the first beep is called "clear forward" and the second one
"xfer forward". Then you load up the source for compiling break freqs and
enter the data required and then simply assemble & run to save your new STE
break frequencies. If you're compiling a new dialling set, then simply
calculate all the samples with the other proggy, and load the other source.
Enter all the data & assembler and run, and there you are...

You move around in the dial directory with the arrowkeys. Up'n Down 
moves one step at a time, while left & Right moves ten steps a time.
That was all about the functionkeys. I hope you find this program useful.
I accept no responsibility for the use of this program, it was written
entirely for educational purposes, and is not intended for actual use.
It's up to you whatever you do...... After all, all it does is produce
two-note tones.... HAHAHAHHA!!!!! Oh yes, you can send any of the tones
by pressing the appropriate keyboard key as well, so you kan dial with
the keypad or number keys if you like, fun eh????? Well, I think this 
is good enough for a manual, if ya wanna know more, contact me on any
of these BBS's:

	Eagles Nest BBS		+46-18-262804		<TSC WHQ>
	Shire BBS		+1-567-867-5654		<TSC US HQ 1>
	Happy Hideaway BBS      +1-813-596-4999		<TSC US HQ 2>
	NaStY dReAmS		+46-410-15313		<COOL BOARD!>
	X-Factor BBS            +45-31783283		<COOL BOARD!>
        Arctic Glace BBS        +45-65303724		<COOL BOARD!>
        Lynx BBS                +46-8-6003456		<LYNX WHQ>
	Frontier BBS		+46-18-241690		<COOL BOARD!>
	Red Dwarf BBS		+46-21-55239		<UNIT 17 WHQ>
	Pumpa Satan BBS		+46-451-91002		<SYNC WHQ>
	Someware BBS		+46-291-10992		<TRANCEATION WHQ>

The story of The Syndicate MF Dialer:
=====================================

In the end of the summer '91, when I was at vaccation in the southern parts
of Sweden, I got a call from Illegal Exception. He told me that some Amiga
guy in Uppsala was calling for free using some strange program that sent
tones through the fone line. It was not the first time that I've heard of
blueboxing, but before that, I thought it was only possible for people
in Usa for example. This made me start coding on the first BB, which only
had the capability of breaking the line (The line says <BEEP-KERCHUNK>).
But soon, we got things working the way the were supposed to, and since then
the TSC MF Dialer has been the most advanced bluebox on the ST scene. (I do
not know of any other BB that's more advanced, not on the ST anyway!!).
	
Some personal greetz must go to the following people/groups:
============================================================

Guru Josh 		(For writing such nice texts about blueboxing, it's
           		actually because of your files, that I started coding
			this fab BB on the ST/STE/TT.

Sync			(Se upp f”r den gr”na gnun som s„ger m„„„„!!!!
			Also thanx a lot for the help with explaining how to
			calculate the STE samples for the dialer!!!).

Agression		(Hey Xenith, thanx for the STE check info!!!).

UNC			(Especially Qwerty & WizTom!!).

Delta Force		(Hi Daniel........).

TEX			(How are things in Germany, Daryl????? Hope Viking X
			brings this to ya quick.......).

Respectables		(Hope to see ya on the Electra Party, it was quite nice
			when we boxed at the Haninge party (TCB/2LC).

Illegal Exception/SOTE 	(For helping me to beta-test the first versions
			and of course greetz to the rest of SOTE for being
			such a nice bunch of cool guys!!).

TCB			(Any new "tjofr„ser", Anders???).

Nacho Gonzalez		(Really nice to talk to ya, have u got any handle?).

The Fone Company	(For sending those large bills.... :-) :-) :-(

Some big bad fuckings must go to the following lamers:
======================================================

The Pirate of G.R.C 	(He ripped my soundtables to make a lame Bluebox!!).

Mr. Thompson/Triple H	(You are so fucking lame, always when Mr. Terry raises
			my level at your BBS, you go and restore it, drop
			dead, you punk!!!!).

If you're not in the list, please do forgive me, because I'm writing this
in a great hurry. If you wanna contact me, the address is below.......
Greetings to everyone I know!!!!! This will probably cause total anarchy
in telecommunication, but who cares, ANARCHY RULES!!!!
Eagles Nest is now up and going strong again. The fone # is as always
+46-18-262804, and 300-14400 HST...... The current system pw is:
///SESAM24/// but that is subject to monthly change, the 1:st of each month
it will be changed, to prevent lamers from gaining access..... If ya wanna
get in touch with me, call the board or write to:

		Beeblebrox Industries Unlimited.
		C/O Carl Andersson
		Liggargatan 5J
		754 20 Uppsala
		Sweden

Be sure to include some references that can validate you, and yar complete
snailmail adress & fone #'s. (And of course International reply Coupons, or
if you live in Sweden, stamps for me to return your letter!!!).

Greetz, Zaphod/ONC/TSC.
