;	int	say(int mode, char *buf)
; prononce la suite de phonemes contenus dans buf.
; mode = 0:	retour immediat, silence en fin de phrase
; mode = 1:	attend la fin de la phrase.
; mode = 2:	retour immediat, sans silence en fin de phrase

;
; design:
;
; 1] english -> phonetic text 
; (not in this version)
;
; 2] phonetic text -> binary phoneme 'buffer' 
; (phoneme indices, pitch, length)
;
; 3] phoneme buf -> speech buffer 
; (9 byte long entries indicating frequency?
;
; 4] speech buffer -> wave samples + hiss -> YM2149

TIMAVEC		equ	$000134
GISELECT	equ	$ffff8800
GIDATA		equ	$ffff8802
IPRA		equ	$fffffa0b
ISRA		equ	$fffffa0f
IMRA		equ	$fffffa13

	ifne	0
	.globl	_say
	.globl	say
	.globl	_set_pitch
	.globl	set_pitch
	.globl	_set_rate
	.globl	set_rate
	.globl	_say_copyright
	.globl	say_copyright
	else
	endc

	text

_say_copyright:
say_copyright:
	dc.b	$0d,$0a,"MC68000/AY-3-8910 SPEECH SYNTHESIZER V:2.0"
	dc.b	$0d,$0a,"Copyright 1986 A.D.BEVERIDGE & M.N.DAY"
	dc.b	$0d,$0a,"ALL RIGHTS RESERVED.",$0d,$0a,$00
	even

_set_pitch:
set_pitch:
	link	a6,#0
	move	__set_pitc,d1
	bsr	verif
	bmi	spit2
	move.b	d0,__set_pitc
spit2:
	unlk	a6
	rts

_set_rate:
set_rate:
	link	a6,#0
	move	__set_rate,d1
	bsr	verif
	bmi	srat2
	move.b	d0,__set_rate
srat2:
	unlk	a6
	rts
verif:
	move	8(a6),d0
	bmi	ret_old
	cmpi	#200,d0
	bhs	ret_bad
	cmpi	#20,d0
	blt	ret_bad
	rts
ret_bad:
	moveq	#-1,d0
	rts
ret_old:
	move	d1,d0
	rts

;*********

; convert english to phonetic text..
; input:
; a0: english text (null-terminated)
; output:
; PHOBUFF contains phonetic text (null-terminated)
TEXTIN
  LEA       TYPETAB,A3
  JSR       to_upper
  LEA       PHOBUFF,A2
CONVWORD
  LEA       L0044,A1
  MOVE.B    (A0),D0 
  BNE.S     MORETODO
  MOVE.L    #PHOBUFF,D0 
  RTS 
MORETODO
  EXT.W     D0
  BTST      #0,0(A3,D0.W) 
  BNE.S     L0015 
  MOVE.W    #$40,D0 
L0015:
  SUBI.W    #$40,D0 
  ADD.W     D0,D0 
  ADDA.W    0(A1,D0.W),A1 
  BRA.S     L0017 
NOMATCH:
  TST.B     (A1)+ 
  BNE.S     NOMATCH 
L0017:
  MOVEA.L   A0,A4 
L0018:
  TST.B     (A4)
  BEQ.S     NOMATCH 
  MOVE.B    (A1),D0 
  BCLR      #7,D0 
  CMP.B     (A4)+,D0
  BNE.S     NOMATCH 
  TST.B     (A1)+ 
  BPL.S     L0018 
  MOVEA.L   A0,A5 
L0019:
  MOVE.B    (A1),D0 
  BCLR      #7,D0 
  EXT.W     D0
  BEQ.S     L001B 
  CMPI.B    #9,D0 
  BGT.S     L001A 
  BSR       L0020 
  BEQ.S     NOMATCH 
  BRA.S     L001B 
L001A:
  CMP.B     -(A5),D0
  BNE.S     NOMATCH 
L001B:
  TST.B     (A1)+ 
  BPL.S     L0019 
  MOVEA.L   A4,A5 
L001C:
  MOVE.B    (A1),D0 
  BCLR      #7,D0 
  EXT.W     D0
  BEQ.S     L001E 
  CMPI.B    #9,D0 
  BGT.S     L001D 
  BSR       L002D 
  BEQ.S     NOMATCH 
  BRA.S     L001E 
L001D:
  CMP.B     (A5)+,D0
  BNE.S     NOMATCH 
L001E:
  TST.B     (A1)+ 
  BPL.S     L001C 
GOTMATCH
  MOVE.B    (A1)+,(A2)+ 
  BNE.S     GOTMATCH
  SUBQ.L    #1,A2 
  MOVEA.L   A4,A0 
  BRA       CONVWORD
L0020:
  MOVE.B    -(A5),D1
  EXT.W     D1
  SUBQ.B    #1,D0 
  BNE.S     L0021 
  BTST      #0,0(A3,D1.W) 
  EORI.B    #4,CCR
  RTS 
L0021:
  SUBQ.B    #1,D0 
  BNE.S     L0022 
  BTST      #1,0(A3,D1.W) 
  RTS 
L0022:
  SUBQ.B    #1,D0 
  BNE.S     L0023 
  BTST      #2,0(A3,D1.W) 
  RTS 
L0023:
  SUBQ.B    #1,D0 
  BNE.S     L0024 
  BTST      #4,0(A3,D1.W) 
  RTS 
L0024:
  SUBQ.L    #1,D0 
  BNE.S     L0028 
  BTST      #3,0(A3,D1.W) 
  BNE.S     L0026 
  CMPI.B    #$48,D1 
  BNE.S     L0027 
  MOVE.B    -(A5),D1
  CMPI.B    #$43,D1 
  BEQ.S     L0025 
  CMPI.B    #$53,D1 
  BNE.S     L0027 
L0025:
  MOVEQ     #$FFFFFFFF,D1 
L0026:
  RTS 
L0027:
  MOVEQ     #0,D1 
  RTS 
L0028:
  SUBQ.B    #1,D0 
  BNE.S     L0029 
  BTST      #5,0(A3,D1.W) 
  BNE.S     L0026 
  CMPI.B    #$48,D1 
  BNE.S     L0027 
  MOVE.B    -(A5),D1
  CMPI.B    #$43,D1 
  BEQ.S     L0025 
  CMPI.B    #$53,D1 
  BEQ.S     L0025 
  CMPI.B    #$54,D1 
  BEQ.S     L0025 
  BRA.S     L0027 
L0029:
  SUBQ.B    #1,D0 
  BNE.S     L002A 
  CMPI.B    #$45,D1 
  BEQ.S     L0025 
  CMPI.B    #$49,D1 
  BEQ.S     L0025 
  CMPI.B    #$59,D1 
  BEQ.S     L0025 
  BRA.S     L0027 
L002A:
  SUBQ.B    #1,D0 
  BNE.S     L002C 
  ADDQ.L    #1,A5 
L002B:
  MOVE.B    -(A5),D1
  EXT.W     D1
  BTST      #2,0(A3,D1.W) 
  BNE.S     L002B 
  ADDQ.L    #1,A5 
  BRA.S     L0025 
L002C:
  ILLEGAL 
L002D:
  MOVE.B    (A5)+,D1
  EXT.W     D1
  SUBQ.B    #1,D0 
  BNE.S     L002E 
  BTST      #0,0(A3,D1.W) 
  EORI.B    #4,CCR
  RTS 
L002E:
  SUBQ.B    #1,D0 
  BNE.S     L002F 
  BTST      #1,0(A3,D1.W) 
  RTS 
L002F:
  SUBQ.B    #1,D0 
  BNE.S     L0030 
  BTST      #2,0(A3,D1.W) 
  RTS 
L0030:
  SUBQ.B    #1,D0 
  BNE.S     L0031 
  BTST      #4,0(A3,D1.W) 
  RTS 
L0031:
  SUBQ.L    #1,D0 
  BNE.S     L0035 
  BTST      #3,0(A3,D1.W) 
  BNE.S     L0033 
  CMPI.B    #$48,D1 
  BNE.S     L0034 
  MOVE.B    (A5)+,D1
  CMPI.B    #$43,D1 
  BEQ.S     L0032 
  CMPI.B    #$53,D1 
  BNE.S     L0034 
L0032:
  MOVEQ     #$FFFFFFFF,D1 
L0033:
  RTS 
L0034:
  MOVEQ     #0,D1 
  RTS 
L0035:
  SUBQ.B    #1,D0 
  BNE.S     L0036 
  BTST      #5,0(A3,D1.W) 
  BNE.S     L0033 
  CMPI.B    #$48,D1 
  BNE.S     L0034 
  MOVE.B    (A5)+,D1
  CMPI.B    #$43,D1 
  BEQ.S     L0032 
  CMPI.B    #$53,D1 
  BEQ.S     L0032 
  CMPI.B    #$54,D1 
  BEQ.S     L0032 
  BRA.S     L0034 
L0036:
  SUBQ.B    #1,D0 
  BNE.S     L0037 
  CMPI.B    #$45,D1 
  BEQ.S     L0032 
  CMPI.B    #$49,D1 
  BEQ.S     L0032 
  CMPI.B    #$59,D1 
  BEQ.S     L0032 
  BRA.S     L0034 
L0037:
  SUBQ.B    #1,D0 
  BNE.S     L0039 
  SUBQ.L    #1,A5 
L0038:
  MOVE.B    (A5)+,D1
  EXT.W     D1
  BTST      #2,0(A3,D1.W) 
  BNE.S     L0038 
  SUBQ.L    #1,A5 
  BRA.S     L0032 
L0039:
  SUBQ.B    #1,D0 
  BNE       L002C 
  CMPI.B    #$49,D1 
  BNE.S     L003C 
  CMPI.B    #$4E,(A5)+
  BNE.S     L003B 
  CMPI.B    #$47,(A5)+
  BNE.S     L003B 
L003A:
  MOVEQ     #$FFFFFFFF,D1 
  RTS 
L003B:
  MOVEQ     #0,D1 
  RTS 
L003C:
  CMPI.B    #$45,D1 
  BNE.S     L003B 
  MOVE.B    (A5)+,D1
  CMPI.B    #$52,D1 
  BEQ.S     L003A 
  CMPI.B    #$53,D1 
  BEQ.S     L003A 
  CMPI.B    #$44,D1 
  BEQ.S     L003A 
  CMPI.B    #$4C,D1 
  BNE.S     L003D 
  CMPI.B    #$59,(A5)+
  BEQ.S     L003A 
  BRA.S     L003B 
L003D:
  CMPI.B    #$46,D1 
  BNE.S     L003B 
  CMPI.B    #$55,(A5)+
  BNE.S     L003B 
  CMPI.B    #$4C,(A5)+
  BEQ.S     L003A 
  BRA.S     L003B 

; uppercase conversion..
to_upper:
  MOVEM.L   A0-A1,-(A7) 
  MOVEQ     #0,D0 
  MOVE.B    #$20,L00E3
L003F:
  MOVE.B    (A1)+,D0
  ANDI.B    #$7F,D0 
  BEQ.S     L0041 
  CMPI.B    #$60,D0 
  BLT.S     L0040 
  ANDI.B    #$5F,D0 
L0040:
  TST.B     0(A3,D0.W)
  BEQ.S     L0042 
L0041:
  MOVE.B    D0,(A0)+
L0042:
  TST.B     D0
  BNE.S     L003F 
  MOVEM.L   (A7)+,A0-A1 
  RTS 

