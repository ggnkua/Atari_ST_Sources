*-------------------------------------------------------------------------------
* Jeder Eintrag ist 16 Bytes lang,
* 1.Word: gibt an, welche Bits des Opcodes immer gesetzt sind
* 2.Word: gibt an, welche Bits des Opcodes immer gel”scht sind, gel”schte Bits
*		  sind gesetzt!
* 3.Word: bei den FPU Befehlen enth„lt dieses in den Bit 0-5 die untersten
*		  6 Bit des zweiten Befehlwortes, sonst gilt:
* 3.Word: Bit 0-11 = erlaubte Adressierungsarten
*		  Bit 11 = Dn
*		  Bit 10 = An
*		  Bit 9  = (An)
*		  Bit 8  = (An)+
*		  Bit 7  = -(An)
*		  Bit 6  = d16(An)
*		  Bit 5  = d8(An,Xn), (bd,An,Xn), ([bd,An],Xn,od), ([bd,An,Xn],od)
*		  Bit 4  = Abs.w
*		  Bit 3  = Abs.l
*		  Bit 2  = d16(PC)
*		  Bit 1  = d8(PC,Xn), (bd,PC,Xn), ([bd,PC],Xn,od), ([bd,PC,Xn],od)
*		  Bit 0  = #Immediate
*	      Bit 12/13  = erlaubte Operandenl„nge
*		  00	 = Byte
*		  01	 = Word
*		  10	 = Long
*		  Bit 14 = An zugelassen bei .w und .l (Adressierungsart 4)
*		  Bit 15 = - Bitbefehle ohne <ea>,Dn (eigentlich nur #Imm)
*				   #Imm,Dn folgt bei Adressierungsart 11
*				   - CHK2 gesetzt, CMP2 gel”scht
*		  Bit 14/15 = 0 = DIVS.L
*					= 1 = DIVU.L
*					= 2 = DIVSL.L
*					= 3 = DIVUL.L
*		  Nibble gesetzt ---> Befehl darf ohne 0 oder 32 abgeschlossen sein
*		  (Scc, Bcc, DBcc, TRAPcc)
* 4.Word: Higher Byte = Befehlsformat (siehe Doku zum Disassembler)
*		  Lower Byte	= Prozessortyp
*		  Bit 0 = 68000
*		  Bit 1 = 68010
*		  Bit 2 = 68020
*		  Bit 3 = 68030
*		  Bit 4 = 68040
*		  Bit 5 = reserved
*		  Bit 6 = FPU
* Anschliessend kommt der String, der 8 Zeichen lang ist
*-------------------------------------------------------------------------------

		.EXPORT		Befehlstabelle

*-------------------------------------------------------------------------------

		.DATA
Befehlstabelle:	dc.w	NULL-Befehlstabelle,EINS-Befehlstabelle,ZWEI-Befehlstabelle
				dc.w	DREI-Befehlstabelle,VIER-Befehlstabelle,FUENF-Befehlstabelle
				dc.w	SECHS-Befehlstabelle,SIEBEN-Befehlstabelle,ACHT-Befehlstabelle
				dc.w	NEUN-Befehlstabelle,ZEHN-Befehlstabelle,ELF-Befehlstabelle
				dc.w	ZWOELF-Befehlstabelle,DREIZEHN-Befehlstabelle,VIERZEHN-Befehlstabelle
				dc.w	FUENFZEHN-Befehlstabelle

*-------------------------------------------------------------------------------

FUENFZEHN:		dc.w	88
				dc.b	$F6,$20,$09,$D8,$23,$00,40,%10000
				dc.b	'MOVE16  '
				dc.b	$F6,$00,$09,$E0,$23,$00,40,%10000
				dc.b	'MOVE16  '
				dc.b	$F4,$08,$0B,$30,$02,$00,41,%10000
				dc.b	'CINVL   '
				dc.b	$F4,$10,$0B,$28,$02,$00,41,%10000
				dc.b	'CINVP   '
				dc.b	$F4,$18,$0B,$20,$02,$00,41,%10000
				dc.b	'CINVA   '
				dc.b	$F4,$28,$0B,$10,$02,$00,41,%10000
				dc.b	'CPUSHL  '
				dc.b	$F4,$30,$0B,$08,$02,$00,41,%10000
				dc.b	'CPUSHP  '
				dc.b	$F4,$38,$0B,$00,$02,$00,41,%10000
				dc.b	'CPUSHA  '
				dc.b	$F0,$00,$0F,$C0,$02,$78,42,%1000
				dc.b	'PMOVE   '
				dc.b	$F0,$00,$0F,$C0,$02,$78,42,%1000
				dc.b	'PMOVEFD '

				dc.b	$F0,$00,$0F,$C0,$02,$78,43,%1000	; 68030 *
				dc.b	'PFLUSH  '
				dc.b	$F0,$00,$0F,$C0,$02,$78,43,%1000	; 68030 *
				dc.b	'PFLUSHA '

				dc.b	$F5,$08,$0A,$F0,$02,$00,44,%10000	; 68040 *
				dc.b	'PFLUSH  '
				dc.b	$F5,$00,$0A,$F8,$02,$00,44,%10000	; 68040 *
				dc.b	'PFLUSHN '
				dc.b	$F5,$18,$0A,$E0,$00,$00,0,%10000	; 68040 *
				dc.b	'PFLUSHA '
				dc.b	$F5,$10,$0A,$E8,$00,$00,0,%10000	; 68040 *
				dc.b	'PFLUSHAN'

				dc.b	$F0,$00,$0F,$C0,$02,$78,45,%1000	; 68030 *
				dc.b	'PLOADR  '
				dc.b	$F0,$00,$0F,$C0,$02,$78,45,%1000	; 68030 *
				dc.b	'PLOADW  '

				dc.b	$F0,$00,$0F,$C0,$02,$78,46,%1000	; 68030
				dc.b	'PTESTR  '
				dc.b	$F0,$00,$0F,$C0,$02,$78	,46,%1000	; 68030
				dc.b	'PTESTW  '
				dc.b	$F5,$48,$0A,$B0,$02,$00,47,%10000	; 68040
				dc.b	'PTESTW  '
				dc.b	$F5,$68,$0A,$90,$02,$00,47,%10000	; 68040
				dc.b	'PTESTR  '

*---------------------- Data Movement Operations
				dc.b	$F2,$00,$0D,$C0,$FF,$00,48,%1010000 ; normal
				dc.b	'FMOVE   '
				dc.b	$F2,$00,$0D,$C0,$FF,$40,48,%10000 ; normal
				dc.b	'FSMOVE  '
				dc.b	$F2,$00,$0D,$C0,$FF,$44,48,%10000 ; normal
				dc.b	'FDMOVE  '
				dc.b	$F2,$00,$0D,$C0,$00,$00,51,%1010000 ; mit K-Faktor
				dc.b	'FMOVE   '
				dc.b	$F2,$00,$0D,$FF,$00,$00,52,%1010000
				dc.b	'FMOVECR '
				dc.b	$F2,$00,$0D,$C0,$02,$F8,57,%1010000 ; reg,mem
				dc.b	'FMOVEM  '
				dc.b	$F2,$00,$0D,$C0,$03,$7E,58,%1010000 ; mem,reg
				dc.b	'FMOVEM  '
* die beiden folgenden Befehle sind gleich codiert
* sie unterscheiden sich nur durch das oberste Nibble des 3.Words
				dc.b	$F2,$00,$0D,$C0,$FF,$F8,59,%1010000 ; Control Reg.
				dc.b	'FMOVE   '
				dc.b	$F2,$00,$0D,$C0,$0F,$F8,59,%1010000 ; Control Reg.
				dc.b	'FMOVEM  '

*---------------------- Dyadic Operations
* 3.Word: enth„lt in den Bits 0-5 die Extension
* das obere Byte ist $FF und unterscheidet die Dyadic von den Monadic Operations

				dc.b	$F2,$00,$0D,$C0,$FF,$38,48,%1010000
				dc.b	'FCMP    '
				dc.b	$F2,$00,$0D,$C0,$FF,$22,48,%1010000
				dc.b	'FADD    '
				dc.b	$F2,$00,$0D,$C0,$FF,$62,48,%10000
				dc.b	'FSADD   '
				dc.b	$F2,$00,$0D,$C0,$FF,$66,48,%10000
				dc.b	'FDADD   '
				dc.b	$F2,$00,$0D,$C0,$FF,$28,48,%1010000
				dc.b	'FSUB    '
				dc.b	$F2,$00,$0D,$C0,$FF,$68,48,%10000
				dc.b	'FSSUB   '
				dc.b	$F2,$00,$0D,$C0,$FF,$6C,48,%10000
				dc.b	'FDSUB   '
				dc.b	$F2,$00,$0D,$C0,$FF,$23,48,%1010000
				dc.b	'FMUL    '
				dc.b	$F2,$00,$0D,$C0,$FF,$63,48,%10000
				dc.b	'FSMUL   '
				dc.b	$F2,$00,$0D,$C0,$FF,$67,48,%10000
				dc.b	'FDMUL   '
				dc.b	$F2,$00,$0D,$C0,$FF,$20,48,%1010000
				dc.b	'FDIV    '
				dc.b	$F2,$00,$0D,$C0,$FF,$60,48,%10000
				dc.b	'FSDIV   '
				dc.b	$F2,$00,$0D,$C0,$FF,$64,48,%10000
				dc.b	'FDDIV   '
				dc.b	$F2,$00,$0D,$C0,$FF,$27,48,%1010000
				dc.b	'FSGLMUL '
				dc.b	$F2,$00,$0D,$C0,$FF,$24,48,%1010000
				dc.b	'FSGLDIV '
				dc.b	$F2,$00,$0D,$C0,$FF,$21,48,%1010000
				dc.b	'FMOD    '
				dc.b	$F2,$00,$0D,$C0,$FF,$25,48,%1010000
				dc.b	'FREM    '
				dc.b	$F2,$00,$0D,$C0,$FF,$26,48,%1010000
				dc.b	'FSCALE  '

*---------------------- Monadic Operations
* 3.Word: enth„lt in den Bits 0-5 die Extension
* das obere Byte ist $00 und unterscheidet die Monadic von den Dyadic Operations

				dc.b	$F2,$00,$0D,$C0,$00,$18,48,%1010000
				dc.b	'FABS    '
				dc.b	$F2,$00,$0D,$C0,$00,$58,48,%10000
				dc.b	'FSABS   '
				dc.b	$F2,$00,$0D,$C0,$00,$5C,48,%10000
				dc.b	'FDABS   '
				dc.b	$F2,$00,$0D,$C0,$00,$1C,48,%1010000
				dc.b	'FACOS   '
				dc.b	$F2,$00,$0D,$C0,$00,$0C,48,%1010000
				dc.b	'FASIN   '
				dc.b	$F2,$00,$0D,$C0,$00,$0A,48,%1010000
				dc.b	'FATAN   '
				dc.b	$F2,$00,$0D,$C0,$00,$0D,48,%1010000
				dc.b	'FATANH  '
				dc.b	$F2,$00,$0D,$C0,$00,$1D,48,%1010000
				dc.b	'FCOS    '
				dc.b	$F2,$00,$0D,$C0,$00,$19,48,%1010000
				dc.b	'FCOSH   '
				dc.b	$F2,$00,$0D,$C0,$00,$10,48,%1010000
				dc.b	'FETOX   '
				dc.b	$F2,$00,$0D,$C0,$00,$08,48,%1010000
				dc.b	'FETOXM1 '
				dc.b	$F2,$00,$0D,$C0,$00,$1E,48,%1010000
				dc.b	'FGETEXP '
				dc.b	$F2,$00,$0D,$C0,$00,$1F,48,%1010000
				dc.b	'FGETMAN '
				dc.b	$F2,$00,$0D,$C0,$00,$01,48,%1010000
				dc.b	'FINT    '
				dc.b	$F2,$00,$0D,$C0,$00,$03,48,%1010000
				dc.b	'FINTRZ  '
				dc.b	$F2,$00,$0D,$C0,$00,$15,48,%1010000
				dc.b	'FLOG10  '
				dc.b	$F2,$00,$0D,$C0,$00,$16,48,%1010000
				dc.b	'FLOG2   '
				dc.b	$F2,$00,$0D,$C0,$00,$14,48,%1010000
				dc.b	'FLOGN   '
				dc.b	$F2,$00,$0D,$C0,$00,$06,48,%1010000
				dc.b	'FLOGNP1 '
				dc.b	$F2,$00,$0D,$C0,$00,$1A,48,%1010000
				dc.b	'FNEG    '
				dc.b	$F2,$00,$0D,$C0,$00,$5A,48,%10000
				dc.b	'FSNEG   '
				dc.b	$F2,$00,$0D,$C0,$00,$5E,48,%10000
				dc.b	'FDNEG   '
				dc.b	$F2,$00,$0D,$C0,$00,$0E,48,%1010000
				dc.b	'FSIN    '
				dc.b	$F2,$00,$0D,$C0,$00,$02,48,%1010000
				dc.b	'FSINH   '
				dc.b	$F2,$00,$0D,$C0,$00,$04,48,%1010000
				dc.b	'FSQRT   '
				dc.b	$F2,$00,$0D,$C0,$00,$41,48,%10000
				dc.b	'FSSQRT  '
				dc.b	$F2,$00,$0D,$C0,$00,$45,48,%10000
				dc.b	'FDSQRT  '
				dc.b	$F2,$00,$0D,$C0,$00,$0F,48,%1010000
				dc.b	'FTAN    '
				dc.b	$F2,$00,$0D,$C0,$00,$09,48,%1010000
				dc.b	'FTANH   '
				dc.b	$F2,$00,$0D,$C0,$00,$12,48,%1010000
				dc.b	'FTENTOX '
				dc.b	$F2,$00,$0D,$C0,$00,$11,48,%1010000
				dc.b	'FTWOTOX '

*---------------------- Dual Monadic Operations
				dc.b	$F2,$00,$0D,$C0,$00,$00,56,%1010000
				dc.b	'FSINCOS '

*---------------------- System Control Operations
				dc.b	$F3,$40,$0C,$80,$03,$7E,2,%1010000
				dc.b	'FRESTORE'
				dc.b	$F3,$00,$0C,$C0,$02,$F8,2,%1010000
				dc.b	'FSAVE   '
				dc.b	$F2,$78,$0D,$80,$00,$00,55,%1010000
				dc.b	'FTRAP   '

*---------------------- Program Control Operations
				dc.b	$F2,$00,$0D,$C0,$01,$3A,48,%1010000
				dc.b	'FTST    '
				dc.b	$F2,$80,$0D,$00,$00,$00,49,%1010000
				dc.b	'FB      '
				dc.b	$F2,$48,$0D,$B0,$00,$00,50,%1010000
				dc.b	'FDB     '
				dc.b	$F2,$40,$0D,$80,$0B,$F8,54,%1010000
				dc.b	'FS      '
				dc.b	$F2,$80,$0D,$7F,$00,$00,53,%1010000
				dc.b	'FNOP    '

*-----------------------

VIERZEHN:		dc.w	55
				dc.b	$E7,$C0,$18,$00,$13,$F8,2,%11111 ; Memory
				dc.b	'ROL.W   '
				dc.b	$E6,$C0,$19,$00,$13,$F8,2,%11111 ; Memory
				dc.b	'ROR.W   '
				dc.b	$E5,$C0,$1A,$00,$13,$F8,2,%11111 ; Memory
				dc.b	'ROXL.W  '
				dc.b	$E4,$C0,$1B,$00,$13,$F8,2,%11111 ; Memory
				dc.b	'ROXR.W  '
				dc.b	$E3,$C0,$1C,$00,$13,$F8,2,%11111 ; Memory
				dc.b	'LSL.W   '
				dc.b	$E2,$C0,$1D,$00,$13,$F8,2,%11111 ; Memory
				dc.b	'LSR.W   '
				dc.b	$E1,$C0,$1E,$00,$13,$F8,2,%11111 ; Memory
				dc.b	'ASL.W   '
				dc.b	$E0,$C0,$1F,$00,$13,$F8,2,%11111 ; Memory
				dc.b	'ASR.W   '
				dc.b	$E7,$C0,$18,$00,$13,$F8,2,%11111 ; Memory
				dc.b	'ROL     '
				dc.b	$E6,$C0,$19,$00,$13,$F8,2,%11111 ; Memory
				dc.b	'ROR     '
				dc.b	$E5,$C0,$1A,$00,$13,$F8,2,%11111 ; Memory
				dc.b	'ROXL    '
				dc.b	$E4,$C0,$1B,$00,$13,$F8,2,%11111 ; Memory
				dc.b	'ROXR    '
				dc.b	$E3,$C0,$1C,$00,$13,$F8,2,%11111 ; Memory
				dc.b	'LSL     '
				dc.b	$E2,$C0,$1D,$00,$13,$F8,2,%11111 ; Memory
				dc.b	'LSR     '
				dc.b	$E1,$C0,$1E,$00,$13,$F8,2,%11111 ; Memory
				dc.b	'ASL     '
				dc.b	$E0,$C0,$1F,$00,$13,$F8,2,%11111 ; Memory
				dc.b	'ASR     '

				dc.b	$E1,$98,$10,$40,$08,$01,13,%11111
				dc.b	'ROL.L   '
				dc.b	$E1,$58,$10,$80,$08,$01,13,%11111
				dc.b	'ROL.W   '
				dc.b	$E1,$18,$10,$C0,$08,$01,13,%11111
				dc.b	'ROL.B   '
				dc.b	$E1,$58,$10,$80,$08,$01,13,%11111
				dc.b	'ROL     '
				dc.b	$E0,$98,$11,$40,$08,$01,13,%11111
				dc.b	'ROR.L   '
				dc.b	$E0,$58,$11,$80,$08,$01,13,%11111
				dc.b	'ROR.W   '
				dc.b	$E0,$18,$11,$C0,$08,$01,13,%11111
				dc.b	'ROR.B   '
				dc.b	$E0,$58,$11,$80,$08,$01,13,%11111
				dc.b	'ROR     '
				dc.b	$E1,$90,$10,$48,$08,$01,13,%11111
				dc.b	'ROXL.L  '
				dc.b	$E1,$50,$10,$88,$08,$01,13,%11111
				dc.b	'ROXL.W  '
				dc.b	$E1,$10,$10,$C8,$08,$01,13,%11111
				dc.b	'ROXL.B  '
				dc.b	$E1,$50,$10,$88,$08,$01,13,%11111
				dc.b	'ROXL    '
				dc.b	$E0,$90,$11,$48,$08,$01,13,%11111
				dc.b	'ROXR.L  '
				dc.b	$E0,$50,$11,$88,$08,$01,13,%11111
				dc.b	'ROXR.W  '
				dc.b	$E0,$10,$11,$C8,$08,$01,13,%11111
				dc.b	'ROXR.B  '
				dc.b	$E0,$50,$11,$88,$08,$01,13,%11111
				dc.b	'ROXR    '
				dc.b	$E1,$88,$10,$50,$08,$01,13,%11111
				dc.b	'LSL.L   '
				dc.b	$E1,$48,$10,$90,$08,$01,13,%11111
				dc.b	'LSL.W   '
				dc.b	$E1,$08,$10,$D0,$08,$01,13,%11111
				dc.b	'LSL.B   '
				dc.b	$E1,$48,$10,$90,$08,$01,13,%11111
				dc.b	'LSL     '
				dc.b	$E0,$88,$11,$50,$08,$01,13,%11111
				dc.b	'LSR.L   '
				dc.b	$E0,$48,$11,$90,$08,$01,13,%11111
				dc.b	'LSR.W   '
				dc.b	$E0,$08,$11,$D0,$08,$01,13,%11111
				dc.b	'LSR.B   '
				dc.b	$E0,$48,$11,$90,$08,$01,13,%11111
				dc.b	'LSR     '
				dc.b	$E1,$80,$10,$58,$08,$01,13,%11111
				dc.b	'ASL.L   '
				dc.b	$E1,$40,$10,$98,$08,$01,13,%11111
				dc.b	'ASL.W   '
				dc.b	$E1,$00,$10,$D8,$08,$01,13,%11111
				dc.b	'ASL.B   '
				dc.b	$E1,$40,$10,$98,$08,$01,13,%11111
				dc.b	'ASL     '
				dc.b	$E0,$80,$11,$58,$08,$01,13,%11111
				dc.b	'ASR.L   '
				dc.b	$E0,$40,$11,$98,$08,$01,13,%11111
				dc.b	'ASR.W   '
				dc.b	$E0,$00,$11,$D8,$08,$01,13,%11111
				dc.b	'ASR.B   '
				dc.b	$E0,$40,$11,$98,$08,$01,13,%11111
				dc.b	'ASR     '

				dc.b	$E8,$C0,$17,$00,$0A,$7E,29,%11100
				dc.b	'BFTST   '
				dc.b	$E9,$C0,$16,$00,$0A,$7E,29,%11100
				dc.b	'BFEXTU  '
				dc.b	$EA,$C0,$15,$00,$0A,$78,29,%11100
				dc.b	'BFCHG   '
				dc.b	$EB,$C0,$14,$00,$0A,$7E,29,%11100
				dc.b	'BFEXTS  '
				dc.b	$EC,$C0,$13,$00,$0A,$78,29,%11100
				dc.b	'BFCLR   '
				dc.b	$ED,$C0,$12,$00,$0A,$7E,29,%11100
				dc.b	'BFFFO   '
				dc.b	$EE,$C0,$11,$00,$0A,$78,29,%11100
				dc.b	'BFSET   '
				dc.b	$EF,$C0,$10,$00,$0A,$78,29,%11100
				dc.b	'BFINS   '

*-----------------------

DREIZEHN:		dc.w	10
				dc.b	$D0,$80,$20,$40,$63,$F8,4,%11111
				dc.b	'ADD.L   '
				dc.b	$D0,$40,$20,$80,$53,$F8,4,%11111
				dc.b	'ADD.W   '
				dc.b	$D0,$00,$20,$C0,$03,$F8,4,%11111
				dc.b	'ADD.B   '
				dc.b	$D0,$40,$20,$80,$53,$F8,4,%11111
				dc.b	'ADD     '

				dc.b	$D1,$C0,$20,$00,$2F,$FF,5,%11111
				dc.b	'ADDA.L  '
				dc.b	$D0,$C0,$21,$00,$1F,$FF,5,%11111
				dc.b	'ADDA.W  '
				dc.b	$D0,$C0,$21,$00,$1F,$FF,5,%11111
				dc.b	'ADDA    '

				dc.b	$D1,$80,$20,$70,$28,$80,3,%11111
				dc.b	'ADDX.L  '
				dc.b	$D1,$40,$20,$B0,$18,$80,3,%11111
				dc.b	'ADDX.W  '
				dc.b	$D1,$00,$20,$F0,$08,$80,3,%11111
				dc.b	'ADDX.B  '
				dc.b	$D1,$40,$20,$B0,$18,$80,3,%11111
				dc.b	'ADDX    '

*-----------------------

ZWOELF: 		dc.w	8
				dc.b	$C0,$80,$30,$40,$23,$F8,4,%11111
				dc.b	'AND.L   '
				dc.b	$C0,$40,$30,$80,$13,$F8,4,%11111
				dc.b	'AND.W   '
				dc.b	$C0,$00,$30,$C0,$03,$F8,4,%11111
				dc.b	'AND.B   '
				dc.b	$C0,$40,$30,$80,$13,$F8,4,%11111
				dc.b	'AND     '

				dc.b	$C1,$C0,$30,$00,$1B,$FF,12,%11111
				dc.b	'MULS    '
				dc.b	$C0,$C0,$31,$00,$1B,$FF,12,%11111
				dc.b	'MULU    '

				dc.b	$C1,$00,$30,$30,$2C,$00,16,%11111
				dc.b	'EXG     '
				dc.b	$C1,$00,$30,$30,$2C,$00,16,%11111
				dc.b	'EXG.L   '
				dc.b	$C1,$00,$30,$F0,$08,$80,3,%11111
				dc.b	'ABCD    '

*-----------------------

ELF:			dc.w	14
				dc.b	$B0,$80,$41,$40,$68,$00,4,%11111
				dc.b	'CMP.L   '
				dc.b	$B0,$40,$41,$80,$58,$00,4,%11111
				dc.b	'CMP.W   '
				dc.b	$B0,$00,$41,$C0,$08,$00,4,%11111
				dc.b	'CMP.B   '
				dc.b	$B0,$40,$41,$80,$58,$00,4,%11111
				dc.b	'CMP     '

				dc.b	$B1,$C0,$40,$00,$2F,$FF,5,%11111
				dc.b	'CMPA.L  '
				dc.b	$B0,$C0,$41,$00,$1F,$FF,5,%11111
				dc.b	'CMPA.W  '
				dc.b	$B1,$C0,$40,$00,$2F,$FF,5,%11111
				dc.b	'CMPA    '

				dc.b	$B1,$80,$40,$40,$2B,$F8,4,%11111
				dc.b	'EOR.L   '
				dc.b	$B1,$40,$40,$80,$1B,$F8,4,%11111
				dc.b	'EOR.W   '
				dc.b	$B1,$00,$40,$C0,$0B,$F8,4,%11111
				dc.b	'EOR.B   '
				dc.b	$B1,$40,$40,$80,$1B,$F8,4,%11111
				dc.b	'EOR     '

				dc.b	$B1,$88,$40,$70,$21,$00,15,%11111
				dc.b	'CMPM.L  '
				dc.b	$B1,$48,$40,$B0,$11,$00,15,%11111
				dc.b	'CMPM.W  '
				dc.b	$B1,$08,$40,$F0,$01,$00,15,%11111
				dc.b	'CMPM.B  '
				dc.b	$B1,$48,$40,$B0,$11,$00,15,%11111
				dc.b	'CMPM    '

*-----------------------

ZEHN:			dc.w	0
				dc.b	$A0,$00,$00,$00,$00,$01,1,%11111
				dc.b	'LINEA   '

*-----------------------

NEUN:			dc.w	10
				dc.b	$90,$80,$60,$40,$63,$F8,4,%11111
				dc.b	'SUB.L   '
				dc.b	$90,$40,$60,$80,$53,$F8,4,%11111
				dc.b	'SUB.W   '
				dc.b	$90,$00,$60,$C0,$03,$F8,4,%11111
				dc.b	'SUB.B   '
				dc.b	$90,$40,$60,$80,$53,$F8,4,%11111
				dc.b	'SUB     '

				dc.b	$91,$C0,$60,$00,$2F,$FF,5,%11111
				dc.b	'SUBA.L  '
				dc.b	$90,$C0,$61,$00,$1F,$FF,5,%11111
				dc.b	'SUBA.W  '
				dc.b	$91,$C0,$60,$00,$2F,$FF,5,%11111
				dc.b	'SUBA    '

				dc.b	$91,$80,$60,$70,$28,$80,3,%11111
				dc.b	'SUBX.L  '
				dc.b	$91,$40,$60,$B0,$18,$80,3,%11111
				dc.b	'SUBX.W  '
				dc.b	$91,$00,$60,$F0,$08,$80,3,%11111
				dc.b	'SUBX.B  '
				dc.b	$91,$40,$60,$B0,$18,$80,3,%11111
				dc.b	'SUBX    '

*-----------------------

ACHT:			dc.w	10
				dc.b	$80,$80,$70,$40,$23,$F8,4,%11111
				dc.b	'OR.L    '
				dc.b	$80,$40,$70,$80,$13,$F8,4,%11111
				dc.b	'OR.W    '
				dc.b	$80,$00,$70,$C0,$03,$F8,4,%11111
				dc.b	'OR.B    '
				dc.b	$80,$40,$70,$80,$13,$F8,4,%11111
				dc.b	'OR      '

				dc.b	$81,$C0,$70,$00,$1B,$FF,12,%11111
				dc.b	'DIVS.W  '
				dc.b	$81,$C0,$70,$00,$1B,$FF,12,%11111
				dc.b	'DIVS    '
				dc.b	$80,$C0,$71,$00,$1B,$FF,12,%11111
				dc.b	'DIVU.W  '
				dc.b	$80,$C0,$71,$00,$1B,$FF,12,%11111
				dc.b	'DIVU    '
				dc.b	$81,$00,$70,$F0,$08,$80,3,%11111
				dc.b	'SBCD    '

				dc.b	$81,$40,$70,$B0,$18,$80,37,%11100
				dc.b	'PACK    '
				dc.b	$81,$80,$70,$70,$18,$80,37,%11100
				dc.b	'UNPK    '

*-----------------------

SIEBEN: 		dc.w	1
				dc.b	$70,$00,$81,$00,$28,$00,24,%11111
				dc.b	'MOVEQ   '
				dc.b	$70,$00,$81,$00,$28,$00,24,%11111
				dc.b	'MOVEQ.L '

*-----------------------

SECHS:			dc.w	0
				dc.b	$60,$00,$90,$00,$F0,$18,9,%11111
				dc.b	'B       '

*-----------------------

FUENF:			dc.w	12
				dc.b	$50,$C8,$A0,$30,$F0,$00,8,%11111
				dc.b	'DB      '
				dc.b	$50,$C0,$A0,$00,$FB,$F8,10,%11111
				dc.b	'S       '

				dc.b	$50,$80,$A1,$40,$2F,$F8,7,%11111
				dc.b	'ADDQ.L  '
				dc.b	$50,$40,$A1,$80,$1F,$F8,7,%11111
				dc.b	'ADDQ.W  '
				dc.b	$50,$00,$A1,$C0,$0B,$F8,7,%11111
				dc.b	'ADDQ.B  '
				dc.b	$50,$40,$A1,$80,$1F,$F8,7,%11111
				dc.b	'ADDQ    '

				dc.b	$51,$80,$A0,$40,$2F,$F8,7,%11111
				dc.b	'SUBQ.L  '
				dc.b	$51,$40,$A0,$80,$1F,$F8,7,%11111
				dc.b	'SUBQ.W  '
				dc.b	$51,$00,$A0,$C0,$0B,$F8,7,%11111
				dc.b	'SUBQ.B  '
				dc.b	$51,$40,$A0,$80,$1F,$F8,7,%11111
				dc.b	'SUBQ    '

				dc.b	$50,$FA,$A0,$05,$F0,$10,38,%11100 ; cc.W
				dc.b	'TRAP    '
				dc.b	$50,$FB,$A0,$04,$F0,$20,38,%11100 ; cc.L
				dc.b	'TRAP    '
				dc.b	$50,$FC,$A0,$03,$F0,$00,38,%11100 ; cc
				dc.b	'TRAP    '

*-----------------------

VIER:			dc.w	79
				dc.b	$42,$80,$BD,$40,$2B,$F8,2,%11111
				dc.b	'CLR.L   '
				dc.b	$42,$40,$BD,$80,$1B,$F8,2,%11111
				dc.b	'CLR.W   '
				dc.b	$42,$00,$BD,$C0,$0B,$F8,2,%11111
				dc.b	'CLR.B   '
				dc.b	$42,$40,$BD,$80,$1B,$F8,2,%11111
				dc.b	'CLR     '

				dc.b	$4A,$80,$B5,$40,$2B,$F8,2,%11
				dc.b	'TST.L   '
				dc.b	$4A,$40,$B5,$80,$1B,$F8,2,%11
				dc.b	'TST.W   '
				dc.b	$4A,$00,$B5,$C0,$0B,$F8,2,%11
				dc.b	'TST.B   '
				dc.b	$4A,$40,$B5,$80,$1B,$F8,2,%11
				dc.b	'TST     '
				dc.b	$4A,$80,$B5,$40,$2F,$FF,2,%11100
				dc.b	'TST.L   '
				dc.b	$4A,$40,$B5,$80,$1F,$FF,2,%11100
				dc.b	'TST.W   '
				dc.b	$4A,$00,$B5,$C0,$0B,$FF,2,%11100
				dc.b	'TST.B   '
				dc.b	$4A,$40,$B5,$80,$1F,$FF,2,%11100
				dc.b	'TST     '

				dc.b	$41,$C0,$B0,$00,$12,$7E,5,%11111
				dc.b	'LEA     '

				dc.b	$48,$40,$B7,$80,$02,$7E,2,%11111
				dc.b	'PEA     '

				dc.b	$4E,$C0,$B1,$00,$02,$7E,2,%11111
				dc.b	'JMP     '
				dc.b	$4E,$80,$B1,$40,$02,$7E,2,%11111
				dc.b	'JSR     '

				dc.b	$4E,$71,$B1,$8E,$00,$00,0,%11111
				dc.b	'NOP     '

				dc.b	$48,$C0,$B7,$00,$22,$F8,22,%11111
				dc.b	'MOVEM.L '
				dc.b	$4C,$C0,$B3,$00,$23,$7E,22,%11111
				dc.b	'MOVEM.L '
				dc.b	$48,$80,$B7,$40,$12,$F8,22,%11111
				dc.b	'MOVEM.W '
				dc.b	$4C,$80,$B3,$40,$13,$7E,22,%11111
				dc.b	'MOVEM.W '
				dc.b	$48,$C0,$B7,$00,$22,$F8,22,%11111
				dc.b	'MOVEM   '
				dc.b	$4C,$C0,$B3,$00,$23,$7E,22,%11111
				dc.b	'MOVEM   '

				dc.b	$48,$C0,$B7,$38,$28,$00,2,%11111
				dc.b	'EXT.L   '
				dc.b	$48,$80,$B7,$78,$18,$00,2,%11111
				dc.b	'EXT.W   '
				dc.b	$48,$80,$B7,$78,$18,$00,2,%11111
				dc.b	'EXT     '
				dc.b	$49,$C0,$B6,$38,$08,$00,2,%11100
				dc.b	'EXTB.L  '
				dc.b	$49,$C0,$B6,$38,$08,$00,2,%11100
				dc.b	'EXTB    '

				dc.b	$4E,$40,$B1,$B0,$00,$00,17,%11111
				dc.b	'TRAP    '
				dc.b	$48,$40,$B7,$B8,$08,$00,2,%11111
				dc.b	'SWAP    '

				dc.b	$46,$80,$B9,$40,$2B,$F8,2,%11111
				dc.b	'NOT.L   '
				dc.b	$46,$40,$B9,$80,$1B,$F8,2,%11111
				dc.b	'NOT.W   '
				dc.b	$46,$00,$B9,$C0,$0B,$F8,2,%11111
				dc.b	'NOT.B   '
				dc.b	$46,$40,$B9,$80,$1B,$F8,2,%11111
				dc.b	'NOT     '

				dc.b	$44,$80,$BB,$40,$2B,$F8,2,%11111
				dc.b	'NEG.L   '
				dc.b	$44,$40,$BB,$80,$1B,$F8,2,%11111
				dc.b	'NEG.W   '
				dc.b	$44,$00,$BB,$C0,$0B,$F8,2,%11111
				dc.b	'NEG.B   '
				dc.b	$44,$40,$BB,$80,$1B,$F8,2,%11111
				dc.b	'NEG     '

				dc.b	$4E,$77,$B1,$88,$00,$00,0,%11111
				dc.b	'RTR     '
				dc.b	$4E,$75,$B1,$8A,$00,$00,0,%11111
				dc.b	'RTS     '
				dc.b	$4E,$74,$B1,$8B,$10,$01,20,%11110
				dc.b	'RTD     '
				dc.b	$4E,$73,$B1,$8C,$00,$00,0,%11111
				dc.b	'RTE     '

				dc.b	$4E,$58,$B1,$A0,$04,$00,18,%11111
				dc.b	'UNLK    '

				dc.b	$4E,$50,$B1,$A8,$14,$00,19,%11111
				dc.b	'LINK.W  '
				dc.b	$4E,$50,$B1,$A8,$14,$00,19,%11111
				dc.b	'LINK    '
				dc.b	$48,$08,$B7,$F0,$24,$00,19,%11100
				dc.b	'LINK.L  '
				dc.b	$48,$08,$B7,$F0,$24,$00,19,%11100
				dc.b	'LINK    '

				dc.b	$4E,$60,$B1,$90,$24,$00,25,%11111 ; USP
				dc.b	'MOVE    '
				dc.b	$4E,$60,$B1,$90,$24,$00,25,%11111 ; USP
				dc.b	'MOVE.L  '

				dc.b	$46,$C0,$B9,$00,$1B,$FF,26,%11111 ; ,SR
				dc.b	'MOVE    '
				dc.b	$46,$C0,$B9,$00,$1B,$FF,26,%11111 ; ,SR
				dc.b	'MOVE.W  '
				dc.b	$44,$C0,$BB,$00,$0B,$FF,26,%11111 ; ,CCR
				dc.b	'MOVE    '
				dc.b	$44,$C0,$BB,$00,$0B,$FF,26,%11111 ; ,CCR
				dc.b	'MOVE.W  '
				dc.b	$40,$C0,$BF,$00,$1B,$F8,26,%11111 ; SR,
				dc.b	'MOVE    '
				dc.b	$40,$C0,$BF,$00,$1B,$F8,26,%11111 ; SR,
				dc.b	'MOVE.W  '
				dc.b	$42,$C0,$BD,$00,$0B,$F8,26,%11110 ; CCR,
				dc.b	'MOVE    '
				dc.b	$42,$C0,$BD,$00,$0B,$F8,26,%11110 ; CCR,
				dc.b	'MOVE.W  '

				dc.b	$48,$00,$B7,$C0,$0B,$F8,2,%11111
				dc.b	'NBCD    '

				dc.b	$40,$80,$BF,$40,$2B,$F8,2,%11111
				dc.b	'NEGX.L  '
				dc.b	$40,$40,$BF,$80,$1B,$F8,2,%11111
				dc.b	'NEGX.W  '
				dc.b	$40,$00,$BF,$C0,$0B,$F8,2,%11111
				dc.b	'NEGX.B  '
				dc.b	$40,$40,$BF,$80,$1B,$F8,2,%11111
				dc.b	'NEGX    '

				dc.b	$4A,$C0,$B5,$00,$0B,$F8,2,%11111
				dc.b	'TAS     '
				dc.b	$4E,$76,$B1,$89,$00,$00,0,%11111
				dc.b	'TRAPV   '

				dc.b	$41,$00,$B0,$C0,$2B,$FF,12,%11100
				dc.b	'CHK.L   '
				dc.b	$41,$80,$B0,$40,$1B,$FF,12,%11111
				dc.b	'CHK.W   '
				dc.b	$41,$80,$B0,$40,$1B,$FF,12,%11111
				dc.b	'CHK     '

				dc.b	$4C,$00,$B3,$C0,$6B,$FF,34,%11100
				dc.b	'MULU.L  '
				dc.b	$4C,$00,$B3,$C0,$2B,$FF,34,%11100
				dc.b	'MULS.L  '

				dc.b	$4C,$40,$B3,$80,$2B,$FF,34,%11100
				dc.b	'DIVS.L  '
				dc.b	$4C,$40,$B3,$80,$AB,$FF,34,%11100
				dc.b	'DIVSL.L '
				dc.b	$4C,$40,$B3,$80,$6B,$FF,34,%11100
				dc.b	'DIVU.L  '
				dc.b	$4C,$40,$B3,$80,$EB,$FF,34,%11100
				dc.b	'DIVUL.L '
				dc.b	$4C,$40,$B3,$80,$AB,$FF,34,%11100
				dc.b	'DIVSL   '
				dc.b	$4C,$40,$B3,$80,$EB,$FF,34,%11100
				dc.b	'DIVUL   '

				dc.b	$4E,$72,$B1,$8D,$10,$01,20,%11111
				dc.b	'STOP    '
				dc.b	$4E,$70,$B1,$8F,$00,$00,0,%11111
				dc.b	'RESET   '
				dc.b	$4A,$FC,$B5,$03,$00,$00,0,%11111
				dc.b	'ILLEGAL '

				dc.b	$48,$48,$B7,$B0,$00,$00,28,%11110
				dc.b	'BKPT    '

				dc.b	$4E,$7A,$B1,$84,$20,$01,35,%11110
				dc.b	'MOVEC   '

*-----------------------

DREI:			dc.w	3
				dc.b	$30,$00,$C0,$00,$1B,$F8,27,%11111
				dc.b	'MOVE.W  '
				dc.b	$30,$00,$C0,$00,$1B,$F8,27,%11111
				dc.b	'MOVE    '
				dc.b	$30,$40,$C1,$80,$14,$00,21,%11111
				dc.b	'MOVEA.W '
				dc.b	$30,$40,$C1,$80,$14,$00,21,%11111
				dc.b	'MOVEA   '

*-----------------------

ZWEI:			dc.w	1
				dc.b	$20,$00,$D0,$00,$2B,$F8,27,%11111
				dc.b	'MOVE.L  '
				dc.b	$20,$40,$D1,$80,$24,$00,21,%11111
				dc.b	'MOVEA.L '

*-----------------------

EINS:			dc.w	0
				dc.b	$10,$00,$E0,$00,$0B,$F8,27,%11111
				dc.b	'MOVE.B  '

*-----------------------

NULL:			dc.w	65
				dc.b	$0C,$80,$F3,$40,$2B,$F8,6,%11
				dc.b	'CMPI.L  '
				dc.b	$0C,$40,$F3,$80,$1B,$F8,6,%11
				dc.b	'CMPI.W  '
				dc.b	$0C,$00,$F3,$C0,$0B,$F8,6,%11
				dc.b	'CMPI.B  '
				dc.b	$0C,$40,$F3,$80,$1B,$F8,6,%11
				dc.b	'CMPI    '
				dc.b	$0C,$80,$F3,$40,$2B,$FE,6,%11100
				dc.b	'CMPI.L  '
				dc.b	$0C,$40,$F3,$80,$1B,$FE,6,%11100
				dc.b	'CMPI.W  '
				dc.b	$0C,$00,$F3,$C0,$0B,$FE,6,%11100
				dc.b	'CMPI.B  '
				dc.b	$0C,$40,$F3,$80,$1B,$FE,6,%11100
				dc.b	'CMPI    '

				dc.b	$06,$80,$F9,$40,$2B,$F8,6,%11111
				dc.b	'ADDI.L  '
				dc.b	$06,$40,$F9,$80,$1B,$F8,6,%11111
				dc.b	'ADDI.W  '
				dc.b	$06,$00,$F9,$C0,$0B,$F8,6,%11111
				dc.b	'ADDI.B  '
				dc.b	$06,$40,$F9,$80,$1B,$F8,6,%11111
				dc.b	'ADDI    '

				dc.b	$04,$80,$FB,$40,$2B,$F8,6,%11111
				dc.b	'SUBI.L  '
				dc.b	$04,$40,$FB,$80,$1B,$F8,6,%11111
				dc.b	'SUBI.W  '
				dc.b	$04,$00,$FB,$C0,$0B,$F8,6,%11111
				dc.b	'SUBI.B  '
				dc.b	$04,$40,$FB,$80,$1B,$F8,6,%11111
				dc.b	'SUBI    '

				dc.b	$02,$3C,$FD,$83,$10,$01,14,%11111 ; CCR, SR
				dc.b	'ANDI    '
				dc.b	$02,$3C,$FD,$83,$10,$01,14,%11111 ; CCR, SR
				dc.b	'ANDI.W  '
				dc.b	$02,$3C,$FD,$83,$10,$01,14,%11111 ; CCR, SR
				dc.b	'ANDI.B  '

				dc.b	$02,$80,$FD,$40,$2B,$F8,6,%11111
				dc.b	'ANDI.L  '
				dc.b	$02,$40,$FD,$80,$1B,$F8,6,%11111
				dc.b	'ANDI.W  '
				dc.b	$02,$00,$FD,$C0,$0B,$F8,6,%11111
				dc.b	'ANDI.B  '
				dc.b	$02,$40,$FD,$80,$1B,$F8,6,%11111
				dc.b	'ANDI    '

				dc.b	$00,$3C,$FF,$83,$10,$01,14,%11111 ; CCR, SR
				dc.b	'ORI     '
				dc.b	$00,$3C,$FF,$83,$10,$01,14,%11111 ; CCR, SR
				dc.b	'ORI.W   '
				dc.b	$00,$80,$FF,$40,$2B,$F8,6,%11111
				dc.b	'ORI.L   '
				dc.b	$00,$40,$FF,$80,$1B,$F8,6,%11111
				dc.b	'ORI.W   '
				dc.b	$00,$00,$FF,$C0,$0B,$F8,6,%11111
				dc.b	'ORI.B   '
				dc.b	$00,$40,$FF,$80,$1B,$F8,6,%11111
				dc.b	'ORI     '

				dc.b	$0A,$3C,$F5,$83,$10,$01,14,%11111 ; CCR, SR
				dc.b	'EORI    '
				dc.b	$0A,$80,$F5,$40,$2B,$F8,6,%11111
				dc.b	'EORI.L  '
				dc.b	$0A,$40,$F5,$80,$1B,$F8,6,%11111
				dc.b	'EORI.W  '
				dc.b	$0A,$00,$F5,$C0,$0B,$F8,6,%11111
				dc.b	'EORI.B  '

				dc.b	$0A,$40,$F5,$80,$1B,$F8,6,%11111
				dc.b	'EORI    '

				dc.b	$01,$C0,$F0,$00,$8B,$F8,4,%11111 ; Dn
				dc.b	'BSET    '
				dc.b	$01,$80,$F0,$40,$8B,$F8,4,%11111
				dc.b	'BCLR    '
				dc.b	$01,$40,$F0,$80,$8B,$F8,4,%11111
				dc.b	'BCHG    '
				dc.b	$01,$00,$F0,$C0,$8B,$FF,4,%11111
				dc.b	'BTST    '

				dc.b	$08,$C0,$F7,$00,$0B,$F8,11,%11111 ; #Im
				dc.b	'BSET    '
				dc.b	$08,$80,$F7,$40,$0B,$F8,11,%11111
				dc.b	'BCLR    '
				dc.b	$08,$40,$F7,$80,$0B,$F8,11,%11111
				dc.b	'BCHG    '
				dc.b	$08,$00,$F7,$C0,$0B,$FE,11,%11111
				dc.b	'BTST    '

				dc.b	$01,$48,$F0,$30,$28,$40,23,%11111
				dc.b	'MOVEP.L '
				dc.b	$01,$08,$F0,$70,$18,$40,23,%11111
				dc.b	'MOVEP.W '
				dc.b	$01,$08,$F0,$70,$18,$40,23,%11111
				dc.b	'MOVEP   '

				dc.b	$0E,$C0,$F1,$00,$23,$F8,31,%11100
				dc.b	'CAS.L   '
				dc.b	$0C,$C0,$F3,$00,$13,$F8,31,%11100
				dc.b	'CAS.W   '
				dc.b	$0A,$C0,$F5,$00,$03,$F8,31,%11100
				dc.b	'CAS.B   '
				dc.b	$0C,$C0,$F3,$00,$13,$F8,31,%11100
				dc.b	'CAS     '

				dc.b	$0E,$FC,$F1,$03,$20,$00,32,%11100
				dc.b	'CAS2.L  '
				dc.b	$0C,$FC,$F3,$03,$10,$00,32,%11100
				dc.b	'CAS2.W  '
				dc.b	$0C,$FC,$F3,$03,$10,$00,32,%11100
				dc.b	'CAS2    '

				dc.b	$04,$C0,$FB,$00,$A2,$7E,33,%11100
				dc.b	'CHK2.L  '
				dc.b	$02,$C0,$FD,$00,$92,$7E,33,%11100
				dc.b	'CHK2.W  '
				dc.b	$00,$C0,$FF,$00,$82,$7E,33,%11100
				dc.b	'CHK2.B  '
				dc.b	$02,$C0,$FD,$00,$92,$7E,33,%11100
				dc.b	'CHK2    '

				dc.b	$04,$C0,$FB,$00,$22,$7E,33,%11100
				dc.b	'CMP2.L  '
				dc.b	$02,$C0,$FD,$00,$12,$7E,33,%11100
				dc.b	'CMP2.W  '
				dc.b	$00,$C0,$FF,$00,$02,$7E,33,%11100
				dc.b	'CMP2.B  '
				dc.b	$02,$C0,$FD,$00,$12,$7E,33,%11100
				dc.b	'CMP2    '

				dc.b	$0E,$80,$F1,$40,$23,$F8,36,%11110
				dc.b	'MOVES.L '
				dc.b	$0E,$40,$F1,$80,$13,$F8,36,%11110
				dc.b	'MOVES.W '
				dc.b	$0E,$00,$F1,$C0,$03,$F8,36,%11110
				dc.b	'MOVES.B '
				dc.b	$0E,$40,$F1,$80,$13,$F8,36,%11110
				dc.b	'MOVES   '

				dc.b	$06,$C0,$F9,$00,$02,$7E,30,%100
				dc.b	'CALLM   '
				dc.b	$06,$C0,$F9,$30,$0C,$00,2,%100
				dc.b	'RTM     '
