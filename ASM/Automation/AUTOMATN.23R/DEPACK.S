* This is the actual depack code for 2.3 packed files. After our packer
* man, JPM, saw this, he got quite annoyed and so he has some things to
* say about Automation and their packer... (don't worry, you don't need
* to understand this code to use it) Over to JPM anyway:


* Oh boy are AUTOMATION LAME coders. Most of the techniques
* used in this packer are ripped from THUNDER packers.

* The most important part of the depack routines within a packer
* is the start bit. This is why THUNDER packers unpack junk
* immediately after the first bit. The first bit is really important.
* This is why the LSD packer was so crap and is also why AUTOMATION
* switched to the way my packer works on the first bit.
* You may call the AUTOMATION packer THUNDER v3.0. He's looked
* at it and written one based on what THUNDER v2.0 was doing.
* The automation packer is a THUNDER clone.

* 1. This packer uses a BYTE TABLE. Stolen from THUNDER v2.0
* 2. This packer uses the first bit to signal the JUNK routine.
*    also stolen from THUNDER packers.
* 3. To top it all it uses shifts to the LEFT, also first used
*    by the THUNDER packers.
* 4. It uses 1 byte repeats, also first used in THUNDER packers.

* The only unique thing about this packer (in fact it's the
* only thing AUTOMATION can call their own), is the use of
* TABLES within the depack routines. This means they only have
* to save the INDEX into that TABLE. Instead of actually saving
* the offsets bitsizes within the packed data.
* IE :- 2 save an offsets bitsize of 10 requires 4bits.
*       2 save the INDEX into the table so you can collect
*       the 10 requires only 2 bits. 50% saving!

* Hope you all find this good readin.		JPM 1990
* Thanks for ripping this out ALIEN.





* this is the depack routine for packed files. Enter it as follows:
*	LEA	packed_file's_address,A0
*	LEA	address_to_depack_to,A1
*	BSR	DEPACK
* -you can be in user mode or supervisor. Sorry there are no comments in
* this source, but I didn't write it, it was hacked out of the packer!

DEPACK	addq.l	#4,a0
	MOVEA.L	A0,A4
	MOVE.L	(A0)+,D5
	ADDA.L	D5,A1
	ADDA.L	(A0),A0
	SUBA.L	#4,A0

* HAH HAH. Has to do this because it's only here to even out
* the file before saving.

	TST.W	-(A0)			Test if it's a dummy.
	BPL.S	L652BC			NO. Valid data.
	SUBQ.L	#1,A0			Adjust it.

* If first BIT is zero then do REPEATS
* ELSE do junk.
* Doesn't this look familiar. THUNDER packers always use the
* first bit to test for for junk.
   
L652BC	MOVE.B	-(A0),D0
L652BE	LSL.B	#1,D0
	BNE.S	L652C6
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L652C6	BCC.S	L65322			Go do the REPEATS.

* Hey up. What's this! A BYTE table in the packed file.
* TUT TUT. Didn't THUNDER v2.0 first use this technique?

* There's a lot of junk code in this routine. There really
* isn't any need for most of this shit. It's purely a smoke
* screen. It looks clever. What it all boils down to is
* to collect the size of a block of junk. Simple eh!!
* Of course, when you've stolen the routine from elsewhere
* it's best to try and hide the fact!!

	CLR.W	D1			Clear size count.
	LSL.B	#1,D0
	BNE.S	L652D2
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L652D2	BCC.S	L65316			If ZERO then its a 1 byte repeat

	LEA	L6530E(PC),A3		Lower table? BIT sizes.
	MOVEQ	#3,D3			Initial index.
L652DA	CLR.W	D1			Clear size count.
	MOVE.B	0(A3,D3.W),D2		Get the BITsize.
	EXT.W	D2			Clear the crap.
	MOVEQ	#-1,D4			Set all the bits.
	LSL.W	D2,D4			Fill with X zero bits.
	NOT.W	D4			Invert the BITS.
	SUBQ.W	#1,D2			Adjust bit size.

* Now collect D2 many bits.
* Used as an index into the UPPER table. (ADJUSTMENTS).

L652EA	LSL.B	#1,D0
	BNE.S	L652F2
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L652F2	ROXL.W	#1,D1			Collect the size.
	DBF	D2,L652EA

	TST.W	D3			??? No zeroes in the table.
	BEQ.S	L65302
	CMP.W	D1,D4
	DBNE	D3,L652DA
L65302	MOVE.B	4(A3,D3.W),D2		Upper table. ADJUSTMENTS.
	EXT.W	D2			Clear crap.
	ADD.W	D2,D1			Adjust JUNK's count size.
	BRA.s	L65316