TYPETAB:
  DCB.W     16,0
  DC.B      '@@@@@@@@'
  DC.B      $00,$00,'@@@@@@'
  DC.B      $80,$80,$80,$80,$80,$80,$80,$80 
  DC.B      $80,$80,'@@@@@@'
  DC.B      '@',$03,$15,$0D,'5',$03,$05,$1D 
  DC.B      $05,$03,'=',$05,'%',$15,'5',$03 
  DC.B      $05,$05,'5-%',$03,$15,$15 
  DC.B      $0D,$03,'=',$00,$00,'@',$00,$00 
  DC.B      $A0,$80,$80,' ',$00,$A1,$80,$80 
  DC.B      '.',$00,$A2,$80,$81,'-AH' 
  DC.B      '1NKWOWT-'
  DC.B      $00,$A2,$80,$80,'KWOW'
  DC.B      '2T-',$00,$A3,$80,$80,' ' 
  DC.B      'NUH2MBER'
  DC.B      $00,$A4,$80,$80,' DOH'
  DC.B      '2LER',$00,$A5,$80,$80
  DC.B      ' PUHSEH2'
  DC.B      'NT',$00,$A6,$80,$80,' A' 
  DC.B      'END',$00,$27,$D3,$80,$81 
  DC.B      'Z',$00,$27,$CD,$80,$80,'M',$00 
  DC.B      $27,$C4,$80,$80,'D',$00,$A7,$80 
  DC.B      $80,$00,$AA,$80,$80,' AE' 
  DC.B      '2STERIHS'
  DC.B      'K',$00,$AB,$80,$80,' PL' 
  DC.B      'UH2S',$00,$AC,$80,$80
  DC.B      ',',$00,$AD,$81,$81,'-',$00,$AD 
  DC.B      $80,$80,$00,$AE,$81,$81,' P'
  DC.B      'OYNT',$00,$AE,$80,$80
  DC.B      '.',$00,$AF,$80,$80,' SL' 
  DC.B      'AE2SH',$00,'52'
  DC.B      '0S',$D4,$81,$81,'FAY'
  DC.B      'V TWEHNT'
  DC.B      'IY EHS T'
  DC.B      'IY',$00,'1040S'
  DC.B      $D4,$81,$81,'TEHN ' 
  DC.B      'FOHRTIY '
  DC.B      'EHS TIY',$00 
  DC.B      $B0,$80,$80,' ZIH2' 
  DC.B      'ROW',$00,'1S',$D4,$81
  DC.B      $80,'FER2ST',$00
  DC.B      '10T',$C8,$81,$80,'TE'
  DC.B      'H2NTH',$00,$B1,$80 
  DC.B      $80,' WAH2N',$00
  DC.B      '2N',$C4,$81,$80,'SEH'
  DC.B      '2KUND',$00,$B2,$80 
  DC.B      $80,' TUW2',$00,'3' 
  DC.B      'R',$C4,$81,$80,'THER'
  DC.B      '2D',$00,$B3,$80,$80,' T' 
  DC.B      'HRIY2',$00,$B4,$80 
  DC.B      $80,' FOH2R',$00
  DC.B      '5T',$C8,$81,$80,'FIH'
  DC.B      '2FTH',$00,$B5,$80,$80
  DC.B      ' FAY2V',$00,$B6
  DC.B      $80,$80,' SIH2K'
  DC.B      'S',$00,$B7,$80,$80,' SE' 
  DC.B      'H2VUN',$00,'8T'
  DC.B      $C8,$81,$80,'EY2TH' 
  DC.B      $00,$B8,$80,$80,' EY2'
  DC.B      'T',$00,$B9,$80,$80,' NA' 
  DC.B      'Y2N',$00,$BA,$80,$80,'.' 
  DC.B      $00,$BB,$80,$80,'.',$00,$BC,$80 
  DC.B      $80,' LEH2S ' 
  DC.B      'DHAEN',$00,$BD,$80 
  DC.B      $80,' IY2KWU' 
  DC.B      'LZ',$00,$BE,$80,$80,' G' 
  DC.B      'REY2TER '
  DC.B      'DHAEN',$00,$BF,$80 
  DC.B      $80,'?',$00,$C0,$80,$80,' A'
  DC.B      'E1T',$00,$DE,$80,$80,' ' 
  DC.B      'KAE2RUHT'
  DC.B      $00,'A',$AE,$81,$80,'EY1' 
  DC.B      ' ',$00,$C1,$81,$81,'AE1' 
  DC.B      $00,$C1,$80,$81,'UH1',$00 
  DC.B      'ANSWE',$D2,$81,$80 
  DC.B      'ARNSER',$00,'A'
  DC.B      'RCHI',$D6,$81,$80,'A'
  DC.B      'R1KAYV',$00,'A'
  DC.B      'LL',$D9,$08,$82,$80,'UL' 
  DC.B      'IY',$00,'A',$CC,$81,$82,'U'
  DC.B      'L',$00,'AR',$C5,$81,$81,'A'
  DC.B      'RR',$00,'A',$D2,$81,$CF,'A'
  DC.B      'XR',$00,'A',$D2,$80,$82,'E'
  DC.B      'H2R',$00,'A',$D3,$D6,$82 
  DC.B      'ARZ',$00,'A',$D3,$03,$81 
  DC.B      $82,'EY2S',$00,$C1,$80
  DC.B      'W',$C1,'AE',$00,'A',$D7,$80
  DC.B      $80,'AO1',$00,'AN',$D9
  DC.B      $08,$81,$80,'EH2NI' 
  DC.B      'Y',$00,'APR',$C9,$81,$80 
  DC.B      'EYPRIH',$00,$C1
  DC.B      $80,'C',$C5,'EY1',$00,$C1 
  DC.B      $80,$03,$07,$82,'EY1',$00 
  DC.B      'AGAI',$CE,$80,$80,'A'
  DC.B      'XGEH2N',$00,'A'
  DC.B      $C7,$08,$82,$C5,'IHJ',$00 
  DC.B      $C1,$80,$03,$89,'EY',$00,$C1
  DC.B      $80,$03,$07,$08,$82,'AE',$00
  DC.B      $C1,$08,$81,$03,$07,$81,'EY'
  DC.B      '2',$00,'AR',$D2,$81,$80,'A'
  DC.B      'XR',$00,'AR',$D2,$80,$80 
  DC.B      'AE2R',$00,'A',$D2,$03
  DC.B      $81,$81,'AA1R',$00,'A'
  DC.B      $D2,$80,$80,'AA1R',$00
  DC.B      'AI',$D2,$80,$80,'EH2'
  DC.B      'R',$00,'A',$C9,$80,$80,'EY'
  DC.B      '2',$00,'A',$D9,$80,$80,'EY'
  DC.B      '1',$00,'A',$D5,$80,$80,'AO'
  DC.B      '2',$00,'A',$CC,$08,$82,$81,'U' 
  DC.B      'L',$00,'AL',$D3,$08,$82,$81
  DC.B      'ULZ',$00,'AL',$CB,$80
  DC.B      $80,'AO2K',$00,'A',$CC
  DC.B      $80,$86,'AOL',$00,'A',$CC 
  DC.B      $80,$85,'AEL',$00,'A',$CC 
  DC.B      $80,$84,'AOL',$00,'A',$CC 
  DC.B      $80,$83,'AEL',$00,'AB'
  DC.B      'L',$C5,$08,$81,$80,'EY2' 
  DC.B      'BUL',$00,'ABL',$C5 
  DC.B      $80,$80,'AXBUL',$00 
  DC.B      $C1,$81,'VI',$C1,'EY1'
  DC.B      $00,$C1,$81,'VAE2',$00
  DC.B      $C1,$80,'V',$CF,'EY2',$00 
  DC.B      'AN',$C7,$80,$87,'EY2'
  DC.B      'NJ',$00,'ATAR',$C9 
  DC.B      $80,$80,'UHTAR1'
  DC.B      'RIY',$00,$C1,$80,'TO'
  DC.B      $CD,'AE',$00,$C1,$80,'TT' 
  DC.B      $82,'AE',$00,'A',$D4,$81,$81
  DC.B      'AET',$00,$C1,$81,$D4,'U' 
  DC.B      'H',$00,'AT',$C5,$80,$81,'E'
  DC.B      'Y1T',$00,$C1,$80,'PA'
  DC.B      $C2,'EY1',$00,$C1,$80,$80 
  DC.B      'AE',$00,$C2,$81,$81,'BI' 
  DC.B      'Y2',$00,'B',$C5,$81,$03,$82
  DC.B      'BIH',$00,'BEIN'
  DC.B      $C7,$80,$80,'BIY2I' 
  DC.B      'HNX',$00,'BOT',$C8 
  DC.B      $81,$81,'BOW2TH'
  DC.B      $00,'BU',$D3,$81,$82,'BI' 
  DC.B      'H2Z',$00,'BREA'
  DC.B      $CB,$80,$80,'BREY1' 
  DC.B      'K',$00,'BUI',$CC,$80,$80 
  DC.B      'BIH2L',$00,$C2,'M' 
  DC.B      $82,$81,$00,$C2,$C2,$80,$00,$C2 
  DC.B      $80,$80,'B',$00,$C3,$81,$81,'S' 
  DC.B      'IY2',$00,'CLIM'
  DC.B      $C2,$80,$80,'KLAYM' 
  DC.B      $00,$C3,$C3,$80,$00,'COV' 
  DC.B      $C5,$80,$81,'KOWV',$00
  DC.B      'C',$C8,$03,$82,$C9,'K',$00,'C' 
  DC.B      $C8,$81,$83,'K',$00,'C',$C8,'E' 
  DC.B      $83,$80,'K',$00,'CH',$C1,$80
  DC.B      'R',$82,'KEH1',$00,'C'
  DC.B      $C8,$80,$80,'CH',$00,'C',$C9
  DC.B      'S',$81,$82,'SAY2',$00
  DC.B      'C',$C9,$80,$C1,'SH',$00,'C'
  DC.B      $C9,$80,$CF,'SH',$00,'C',$C9
  DC.B      $80,'E',$CE,'SH',$00,'CI' 
  DC.B      'T',$D9,$80,$80,'SIHT'
  DC.B      'IY',$00,'C',$C5,$80,'D',$82
  DC.B      'SIY',$00,$C3,$80,$87,'S' 
  DC.B      $00,'C',$CB,$80,$80,'K',$00,'C' 
  DC.B      'OM',$C2,$80,$81,'KOW'
  DC.B      'M',$00,'COM',$C5,$80,$80 
  DC.B      'KUHM',$00,'CO',$D5 
  DC.B      $81,'R',$82,'KUH',$00,'C' 
  DC.B      'UI',$D4,$80,$80,'KIH'
  DC.B      'T',$00,'CREAT',$C5 
  DC.B      $80,$80,'KRIYEY'
  DC.B      'T',$00,'C',$C3,$80,$87,'KS'
  DC.B      $00,'CQ',$D5,$80,$80,'KW' 
  DC.B      $00,$C3,$80,$80,'K',$00,$C4,$81 
  DC.B      $81,'DIY2',$00,'DR' 
  DC.B      $AE,$81,$81,'DOHKT' 
  DC.B      'ER',$00,'DE',$C4,$08,$82 
  DC.B      $81,'DIHD',$00,'D',$C5
  DC.B      $81,'T',$82,'DIY',$00,'D' 
  DC.B      $CA,$80,$80,'J',$00,$C4,'E',$84 
  DC.B      $81,'D',$00,$C4,$C4,$80,$00,'D' 
  DC.B      $C5,$81,'L',$82,'DIH',$00 
  DC.B      'D',$CF,$81,$81,'DUW',$00 
  DC.B      'DOE',$D3,$81,$80,'DA'
  DC.B      'HZ',$00,'DON',$C5,$80
  DC.B      $81,'DAH1N',$00,'D' 
  DC.B      'OIN',$C7,$80,$80,'DU'
  DC.B      'W2IHNX',$00,'D'
  DC.B      'O',$D7,$81,$80,'DAW',$00 
  DC.B      $C4,$80,$80,'D',$00,$C5,$81,$81 
  DC.B      'IY2',$00,'ERRO'
  DC.B      $D2,$80,$80,'EHROH' 
  DC.B      '1R',$00,'ENGLA'
  DC.B      'N',$C4,$80,$80,'IH2N'
  DC.B      'XGLAEND',$00 
  DC.B      $C5,$D2,$85,'EH',$00,$C5,$08
  DC.B      $82,$81,$00,$C5,$08,$81,$81,'I' 
  DC.B      'Y',$00,'E',$C4,$82,$81,'D',$00 
  DC.B      $C5,$08,$82,'D',$81,$00,'E',$D6 
  DC.B      $80,'E',$D2,'EH2V',$00
  DC.B      'E',$D7,$D2,$81,'UW',$00,'E'
  DC.B      $D7,$D2,$89,'UW',$00,'E',$D7
  DC.B      $CC,$81,'UW',$00,'E',$D7,$CC
  DC.B      $89,'UW',$00,'E',$D7,$80,$81
  DC.B      'YUW',$00,'E',$D7,$80,$89 
  DC.B      'YUW',$00,$C5,$80,$03,$89 
  DC.B      'IY2',$00,'ER',$C9,$80
  DC.B      $82,'IY2RIY',$00
  DC.B      'ER',$C9,$80,$80,'EH2'
  DC.B      'RIH',$00,'ERAS'
  DC.B      $C5,$80,$80,'IHREY' 
  DC.B      '1S',$00,'E',$D2,$08,$82,$82
  DC.B      'ER',$00,'E',$D2,$80,$82,'E'
  DC.B      'HR',$00,'E',$D2,$80,$80,'E'
  DC.B      'R',$00,'EVE',$CE,$81,$80 
  DC.B      'IYVUHN',$00,'E'
  DC.B      $D7,$80,$80,'YUW',$00,$C5 
  DC.B      $80,$CF,'IY',$00,'E',$D3,$05
  DC.B      $08,$82,$81,'IHZ',$00,$C5 
  DC.B      $08,$82,'S',$81,$00,'EL',$D9
  DC.B      $08,$82,$81,'LIY',$00,'E' 
  DC.B      'MEN',$D4,$08,$82,$80,'M' 
  DC.B      'EHNT',$00,'EFU'
  DC.B      $CC,$80,$80,'FUHL',$00
  DC.B      'E',$C5,$80,$80,'IY2',$00 
  DC.B      'EAR',$CE,$80,$80,'ER'
  DC.B      '1N',$00,'EA',$D2,$81,$83 
  DC.B      'ER1',$00,'EA',$C4,$80
  DC.B      $80,'EHD',$00,'E',$C1,$08 
  DC.B      $82,$81,'IYAX',$00,'E'
  DC.B      $C1,$80,'S',$D5,'EH1',$00 
  DC.B      'E',$C1,$80,$80,'IY1',$00 
  DC.B      'EIG',$C8,$80,$80,'EY'
  DC.B      '2',$00,'E',$C9,$80,$80,'IY'
  DC.B      '2',$00,'EY',$C5,$81,$80,'A'
  DC.B      'Y2',$00,'E',$D9,$80,$80,'I'
  DC.B      'Y',$00,'E',$D5,$80,$80,'YU'
  DC.B      'W1',$00,'EQUA',$CC 
  DC.B      $80,$80,'IY2KWU'
  DC.B      'L',$00,$C5,$80,$80,'EH',$00
  DC.B      $C6,$81,$81,'EH2F',$00
  DC.B      'FRIEN',$C4,$80,$80 
  DC.B      'FREH1ND',$00 
  DC.B      'FATHE',$D2,$80,$80 
  DC.B      'FAA2DHER'
  DC.B      $00,$C6,$C6,$80,$00,$C6,$80,$80 
  DC.B      'F',$00,$C7,$81,$81,'JIY' 
  DC.B      '2',$00,'GI',$D6,$80,$80,'G'
  DC.B      'IH1V',$00,'GUR'
  DC.B      'E',$C4,$80,$81,'GERD'
  DC.B      $00,$C7,$81,'I',$83,'G',$00,'G' 
  DC.B      $C5,$80,$D4,'GEH1',$00
  DC.B      'GGE',$D3,'U',$D3,$80,'J' 
  DC.B      'IH2S',$00,'G',$C7,$80
  DC.B      $80,'G',$00,$C7,$02,'B',$81,$80 
  DC.B      'G',$00,$C7,$80,$87,'J',$00,'G' 
  DC.B      'REA',$D4,$80,$80,'GR'
  DC.B      'EY2T',$00,'GO',$CE 
  DC.B      $80,$C5,'GOH1N',$00 
  DC.B      'G',$C8,$82,$80,$00,'G',$CE,$81 
  DC.B      $80,'N',$00,$C7,$80,$80,'G',$00 
  DC.B      $C8,$81,$81,'/HEY2' 
  DC.B      'CH',$00,'HA',$D6,$81,$80 
  DC.B      '/HAE1V',$00,'H'
  DC.B      'ER',$C5,$81,$80,'/HI'
  DC.B      'YR',$00,'HOU',$D2,$81
  DC.B      $80,'AW1ER',$00,'H' 
  DC.B      'O',$D7,$80,$80,'/HAW'
  DC.B      $00,$C8,$80,$82,'/H',$00,$C8
  DC.B      $80,$80,$00,$C9,$81,$81,'AY'
  DC.B      '2',$00,$C9,'ME',$D3,$80,'I'
  DC.B      'Y',$00,$C9,'TNA',$81,$80 
  DC.B      'IY',$00,$C9,$80,'NDO'
  DC.B      $D7,'IH',$00,'INDL' 
  DC.B      'E',$81,$80,$80,'IH1N'
  DC.B      'DUL',$00,$C9,$83,'DE'
  DC.B      $CE,'IH',$00,'I',$CE,$81,$80
  DC.B      'IN',$00,$C9,$80,$81,'AY' 
  DC.B      $00,'IF',$D9,$80,$80,'IH' 
  DC.B      'FAY',$00,'I',$CE,$80,$C4 
  DC.B      'AY1N',$00,'IE',$D2 
  DC.B      $80,$80,'IYER',$00,'I'
  DC.B      'E',$C4,'R',$08,$82,$81,'IY'
  DC.B      'D',$00,'IE',$C4,$80,$81,'A'
  DC.B      'Y1D',$00,'IE',$CE,$80
  DC.B      $80,'IYEHN',$00,'I' 
  DC.B      $C5,$80,$D4,'AY2EH' 
  DC.B      $00,$C9,$08,$81,$03,$89,'AY'
  DC.B      '1',$00,'I',$C5,$08,$81,$81,'A' 
  DC.B      'Y2',$00,$C9,$80,$89,'IY' 
  DC.B      $00,'I',$C5,$80,$80,'IY2' 
  DC.B      $00,'IDE',$C1,$81,$80,'A' 
  DC.B      'YDIY1AH',$00 
  DC.B      'I',$C4,$81,$C5,'AYD',$00 
  DC.B      $C9,$80,$03,$07,$08,$82,'IH'
  DC.B      $00,'I',$D2,$80,$82,'AYR' 
  DC.B      $00,'I',$DA,$80,$89,'AYZ' 
  DC.B      $00,'I',$D3,$80,$89,'AYZ' 
  DC.B      $00,$C9,$03,$C9,$03,$82,'IH'
  DC.B      $00,'IL',$C5,$80,$80,'AY' 
  DC.B      'L',$00,$C9,$03,$08,$82,$03,$87 
  DC.B      'IH',$00,$C9,$08,$87,$03,$87
  DC.B      'AY',$00,$C9,$80,$03,$87,'A'
  DC.B      'Y',$00,'I',$D2,$80,$80,'ER'
  DC.B      $00,'IG',$C8,$80,$80,'AY' 
  DC.B      '2',$00,'IL',$C4,$80,$80,'A'
  DC.B      'Y1LD',$00,'IG',$CE 
  DC.B      $81,$80,'IHGN',$00,'I'
  DC.B      'G',$CE,$80,$81,'AY2N'
  DC.B      $00,'IG',$CE,$80,$83,'AY' 
  DC.B      '2N',$00,'IG',$CE,$80,$89 
  DC.B      'AY2N',$00,'ICR'
  DC.B      $CF,$80,$80,'AY2KR' 
  DC.B      'OH',$00,'IQU',$C5,$80
  DC.B      $80,'IY2K',$00,$C9,$80
  DC.B      $80,'IH',$00,$CA,$81,$81,'J'
  DC.B      'EY2',$00,'JUL',$D9 
  DC.B      $81,$80,'JUWLAY'
  DC.B      $00,$CA,$80,$80,'J',$00,$CB,$81 
  DC.B      $81,'KEY2',$00,$CB,$81
  DC.B      $CE,$00,$CB,$80,$80,'K',$00,$CC 
  DC.B      $81,$81,'EH2L',$00,'L'
  DC.B      $CF,$80,'C',$82,'LOW',$00 
  DC.B      'L',$C9,$81,'BR',$C1,'LA' 
  DC.B      'Y1',$00,'L',$C9,$81,'A',$C9
  DC.B      'LIY1',$00,'L',$C9,$81
  DC.B      $82,'LAY1',$00,$CC,$CC
  DC.B      $80,$00,$CC,$03,$08,$82,$89,'U' 
  DC.B      'L',$00,'L',$C5,$80,$81,'UL'
  DC.B      $00,'LEA',$C4,$80,$80,'L' 
  DC.B      'IYD',$00,'LAUG'
  DC.B      $C8,$81,$80,'LAE2F' 
  DC.B      $00,$CC,$80,$80,'L',$00,$CD,$81 
  DC.B      $81,'EH2M',$00,'M',$C5
  DC.B      $81,$81,'MIY2',$00,'M'
  DC.B      'R',$AE,$81,$81,'MIH2'
  DC.B      'STER',$00,'MS',$AE 
  DC.B      $81,$80,'MIH1Z',$00 
  DC.B      'MRS',$AE,$81,$81,'MI'
  DC.B      'H2SIXZ',$00,'M'
  DC.B      'O',$D6,$80,$80,'MUW2'
  DC.B      'V',$00,'MACHI',$CE 
  DC.B      $80,$80,'MAHSHI'
  DC.B      'Y1N',$00,$CD,$CD,$80,$00 
  DC.B      $CD,$80,$80,'M',$00,$CE,$81,$81 
  DC.B      'EH2N',$00,'N',$C7,$C5
  DC.B      $87,'NJ',$00,'N',$C7,$80,$D2
  DC.B      'NXG',$00,'N',$C7,$80,$82 
  DC.B      'NXG',$00,'NG',$CC,$80
  DC.B      $89,'NXGUL',$00,'N' 
  DC.B      'GU',$C5,$80,$80,'NX',$00 
  DC.B      'N',$C7,$80,$80,'NX',$00,'N'
  DC.B      $CB,$80,$80,'NXK',$00,'N' 
  DC.B      'O',$D6,$81,$80,'NAOV'
  DC.B      $00,'NO',$D7,$81,$81,'NA' 
  DC.B      'W2',$00,$CE,$CE,$80,$00,'N'
  DC.B      'ON',$C5,$80,$80,'NAH'
  DC.B      '2N',$00,$CE,$80,$80,'N',$00
  DC.B      $CF,$81,$81,'OW2',$00,'O' 
  DC.B      $C6,$80,$81,'OHV',$00,'O' 
  DC.B      'F',$C6,$80,$80,'OH1F'
  DC.B      $00,'O',$CB,$81,$81,'OWK' 
  DC.B      'EY1',$00,'O',$C8,$81,$81 
  DC.B      'OW1',$00,'OROU'
  DC.B      'G',$C8,$80,$80,'UHRU'
  DC.B      'H1',$00,'O',$D2,$08,$82,$81
  DC.B      'ER',$00,'OR',$D3,$08,$82 
  DC.B      $81,'ERZ',$00,'O',$D2,$80 
  DC.B      $80,'AOR',$00,'ON',$C5
  DC.B      $81,$80,'WAHN',$00,$CF
  DC.B      'R',$D0,'V',$C5,'UW2',$00 
  DC.B      'ON',$C5,$82,$81,'WAH'
  DC.B      'N',$00,'OV',$C5,'L',$81,$81
  DC.B      'UHV',$00,$CF,$80,$03,'E' 
  DC.B      'OW1',$00,'O',$D7,$80
  DC.B      $80,'OW',$00,'OVE',$D2
  DC.B      $81,$80,'OW1VER'
  DC.B      $00,$CF,$80,$03,$89,'OW1' 
  DC.B      $00,'O',$D6,$80,$80,'AH2' 
  DC.B      'V',$00,$CF,$80,$03,'E',$CE,'O' 
  DC.B      'W',$00,$CF,$80,$03,'I',$C5,'A' 
  DC.B      'A1',$00,$CF,$80,$03,'I',$82
  DC.B      'OW1',$00,'O',$CC,$80,$C4 
  DC.B      'OW2L',$00,'OUG'
  DC.B      'H',$D4,$80,$80,'OH1R'
  DC.B      'T',$00,'OUG',$C8,$80,$80 
  DC.B      'OH1F',$00,'OUG'
  DC.B      $C8,'R',$81,$80,'UH1F'
  DC.B      $00,'OUG',$C8,'T',$81,$80 
  DC.B      'UH1F',$00,'OUG'
  DC.B      $C8,$80,$80,'OH1F',$00
  DC.B      'O',$D5,$81,$80,'AW',$00,'O'
  DC.B      $D5,$C8,'S',$82,'AW2',$00 
  DC.B      'OUS',$C5,$80,$80,'AW'
  DC.B      'S',$00,'OU',$D3,$80,$80,'A'
  DC.B      'XS',$00,'OU',$D2,'L',$C6 
  DC.B      $80,'AWER',$00,'OU' 
  DC.B      $D2,$C6,$80,'OH1R',$00
  DC.B      'OU',$D2,$80,$C3,'OH1'
  DC.B      'R',$00,'OU',$D2,$D4,$80,'U'
  DC.B      'W1R',$00,'OU',$D2,$D0
  DC.B      $80,'OH1R',$00,'OU' 
  DC.B      $D2,$D9,$80,'OH1R',$00
  DC.B      'OU',$D2,$80,$80,'ER1'
  DC.B      $00,'OUL',$C4,$CD,$80,'A' 
  DC.B      'O1LD',$00,'OUL'
  DC.B      $C4,$80,'E',$D2,'AO1L'
  DC.B      'D',$00,'OUL',$C4,$80,$80 
  DC.B      'UX1D',$00,'O',$D5,$80
  DC.B      $03,$CC,'AH1',$00,'OU'
  DC.B      $D0,$80,$80,'UW1P',$00
  DC.B      'O',$D5,$80,$80,'AW',$00,'O'
  DC.B      $D9,$80,$80,'OY',$00,'OI' 
  DC.B      'N',$C7,$C7,$80,'OW2I'
  DC.B      'HNX',$00,'OIN',$C7 
  DC.B      $80,$80,'OYNX',$00,'O'
  DC.B      'O',$D2,$80,$80,'OH1R'
  DC.B      $00,'OO',$CB,$80,$80,'UX' 
  DC.B      '1K',$00,'OO',$C4,$C6,$80 
  DC.B      'UW1D',$00,'OO',$C4 
  DC.B      $CC,$80,'UH1D',$00,'O'
  DC.B      'O',$C4,$CD,$80,'UW1D'
  DC.B      $00,'OO',$C4,$80,$80,'UX' 
  DC.B      '1D',$00,'OO',$D4,$C6,$80 
  DC.B      'UX1T',$00,'O',$CF,$80
  DC.B      $80,'UW1',$00,'O',$A7,$80 
  DC.B      $80,'OH',$00,'OE',$D5,$80 
  DC.B      $80,'UX1',$00,$CF,$80,$C5 
  DC.B      'OW',$00,$CF,$80,$81,'OW' 
  DC.B      $00,'OE',$D3,$80,$81,'OW' 
  DC.B      'Z',$00,'O',$C1,$80,$80,'OW'
  DC.B      '2',$00,'ONL',$D9,$81,$80 
  DC.B      'OW2NLIY',$00 
  DC.B      'ONC',$C5,$81,$80,'WA'
  DC.B      'H2NS',$00,'ON',$27 
  DC.B      $D4,$80,$80,'OW2NT' 
  DC.B      $00,$CF,$C3,$CE,'AA',$00,$CF
  DC.B      $80,'N',$C7,'OH',$00,$CF,$03
  DC.B      $08,$81,$CE,'OH',$00,'O',$CE
  DC.B      $C9,$80,'UN',$00,'O',$CE,$08
  DC.B      $82,$81,'UN',$00,'O',$CE,$03
  DC.B      $82,$80,'UN',$00,$CF,$80,'S'
  DC.B      'TOW',$00,'O',$C6,$80
  DC.B      $83,'AO2F',$00,'OT' 
  DC.B      'HE',$D2,$80,$80,'AH1'
  DC.B      'DHER',$00,$CF,$D2,$C2
  DC.B      'AA',$00,$CF,'R',$83,$08,$82
  DC.B      'OW1',$00,'OS',$D3,$80
  DC.B      $81,'AO1S',$00,'O',$CD
  DC.B      $03,$08,$82,$80,'AHM',$00 
  DC.B      $CF,$80,$80,'AA',$00,$D0,$81
  DC.B      $81,'PIY2',$00,'P',$C8
  DC.B      $80,$80,'F',$00,'PEOP'
  DC.B      $CC,$80,$80,'PIY1P' 
  DC.B      'UL',$00,'PO',$D7,$80,$80 
  DC.B      'PAW2',$00,'PU',$D4 
  DC.B      $80,$81,'PUHT',$00,$D0
  DC.B      $80,$D0,$00,$D0,$81,$D3,$00,$D0 
  DC.B      $81,$CE,$00,'PROF',$AE
  DC.B      $81,$80,'PROHFE'
  DC.B      'H2SER',$00,$D0,$80 
  DC.B      $80,'P',$00,$D1,$81,$81,'KY'
  DC.B      'UW2',$00,'QUA',$D2 
  DC.B      $80,$80,'KWOH1R'
  DC.B      $00,'QU',$C9,$80,'R',$C5,'K'
  DC.B      'WAY1',$00,'Q',$D5,$80
  DC.B      $80,'KW',$00,$D1,$80,$80,'K'
  DC.B      $00,$D2,$81,$81,'AA1R'
  DC.B      $00,'RHYM',$C5,$80,$80
  DC.B      'RAY1M',$00,'RU'
  DC.B      $CC,$81,$80,'RUX1L' 
  DC.B      $00,'R',$C5,$81,'T',$82,'RI'
  DC.B      'Y',$00,'ROUTIN'
  DC.B      $C5,$80,$80,'RUWTI' 
  DC.B      'Y1N',$00,$D2,$80,$D2,$00 
  DC.B      $D2,$80,$80,'R',$00,$D3,$81,$81 
  DC.B      'EH2S',$00,'S',$C8,$80
  DC.B      $80,'SH',$00,'SIO',$CE
  DC.B      $82,$80,'ZHUN',$00,'S'
  DC.B      'OM',$C5,$80,$80,'SAH'
  DC.B      'M',$00,'SU',$D2,$82,$82,'Z'
  DC.B      'HER',$00,'SU',$D2,$80
  DC.B      $82,'SHER',$00,'S',$D5
  DC.B      $82,$82,'ZHUW',$00,'S'
  DC.B      'S',$D5,$82,$82,'SHUW'
  DC.B      $00,'SE',$C4,$82,$81,'ZD' 
  DC.B      $00,$D3,$82,$82,'Z',$00,'SA'
  DC.B      'I',$C4,$80,$80,'SEHD'
  DC.B      $00,'SIO',$CE,$83,$80,'S' 
  DC.B      'HUN',$00,$D3,$80,$D3,$00 
  DC.B      $D3,$84,$81,'Z',$00,$D3,'E',$04 
  DC.B      $08,$82,$81,'Z',$00,$D3,$02,$03 
  DC.B      $08,$82,$81,'S',$00,$D3,$D5,$81 
  DC.B      'S',$00,$D3,$02,$08,$81,$81,'Z' 
  DC.B      $00,$D3,$02,$82,$81,'Z',$00,'S' 
  DC.B      'C',$C8,$81,$80,'SK',$00,$D3
  DC.B      $80,'C',$87,$00,'S',$CD,$82,$80 
  DC.B      'ZUM',$00,'SN',$27,$D4
  DC.B      $82,$80,'ZUNT',$00,'S'
  DC.B      'TL',$C5,$80,$80,'SUL'
  DC.B      $00,$D3,$80,$80,'S',$00,$D4,$81 
  DC.B      $81,'TIY2',$00,'TH' 
  DC.B      $C5,$81,$01,$82,'DHIY'
  DC.B      $00,'TH',$C5,$81,$81,'DH' 
  DC.B      'AX',$00,'T',$CF,$81,$81,'T'
  DC.B      'UX',$00,'T',$CF,'N',$02,$81
  DC.B      $81,'TUX',$00,'T',$CF,$81 
  DC.B      'G',$C5,'TUX',$00,'TO'
  DC.B      'M',$C2,$80,$80,'TUX1'
  DC.B      'M',$00,'T',$CF,$80,'NIG' 
  DC.B      'H',$D4,'TUX',$00,'T',$CF 
  DC.B      $80,$81,'TOW',$00,'TH'
  DC.B      'A',$D4,$81,$80,'DHAE'
  DC.B      'T',$00,'THI',$D3,$81,$81 
  DC.B      'DHIHS',$00,'TH'
  DC.B      'E',$D9,$81,$80,'DHEY'
  DC.B      $00,'THER',$C5,$81,$80
  DC.B      'DHEHR',$00,'TH'
  DC.B      'E',$D2,$80,$80,'DHER'
  DC.B      $00,'THEI',$D2,$80,$80
  DC.B      'DHEHR',$00,'TH'
  DC.B      'A',$CE,$81,$81,'DHAE'
  DC.B      'N',$00,'THE',$CD,$81,$81 
  DC.B      'DHEHM',$00,'TH'
  DC.B      'ES',$C5,$80,$81,'DHI'
  DC.B      'YZ',$00,'THE',$CE,$81
  DC.B      $80,'DHEHN',$00,'T' 
  DC.B      'HROUG',$C8,$80,$80 
  DC.B      'THRUW2',$00,'T'
  DC.B      'HOS',$C5,$80,$80,'DH'
  DC.B      'OHZ',$00,'THOU'
  DC.B      'G',$C8,$80,$81,'DHOW'
  DC.B      $00,'TODA',$D9,$80,$80
  DC.B      'TUXDEY',$00,'T'
  DC.B      'OM',$CF,$80,'RRO',$D7
  DC.B      'TUMAA1',$00,'T'
  DC.B      $CF,$80,'TA',$CC,'TOW'
  DC.B      '1',$00,'THU',$D3,$81,$80 
  DC.B      'DHAH2S',$00,'T'
  DC.B      $C8,$80,$80,'TH',$00,'TE' 
  DC.B      $C4,$08,$82,$81,'TIXD'
  DC.B      $00,'T',$C9,$D3,$02,$CE,'CH'
  DC.B      $00,'T',$C9,$80,$CF,'SH',$00
  DC.B      'T',$C9,$80,$C1,'SH',$00,'T'
  DC.B      'IE',$CE,$80,$80,'SHU'
  DC.B      'N',$00,'TU',$D2,$80,$82,'C'
  DC.B      'HER',$00,'T',$D5,$80,$C1 
  DC.B      'CHUW',$00,'TW',$CF 
  DC.B      $81,$80,'TUW',$00,$D4,$D4 
  DC.B      $80,$00,$D4,$80,'C',$C8,$00,$D4 
  DC.B      $85,'EN',$81,$00,$D4,$80,$80
  DC.B      'T',$00,$D5,$81,$81,'YUW' 
  DC.B      '2',$00,'UL',$CC,$C2,$80,'U'
  DC.B      'XL',$00,'UL',$CC,$84,$80 
  DC.B      'UHL',$00,'UL',$CC,$80
  DC.B      $80,'UXL',$00,'U',$CE,$83 
  DC.B      'EYUWN',$00,'U'
  DC.B      $CE,$81,'I',$CE,'UH',$00,'U'
  DC.B      $CE,$81,$C9,'YUWN',$00
  DC.B      'U',$CE,$81,$80,'AHN',$00 
  DC.B      'UPO',$CE,$81,$80,'AX'
  DC.B      'PAON',$00,'U',$D2,$86
  DC.B      $82,'UH2R',$00,'U',$D2
  DC.B      $80,$82,'YUH2R',$00 
  DC.B      'U',$D2,$80,$80,'ER',$00,'U'
  DC.B      $D9,$80,$80,'AY1',$00,$D5 
  DC.B      $80,$03,$81,'UH',$00,'UL' 
  DC.B      $C5,$80,$81,'YUWL',$00
  DC.B      $D5,$80,$03,$83,'AH1',$00 
  DC.B      $D5,'G',$81,$82,$00,$D5,$C7,$89 
  DC.B      $00,$D5,$C7,$82,'W',$00,$D5,'N' 
  DC.B      $82,$80,'YUW',$00,$D5,$86 
  DC.B      $80,'UW',$00,$D5,$80,$80,'Y'
  DC.B      'UW',$00,$D6,$81,$81,'VI' 
  DC.B      'Y2',$00,'VIE',$D7,$80
  DC.B      $80,'VYUW1',$00,'V' 
  DC.B      'AL',$D5,$80,$80,'VAE'
  DC.B      '1LYUW',$00,$D6,$80 
  DC.B      $80,'V',$00,$D7,$81,$81,'DA'
  DC.B      'H2BULYUW'
  DC.B      $00,'WER',$C5,$81,$80,'W' 
  DC.B      'ER',$00,'W',$C1,$80,'S',$C8
  DC.B      'WAA',$00,'W',$C1,$80,'S' 
  DC.B      $D4,'WEY',$00,'W',$C1,$80 
  DC.B      $D3,'WAH',$00,'W',$C1,$80 
  DC.B      $D4,'WAA',$00,'WHE' 
  DC.B      'R',$C5,$80,$80,'WEHR'
  DC.B      $00,'WHA',$D4,$80,$80,'W' 
  DC.B      'AHT',$00,'WHO',$CC 
  DC.B      $80,$80,'/HOWL',$00 
  DC.B      'WH',$CF,$80,$80,'/HU'
  DC.B      'W',$00,'W',$C8,$80,$80,'W',$00 
  DC.B      'WA',$D2,$80,$82,'WEH'
  DC.B      'R',$00,'WA',$D2,$80,$80,'W'
  DC.B      'AOR',$00,'WO',$D2,$80
  DC.B      $83,'WER',$00,'W',$D2,$80 
  DC.B      $80,'R',$00,'WO',$CD,$80,$C1
  DC.B      'WUHM',$00,'WO',$CD 
  DC.B      $80,$C5,'WUM',$00,'WE'
  DC.B      $C1,$80,$D2,'WEH',$00,'W' 
  DC.B      'AN',$D4,$80,$80,'WAA'
  DC.B      '1NT',$00,$D7,$80,$80,'W' 
  DC.B      $00,$D8,$81,$81,'EH2K'
  DC.B      'S',$00,$D8,$81,$80,'Z',$00,$D8 
  DC.B      $80,$80,'KS',$00,$D9,$81,$81
  DC.B      'WAY2',$00,'YOU'
  DC.B      'N',$C7,$80,$80,'YAHN'
  DC.B      'X',$00,'YOU',$D2,$81,$80 
  DC.B      'YOHR',$00,'YO',$D5 
  DC.B      $81,$80,'YUW',$00,'YE'
  DC.B      $D3,$81,$80,'YEHS',$00
  DC.B      $D9,$81,$80,'Y',$00,'YC',$C8
  DC.B      'S',$D0,$80,'AYK',$00,$D9 
  DC.B      $03,$08,$82,$81,'IY',$00,$D9
  DC.B      $03,$08,$82,$C9,'IY',$00,$D9
  DC.B      $08,$81,$81,'AY',$00,$D9,$08
  DC.B      $81,$82,'AY',$00,$D9,$08,$81
  DC.B      $03,$07,$08,$82,'IH',$00,$D9
  DC.B      $08,$81,$03,$82,'AY',$00,$D9
  DC.B      $C6,$80,'AY',$00,$D9,$80,$80
  DC.B      'IH',$00,$DA,$81,$81,'ZE' 
  DC.B      'H1D',$00,$DA,$80,$80,'Z' 
  DC.B      $00,$00 
