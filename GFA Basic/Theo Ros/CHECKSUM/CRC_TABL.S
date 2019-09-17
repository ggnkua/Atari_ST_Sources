; =============================================================================
;
; CRC_TABL()
;
; This routine returns the CRC checksum for a given block of bytes.
; It does this by reading the mask_values from internal tables.
; This method takes quite a bit of memory because of the tables, 
; but is faster than calculating a CRC on the fly (like with the
; CRC_CALC routine, which first builds the table on the stack).
;
; CRC checksums are used in modem programs to check if a block is
; transferred properly (usually 16-bit CCITT or 32-bit ANSI) and
; also in file-crunch programs:
;
; 16-bit CCITT	used in higher modem protocols (Ymodem, Zmodem)
; 16-bit Arctype	used in ARC, ZOO, LHARC and DC_CRC.PRG
; 16-bit XMDM	used in Xmodem protocol (I think..)
; 32-bit ANSI	used in ZIP,ARJ and Zmodem protocol
;
; You COULD also use crc's to check the files on your disk to keep
; them absolutely virus-free (DC_CRC). In that case, remember that
; SOME programs have self-modifying code...
;
; Call from GfA: crc%=C:crc_tabl%(W:type&,L:previous%,L:length%,L:block%)
;
; where:	type&	= 0: return CRC-16-CCITT checksum
;		= 1: return CRC-16 Arctype checksum
;		= 2: return CRC-16 Xmodem checksum
;		=>3: return CRC-32 ANSI checksum
;	previous% the checksum calculated from earlier block(s)
;		normally 0, when the full block is in memory,
;		or at the start of computation.
;		If memory is short, you can cut a file in
;		several shorter chunks. (see crc_file() for this)
;	length%	the length of the block in bytes
;	block%	the address of the block in memory
;
; CRC_TABL() was written in Devpac3 assembler to produce an Atari
; Executable file CRC_TABL.PRG of 2752 bytes. Stripping off the
; first 28 bytes leaves you with the CRC_TABL.INL of 2724 bytes.
;
; Theo Ros  15/10/1997
; 
; =============================================================================

crc_tabl:	movem.l	6(sp),d0-d1/a0	; get previous, length and address
	move.w	4(sp),d2		; check opcode type&
	beq.s	crc16_ccitt	; type& = 0: CRC-16-CCITT
	cmpi.w	#1,d2		; type& = 1: CRC-16 ARC
	beq.s	crc16_arc
	cmpi.w	#2,d2		; type& = 2: CRC-16 XMODEM
	beq.s	crc16_xmdm
	; falls through to CRC32 	; type&  =>3

; =============================================================================
; crc32	XOR: x^32+x^26+x^23+x^22+x^16+x^12+x^11+x^10+x^8+x^7+x^5+x^4+x^2+x+1
; =============================================================================

crc32:	lea	tab32(pc),a1	; get address of CRC-32 table
	not.l	d0		; init previous%
	
loop_32:	subq.l	#1,d1		; any bytes left to do?
	bmi.s	exit_32
	moveq	#0,d2   
	move.b	(a0)+,d2
	eor.b	d0,d2
	lsr.l	#8,d0
	lsl.w	#2,d2
	move.l	(a1,d2.w),d2
	eor.l	d2,d0
	bra.s	loop_32

exit_32:	not.l	d0
	rts
	
; =============================================================================
; crc16_ccitt	XOR: x^16+x^12+x^5+1
; =============================================================================

crc16_ccitt:
	lea	tab16ccitt(pc),a1	; get address of CRC-16-CCITT table

loop_c16:	subq.l	#1,d1		; any bytes left to do?
	bmi.s	exit_16
	moveq	#0,d2   
	move.b	(a0)+,d2	
	ror.w	#8,d0
	eor.b	d0,d2
	add.w	d2,d2
	move.w	(a1,d2.w),d2
	clr.b	d0
	eor.w	d2,d0
	bra.s	loop_c16
	
exit_16:	andi.l	#$ffff,d0		; return 16 bit value
	rts

; =============================================================================
; crc16_arc	XOR: x^16+x^15+x^13+1
; =============================================================================

crc16_arc:
	cmpi.l	#$4001,d1		; max. chunklength = &H4000
	blt.s	calc_a16		; so, if length% > 16384
	lea	$4000(a0),a0	; move pointer to last part
	subi.l	#$4000,d1		; and adjust length
	bra.s	crc16_arc

