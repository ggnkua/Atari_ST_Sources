*------------------------------------------------------------------------------
* Copylock(tm) ST - Disk Protection System for the Atari ST/STE
*
* (c)1988-90 Rob Northen Computing, U.K. All Rights Reserved.
*
* Title  : keydisk.s
*
* Date   : 12.7.90
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
*                                 IMPORTANT
*                                 ---------
*
*    1. DO NOT COPY THIS FILE OR ANY OTHER COPYLOCK FILE ONTO THE KEY DISK
*
*    2. DO NOT REFORMAT ANY OF THE TRACKS ON THE KEY DISK
*
*    3. DO NOT OVERWRITE SECTOR 6 ON TRACK 0
*
*    4. DO TEST PROTECTED CODE THOROUGHLY
*
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* Read the serial number from a Copylock ST key disk in floppy drive A or B
* on entry, (must be supervisor mode)
*	d0.w = drive no. of key disk (0-1)
*
*          bit 2 of the drive no. controls whether only one drive is
*          examined for the key disk or both drives. If bit 2 is clear
*          only the drive specified in bits 0-1 of d0.w will be examined.
*          If bit 2 is set drive A and B are examined for a key disk.
*
*	d1.w = motor off flag, 0=turn motor off, 1=leave motor on
* on exit,
*	d0.l = serial no. 0=key disk not found
*	d1.w = drive no. key disk was found in
*
*	all other registers preserved
*
* Note:
*	system variable flock at $43e.w is used, but its contents are
*       preserved.
*
*	Keydisk must not be called as a subroutine. No RTS is done at 
*	the end of the code (see example below).	
*
*	The serial number of the key disk can be found by running the
*       program SERIALNO.TOS.
*
*	The following vectors are trashed: trace, bus, address, illegal
*	and divide by zero.
*
*	The key disk is formatted as a double sided 80 track disk with
*       10 sectors per track. The boot sector is configured as a single
*       sided 10 sector disk for compatibility with single sided drives.
*       All 2*10*80 sectors may be used for reading and writing, with
*	the exception of sector 6 on track 0. 
*
* Example
*
* check_for_key_disk
*		moveq.l	#0,d0			drive A only
*		moveq.l	#0,d1			turn motor off
*		INCLUDE	keydisk.s
*		cmp.l	#serial_no,d0
*		bne.s	no_key_disk
*				
* no_key_disk
*		rts
*				
* Suggestions for better protection
* ---------------------------------
*
* 1. Include the source file two or three times if possible into the main
*    program, preferably not right at the beginning of the file.
*
* 2. Write software checks into the program which test for any changes
*    made to the program in an attempt by a hacker to remove the
*    protection. Use CRC's, 16/32 bit checksums or simply EOR all
*    words/longs.
*
* 3. Disguise each check as much as possible, by making each check
*    different or coding each check differently and by hiding the checks
*    in the middle of other routines.
*
* 4. Include as many checks as possible spread throughout the whole
*    program.
*
* 5. Perform checks continually throughout the running of the program.
*
* 6. Checks which fail should not simply cause the program to hangup but
*    continue to run slightly differently which may not be apparent to the
*    hacker straight away. After performing a check do not use IF THEN
*    ELSE constructs, which can easily be removed, instead use a logical
*    or arithmetic operation on the result from the check and combine it
*    with a program variable. This is harder to remove since the hacker
*    would have to know the value of the result.
*
* 7. Write checks into interrupt routines. The check could generate a
*    checksum by reading one byte from the program each time the interrupt
*    is called and signalling another routine when the last byte from the
*    program has been read.
*------------------------------------------------------------------------------
keydisk
		dc.l $487A000A,$23DF0000,$00104AFC,$48E7FFFF,$487A001A,$23DF0000,$0010204F,$4E7A0002
		dc.l $2F40003C,$08800000,$4E7B0002,$2E484CFA,$7FFF0002,$2F3C4E73,$00002F3C,$00000010
		dc.l $2F3C0004,$DDB92F3C,$BD96BDAE,$2F3CB386,$B5862F3C,$D046D246,$2F3C0246,$A71F2F3C
		dc.l $00023C17,$2F3C0004,$2C6F2F3C,$BD96BDAE,$23CF0000,$0024007C,$A71F5CB9,$00000024
		dc.l $7285712C,$2F186D85,$DA2C2F34,$6D858354,$2F2C2540,$6C4B2EFC,$614D27F9,$678CFF85
		dc.l $C0B72F2C,$00401A4E,$9ABAA9DC,$CB5EF4C0,$BDB7B20E,$273DA4C9,$FF850DE9,$2F2C7EFC
		dc.l $23B8B7E3,$5DA7AF80,$E2D00594,$293D964B,$AD3F693F,$F0859B6F,$2F347276,$253C2696
		dc.l $273996A5,$F9405D05,$FF93D86F,$0040380F,$9EBA819D,$4DB3DF44,$A9BCA19B,$E675A2DB
		dc.l $2E3E45B7,$6B53B6C0,$A31A2DD7,$DC7696B8,$DACB277E,$782E72FA,$65F825B3,$73E79A6E
		dc.l $CD2892CB,$85922E3E,$25B3D76F,$9A6EEEFD,$F9B29BA1,$DA5929BF,$0C5E5A15,$5C01C6E6
		dc.l $6D3DDB38,$6F3E3A0E,$277E6A3E,$8B780000,$BAC8614F,$F5412A5B,$96A20000,$3235493E
		dc.l $F541BAB1,$153A0000,$AE499EAC,$F541F8D1,$DA750000,$5E25FF85,$F5410AE5,$FA550000
		dc.l $D0292F3C,$F5417C8E,$DA770000,$B4799EAC,$F541EEE1,$DA750000,$A815FF85,$F54130F5
		dc.l $FA550000,$B9882F3C,$F541408D,$25820000,$6316AFBC,$F541DA80,$940C0000,$7DF5614D
		dc.l $F5419B67,$67D30CC0,$8FF12F2C,$8FF1000C,$F9B268F9,$DA591839,$09951E8C,$09950024
		dc.l $83342FD8,$38FCA7EB,$D1C4D735,$A7640609,$7EC53539,$7CAC5B85,$4632F79B,$192B4AB1
		dc.l $DAB12639,$EE36A7C0,$E446D55A,$A6F40496,$9DF3EAE5,$CD2FBE22,$E3B5EDFC,$F230C283
		dc.l $215A328F,$B0E48915,$E00E5F9C,$0FE85FA4,$A3605FA8,$32EC472C,$EA707669,$CE395A7F
		dc.l $E2BF89DB,$AB9AB917,$9C7B5C9F,$72075EFA,$AEBF7480,$D89B7348,$BE1DA281,$12A3D111
		dc.l $E6AAB6A4,$15E00D2A,$45BEE0A7,$6BC4FD03,$E1B72C5B,$17FC51DD,$47396A41,$8CBF2DFB
		dc.l $BBF8C3CA,$E1E62898,$EEDE6EA3,$AD5691C3,$04D07575,$340DBA63,$B85A1663,$41E093A6
		dc.l $B9136967,$5CA5985C,$3217C7D1,$E362BDA4,$128F21AA,$F8D586F8,$D7E7720A,$EC6DA160
		dc.l $C0F3D052,$4C79EEDC,$63001C2A,$56F3E1B5,$6776F63B,$94BCE147,$2D63DCCE,$85F6F354
		dc.l $B762E6AF,$7CEBCE35,$D17989BC,$00B23D42,$2FE980C9,$846FB241,$778045FB,$A6BC3E8E
		dc.l $4C7E6DCD,$63049F3D,$56FF1C24,$A63BE256,$D5F3D155,$5371E7DB,$80D1FC61,$B0E381DB
		dc.l $E01E5662,$0D2A3814,$3CE60B17,$BA608364,$E9634696,$ECE9D816,$8D4C61A4,$EC053817
		dc.l $1BBEED2A,$FE79145F,$D140E6DA,$B43CAF10,$46FEDF45,$69C2BBF7,$9AFEC64A,$7FB8F304
		dc.l $508487B6,$CB80CF72,$AE3AFFA7,$81069A11,$B0BD3329,$497F5199,$66C32823,$9583001F
		dc.l $6F467AE2,$6B23AA2E,$00A8136B,$2FE08684,$8466B584,$52D0DB36,$820EF68A,$15954D89
		dc.l $C99A7CC5,$CBE4D2C3,$039701FA,$FB5CFFC0,$721FD102,$2527003E,$D859B384,$079EEBF6
		dc.l $36D0E93D,$5E57F8C9,$F356E450,$CED9795E,$CA2A5E1B,$31C561A3,$864B90BD,$50FB6608
		dc.l $36BD946F,$E05BC355,$F3F574F4,$23908722,$BF1A4EAB,$95281429,$1B67BC9F,$9E9823ED
		dc.l $323088BA,$9EB84EBF,$1A4B244E,$DC115375,$49DCE873,$ECA31750,$79682C5E,$3D2E5B65
		dc.l $A8E72317,$D8B31014,$5E25F666,$8CF1C565,$0B674917,$3A337A14,$BCA561EF,$3A8CD12B
		dc.l $9113FFAF,$76A62EF4,$4D2C5F7A,$314E8E36,$024D08B0,$95EF37E8,$B7D3AE85,$E62324EB
		dc.l $9BD55327,$7E67DA2C,$1F2EA08E,$4E9509B6,$2B270B0E,$04CBEFA8,$34F84692,$C5424632
		dc.l $EAFED485,$A9ED956F,$704F42A6,$5F70D710,$91D5F8D3,$6860AE04,$475E4CB6,$69E36375
		dc.l $305514B8,$1F68E502,$51DDCAC1,$285FAA7C,$6C7F4F3E,$61BA0722,$387C365B,$17BFC4DD
		dc.l $045CE3D8,$96DF13EB,$3FE7E64D,$5CDFC991,$362AB050,$A45FDFC4,$1F39B54B,$9820E485
		dc.l $03D2A9F7,$33889AF4,$B508317A,$E4ECD73D,$143CEDC3,$4372C84B,$88F833A4,$4E7A5916
		dc.l $7D366A98,$32BC99D7,$DBBEC993,$E8BD4F15,$FF437ED3,$94F5AE0F,$F4C96BAF,$24006369
		dc.l $DE047FA6,$C00A53DE,$14908322,$BAE976DD,$5253A619,$70244BA3,$9F6752A8,$321148C9
		dc.l $E7EB7F05,$8E8DAE4F,$9D8E2641,$412D5582,$DB140908,$0AA83C8E,$D3EF6B35,$482C6664
		dc.l $B3C72816,$E3831B15,$6505E0A7,$9491F72D,$C3E99C8F,$F32A03DE,$DD988A99,$0C54B99A
		dc.l $8AD20E20,$BA14F39F,$E9AF45A2,$9DB574DE,$9F2A4A6E,$35B079A2,$D8F6A821,$6D321D40
		dc.l $1DB8E2FA,$4CF5C948,$83CF4ED1,$7F8A4A22,$05DA637B,$9B2C4DED,$2CBEF89F,$8290AB91
		dc.l $64A2AEC3,$9AF44A35,$ED86C5E7,$245869D9,$076A7E0B,$5EBC4A7D,$F24E172F,$8A202C21
		dc.l $EE32D153,$E6844EC5,$3B16EC77,$B3E8F269,$18FAA89B,$324C570D,$C7DE45BF,$A1B0BCB1
		dc.l $87C203E3,$42146355,$98A62307,$53788AF9,$3A8AE32B,$15DC739D,$AD6E844F,$C9405D41
		dc.l $31524673,$ADA487E5,$06366997,$03083389,$6C1A2DBB,$096CA02D,$A2FED2DF,$00D00DD1
		dc.l $EAE29903,$2934BC75,$83C6C027,$C298EC19,$ADAA884B,$0CFCDCBD,$A88E316F,$4860CE61
		dc.l $B472FB93,$B4C40105,$115626B7,$9228B4A9,$FF3AF2DB,$208C294D,$BE1E9FFF,$9FF09EF1
		dc.l $8E026E23,$50545595,$AEE69D47,$71B88D39,$60CA6D6B,$441C85DD,$E3AE1E8F,$07807F81
		dc.l $7792F0B3,$FBE4BA25,$5C7623D7,$614875C9,$D25AF7FB,$77ACF26D,$193EAD1F,$7F107011
		dc.l $71228343,$B7742EB5,$1A06BA67,$60D86E59,$53EA928B,$BB3C6EFD,$5ECE4BAF,$06A070A1
		dc.l $7AB225D3,$8304B345,$E79660F7,$706876E9,$E57A3D1B,$0ECCFB8D,$B45EFA3F,$9E308131
		dc.l $9442D863,$5E9447D5,$C5261787,$8FF88F79,$870AF7AB,$725C981D,$19EEB8CF,$45C0A1C1
		dc.l $BDD29AF3,$4A24EC65,$B2B6DE17,$BF88B809,$389AC23B,$E5EC44AD,$8F7E875F,$FD50D251
		dc.l $F7626D83,$45B4A0F5,$B046B4A7,$FF18F099,$FA2A9CCB,$697C013D,$150E65EF,$C4E012E1
		dc.l $40F25013,$51446585,$BDD69B37,$4EA83929,$CBBA875B,$FD0CCDCD,$AA9E547F,$9C706371
		dc.l $9A8242A3,$6CD43A15,$DB6691C7,$AE3891B9,$AD4A81EB,$A09CAA5D,$502E530F,$8400C401
		dc.l $04124533,$98641EA5,$08F69857,$1DC8FA49,$F828175E,$82EE46E2,$17357662,$BCBB59E8
		dc.l $3FBB8934,$D96F478C,$524C76C8,$8EFD2C32,$1926E701,$4862E1FC,$48620024,$3E4400C0
		dc.l $E1E8CE84,$A7B3E1B8,$CE845097,$9E47CE84,$443FB9F7,$CE84E440,$AD67CE84,$4D02AE56
		dc.l $CE84503A,$CCF4CE84,$DD59B838,$CE8458CB,$86BECE84,$78408742,$CE84EAC6,$C360CE84
		dc.l $153A3272,$CE84FFE0,$B838CE84,$54003278,$CE84DD08,$8EB6CE84,$F7D2869A,$CE84FEAB
		dc.l $E1BACE84,$39FEE104,$CE848F2A,$1E56CE84,$ABD0E1A8,$CE8414C4,$C267CE84,$FDD4A9C2
		dc.l $CE841B46,$5C16A042,$0FF4C3F0,$724451E0,$E1B8C5C4,$3AF8E1B8,$C7C4E3F0,$E1B8C9F1
		dc.l $38443580,$E1B8C277,$9E98E19C
		