L0044:
  DC.B      $EC,$E6,$EE,$D7,$F0,$C1,$F1,'"' 
  DC.B      $F1,$FC,$F2,'{',$F4,$0E,$F4,'@' 
  DC.B      $F4,$B6,$F4,$F9,$F6,'j',$F6,$84 
  DC.B      $F6,$95,$F6,$F4,$F7,'S',$F7,$BE 
  DC.B      $FA,$A4,$FA,$F9,$FB,$27,$FB,'k' 
  DC.B      $FC,'4',$FD,$C8,$FE,'y',$FE,$A1 
  DC.B      $FF,'_',$FF,'s',$FF,$F1 

L00E3:
  DS.B      1 
PHOBUFF:
  DS.B      257 


;*********

_say:
say:
	link	a6,#0
	movem.l	d1-d7/a0-a5,-(sp)
	move	8(a6),d0
	cmpi	#3,d0
	bne	saymd			; mode 3: test
	move.l	P3ae2,d0
	beq	realbye
	moveq	#1,d0
	bra	realbye
saymd:
	move	d0,saymode
waitp:
	tst.l	P3ae2			; attend la fin de la phrase
	bne	waitp			; precedente
testptr:
	move.l	10(a6),d0		; si ptr = 0, sortie
	beq	bye
	move.l	d0,a0
	tst.b	(a0)			; si chaine vide, repetition
	bne	decod
	move	badbuf,d0
	beq	repeat			; ... apres verif du buffer
	bra	bye
decod:
	bsr	stopsnd
	bsr	decode			; traitement de la phrase
	tst.l	d0			; sortie si elle est incorrecte
	bne	badret
	lea	phoneme(pc),a1
	lea	P44c2(pc),a5
	bsr	S196a			; traite les AY OY
	bsr	S1a68
	bsr	S1a9a
	bsr	S1ac4
	bsr	S1b08
	bsr	S1b5a
repeat:
	bsr	S2076

	moveq	#0,d0
badret:	move	d0,badbuf
bye:
	cmpi	#1,saymode		; en mode 1,
	bne	realbye			; attend la fin de phrase
waitend:
	tst.l	P3ae2
	bne	waitend
realbye:
	movem.l	(sp)+,d1-d7/a0-a5
	unlk	a6
	rts

uppercase:
	cmpi.b	#$61,d0
	bcs	L18a0
	cmpi.b	#$7b,d0
	bcc	L18a0
	subi.b	#$20,d0
L18a0:	rts

;*****************************************************************************
; entree: a0 = phrase
; decode les phonemes dans 'buffer'
; format de buffer: groupes de 4 octets termines par un mot a $FFFFFFFF
;	2 octets:	rang dans la table des phonemes
;	2 octets:	bits 0..3: hauteur, bit 6: raccourci, bit 7: rallonge
;*****************************************************************************
; decodes phonetic text to phoneme structure list

decode:	lea	buffer,a1
L18a6:	move.l	#$ffffffff,(a1)
	move.b	(a0)+,d0
	beq	L193a

	cmpi.b	#$31,d0			; chiffre 1..9
	bcs	L18d0
	cmpi.b	#$3a,d0
	bcc	L18d0
	subi.b	#$30,d0
	tst.b	-2(a1)
	bne	L1924
	move.b	d0,-2(a1)
	bra	L18a6