L6530E	DC.B	$A,3,2,2,$E,7,4,1

L65316	MOVE.B	-(A0),-(A1)		Transfer BYTES of junk.
	DBF	D1,L65316

L65322	MOVEA.L	A4,A3
	ADDQ.L	#8,A3
	CMPA.L	A3,A0
	BLE	gohome
	LEA	L65368(PC),A3		Little table.
	MOVEQ	#3,D2
L65332	LSL.B	#1,D0
	BNE.S	L6533A
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L6533A	BCC.S	L65340
	DBF	D2,L65332

L65340	CLR.W	D1
	ADDQ.W	#1,D2
	MOVE.B	0(A3,D2.W),D3		Get the BIT size.
	BEQ.S	L6535C			If ZERO no more bit to collect.
	EXT.W	D3			Clear the crap.
	SUBQ.W	#1,D3			Adjust for looping

L6534E	LSL.B	#1,D0
	BNE.S	L65356
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L65356	ROXL.W	#1,D1
	DBF	D3,L6534E

L6535C	MOVE.B	5(A3,D2.W),D3		Get any ADJUSTMENTS.
	EXT.W	D3
	ADD.W	D3,D1
	BRA.s	L65372			Go to normal REPEAT routine.

L65368	DC.B	$A,2,1,0,0,$A,6,4	Little table.
	DC.B	3,2

* This is one way of doing it!!!
* Enters with the REPEATS size in D1.
* If size is 2 then skip routine below and use the small
* table in A3. Else the routine use the big offset table.
* The routine index's 0,1,2 bytes into the offsets in the big table.

L65372	CMPI.W	#2,D1			2byte repeat.
	BEQ.S	rep			Yeh. Use A3's small table.
	LEA	L653AC(PC),A3		ELSE use the big table.
	MOVEQ	#1,D3			Only two bits to collect.
L6537E	LSL.B	#1,D0
	BNE.S	L65386
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0

* If first bit is zero then exit. This stops D3 being decemented
* and allows access to another byte (3rd byte) in the table.

L65386	BCC.S	L6538C			If first bit zero then leave
	DBF	D3,L6537E
L6538C	ADDQ.W	#1,D3			Adjust index into the table.
	CLR.W	D2			UGH!!
	MOVE.B	0(A3,D3.W),D4		Fetch offset's bitsize.
	EXT.W	D4			Clear the crap.

* Now it actually manges to get round to the offset!!
* This time it index's the other half of the BIG offset table.
* The other half of the table contains ADJUSTMENT's to the
* actual offsets. They are accessed via D3. Both tables are aligned.
* If you don't need any adjustments just index the ZERO byte!!
* 6 bytes in lower table.
* 6 bytes in upper table.  The ADJUSTMENT's to the offset.

L65396	LSL.B	#1,D0
	BNE.S	L6539E
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L6539E	ROXL.W	#1,D2			Collect offset.
	DBF	D4,L65396
	LSL.W	#1,D3			Align with upper table.
	ADD.W	4(A3,D3.W),D2		Add the adjustment to the offset.
	BRA.S	L653DC			Go to MAIN repeat routine.

L653AC	DC.B	$B,4,7,0,1,$20		Offset bit sizes.
	DC.B	0,0,0,$20,0,0		Adjustments to the offsets.

* Repeated strings subroutine.

rep	CLR.W	D2			Clear offset register.
	MOVEQ	#5,D3			SMALL 6bit offset
	CLR.W	D4			Set the ADJUSTER.
	LSL.B	#1,D0
	BNE.S	L653C6
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L653C6	BCC.S	L653CC			If CLEAR then small offset.
	MOVEQ	#8,D3			LARGE 9bit offset.
	MOVEQ	#$40,D4			Set the ADJUSTER.

* Collect the offset.

L653CC	LSL.B	#1,D0
	BNE.S	L653D4
	MOVE.B	-(A0),D0		Reload the data register.
	ROXL.B	#1,D0			and shift first bit.
L653D4	ROXL.W	#1,D2			Collect the offset.
	DBF	D3,L653CC

	ADD.W	D4,D2			Add any ADJUSTER to offset.
L653DC	LEA	0(A1,D2.W),A2		Calc address of repeated string.
	EXT.L	D1			Clear the shit in the LENGTH.
	ADDA.L	D1,A2			LENGTH + address = string end.
	SUBQ.W	#1,D1			Adust LENGTH for looping.
L653E6	MOVE.B	-(A2),-(A1)		Transfer the bytes.
	DBF	D1,L653E6
	BRA	L652BE
gohome	RTS