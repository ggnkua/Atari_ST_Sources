	dc.w	%1111111110111000,%1111010110001000
	dc.b	'PLPA    '
	dc.l	plpa
	dc.l	$ffffffff



	dc.w	%1111111111111111,%1111100000000000
	dc.b	'LPSTOP  '
	dc.l	lpstop
	dc.l	$ffffffff
	
	
	dc.w	%1111111111000000,%1111001000000000
	dc.b	'        '
	dc.l	fpu_norm
	dc.l	$ffffffff
	
	dc.w	%1111111110000000,%1111001010000000	; fnop aussi
	dc.b	'        '
	dc.l	fbcc
	dc.l	$ffffffff
	
	dc.w	%1111111111000000,%1111001001000000
	dc.b	'        '
	dc.l	ftrap_scc
	dc.l	$ffffffff

	dc.w	%1111111111111000,%1111011000100000
	dc.b	'MOVE16  '
	dc.l	MOVE16AN
	dc.l	$ffffffff
	
	
	dc.w	%1111111111100000,%1111011000000000
	dc.b	'MOVE16  '
	dc.l	MOVE16ABS
	dc.l	$ffffffff
	
	dc.w	%1111111111011000,%1111010101001000
	dc.b	'PTEST   '
	dc.l	PTEST
	dc.l	%00100111100000
	
	dc.w	%1111111111100000,%1111010100000000
	dc.b	'PFLUSH  '
	dc.l	PFLUSH
	dc.l	%00100111100000
	
	dc.w	%1111111100100000,%1111010000000000
	dc.b	'CINV    '
	dc.l	CINV
	dc.l	$ffffffff
	
	dC.w	%1111111100100000,%1111010000100000
	dc.b	'CPUSH   '
	dc.l	CINV
	dc.l	$ffffffff
	
	dc.w	%1111000111110000,%1100000100000000
	dc.b	'ABCD    '
	dc.l	bcd_reg
	dc.l	$ffffffff
	
	dc.w	%1111111100000000,%0000011000000000
	dc.b	'ADDI    '
	dc.l	immediat
	dc.l	%11111111100000
	
	dc.w	%1111000011111000,%0101000011001000
	dc.b	'DB      '
	dc.l	dbcc
	dc.l	$ffffffff
	
	dc.w	%1111000011111111,%0101000011111010		; 3 possibilites
	dc.b	'TRAP    '	;avec cc
	dc.l	trapcc
	dc.l	$ffffffff
	
	dc.w	%1111000011111111,%0101000011111011
	dc.b	'TRAP    '	;avec cc
	dc.l	trapcc
	dc.l	$ffffffff
	
	dc.w	%1111000011111111,%0101000011111100
	dc.b	'TRAP    '	;avec cc
	dc.l	trapcc
	dc.l	$ffffffff
	
	dc.w	%1111000011000000,%0101000011000000
	dc.b	'S       '
	dc.l	scc
	dc.l	%10111111100000
	
	dc.w	%1111000100000000,%0101000000000000
	dc.b	'ADDQ    '
	dc.l	quick
	dc.l	%11111111100000
	
	dc.w	%1111000011000000,%1101000011000000	; adda
	dc.b	'ADD     '
	dc.l	reg_adr
	dc.l	%11111111110011
	
	dc.w	%1111000100110000,%1101000100000000
	dc.b	'ADDX    '
	dc.l	bcd_reg
	dc.l	$ffffffff
	
	dc.w	%1111000100000000,%1101000000000000	; add	ea,dn
	dc.b	'ADD     '
	dc.l	reg_adr
	dc.l	%11111111110011
	
	dc.w	%1111000100000000,%1101000100000000	; add	dn,ea
	dc.b	'ADD     '
	dc.l	reg_adr
	dc.l	%00111111100000
	
	dc.w	%1111000111000000,%1100000111000000
	dc.b	'MULS.W  '	;en 16 bits 
	dc.l	mulu_w
	dc.l	%10111111110011
	
	dc.w	%1111000100110000,%1100000100000000
	dc.b	'EXG     '
	dc.l	exg
	dc.l	$ffffffff
	
	dc.w	%1111000111000000,%1100000011000000
	dc.b	'MULU.W  '	;en 16
	dc.l	mulu_w
	dc.l	%10111111110011
	
	dc.w	%1111000100000000,%1100000000000000	; ea => dn
	dc.b	'AND     '
	dc.l	reg_adr
	dc.l	%10111111110011
	
	dc.w	%1111000100000000,%1100000100000000	; dn => ea
	dc.b	'AND     '	
	dc.l	reg_adr
	dc.l	%00111111100000
	
	dc.w	%1111100111000000,%0000000011000000	;soit chk2 soit cmp2
	dc.b	'        '
	dc.l	cmp2_chk2
	dc.l	$ffffffff
	
	dc.w	%1111111111111111,%0000001000111100
	dc.b	'ANDI    '	; vers ccr
	dc.l	vers_ccr
	dc.l	$ffffffff
	
	dc.w	%1111111111111111,%0000001001111100
	dc.b	'ANDI    '	; vers sr
	dc.l	vers_sr
	dc.l	$ffffffff
	
	dc.w	%1111111100000000,%0000001000000000
	dc.b	'ANDI    '
	dc.l	immediat
	dc.l	%10111111100000
	
	dc.w	%1111111111000000,%1110100011000000
	dc.b	'BFTST   '
	dc.l	bfchg
	dc.l	%10100111100011
	

	dc.w	%1111111111000000,%1110000011000000
	dc.b	'ASR     '	;memoire
	dc.l	as_ae
	dc.l	%00111111100000
	
	dc.w	%1111111111000000,%1110100111000000
	dc.b	'BFEXTU  '
	dc.l	bfchg_dn
	dc.l	%10100111100011
	
	dc.w	%1111111111000000,%1110101011000000
	dc.b	'BFCHG   '
	dc.l	bfchg
	dc.l	%10100111100000
	
	dc.w	%1111111111000000,%1110110011000000
	dc.b	'BFCLR   '
	dc.l	bfchg
	dc.l	%10100111100000
	
	dc.w	%1111111111000000,%1110111011000000
	dc.b	'BFSET   '
	dc.l	bfchg
	dc.l	%10100111100000
	
	dc.w	%1111000100011000,%1110000000000000
	dc.b	'ASR     '	;registre
	dc.l	as_dn
	dc.l	$ffffffff
	
	dc.w	%1111111111000000,%1110101111000000
	dc.b	'BFEXTS  '
	dc.l	bfchg_dn
	dc.l	%10100111100011
	
	dc.w	%1111111111000000,%1110110111000000
	dc.b	'BFFFO   '
	dc.l	bfchg_dn
	dc.l	%10100111100011

	dc.w	%1110111111000000,%1110111111000000
	dc.b	'BFINS   '
	dc.l	dn_bfchg
	dc.l	%10100111100000
	
	
	dc.w	%1111000100011000,%1110000100000000
	dc.b	'ASL     '	;registre
	dc.l	as_dn
	dc.l	$ffffffff
	
	dc.w	%1111111111000000,%1110000111000000
	dc.b	'ASL     '	;memoire
	dc.l	as_ae
	dc.l	%00111111100000
	
	dc.w	%1111000000000000,%0110000000000000
	dc.b	'B       '
	dc.l	bcc
	dc.l	$ffffffff
	
	dc.w	%1111000100111000,%0000000100001000
	dc.b    'MOVEP   '
	dc.l	movep
	dc.l	$ffffffff
	
	dc.w	%1111000111000000,%0000000101000000
	dc.b	'BCHG    '	;cas bchg dn,ae
	dc.l	btst_dn
	dc.l	%10111111100000
	
	dc.w	%1111111111000000,%0000100001000000
	dc.b	'BCHG    '	;cas bchg #sss,ae
	dc.l	btst_imm
	dc.l	%10111111100000
	
	dc.w	%1111000111000000,%0000000110000000
	dc.b	'BCLR    '	;cas bclr dn,ae
	dc.l	btst_dn
	dc.l	%10111111100000
	
	dc.w	%1111111111000000,%0000100010000000
	dc.b	'BCLR    '	;cas bclr #sss,ae
	dc.l	btst_imm
	dc.l	%10111111100000
	
	dc.w	%1111111111111000,%0100100001001000
	dc.b	'BKPT    '
	dc.l	bkpt
	dc.l	$ffffffff
	
	dc.w	%1111000111000000,%0000000111000000
	dc.b	'BSET    '	;cas bset dn,ae
	dc.l	btst_dn
	dc.l	%10111111100000
	
	dc.w	%1111111111000000,%0000100011000000
	dc.b	'BSET    '	;cas bset #sss,ae
	dc.l	btst_imm
	dc.l	%10111111100000
	
	dc.w	%1111000111000000,%0000000100000000
	dc.b	'BTST    '	;cas du btst dn,ae
	dc.l	btst_dn
	dc.l	%10111111110011
	
	dc.w	%1111111111000000,%0000100000000000
	dc.b	'BTST    '	;cas du btst #sss,ae
	dc.l	btst_imm
	dc.l	%10111111100011
	
	dc.w	%1111100111111111,%0000100011111100
	dc.b	'CAS2    '
	dc.l	cas2
	dc.l	%00111111100000
	
	dc.w	%1111100111000000,%0000100011000000
	dc.b	'CAS     '
	dc.l	cas
	dc.l	%00111111100000
	
	dc.w	%1111111111111000,%0100100001000000
	dc.b	'SWAP    '
	dc.l	swap
	dc.l	$ffffffff
	
	dc.w	%1111111111111000,%0100100000001000	; link en long
	dc.b	'LINK    '
	dc.l	link_l
	dc.l	$ffffffff
	
	dc.w	%1111111111000000,%0100100000000000
	dc.b	'NBCD    '
	dc.l	add_s_taille
	dc.l	%10111111100000
	
	dc.w	%1111111000111000,%0100100000000000
	dc.b	'EXT     '      ;attention au extb
	dc.l	ext
	dc.l	$ffffffff
	
	dc.w	%1111111111000000,%0100110000000000
	dc.b	'MUL     '	;en long
	dc.l	muls_l
	dc.l	%10111111110011
	
	dc.w	%1111111111000000,%0100010011000000
	dc.b	'MOVE    '	;vers ccr
	dc.l	move_vers_ccr
	dc.l	%10111111110011
	
	dc.w	%1111111100000000,%0100010000000000
	dc.b	'NEG     '
	dc.l	adr_seule
	dc.l	%10111111100000
	
	dc.w	%1111111110000000,%0100100010000000	; reg to mem
	dc.b	'MOVEM   '
	dc.l	movem
	dc.l	%00101111100000
		
	dc.w	%1111111110000000,%0100110010000000	; mem to reg
	dc.b	'MOVEM   '
	dc.l	movem
	dc.l	%00110111100011
	
	dc.w	%1111111111000000,%0100111010000000
	dc.b	'JSR     '
	dc.l	add_s_taille
	dc.l	%00100111100011
	
	dc.w	%1111000101000000,%0100000100000000
	dc.b	'CHK     '
	dc.l	chk
	dc.l	%10111111110011
	
	dc.w	%1111111111000000,%0100001011000000
	dc.b	'MOVE    '	;de ccr
	dc.l	move_de_ccr
	dc.l	%10111111100000
	
	dc.w	%1111111100000000,%0100001000000000
	dc.b	'CLR     '
	dc.l	adr_seule
	dc.l	%10111111100000
	
	dc.w	%1111000011000000,%1011000011000000	;cmpa
	dc.b	'CMP     '
	dc.l	reg_adr
	dc.l	%11111111110011
	
	dc.w	%1111000100111000,%1011000100001000
	dc.b	'CMPM    '
	dc.l	bcd_reg1
	dc.l	$ffffffff
	
	dc.w	%1111000100000000,%1011000100000000	
	dc.b	'EOR     '
	dc.l	reg_adr
	dc.l	%10111111100000
	
	dc.w	%1111000100000000,%1011000000000000	;cmp
	dc.b	'CMP     '
	dc.l	reg_adr
	dc.l	%11111111110011
	
	dc.w	%1111111100000000,%0000110000000000
	dc.b	'CMPI    '
	dc.l	immediat
	dc.l	%10111111100011
	
	dc.w	%1111111111000000,%1111000000000000	;gerer avec PLOAD,PMOVE,PTEST
	dc.b	'P       '
	dc.l	p_divers
	dc.l	%00100111100000
	
	;dc.w	%1111111111111111,%1111000000000000     ; avirer sans doute ces 3 lignes
	;dc.b	'LINEF   '
	;dc.l	line_f
	;dc.w	%1111000110000000,%1111000010000000
	;dc.b	'cpBcc   '	;branchement sur condition copro
	;dc.l	line_f
	;dc.w	%1111000111111000,%1111000001001000
	;dc.b	'cpDBcc  '
	;dc.l	line_f
	;dc.w	%1111000111000000,%1111000000000000
	;dc.b	'cpGEN   '
	;dc.l	line_f
	
	dc.w	%1111111111000000,%1111001101000000
	dc.b	'FRSTORE '
	dc.l	fadr
	dc.l	%00110111100011
	
	dc.w	%1111111111000000,%1111001100000000
	dc.b	'FSAVE   '
	dc.l	fadr
	dc.l	%00101111100000
	
	;dc.w	%1111000111000000,%1111000001000000
	;dc.b	'cpScc   '
	;dc.l	line_f
	;dc.w	%1111000111111000,%1111000001111000
	;dc.b	'cpTRAP  '
	;dc.l	line_f
	
	dc.w	%1111000111000000,%1000000111000000
	dc.b	'DIVS.W  '
	dc.l	mulu_w
	dc.l	%10111111110011
	
	dc.w	%1111111111000000,%0100110001000000
	dc.b	'DIV     '	;ou divls
	dc.l	muls_l
	dc.l	%10111111110011
	
	dc.w	%1111000111000000,%1000000011000000
	dc.b	'DIVU.W  '
	dc.l	mulu_w
	dc.l	%10111111110011
	
	dc.w	%1111111111000000,%0100110001000000
	dc.b	'DIV     '
	dc.l	muls_l
	dc.l	%10111111110011
	
	dc.w	%1111111111111111,%0000101000111100
	dc.b	'EORI    '	;vers ccr
	dc.l	vers_ccr
	dc.l	$ffffffff
	
	dc.w	%1111111111111111,%0000101001111100
	dc.b	'EORI    '	;vers sr
	dc.l	vers_sr
	dc.l	$ffffffff
	
	dc.w	%1111111100000000,%0000101000000000
	dc.b	'EORI    '
	dc.l	immediat
	dc.l	%10111111100000
	
	dc.w	%1111111111111111,%0100101011111100
	dc.b	'ILLEGAL '
	dc.l	no_param
	dc.l	$ffffffff
	
	dc.w	%1111111111000000,%0100111011000000
	dc.b	'JMP     '
	dc.l	add_s_taille
	dc.l	%00100111100011
	
	dc.w	%1111000111000000,%0100000111000000	; lea sans le a
	dc.b	'LE      '				
	dc.l	reg_adr
	dc.l	%00100111100011
	
	dc.w	%1111111111111000,%0100111001010000	; link en word
	dc.b	'LINK    '
	dc.l	link_w
	dc.l	$ffffffff
	
	dc.w	%1111000100011000,%1110000100001000
	dc.b	'LSL     '	; cas avec registre
	dc.l	as_dn
	dc.l	$ffffffff
	
	dc.w	%1111111111000000,%1110001111000000
	dc.b	'LSL     '	; cas avec memoire
	dc.l	as_ae
	dc.l	%00111111100000
	
	dc.w	%1111000100011000,%1110000000001000
	dc.b	'LSR     '	;cas avec registre
	dc.l	as_dn
	dc.l	$ffffffff
	
	dc.w	%1111111111000000,%1110001011000000
	dc.b	'LSR     '	;cas avec memoire
	dc.l	as_ae
	dc.l	%00111111100000
	
	dc.w	%1111111100000000,%0000010000000000
	dc.b	'SUBI    '
	dc.l	immediat
	dc.l	%10111111100000
	
	dc.w	%1111111111111111,%0000000000111100
	dc.b	'ORI     '	;vers ccr
	dc.l	vers_ccr
	dc.l	$ffffffff
	
	dc.w	%1111111111111111,%0000000001111100
	dc.b	'ORI     '	;vers sr
	dc.l	vers_sr
	dc.l	$ffffffff
	
	dc.w	%1111111100000000,%0000000000000000
	dc.b	'ORI     '
	dc.l	immediat
	dc.l	%10111111100000
	
	dc.w	%1111111100000000,%0000111000000000
	dc.b	'MOVES   '
	dc.l	moves
	dc.l	%00111111100000
	
	dc.w	%1100000000000000,%0000000000000000	; gerer le movea
	dc.b    'MOVE    '
	dc.l	tout_tout
	dc.l	%111111111000000011111111110011
	
	dc.w	%1111111111000000,%0100000011000000
	dc.b	'MOVE    '	;de sr
	dc.l	move_de_sr
	dc.l	%10111111100000
	
	dc.w	%1111111111000000,%0100011011000000
	dc.b	'MOVE    '	;vers sr
	dc.l	move_vers_sr
	dc.l	%10111111110011
	
	dc.w	%1111111111110000,%0100111001100000	;de et vers
	dc.b	'MOVE    '	;de usp
	dc.l	move_usp
	dc.l	$ffffffff
	
	dc.w	%1111111111111110,%0100111001111010
	dc.b	'MOVEC   '
	dc.l	movec
	dc.l	$ffffffff
	
	dc.w	%1111000100000000,%0111000000000000
	dc.b	'MOVEQ   '
	dc.l	moveq
	dc.l	$ffffffff
	
	dc.w	%1111111111000000,%0100110000000000
	dc.b	'MUL     '	;en 32
	dc.l	muls_l
	dc.l	%10111111110011
	
	dc.w	%1111111100000000,%0100000000000000
	dc.b	'NEGX    '
	dc.l	adr_seule
	dc.l	%10111111100000
	
	dc.w	$ffff,$4e71
	dc.b	'NOP     '
	dc.l	no_param
	dc.l	$ffffffff
	
	dc.w	%1111111100000000,%0100011000000000
	dc.b	'NOT     '
	dc.l	adr_seule
	dc.l	%10111111100000
	
	dc.w	%1111000111110000,%1000000100000000
	dc.b	'SBCD    '
	dc.l	bcd_reg
	dc.l	$ffffffff
	
	dc.w	%1111000111110000,%1000000101000000
	dc.b	'PACK    '
	dc.l	pack
	dc.l	$ffffffff
	
	dc.w	%1111000111110000,%1000000110000000
	dc.b	'UNPK    '
	dc.l	pack
	dc.l	$ffffffff
	
	dc.w	%1111000100000000,%1000000000000000	; ea => dn
	dc.b	'OR      '
	dc.l	reg_adr
	dc.l	%10111111110011
	
	dc.w	%1111000100000000,%1000000100000000	; dn => ea
	dc.b	'OR      '
	dc.l	reg_adr
	dc.l	%00111111100000
	
	dc.w	%1111111111000000,%0100100001000000
	dc.b	'PEA     '
	dc.l	add_s_taille
	dc.l	%00100111100011
	
	
	dc.w	%1111111111111111,%0100111001110000
	dc.b	'RESET   '
	dc.l	no_param
	dc.l	$ffffffff
	
	dc.w	%1111111111000000,%1110011111000000
	dc.b	'ROL     '	; avec mem
	dc.l	as_ae
	dc.l	%00111111100000
	
	dc.w	%1111000100011000,%1110000100011000
	dc.b	'ROL     '	; avec reg
	dc.l	as_dn
	dc.l	$ffffffff
	
	
	dc.w	%1111000100011000,%1110000000011000
	dc.b	'ROR     '	; avec reg
	dc.l	as_dn
	dc.l	$ffffffff
	
	dc.w	%1111111111000000,%1110011011000000
	dc.b	'ROR     '	; avec mem
	dc.l	as_ae
	dc.l	%00111111100000
	
	dc.w	%1111000100011000,%1110000100010000
	dc.b	'ROXL    '	; avec reg
	dc.l	as_dn
	dc.l	$ffffffff
	
	dc.w	%1111111111000000,%1110010111000000
	dc.b	'ROXL    '	; avec mem
	dc.l	as_ae
	dc.l	%00111111100000
	
	dc.w	%1111000100011000,%1110000000010000
	dc.b	'ROXR    '	; avec reg
	dc.l	as_dn
	dc.l	$ffffffff
	
	dc.w	%1111111111000000,%1110010011000000
	dc.b	'ROXR    '	; avec mem
	dc.l	as_ae
	dc.l	%00111111100000
	
	dc.w	%1111111111111111,%0100111001110100
	dc.b	'RTD     '
	dc.l	rtd
	dc.l	$ffffffff
	
	dc.w	%1111111111111111,%0100111001110011
	dc.b	'RTE     '
	dc.l	no_param
	dc.l	$ffffffff
	
	dc.w	%1111111111111111,%0100111001110111
	dc.b	'RTR     '
	dc.l	no_param
	dc.l	$ffffffff
	
	dc.w	%1111111111111111,$4e75
	dc.b	'RTS     '
	dc.l	no_param
	dc.l	$ffffffff
	
	dc.w	$ffff,%0100111001110010
	dc.b	'STOP    '
	dc.l	rtd
	dc.l	$ffffffff
	
	dc.w	%1111000011000000,%1001000011000000	; suba
	dc.b	'SUB     '
	dc.l	reg_adr
	dc.l	%11111111110011
	
	dc.w	%1111000100110000,%1001000100000000
	dc.b	'SUBX    '
	dc.l	bcd_reg
	dc.l	$ffffffff
	
	dc.w	%1111000100000000,%1001000000000000	; sub	ea,dn
	dc.b	'SUB     '
	dc.l	reg_adr
	dc.l	%11111111110011
	
	dc.w	%1111000100000000,%1001000100000000	; sub	dn,ea
	dc.b	'SUB     '
	dc.l	reg_adr
	dc.l	%00111111100000
	
	dc.w	%1111000100000000,%0101000100000000
	dc.b	'SUBQ    '
	dc.l	quick
	dc.l	%11111111100000
	
	dc.w	%1111111111000000,%0100101011000000
	dc.b	'TAS     '
	dc.l	add_s_taille
	dc.l	%10111111100000
	
	dc.w	%1111111111110000,%0100111001000000
	dc.b	'TRAP    '	
	dc.l	trap
	dc.l	$ffffffff
	
	dc.w	%1111111111111111,%0100111001110110
	dc.b	'TRAPV   '
	dc.l	no_param
	dc.l	$ffffffff
	
	dc.w	%1111111100000000,%0100101000000000
	dc.b	'TST     '
	dc.l	adr_seule
	dc.l	%11111111110011
	
	dc.w	%1111111111111000,%0100111001011000
	dc.b	'UNLK    '
	dc.l	unlk
	dc.l	$ffffffff
	
	dc.w	%0,0
	dc.b	'DC.W    '
	dc.l	dcw
	dc.l	$ffffffff