L18d0:	cmpi.b	#$3e,d0			; '>'
	bne	L18e4
	move.b	-2(a1),d1
	andi.b	#$C0,d1
	bne	L1924
	ori.b	#$80,-2(a1)
	bra	L18a6

L18e4:	cmpi.b	#$3c,d0			; '<'
	bne	L18f8
	move.b	-2(a1),d1
	andi.b	#$C0,d1
	bne	L1924
	ori.b	#$40,-2(a1)
	bra	L18a6

L18f8:	bsr	uppercase
	move.b	d0,d1
	move.b	(a0),d0
	bsr	uppercase
	lea	phoneme(pc),a2
	moveq	#0,d2
L1906:	cmp.b	0(a2,d2.w),d1
	bne	L191a
	cmpi.b	#$20,1(a2,d2.w)
	beq	L192a
	cmp.b	1(a2,d2.w),d0
	beq	L1928
L191a:	addi.w	#34,d2
	tst.b	0(a2,d2.w)
	bpl	L1906
L1924:	moveq	#-1,d0
	rts

L1928:	addq.l	#1,a0
L192a:	move	d2,(a1)+
	clr.w	(a1)+
	cmpa.l	#buffer+1024,a1
	beq	L1924
	bra	L18a6

L193a:	cmpi	#2,saymode
	beq	Lend
	move	#_Q-phoneme,(a1)+
	clr.w	(a1)+
Lend:
	move.l	#$ffffffff,(a1)+
Lret:	moveq	#0,d0
	rts

;*********
; decale le buffer pour inserer 4 octets: d1.w d2.b et d3.b
;
insert:
	move.l	a1,-(a7)
	lea	buffer+1020,a1
L1950:	cmpa.l	a0,a1
	beq	L195a
	move.l	-(a1),4(a1)
	bra	L1950
L195a:	move	d1,0(a0)
	move.b	d2,2(a0)
	move.b	d3,3(a0)
	movea.l	(a7)+,a1
	rts

;************

S196a:
	lea	buffer,a0
L196e:	moveq	#0,d0
	move	(a0),d0
	bmi	L1a66
	cmpi	#_SPACE-phoneme,d0
	beq	L1a5e
	ble	L199a
	move	2(a1,d0.w),(a0)
	move	4(a1,d0.w),d1
	move.b	2(a0),d2
	moveq	#0,d3
	addq.l	#4,a0
	bsr	insert
	subq.l	#4,a0
	move	(a0),d0

L199a:	cmpi	#_UW-phoneme,d0
	bgt	L19bc
	move	#$0110,d1
	cmpi	#$0044,d0
	ble	L19ae
	move	#$00ee,d1
L19ae:	move.b	2(a0),d2
	moveq	#0,d3
	addq.l	#4,a0
	bsr	insert
	subq.l	#4,a0
	move	(a0),d0
L19bc:	cmpi	#_R-phoneme,d0
	bne	L19e8
	move	-4(a0),d1
	bmi	L1a5e
	cmpi	#_EH-phoneme,d1
	bgt	L1a5e
	move	4(a0),d1
	bmi	L19e0
	cmpi	#_EH-phoneme,d1
	ble	L1a5e
L19e0:	move	#_RX-phoneme,(a0)
	bra	L1a5e
L19e8:	cmpi	#_L-phoneme,d0
	bne	L1a14
	move	-4(a0),d1
	bmi	L1a5e
	cmpi	#_EH-phoneme,d1
	bgt	L1a5e
	move	4(a0),d1
	bmi	L1a0e
	cmpi	#_EH-phoneme,d1
	ble	L1a5e
L1a0e:	move	#_LX-phoneme,(a0)
	bra	L1a5e
L1a14:	cmpi	#_S-phoneme,d0
	bne	L1a5e
	cmpi	#_G-phoneme,-4(a0)
	bne	L1a28
	move	#_Z-phoneme,(a0)
	bra	L1a5e
L1a28:	cmpi	#_EH-phoneme,8(a0)
	bgt	L1a5e
	cmpi	#_P-phoneme,4(a0)
	bne	L1a40
	move	#_B-phoneme,4(a0)
	bra	L1a5e
L1a40:	cmpi	#_T-phoneme,4(a0)
	bne	L1a50
	move	#_D-phoneme,4(a0)
	bra	L1a5e
L1a50:	cmpi	#_K-phoneme,4(a0)
	bne	L1a5e
	move	#_G-phoneme,4(a0)
L1a5e:	addq.l	#4,a0
	tst.w	(a0)
	bpl	L196e
L1a66:	rts

;**********

S1a68:
	lea	buffer,a0
	moveq	#0,d0
L1a6e:	move	(a0),d0
	bpl	L1a74
	rts
L1a74:	cmpi	#_EH-phoneme,d0
	ble	L1a96
	cmpi	#_S-phoneme,d0
	bge	L1a96
	move	4(a0),d0
	bmi	L1a96
	cmpi	#_EH-phoneme,d0
	bgt	L1a96
	move.b	6(a0),d0
	beq	L1a96
	move.b	d0,2(a0)
L1a96:	addq.l	#4,a0
	bra	L1a6e

;***********

S1a9a:
	lea	buffer,a0
L1a9e:	move	(a0),d0
	bmi	L1ac2
	btst	#7,32(a1,d0.w)
	beq	L1abe
	move	d0,d1
	addi.w	#34,d1
	move.b	2(a0),d2
	moveq	#0,d3
	addq.l	#4,a0
	bsr	insert
	bra	L1a9e
L1abe:	addq.l	#4,a0
	bra	L1a9e
L1ac2:	rts

;*********

S1ac4:
	lea	buffer,a0
	moveq	#0,d0
L1aca:	move	(a0),d0
	bpl	L1ad0
	rts
L1ad0:	move.b	3(a1,d0.w),d1
	move.b	2(a0),d2
	bpl	L1ae4
	move.b	d1,d3
	lsr.b	#1,d3
	addq.b	#1,d3
	add.b	d3,d1
	bra	L1af8
L1ae4:	btst	#6,d2
	beq	L1af0
	lsr.b	#1,d1
	addq.b	#1,d1
	bra	L1af8
L1af0:	tst.b	d2
	beq	L1af8
	move.b	2(a1,d0.w),d1
L1af8:	andi.w	#$3f,d2
	move.b	d2,2(a0)
	move.b	d1,3(a0)
	addq.l	#4,a0
	bra	L1aca

;***********

S1b08:
	lea	buffer,a0
	moveq	#0,d0
L1b0e:	move	(a0),d0
	bmi	L1b58
	cmpi	#_S-phoneme,d0
	ble	L1b54
	moveq	#0,d4
L1b1a:	subq.l	#4,d4
	move	0(a0,d4.w),d0
	bmi	L1b54
	cmpi	#_S-phoneme,d0
	bgt	L1b50
	cmpi	#_EH-phoneme,d0
	bgt	L1b1a
	bra	L1b50
L1b30:	move	0(a0,d4.w),d0
	btst	#5,32(a1,d0.w)
	beq	L1b44
	btst	#6,32(a1,d0.w)
	beq	L1b50
L1b44:	move.b	3(a0,d4.w),d1
	lsr.b	#1,d1
	addq.b	#1,d1
	add.b	d1,3(a0,d4.w)
L1b50:	addq.l	#4,d4
	bne	L1b30
L1b54:	addq.l	#4,a0
	bra	L1b0e
L1b58:	rts

;**********

S1b5a:
	lea	buffer,a0
	lea	spchbuff,a2
	moveq	#0,d0			; efface le buffer de parole (9 ko)
	move	#$011f,d1
L1b70:	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	dbra	d1,L1b70

	lea	spchbuff,a2
	moveq	#0,d1
	move.b	d0,20(a5)
	move.b	d0,21(a5)
L1b92:	move	(a0),d0
	bmi	L1e12
	move	4(a1,d0.w),2(a5)
	move	8(a1,d0.w),8(a5)
	move	12(a1,d0.w),14(a5)
	move.b	21(a1,d0.w),5(a5)
	move.b	23(a1,d0.w),11(a5)
	move.b	25(a1,d0.w),17(a5)
	move.b	27(a1,d0.w),19(a5)
	moveq	#0,d4
	move	d4,24(a5)
	move	d4,26(a5)
	move.b	20(a5),d4
	cmp.b	3(a0),d4
	ble	L1bdc
	move.b	3(a0),20(a5)
L1bdc:	move.b	21(a5),d4
	cmp.b	3(a0),d4
	ble	L1bec
	move.b	3(a0),21(a5)
L1bec:	bsr	S1f04
	move.b	20(a5),24(a5)
	move.b	21(a5),26(a5)
	move	2(a5),0(a5)
	move	8(a5),6(a5)
	move	14(a5),12(a5)
	move.b	5(a5),4(a5)
	move.b	11(a5),10(a5)
	move.b	17(a5),16(a5)
	move.b	19(a5),18(a5)
	move	4(a0),d1
	bmi	L1e12
	move.b	$0010(a1,d0.w),d2
	cmp.b	$0010(a1,d1.w),d2
	bge	L1c54
	move.b	$0014(a1,d1.w),$0016(a5)
	move.b	$0013(a1,d1.w),$0014(a5)
	move.b	$001f(a1,d1.w),$0017(a5)
	move.b	$001e(a1,d1.w),$0015(a5)
	exg	d0,d1
	bra	L1c6c
L1c54:	move.b	$0014(a1,d0.w),$0014(a5)
	move.b	$0013(a1,d0.w),$0016(a5)
	move.b	$001f(a1,d0.w),$0015(a5)
	move.b	$001e(a1,d0.w),$0017(a5)
L1c6c:	move.b	$0003(a0),d6
	cmp.b	$0014(a5),d6
	bge	L1c7a
	move.b	d6,$0014(a5)
L1c7a:	cmp.b	$0015(a5),d6
	bge	L1c84
	move.b	d6,$0015(a5)
L1c84:	cmpi	#_R-phoneme,d1
	bne	L1c8e
	moveq	#$00,d2
	bra	L1c9a
L1c8e:	move	$0004(a1,d1.w),d2
	move.b	$0011(a1,d0.w),d3
	bsr	S204c
L1c9a:	add.w	$0006(a1,d0.w),d2
	move	d2,$0002(a5)
	move	$0008(a1,d1.w),d2
	move.b	$0011(a1,d0.w),d3
	bsr	S204c
	add.w	$000a(a1,d0.w),d2
	move	d2,$0008(a5)
	move	$000c(a1,d1.w),d2
	move.b	$0012(a1,d0.w),d3
	bsr	S204c
	add.w	$000e(a1,d0.w),d2
	move	d2,$000e(a5)
	move.b	$0015(a1,d1.w),d2
	ext.w	d2
	move.b	$001d(a1,d0.w),d3
	bsr	S204c
	add.b	$0016(a1,d0.w),d2
	move.b	d2,$0005(a5)
	move.b	$0017(a1,d1.w),d2
	ext.w	d2
	move.b	$001d(a1,d0.w),d3
	bsr	S204c
	add.b	$0018(a1,d0.w),d2
	move.b	d2,$000b(a5)
	move.b	$0019(a1,d1.w),d2
	ext.w	d2
	move.b	$001d(a1,d0.w),d3
	bsr	S204c
	add.b	$001a(a1,d0.w),d2
	move.b	d2,$0011(a5)
	move.b	$001b(a1,d1.w),d2
	ext.w	d2
	move.b	$001d(a1,d0.w),d3
	bsr	S204c
	add.b	$001c(a1,d0.w),d2
	move.b	d2,$0013(a5)
	moveq	#$00,d2
	move.b	$0003(a0),d2
	sub.b	$0018(a5),d2
	sub.b	$0014(a5),d2
	ble	L1d6e
	moveq	#$00,d3
	move.b	$0018(a5),d3
	mulu	#$0009,d3
	bra	L1d6a
L1d3e:	move	$0000(a5),d7
	bsr	S205c
	move.b	d7,$0003(a2,d3.w)
	move	$0006(a5),d7
	bsr	S205c
	move.b	d7,$0005(a2,d3.w)
	move	$000c(a5),d7
	bsr	S205c
	move.b	d7,$0007(a2,d3.w)
	addi.w	#$0009,d3
	addq.b	#1,$0018(a5)
L1d6a:	dbra	d2,L1d3e
L1d6e:	moveq	#$00,d2
	move.b	$0003(a0),d2
	sub.b	$001a(a5),d2
	sub.b	$0015(a5),d2
	ble	L1dc6
	moveq	#$00,d3
	move.b	$001a(a5),d3
	mulu	#9,d3
	bra	L1dc2
L1d8a:	move.b	4(a5),d7
	bsr	S2064
	move.b	d7,4(a2,d3.w)
	move.b	10(a5),d7
	bsr	S2064
	move.b	d7,6(a2,d3.w)
	move.b	16(a5),d7
	bsr	S2064
	move.b	d7,8(a2,d3.w)
	move.b	18(a5),d7
	bsr	S2064
	move.b	d7,1(a2,d3.w)
	addi.w	#9,d3
	addq.b	#1,$001a(a5)
L1dc2:	dbra	d2,L1d8a
L1dc6:	bsr	S1f04
	move	$0002(a5),$0000(a5)
	move	$0008(a5),$0006(a5)
	move	$000e(a5),$000c(a5)
	move.b	$0005(a5),$0004(a5)
	move.b	$000b(a5),$000a(a5)
	move.b	$0011(a5),$0010(a5)
	move.b	$0013(a5),$0012(a5)
	move.b	$0016(a5),$0014(a5)
	move.b	$0017(a5),$0015(a5)
	moveq	#0,d0
	move.b	3(a0),d0
	mulu	#9,d0
	adda.l	d0,a2
	addq.l	#4,a0
	bra	L1b92
L1e12:	clr.b	(a2)
	lea	spchbuff,a2
	lea	buffer,a0
L1e1c:	move	(a0),d0
	bmi	L1e3c
	moveq	#0,d1
	move.b	3(a0),d1
	move.b	$0021(a1,d0.w),d2
	bra	L1e34
L1e2c:	move.b	d2,2(a2)
	adda.w	#9,a2
L1e34:	dbra	d1,L1e2c
	addq.l	#4,a0
	bra	L1e1c

L1e3c:	lea	buffer,a0
	lea	spchbuff,a2
	moveq	#$42,d0
	moveq	#0,d2
L1e48:	move	(a0),d4
	bmi	L1f02
	moveq	#$00,d5
	move.b	3(a0),d5
	subq.b	#1,d5
	blt	L1e84
	cmpi	#_SPACE-phoneme,d4
	beq	L1e6a
	cmpi	#_S-phoneme,d4
	bgt	L1ea8
	tst.b	2(a0)
	bne	L1e88
L1e6a:	move.b	d0,0(a2)
	cmpi.b	#$42,d0
	beq	L1e7c
	blt	L1e7a
	subq.b	#1,d0
	bra	L1e7c
L1e7a:	addq.b	#1,d0
L1e7c:	adda.w	#9,a2
	dbra	d5,L1e6a

L1e84:	addq.l	#4,a0
	bra	L1e48

L1e88:	moveq	#0,d0
	move.b	2(a0),d0
	move.b	d0,d7
	add.b	d0,d0
	add.b	d7,d0
	neg.b	d0
	addi.b	#$42,d0
L1e9a:	move.b	d0,0(a2)
	adda.w	#9,a2
	dbra	d5,L1e9a
	bra	L1e84

L1ea8:	moveq	#-$14,d2
	moveq	#0,d3
L1eac:	subi.w	#4,d3
	tst.w	0(a0,d3.w)
	bmi	L1ec8
	cmpi	#_S-phoneme,0(a0,d3.w)
	bgt	L1ec8
	moveq	#0,d4
	add.b	3(a0,d3.w),d2
	blt	L1eac
	moveq	#$00,d2
L1ec8:	addi.b	#$14,d2
	beq	L1efc
	cmpi	#$0880,(a0)
	bne	L1ed8
	moveq	#$01,d1
	bra	L1ee8
L1ed8:	cmpi	#$08c4,(a0)
	bne	L1ee2
	moveq	#-1,d1
	bra	L1ee8
L1ee2:	moveq	#$01,d1
	lsr.b	#1,d2
	addq.b	#1,d2
L1ee8:	ext.w	d2
	muls	#-9,d2
	moveq	#0,d3
L1ef0:	add.b	d1,d3
	add.b	d3,0(a2,d2.w)
	addi	#9,d2
	ble	L1ef0
L1efc:	moveq	#$42,d0
	bra	L1e6a
L1f02:	rts

;**********

S1f04:
	movem.l	d0-d7,-(a7)
	moveq	#0,d0
	move.b	24(a5),d0
	mulu	#9,d0
	lea	0(a2,d0.w),a3
	move	0(a5),d0
	move	2(a5),d1
	lea	3(a3),a4
	moveq	#0,d2
	move.b	20(a5),d2
	bsr	S1fc4
	move	6(a5),d0
	move	8(a5),d1
	lea	5(a3),a4
	moveq	#0,d2
	move.b	20(a5),d2
	bsr	S1fc4
	move	12(a5),d0
	move	14(a5),d1
	lea	7(a3),a4
	moveq	#0,d2
	move.b	20(a5),d2
	bsr	S1fc4
	moveq	#0,d0
	move.b	26(a5),d0
	mulu	#9,d0
	lea	0(a2,d0.w),a3
	move.b	4(a5),d0
	move.b	5(a5),d1
	lea	4(a3),a4
	moveq	#0,d2
	move.b	21(a5),d2
	bsr	S1ffe
	move.b	10(a5),d0
	move.b	11(a5),d1
	lea	6(a3),a4
	moveq	#0,d2
	move.b	21(a5),d2
	bsr	S1ffe
	move.b	16(a5),d0
	move.b	17(a5),d1
	lea	8(a3),a4
	moveq	#0,d2
	move.b	21(a5),d2
	bsr	S1ffe
	move.b	18(a5),d0
	move.b	19(a5),d1
	lea	1(a3),a4
	moveq	#0,d2
	move.b	21(a5),d2
	bsr	S1ffe
	movem.l	(a7)+,d0-d7
	rts

;**********

S1fc4:
	tst.b	d2
	beq	L1ffc
	move	d1,d3
	sub.w	d0,d3
	ext.l	d3
	divs	d2,d3
	move	d3,d4
	asr.w	#1,d4
	add.w	d4,d0
	bra	L1ff8
