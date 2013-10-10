;An introduction to cracking/68000 (c)1991 Hank of the Diskmap Crew.

;Please read this doc in medium resloution.
;Please read this doc in GENST2.PRG
;Start time 12:18 a.m. 6th August 1991.
;Finish time 03:08 p.m. 7th august 1991. 

;A long while ago the ALIEN of the Pompey Pirates released a breif
;document about hacking particular types of protection on this
;wonderful machine, As with the ALIEN i am totally fed up with people
;asking "How do you crack oringinal sofware ?" - so here is a starters
;guide.

;Question 1:
;Do you know any 68000 assembler ?
;No ? - Buy the ATARI ST internals by abacus books œ25-00 tops.
;Read the paragraphs on the Gemdos,Bios,Xbios & the Exeption vectors
;then return to this document - Believe me it's easy !!.


;Ok you now know about the traps,exeption vectors & the status reg.

;Qestion 2:
;What vector is at address $10 ?
;Answer - Illegal intruction - Were you right ?

;Question 3:
;what is this trap function - 

	clr.l	-(sp)
	move.w	#$20,-(sp)		;function number
	trap	#1
	addq.w	#6,sp

;Answer - Supervisor mode.
;This trap is probabaly the most important out of all the traps as
;you have to enable supervisor mode to access all the hardware and
;the lower end of memory of the ATARI ST.
;Before going into supervisor mode your SR(status register) will be
;at $0300/8300 after it will be $2300/a300 if it is the later you
;are succesfully in super mode.

;Now a bit about the hardware.
;N.B. - all source code documentation in this file has been optom-
;ised with the ".w" on the end of the hardware or low end memory
;address i.e. $ffff8240.w, you may see this registor or any other
;documentated as $ff8240 or $ffff8240, dont panic it's the same reg.
;this optomisation saves 2 bytes on the later 2 examples. The later
;2 are also examples of "Lazy programing".

;The registers:

;	$ffff8240.w			;color 0
;	$ffff8242.w			;color 1
	
;	$ffff825c.w			;color 15
;	$ffff825e.w			;color 16

;These registers form the color pallette as you have probably guesed   
;the next one afer $ffff8242.w would be $ffff8244.w and so on until
;$ffff825e.w - easy ?


;	$ffff820a.w			;sync mode
	move.b	#$00,$ffff820a.w	;60 Hz	(American)
	move.b	#$01,$ffff820a.w	;70 Hz	(mono)
	move.b	#$02,$ffff820a.w	;50 Hz	(British)

;	$ffff8260.w			;resolution
	move.b	#$00,$ffff8260.w	;low res
	move.b	#$01,$ffff8260.w	;med res
	move.b	#$02,$ffff8260.w	;high res

;	$ffff8001.w			;memory config
;don't mess!!

;	$ffff8201.w			;high byte of the srceen addr
;	$ffff8203.w			;low byte of the srceen addr

	move.b	#$07,$ffff8201.w	;screen at
	move.b	#$80,$ffff8203.w	;$78000

;	$fffffc02.w			;the keyboard

	move.b	#$12,$fffffc02.w	;kill mouse
	move.b	#$08,$fffffc02.w	;restore mouse

;you may also see this reg. addressed as:-

	lea	$fffffc00.w,a0		;reg. start in a0
;	move.b	#num,2(a0)		;2+a0 = $fffffc02.w

;	$ffff8800.w			;the psg reg.

	move.b	#$0e,$ffff8800.w	;init psg (disk drive mode)

;when i am looking for a protection i normally search for this addr.

;e.g.:-

	move.w	sr,-(sp)		;save status register
	or.w	#$0700,sr		;$2700 on the sr - kill interupts	
	move.b	#$0e,$ffff8800.w	;init psg
	move.b	$ffff8800.w,d1		;get drive status
	move.b	d1,d2			;save old drive status
	and.b	#$f8,d1			;mask bits
	move.b	d1,$ffff8802.w		;gi select
	move.w	(sp)+,sr		;restore status register
	rts				;return from subroutine

;alernitaly you can address the psg as:

	move.l	#$0e002500,$ffff8800.w	;read side 0 of the disk
	move.l	#$0e002400,$ffff8800.w	;read side 1 of the disk
	move.l	#$0e002700,$ffff8800.w	;de-select (turn off light)

;The MFP interupt registers.

;	$fffffa01.w			;paralell port	
;	$fffffa03.w

;	$fffffa23.w
;	$fffffa25.w

