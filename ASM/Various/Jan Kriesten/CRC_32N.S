;--------------------------------------------------------------------------
;		CRC_32N.S
;		Assemblerroutinen (68000er) zur CRC-Berechnung;
;
;		(c) 1994 by Jan Kriesten, D-3550 Marburg, FidoNet: 2:244/4344
;
;		Die CRC-Tabelle fÅr CRC-32 ist hier enthalten;
;

	.GLOBL	Crc32Str, Crc32Blk, Crc32Upd
	.GLOBL	Crc32Tab

	.TEXT

;--------------------------------------------------------------------------
;		Routine zur CRC-32 Berechnung (ANSI X3.66) eines
;		nullterminierten Strings;
;		Polynom: x^32+x^26+x^23+x^22+x^16+x^12+x^11+x^10+x^8+x^7+x^5+x^4+x^2+x+1
;		Die Berechnung wird mit Hilfe einer Tabelle durchgefÅhrt, so daû
;		8 BIT gleichzeitig herangezogen werden kînnen.
;
;		->	a0:	- Adresse eines nullterminierten Strings;
;		<-	d0:	- CRC-32 ( 4 Byte );

	.MODULE Crc32Str
	
		moveq		#-$1, d0		; d0 vorbesetzen
		lea.l		Crc32Tab, a1	; Adresse der CRC-Tabelle nach a1.

		bra .LoopStart

.Loop:
		clr.w		d1				; d1 lîschen
		move.b		d0, d1			; Kopiere d0 nach d1
		lsr.l		#8, d0			; d0 wird um 8 BIT rechts geschoben

		eor.b		d2, d1			; x = crc XOR (*msg)
		add.w		d1, d1			; mal 4, da auf long adressiert wird
		add.w		d1, d1			; (2 'add.w d1, d1' sind schneller als 1 'lsl.w #2, d1')
		move.l		(a1,d1.w), d1	; entsprechender Tabelleneintrag nach d1

		eor.l		d1, d0			; y = (crc >> 8) XOR x

.LoopStart:
		move.b		(a0)+, d2		; erstes Byte des Strings nach d2 ...
		bne			.Loop			; wenn d2 != 0, dann geht's weiter

		rts							; ... endlich schluss und zurÅck!

	.ENDMOD

;--------------------------------------------------------------------------
;		Routine zur CRC-32 Berechnung (ANSI X3.66) eines
;		beliebigen Datenblockes;
;		Polynom: x^32+x^26+x^23+x^22+x^16+x^12+x^11+x^10+x^8+x^7+x^5+x^4+x^2+x+1
;		Die Berechnung wird mit Hilfe einer Tabelle durchgefÅhrt, so daû
;		8 BIT gleichzeitig herangezogen werden kînnen.
;
;		->	a0:	- Adresse eines nullterminierten Strings;
;			d0:	- LÑnge des Datenblockes ( 4 Bytes unsigned )
;		<-	d0:	- CRC-32 ( 4 Bytes unsigned );

	.MODULE Crc32Blk

		move.l		d3, -(sp)		; Register retten.
		move.l		d0, d3			; counter in d3 initialisieren

		moveq		#-$1, d0		; d0 vorbesetzen
		lea.l		Crc32Tab, a1	; Adresse der CRC-Tabelle nach a1.

		bra			.LoopStart

.Loop:
		clr.w		d1				; d1 lîschen
		move.b		d0, d1			; Kopiere d0 nach d1
		lsr.l		#8, d0			; d0 wird um 8 BIT rechts geschoben

		eor.b		d2, d1			; x = crc XOR (*msg)
		add.w		d1, d1			; mal 4, da auf long adressiert wird
		add.w		d1, d1			; (2 'add.w d1, d1' sind schneller als 1 'lsl.w #2, d1')
		move.l		(a1, d1.w), d1	; entsprechender Tabelleneintrag nach d1

		eor.l		d1, d0			; y = (crc >> 8) XOR x

.LoopStart:
		move.b		(a0)+, d2		; erstes Byte des Strings nach d2 ...

		subq.l		#1, d3			; counter um 1 erniedrigen
		bpl			.Loop			; wenn d3 >= 0, dann geht's weiter

		move.l		(sp)+, d3		; Register restaurieren.
		rts							; ... endlich schluss und zurÅck!

	.ENDMOD