L1fd8:	move	d0,d7
	bsr	S205c
	tst.b	(a4)
	beq	L1ff0
	tst.l	d3
	bmi	L1fec
	cmp.b	(a4),d7
	bgt	L1ff0
	bra	L1ff2
L1fec:	cmp.b	(a4),d7
	bge	L1ff2
L1ff0:	move.b	d7,(a4)
L1ff2:	add.w	d3,d0
	adda.w	#9,a4
L1ff8:	dbra	d2,L1fd8
L1ffc:	rts

;**********

S1ffe:
	tst.b	d2
	beq	L204a
	andi.l	#$ff,d0
	move.b	d1,d3
	sub.b	d0,d3
	lsl.w	#8,d3
	ext.l	d3
	divs	d2,d3
	ext.l	d3
	lsl.l	#8,d3
	move.l	d3,d4
	asr.l	#1,d4
	swap	d0
	add.l	d4,d0
	swap	d0
	bra	L2046
L2022:	move.b	d0,d7
	bsr	S2064
	tst.b	(a4)
	beq	L203a
	tst.l	d3
	bmi	L2036
	cmp.b	(a4),d7
	bgt	L203a
	bra	L203c
L2036:	cmp.b	(a4),d7
	bge	L203c
L203a:	move.b	d7,(a4)
L203c:	swap	d0
	add.l	d3,d0
	swap	d0
	adda.w	#9,a4
L2046:	dbra	d2,L2022
L204a:	rts

;**********

S204c:
	tst.b	d3
	beq	L2058
	subq.b	#1,d3
	bne	L2056
	asr.w	#1,d2
L2056:	rts
L2058:	moveq	#0,d2
	rts
S205c:
	addi.w	#16,d7
	lsr.w	#5,d7
	rts

;**********

S2064:
	move.b	d7,d6
	add.b	d6,d6
	add.b	d6,d7
	subi.b	#$59,d7
	bpl	L2072
	moveq	#$00,d7
L2072:	lsr.b	#2,d7
	rts

;**********

S2076:
	moveq	#$00,d0
	moveq	#$00,d1
	move.b	__set_pitc(pc),d0
	move.b	d0,use_pitc
	move.b	__set_rate(pc),d1
	mulu	#$004d,d1
	divu	d0,d1
	move.b	d1,use_rate
	clr.b	P3ae6
	move.l	#spchbuff,P3ae2
	pea	opwaves(pc)
	move	d0,-(a7)
	move	#1,-(a7)
	clr	-(a7)
	move	#31,-(a7)
	trap	#14
	adda.w	#12,a7
	rts

;	data

; this is a wave table.. each wave is 256 samples (bytes) long.
; each wave if pre-amplified (16 levels of amp).
P20ca:	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001
	dc.w	$0101,$0101,$0101,$0101,$0101,$0101,$0101,$0101
	dc.w	$0202,$0202,$0202,$0202,$0202,$0202,$0202,$0202
	dc.w	$0202,$0202,$0202,$0202,$0202,$0202,$0202,$0202
	dc.w	$0202,$0202,$0202,$0202,$0202,$0202,$0202,$0202
	dc.w	$0202,$0202,$0202,$0202,$0202,$0202,$0202,$0202
	dc.w	$0201,$0101,$0101,$0101,$0101,$0101,$0101,$0101
	dc.w	$0101,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$00FF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE
	dc.w	$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE
	dc.w	$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE
	dc.w	$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE
	dc.w	$FEFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0101,$0101,$0101,$0102
	dc.w	$0202,$0202,$0202,$0203,$0303,$0303,$0303,$0303
	dc.w	$0404,$0404,$0404,$0404,$0404,$0404,$0405,$0505
	dc.w	$0505,$0505,$0505,$0505,$0505,$0505,$0505,$0505
	dc.w	$0505,$0505,$0505,$0505,$0505,$0505,$0505,$0505
	dc.w	$0505,$0505,$0404,$0404,$0404,$0404,$0404,$0404
	dc.w	$0403,$0303,$0303,$0303,$0303,$0202,$0202,$0202
	dc.w	$0202,$0101,$0101,$0101,$0100,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$FEFE,$FEFE,$FEFE,$FEFD,$FDFD,$FDFD,$FDFD,$FDFD
	dc.w	$FCFC,$FCFC,$FCFC,$FCFC,$FCFC,$FCFC,$FCFB,$FBFB
	dc.w	$FBFB,$FBFB,$FBFB,$FBFB,$FBFB,$FBFB,$FBFB,$FBFB
	dc.w	$FBFB,$FBFB,$FBFB,$FBFB,$FBFB,$FBFB,$FBFB,$FBFB
	dc.w	$FBFB,$FBFB,$FCFC,$FCFC,$FCFC,$FCFC,$FCFC,$FCFC
	dc.w	$FCFD,$FDFD,$FDFD,$FDFD,$FDFD,$FEFE,$FEFE,$FEFE
	dc.w	$FEFE,$FFFF,$FFFF,$FFFF,$FF00,$0000,$0000,$0000
	dc.w	$0000,$0000,$0001,$0101,$0101,$0202,$0202,$0203
	dc.w	$0303,$0303,$0404,$0404,$0404,$0505,$0505,$0505
	dc.w	$0606,$0606,$0606,$0606,$0707,$0707,$0707,$0707
	dc.w	$0707,$0808,$0808,$0808,$0808,$0808,$0808,$0808
	dc.w	$0808,$0808,$0808,$0808,$0808,$0808,$0808,$0807
	dc.w	$0707,$0707,$0707,$0707,$0706,$0606,$0606,$0606
	dc.w	$0605,$0505,$0505,$0504,$0404,$0404,$0403,$0303
	dc.w	$0303,$0202,$0202,$0201,$0101,$0101,$0000,$0000
	dc.w	$0000,$0000,$00FF,$FFFF,$FFFF,$FEFE,$FEFE,$FEFD
	dc.w	$FDFD,$FDFD,$FCFC,$FCFC,$FCFC,$FBFB,$FBFB,$FBFB
	dc.w	$FAFA,$FAFA,$FAFA,$FAFA,$F9F9,$F9F9,$F9F9,$F9F9
	dc.w	$F9F9,$F8F8,$F8F8,$F8F8,$F8F8,$F8F8,$F8F8,$F8F8
	dc.w	$F8F8,$F8F8,$F8F8,$F8F8,$F8F8,$F8F8,$F8F8,$F8F9
	dc.w	$F9F9,$F9F9,$F9F9,$F9F9,$F9FA,$FAFA,$FAFA,$FAFA
	dc.w	$FAFB,$FBFB,$FBFB,$FBFC,$FCFC,$FCFC,$FCFD,$FDFD
	dc.w	$FDFD,$FEFE,$FEFE,$FEFF,$FFFF,$FFFF,$0000,$0000
	dc.w	$0000,$0000,$0101,$0101,$0202,$0203,$0303,$0304
	dc.w	$0404,$0405,$0505,$0506,$0606,$0606,$0707,$0707
	dc.w	$0808,$0808,$0808,$0909,$0909,$0909,$090A,$0A0A
	dc.w	$0A0A,$0A0A,$0A0A,$0A0B,$0B0B,$0B0B,$0B0B,$0B0B
	dc.w	$0B0B,$0B0B,$0B0B,$0B0B,$0B0B,$0A0A,$0A0A,$0A0A
	dc.w	$0A0A,$0A0A,$0909,$0909,$0909,$0908,$0808,$0808
	dc.w	$0807,$0707,$0706,$0606,$0606,$0505,$0505,$0404
	dc.w	$0404,$0303,$0303,$0202,$0201,$0101,$0100,$0000
	dc.w	$0000,$0000,$FFFF,$FFFF,$FEFE,$FEFD,$FDFD,$FDFC
	dc.w	$FCFC,$FCFB,$FBFB,$FBFA,$FAFA,$FAFA,$F9F9,$F9F9
	dc.w	$F8F8,$F8F8,$F8F8,$F7F7,$F7F7,$F7F7,$F7F6,$F6F6
	dc.w	$F6F6,$F6F6,$F6F6,$F6F5,$F5F5,$F5F5,$F5F5,$F5F5
	dc.w	$F5F5,$F5F5,$F5F5,$F5F5,$F5F5,$F6F6,$F6F6,$F6F6
	dc.w	$F6F6,$F6F6,$F7F7,$F7F7,$F7F7,$F7F8,$F8F8,$F8F8
	dc.w	$F8F9,$F9F9,$F9FA,$FAFA,$FAFA,$FBFB,$FBFB,$FCFC
	dc.w	$FCFC,$FDFD,$FDFD,$FEFE,$FEFF,$FFFF,$FF00,$0000
	dc.w	$0000,$0001,$0101,$0202,$0203,$0303,$0404,$0405
	dc.w	$0505,$0606,$0606,$0707,$0708,$0808,$0809,$0909
	dc.w	$0A0A,$0A0A,$0A0B,$0B0B,$0B0B,$0C0C,$0C0C,$0C0C
	dc.w	$0D0D,$0D0D,$0D0D,$0D0D,$0D0D,$0E0E,$0E0E,$0E0E
	dc.w	$0E0E,$0E0E,$0E0E,$0E0D,$0D0D,$0D0D,$0D0D,$0D0D
	dc.w	$0D0C,$0C0C,$0C0C,$0C0B,$0B0B,$0B0B,$0A0A,$0A0A
	dc.w	$0A09,$0909,$0808,$0808,$0707,$0706,$0606,$0605
	dc.w	$0505,$0404,$0403,$0303,$0202,$0201,$0101,$0000
	dc.w	$0000,$00FF,$FFFF,$FEFE,$FEFD,$FDFD,$FCFC,$FCFB
	dc.w	$FBFB,$FAFA,$FAFA,$F9F9,$F9F8,$F8F8,$F8F7,$F7F7
	dc.w	$F6F6,$F6F6,$F6F5,$F5F5,$F5F5,$F4F4,$F4F4,$F4F4
	dc.w	$F3F3,$F3F3,$F3F3,$F3F3,$F3F3,$F2F2,$F2F2,$F2F2
	dc.w	$F2F2,$F2F2,$F2F2,$F2F3,$F3F3,$F3F3,$F3F3,$F3F3
	dc.w	$F3F4,$F4F4,$F4F4,$F4F5,$F5F5,$F5F5,$F6F6,$F6F6
	dc.w	$F6F7,$F7F7,$F8F8,$F8F8,$F9F9,$F9FA,$FAFA,$FAFB
	dc.w	$FBFB,$FCFC,$FCFD,$FDFD,$FEFE,$FEFF,$FFFF,$0000
	dc.w	$0000,$0001,$0102,$0202,$0303,$0404,$0405,$0506
	dc.w	$0606,$0707,$0808,$0809,$0909,$0A0A,$0A0B,$0B0B
	dc.w	$0C0C,$0C0C,$0D0D,$0D0D,$0E0E,$0E0E,$0E0F,$0F0F
	dc.w	$0F0F,$1010,$1010,$1010,$1010,$1010,$1010,$1010
	dc.w	$1010,$1010,$1010,$1010,$1010,$1010,$1010,$100F
	dc.w	$0F0F,$0F0F,$0E0E,$0E0E,$0E0D,$0D0D,$0D0C,$0C0C
	dc.w	$0C0B,$0B0B,$0A0A,$0A09,$0909,$0808,$0807,$0706
	dc.w	$0606,$0505,$0404,$0403,$0302,$0202,$0101,$0000
	dc.w	$0000,$00FF,$FFFE,$FEFE,$FDFD,$FCFC,$FCFB,$FBFA
	dc.w	$FAFA,$F9F9,$F8F8,$F8F7,$F7F7,$F6F6,$F6F5,$F5F5
	dc.w	$F4F4,$F4F4,$F3F3,$F3F3,$F2F2,$F2F2,$F2F1,$F1F1
	dc.w	$F1F1,$F0F0,$F0F0,$F0F0,$F0F0,$F0F0,$F0F0,$F0F0
	dc.w	$F0F0,$F0F0,$F0F0,$F0F0,$F0F0,$F0F0,$F0F0,$F0F1
	dc.w	$F1F1,$F1F1,$F2F2,$F2F2,$F2F3,$F3F3,$F3F4,$F4F4
	dc.w	$F4F5,$F5F5,$F6F6,$F6F7,$F7F7,$F8F8,$F8F9,$F9FA
	dc.w	$FAFA,$FBFB,$FCFC,$FCFD,$FDFE,$FEFE,$FFFF,$0000
	dc.w	$0000,$0001,$0102,$0203,$0304,$0405,$0506,$0607
	dc.w	$0708,$0808,$0909,$0A0A,$0B0B,$0B0C,$0C0C,$0D0D
	dc.w	$0E0E,$0E0F,$0F0F,$0F10,$1010,$1111,$1111,$1112
	dc.w	$1212,$1212,$1213,$1313,$1313,$1313,$1313,$1313
	dc.w	$1313,$1313,$1313,$1313,$1313,$1313,$1212,$1212
	dc.w	$1212,$1111,$1111,$1110,$1010,$0F0F,$0F0F,$0E0E
	dc.w	$0E0D,$0D0C,$0C0C,$0B0B,$0B0A,$0A09,$0908,$0808
	dc.w	$0707,$0606,$0505,$0404,$0303,$0202,$0101,$0000
	dc.w	$0000,$00FF,$FFFE,$FEFD,$FDFC,$FCFB,$FBFA,$FAF9
	dc.w	$F9F8,$F8F8,$F7F7,$F6F6,$F5F5,$F5F4,$F4F4,$F3F3
	dc.w	$F2F2,$F2F1,$F1F1,$F1F0,$F0F0,$EFEF,$EFEF,$EFEE
	dc.w	$EEEE,$EEEE,$EEED,$EDED,$EDED,$EDED,$EDED,$EDED
	dc.w	$EDED,$EDED,$EDED,$EDED,$EDED,$EDED,$EEEE,$EEEE
	dc.w	$EEEE,$EFEF,$EFEF,$EFF0,$F0F0,$F1F1,$F1F1,$F2F2
	dc.w	$F2F3,$F3F4,$F4F4,$F5F5,$F5F6,$F6F7,$F7F8,$F8F8
	dc.w	$F9F9,$FAFA,$FBFB,$FCFC,$FDFD,$FEFE,$FFFF,$0000
	dc.w	$0000,$0101,$0202,$0303,$0404,$0506,$0607,$0708
	dc.w	$0809,$090A,$0A0B,$0B0C,$0C0D,$0D0D,$0E0E,$0F0F
	dc.w	$1010,$1011,$1111,$1212,$1213,$1313,$1314,$1414
	dc.w	$1415,$1515,$1515,$1516,$1616,$1616,$1616,$1616
	dc.w	$1616,$1616,$1616,$1616,$1616,$1515,$1515,$1515
	dc.w	$1414,$1414,$1313,$1313,$1212,$1211,$1111,$1010
	dc.w	$100F,$0F0E,$0E0D,$0D0D,$0C0C,$0B0B,$0A0A,$0909
	dc.w	$0808,$0707,$0606,$0504,$0403,$0302,$0201,$0100
	dc.w	$0000,$FFFF,$FEFE,$FDFD,$FCFC,$FBFA,$FAF9,$F9F8
	dc.w	$F8F7,$F7F6,$F6F5,$F5F4,$F4F3,$F3F3,$F2F2,$F1F1
	dc.w	$F0F0,$F0EF,$EFEF,$EEEE,$EEED,$EDED,$EDEC,$ECEC
	dc.w	$ECEB,$EBEB,$EBEB,$EBEA,$EAEA,$EAEA,$EAEA,$EAEA
	dc.w	$EAEA,$EAEA,$EAEA,$EAEA,$EAEA,$EBEB,$EBEB,$EBEB
	dc.w	$ECEC,$ECEC,$EDED,$EDED,$EEEE,$EEEF,$EFEF,$F0F0
	dc.w	$F0F1,$F1F2,$F2F3,$F3F3,$F4F4,$F5F5,$F6F6,$F7F7
	dc.w	$F8F8,$F9F9,$FAFA,$FBFC,$FCFD,$FDFE,$FEFF,$FF00
	dc.w	$0000,$0101,$0203,$0304,$0405,$0606,$0707,$0809
	dc.w	$090A,$0A0B,$0C0C,$0D0D,$0E0E,$0F0F,$1010,$1111
	dc.w	$1212,$1213,$1314,$1414,$1515,$1516,$1616,$1717
	dc.w	$1717,$1818,$1818,$1818,$1919,$1919,$1919,$1919
	dc.w	$1919,$1919,$1919,$1919,$1918,$1818,$1818,$1817
	dc.w	$1717,$1716,$1616,$1515,$1514,$1414,$1313,$1212
	dc.w	$1211,$1110,$100F,$0F0E,$0E0D,$0D0C,$0C0B,$0A0A
	dc.w	$0909,$0807,$0706,$0605,$0404,$0303,$0201,$0100
	dc.w	$0000,$FFFF,$FEFD,$FDFC,$FCFB,$FAFA,$F9F9,$F8F7
	dc.w	$F7F6,$F6F5,$F4F4,$F3F3,$F2F2,$F1F1,$F0F0,$EFEF
	dc.w	$EEEE,$EEED,$EDEC,$ECEC,$EBEB,$EBEA,$EAEA,$E9E9
	dc.w	$E9E9,$E8E8,$E8E8,$E8E8,$E7E7,$E7E7,$E7E7,$E7E7
	dc.w	$E7E7,$E7E7,$E7E7,$E7E7,$E7E8,$E8E8,$E8E8,$E8E9
	dc.w	$E9E9,$E9EA,$EAEA,$EBEB,$EBEC,$ECEC,$EDED,$EEEE
	dc.w	$EEEF,$EFF0,$F0F1,$F1F2,$F2F3,$F3F4,$F4F5,$F6F6
	dc.w	$F7F7,$F8F9,$F9FA,$FAFB,$FCFC,$FDFD,$FEFF,$FF00
	dc.w	$0000,$0102,$0203,$0404,$0506,$0607,$0808,$090A
	dc.w	$0A0B,$0C0C,$0D0D,$0E0F,$0F10,$1011,$1112,$1313
	dc.w	$1414,$1415,$1516,$1617,$1717,$1818,$1819,$1919
	dc.w	$1A1A,$1A1A,$1B1B,$1B1B,$1B1B,$1C1C,$1C1C,$1C1C
	dc.w	$1C1C,$1C1C,$1C1C,$1C1B,$1B1B,$1B1B,$1B1A,$1A1A
	dc.w	$1A19,$1919,$1818,$1817,$1717,$1616,$1515,$1414
	dc.w	$1413,$1312,$1111,$1010,$0F0F,$0E0D,$0D0C,$0C0B
	dc.w	$0A0A,$0908,$0807,$0606,$0504,$0403,$0202,$0100
	dc.w	$0000,$FFFE,$FEFD,$FCFC,$FBFA,$FAF9,$F8F8,$F7F6
	dc.w	$F6F5,$F4F4,$F3F3,$F2F1,$F1F0,$F0EF,$EFEE,$EDED
	dc.w	$ECEC,$ECEB,$EBEA,$EAE9,$E9E9,$E8E8,$E8E7,$E7E7
	dc.w	$E6E6,$E6E6,$E5E5,$E5E5,$E5E5,$E4E4,$E4E4,$E4E4
	dc.w	$E4E4,$E4E4,$E4E4,$E4E5,$E5E5,$E5E5,$E5E6,$E6E6
	dc.w	$E6E7,$E7E7,$E8E8,$E8E9,$E9E9,$EAEA,$EBEB,$ECEC
	dc.w	$ECED,$EDEE,$EFEF,$F0F0,$F1F1,$F2F3,$F3F4,$F4F5
	dc.w	$F6F6,$F7F8,$F8F9,$FAFA,$FBFC,$FCFD,$FEFE,$FF00
	dc.w	$0000,$0102,$0303,$0405,$0606,$0708,$0909,$0A0B
	dc.w	$0B0C,$0D0E,$0E0F,$1010,$1111,$1213,$1314,$1415
	dc.w	$1616,$1717,$1818,$1919,$191A,$1A1B,$1B1B,$1C1C
	dc.w	$1C1D,$1D1D,$1D1E,$1E1E,$1E1E,$1E1E,$1F1F,$1F1F
	dc.w	$1F1F,$1F1F,$1F1E,$1E1E,$1E1E,$1E1E,$1D1D,$1D1D
	dc.w	$1C1C,$1C1B,$1B1B,$1A1A,$1919,$1918,$1817,$1716
	dc.w	$1615,$1414,$1313,$1211,$1110,$100F,$0E0E,$0D0C
	dc.w	$0B0B,$0A09,$0908,$0706,$0605,$0403,$0302,$0100
	dc.w	$0000,$FFFE,$FDFD,$FCFB,$FAFA,$F9F8,$F7F7,$F6F5
	dc.w	$F5F4,$F3F2,$F2F1,$F0F0,$EFEF,$EEED,$EDEC,$ECEB
	dc.w	$EAEA,$E9E9,$E8E8,$E7E7,$E7E6,$E6E5,$E5E5,$E4E4
	dc.w	$E4E3,$E3E3,$E3E2,$E2E2,$E2E2,$E2E2,$E1E1,$E1E1
	dc.w	$E1E1,$E1E1,$E1E2,$E2E2,$E2E2,$E2E2,$E3E3,$E3E3
	dc.w	$E4E4,$E4E5,$E5E5,$E6E6,$E7E7,$E7E8,$E8E9,$E9EA
	dc.w	$EAEB,$ECEC,$EDED,$EEEF,$EFF0,$F0F1,$F2F2,$F3F4
	dc.w	$F5F5,$F6F7,$F7F8,$F9FA,$FAFB,$FCFD,$FDFE,$FF00
	dc.w	$0000,$0102,$0304,$0405,$0607,$0809,$090A,$0B0C
	dc.w	$0D0D,$0E0F,$1010,$1112,$1213,$1414,$1516,$1617
	dc.w	$1818,$1919,$1A1A,$1B1B,$1C1C,$1D1D,$1D1E,$1E1F
	dc.w	$1F1F,$2020,$2020,$2021,$2121,$2121,$2121,$2121
	dc.w	$2121,$2121,$2121,$2121,$2121,$2020,$2020,$201F
	dc.w	$1F1F,$1E1E,$1D1D,$1D1C,$1C1B,$1B1A,$1A19,$1918
	dc.w	$1817,$1616,$1514,$1413,$1212,$1110,$100F,$0E0D
	dc.w	$0D0C,$0B0A,$0909,$0807,$0605,$0404,$0302,$0100
	dc.w	$0000,$FFFE,$FDFC,$FCFB,$FAF9,$F8F7,$F7F6,$F5F4
	dc.w	$F3F3,$F2F1,$F0F0,$EFEE,$EEED,$ECEC,$EBEA,$EAE9
	dc.w	$E8E8,$E7E7,$E6E6,$E5E5,$E4E4,$E3E3,$E3E2,$E2E1
	dc.w	$E1E1,$E0E0,$E0E0,$E0DF,$DFDF,$DFDF,$DFDF,$DFDF
	dc.w	$DFDF,$DFDF,$DFDF,$DFDF,$DFDF,$E0E0,$E0E0,$E0E1
	dc.w	$E1E1,$E2E2,$E3E3,$E3E4,$E4E5,$E5E6,$E6E7,$E7E8
	dc.w	$E8E9,$EAEA,$EBEC,$ECED,$EEEE,$EFF0,$F0F1,$F2F3
	dc.w	$F3F4,$F5F6,$F7F7,$F8F9,$FAFB,$FCFC,$FDFE,$FF00
	dc.w	$0000,$0102,$0304,$0506,$0708,$0809,$0A0B,$0C0D
	dc.w	$0E0E,$0F10,$1112,$1213,$1415,$1516,$1718,$1819
	dc.w	$1A1A,$1B1B,$1C1D,$1D1E,$1E1F,$1F20,$2020,$2121
	dc.w	$2222,$2222,$2323,$2323,$2424,$2424,$2424,$2424
	dc.w	$2424,$2424,$2424,$2424,$2423,$2323,$2322,$2222
	dc.w	$2221,$2120,$2020,$1F1F,$1E1E,$1D1D,$1C1B,$1B1A
	dc.w	$1A19,$1818,$1716,$1515,$1413,$1212,$1110,$0F0E
	dc.w	$0E0D,$0C0B,$0A09,$0808,$0706,$0504,$0302,$0100
	dc.w	$0000,$FFFE,$FDFC,$FBFA,$F9F8,$F8F7,$F6F5,$F4F3
	dc.w	$F2F2,$F1F0,$EFEE,$EEED,$ECEB,$EBEA,$E9E8,$E8E7
	dc.w	$E6E6,$E5E5,$E4E3,$E3E2,$E2E1,$E1E0,$E0E0,$DFDF
	dc.w	$DEDE,$DEDE,$DDDD,$DDDD,$DCDC,$DCDC,$DCDC,$DCDC
	dc.w	$DCDC,$DCDC,$DCDC,$DCDC,$DCDD,$DDDD,$DDDE,$DEDE
	dc.w	$DEDF,$DFE0,$E0E0,$E1E1,$E2E2,$E3E3,$E4E5,$E5E6
	dc.w	$E6E7,$E8E8,$E9EA,$EBEB,$ECED,$EEEE,$EFF0,$F1F2
	dc.w	$F2F3,$F4F5,$F6F7,$F8F8,$F9FA,$FBFC,$FDFE,$FF00
	dc.w	$0000,$0102,$0304,$0506,$0708,$090A,$0B0C,$0D0E
	dc.w	$0F10,$1011,$1213,$1415,$1616,$1718,$1919,$1A1B
	dc.w	$1C1C,$1D1E,$1E1F,$1F20,$2021,$2222,$2223,$2324
	dc.w	$2425,$2525,$2526,$2626,$2627,$2727,$2727,$2727
	dc.w	$2727,$2727,$2727,$2727,$2626,$2626,$2525,$2525
	dc.w	$2424,$2323,$2222,$2221,$2020,$1F1F,$1E1E,$1D1C
	dc.w	$1C1B,$1A19,$1918,$1716,$1615,$1413,$1211,$1010
	dc.w	$0F0E,$0D0C,$0B0A,$0908,$0706,$0504,$0302,$0100
	dc.w	$0000,$FFFE,$FDFC,$FBFA,$F9F8,$F7F6,$F5F4,$F3F2
	dc.w	$F1F0,$F0EF,$EEED,$ECEB,$EAEA,$E9E8,$E7E7,$E6E5
	dc.w	$E4E4,$E3E2,$E2E1,$E1E0,$E0DF,$DEDE,$DEDD,$DDDC
	dc.w	$DCDB,$DBDB,$DBDA,$DADA,$DAD9,$D9D9,$D9D9,$D9D9
	dc.w	$D9D9,$D9D9,$D9D9,$D9D9,$DADA,$DADA,$DBDB,$DBDB
	dc.w	$DCDC,$DDDD,$DEDE,$DEDF,$E0E0,$E1E1,$E2E2,$E3E4
	dc.w	$E4E5,$E6E7,$E7E8,$E9EA,$EAEB,$ECED,$EEEF,$F0F0
	dc.w	$F1F2,$F3F4,$F5F6,$F7F8,$F9FA,$FBFC,$FDFE,$FF00
	dc.w	$0001,$0203,$0405,$0607,$0809,$0A0B,$0C0D,$0E0F
	dc.w	$1011,$1213,$1414,$1516,$1718,$191A,$1A1B,$1C1D
	dc.w	$1E1E,$1F20,$2021,$2222,$2323,$2424,$2525,$2626
	dc.w	$2727,$2828,$2828,$2929,$2929,$2A2A,$2A2A,$2A2A
	dc.w	$2A2A,$2A2A,$2A2A,$2A29,$2929,$2928,$2828,$2827
	dc.w	$2726,$2625,$2524,$2423,$2322,$2221,$2020,$1F1E
	dc.w	$1E1D,$1C1B,$1A1A,$1918,$1716,$1514,$1413,$1211
	dc.w	$100F,$0E0D,$0C0B,$0A09,$0807,$0605,$0403,$0201
	dc.w	$00FF,$FEFD,$FCFB,$FAF9,$F8F7,$F6F5,$F4F3,$F2F1
	dc.w	$F0EF,$EEED,$ECEC,$EBEA,$E9E8,$E7E6,$E6E5,$E4E3
	dc.w	$E2E2,$E1E0,$E0DF,$DEDE,$DDDD,$DCDC,$DBDB,$DADA
	dc.w	$D9D9,$D8D8,$D8D8,$D7D7,$D7D7,$D6D6,$D6D6,$D6D6
	dc.w	$D6D6,$D6D6,$D6D6,$D6D7,$D7D7,$D7D8,$D8D8,$D8D9
	dc.w	$D9DA,$DADB,$DBDC,$DCDD,$DDDE,$DEDF,$E0E0,$E1E2
	dc.w	$E2E3,$E4E5,$E6E6,$E7E8,$E9EA,$EBEC,$ECED,$EEEF
	dc.w	$F0F1,$F2F3,$F4F5,$F6F7,$F8F9,$FAFB,$FCFD,$FEFF