;As with the color pallette regs. these regs. are addressed every
;2 bytes after each other.
;Only a byte may be poked in to each reg. as they are addressed
;on un-even boundaries.  


;Most of the other hardware registers are documented in the Internals
;book.

;Op codes
;When cracking games the program normaly has to be modified using HEX
;here are some of the important HEX equlivelents of thier source code
;counterparts.


;	NOP		$4e71		;no operation
;	ILLEGAL		$4afc		;illegal instruction
;	RTS		$4e75		;return from subroutine
;	RTE		$4e73		;return from exeption
;	MOVEQ #0,D0	$7000		;clr.l	d0!!
;	BRA		$6000		;branch always

;The above instructions are the ones i mostly use when cracking games
;How to modify memory is explaned later in the section on monst2.


;Copy Protections:- (Disk) 
;There are three main types of protections at the moment and they are
;all crap!

;Gremlin Graphics Protection 

	BSR.S	GREM
	CLR.W	-(SP)		;fucnction warmstart
	TRAP	#1


GREM	LEA	$FFFF8604.W,A5
	BSR	LBD66
	MOVEQ	#5,D1
	BSR	LBD76
	MOVEQ	#0,D0
	BSR	LBD3C
	BSR.S	LBCCC
	BSR	LBD28
	MOVE.L	D0,-(A7)
	BSR	LBD66
	MOVEQ	#$4F,D0		;$4f = track 79
	BSR	LBD3C
	BSR.S	LBCCC
	BSR	LBD28
	SUB.L	D0,(A7)
	BSR	LBD66
	CMPI.L	#$3C,(A7)+
	BGT	LBDAE		;BRA HERE TO KILL PROTECTION!!
LBCBE	MOVEQ	#-1,D0
LBCC0	MOVE.W	D0,$FFFF8240.W
	DBF	D0,LBCC0
	BRA.S	LBCBE
LBCCC	BSR.S	LBD06
	BSR	LBD9A
	MOVE.W	#$90,2(A5)
	MOVE.W	#$190,2(A5)
	MOVE.W	#$90,2(A5)
	BSR.S	LBD20
	MOVE.W	#$1F,(A5)
	BSR.S	LBD20
	MOVE.W	#$80,2(A5)
	BSR.S	LBD20
	MOVE.W	#$E4,(A5)
	BSR.S	LBD20
LBCFA	BTST	#5,$FFFFFA01.W
	BNE.S	LBCFA
	RTS
LBD06	MOVE.W	#$1F40,D1
LBD0A	DBF	D1,LBD0A
	RTS
LBD10	MOVE.W	#$80,2(A5)
	BSR.S	LBD20
	MOVE.W	(A5),D1
	BRA.S	LBD20
LBD1C	BSR.S	LBD20
	MOVE.W	D0,(A5)
LBD20	MOVEQ	#$24,D4
LBD22	DBF	D4,LBD22
	RTS
LBD28	MOVEQ	#0,D0
	MOVE.B	5(A5),D0
	SWAP	D0
	MOVE.B	7(A5),D0
	LSL.W	#8,D0
	MOVE.B	9(A5),D0
	RTS
LBD3C	BSR.S	LBD06
	MOVE.W	#$86,2(A5)
	BSR.S	LBD1C
	MOVEQ	#$10,D0
	MOVE.W	#$80,2(A5)
	BSR.S	LBD1C
	MOVE.L	#$60000,D3
LBD56	SUBQ.L	#1,D3
	BEQ	LBCBE
	BTST	#5,$FFFFFA01.W
	BNE.S	LBD56
LBD66	MOVE.W	#$64,D0
LBD6A	BSR.S	LBD06
	DBF	D0,LBD6A
	BSR	LBD10
	RTS
LBD76	MOVE	SR,-(A7)
	ORI.W	#$700,SR
	MOVE.B	#$E,$FFFF8800.W
	MOVE.B	$FFFF8800.W,D0
	ANDI.B	#$F8,D0
	OR.B	D1,D0
	MOVE.B	D0,$FFFF8802.W
	MOVE.W	(A7)+,SR
	RTS
LBD9A	MOVE.B	#0,9(A5)
	MOVE.B	#$80,7(A5)
	MOVE.B	#7,5(A5)
	RTS
LBDAE	MOVEQ	#7,D1
	BSR	LBD76
	RTS