calc_a16:	lea	tab16arc(pc),a1	; get address of CRC-16-ARC table
	ror.w	#8,d0		; init previous%
	bsr.s	crc_16
	ror.w	#8,d0		; --> INTEL format
	bra.s	exit_16

; =============================================================================
; crc16_xmdm	XOR: x^16+x^15+x^2+1
; =============================================================================


crc16_xmdm:
	lea	tab16xmdm(pc),a1	; get address of CRC-16-XMODEM table
	not.w	d0		; init previous%
	bsr.s	crc_16
	not.w	d0
	bra.s	exit_16

; =============================================================================
; subroutine crc_16 handles both 16-bit ARC type and 16-bit XMODEM type
; =============================================================================

crc_16:	subq.l	#1,d1		; any bytes left to do?
	bmi.s	return
	moveq	#0,d2   
	move.b	(a0)+,d2
	eor.b	d0,d2
	add.w	d2,d2
	move.w	(a1,d2.w),d2
	lsr.w	#8,d0
	eor.w	d2,d0
	bra.s	crc_16
return:	rts

; =============================================================================

	even

tab16ccitt:     
	dc.w $0000,$1021,$2042,$3063,$4084,$50a5,$60c6,$70e7
	dc.w $8108,$9129,$a14a,$b16b,$c18c,$d1ad,$e1ce,$f1ef
	dc.w $1231,$0210,$3273,$2252,$52b5,$4294,$72f7,$62d6
	dc.w $9339,$8318,$b37b,$a35a,$d3bd,$c39c,$f3ff,$e3de
	dc.w $2462,$3443,$0420,$1401,$64e6,$74c7,$44a4,$5485
	dc.w $a56a,$b54b,$8528,$9509,$e5ee,$f5cf,$c5ac,$d58d
	dc.w $3653,$2672,$1611,$0630,$76d7,$66f6,$5695,$46b4
	dc.w $b75b,$a77a,$9719,$8738,$f7df,$e7fe,$d79d,$c7bc
	dc.w $48c4,$58e5,$6886,$78a7,$0840,$1861,$2802,$3823
	dc.w $c9cc,$d9ed,$e98e,$f9af,$8948,$9969,$a90a,$b92b
	dc.w $5af5,$4ad4,$7ab7,$6a96,$1a71,$0a50,$3a33,$2a12
	dc.w $dbfd,$cbdc,$fbbf,$eb9e,$9b79,$8b58,$bb3b,$ab1a
	dc.w $6ca6,$7c87,$4ce4,$5cc5,$2c22,$3c03,$0c60,$1c41
	dc.w $edae,$fd8f,$cdec,$ddcd,$ad2a,$bd0b,$8d68,$9d49
	dc.w $7e97,$6eb6,$5ed5,$4ef4,$3e13,$2e32,$1e51,$0e70
	dc.w $ff9f,$efbe,$dfdd,$cffc,$bf1b,$af3a,$9f59,$8f78
	dc.w $9188,$81a9,$b1ca,$a1eb,$d10c,$c12d,$f14e,$e16f
	dc.w $1080,$00a1,$30c2,$20e3,$5004,$4025,$7046,$6067
	dc.w $83b9,$9398,$a3fb,$b3da,$c33d,$d31c,$e37f,$f35e
	dc.w $02b1,$1290,$22f3,$32d2,$4235,$5214,$6277,$7256
	dc.w $b5ea,$a5cb,$95a8,$8589,$f56e,$e54f,$d52c,$c50d
	dc.w $34e2,$24c3,$14a0,$0481,$7466,$6447,$5424,$4405
	dc.w $a7db,$b7fa,$8799,$97b8,$e75f,$f77e,$c71d,$d73c
	dc.w $26d3,$36f2,$0691,$16b0,$6657,$7676,$4615,$5634
	dc.w $d94c,$c96d,$f90e,$e92f,$99c8,$89e9,$b98a,$a9ab
	dc.w $5844,$4865,$7806,$6827,$18c0,$08e1,$3882,$28a3
	dc.w $cb7d,$db5c,$eb3f,$fb1e,$8bf9,$9bd8,$abbb,$bb9a
	dc.w $4a75,$5a54,$6a37,$7a16,$0af1,$1ad0,$2ab3,$3a92
	dc.w $fd2e,$ed0f,$dd6c,$cd4d,$bdaa,$ad8b,$9de8,$8dc9
	dc.w $7c26,$6c07,$5c64,$4c45,$3ca2,$2c83,$1ce0,$0cc1
	dc.w $ef1f,$ff3e,$cf5d,$df7c,$af9b,$bfba,$8fd9,$9ff8
	dc.w $6e17,$7e36,$4e55,$5e74,$2e93,$3eb2,$0ed1,$1ef0