;	text

stopsnd:
	movem.l	d0-d1/a0-a1,-(a7)
	pea	P30e0(pc)
	move	#38,-(a7)
	trap	#14
	addq.l	#6,a7
	movem.l	(a7)+,d0-d1/a0-a1
	rts
P30e0:	ori	#$0700,sr
	move.b	#$07,GISELECT.w
	move.b	#$7f,GIDATA.w
	move.l	TIMAVEC,old134
	rts

L30f6:	clr.l	P3ae2
	bclr	#5,IMRA.w
	bclr	#5,IPRA.w
	bclr	#5,ISRA.w
	move	(a7)+,d1
	move.l	(a7)+,d0
	movea.l	(a7)+,a0
	move.b	#$07,GISELECT.w
	move.b	#$7f,GIDATA.w
	move.l	old134,TIMAVEC.w
	rte

SMC:=	0

; basically, this does nothing (because all tone is mute) but waiting for
; this 'hiss' phoneme to end.
ophiss:	move.l	a0,-(a7)
	move.l	d0,-(a7)
	subq.b	#1,P3ae6
	bmi.s	L3144
	
	ifne	SMC
	lea	P20ca(pc),a0
L329a:	addi.b	#$00,L32b2+3
L32a2:	addi.b	#$00,L32b6+3
L32aa:	addi.b	#$00,L32ba+3
L32b2:	move.b	$1000(a0),d0
L32b6:	add.b	$1000(a0),d0
L32ba:	add.b	$1000(a0),d0
	andi.w	#$00ff,d0
	lsl.w	#3,d0
	lea	P32e2(pc),a0
	adda.w	d0,a0
	rept	2
	move.b	(a0)+,GISELECT.w
	move.b	(a0)+,GIDATA.w
	endr
	endc

	move.l	(a7)+,d0
	movea.l	(a7)+,a0
	bclr	#5,ISRA.w
	rte

opwaves:move.l	a0,-(a7)
	move.l	d0,-(a7)
L3144:	move.w	d1,-(a7)
	subq.b	#1,P3ae6
	bpl	L3210

	move.b	use_rate(pc),P3ae6
	movea.l	P3ae2(pc),a0			; a0: speech buffer pointer
	move.b	(a0)+,P3ae7
	beq	L30f6
	move.b	(a0)+,d0
	beq.s	L31cc
; set channel C amp..
	move.b	#$0a,GISELECT.w
	move.b	d0,GIDATA.w
; set noise frequency..
	move.b	#$06,GISELECT.w
	move.b	(a0)+,GIDATA.w

; arghl! this sets ophiss parameters!
	ifne	SMC
	move.b	(a0)+,L329a+3
	move.b	(a0)+,L32b2+2
	move.b	(a0)+,L32a2+3
	move.b	(a0)+,L32b6+2
	move.b	(a0)+,L32aa+3
	move.b	(a0)+,L32ba+2
	else
	addq	#6,a0	
	endc

	move.l	a0,P3ae2
	move.l	#ophiss,TIMAVEC.w
; disable all PSG channels except noise channel C..
	move.b	#$07,GISELECT.w
	move.b	#$5f,GIDATA.w
	bra	L3278

L31cc:	addq.l	#1,a0

	ifne	SMC
	move.b	(a0)+,L3238+3	; set wave A step
	move.b	(a0)+,L3250+2	; set wave A amplitude
	move.b	(a0)+,L3240+3	; set wave B step
	move.b	(a0)+,L3254+2	; set wave B amplitude
	move.b	(a0)+,L3248+3	; set wave C step
	move.b	(a0)+,L3258+2	; set wave C amplitude
	else
	move.l	(a0)+,wave_params
	move.w	(a0)+,wave_params+4
	endc

	move.l	#opwaves,TIMAVEC.w
; disable all noise and tone PSG channels..
	move.b	#$07,GISELECT.w
	move.b	#$7f,GIDATA.w
	move.l	a0,P3ae2

L3210:	subq.b	#1,P3ae8
	bpl.s	L3234

; reset wave positions
	move.b	P3ae7(pc),P3ae8
	moveq	#$00,d0

	ifne	SMC
	move.b	d0,L3250+3
	move.b	d0,L3254+3
	move.b	d0,L3258+3
	else
	move.l	d0,wave_pos
	endc

L3234:	lea	P20ca(pc),a0

	ifne	SMC

; step through the wave..
L3238:	addi.b	#$00,L3250+3
L3240:	addi.b	#$00,L3254+3
L3248:	addi.b	#$00,L3258+3
; mix 3 formants (waves)..
L3250:	move.b	$1000(a0),d0
L3254:	add.b	$1000(a0),d0
L3258:	add.b	$1000(a0),d0

	else

; step through the wave..
	move.b	wave_a_step(pc),d0
	add.b	d0,wave_a_pos
	move.b	wave_b_step(pc),d0
	add.b	d0,wave_b_pos
	move.b	wave_c_step(pc),d0
	add.b	d0,wave_c_pos
; mix 3 formants (waves)..
	move.b	wave_a_amp,d1
	lsl.w	#8,d1
	move.b	wave_a_pos,d1
	move.b	(a0,d1.w),d0
	move.b	wave_b_amp,d1
	lsl.w	#8,d1
	move.b	wave_b_pos,d1
	add.b	(a0,d1.w),d0
	move.b	wave_c_amp,d1
	lsl.w	#8,d1
	move.b	wave_c_pos,d1
	add.b	(a0,d1.w),d0

	endc

; d0.b=sample (signed)
	andi.w	#$ff,d0
	lsl.w	#3,d0			; $0000..$07F8
	lea	P32e2(pc,d0.w),a0

	ifne	1

	movem.l	a1-a2,-(sp)
	lea	GISELECT.w,a1
	lea	GIDATA.w,a2
	rept	3
	move.b	(a0)+,(a1)
	move.b	(a0)+,(a2)
	endr
	movem.l	(sp)+,a1-a2

	else

	move.l	(a0)+,d0
	move	(a0),d1
	lea	GISELECT.w,a0
	movep.l	d0,0(a0)
	movep.w	d1,0(a0)

	endc

L3278:	move.w	(a7)+,d1
	move.l	(a7)+,d0
	movea.l	(a7)+,a0
	bclr	#5,ISRA.w
	rte

