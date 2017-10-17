 *
 * EXT_ASM.S
 * Librairie de fonctions SCSI en C, s'appuyant sur la SCSI LIB.
 * 1998 - Franáois GALEA.
 *

	export	swap_long, swap_short
	export	set_ws, swap_endian, scramble, change_format
	export	protect_decrypt
	xref	philips_set_write_speed, teac_set_speed, mmc_set_speed
	xref	reg_ok

; Change le format big/little endian d'un long
; d0 = le long
swap_long:
	ror.w	#8,d0
	swap	d0
	ror.w	#8,d0
	rts

; Change le format big/little endian d'un short
; d0 = le short
swap_short:
	ror.w	#8,d0
	rts

; DÇcryptage de la fonction de changement de vitesse
; a0 = adresse du code (sans checksum !!!)
; a1 = adresse du nom
protect_decrypt:
	move.l	a2,-(sp)
	subq	#8,sp
	move.l	sp,a2
	moveq	#7,d0
.yo:
	move.b	(a0)+,d1
	subq	#1,d1
	lsl.b	#4,d1
	move.b	(a0)+,d2
	subq	#1,d2
	and.b	#$0f,d2
	or.b	d2,d1
	move.b	(a1)+,d2
	sub.b	d2,d1
	move.b	d1,(a2)+
	dbra	d0,.yo
	move.l	sp,a0
; a0 = adresse de la clÇ de 64 bits
	lea	crypt_start(pc),a1
	moveq	#(crypt_end-crypt_start)/8-1,d0   ; Taille / 8 -> 64 bits
	move.l	(a0),d1
	move.l	4(a0),d2
.bcl:	eor.l	d1,(a1)+
	eor.l	d2,(a1)+
	dbra	d0,.bcl
	moveq	#(((crypt_end-crypt_start)/2)&3)-1,d0
	bmi.s	.rts
.bcl2:	move	(a0)+,d1
	eor.w	d1,(a1)+
	dbra	d0,.bcl2
.rts:	addq	#8,sp
	move.l	(sp)+,a2
	rts

; SÇlection de la vitesse d'Çcriture
; d0 = vitesse d'Çcriture
; d1 = mode d'Çcriture (1=philips, 2=teac, 3=mmc)
set_ws:
	tst	reg_ok
	bne.s	crypt_start
	rts
crypt_start:
	subq.w	#1,d1
	bne.s	.yo
	bsr	philips_set_write_speed
	bra.s	.rts
.yo:	sub.w	#1,d1
	bne.s	.g
	bsr	teac_set_speed
	bra.s	.rts
.g:	add.w	#-1,d1
	bne.s	.rts
	move.l	d0,d1
	moveq	#0,d0
	bsr	mmc_set_speed
.rts:	rts
	dc.b	"ùÏñ 5óõÛ"
crypt_end:
	dc.w	crypt_end-crypt_start

;int set_write_speed( int speed, int write_mode )
;{
;  int ret;
;  switch( write_mode )
;  {
;    case 1:
;      ret = philips_set_write_speed( speed );
;      break;
;    case 2:
;      ret = teac_set_speed( speed );
;      break;
;    case 3:
;      ret = mmc_set_speed( 0, speed );
;      break;
;  }
;  return ret;
;}


; Swap des octets, lors de la lecture d'une piste audio
; a0 = adresse du bloc
; d0.l = longueur du bloc en octets
swap_endian:
	add.l	d0,a0
	lsr.l	#4,d0		; Division par 16 de la taille
	beq.s	.rts
	move.l	d0,a1		; Compteur de boucle
	movem.l	d3-d7,-(sp)
.bcl:
	movem.w	-16(a0),d0-d7	; 8 + 4 * 8 = 40 cycles 030
	ror.w	#8,d0		; 6 cycles
	ror.w	#8,d1		;
	ror.w	#8,d2		;
	ror.w	#8,d3		;
	ror.w	#8,d4		;
	ror.w	#8,d5		;
	ror.w	#8,d6		;
	ror.w	#8,d7		; 6 * 8 = 48 cycles
	movem.w	d0-d7,-(a0)	; 4 + 2 * 8 = 20 cycles (total = 108 cycles)

	subq.l	#1,a1
	tst.l	a1
	bne.s	.bcl

	movem.l	(sp)+,d3-d7