;The above protection can removed several ways.
;e.g. 1 - find the following line in the source code 
;CMP.L	#$3C,(A7)+, now the next line should be BGT
;the opcode for this instruction is $6E00 (BGT) replace
;the $6E00 with $6000 (BRA) - it's now cracked.

;e.g. 2 - Simply put an RTS ($4E75) on the first line of
;the protection (LEA $FFFF8604.W,A5) doing this is better
;as the protection is never run.
;N.B. before using this methord make sure that the protection
;is actually in a sub-routine (JSR) or (BSR) if not only use
;example 1 

;e.g. 3 - Relplace the BSR.S PROT with NOP NOP ($4E71$4E71)
;it has the same effects as above but check the rest of the
;code as a protection can be called from more than one place.

;The above source listing was taken from impossamole - try it.


;Protoscan II Protection

LOOP	BSR.S	PROT
	TST.B	D0		;Original
	BNE.S	LOOP		;No try again
	CLR.W	-(SP)		;Function warmstart
	TRAP	#1		;and return to desktop


PROT	LEA	$63000,A0	;Buffer
	MOVE.L	A0,$7079E
	MOVEQ	#1,D3
L7054C	MOVE.L	D3,$707A2
	BSR	L70776
	BSR.S	L70582
	BSR.S	L705B8
	BSR.S	L705CE
	BSR	L7060E
	BSR	L7060E
	BSR.S	L705B8
	BSR	L706CA
	BSR	L7073A
	MOVE.B	$707A6,D0
	TST.B	D0
	BEQ.S	L70580
	MOVE.L	$707A2,D3
	DBF	D3,L7054C
L7057E	BRA.S	L7057E
L70580	RTS
L70582	MOVE.W	#0,D0
	ADDQ.B	#1,D0
	LSL.B	#1,D0
	ORI.W	#0,D0
	EORI.B	#7,D0
	ANDI.B	#7,D0
L70596	MOVE.B	#7,$FFFF8800.W
	MOVE.B	#$FF,$FFFF8802.W
	MOVE.B	#$E,$FFFF8800.W
	MOVE.B	$FFFF8800.W,D1
	ANDI.B	#$F8,D1
	OR.B	D0,D1
	MOVE.B	D1,$FFFF8802.W
	RTS
L705B8	MOVE.W	#$80,$FFFF8606.W
	MOVE.W	#$D0,D6
	BSR	L706E0
	MOVEQ	#$28,D7
	BSR	L706DA
	RTS
L705CE	BSR	L706FE
	MOVE.W	#$86,$FFFF8606.W
	MOVE.W	#$4F,D6
	BSR	L706E0
	MOVE.W	#$80,$FFFF8606.W
	MOVE.W	#$1B,D6
	BSR	L706E0
	MOVE.L	#$60000,D7
L705F4	SUBQ.L	#1,D7
	BEQ.S	L70602
	BTST	#5,$FFFFFA01.W
	BNE.S	L705F4
	RTS
L70602	BRA.S	L705CE
	MOVE.W	#$FFF9,$707A6
	RTS
L7060E	CLR.L	$70796
	MOVE	SR,L7078C
	MOVE.W	#$90,$FFFF8606.W
	MOVE.W	#$190,$FFFF8606.W
	MOVE.W	#$90,$FFFF8606.W
	MOVEQ	#$16,D6
	MOVE.W	#$200,D2
	MULU	D6,D2
	MOVE.W	D2,L7078E
	MOVE.L	$7079E,D3
	ADD.L	D3,D2
	MOVE.L	D2,L70792
	BSR	L706E0
	MOVE.L	$7079E,D0
	MOVE.B	D0,$FFFF860D.W
	LSR.L	#8,D0
	MOVE.B	D0,$FFFF860B.W
	LSR.L	#8,D0
	MOVE.B	D0,$FFFF8609.W
	MOVE.W	#$80,$FFFF8606.W
	MOVE.W	#$E8,D6
	BSR.S	L706E0
	MOVE.L	#$50000,D7
	MOVEA.L	L70792(PC),A5
	MOVE.W	#$200,D0
L70678	DBF	D0,L70678
L7067C	BTST	#5,$FFFFFA01.W
	BEQ.S	L706A6
	SUBQ.L	#1,D7
	BEQ.S	L706C4
	MOVE.B	$FFFF8609.W,L70797
	MOVE.B	$FFFF860B.W,L70798
	MOVE.B	$FFFF860D.W,L70799
	CMPA.L	L70796,A5
	BGT.S	L7067C