; wave PSG addr/value pairs
; channel A,B,C amplitudes!
; each entry 6 bytes (3 pairs), zero-padded to 8 for fast indexing.
P32e2:	dc.b	$08,$0c,$09,$0b,$0a,$09,$00,$00,$08,$0c,$09,$0b,$0a
	dc.b	$09,$00,$00,$08,$0d,$09,$08,$0a,$08,$00,$00,$08,$0b
	dc.b	$09,$0b,$0a,$0b,$00,$00,$08,$0d,$09,$09,$0a,$05,$00
	dc.b	$00,$08,$0c,$09,$0b,$0a,$08,$00,$00,$08,$0d,$09,$09
	dc.b	$0a,$02,$00,$00,$08,$0d,$09,$08,$0a,$06,$00,$00,$08
	dc.b	$0c,$09,$0b,$0a,$07,$00,$00,$08,$0d,$09,$07,$0a,$07
	dc.b	$00,$00,$08,$0c,$09,$0b,$0a,$06,$00,$00,$08,$0c,$09
	dc.b	$0a,$0a,$09,$00,$00,$08,$0b,$09,$0b,$0a,$0a,$00,$00
	dc.b	$08,$0c,$09,$0b,$0a,$02,$00,$00,$08,$0c,$09,$0b,$0a
	dc.b	$00,$00,$00,$08,$0c,$09,$0a,$0a,$08,$00,$00,$08,$0d
	dc.b	$09,$06,$0a,$04,$00,$00,$08,$0d,$09,$05,$0a,$05,$00
	dc.b	$00,$08,$0d,$09,$05,$0a,$04,$00,$00,$08,$0c,$09,$09
	dc.b	$0a,$09,$00,$00,$08,$0d,$09,$04,$0a,$03,$00,$00,$08
	dc.b	$0b,$09,$0b,$0a,$09,$00,$00,$08,$0c,$09,$0a,$0a,$05
	dc.b	$00,$00,$08,$0b,$09,$0a,$0a,$0a,$00,$00,$08,$0c,$09
	dc.b	$09,$0a,$08,$00,$00,$08,$0b,$09,$0b,$0a,$08,$00,$00
	dc.b	$08,$0c,$09,$0a,$0a,$00,$00,$00,$08,$0c,$09,$0a,$0a
	dc.b	$00,$00,$00,$08,$0c,$09,$09,$0a,$07,$00,$00,$08,$0b
	dc.b	$09,$0b,$0a,$07,$00,$00,$08,$0c,$09,$09,$0a,$06,$00
	dc.b	$00,$08,$0b,$09,$0b,$0a,$06,$00,$00,$08,$0b,$09,$0a
	dc.b	$0a,$09,$00,$00,$08,$0b,$09,$0b,$0a,$05,$00,$00,$08
	dc.b	$0a,$09,$0a,$0a,$0a,$00,$00,$08,$0b,$09,$0b,$0a,$02
	dc.b	$00,$00,$08,$0b,$09,$0a,$0a,$08,$00,$00,$08,$0c,$09
	dc.b	$07,$0a,$07,$00,$00,$08,$0c,$09,$08,$0a,$04,$00,$00
	dc.b	$08,$0c,$09,$07,$0a,$06,$00,$00,$08,$0b,$09,$09,$0a
	dc.b	$09,$00,$00,$08,$0c,$09,$06,$0a,$06,$00,$00,$08,$0a
	dc.b	$09,$0a,$0a,$09,$00,$00,$08,$0c,$09,$07,$0a,$03,$00
	dc.b	$00,$08,$0b,$09,$0a,$0a,$05,$00,$00,$08,$0b,$09,$09
	dc.b	$0a,$08,$00,$00,$08,$0b,$09,$0a,$0a,$03,$00,$00,$08
	dc.b	$0a,$09,$0a,$0a,$08,$00,$00,$08,$0b,$09,$0a,$0a,$00
	dc.b	$00,$00,$08,$0b,$09,$09,$0a,$07,$00,$00,$08,$0b,$09
	dc.b	$08,$0a,$08,$00,$00,$08,$0a,$09,$0a,$0a,$07,$00,$00
	dc.b	$08,$0a,$09,$09,$0a,$09,$00,$00,$08,$0c,$09,$01,$0a
	dc.b	$01,$00,$00,$08,$0a,$09,$0a,$0a,$06,$00,$00,$08,$0b
	dc.b	$09,$08,$0a,$07,$00,$00,$08,$0a,$09,$0a,$0a,$05,$00
	dc.b	$00,$08,$0a,$09,$09,$0a,$08,$00,$00,$08,$0a,$09,$0a
	dc.b	$0a,$02,$00,$00,$08,$0a,$09,$0a,$0a,$01,$00,$00,$08
	dc.b	$0a,$09,$0a,$0a,$00,$00,$00,$08,$09,$09,$09,$0a,$09
	dc.b	$00,$00,$08,$0a,$09,$08,$0a,$08,$00,$00,$08,$0b,$09
	dc.b	$08,$0a,$01,$00,$00,$08,$0a,$09,$09,$0a,$06,$00,$00
	dc.b	$08,$0b,$09,$07,$0a,$04,$00,$00,$08,$0a,$09,$09,$0a
	dc.b	$05,$00,$00,$08,$09,$09,$09,$0a,$08,$00,$00,$08,$0a
	dc.b	$09,$09,$0a,$03,$00,$00,$08,$0a,$09,$08,$0a,$06,$00
	dc.b	$00,$08,$0a,$09,$09,$0a,$00,$00,$00,$08,$09,$09,$09
	dc.b	$0a,$07,$00,$00,$08,$09,$09,$08,$0a,$08,$00,$00,$08
	dc.b	$0a,$09,$08,$0a,$04,$00,$00,$08,$09,$09,$09,$0a,$06
	dc.b	$00,$00,$08,$0a,$09,$08,$0a,$01,$00,$00,$08,$09,$09
	dc.b	$09,$0a,$05,$00,$00,$08,$09,$09,$08,$0a,$07,$00,$00
	dc.b	$08,$08,$09,$08,$0a,$08,$00,$00,$08,$09,$09,$09,$0a
	dc.b	$02,$00,$00,$08,$09,$09,$08,$0a,$06,$00,$00,$08,$09
	dc.b	$09,$09,$0a,$00,$00,$00,$08,$09,$09,$07,$0a,$07,$00
	dc.b	$00,$08,$08,$09,$08,$0a,$07,$00,$00,$08,$09,$09,$07
	dc.b	$0a,$06,$00,$00,$08,$09,$09,$08,$0a,$02,$00,$00,$08
	dc.b	$08,$09,$08,$0a,$06,$00,$00,$08,$09,$09,$06,$0a,$06
	dc.b	$00,$00,$08,$08,$09,$07,$0a,$07,$00,$00,$08,$08,$09
	dc.b	$08,$0a,$04,$00,$00,$08,$08,$09,$07,$0a,$06,$00,$00
	dc.b	$08,$08,$09,$08,$0a,$02,$00,$00,$08,$07,$09,$07,$0a
	dc.b	$07,$00,$00,$08,$08,$09,$06,$0a,$06,$00,$00,$08,$08
	dc.b	$09,$07,$0a,$04,$00,$00,$08,$07,$09,$07,$0a,$06,$00
	dc.b	$00,$08,$08,$09,$06,$0a,$05,$00,$00,$08,$08,$09,$06
	dc.b	$0a,$04,$00,$00,$08,$07,$09,$06,$0a,$06,$00,$00,$08
	dc.b	$07,$09,$07,$0a,$04,$00,$00,$08,$08,$09,$05,$0a,$04
	dc.b	$00,$00,$08,$06,$09,$06,$0a,$06,$00,$00,$08,$07,$09
	dc.b	$06,$0a,$04,$00,$00,$08,$07,$09,$05,$0a,$05,$00,$00
	dc.b	$08,$06,$09,$06,$0a,$05,$00,$00,$08,$06,$09,$06,$0a
	dc.b	$04,$00,$00,$08,$06,$09,$05,$0a,$05,$00,$00,$08,$06
	dc.b	$09,$06,$0a,$02,$00,$00,$08,$06,$09,$05,$0a,$04,$00
	dc.b	$00,$08,$05,$09,$05,$0a,$05,$00,$00,$08,$06,$09,$05
	dc.b	$0a,$02,$00,$00,$08,$05,$09,$05,$0a,$04,$00,$00,$08
	dc.b	$05,$09,$04,$0a,$04,$00,$00,$08,$05,$09,$05,$0a,$02
	dc.b	$00,$00,$08,$04,$09,$04,$0a,$04,$00,$00,$08,$04,$09
	dc.b	$04,$0a,$03,$00,$00,$08,$04,$09,$04,$0a,$02,$00,$00
	dc.b	$08,$04,$09,$03,$0a,$03,$00,$00,$08,$03,$09,$03,$0a
	dc.b	$03,$00,$00,$08,$03,$09,$03,$0a,$02,$00,$00,$08,$03
	dc.b	$09,$02,$0a,$02,$00,$00,$08,$02,$09,$02,$0a,$02,$00
	dc.b	$00,$08,$02,$09,$02,$0a,$01,$00,$00,$08,$01,$09,$01
	dc.b	$0a,$01,$00,$00,$08,$02,$09,$01,$0a,$00,$00,$00,$08
	dc.b	$01,$09,$01,$0a,$00,$00,$00,$08,$01,$09,$00,$0a,$00
	dc.b	$00,$00,$08,$00,$09,$00,$0a,$00,$00,$00,$08,$0e,$09
	dc.b	$0d,$0a,$0c,$00,$00,$08,$0f,$09,$03,$0a,$00,$00,$00
	dc.b	$08,$0f,$09,$03,$0a,$00,$00,$00,$08,$0f,$09,$03,$0a
	dc.b	$00,$00,$00,$08,$0f,$09,$03,$0a,$00,$00,$00,$08,$0f
	dc.b	$09,$03,$0a,$00,$00,$00,$08,$0f,$09,$03,$0a,$00,$00
	dc.b	$00,$08,$0e,$09,$0d,$0a,$0b,$00,$00,$08,$0e,$09,$0d
	dc.b	$0a,$0b,$00,$00,$08,$0e,$09,$0d,$0a,$0b,$00,$00,$08
	dc.b	$0e,$09,$0d,$0a,$0b,$00,$00,$08,$0e,$09,$0d,$0a,$0b
	dc.b	$00,$00,$08,$0e,$09,$0d,$0a,$0b,$00,$00,$08,$0e,$09
	dc.b	$0d,$0a,$0b,$00,$00,$08,$0e,$09,$0d,$0a,$0a,$00,$00
	dc.b	$08,$0e,$09,$0d,$0a,$0a,$00,$00,$08,$0e,$09,$0d,$0a
	dc.b	$0a,$00,$00,$08,$0e,$09,$0d,$0a,$0a,$00,$00,$08,$0e
	dc.b	$09,$0c,$0a,$0c,$00,$00,$08,$0e,$09,$0d,$0a,$00,$00
	dc.b	$00,$08,$0d,$09,$0d,$0a,$0d,$00,$00,$08,$0d,$09,$0d
	dc.b	$0a,$0d,$00,$00,$08,$0d,$09,$0d,$0a,$0d,$00,$00,$08
	dc.b	$0d,$09,$0d,$0a,$0d,$00,$00,$08,$0d,$09,$0d,$0a,$0d
	dc.b	$00,$00,$08,$0d,$09,$0d,$0a,$0d,$00,$00,$08,$0e,$09
	dc.b	$0c,$0a,$0b,$00,$00,$08,$0e,$09,$0c,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$0b,$00,$00,$08,$0e,$09,$0c,$0a
	dc.b	$0b,$00,$00,$08,$0e,$09,$0c,$0a,$0b,$00,$00,$08,$0e
	dc.b	$09,$0c,$0a,$0b,$00,$00,$08,$0e,$09,$0c,$0a,$0b,$00
	dc.b	$00,$08,$0e,$09,$0c,$0a,$0b,$00,$00,$08,$0e,$09,$0c
	dc.b	$0a,$0a,$00,$00,$08,$0e,$09,$0c,$0a,$0a,$00,$00,$08
	dc.b	$0e,$09,$0c,$0a,$0a,$00,$00,$08,$0e,$09,$0c,$0a,$0a
	dc.b	$00,$00,$08,$0d,$09,$0d,$0a,$0c,$00,$00,$08,$0d,$09
	dc.b	$0d,$0a,$0c,$00,$00,$08,$0e,$09,$0c,$0a,$09,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$09,$00,$00,$08,$0e,$09,$0c,$0a
	dc.b	$05,$00,$00,$08,$0e,$09,$0c,$0a,$00,$00,$00,$08,$0e
	dc.b	$09,$0c,$0a,$00,$00,$00,$08,$0e,$09,$0b,$0a,$0b,$00
	dc.b	$00,$08,$0e,$09,$0b,$0a,$0b,$00,$00,$08,$0e,$09,$0b
	dc.b	$0a,$0b,$00,$00,$08,$0e,$09,$0b,$0a,$0b,$00,$00,$08
	dc.b	$0e,$09,$0b,$0a,$0a,$00,$00,$08,$0e,$09,$0b,$0a,$0a
	dc.b	$00,$00,$08,$0e,$09,$0b,$0a,$0a,$00,$00,$08,$0d,$09
	dc.b	$0d,$0a,$0b,$00,$00,$08,$0d,$09,$0d,$0a,$0b,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$0b,$00,$00,$08,$0e,$09,$0b,$0a
	dc.b	$09,$00,$00,$08,$0e,$09,$0b,$0a,$09,$00,$00,$08,$0e
	dc.b	$09,$0b,$0a,$09,$00,$00,$08,$0d,$09,$0c,$0a,$0c,$00
	dc.b	$00,$08,$0d,$09,$0d,$0a,$0a,$00,$00,$08,$0e,$09,$0b
	dc.b	$0a,$07,$00,$00,$08,$0e,$09,$0b,$0a,$00,$00,$00,$08
	dc.b	$0e,$09,$0b,$0a,$00,$00,$00,$08,$0d,$09,$0d,$0a,$09
	dc.b	$00,$00,$08,$0d,$09,$0d,$0a,$09,$00,$00,$08,$0e,$09
	dc.b	$0a,$0a,$09,$00,$00,$08,$0d,$09,$0d,$0a,$08,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$07,$00,$00,$08,$0d,$09,$0d,$0a
	dc.b	$04,$00,$00,$08,$0d,$09,$0d,$0a,$00,$00,$00,$08,$0e
	dc.b	$09,$0a,$0a,$04,$00,$00,$08,$0e,$09,$09,$0a,$09,$00
	dc.b	$00,$08,$0e,$09,$09,$0a,$09,$00,$00,$08,$0d,$09,$0c
	dc.b	$0a,$0b,$00,$00,$08,$0e,$09,$09,$0a,$08,$00,$00,$08
	dc.b	$0e,$09,$09,$0a,$08,$00,$00,$08,$0e,$09,$09,$0a,$07
	dc.b	$00,$00,$08,$0e,$09,$08,$0a,$08,$00,$00,$08,$0e,$09
	dc.b	$09,$0a,$01,$00,$00,$08,$0c,$09,$0c,$0a,$0c,$00,$00
	dc.b	$08,$0d,$09,$0c,$0a,$0a,$00,$00,$08,$0e,$09,$08,$0a
	dc.b	$06,$00,$00,$08,$0e,$09,$07,$0a,$07,$00,$00,$08,$0e
	dc.b	$09,$08,$0a,$00,$00,$00,$08,$0e,$09,$07,$0a,$05,$00
	dc.b	$00,$08,$0e,$09,$06,$0a,$06,$00,$00,$08,$0d,$09,$0c
	dc.b	$0a,$09,$00,$00,$08,$0e,$09,$05,$0a,$05,$00,$00,$08
	dc.b	$0e,$09,$04,$0a,$04,$00,$00,$08,$0d,$09,$0c,$0a,$08
	dc.b	$00,$00,$08,$0d,$09,$0b,$0a,$0b,$00,$00,$08,$0e,$09
	dc.b	$00,$0a,$00,$00,$00,$08,$0d,$09,$0c,$0a,$06,$00,$00
	dc.b	$08,$0d,$09,$0c,$0a,$05,$00,$00,$08,$0d,$09,$0c,$0a
	dc.b	$02,$00,$00,$08,$0c,$09,$0c,$0a,$0b,$00,$00,$08,$0c
	dc.b	$09,$0c,$0a,$0b,$00,$00,$08,$0d,$09,$0b,$0a,$0a,$00
	dc.b	$00,$08,$0d,$09,$0b,$0a,$0a,$00,$00,$08,$0d,$09,$0b
	dc.b	$0a,$0a,$00,$00,$08,$0d,$09,$0b,$0a,$0a,$00,$00,$08
	dc.b	$0c,$09,$0c,$0a,$0a,$00,$00,$08,$0c,$09,$0c,$0a,$0a
	dc.b	$00,$00,$08,$0c,$09,$0c,$0a,$0a,$00,$00,$08,$0d,$09
	dc.b	$0b,$0a,$09,$00,$00,$08,$0d,$09,$0b,$0a,$09,$00,$00
	dc.b	$08,$0d,$09,$0a,$0a,$0a,$00,$00,$08,$0d,$09,$0a,$0a
	dc.b	$0a,$00,$00,$08,$0d,$09,$0a,$0a,$0a,$00,$00,$08,$0c
	dc.b	$09,$0c,$0a,$09,$00,$00,$08,$0c,$09,$0c,$0a,$09,$00
	dc.b	$00,$08,$0c,$09,$0c,$0a,$09,$00,$00,$08,$0d,$09,$0b
	dc.b	$0a,$06,$00,$00,$08,$0c,$09,$0b,$0a,$0b,$00,$00,$08
	dc.b	$0c,$09,$0c,$0a,$08,$00,$00,$08,$0d,$09,$0b,$0a,$00
	dc.b	$00,$00,$08,$0d,$09,$0b,$0a,$00,$00,$00,$08,$0c,$09
	dc.b	$0c,$0a,$07,$00,$00,$08,$0c,$09,$0c,$0a,$06,$00,$00
	dc.b	$08,$0c,$09,$0c,$0a,$05,$00,$00,$08,$0c,$09,$0c,$0a
	dc.b	$03,$00,$00,$08,$0c,$09,$0c,$0a,$01,$00,$00,$08,$0c
	dc.b	$09,$0b,$0a,$0a,$00,$00,$08,$0d,$09,$0a,$0a,$05,$00
	dc.b	$00,$08,$0d,$09,$0a,$0a,$04,$00,$00,$08,$0d,$09,$0a
	dc.b	$0a,$02,$00,$00,$08,$0d,$09,$09,$0a,$08,$00,$00,$08
	dc.b	$0d,$09,$09,$0a,$08,$00,$00

	ifeq	0 SMC
L3238:	addi.b	#$00,L3250+3
L3240:	addi.b	#$00,L3254+3
L3248:	addi.b	#$00,L3258+3
; mix 3 formants (waves)..
L3250:	move.b	$1000(a0),d0
L3254:	add.b	$1000(a0),d0
L3258:	add.b	$1000(a0),d0
	endc

wave_params:
wave_a_step:
	ds.b	1
wave_a_amp:
	ds.b	1
wave_b_step:
	ds.b	1
wave_b_amp:
	ds.b	1
wave_c_step:
	ds.b	1
wave_c_amp:
	ds.b	1

wave_pos:
wave_a_pos:
	ds.b	1
wave_b_pos:
	ds.b	1
wave_c_pos:
	ds.b	1
	ds.b	1			A,B,C positions

hiss_params:
hiss_a_step:
	ds.b	1
hiss_a_amp:
	ds.b	1