.rts:
	rts

; Ancienne routine :
;	move	(a0),d1
;	rol.w	#8,d1
;	move	d1,(a0)+
;	move	(a0),d1
;	rol.w	#8,d1
;	move	d1,(a0)+
;	subq.l	#1,d0
;	bcc.s	.bcl

; Suppression des headers, EDC et ECC de blocs
; a0 = adresse des blocs
; d0 = nombre de blocs
; d1 = offset de dÇpart des infos (16 si mode 1 ou 2, 0 si audio)
; d2 = taille d'un bloc (2352 si pas de rÇduction)
; (on considäre que la taille d'un bloc est multiple de 16)
change_format:
	cmp.w	#2352,d2
	bne.s	.ok
	rts
.ok:
	movem.l	d3-d7,-(sp)
	cmp.w	#2354,d2
	bpl.s	.raw1
	subq	#1,d0
	lea	(a0,d1.w),a1
	move.l	#2352,d1
	sub.w	d2,d1	; 2352 - blocksize = incrÇment d'adresse
	lsr	#4,d2	; Division de la taille par 16
	subq	#1,d2
.bcl2:
	move	d2,d7
.bcl:
	movem.l	(a1)+,d3-d6
	movem.l	d3-d6,(a0)
	lea	16(a0),a0
	dbra	d7,.bcl
	add.l	d1,a1
	dbra	d0,.bcl2
	bra.s	.bye
.raw1:
	move	d0,d1
	mulu.w	#2352,d1
	lea	(a0,d1.l),a1	; adresse Ö la fin du dernier bloc source
	move	d0,d1
	mulu.w	d2,d1
	lea	(a0,d1.l),a0	; adresse apräs le dernier bloc destination
	sub.w	#2352,d2	; intervalle Ö sauter Ö chaque copie
	moveq	#16,d7
	subq	#1,d0		; Compteur de blocs Ö copier
.bcl4:
	sub.w	d2,a0
	move	#2352/16-1,d1	; Compteur de blocs de 16 octets Ö copier
.bcl3:
	sub.l	d7,a1
	movem.l	(a1),d3-d6
	movem.l	d3-d6,-(a0)
	dbra	d1,.bcl3
	dbra	d0,.bcl4
.bye:
	movem.l	(sp)+,d3-d7
	rts

; Scramblage de blocs
; a0 = adresse du premier bloc
; d0 = nombre de blocs
scramble:
	subq.w	#1,d0
	movem.l	d3-d5,-(sp)
.bcl:
	lea	scramble_data(pc),a1
	move	#2352/16-1,d1
.bcl2:
	movem.l	(a1)+,d2-d5
	eor.l	d2,(a0)+
	eor.l	d3,(a0)+
	eor.l	d4,(a0)+
	eor.l	d5,(a0)+
	dbra	d1,.bcl2
	dbra	d0,.bcl
	movem.l	(sp)+,d3-d5
	rts

scramble_data:
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0180,$0060
	dc.w	$0028,$001E,$8008,$6006,$A802,$FE81,$8060,$6028
	dc.w	$281E,$9E88,$6866,$AEAA,$FC7F,$01E0,$0048,$0036
	dc.w	$8016,$E00E,$C804,$5683,$7EE1,$E048,$4836,$B696
	dc.w	$F6EE,$C6CC,$52D5,$FD9F,$01A8,$007E,$8020,$6018
	dc.w	$280A,$9E87,$2862,$9EA9,$A87E,$FEA0,$4078,$3022
	dc.w	$9419,$AF4A,$FC37,$01D6,$805E,$E038,$4812,$B68D
	dc.w	$B6E5,$B6CB,$36D7,$56DE,$BED8,$705A,$A43B,$3B53
	dc.w	$537D,$FDE1,$8188,$6066,$A82A,$FE9F,$0068,$002E
	dc.w	$801C,$6009,$E806,$CE82,$D461,$9F68,$682E,$AE9C
	dc.w	$7C69,$E1EE,$C84C,$56B5,$FEF7,$0046,$8032,$E015
	dc.w	$880F,$2684,$1AE3,$4B09,$F746,$C6B2,$D2F5,$9D87
	dc.w	$29A2,$9EF9,$A842,$FEB1,$8074,$6027,$681A,$AE8B
	dc.w	$3C67,$51EA,$BC4F,$31F4,$1447,$4F72,$B425,$B75B
	dc.w	$36BB,$56F3,$7EC5,$E053,$083D,$C691,$92EC,$6D8D
	dc.w	$EDA5,$8DBB,$25B3,$5B35,$FB57,$037E,$81E0,$6048
	dc.w	$2836,$9E96,$E86E,$CEAC,$547D,$FF61,$8028,$601E
	dc.w	$A808,$7E86,$A062,$F829,$829E,$E1A8,$487E,$B6A0
	dc.w	$76F8,$26C2,$9AD1,$AB1C,$7F49,$E036,$C816,$D68E
	dc.w	$DEE4,$584B,$7AB7,$6336,$A9D6,$FEDE,$C058,$503A
	dc.w	$BC13,$31CD,$D455,$9F7F,$2820,$1E98,$086A,$86AF
	dc.w	$22FC,$1981,$CAE0,$5708,$3E86,$9062,$EC29,$8DDE
	dc.w	$E598,$4B2A,$B75F,$36B8,$16F2,$8EC5,$A453,$3B7D
	dc.w	$D361,$9DE8,$698E,$AEE4,$7C4B,$61F7,$6846,$AEB2
	dc.w	$FC75,$81E7,$204A,$9837,$2A96,$9F2E,$E81C,$4E89
	dc.w	$F466,$C76A,$D2AF,$1DBC,$09B1,$C6F4,$52C7,$7D92
	dc.w	$A1AD,$B87D,$B2A1,$B5B8,$7732,$A695,$BAEF,$330C
	dc.w	$15C5,$CF13,$140D,$CF45,$9433,$2F55,$DC3F,$19D0
	dc.w	$0ADC,$0719,$C28A,$D1A7,$1C7A,$89E3,$26C9,$DAD6
	dc.w	$DB1E,$DB48,$5B76,$BB66,$F36A,$C5EF,$130C,$0DC5
	dc.w	$C593,$132D,$CDDD,$9599,$AF2A,$FC1F,$01C8,$0056
	dc.w	$803E,$E010,$480C,$3685,$D6E3,$1EC9,$C856,$D6BE
	dc.w	$DEF0,$5844,$3AB3,$5335,$FDD7,$019E,$8068,$602E
	dc.w	$A81C,$7E89,$E066,$C82A,$D69F,$1EE8,$084E,$86B4
	dc.w	$62F7,$6986,$AEE2,$FC49,$81F6,$E046,$C832,$D695
	dc.w	$9EEF,$284C,$1EB5,$C877,$16A6,$8EFA,$E443,$0B71
	dc.w	$C764,$52AB,$7DBF,$61B0,$2874,$1EA7,$487A,$B6A3
	dc.w	$36F9,$D6C2,$DED1,$985C,$6AB9,$EF32,$CC15,$95CF
	dc.w	$2F14,$1C0F,$49C4,$36D3,$56DD,$FED9,$805A,$E03B
	dc.w	$0813,$468D,$F2E5,$858B,$2327,$59DA,$BADB,$331B
	dc.w	$55CB,$7F17,$600E,$A804,$7E83,$6061,$E828,$4E9E
	dc.w	$B468,$776E,$A6AC,$7AFD,$E301,$89C0,$66D0,$2ADC
	dc.w	$1F19,$C80A,$D687,$1EE2,$8849,$A6B6,$FAF6,$C306
	dc.w	$D1C2,$DC51,$99FC,$6AC1,$EF10,$4C0C,$35C5,$D713
	dc.w	$1E8D,$C865,$96AB,$2EFF,$5C40,$39F0,$12C4,$0D93
	dc.w	$45AD,$F33D,$85D1,$A31C,$79C9,$E2D6,$C99E,$D6E8
	dc.w	$5ECE,$B854,$72BF,$65B0,$2B34,$1F57,$483E,$B690
	dc.w	$76EC,$26CD,$DAD5,$9B1F,$2B48,$1F76,$8826,$E69A
	dc.w	$CAEB,$170F,$4E84,$3463,$5769,$FEAE,$C07C,$5021
	dc.w	$FC18,$41CA,$B057,$343E,$9750,$6EBC,$2C71,$DDE4
	dc.w	$598B,$7AE7,$630A,$A9C7,$3ED2,$905D,$AC39,$BDD2
	dc.w	$F19D,$8469,$A36E,$F9EC,$42CD,$F195,$846F,$236C
	dc.w	$19ED,$CACD,$9715,$AE8F,$3C64,$11EB,$4C4F,$75F4
	dc.w	$2707,$5A82,$BB21,$B358,$75FA,$A703,$3A81,$D320
	dc.w	$5DD8,$399A,$92EB,$2D8F,$5DA4,$39BB,$52F3,$7D85
	dc.w	$E1A3,$0879,$C6A2,$D2F9,$9D82,$E9A1,$8EF8,$6442
	dc.w	$AB71,$BF64,$702B,$641F,$6B48,$2F76,$9C26,$E9DA
	dc.w	$CEDB,$145B,$4F7B,$7423,$6759,$EABA,$CF33,$1415
	dc.w	$CF4F,$1434,$0F57,$443E,$B350,$75FC,$2701,$DA80
	dc.w	$5B20,$3B58,$137A,$8DE3,$2589,$DB26,$DB5A,$DB7B
	dc.w	$1B63,$4B69,$F76E,$C6AC,$52FD,$FD81,$81A0,$6078
	dc.w	$2822,$9E99,$A86A,$FEAF,$007C,$0021,$C018,$500A
	dc.w	$BC07,$31C2,$9451,$AF7C,$7C21,$E1D8,$485A,$B6BB
	dc.w	$36F3,$56C5,$FED3,$005D,$C039,$9012,$EC0D,$8DC5
	dc.w	$A593,$3B2D,$D35D,$9DF9,$A982,$FEE1,$8048,$6036
	dc.w	$A816,$FE8E,$C064,$502B,$7C1F,$61C8,$2856,$9EBE
	dc.w	$E870,$4EA4,$347B,$5763,$7EA9,$E07E,$C820,$5698
	dc.w	$3EEA,$904F,$2C34,$1DD7,$499E,$B6E8,$76CE,$A6D4
	dc.w	$7ADF,$6318,$29CA,$9ED7,$285E,$9EB8,$6872,$AEA5
	dc.w	$BC7B,$31E3,$5449,$FF76,$C026,$D01A,$DC0B,$19C7
	dc.w	$4AD2,$B71D,$B689,$B6E6,$F6CA,$C6D7,$12DE,$8D98
	dc.w	$65AA,$AB3F,$3F50,$103C,$0C11,$C5CC,$5315,$FDCF
	dc.w	$0194,$006F,$402C,$301D,$D409,$9F46,$E832,$CE95
	dc.w	$946F,$2F6C,$1C2D,$C9DD,$96D9,$AEDA,$FC5B,$01FB
	dc.w	$4043,$7031,$E414,$4B4F,$7774,$26A7,$5AFA,$BB03
	dc.w	$3341,$D5F0,$5F04,$3803,$5281,$FDA0,$41B8,$3072
	dc.w	$9425,$AF5B,$3C3B,$51D3,$7C5D,$E1F9,$8842,$E6B1
	dc.w	$8AF4,$6707,$6A82,$AF21,$BC18,$71CA,$A457,$3B7E
	dc.w	$9360,$6DE8,$2D8E,$9DA4,$69BB,$6EF3,$6C45,$EDF3
	dc.w	$0D85,$C5A3,$1339,$CDD2,$D59D,$9F29,$A81E,$FE88
	dc.w	$4066,$B02A,$F41F,$0748,$02B6,$81B6,$E076,$C826
	dc.w	$D69A,$DEEB,$184F,$4AB4,$3737,$5696,$BEEE,$F04C
	dc.w	$4435,$F357,$05FE,$8300,$61C0,$2850,$1EBC,$0871
	dc.w	$C6A4,$52FB,$7D83,$61A1,$E878,$4EA2,$B479,$B762
	dc.w	$F6A9,$86FE,$E2C0,$4990,$36EC,$16CD,$CED5,$945F
	dc.w	$2F78,$1C22,$89D9,$A6DA,$FADB,$031B,$41CB,$7057
	dc.w	$643E,$AB50,$7F7C,$2021,$D818,$5A8A,$BB27,$335A
	dc.w	$95FB,$2F03,$5C01,$F9C0,$42D0,$319C,$1469,$CF6E
	dc.w	$D42C,$5F5D,$F839,$8292,$E1AD,$887D,$A6A1,$BAF8
	dc.w	$7302,$A5C1,$BB10,$734C,$25F5,$DB07,$1B42,$8B71
	dc.w	$A764,$7AAB,$633F,$69D0,$2EDC,$1C59,$C9FA,$D6C3
	dc.w	$1ED1,$C85C,$56B9,$FEF2,$C045,$9033,$2C15,$DDCF
	dc.w	$1994,$0AEF,$470C,$3285,$D5A3,$1F39,$C812,$D68D
	dc.w	$9EE5,$A84B,$3EB7,$5076,$BC26,$F1DA,$C45B,$137B
	dc.w	$4DE3,$7589,$E726,$CA9A,$D72B,$1E9F,$4868,$36AE
	dc.w	$96FC,$6EC1,$EC50,$4DFC,$3581,$D720,$5E98,$386A
	dc.w	$92AF,$2DBC,$1DB1,$C9B4,$56F7,$7EC6,$A052,$F83D
	dc.w	$8291,$A1AC,$787D,$E2A1,$89B8,$66F2,$AAC5,$BF13
	dc.w	$300D,$D405,$9F43,$2831,$DE94,$586F,$7AAC,$233D
	dc.w	$D9D1,$9ADC,$6B19,$EF4A,$CC37,$15D6,$8F1E,$E408
	dc.w	$4B46,$B772,$F6A5,$86FB,$22C3,$5991,$FAEC,$430D
	dc.w	$F1C5,$8453,$237D,$D9E1,$9AC8,$6B16,$AF4E,$FC34
	dc.w	$41D7,$705E,$A438,$7B52,$A37D,$B9E1,$B2C8,$7596
	dc.w	$A72E,$FA9C,$4329,$F1DE,$C458,$537A,$BDE3,$3189
	dc.w	$D466,$DF6A,$D82F,$1A9C,$0B29,$C75E,$D2B8,$5DB2
	dc.w	$B9B5,$B2F7,$3586,$9722,$EE99,$8C6A,$E5EF,$0B0C
	dc.w	$0745,$C2B3,$11B5,$CC77,$15E6,$8F0A,$E407,$0B42
	dc.w	$8771,$A2A4,$79BB,$62F3,$6985,$EEE3,$0C49,$C5F6
	dc.w	$D306,$DDC2,$D991,$9AEC,$6B0D,$EF45,$8C33,$25D5
	dc.w	$DB1F,$1B48,$0B76,$8766,$E2AA,$C9BF,$16F0,$0EC4
	dc.w	$0453,$437D,$F1E1,$8448,$6376,$A9E6,$FECA,$C057
	dc.w	$103E,$8C10,$65CC,$2B15,$DF4F,$1834,$0A97,$472E
	dc.w	$B29C,$75A9,$E73E,$CA90,$572C,$3E9D,$D069,$9C2E
	dc.w	$E9DC,$4ED9,$F45A,$C77B,$12A3,$4DB9,$F5B2,$C735
	dc.w	$9297,$2DAE,$9DBC,$69B1,$EEF4,$4C47,$75F2,$A705
	dc.w	$BA83,$3321,$D5D8,$5F1A,$B80B,$3287,$55A2,$BF39
	dc.w	$B012,$F40D,$8745,$A2B3,$39B5,$D2F7,$1D86,$89A2
	dc.w	$E6F9,$8AC2,$E711,$8A8C,$6725,$EA9B,$0F2B,$441F
	dc.w	$7348,$25F6,$9B06,$EB42,$CF71,$9424,$6F5B,$6C3B
	dc.w	$6DD3,$6D9D,$EDA9,$8DBE,$E5B0,$4B34,$3757,$56BE
	dc.w	$BEF0,$7044,$2433,$5B55,$FB7F,$0360,$01E8,$004E
	dc.w	$8034,$6017,$680E,$AE84,$7C63,$61E9,$E84E,$CEB4
	dc.w	$5477,$7F66,$A02A,$F81F,$0288,$01A6,$807A,$E023
	dc.w	$0819,$C68A,$D2E7,$1D8A,$89A7,$26FA,$9AC3,$2B11
	dc.w	$DF4C,$5835,$FA97,$032E,$81DC,$6059,$E83A,$CE93
	dc.w	$146D,$CF6D,$942D,$AF5D,$BC39,$B1D2,$F45D,$8779
	dc.w	$A2A2,$F9B9,$82F2,$E185,$8863,$26A9,$DAFE,$DB00
	dc.w	$5B40,$3B70,$1364,$0DEB,$458F,$7324,$25DB,$5B1B
	dc.w	$7B4B,$6377,$69E6,$AECA,$FC57,$01FE,$8040,$6030
	dc.w	$2814,$1E8F,$4864,$36AB,$56FF,$7EC0,$2050,$183C
	dc.w	$0A91,$C72C,$529D,$FDA9,$81BE,$E070,$4824,$369B
	dc.w	$56EB,$7ECF,$6054,$283F,$5E90,$386C,$12AD,$CDBD
	dc.w	$95B1,$AF34,$7C17,$61CE,$A854,$7EBF,$6070,$2824
	dc.w	$1E9B,$486B,$76AF,$66FC,$2AC1,$DF10,$580C,$3A85
	dc.w	$D323,$1DD9,$C99A,$D6EB,$1ECF,$4854,$36BF,$56F0
	dc.w	$3EC4,$1053,$4C3D,$F5D1,$871C,$6289,$E9A6,$CEFA
	dc.w	$D443,$1F71,$C824,$569B,$7EEB,$604F,$6834,$2E97
	dc.w	$5C6E,$B9EC,$72CD,$E595,$8B2F,$275C,$1AB9,$CB32
	dc.w	$D755,$9EBF,$2870,$1EA4,$087B,$46A3,$72F9,$E582
	dc.w	$CB21,$9758,$6EBA,$AC73,$3DE5,$D18B,$1C67,$49EA
	dc.w	$B6CF,$36D4,$16DF,$4ED8,$345A,$977B,$2EA3,$5C79
	dc.w	$F9E2,$C2C9,$9196,$EC6E,$CDEC,$558D,$FF25,$801B
	dc.w	$200B,$5807,$7A82,$A321,$B9D8,$72DA,$A59B,$3B2B
	dc.w	$535F,$7DF8,$2182,$9861,$AAA8,$7F3E,$A010,$780C
	dc.w	$2285,$D9A3,$1AF9,$CB02,$D741,$9EB0,$6874,$2EA7
	dc.w	$5C7A,$B9E3,$32C9,$D596,$DF2E,$D81C,$5A89,$FB26
	dc.w	$C35A,$D1FB,$1C43,$49F1,$F6C4,$46D3,$72DD,$E599