L706A6	MOVE.W	#$90,$FFFF8606.W
	MOVE.W	$FFFF8606.W,D5
	MOVE.W	D5,L70790
	BTST	#0,D5
	BEQ.S	L706C4
	MOVE.W	#$80,$FFFF8606.W
	BSR.S	L7072C
L706C4	MOVE.W	L7078C(PC),SR
	RTS
L706CA	MOVE.W	#$80,$FFFF8606.W
	MOVE.B	#7,D0
	BSR	L70596
	RTS
L706DA	DBF	D7,L706DA
	RTS
L706E0	BSR.S	L706EE
	MOVE.W	D6,$FFFF8604.W
	BSR.S	L706EE
	RTS
	MOVE.W	$FFFF8604.W,D3
L706EE	MOVE	SR,-(A7)
	MOVE.W	D7,-(A7)
	MOVEQ	#$28,D7
L706F4	DBF	D7,L706F4
	MOVE.W	(A7)+,D7
	MOVE.W	(A7)+,SR
	RTS
L706FE	MOVE.W	L7079A,D6
	ANDI.W	#3,D6
	MOVE.L	#$50000,D7
	MOVE.W	#$80,$FFFF8606.W
	BSR.S	L706E0
L70714	SUBQ.L	#1,D7
	BEQ.S	L70722
	BTST	#5,$FFFFFA01.W
	BNE.S	L70714
	RTS
L70722	MOVE.B	#$F9,$707A6
	RTS
L7072C	BSR.S	L706EE
	MOVE.W	$FFFF8604.W,$7079C
	BSR.S	L706EE
	RTS
L7073A	MOVE.L	$7079E,D1
	ADDI.L	#$2EE0,D1
	MOVEA.L	D1,A0
	MOVE.L	#$DAC,D3
	MOVEQ	#0,D2
	MOVE.W	-(A0),D5
L70750	MOVE.W	-(A0),D0
	CMP.W	D0,D5
	BNE.S	L7075E
	ADDQ.L	#2,D2
	DBF	D3,L70750
	BRA.S	L7076E
L7075E	SUBI.L	#$170C,D2
	BMI.S	L7076E
	CLR.B	$707A6
	RTS
L7076E	ST	$707A6
	RTS
L70776	MOVE.L	#$176F,D2
	MOVEA.L	$7079E,A0
	MOVE.L	$4BA.W,D3
L70784	MOVE.W	D3,(A0)+
	DBF	D2,L70784
	RTS
L7078C	DC.L	0
L7078E	DC.L	0
L70790	DC.L	0
L70792	DC.L	0
L70796	DC.L	0
L70797	DC.L	0
L70798	ORI.B	#3,D0
L70799	DC.L	0
L7079A	DC.L	0 



;To remove a Protoscan protection all you have to do is type MOVEQ #0,D0
;RTS ($70004E75) you need the moveq so that D0 is equil (0) when it returns
;from the protection as most of them do a TST.B D0 see above example.


;Here is a brief list of games you will find this protection in:

;The Untouchables
;Postman Pat
;Ninja Warriors
;Continental Curcus
;Where Time Stood Still


;Rob Northern Protection(internal)

;This one is probably the hardest of the three.


;ROB	MOVEQ	#0,D0
;	MOVEQ	#0,D1
;	PEA	L12345(PC)
;	MOVE.L	#$50004,-(SP)
;	TRAP	#13
;	ADDQ.W	#8,SP
;L12345	MOVE.L	(SP)+,$10.W
;	ILLEGAL	
;	DC.W	$2345
;	AND.W	#$F8,SR
;	CLR.L	$24.W
;	MOVE.L	#43245365363,-(SP)
;	MOVE.L	#88745222435,-(SP)
;	MOVE.L	#47788679999,-(SP)
;	MOVE.L	#43245365363,-(SP)
;	MOVE.L	#4324536536,-(SP)
;
;There would be about 2.5kb of data between the above and below
;parts of code, i have done this to simplyfy the example.


;	DC.W	$FEFE
;	AND.W	$FFFFFF8913.W,D5
;	RTE

;These following examples are what maybe carried at the bottom of 
;a RNC protection

;1       CMP.L #$42425673,D0
;	 BNE	$34566

;The above line (BNE) would be replaced by a $4E71 (NOP)
;If it should read (BEQ) this would be changed to a (BRA)
;$6000