hiss_b_step:
	ds.b	1
hiss_b_amp:
	ds.b	1

hiss_a_pos:
	ds.b	1
hiss_b_pos:
	ds.b	1

P3ae2:	dc.l	0
P3ae6:	dc.b	$00
P3ae7:	dc.b	$00
P3ae8:	dc.b	$00,$00

phoneme:
_EY:	dc.b	"EY"		;  0 (0000)
	dc.w	$0e0d,$0262,$012c,$0906,$047e,$0b40,$05a0,$0201
	dc.w	$0105,$0530,$1830,$182a,$1500,$0001,$0505,$4000
_AY:	dc.b	"AY"		;  1 (0022)
	dc.w	$0f0c,$0366,$01ae,$04e2,$026c,$0b04,$0582,$0201
	dc.w	$0105,$0532,$192f,$171f,$0f00,$0001,$0505,$4000
_OY:	dc.b	"OY"		;  2 (0044)
	dc.w	$0f0c,$02a8,$0154,$03e8,$01f4,$0b04,$0582,$0201
	dc.w	$0105,$0532,$192d,$2c1e,$0f00,$0001,$0505,$4000
_AW:	dc.b	"AW"		;  3 (0066)
	dc.w	$0f0c,$0366,$01ae,$0564,$02b2,$0b04,$0582,$0201
	dc.w	$0105,$0532,$192f,$171f,$0f00,$0001,$0505,$4000
_OW:	dc.b	"OW"		;  4 (0088)
	dc.w	$0e0e,$0244,$0122,$03c0,$01e0,$0b04,$0582,$0201
	dc.w	$0104,$0432,$192d,$161e,$0f00,$0001,$0505,$4000
_UW:	dc.b	"UW"		;  5 (00aa)
	dc.w	$0e09,$01a4,$00d2,$0442,$021c,$0a46,$051e,$0201
	dc.w	$0104,$042f,$1728,$141e,$0f00,$0001,$0505,$4000
_AR:	dc.b	"AR"		;  6 (00cc)
	dc.w	$0f0f,$0316,$019a,$0370,$01d6,$09c4,$04c4,$0201
	dc.w	$0104,$0432,$1831,$181d,$0e00,$0001,$0404,$4000
_WX:	dc.b	"WX"		;  7 (00ee)
	dc.w	$0808,$01a4,$00d2,$03a2,$01cc,$0a00,$0500,$0501
	dc.w	$0104,$042f,$1728,$141e,$0f00,$0001,$0404,$4000
_YX:	dc.b	"YX"		;  8 (0110)
	dc.w	$0807,$01e0,$00f0,$08a2,$044c,$0ba4,$05d2,$0501
	dc.w	$0104,$0430,$182d,$1627,$1300,$0001,$0404,$4000
_AE:	dc.b	"AE"		;  9 (0132)
	dc.w	$0e08,$0316,$019a,$06f4,$03b6,$09c4,$04c4,$0201
	dc.w	$0104,$0432,$182f,$1826,$1100,$0001,$0404,$4000
_IY:	dc.b	"IY"		; 10 (0154)
	dc.w	$0b08,$00fa,$006e,$0910,$04a6,$0c94,$062c,$0201
	dc.w	$0104,$0432,$1821,$1124,$1100,$0001,$0404,$4000
_ER:	dc.b	"ER"		; 11 (0176)
	dc.w	$0e0b,$0244,$0122,$058c,$02c6,$09c4,$04c4,$0501
	dc.w	$0104,$0432,$182d,$1521,$1100,$0001,$0404,$4000
_AO:	dc.b	"AO"		; 12 (0198)
	dc.w	$100c,$01ea,$00e6,$0334,$01d6,$09c4,$04c4,$0201
	dc.w	$0104,$0432,$182d,$1516,$0a00,$0001,$0404,$4000
_UX:	dc.b	"UX"		; 13 (01ba)
	dc.w	$0c0a,$01c2,$00dc,$0488,$0244,$0a46,$051e,$0201
	dc.w	$0104,$0432,$1826,$1111,$0700,$0001,$0404,$4000
_UH:	dc.b	"UH"		; 14 (01dc)
	dc.w	$0c0a,$02bc,$015e,$0550,$02c6,$09c4,$04c4,$0201
	dc.w	$0104,$0432,$182b,$151f,$0e00,$0001,$0404,$4000
_AH:	dc.b	"AH"		; 15 (01fe)
	dc.w	$0b06,$02e4,$0172,$0582,$02e4,$0ae6,$053c,$0201
	dc.w	$0104,$0432,$182d,$161f,$0e00,$0001,$0404,$4000
_AA:	dc.b	"AA"		; 16 (0220)
	dc.w	$0f0b,$0262,$0122,$0370,$01d6,$09c4,$04c4,$0201
	dc.w	$0104,$0432,$182f,$1816,$0a00,$0001,$0404,$4000
_OH:	dc.b	"OH"		; 17 (0242)
	dc.w	$0e0a,$0244,$0104,$03c0,$0208,$0b04,$056e,$0a01
	dc.w	$0104,$0432,$182f,$181e,$0e00,$0001,$0404,$4000
_AX:	dc.b	"AX"		; 18 (0264)
	dc.w	$0605,$01ea,$00e6,$05c8,$02c6,$09c4,$04c4,$0201
	dc.w	$0104,$0432,$1832,$1821,$1100,$0001,$0404,$4000
_IX:	dc.b	"IX"		; 19 (0286)
	dc.w	$0605,$01c2,$00d2,$0924,$0460,$0ba4,$05aa,$0501
	dc.w	$0104,$042f,$162c,$1526,$1400,$0001,$0404,$4000
_IH:	dc.b	"IH"		; 20 (02a8)
	dc.w	$0908,$0190,$00aa,$0820,$042e,$0a00,$053c,$0201
	dc.w	$0104,$0432,$1824,$1123,$1100,$0001,$0404,$4000
_EH:	dc.b	"EH"		; 21 (02ca)
	dc.w	$0b08,$0280,$015e,$07e4,$042e,$09c4,$04c4,$0201
	dc.w	$0104,$0432,$182a,$1526,$1100,$0001,$0404,$4000
_DH:	dc.b	"DH"		; 22 (02ec)
	dc.w	$0606,$0118,$00aa,$0640,$04a6,$0a00,$0000,$1401
	dc.w	$0203,$021d,$001f,$001a,$0028,$0000,$0000,$6010
_ZH:	dc.b	"ZH"		; 23 (030e)
	dc.w	$0606,$0118,$00aa,$07e4,$04a6,$0a00,$0000,$1401
	dc.w	$0203,$021d,$001a,$0024,$0028,$0000,$0000,$6010
_CH:	dc.b	"CH"		; 24 (0330)
	dc.w	$0606,$00be,$006e,$06f4,$03b6,$0a78,$0a78,$1701
	dc.w	$0002,$0000,$0000,$0000,$0000,$0000,$0000,$a000
	dc.b	"CH"		; 25 (0352)
	dc.w	$0707,$0190,$00aa,$07e4,$04a6,$0a00,$0000,$1601
	dc.w	$0203,$0100,$001f,$002a,$002c,$0000,$0000,$2014
_LX:	dc.b	"LX"		; 26 (0374)
	dc.w	$0b09,$0208,$0104,$04a6,$024e,$0dc0,$06e0,$0801
	dc.w	$0103,$022f,$0028,$001f,$0000,$0000,$0000,$4000
_RX:	dc.b	"RX"		; 27 (0396)
	dc.w	$0a07,$0244,$0122,$0668,$0334,$07c6,$03de,$0201
	dc.w	$0103,$032f,$002d,$0027,$0000,$0000,$0000,$4000
_SH:	dc.b	"SH"		; 28 (03b8)
	dc.w	$0a0a,$0190,$00aa,$07e4,$04a6,$0a00,$0000,$1201
	dc.w	$0203,$0100,$001f,$0028,$002a,$0000,$0000,$2011
_NX:	dc.b	"NX"		; 29 (03da)
	dc.w	$0807,$0136,$006e,$0334,$060e,$0af0,$062c,$0801
	dc.w	$0102,$0132,$0021,$001c,$0000,$0000,$0000,$4000
_TH:	dc.b	"TH"		; 30 (03fc)
	dc.w	$0a0a,$0190,$00aa,$06f4,$04a6,$0a78,$0a78,$1201
	dc.w	$0003,$0100,$001a,$001c,$002a,$0000,$0000,$2010
	dc.b	"/H"		; 31 (041e)
	dc.w	$0707,$01ea,$0000,$05c8,$0000,$09c4,$0000,$1e02
	dc.w	$0200,$041f,$f220,$f216,$f92c,$0002,$0007,$001a
_V:	dc.b	"V "		; 32 (0440)
	dc.w	$0807,$0118,$00aa,$058c,$015e,$0a00,$03d4,$1401
	dc.w	$0103,$021b,$0026,$0022,$0028,$0000,$0000,$6010
_Z:	dc.b	"Z "		; 33 (0462)
	dc.w	$0606,$0118,$00aa,$06b8,$03b6,$0a00,$0000,$1401
	dc.w	$0203,$021d,$0018,$0018,$002c,$0000,$0000,$600e
_J:	dc.b	"J "		; 34 (0484)
	dc.w	$0404,$00c8,$006e,$0848,$044c,$0f28,$0f28,$1a01
	dc.w	$0002,$001f,$0000,$0000,$0000,$0000,$0000,$c000
	dc.b	"J "		; 35 (04a6)
	dc.w	$0606,$00a0,$006e,$09e2,$051e,$0ca8,$0000,$1901
	dc.w	$0203,$012c,$0024,$001f,$002b,$0000,$0000,$4012
_L:	dc.b	"L "		; 36 (04c8)
	dc.w	$0906,$01c2,$00dc,$03c0,$01b8,$0dc0,$06a4,$0901
	dc.w	$0103,$022f,$0028,$001f,$0000,$0000,$0000,$4000
_R:	dc.b	"R "		; 37 (04ea)
	dc.w	$0b0b,$01ea,$0000,$049c,$024e,$0640,$02e4,$0a01
	dc.w	$0103,$022a,$1523,$1123,$1100,$0001,$0505,$4000
_W:	dc.b	"W "		; 38 (050c)
	dc.w	$0808,$0168,$0064,$0302,$015e,$0b40,$0564,$0801
	dc.w	$0103,$022f,$1728,$1428,$1400,$0001,$0203,$4000
_Y:	dc.b	"Y "		; 39 (052e)
	dc.w	$0707,$00fa,$006e,$09c4,$04a6,$0ba4,$05b4,$0a01
	dc.w	$0104,$0432,$1821,$1126,$1100,$0001,$0404,$4000
_Q:	dc.b	"Q "		; 40 (0550)
	dc.w	$0505,$0000,$0000,$0000,$0000,$0000,$0000,$1d00
	dc.w	$0000,$0000,$f600,$f600,$f600,$0002,$0300,$0000
_P:	dc.b	"P "		; 41 (0572)
	dc.w	$0808,$00be,$006e,$02f8,$015e,$09c4,$0000,$1701
	dc.w	$0202,$0200,$0000,$0000,$0000,$0000,$0000,$8000
	dc.b	"P "		; 42 (0594)
	dc.w	$0101,$00be,$0000,$02f8,$0000,$09c4,$0000,$1d00
	dc.w	$0000,$0018,$0028,$0024,$002d,$0000,$0000,$8014
	dc.b	"P "		; 43 (05b6)
	dc.w	$0202,$00be,$006e,$02f8,$015e,$09c4,$0000,$1701
	dc.w	$0202,$0215,$0023,$001e,$002b,$0000,$0000,$0018
_T:	dc.b	"T "		; 44 (05d8)
	dc.w	$0604,$00be,$006e,$06f4,$03b6,$0a78,$0a78,$1701
	dc.w	$0002,$0200,$0000,$0000,$0000,$0000,$0000,$8000
	dc.b	"T "		; 45 (05fa)
	dc.w	$0101,$00be,$0000,$06f4,$0000,$0a78,$0000,$1d00
	dc.w	$0000,$0000,$0000,$0026,$002d,$0000,$0000,$8008
	dc.b	"T "		; 46 (061c)
	dc.w	$0202,$00be,$006e,$06f4,$03b6,$0a78,$0a78,$1701
	dc.w	$0002,$0100,$0000,$001c,$002b,$0000,$0000,$000a
_K:	dc.b	"K "		; 47 (063e)
	dc.w	$0706,$00be,$006e,$05c8,$060e,$0a3c,$062c,$1701
	dc.w	$0103,$0300,$0000,$0000,$0000,$0000,$0000,$8000
	dc.b	"K "		; 48 (0660)
	dc.w	$0201,$0140,$0000,$0ac8,$0000,$0ca8,$0000,$1d00
	dc.w	$0000,$002d,$002b,$0026,$002d,$0000,$0000,$8008
	dc.b	"K "		; 49 (0682)
	dc.w	$0404,$00be,$006e,$05c8,$060e,$0a3c,$062c,$1701
	dc.w	$0103,$0200,$0000,$0000,$0000,$0000,$0000,$0000
_B:	dc.b	"B "		; 50 (06a4)
	dc.w	$0806,$00be,$006e,$02f8,$015e,$09c4,$0000,$1a01
	dc.w	$0202,$0218,$0000,$0000,$0000,$0000,$0000,$c000
	dc.b	"B "		; 51 (06c6)
	dc.w	$0201,$00be,$0000,$02f8,$0000,$09c4,$0000,$1d00
	dc.w	$0000,$0018,$002e,$0028,$0000,$0000,$0000,$c000
	dc.b	"B "		; 52 (06e8)
	dc.w	$0101,$00be,$006e,$02f8,$015e,$09c4,$0000,$1b01
	dc.w	$0202,$0018,$0018,$0018,$0000,$0000,$0000,$4000
_D:	dc.b	"D "		; 53 (070a)
	dc.w	$0705,$00be,$006e,$06f4,$03b6,$0a78,$0a78,$1a01
	dc.w	$0002,$021f,$0000,$0000,$0000,$0000,$0000,$c000
	dc.b	"D "		; 54 (072c)
	dc.w	$0201,$00be,$0000,$06f4,$0000,$0a78,$0000,$1d00
	dc.w	$0000,$0026,$0026,$0023,$0000,$0000,$0000,$c000
	dc.b	"D "		; 55 (074e)
	dc.w	$0101,$00be,$006e,$06f4,$03b6,$0a78,$0a78,$1b01
	dc.w	$0003,$0126,$001c,$0018,$0000,$0000,$0000,$4000
_G:	dc.b	"G "		; 56 (0770)
	dc.w	$0706,$00be,$006e,$05c8,$060e,$0a3c,$062c,$1a01
	dc.w	$0102,$0220,$0000,$0000,$0000,$0000,$0000,$c000
	dc.b	"G "		; 57 (0792)
	dc.w	$0201,$00be,$0000,$05c8,$0000,$0a3c,$0000,$1d00
	dc.w	$0000,$0022,$0028,$0024,$0000,$0000,$0000,$c000
	dc.b	"G "		; 58 (07b4)
	dc.w	$0202,$00be,$006e,$05c8,$060e,$0a3c,$062c,$1b01
	dc.w	$0104,$0100,$0000,$0000,$0000,$0000,$0000,$4000
_M:	dc.b	"M "		; 59 (07d6)
	dc.w	$0807,$00be,$006e,$03e8,$015e,$0898,$0000,$0801
	dc.w	$0201,$012d,$0013,$001a,$0000,$0000,$0000,$4000
_N:	dc.b	"N "		; 60 (07f8)
	dc.w	$0807,$00be,$006e,$0514,$03b6,$0a3c,$0a78,$0801
	dc.w	$0002,$012d,$0013,$001a,$0000,$0000,$0000,$4000
_F:	dc.b	"F "		; 61 (081a)
	dc.w	$0a0a,$0190,$00aa,$058c,$015e,$0a00,$03d4,$1201
	dc.w	$0103,$0100,$0020,$001e,$002a,$0000,$0000,$200a
_S:	dc.b	"S "		; 62 (083c)
	dc.w	$0c0c,$0190,$00aa,$06b8,$03b6,$0a3c,$0000,$1201
	dc.w	$0203,$0100,$001c,$001c,$002c,$0000,$0000,$2007
	dc.b	"- "		; 63 (085e)
	dc.w	$0808,$0000,$0000,$0000,$0000,$0000,$0000,$1f00
	dc.w	$0000,$0000,$f600,$f600,$f600,$0001,$0300,$0000
	dc.b	". "		; 64 (0880v )
	dc.w	$1212,$0000,$0000,$0000,$0000,$0000,$0000,$1f00
	dc.w	$0000,$0000,$f600,$f600,$f600,$0001,$0300,$0000
	dc.b	", "		; 65 (08a2)
	dc.w	$0e0e,$0000,$0000,$0000,$0000,$0000,$0000,$1f00
	dc.w	$0000,$0000,$f600,$f600,$f600,$0001,$0300,$0000
	dc.b	"? "		; 66 (08c4)
	dc.w	$1212,$0000,$0000,$0000,$0000,$0000,$0000,$1f00
	dc.w	$0000,$0000,$f600,$f600,$f600,$0001,$0300,$0000
_SPACE:	dc.b	"  "		; 67 (08e6)
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$1f00
	dc.w	$0000,$0000,$f600,$f600,$f600,$0001,$0300,$0000
_UL:	dc.b	"UL"		; 68 (0908)
	dc.w	$0264,$04c8,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
_UM:	dc.b	"UM"		; 69 (092a)
	dc.w	$0264,$07d6,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
_UN:	dc.b	"UN"		; 70 (094c)
	dc.w	$0264,$07f8,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
_IL:	dc.b	"IL"		; 71 (096e)
	dc.w	$0286,$04c8,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
_IM:	dc.b	"IM"		; 72 (0990)
	dc.w	$0286,$07d6,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
_IN:	dc.b	"IN"		; 73 (09b2)
	dc.w	$0286,$07f8,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$ffff,$ffff

P44c2:	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$ffff,$ffff

__set_rate:
	dc.b	"O"
	even
__set_pitc:
	dc.b	"M"
	even
use_rate:
	dc.b	"O"
use_pitc:
	dc.b	"M"
badbuf:
	dc.w	-1

	bss

	ds.l	1
buffer:	ds.b	1028
spchbuff:
	ds.b	$2400
saymode:
	ds.w	1
old134:
	ds.l	1