tab16arc:
	dc.w $0000,$c0c1,$c181,$0140,$c301,$03c0,$0280,$c241
	dc.w $c601,$06c0,$0780,$c741,$0500,$c5c1,$c481,$0440
	dc.w $cc01,$0cc0,$0d80,$cd41,$0f00,$cfc1,$ce81,$0e40
	dc.w $0a00,$cac1,$cb81,$0b40,$c901,$09c0,$0880,$c841
	dc.w $d801,$18c0,$1980,$d941,$1b00,$dbc1,$da81,$1a40
	dc.w $1e00,$dec1,$df81,$1f40,$dd01,$1dc0,$1c80,$dc41
	dc.w $1400,$d4c1,$d581,$1540,$d701,$17c0,$1680,$d641
	dc.w $d201,$12c0,$1380,$d341,$1100,$d1c1,$d081,$1040
	dc.w $f001,$30c0,$3180,$f141,$3300,$f3c1,$f281,$3240
	dc.w $3600,$f6c1,$f781,$3740,$f501,$35c0,$3480,$f441
	dc.w $3c00,$fcc1,$fd81,$3d40,$ff01,$3fc0,$3e80,$fe41
	dc.w $fa01,$3ac0,$3b80,$fb41,$3900,$f9c1,$f881,$3840
	dc.w $2800,$e8c1,$e981,$2940,$eb01,$2bc0,$2a80,$ea41
	dc.w $ee01,$2ec0,$2f80,$ef41,$2d00,$edc1,$ec81,$2c40
	dc.w $e401,$24c0,$2580,$e541,$2700,$e7c1,$e681,$2640
	dc.w $2200,$e2c1,$e381,$2340,$e101,$21c0,$2080,$e041
	dc.w $a001,$60c0,$6180,$a141,$6300,$a3c1,$a281,$6240
	dc.w $6600,$a6c1,$a781,$6740,$a501,$65c0,$6480,$a441
	dc.w $6c00,$acc1,$ad81,$6d40,$af01,$6fc0,$6e80,$ae41
	dc.w $aa01,$6ac0,$6b80,$ab41,$6900,$a9c1,$a881,$6840
	dc.w $7800,$b8c1,$b981,$7940,$bb01,$7bc0,$7a80,$ba41
	dc.w $be01,$7ec0,$7f80,$bf41,$7d00,$bdc1,$bc81,$7c40
	dc.w $b401,$74c0,$7580,$b541,$7700,$b7c1,$b681,$7640
	dc.w $7200,$b2c1,$b381,$7340,$b101,$71c0,$7080,$b041
	dc.w $5000,$90c1,$9181,$5140,$9301,$53c0,$5280,$9241
	dc.w $9601,$56c0,$5780,$9741,$5500,$95c1,$9481,$5440
	dc.w $9c01,$5cc0,$5d80,$9d41,$5f00,$9fc1,$9e81,$5e40
	dc.w $5a00,$9ac1,$9b81,$5b40,$9901,$59c0,$5880,$9841
	dc.w $8801,$48c0,$4980,$8941,$4b00,$8bc1,$8a81,$4a40
	dc.w $4e00,$8ec1,$8f81,$4f40,$8d01,$4dc0,$4c80,$8c41
	dc.w $4400,$84c1,$8581,$4540,$8701,$47c0,$4680,$8641
	dc.w $8201,$42c0,$4380,$8341,$4100,$81c1,$8081,$4040