;2 	 MOVE.L	D0,ADDR
;These become more complicated as the address D0 is placed
;in can be checked at any time.
;To get round this you must do a string search* on the address
;that D0 is placed in to find the serial number of the disk.
;Once you have done that you must force the serial no. into
;D0 yourself then modify the protection.
;To find a Rob Northern do a string search* on $4AFC(ILLEGAL)

*see section on monst2 for string search

;i.e. 
;ROB	MOVEQ	#0,D0
;	MOVEQ	#0,D1
;	MOVE.L	#$42425675,D0
;	MOVE.L	D0,$24.W
;	BRA	$888	;jump over protection
;L12345	MOVE.L	(SP)+,$10.W
;	ILLEGAL	
;	DC.W	$2345
;	AND.W	#$F8,SR
;	CLR.L	$24.W
;	MOVE.L	#43245365363,-(SP)
;	MOVE.L	#88745222435,-(SP)
;	MOVE.L	#47788679999,-(SP)
;	MOVE.L	#43245365363,-(SP)
;	MOVE.L	#4324536536,-(SP)
;
;There would be about 2.5kb of data between the above and below
;parts of code, i have done this to simplyfy the example.


;	DC.W	$FEFE
;	AND.W	$FFFFFF8913.W,D5
;	RTE


;The modified version should look something like the above.
;When you have poked the serial number into D0
;you must then jump over the protection to where the code
;checks or pokes D0 into an address

;the opcode for this is;
;12345678 is for my example only

;	move.l	#$12345678,d0
;	move.l	d0,$24.w
;	bra	coderestart


;	$203c12345678	;move.l	#serialno,d0 
;	$21c00024	;move.l	d0,$24.w
;	$60000888	;bra	coderestart

;there are examples of all these protections for you to crack.
;they are all executable files that will crash - it's up to
;you to get them to work. the screen will turn red if they fail
;and green if you manage to crack them.

;filenames
;GREMLIN.PRG	;Gremlin Graphics Protection
;PROT.PRG	;Protoscan II Protection
;RNC.PRG	;Rob Northern Protection


;Rob Northern Protection (external)

;This one is a real pig for beginers.
;To look at it looks like the internal version exept the
;whole file is encripted.

;Leave this one alone for the time being.


;Novela Protection(manual)

;Not so many games use this one but there are the odd ones like
;Carrier Command,Fighter Bomber, Midwinter.

;To crack these you must be more involved with 68000 programing.

;Again leave these ones alone.



;Disk Types:-

;There are 2 types of format in which games appear

;1- the Auto folder booter/Double click booter(desktop)
;2- boot disks - the types with no files visible on the desktop
;i.e. Operation Wolf, Swichblade II(original version).



;Auto folders + Desktop booters can be directly loaded in to monst2
;as executable files.
;you must first load & run the freemem.prg file, then load your
;executable file. (all loading explaned in the monst2 section)

;Boot Disks - These are slightly more tricky as they run from the
;boot sector, To access these you must read in the boot sector
;using the bootfile.prg there is no need to load the freemem.prg
;first you must then "Trace"* through the bootsector, The bootdisk.prg
;file looks something like this:-

*Refer to monst2 section     

	clr.l	-(sp)
	move.w	#$20,-(sp)	;function supervisor mode
	trap	#1
	addq.w	#6,sp 

	move.w	#1,-(sp)	;read 1 sector
	clr.w	-(sp)		;side 0
	clr.w	-(sp)		;track 0
	move.w	#1,-(sp)	;sector 1
	clr.w	-(sp)		;dive 0
	clr.l	-(sp)		;unused long word
	pea	$30000		;buffer address
	move.w	#8,-(sp)	;function read sectors
	trap	#14		;trap xbios
	lea	20(sp),sp	;correct stack
	jmp	$30000		;jump to the boot sector

;I will not go into much detail with these as it can become
;quite complicated.

;Once you have read in the bootsector you have accessed the games 
;loader.

;For instance if you can get hold of Count Duckula (original)
;then it is a good one to practice on as it loads at a sensible
;address and is not protected in any way.

;1 load the bootdisk.prg.
;2 Insert Count duckula.
;3 fill memory from 10000,80000 with $ee*
;4 trace through the bootdisk.prg until it has jumped to $30000*
;5 trace the Duckula loader until you hit a DBF then do a breakpoint*
;6 your pc should now be on the line JMP (A2)*
;7 trace this line!*
;8 continue tracing until your pc is on the BCC.S line just before
;the JMP (A5) and do another breakpoint.*
;the disk should now be loading into memeory.
;9 when it has finished loading set window M2 to $10000 - ok?
;now do a string search on your fill pattern $ee.
;you may find the odd one in count duckula - just press N until
;you hit a large block of them.
;10 press TAB so you are on window M3 - memory and press the left
;cursor ones.
;11 press TAB twice so you are now on M2 - disassembly and set
;the window to $10000, so now M3 points to the end and M2 points
;to the start!!.
;12 insert a blank formatted disk and save Duckula out as a file.
;to save press S save binary,filename  type DUCK.RAW <return>
;start address,end   - type M2(start),M3(end) <return> it should
;now save out Duckula.  