;--------------------------------------------------------------------------
;		Routine zum Updaten einer CRC-32 Berechnung (ANSI X3.66)
;		mit den Åbergebenen Zeichen;
;		Polynom: x^32+x^26+x^23+x^22+x^16+x^12+x^11+x^10+x^8+x^7+x^5+x^4+x^2+x+1
;		Die Berechnung wird mit Hilfe einer Tabelle durchgefÅhrt, so daû
;		8 BIT gleichzeitig herangezogen werden kînnen.
;
;		->	d0:	- bisheriger CRC (4 Byte unsigned;
;			d1:	- hinzuzufÅgendes Byte;
;		<-	d0:	- CRC-32 ( 4 Byte unsigned );

	.MODULE Crc32Upd

		lea.l		Crc32Tab, a0	; Adresse der CRC-Tabelle nach a1.

		clr.w		d2				; d2 lîschen
		move.b		d0, d2			; Kopiere d0 nach d2
		lsr.l		#8, d0			; d0 wird um 8 BIT rechts geschoben

		eor.b		d1, d2			; x = crc XOR (*msg)
		add.w		d2, d2			; mal 4, da auf long adressiert wird
		add.w		d2, d2			; (2 'add.w d1, d1' sind schneller als 1 'lsl.w #2, d1')
		move.l		(a0, d2.w), d2	; entsprechender Tabelleneintrag nach d1

		eor.l		d2, d0			; y = (crc >> 8) XOR x

		rts							; ... endlich schluss und zurÅck!

	.ENDMOD

;--------------------------------------------------------------------------
	.DATA

	.MODULE Crc32Tab
	
		dc.l $00000000, $77073096, $ee0e612c, $990951ba, $076dc419, $706af48f, $e963a535, $9e6495a3 
		dc.l $0edb8832, $79dcb8a4, $e0d5e91e, $97d2d988, $09b64c2b, $7eb17cbd, $e7b82d07, $90bf1d91 
		dc.l $1db71064, $6ab020f2, $f3b97148, $84be41de, $1adad47d, $6ddde4eb, $f4d4b551, $83d385c7 
		dc.l $136c9856, $646ba8c0, $fd62f97a, $8a65c9ec, $14015c4f, $63066cd9, $fa0f3d63, $8d080df5 
		dc.l $3b6e20c8, $4c69105e, $d56041e4, $a2677172, $3c03e4d1, $4b04d447, $d20d85fd, $a50ab56b 
		dc.l $35b5a8fa, $42b2986c, $dbbbc9d6, $acbcf940, $32d86ce3, $45df5c75, $dcd60dcf, $abd13d59 
		dc.l $26d930ac, $51de003a, $c8d75180, $bfd06116, $21b4f4b5, $56b3c423, $cfba9599, $b8bda50f 
		dc.l $2802b89e, $5f058808, $c60cd9b2, $b10be924, $2f6f7c87, $58684c11, $c1611dab, $b6662d3d 
		dc.l $76dc4190, $01db7106, $98d220bc, $efd5102a, $71b18589, $06b6b51f, $9fbfe4a5, $e8b8d433 
		dc.l $7807c9a2, $0f00f934, $9609a88e, $e10e9818, $7f6a0dbb, $086d3d2d, $91646c97, $e6635c01 
		dc.l $6b6b51f4, $1c6c6162, $856530d8, $f262004e, $6c0695ed, $1b01a57b, $8208f4c1, $f50fc457 
		dc.l $65b0d9c6, $12b7e950, $8bbeb8ea, $fcb9887c, $62dd1ddf, $15da2d49, $8cd37cf3, $fbd44c65 
		dc.l $4db26158, $3ab551ce, $a3bc0074, $d4bb30e2, $4adfa541, $3dd895d7, $a4d1c46d, $d3d6f4fb 
		dc.l $4369e96a, $346ed9fc, $ad678846, $da60b8d0, $44042d73, $33031de5, $aa0a4c5f, $dd0d7cc9 
		dc.l $5005713c, $270241aa, $be0b1010, $c90c2086, $5768b525, $206f85b3, $b966d409, $ce61e49f 
		dc.l $5edef90e, $29d9c998, $b0d09822, $c7d7a8b4, $59b33d17, $2eb40d81, $b7bd5c3b, $c0ba6cad 
		dc.l $edb88320, $9abfb3b6, $03b6e20c, $74b1d29a, $ead54739, $9dd277af, $04db2615, $73dc1683 
		dc.l $e3630b12, $94643b84, $0d6d6a3e, $7a6a5aa8, $e40ecf0b, $9309ff9d, $0a00ae27, $7d079eb1 
		dc.l $f00f9344, $8708a3d2, $1e01f268, $6906c2fe, $f762575d, $806567cb, $196c3671, $6e6b06e7 
		dc.l $fed41b76, $89d32be0, $10da7a5a, $67dd4acc, $f9b9df6f, $8ebeeff9, $17b7be43, $60b08ed5 
		dc.l $d6d6a3e8, $a1d1937e, $38d8c2c4, $4fdff252, $d1bb67f1, $a6bc5767, $3fb506dd, $48b2364b 
		dc.l $d80d2bda, $af0a1b4c, $36034af6, $41047a60, $df60efc3, $a867df55, $316e8eef, $4669be79 
		dc.l $cb61b38c, $bc66831a, $256fd2a0, $5268e236, $cc0c7795, $bb0b4703, $220216b9, $5505262f 
		dc.l $c5ba3bbe, $b2bd0b28, $2bb45a92, $5cb36a04, $c2d7ffa7, $b5d0cf31, $2cd99e8b, $5bdeae1d 
		dc.l $9b64c2b0, $ec63f226, $756aa39c, $026d930a, $9c0906a9, $eb0e363f, $72076785, $05005713 
		dc.l $95bf4a82, $e2b87a14, $7bb12bae, $0cb61b38, $92d28e9b, $e5d5be0d, $7cdcefb7, $0bdbdf21 
		dc.l $86d3d2d4, $f1d4e242, $68ddb3f8, $1fda836e, $81be16cd, $f6b9265b, $6fb077e1, $18b74777 
		dc.l $88085ae6, $ff0f6a70, $66063bca, $11010b5c, $8f659eff, $f862ae69, $616bffd3, $166ccf45 
		dc.l $a00ae278, $d70dd2ee, $4e048354, $3903b3c2, $a7672661, $d06016f7, $4969474d, $3e6e77db 
		dc.l $aed16a4a, $d9d65adc, $40df0b66, $37d83bf0, $a9bcae53, $debb9ec5, $47b2cf7f, $30b5ffe9 
		dc.l $bdbdf21c, $cabac28a, $53b39330, $24b4a3a6, $bad03605, $cdd70693, $54de5729, $23d967bf 
		dc.l $b3667a2e, $c4614ab8, $5d681b02, $2a6f2b94, $b40bbe37, $c30c8ea1, $5a05df1b, $2d02ef8d 

	.ENDMOD
	
	.END