tab16xmdm:
	dc.w $0000,$1189,$2312,$329b,$4624,$57ad,$6536,$74bf
	dc.w $8c48,$9dc1,$af5a,$bed3,$ca6c,$dbe5,$e97e,$f8f7
	dc.w $1081,$0108,$3393,$221a,$56a5,$472c,$75b7,$643e
	dc.w $9cc9,$8d40,$bfdb,$ae52,$daed,$cb64,$f9ff,$e876
	dc.w $2102,$308b,$0210,$1399,$6726,$76af,$4434,$55bd
	dc.w $ad4a,$bcc3,$8e58,$9fd1,$eb6e,$fae7,$c87c,$d9f5
	dc.w $3183,$200a,$1291,$0318,$77a7,$662e,$54b5,$453c
	dc.w $bdcb,$ac42,$9ed9,$8f50,$fbef,$ea66,$d8fd,$c974
	dc.w $4204,$538d,$6116,$709f,$0420,$15a9,$2732,$36bb
	dc.w $ce4c,$dfc5,$ed5e,$fcd7,$8868,$99e1,$ab7a,$baf3
	dc.w $5285,$430c,$7197,$601e,$14a1,$0528,$37b3,$263a
	dc.w $decd,$cf44,$fddf,$ec56,$98e9,$8960,$bbfb,$aa72
	dc.w $6306,$728f,$4014,$519d,$2522,$34ab,$0630,$17b9
	dc.w $ef4e,$fec7,$cc5c,$ddd5,$a96a,$b8e3,$8a78,$9bf1
	dc.w $7387,$620e,$5095,$411c,$35a3,$242a,$16b1,$0738
	dc.w $ffcf,$ee46,$dcdd,$cd54,$b9eb,$a862,$9af9,$8b70
	dc.w $8408,$9581,$a71a,$b693,$c22c,$d3a5,$e13e,$f0b7
	dc.w $0840,$19c9,$2b52,$3adb,$4e64,$5fed,$6d76,$7cff
	dc.w $9489,$8500,$b79b,$a612,$d2ad,$c324,$f1bf,$e036
	dc.w $18c1,$0948,$3bd3,$2a5a,$5ee5,$4f6c,$7df7,$6c7e
	dc.w $a50a,$b483,$8618,$9791,$e32e,$f2a7,$c03c,$d1b5
	dc.w $2942,$38cb,$0a50,$1bd9,$6f66,$7eef,$4c74,$5dfd
	dc.w $b58b,$a402,$9699,$8710,$f3af,$e226,$d0bd,$c134
	dc.w $39c3,$284a,$1ad1,$0b58,$7fe7,$6e6e,$5cf5,$4d7c
	dc.w $c60c,$d785,$e51e,$f497,$8028,$91a1,$a33a,$b2b3
	dc.w $4a44,$5bcd,$6956,$78df,$0c60,$1de9,$2f72,$3efb
	dc.w $d68d,$c704,$f59f,$e416,$90a9,$8120,$b3bb,$a232
	dc.w $5ac5,$4b4c,$79d7,$685e,$1ce1,$0d68,$3ff3,$2e7a
	dc.w $e70e,$f687,$c41c,$d595,$a12a,$b0a3,$8238,$93b1
	dc.w $6b46,$7acf,$4854,$59dd,$2d62,$3ceb,$0e70,$1ff9
	dc.w $f78f,$e606,$d49d,$c514,$b1ab,$a022,$92b9,$8330
	dc.w $7bc7,$6a4e,$58d5,$495c,$3de3,$2c6a,$1ef1,$0f78