;N.B. Count Duckula Must allways be run from $10000

;There is a piece of code called "COPY.S" use this to 
;relocate Duckula to $10000

;i.e. dest equ	$10000
;incbin	duck.raw 

;Full documentation is in this file.


;modifing an executable file.

;As with all executable files(.prg,.tos,.acc,.app,.ttp)
;they have relocation data on the end of the file so if
;you want to crack an executable file you cannot save an
;executable file out if you loaded it into the monitor
;as executable.
;1 you must file memory as with duckula $10000,$80000,$ee
;2 load your program in as binary - press B  Gremlin.prg,$10000
;3 the gremlin.prg will have now loaded at $10000 providing it is
;on the disk!!.
;4 modify the relevent parts.
;5 seach for $ee
;6 point M3 to the end byte by pressing the left cursor as in duckula
;and then set M2 to $10000 and save it out as a binary file as with
;duckula - i hope that is not too complicated.
;N.B. this file will still be executable.

;Monst2 - the best 68000 monitor

;N.B. if you have a spare œ59-99 then buy it!!

;When you press (y) to load the monitor it will prompt you to
;enter an executable file to load.

;1- If you wish to load an exec file type freemem.prg <return twice>
;then press R (run) followed by G (go). Now press ctrl L (load exec file)
;followed by the program you wish to load's name.


;2- A boot disk just type bootdisk.prg <return twice>

;3- A binary file i.e. duckula.raw - press escape
;then B (load Binary file) DUCKULA.RAW,$10000 - easy!
---------------------------------------------------------------

;Monst2 instructions.

;CTRL Z - TRACE ONE LINE OF CODE (RUN ONE LINE OF CODE)   
;CTRL A - BREAKPOINT RUN A LOOP OR BSR,JSR -I.E.
;DBF,BCC,BNE,JSR,BSR. THIS COMMAND SAVES TIME.
;CTRL S - SKIP ONE LINE (SEE THINGS TO AVOID)
;B - LOAD BINARY FILENAME  <FILENAME,ADDR>
;S - SAVE BINARY FILENAME <FILENAME> (RETURN) <START,END ADDR>
;CTRL L - LOAD EXECUTABLE FILE - THIS WILL NOT WORK IF AN EXEC FILE
;FILE IS STILL RUNABLE IN MEMORY- THE OLD FILE HAS TO BE TERMINATED.
;O - ENTER EXPRESION (PROGRAMMERS CALCULATOR) \NUMBER = DECIMAL
;NUMBER = HEX.
;ALT Z - OPEN WINDOW TO FULL SCREEN.
;M - WINDOW START ADDRESS
;TAB KEY - FLICK BETWEEN M1-REGS,M2-DISASSEMBLY,M3-MEMORY.
;G - SEARCH - PRESS W THEN YOUR PATTERN I.E. $EE
;N - SEARCH NEXT - CONTINUE TO LOOK.
;R - FOLLOWED BY G  IS RUN,GO
;W - FILL <START,END,WITH>
;CTRL E - RE-INSTALL SYSTEM VECTORS I.E. TRAPS,EXEPTIONS.
;V - VIEW WORK SCREEN.
;I - COPY <START,END,TO>
;ALT R - REGISTER=VALUE.

;Things to avoid when tracing a program:-

;Anything to do with $24.w,$25.w,$26.w,$27.w 
;Anything to do with $10.w,$11.w,$12.w,$13.w
;$118.w		;keyscanner
;$70.w		;vertical blank
;any of the MFP interupts described at the start of this doc.
;	move.b	#$13,$fffffc02.w	;keyboard master reset
;RESET
;ILLEGAL
;TRAPV
;DIVU #0,REG

;when loading a bootdisk into memory do not load below $8000
;it may do something like lea	$600.w,a0
			  bsr.s	load
;simply fill memory from $80000,$d0000 then ALT-R a0=$80600
;load it 512kb higher!


;thats all - thank god......