tab32:	dc.l $00000000,$77073096,$ee0e612c,$990951ba,$076dc419,$706af48f,$e963a535,$9e6495a3 
	dc.l $0edb8832,$79dcb8a4,$e0d5e91e,$97d2d988,$09b64c2b,$7eb17cbd,$e7b82d07,$90bf1d91 
	dc.l $1db71064,$6ab020f2,$f3b97148,$84be41de,$1adad47d,$6ddde4eb,$f4d4b551,$83d385c7 
	dc.l $136c9856,$646ba8c0,$fd62f97a,$8a65c9ec,$14015c4f,$63066cd9,$fa0f3d63,$8d080df5 
	dc.l $3b6e20c8,$4c69105e,$d56041e4,$a2677172,$3c03e4d1,$4b04d447,$d20d85fd,$a50ab56b 
	dc.l $35b5a8fa,$42b2986c,$dbbbc9d6,$acbcf940,$32d86ce3,$45df5c75,$dcd60dcf,$abd13d59 
	dc.l $26d930ac,$51de003a,$c8d75180,$bfd06116,$21b4f4b5,$56b3c423,$cfba9599,$b8bda50f 
	dc.l $2802b89e,$5f058808,$c60cd9b2,$b10be924,$2f6f7c87,$58684c11,$c1611dab,$b6662d3d 
	dc.l $76dc4190,$01db7106,$98d220bc,$efd5102a,$71b18589,$06b6b51f,$9fbfe4a5,$e8b8d433 
	dc.l $7807c9a2,$0f00f934,$9609a88e,$e10e9818,$7f6a0dbb,$086d3d2d,$91646c97,$e6635c01 
	dc.l $6b6b51f4,$1c6c6162,$856530d8,$f262004e,$6c0695ed,$1b01a57b,$8208f4c1,$f50fc457 
	dc.l $65b0d9c6,$12b7e950,$8bbeb8ea,$fcb9887c,$62dd1ddf,$15da2d49,$8cd37cf3,$fbd44c65 
	dc.l $4db26158,$3ab551ce,$a3bc0074,$d4bb30e2,$4adfa541,$3dd895d7,$a4d1c46d,$d3d6f4fb 
	dc.l $4369e96a,$346ed9fc,$ad678846,$da60b8d0,$44042d73,$33031de5,$aa0a4c5f,$dd0d7cc9 
	dc.l $5005713c,$270241aa,$be0b1010,$c90c2086,$5768b525,$206f85b3,$b966d409,$ce61e49f 
	dc.l $5edef90e,$29d9c998,$b0d09822,$c7d7a8b4,$59b33d17,$2eb40d81,$b7bd5c3b,$c0ba6cad 
	dc.l $edb88320,$9abfb3b6,$03b6e20c,$74b1d29a,$ead54739,$9dd277af,$04db2615,$73dc1683 
	dc.l $e3630b12,$94643b84,$0d6d6a3e,$7a6a5aa8,$e40ecf0b,$9309ff9d,$0a00ae27,$7d079eb1 
	dc.l $f00f9344,$8708a3d2,$1e01f268,$6906c2fe,$f762575d,$806567cb,$196c3671,$6e6b06e7 
	dc.l $fed41b76,$89d32be0,$10da7a5a,$67dd4acc,$f9b9df6f,$8ebeeff9,$17b7be43,$60b08ed5 
	dc.l $d6d6a3e8,$a1d1937e,$38d8c2c4,$4fdff252,$d1bb67f1,$a6bc5767,$3fb506dd,$48b2364b 
	dc.l $d80d2bda,$af0a1b4c,$36034af6,$41047a60,$df60efc3,$a867df55,$316e8eef,$4669be79 
	dc.l $cb61b38c,$bc66831a,$256fd2a0,$5268e236,$cc0c7795,$bb0b4703,$220216b9,$5505262f 
	dc.l $c5ba3bbe,$b2bd0b28,$2bb45a92,$5cb36a04,$c2d7ffa7,$b5d0cf31,$2cd99e8b,$5bdeae1d 
	dc.l $9b64c2b0,$ec63f226,$756aa39c,$026d930a,$9c0906a9,$eb0e363f,$72076785,$05005713 
	dc.l $95bf4a82,$e2b87a14,$7bb12bae,$0cb61b38,$92d28e9b,$e5d5be0d,$7cdcefb7,$0bdbdf21 
	dc.l $86d3d2d4,$f1d4e242,$68ddb3f8,$1fda836e,$81be16cd,$f6b9265b,$6fb077e1,$18b74777 
	dc.l $88085ae6,$ff0f6a70,$66063bca,$11010b5c,$8f659eff,$f862ae69,$616bffd3,$166ccf45 
	dc.l $a00ae278,$d70dd2ee,$4e048354,$3903b3c2,$a7672661,$d06016f7,$4969474d,$3e6e77db 
	dc.l $aed16a4a,$d9d65adc,$40df0b66,$37d83bf0,$a9bcae53,$debb9ec5,$47b2cf7f,$30b5ffe9 
	dc.l $bdbdf21c,$cabac28a,$53b39330,$24b4a3a6,$bad03605,$cdd70693,$54de5729,$23d967bf 
	dc.l $b3667a2e,$c4614ab8,$5d681b02,$2a6f2b94,$b40bbe37,$c30c8ea1,$5a05df1b,$2d02ef8d 

	end