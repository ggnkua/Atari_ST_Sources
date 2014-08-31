;
; Copyright 1990-2006 Alexandre Lemaresquier, Raphael Lemoine
;                     Laurent Chemla (Serial support), Daniel Verite (AmigaOS support)
;
; This file is part of Adebug.
;
; Adebug is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; Adebug is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with Adebug; if not, write to the Free Software
; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
;

;  #[ REMs & equates:
;
; desassembleur 68000/68008/68010/68012/68030/68881/68882/68040/CPU32
;
;           pour Adebug versions Atari ST, TT et Mac II
;
;
; En entree:	A0 = adresse de la chaine ASCII
;		A1 = adresse de l'instruction a desassembler
;		D0 = type de microprocesseur accepte:
;
;			bit 0 =
;			bit 1 =
;			bit 2 =
;			bit 3 =
;
; En sortie:	D0 = -1 (erreur de lecture) , 0 (desassemblage effectue)
;		A0 = adresse de la chaine ASCII
;		A1 = adresse d'un descripteur sur l'instruction desassemblee
;
;

;  #[ Instruction descriptor:

; Descripteur:
;
Instruction_Info_struct:
_I_type			equ	0	; W = Type d'instruction (68000->68851)
_I_priv			equ	2	; W = Flag User/Super (0/-1)
_I_branchf		equ	4	; W = Instruction de saut (0/-1)
_I_branchyn		equ	6	; W = Saut pris (0/-1)
_I_branchaddr		equ	8	; L = Adresse du saut
_I_coproc		equ	12	; W = Instruction coprocesseur (0/-1)
_I_idnumber		equ	14	; W = Numero d'ID (si coprocesseur)
_I_exc			equ	16	; W = Exception (0/-1)
_I_exc_type		equ	18	; W = Type d'exception (si exception)
_I_size			equ	20	; W = Taille de l'instruction
_I_sourcef		equ	22	; W = Source (0/-1)
_I_sourcesize		equ	24	; W = Taille de source	(B,W,...)
_I_sourceformat		equ	26	; W = Format de source (1/1, 1/2)
_I_sourceaddr		equ	28	; L = Adresse de source
_I_destf		equ	32	; W = Destination (0/-1)
_I_destsize		equ	34	; W = Taille de destination (B,W,...)
_I_destformat		equ	36	; W = Format de destination (1/1, 1/2)
_I_destaddr		equ	38	; L = Adresse de destination
_I_format		equ	42	; W = Taille de l'instruction (B,W,...)
_I_unimplemented	equ	44	; W = Instruction illegale
_I_Comment		equ	46	; L = Adresse du commentaire ou 0
_I_sourceerror		equ	50	; W = Bus error dans source-indirection
_I_desterror		equ	52	; W = Bus error dans dest-indirection
;
;			Reserved (internal <ea> information)
;
_I_sbasedisp		equ	54
_I_sbasereg		equ	58
_I_sindexreg		equ	62
_I_souterdisp		equ	66
_I_spc			equ	70
_I_dbasedisp		equ	74
_I_dbasereg		equ	78
_I_dindexreg		equ	82
_I_douterdisp		equ	86
_I_dpc			equ	90
;
_I_ID_instruction	equ	94	; W = Instruction ID
_I_total_size		equ	96	; descriptor size

;  #] Instruction descriptor:

;
; equates des bits CCR
;
_X			equ	4
_N			equ	3
_Z			equ	2
_V			equ	1
_C			equ	0

;  #[ Instructions ID:

ID_abcd			equ	0	; done
ID_add			equ	1	; done
ID_adda			equ	2	; done
ID_addi			equ	3	; done
ID_addq			equ	4	; done
ID_addx			equ	5	; done
ID_and			equ	6	; done
ID_andi			equ	7	; done
ID_andi_to_ccr		equ	8	; done
ID_andi_to_sr		equ	9	: done
ID_asl			equ	10	; done
ID_asr			equ	11	; done
ID_bcc			equ	12	; done
ID_bchg			equ	13	; done
ID_bclr			equ	14	; done
ID_bfchg		equ	15	; done
ID_bfclr		equ	16	; done
ID_bfexts		equ	17	; done
ID_bfextu		equ	18	; done
ID_bfffo		equ	19	; done
ID_bfins		equ	20	; done
ID_bfset		equ	21	; done
ID_bftst		equ	22	; done
ID_bgnd			equ	23	; done
ID_bkpt			equ	24	; done
ID_bra			equ	25	; done
ID_bset			equ	26	; done
ID_bsr			equ	27	; done
ID_btst			equ	28	; done
;ID_callm		equ	29	;
ID_cas			equ	30	; done
ID_cas2			equ	31	; done
ID_chk			equ	32	; done
ID_chk2			equ	33	; done
;ID_cinv			equ	34	;
ID_clr			equ	35	; done
ID_cmp			equ	36	; done
ID_cmpa			equ	37	; done
ID_cmpi			equ	38	; done
ID_cmpm			equ	39	; done
ID_cmp2			equ	40	; done
;ID_cpush		equ	41	;
ID_dbcc			equ	42	; done
ID_dc_w			equ	43	: done
ID_divs			equ	44	; done
ID_divsl		equ	45	; done
ID_divu			equ	46	; done
ID_divul		equ	47	; done
ID_eor			equ	48	; done
ID_eori			equ	49	; done
ID_eori_to_ccr		equ	50	; done
ID_eori_to_sr		equ	51	; done
ID_exg			equ	52	; done
ID_ext			equ	53	; done
ID_extb			equ	54	; done
;ID_fabs			equ	55	;
;ID_facos		equ	56	;
;ID_fadd			equ	57	;
;ID_fasin		equ	58	;
;ID_tatan		equ	59	;
;ID_fatanh		equ	60	;
;ID_fbcc			equ	61	;
;ID_fcmp			equ	62	;
;ID_fcos			equ	63	;
;ID_fcosh		equ	64	;
;ID_fdbcc		equ	65	;
;ID_fdiv			equ	66	;
;ID_fetox		equ	67	;
;ID_fgetexp		equ	68	;
;ID_fgetman		equ	69	;
;ID_fint			equ	70	;
;ID_fintrz		equ	71	;
;ID_flog10		equ	72	;
;ID_flog2		equ	73	;
;ID_flogn		equ	74	;
;ID_flognp1		equ	75	;
;ID_fmod			equ	76	;
;ID_fmove		equ	77	;
;ID_fmovecr		equ	78	;
;ID_fmovem		equ	79	;
;ID_fmul			equ	80	;
;ID_fneg			equ	81	;
;ID_fnop			equ	82	;
;ID_frem			equ	83	;
;ID_frestore		equ	84	;
;ID_fsave		equ	85	;
;ID_fscale		equ	86	;
;ID_fscc			equ	87	;
;ID_fsgldiv		equ	88	;
;ID_fsglmul		equ	89	;
;ID_fsin			equ	90	;
;ID_fsincos		equ	91	;
;ID_fsinh		equ	92	;
;ID_fsqrt		equ	93	;
;ID_fsub			equ	94	;
;ID_ftan			equ	95	;
;ID_ftanh		equ	96	;
;ID_ftentox		equ	97	;
;ID_ftrapcc		equ	98	;
;ID_ftst			equ	99	;
;ID_ftwotox		equ	100	;
ID_illegal		equ	101	; done
ID_jmp			equ	102	; done
ID_jsr			equ	103	; done
ID_lea			equ	104	; lea
ID_link			equ	105	; link
;ID_lpstop		equ	106	;
ID_lsl			equ	107	; lsl
ID_lsr			equ	108	; lsr
ID_move			equ	109	; move
ID_movea		equ	110	; movea
ID_move_from_ccr	equ	111	; done
ID_move_to_ccr		equ	112	; done
ID_move_from_sr		equ	113	; done
ID_move_to_sr		equ	114	; done
ID_move_usp		equ	115	; done
ID_move16		equ	116	; done
ID_movec		equ	117	; done
ID_movem		equ	118	; done
ID_movep		equ	119	; done
ID_moveq		equ	120	; done
ID_moves		equ	121	; done
ID_muls			equ	122	; done
ID_mulu			equ	123	; done
ID_nbcd			equ	124	; done
ID_neg			equ	125	; done
ID_negx			equ	126	; done
ID_nop			equ	127	; done
ID_not			equ	128	; done
ID_or			equ	129	; done
ID_ori			equ	130	; done
ID_ori_to_ccr		equ	131	; done
ID_ori_to_sr		equ	132	; done
ID_pack			equ	133	; done
;ID_pbcc			equ	134	;
;ID_pdbcc		equ	135	;
ID_pea			equ	136	; done
ID_pflush		equ	137	; done
ID_pflusha		equ	138	; done
;ID_pflushr		equ	139	;
;ID_pflushs		equ	140	;
ID_pload		equ	141	; done
ID_pmove		equ	142	; done
;ID_prestore		equ	143	;
;ID_psave		equ	144	;
;ID_pscc			equ	145	;
ID_ptest		equ	146	; done
;ID_ptrapcc		equ	147	;
;ID_pvalid		equ	148	;
ID_reset		equ	149	; done
ID_rol			equ	150	; done
ID_ror			equ	151	; done
ID_roxl			equ	152	; done
ID_roxr			equ	153	; done
ID_rtd			equ	154	; done
ID_rte			equ	155	; done
;ID_rtm			equ	156	;
ID_rtr			equ	157	; done
ID_rts			equ	158	; done
ID_sbcd			equ	159	; done
ID_scc			equ	160	; done
ID_stop			equ	161	; done
ID_sub			equ	162	; done
ID_suba			equ	163	; done
ID_subi			equ	164	; done
ID_subq			equ	165	; done
ID_subx			equ	166	; done
ID_swap			equ	167	; done
ID_tas			equ	168	; done
ID_tbls			equ	169	; done
ID_tblsn		equ	170	; done
ID_tblu			equ	171	; done
ID_tblun		equ	172	; done
ID_trap			equ	173	; done
ID_trapcc		equ	174	; done
ID_trapv		equ	175	; done
ID_tst			equ	176	; done
ID_unlk			equ	177	; done
ID_unpk			equ	178	; done

;  #] Instructions ID:

_TAS	MACRO
	IFNE	ATARI
	tas	\1
	ENDC
	IFNE	AMIGA
	bset	#7,\1
	ENDC
	ENDM

; a voir:bcc tests, dbcc tests
;		Mode_register ( .P )
;		<ea> analyse ( Bus error in ([]) )
;
; a finir:	<ea> analyse
;
;		change of flow control in:
;
;		chk2, bkpt*, chk, illegal*, jmp*, jsr*
;		rtd*, rte*, rtr*, rts*, trap*, trapv*
;		dbcc*, trapcc*, bcc*, bra*, bsr*, dc.w*
;		fbcc, fdbcc, fscc, ftrappcc
;
; a faire:	cinvl, cpushl, cinvp, cpushp, cinva, cpusha

;  #] REMs & equates:
; TEXT
;  #[ Main:

disassemble_line:
;
; st fpu_disassembly(a6)
;
 movem.l d1-a5,-(sp)
 st dont_remove_break_flag(a6)
; sf operande_flag(a6)
 lea Disassemble_line_readable_buffer(a6),a3
 move.l a0,-(sp)
 move.l a1,a0
 bsr Disassemble_line_test_berror
 tst.w d0
 bne _D_Read_Error
 movem.l d1-a1,-(sp)
 moveq #-1,d0
 moveq #-1,d1
 st dont_remove_break_flag(a6)
 _JSR _check_if_break
 move.l a0,d0
 movem.l (sp)+,d1-a1
 tst.b dont_remove_break_flag(a6)
 beq.s .1
 move.l dont_remove_break_long(a6),(a1)
 move.l d0,dont_remove_break_long(a6)
.1:
 move.l (sp)+,a0
 moveq #0,d7
 lea instruction_descriptor(a6),a5
 moveq #_I_total_size,d0
 subq.w #1,d0
.clear_descriptor:
 clr.b (a5)+
 dbf d0,.clear_descriptor

 lea instruction_descriptor(a6),a5
 move.w #2,_I_size(a5)
 move.l a0,start_of_line_buffer(a6)
 st optimize_address(a6)
 move.b (a1),d0
 lsr.b #2,d0
 and.w #$3c,d0
 jmp disassemble_table(pc,d0.w)

;  #] Main:
;  #[ Main switch:

 _NOOPTI
disassemble_table:
 bra _0000
 bra _0001
 bra _0010
 bra _0011
 bra _0100
 bra _0101
 bra _0110
 bra _0111
 bra _1000
 bra _1001
 bra _1010
 bra _1011
 bra _1100
 bra _1101
 bra _1110
 bra _1111
 _OPTI

;  #] Main switch:
;  #[ Disassemble routines:
;  #[ 0000:

; ADDI*, ANDI*, ANDI to CCR*, ANDI to SR*, BCHG*, BCLR*, BSET*, BTST*
; CAS*, CAS2*, CHK2*, CMPI*, CMP2*, EORI*, EORI to CCR*, EORI to SR*
; MOVEP*, MOVES*, ORI*, ORI to CCR*, ORI to SR*, SUBI*
_0000:
 move.w (a1),d1
 cmp.w #$003c,d1
 beq _ori_to_ccr
 cmp.w #$007c,d1
 beq _ori_to_sr
 cmp.w #$023c,d1
 beq _andi_to_ccr
 cmp.w #$027c,d1
 beq _andi_to_sr
 cmp.w #$0a3c,d1
 beq _eori_to_ccr
 cmp.w #$0a7c,d1
 beq _eori_to_sr
 move.w d1,d0
 and.w #$f1f8,d0
 cmp.w #$0188,d0
 beq _movep_reg_mem_w
 cmp.w #$0108,d0
 beq _movep_mem_reg_w
 cmp.w #$01c8,d0
 beq _movep_reg_mem_l
 cmp.w #$0148,d0
 beq _movep_mem_reg_l
 move.w d1,d0
 and.w #$ffc0,d0
 tst.w d0
 beq _ori_b
 cmp.w #$0040,d0
 beq _ori_w
 cmp.w #$0080,d0
 beq _ori_l
 cmp.w #$0200,d0
 beq _andi_b
 cmp.w #$0240,d0
 beq _andi_w
 cmp.w #$0280,d0
 beq _andi_l
 cmp.w #$0400,d0
 beq _subi_b
 cmp.w #$0440,d0
 beq _subi_w
 cmp.w #$0480,d0
 beq _subi_l
 cmp.w #$0600,d0
 beq _addi_b
 cmp.w #$0640,d0
 beq _addi_w
 cmp.w #$0680,d0
 beq _addi_l
 cmp.w #$0a00,d0
 beq _eori_b
 cmp.w #$0a40,d0
 beq _eori_w
 cmp.w #$0a80,d0
 beq _eori_l
 cmp.w #$0c00,d0
 beq _cmpi_b
 cmp.w #$0c40,d0
 beq _cmpi_w
 cmp.w #$0c80,d0
 beq _cmpi_l
 cmp.w #$0800,d0
 beq _btst_stat
 cmp.w #$0840,d0
 beq _bchg_stat
 cmp.w #$0880,d0
 beq _bclr_stat
 cmp.w #$08c0,d0
 beq _bset_stat
 move.w d1,d0
 and.w #$f1c0,d0
 cmp.w #$0100,d0
 beq _btst_dyn
 cmp.w #$0140,d0
 beq _bchg_dyn
 cmp.w #$0180,d0
 beq _bclr_dyn
 cmp.w #$01c0,d0
 beq _bset_dyn
 move.w d1,d0

 IFNE _68020!_68030
 moveq #'W',d1
 cmp.w #$0cfc,d0
 beq.s .may_be_cas2
 moveq #'L',d1
 cmp.w #$0efc,d0
 bne.s .not_cas2
.may_be_cas2:
 move.b d1,d0
 move.l 2(a1),d1
 and.l #$0e380e38,d1
 beq _cas2
.not_cas2:
 move.w (a1),d1
 move.w d1,d0
 and.w #$ffc0,d0
 move.w 2(a1),d1
 and.w #$0fff,d1
 cmp.w #$0800,d1
 bne.s .not_chk2
 cmp.w #$00c0,d0
 beq _chk2_b
 cmp.w #$02c0,d0
 beq _chk2_w
 cmp.w #$04c0,d0
 beq _chk2_l
.not_chk2:
 move.w (a1),d1
 move.w d1,d0
 and.w #$ffc0,d0
 move.w 2(a1),d1
 and.w #$fe38,d1
 tst.w d1
 bne.s .not_cas
 cmp.w #$0ac0,d0
 beq _cas_b
 cmp.w #$0cc0,d0
 beq _cas_w
 cmp.w #$0ec0,d0
 beq _cas_l
.not_cas:
 move.w (a1),d1
 move.w d1,d0
 and.w #$ffc0,d0
 move.w 2(a1),d1
 and.w #$0fff,d1
 tst.w d1
 bne.s .not_cmp2
 cmp.w #$00c0,d0
 beq _cmp2_b
 cmp.w #$02c0,d0
 beq _cmp2_w
 cmp.w #$04c0,d0
 beq _cmp2_l
.not_cmp2:
 move.w (a1),d1
 move.w d1,d0
 move.w 2(a1),d1
 and.w #$07ff,d1
 bne.s .not_moves
 and.w #$ffc0,d0
 cmp.w #$0e00,d0
 beq _moves_b
 cmp.w #$0e40,d0
 beq _moves_w
 cmp.w #$0e80,d0
 beq _moves_l
.not_moves:
 ENDC

 bra Error_Disassemble_line

_btst_stat:
 move.w #ID_btst,_I_ID_instruction(a5)
 lea btst_dat,a2
 move.l a2,d0
 lea _101111111111011111,a2
 bra.s b_stat
_bchg_stat:
 move.w #ID_bchg,_I_ID_instruction(a5)
 lea bchg_dat,a2
 move.l a2,d0
 lea _101111111111000000,a2
 bra.s b_stat
_bclr_stat:
 move.w #ID_bclr,_I_ID_instruction(a5)
 lea bclr_dat,a2
 move.l a2,d0
 lea _101111111111000000,a2
 bra.s b_stat
_bset_stat:
 move.w #ID_bset,_I_ID_instruction(a5)
 lea bset_dat,a2
 move.l a2,d0
 lea _101111111111000000,a2
b_stat:
 move.l a2,-(sp)
 move.l d0,a2
 bsr Copy_String
 move.l (sp)+,a2
 move.b #' ',(a0)+
 move.w 2(a1),d1
 move.w d1,d0
 and.w #$1f,d0
 bsr dat_to_asc_bu
 addq.w #2,_I_size(a5)
 move.b #',',(a0)+
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_btst_dyn:
 move.w #ID_btst,_I_ID_instruction(a5)
 lea btst_dat,a2
 move.l a2,d0
 lea _101111111111111111,a2
 bra.s b_dyn
_bchg_dyn:
 move.w #ID_bchg,_I_ID_instruction(a5)
 lea bchg_dat,a2
 move.l a2,d0
 lea _101111111111000000,a2
 bra.s b_dyn
_bclr_dyn:
 move.w #ID_bclr,_I_ID_instruction(a5)
 lea bclr_dat,a2
 move.l a2,d0
 lea _101111111111000000,a2
 bra.s b_dyn
_bset_dyn:
 move.w #ID_bset,_I_ID_instruction(a5)
 lea bset_dat,a2
 move.l a2,d0
 lea _101111111111000000,a2
b_dyn:
 move.l a2,-(sp)
 move.l d0,a2
 bsr Copy_String
 move.l (sp)+,a2
 move.w #'B',_I_format(a5)
 move.b #' ',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w (a1),d1
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_movep_reg_mem_w:
 move.w #ID_movep,_I_ID_instruction(a5)
 lea movep_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'W',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w (a1),d1
 or.w #$20,d1
 move.l 2(a1),d2
 bsr Force_Mode_Register
 bra End_Disassemble_line

_movep_mem_reg_w:
 move.w #ID_movep,_I_ID_instruction(a5)
 lea movep_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'W',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w (a1),d1
 or.w #$20,d1
 move.l 2(a1),d2
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_movep_reg_mem_l:
 move.w #ID_movep,_I_ID_instruction(a5)
 lea movep_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'L',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w (a1),d1
 or.w #$20,d1
 move.l 2(a1),d2
 bsr Force_Mode_Register
 bra End_Disassemble_line

_movep_mem_reg_l:
 move.w #ID_movep,_I_ID_instruction(a5)
 lea movep_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'L',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w (a1),d1
 or.w #$20,d1
 move.l 2(a1),d2
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_ori_to_ccr:
 move.w #ID_ori_to_ccr,_I_ID_instruction(a5)
 moveq #'B',d0
 move.w d0,_I_format(a5)
 lea ori_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 move.w 2(a1),d0
 bsr dat_to_asc_bu
 addq.w #2,_I_size(a5)
 move.b #',',(a0)+
 lea ccr_dat,a2
 bsr Copy_String
 bra End_Disassemble_line

_ori_to_sr:
 move.w #ID_ori_to_sr,_I_ID_instruction(a5)
 IFNE 68030
 st _I_priv(a5)
 ENDC
 moveq #'W',d0
 move.w d0,_I_format(a5)
 lea ori_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 move.w 2(a1),d0
 bsr dat_to_asc_wu
 addq.w #2,_I_size(a5)
 move.b #',',(a0)+
 lea sr_dat,a2
 bsr Copy_String
 bra End_Disassemble_line

_andi_to_ccr:
 move.w #ID_andi_to_ccr,_I_ID_instruction(a5)
 moveq #'B',d0
 move.w d0,_I_format(a5)
 lea andi_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 move.w 2(a1),d0
 bsr dat_to_asc_bu
 addq.w #2,_I_size(a5)
 move.b #',',(a0)+
 lea ccr_dat,a2
 bsr Copy_String
 bra End_Disassemble_line

_andi_to_sr:
 move.w #ID_andi_to_sr,_I_ID_instruction(a5)
 tst.b disassembly_type(a6)
 beq.s .68000
 st _I_priv(a5)
.68000:
 moveq #'W',d0
 move.w d0,_I_format(a5)
 lea andi_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 move.w 2(a1),d0
 bsr dat_to_asc_wu
 addq.w #2,_I_size(a5)
 move.b #',',(a0)+
 lea sr_dat,a2
 bsr Copy_String
 bra End_Disassemble_line

_eori_to_ccr:
 move.w #ID_eori_to_ccr,_I_ID_instruction(a5)
 moveq #'B',d0
 move.w d0,_I_format(a5)
 lea eori_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 move.w 2(a1),d0
 bsr dat_to_asc_bu
 addq.w #2,_I_size(a5)
 move.b #',',(a0)+
 lea ccr_dat,a2
 bsr Copy_String
 bra End_Disassemble_line

_eori_to_sr:
 move.w #ID_eori_to_sr,_I_ID_instruction(a5)
 tst.b disassembly_type(a6)
 beq.s .68000
 st _I_priv(a5)
.68000:
 moveq #'W',d0
 move.w d0,_I_format(a5)
 lea eori_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 move.w 2(a1),d0
 bsr dat_to_asc_wu
 addq.w #2,_I_size(a5)
 move.b #',',(a0)+
 lea sr_dat,a2
 bsr Copy_String
 bra End_Disassemble_line

_ori_b:
 move.w #ID_ori,_I_ID_instruction(a5)
 moveq #'B',d0
 lea ori_dat,a2
 bra general_i
_ori_w:
 move.w #ID_ori,_I_ID_instruction(a5)
 moveq #'W',d0
 lea ori_dat,a2
 bra general_i
_ori_l:
 move.w #ID_ori,_I_ID_instruction(a5)
 moveq #'L',d0
 lea ori_dat,a2
 bra general_i

_addi_b:
 move.w #ID_addi,_I_ID_instruction(a5)
 moveq #'B',d0
 lea addi_dat,a2
 bra general_i
_addi_w:
 move.w #ID_addi,_I_ID_instruction(a5)
 moveq #'W',d0
 lea addi_dat,a2
 bra general_i
_addi_l:
 move.w #ID_addi,_I_ID_instruction(a5)
 moveq #'L',d0
 lea addi_dat,a2
 bra general_i

_subi_b:
 move.w #ID_subi,_I_ID_instruction(a5)
 moveq #'B',d0
 lea subi_dat,a2
 bra.s general_i
_subi_w:
 move.w #ID_subi,_I_ID_instruction(a5)
 moveq #'W',d0
 lea subi_dat,a2
 bra.s general_i
_subi_l:
 move.w #ID_subi,_I_ID_instruction(a5)
 moveq #'L',d0
 lea subi_dat,a2
 bra.s general_i

_andi_b:
 move.w #ID_andi,_I_ID_instruction(a5)
 moveq #'B',d0
 lea andi_dat,a2
 bra.s general_i
_andi_w:
 move.w #ID_andi,_I_ID_instruction(a5)
 moveq #'W',d0
 lea andi_dat,a2
 bra.s general_i
_andi_l:
 move.w #ID_andi,_I_ID_instruction(a5)
 moveq #'L',d0
 lea andi_dat,a2
 bra.s general_i

_eori_b:
 move.w #ID_eori,_I_ID_instruction(a5)
 moveq #'B',d0
 lea eori_dat,a2
 bra.s general_i
_eori_w:
 move.w #ID_eori,_I_ID_instruction(a5)
 moveq #'W',d0
 lea eori_dat,a2
 bra.s general_i
_eori_l:
 move.w #ID_eori,_I_ID_instruction(a5)
 moveq #'L',d0
 lea eori_dat,a2
general_i:
 move.w d0,_I_format(a5)
 bsr Copy_String
 move.b #'.',(a0)+
 move.b d0,(a0)+
 move.b #' ',(a0)+
 cmp.w #'B',_I_format(a5)
 bne.s .1
.byte:
 move.w 2(a1),d0
 bsr dat_to_asc_bu
 addq.w #2,d7				; ***
 addq.w #2,_I_size(a5)
 move.l 4(a1),d2
 move.l 8(a1),d3
 bra.s .ea
.1:
 cmp.w #'W',_I_format(a5)
 bne.s .2
.word:
 move.w 2(a1),d0
 bsr dat_to_asc_wu
 addq.w #2,d7				; ***
 addq.w #2,_I_size(a5)
 move.l 4(a1),d2
 move.l 8(a1),d3
 bra.s .ea
.2:
 cmp.w #'L',_I_format(a5)
 bne Error_Disassemble_line
.long:
 move.l 2(a1),d0
 bsr dat_to_asc_lu
 addq.w #4,d7				; ***
 addq.w #4,_I_size(a5)
 move.l 6(a1),d2
 move.l 10(a1),d3
.ea:
 move.b #',',(a0)+
 lea _101111111111000000,a2
 IFNE _68020|_68030
 cmp.w #ID_cmpi,_I_ID_instruction(a5)
 bne.s .notcmpi
 lea _101111111111001000,a2
.notcmpi:
 ENDC ;_68020|_68030
 move.w (a1),d1
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_cmpi_b:
 move.w #ID_cmpi,_I_ID_instruction(a5)
 moveq #'B',d0
 lea cmpi_dat,a2
 bra general_i
_cmpi_w:
 move.w #ID_cmpi,_I_ID_instruction(a5)
 moveq #'W',d0
 lea cmpi_dat,a2
 bra general_i
_cmpi_l:
 move.w #ID_cmpi,_I_ID_instruction(a5)
 moveq #'L',d0
 lea cmpi_dat,a2
 bra general_i

 IFNE _68020!_68030
_cas2:
; tst.b disassembly_type(a6)
; beq Error_Disassemble_line
 move.w #ID_cas2,_I_ID_instruction(a5)
 move.w #6,_I_size(a5)
 lea cas2,a2
 bsr Copy_String
 move.b #'.',(a0)+
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.l 2(a1),d1
 swap d1
 bsr Force_Mode_Register
 move.b #':',(a0)+
 swap d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 swap d1
 ror.w #6,d1
 bsr Force_Mode_Register
 move.b #':',(a0)+
 swap d1
 ror.w #6,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.b #'(',(a0)+
 move.l 2(a1),d1
 swap d1
 rol.w #4,d1
 and.w #$f,d1
 bsr Force_Mode_Register
 move.b #')',(a0)+
 move.b #':',(a0)+
 move.b #'(',(a0)+
 swap d1
 rol.w #4,d1
 and.w #$f,d1
 bsr Force_Mode_Register
 move.b #')',(a0)+
 bra End_Disassemble_line
 ENDC

 IFNE _68020!_68030
_chk2_b:
 moveq #'B',d0
 bra.s _chk2
_chk2_w:
 moveq #'W',d0
 bra.s _chk2
_chk2_l:
 moveq #'L',d0
_chk2:
 move.w #ID_chk2,_I_ID_instruction(a5)
 move.w d0,_I_format(a5)
 move.w #4,_I_size(a5)
 lea chk2_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _001001111111011111,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 moveq #2,d7
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w 2(a1),d1
 rol.w #4,d1
 and.w #$f,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line
 ENDC

 IFNE _68020!_68030
_cas_b:
 moveq #'B',d0
 bra.s _cas
_cas_w:
 moveq #'W',d0
 bra.s _cas
_cas_l:
 moveq #'L',d0
_cas:
 move.w #ID_cas,_I_ID_instruction(a5)
 move.w d0,_I_format(a5)
 move.w #4,_I_size(a5)
 lea cas_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w 2(a1),d1
 move.b #'D',(a0)+
 move.b d1,d0
 and.b #7,d0
 add.b #'0',d0
 move.b d0,(a0)+
 move.b #',',(a0)+
 move.b #'D',(a0)+
 lsr.w #6,d1
 and.w #7,d1
 add.b #'0',d1
 move.b d1,(a0)+
 move.b #',',(a0)+
 lea _001111111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line
 ENDC

 IFNE _68020!_68030
_cmp2_b:
 moveq #'B',d0
 bra.s _cmp2
_cmp2_w:
 moveq #'W',d0
 bra.s _cmp2
_cmp2_l:
 moveq #'L',d0
_cmp2:
 move.w #ID_cmp2,_I_ID_instruction(a5)
 move.w d0,_I_format(a5)
 move.w #4,_I_size(a5)
 lea cmp2_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _001001111111011111,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 moveq #2,d7
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w 2(a1),d1
 rol.w #4,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line
 ENDC

 IFNE _68020!_68030
_moves_b:
 moveq #'B',d0
 bra.s internal_moves
_moves_w:
 moveq #'W',d0
 bra.s internal_moves
_moves_l:
 moveq #'L',d0
internal_moves:
 move.w #ID_moves,_I_ID_instruction(a5)
 move.w d0,_I_format(a5)
 move.w #4,_I_size(a5)
 lea moves_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w 2(a1),d1
 btst #11,d1
 beq.s .ea_to_reg
.reg_to_ea:
 rol.w #4,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 lea _001111111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line
.ea_to_reg:
 lea _001111111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w 2(a1),d1
 rol.w #4,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line
 ENDC

;  #] 0000:
;  #[ 0001:

; MOVE (b)*
_0001:
 move.w #ID_move,_I_ID_instruction(a5)
 moveq #'B',d0
 move.w d0,_I_format(a5)
 lea _101111111111111111,a2
internal_move:
 move.l a2,-(sp)
 lea move_dat,a2
 bsr Copy_String
 move.l (sp)+,a2
 move.b #'.',(a0)+
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w (a1),d1
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 lea _101111111111000000,a2
 move.w (a1),d1
 and.w #$0e00,d1
 rol.w #4,d1
 move.w d1,-(sp)
 move.w (a1),d1
 and.w #$01c0,d1
 ror.w #6,d1
 or.w (sp)+,d1
 rol.w #3,d1
 move.l 2(a1,d7.w),d2
 move.l 6(a1,d7.w),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

;  #] 0001:
;  #[ 0010:

; MOVE (l)*, MOVEA (l)*
_0010:
 move.w (a1),d1
 move.w d1,d0
 and.w #$f1c0,d0
 cmp.w #$2040,d0
 beq _movea_l
 bra _move_l

_movea_l:
 moveq #'L',d0
internal_movea:
 move.w #ID_movea,_I_ID_instruction(a5)
 lea movea_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _111111111111111111,a2
 move.w (a1),d1
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 or.w #8,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_move_l:
 move.w #ID_move,_I_ID_instruction(a5)
 moveq #'L',d0
 move.w d0,_I_format(a5)
 lea _111111111111111111,a2
 bra internal_move

;  #] 0010:
;  #[ 0011:

; MOVE (w)*, MOVEA (w)*
_0011:
 move.w (a1),d1
 move.w d1,d0
 and.w #$f1c0,d0
 cmp.w #$3040,d0
 beq _movea_w
 bra _move_w

_movea_w:
 moveq #'W',d0
 bra internal_movea

_move_w:
 move.w #ID_move,_I_ID_instruction(a5)
 moveq #'W',d0
 move.w d0,_I_format(a5)
 lea _111111111111111111,a2
 bra internal_move

;  #] 0011:
;  #[ 0100:

; BGND*, BKPT*, CHK*, CLR*, DIVS(l)*, DIVU(l)*, EXT*, EXTB*, ILLEGAL*, JMP*
;  JSR*, LEA*, LINK*, MOVE from CCR*, MOVE from SR*, MOVE to CCR*, MOVE to SR*
; MOVE from USP*, MOVE to USP*, MOVEC*, MOVEM*, MULS (l)*, MULU (l)*, NBCD*
; NEG*, NEGX*, NOP*, NOT*, PEA*, RESET*, RTD*, RTE*, RTR*, RTS*, STOP*
; SWAP*, TAS*, TST*, TRAP*, TRAPV*, UNLK*
_0100:
 move.w (a1),d1

 IFNE _CPU32
 cmp.w #$4afa,d1
 beq _bgnd
 ENDC ;_CPU32

 cmp.w #$4afc,d1
 beq _illegal
 cmp.w #$4e70,d1
 beq _reset
 cmp.w #$4e71,d1
 beq _nop
 cmp.w #$4e72,d1
 beq _stop
 cmp.w #$4e73,d1
 beq _rte

 IFNE _68010!_68020!_68030
 cmp.w #$4e74,d1
 beq _rtd
 ENDC

 cmp.w #$4e75,d1
 beq _rts
 cmp.w #$4e76,d1
 beq _trapv
 cmp.w #$4e77,d1
 beq _rtr
 move.w d1,d0
 bclr #0,d0

 IFNE _68010!_68020!_68030
 cmp.w #$4e7a,d0
 beq _movec
 ENDC
 and.w #$fff8,d0

 IFNE _68020!_68030
 cmp.w #$4808,d0
 beq _link_long
 ENDC

 cmp.w #$4840,d0
 beq _swap

 IFNE _68010!_68020!_68030
 cmp.w #$4848,d0
 beq _bkpt
 ENDC

 cmp.w #$4e50,d0
 beq _link_word
 cmp.w #$4880,d0
 beq _extbw
 cmp.w #$48c0,d0
 beq _extwl

 IFNE _68020!_68030
 cmp.w #$49c0,d0
 beq _extbl
 ENDC

 cmp.w #$4e58,d0
 beq _unlk
 bclr #3,d0
 cmp.w #$4e40,d0
 beq _trap
 cmp.w #$4e60,d0
 beq _move_usp
 and.w #$ffc0,d0
 cmp.w #$40c0,d0
 beq _move_from_sr

 IFNE _68010!_68020!_68030
 cmp.w #$42c0,d0
 beq _move_from_ccr
 ENDC

 cmp.w #$44c0,d0
 beq _move_to_ccr
 cmp.w #$46c0,d0
 beq _move_to_sr
 cmp.w #$4800,d0
 beq _nbcd
 cmp.w #$4840,d0
 beq _pea
 cmp.w #$4ac0,d0
 beq _tas

 IFNE _68020!_68030
 cmp.w #$4c00,d0
 beq _mull
 cmp.w #$4c40,d0
 beq _divl
 ENDC

 cmp.w #$4ec0,d0
 beq _jmp
 cmp.w #$4e80,d0
 beq _jsr
 and.w #$ff80,d0
 cmp.w #$4880,d0
 beq _movem_rm
 cmp.w #$4c80,d0
 beq _movem_mr
 move.w d1,d0
 and.w #$f1c0,d0
 cmp.w #$4180,d0
 beq _chk_w

 IFNE _68020!_68030
 cmp.w #$4100,d0
 beq _chk_l
 ENDC

 cmp.w #$41c0,d0
 beq _lea
 move.w d1,d0
 and.w #$ffc0,d0
 cmp.w #$4000,d0
 beq _negx_b
 cmp.w #$4040,d0
 beq _negx_w
 cmp.w #$4080,d0
 beq _negx_l
 cmp.w #$4200,d0
 beq _clr_b
 cmp.w #$4240,d0
 beq _clr_w
 cmp.w #$4280,d0
 beq _clr_l
 cmp.w #$4400,d0
 beq _neg_b
 cmp.w #$4440,d0
 beq _neg_w
 cmp.w #$4480,d0
 beq _neg_l
 cmp.w #$4600,d0
 beq _not_b
 cmp.w #$4640,d0
 beq _not_w
 cmp.w #$4680,d0
 beq _not_l
 cmp.w #$4a00,d0
 beq _tst_b
 cmp.w #$4a40,d0
 beq _tst_w
 cmp.w #$4a80,d0
 beq _tst_l
 bra Error_Disassemble_line

 IFNE _CPU32
_bgnd:
 move.w #ID_bgnd,_I_ID_instruction(a5)
 st _I_exc(a5)
 move.w #4,_I_exc_type(a5)
 st _I_branchf(a5)
 st _I_branchyn(a5)
 sub.l a2,a2
 move.l a1,-(sp)
 lea $10(a2),a1
 bsr test_if_readable
 tst.b readable_buffer(a6)
 bne.s .error
 move.l (a1),d0
 move.l (sp)+,a1
 move.l d0,_I_branchaddr(a5)
 lea bgnd_dat,a2
 bsr Copy_String
 bra End_Disassemble_line
.error:
 move.l (sp)+,a1
 bra Mode_Register_error
 ENDC ;_CPU32

_illegal:
 move.w #ID_illegal,_I_ID_instruction(a5)
 st _I_exc(a5)
 move.w #4,_I_exc_type(a5)
 st _I_branchf(a5)
 st _I_branchyn(a5)
 sub.l a2,a2
 move.l a1,-(sp)
 lea $10(a2),a1
 bsr test_if_readable
 tst.l readable_buffer(a6)
 bne.s .error
 move.l (a1),d0
 move.l (sp)+,a1
 move.l d0,_I_branchaddr(a5)
 lea illegal_dat,a2
 bsr Copy_String
 bra End_Disassemble_line
.error:
 move.l (sp)+,a1
 bra Error_Disassemble_line

_nop:
 move.w #ID_nop,_I_ID_instruction(a5)
 lea nop_dat,a2
 bsr Copy_String
 bra End_Disassemble_line

_stop:
 move.w #ID_stop,_I_ID_instruction(a5)
 addq.w #2,_I_size(a5)
 st _I_priv(a5)
 lea stop_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 move.w 2(a1),d0
 bsr dat_to_asc_wu
 bra End_Disassemble_line

 IFNE _68010!_68020!_68030
_rtd:
 move.w #ID_rtd,_I_ID_instruction(a5)
 lea rtd_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 move.w 2(a1),d0
 bsr dat_to_asc_ws
 addq.w #2,_I_size(a5)
 bsr _get_rets_routine
 bra End_Disassemble_line
 ENDC

_rte:
 move.w #ID_rte,_I_ID_instruction(a5)
 st _I_priv(a5)
 lea rte_dat,a2
 bsr Copy_String
 st d1
 bsr _get_reti_routine
 bra End_Disassemble_line

_reset:
 move.w #ID_reset,_I_ID_instruction(a5)
 st _I_priv(a5)
 lea reset_dat,a2
 bsr Copy_String
 bra End_Disassemble_line

_rts:
 move.w #ID_rts,_I_ID_instruction(a5)
 lea rts_dat,a2
 bsr Copy_String
 bsr _get_rets_routine
 bra End_Disassemble_line

_rtr:
 move.w #ID_rtr,_I_ID_instruction(a5)
 lea rtr_dat,a2
 bsr Copy_String
 sf  d1
 bsr _get_reti_routine
 bra End_Disassemble_line

_trapv:
 move.w #ID_trapv,_I_ID_instruction(a5)
 btst #_V,sr_buf+1(a6)
 beq.s .no_overflow
 st _I_exc(a5)
 st _I_branchf(a5)
 st _I_branchyn(a5)
 sub.l a2,a2
 move.l a1,-(sp)
 lea $1c(a2),a1
 bsr test_if_readable
 tst.l readable_buffer(a6)
 bne.s .error
 move.l (a1),d0
 move.l (sp)+,a1
 move.l d0,_I_branchaddr(a5)
.no_overflow:
 lea trapv_dat,a2
 bsr Copy_String
 bra End_Disassemble_line
.error:
 move.l (sp)+,a1
 bra Error_Disassemble_line

 IFNE _68010!_68020!_68030
_bkpt:
 move.w #ID_bkpt,_I_ID_instruction(a5)
 st _I_exc(a5)
 st _I_branchf(a5)
 st _I_branchyn(a5)
 sub.l a2,a2
 move.l a1,-(sp)
 lea $10(a2),a1
 bsr test_if_readable
 tst.l readable_buffer(a6)
 bne.s .error
 move.l (a1),d0
 move.l (sp)+,a1
 move.l d0,_I_branchaddr(a5)
 lea bkpt_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 move.b d1,d0
 and.b #7,d0
 bsr dat_to_asc_bu
 bra End_Disassemble_line
.error:
 move.l (sp)+,a1
 bra Error_Disassemble_line
 ENDC

 IFNE _68010!_68020!_68030
_movec:
 move.w #ID_movec,_I_ID_instruction(a5)
 moveq #'L',d0
 move.w d0,_I_format(a5)
 move.w #4,_I_size(a5)
 lea movec_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 btst #0,d1
 beq.s .cr_to_rx
.rx_to_cr:
 move.w 2(a1),d1
 move.w d1,-(sp)
 rol.w #4,d1
 and.w #$f,d1
 bsr Force_Mode_Register
 move.w (sp)+,d1
 move.b #',',(a0)+
 bsr Put_Control_reg
 bmi Error_Disassemble_line
 bra End_Disassemble_line
.cr_to_rx:
 move.w 2(a1),d1
 bsr Put_Control_reg
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 rol.w #4,d1
 and.w #$f,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

Put_Control_reg:
 lea sfc_dat,a2
 move.w d1,d0
 and.w #$fff,d0
 beq.s .copy
 addq.w #5,a2
 cmp.w #$001,d0
 beq.s .copy
 addq.w #5,a2
 cmp.w #$002,d0
 beq.s .copy
 addq.w #5,a2
 cmp.w #$800,d0
 beq.s .copy
 addq.w #5,a2
 cmp.w #$801,d0
 beq.s .copy
 addq.w #5,a2
 cmp.w #$802,d0
 beq.s .copy
 addq.w #5,a2
 cmp.w #$803,d0
 beq.s .copy
 addq.w #5,a2
 cmp.w #$804,d0
 beq.s .copy
.error:
 moveq #-1,d0
 rts
.copy:
 bsr Copy_String
 moveq #0,d0
 rts
 ENDC

_trap:
 move.w #ID_trap,_I_ID_instruction(a5)
 st _I_exc(a5)
 st _I_branchf(a5)
 st _I_branchyn(a5)
 lea trap_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 move.w d1,d0
 and.w #$f,d0
 sub.l a2,a2
 lea $80(a2),a2
 move.w d0,d2
 lsl.w #2,d2
 add.w d2,a2
 move.l a1,-(sp)
 move.l a2,a1
 bsr test_if_readable
 tst.l readable_buffer(a6)
 bne.s .error
 move.l (a1),d2
 move.l (sp)+,a1
 move.l d2,_I_branchaddr(a5)
 bsr dat_to_asc_bu
 IFNE ATARIST
 tst.b pc_pointer_flag(a6)
 beq End_Disassemble_line
 move.w (a1),d0
 and.w #$f,d0
 cmp.w #1,d0
 beq trap_1
 cmp.w #2,d0
 beq.s trap_2
 cmp.w #$d,d0
 beq trap_d
 cmp.w #$e,d0
 beq trap_e
 ENDC ;de ATARIST
 bra End_Disassemble_line
.error:
 move.l (sp)+,a1
 bra Error_Disassemble_line

 IFNE ATARIST
trap_2:
 move.l d0_buf(a6),d0
 cmp.w #-2,d0
 beq.s .gdos_function
 cmp.w #$c8,d0
 beq.s .aes_trap_functions
 cmp.w #$73,d0
 beq.s .vdi_trap_functions
 bra End_Disassemble_line

.gdos_function:
 lea vdi_text_table,a2
 bra.s .aes_vdi_loop1

.aes_trap_functions:
 lea aes_text_table,a2
 bra.s .aes_vdi_trap_functions

.vdi_trap_functions:
 lea vdi_text_table,a2

.aes_vdi_trap_functions:
 move.l a2,-(sp)
 move.l d1_buf(a6),a2
 move.l (a2),a2
 move.b 11(a2),d0
 lsl.w #8,d0
 move.b 1(a2),d0		; 0,0,param,func
 move.l (sp)+,a2
.aes_vdi_loop1:
 move.b (a2)+,d1
 beq End_Disassemble_line
 cmp.b #-1,d1
 beq.s .aes_vdi_test_function
.aes_vdi_test_parameter:
 lsl.w #8,d1
 move.b (a2)+,d1
 cmp.w d1,d0
 beq.s .aes_vdi_found
 bra.s .aes_vdi_loop2
.aes_vdi_test_function:
 move.b (a2)+,d1
 beq End_Disassemble_line
 cmp.b d1,d0
 beq.s .aes_vdi_found
.aes_vdi_loop2:
 tst.b (a2)+
 bne.s .aes_vdi_loop2
 bra.s .aes_vdi_loop1
.aes_vdi_found:
 move.l a2,_I_Comment(a5)
 bra End_Disassemble_line

;trap_e:
; move.l a7_buf(a6),a2
; move.w sr_buf(a6),d0
; btst #13,d0
; beq.s .user_trap_e
;.super_trap_e:
; move.l ssp_buf(a6),a2
;.user_trap_e:
; move.w (a2),d1
; lea internal_trap_e_table(pc),a2
; cmp.w (a2)+,d1
; bhi End_Disassemble_line
; add.w d1,d1
; add.w d1,d1
; move.l 0(a2,d1.w),d1
; bmi End_Disassemble_line
; move.l d1,_I_Comment(a5)
; bra End_Disassemble_line

trap_1:	lea	t1tab(pc),a2
	bra	trap1de

trap_d:	lea	tdtab(pc),a2
	bra	trap1de

trap_e:	lea	tetab(pc),a2
;	bra	trap1de

trap1de:
	move.l	a7_buf(a6),a1
	move.w	sr_buf(a6),d0
	btst	#13,d0
	beq.s	.user
.super:	move.l	ssp_buf(a6),a1
.user:	move.w	(a1),d1
	move.l	a2,a1
	move.w	(a2)+,d0
.l1:	cmp.w	(a2)+,d1
	beq.s	.found
	addq.w	#2,a2
	dbf	d0,.l1
	bra	End_Disassemble_line
.found:	add.w	(a2)+,a1
	move.l	a1,_I_Comment(a5)
	bra	End_Disassemble_line

t1tab:
	dc.w	(.last-t1tab-2)/4-1
	dc.w	0,.pterm0-t1tab
	dc.w	1,.cconin-t1tab
	dc.w	2,.cconout-t1tab
	dc.w	3,.cauxin-t1tab
	dc.w	4,.cauxout-t1tab
	dc.w	5,.cprnout-t1tab
	dc.w	6,.crawio-t1tab
	dc.w	7,.crawcin-t1tab
	dc.w	8,.cnecin-t1tab
	dc.w	9,.cconws-t1tab
	dc.w	$a,.cconrs-t1tab
	dc.w	$b,.cconis-t1tab
	dc.w	$e,.dsetdrv-t1tab
	dc.w	$10,.cconos-t1tab
	dc.w	$11,.cprnos-t1tab
	dc.w	$12,.cauxis-t1tab
	dc.w	$13,.cauxos-t1tab
	dc.w	$14,.Maddalt-t1tab	;TT
	dc.w	$19,.dgetdrv-t1tab
	dc.w	$1a,.fsetdta-t1tab
	dc.w	$20,.super-t1tab
	dc.w	$2a,.tgetdate-t1tab
	dc.w	$2b,.tsetdate-t1tab
	dc.w	$2c,.tgettime-t1tab
	dc.w	$2d,.tsettime-t1tab
	dc.w	$2f,.fgetdta-t1tab
	dc.w	$30,.sversion-t1tab
	dc.w	$31,.ptermres-t1tab
	dc.w	$36,.dfree-t1tab
	dc.w	$39,.dcreate-t1tab
	dc.w	$3a,.ddelete-t1tab
	dc.w	$3b,.dsetpath-t1tab
	dc.w	$3c,.fcreate-t1tab
	dc.w	$3d,.fopen-t1tab
	dc.w	$3e,.fclose-t1tab
	dc.w	$3f,.fread-t1tab
	dc.w	$40,.fwrite-t1tab
	dc.w	$41,.fdelete-t1tab
	dc.w	$42,.fseek-t1tab
	dc.w	$43,.fattrib-t1tab
	dc.w	$44,.mxalloc-t1tab	;TT
	dc.w	$45,.fdup-t1tab
	dc.w	$46,.fforce-t1tab
	dc.w	$47,.dgetpath-t1tab
	dc.w	$48,.malloc-t1tab
	dc.w	$49,.mfree-t1tab
	dc.w	$4a,.mshrink-t1tab
	dc.w	$4b,.pexec-t1tab
	dc.w	$4c,.pterm-t1tab
	dc.w	$4e,.fsfirst-t1tab
	dc.w	$4f,.fsnext-t1tab
	dc.w	$56,.frename-t1tab
	dc.w	$57,.fdatime-t1tab
	dc.w	$60,.Nversion-t1tab	;Net
	dc.w	$62,.Frlock-t1tab
	dc.w	$63,.Frunlock-t1tab
	dc.w	$64,.Flock-t1tab
	dc.w	$65,.Funlock-t1tab
	dc.w	$66,.Fflush-t1tab
	dc.w	$7b,.Unlock-t1tab
	dc.w	$7c,.Lock-t1tab
	dc.w	$ff,.syield-t1tab	;MTos
	dc.w	$100,.fpipe-t1tab
	dc.w	$104,.fcntl-t1tab
	dc.w	$105,.finstat-t1tab
	dc.w	$106,.foutstat-t1tab
	dc.w	$107,.fgetchar-t1tab
	dc.w	$108,.fputchar-t1tab
	dc.w	$109,.pwait-t1tab
	dc.w	$10a,.pnice-t1tab
	dc.w	$10b,.pgetpid-t1tab
	dc.w	$10c,.pgetppid-t1tab
	dc.w	$10d,.pgetpgrp-t1tab
	dc.w	$10e,.psetpgrp-t1tab
	dc.w	$10f,.pgetuid-t1tab
	dc.w	$110,.psetuid-t1tab
	dc.w	$111,.pkill-t1tab
	dc.w	$112,.psignal-t1tab
	dc.w	$113,.pvfork-t1tab
	dc.w	$114,.pgetgid-t1tab
	dc.w	$115,.psetgid-t1tab
	dc.w	$116,.psigblock-t1tab
	dc.w	$117,.psigsetmask-t1tab
	dc.w	$118,.pusrval-t1tab
	dc.w	$119,.pdomain-t1tab
	dc.w	$11a,.psigreturn-t1tab
	dc.w	$11b,.pfork-t1tab
	dc.w	$11c,.pwait3-t1tab
	dc.w	$11d,.fselect-t1tab
	dc.w	$11e,.prusage-t1tab
	dc.w	$11f,.psetlimit-t1tab
	dc.w	$120,.talarm-t1tab
	dc.w	$121,.pause-t1tab
	dc.w	$122,.sysconf-t1tab
	dc.w	$123,.psigpending-t1tab
	dc.w	$124,.dpathconf-t1tab
	dc.w	$125,.pmsg-t1tab
	dc.w	$126,.fmidipipe-t1tab
	dc.w	$127,.prenice-t1tab
	dc.w	$128,.dopendir-t1tab
	dc.w	$129,.dreaddir-t1tab
	dc.w	$12a,.drewinddir-t1tab
	dc.w	$12b,.dclosedir-t1tab
	dc.w	$12c,.fxattr-t1tab
	dc.w	$12d,.flink-t1tab
	dc.w	$12e,.fsymlink-t1tab
	dc.w	$12f,.freadlink-t1tab
	dc.w	$130,.dcntl-t1tab
	dc.w	$131,.fchown-t1tab
	dc.w	$132,.fchmod-t1tab
	dc.w	$133,.pumask-t1tab
	dc.w	$134,.psemaphore-t1tab
	dc.w	$135,.dlock-t1tab
	dc.w	$136,.psigpause-t1tab
.last:

.pterm0:	dc.b	'Pterm0',0
.cconin:	dc.b	'Cconin',0
.cconout:	dc.b	'Cconout',0
.cauxin:	dc.b	'Cauxin',0
.cauxout:	dc.b	'Cauxout',0
.cprnout:	dc.b	'Cprnout',0
.crawio:	dc.b	'Crawio',0
.crawcin:	dc.b	'Crawcin',0
.cnecin:	dc.b	'Cnecin',0
.cconws:	dc.b	'Cconws',0
.cconrs:	dc.b	'Cconrs',0
.cconis:	dc.b	'Cconis',0
.dsetdrv:	dc.b	'Dsetdrv',0
.cconos:	dc.b	'Cconos',0
.cprnos:	dc.b	'Cprnos',0
.cauxis:	dc.b	'Cauxis',0
.cauxos:	dc.b	'Cauxos',0
.Maddalt:	dc.b	'Maddalt',0
.dgetdrv:	dc.b	'Dgetdrv',0
.fsetdta:	dc.b	'Fsetdta',0
.super:		dc.b	'Super',0
.tgetdate:	dc.b	'Tgetdate',0
.tsetdate:	dc.b	'Tsetdate',0
.tgettime:	dc.b	'Tgettime',0
.tsettime:	dc.b	'Tsettime',0
.fgetdta:	dc.b	'Fgetdta',0
.sversion:	dc.b	'Sversion',0
.ptermres:	dc.b	'Ptermres',0
.dfree:		dc.b	'Dfree',0
.dcreate:	dc.b	'Dcreate',0
.ddelete:	dc.b	'Ddelete',0
.dsetpath:	dc.b	'Dsetpath',0
.fcreate:	dc.b	'Fcreate',0
.fopen:		dc.b	'Fopen',0
.fclose:	dc.b	'Fclose',0
.fread:		dc.b	'Fread',0
.fwrite:	dc.b	'Fwrite',0
.fdelete:	dc.b	'Fdelete',0
.fseek:		dc.b	'Fseek',0
.fattrib:	dc.b	'Fattrib',0
.mxalloc:	dc.b	'Mxalloc',0
.fdup:		dc.b	'Fdup',0
.fforce:	dc.b	'Fforce',0
.dgetpath:	dc.b	'Dgetpath',0
.malloc:	dc.b	'Malloc',0
.mfree:		dc.b	'Mfree',0
.mshrink:	dc.b	'Mshrink',0
.pexec:		dc.b	'Pexec',0
.pterm:		dc.b	'Pterm',0
.fsfirst:	dc.b	'Fsfirst',0
.fsnext:	dc.b	'Fsnext',0
.frename:	dc.b	'Frename',0
.fdatime:	dc.b	'Fdatime',0
.Nversion:	dc.b	'Nversion',0
.Frlock:	dc.b	'Frlock',0
.Frunlock:	dc.b	'Frunlock',0
.Flock:		dc.b	'Flock',0
.Funlock:	dc.b	'Funlock',0
.Fflush:	dc.b	'Fflush',0
.Unlock:	dc.b	'Unlock',0
.Lock:		dc.b	'Lock',0
.syield:	dc.b	'Syield',0
.fpipe:	dc.b	'Fpipe',0
.fcntl:	dc.b	'Fcntl',0
.finstat:	dc.b	'Finstat',0
.foutstat:	dc.b	'Foutstat',0
.fgetchar:	dc.b	'Fgetchar',0
.fputchar:	dc.b	'Fputchar',0
.pwait:	dc.b	'Pwait',0
.pnice:	dc.b	'Pnice',0
.pgetpid:	dc.b	'Pgetpid',0
.pgetppid:	dc.b	'Pgetppid',0
.pgetpgrp:	dc.b	'Pgetpgrp',0
.psetpgrp:	dc.b	'Psetpgrp',0
.pgetuid:	dc.b	'Pgetuid',0
.psetuid:	dc.b	'Psetuid',0
.pkill:	dc.b	'Pkill',0
.psignal:	dc.b	'Psignal',0
.pvfork:	dc.b	'Pvfork',0
.pgetgid:	dc.b	'Pgetgid',0
.psetgid:	dc.b	'Psetgid',0
.psigblock:	dc.b	'Psigblock',0
.psigsetmask:	dc.b	'Psigsetmask',0
.pusrval:	dc.b	'Pusrval',0
.pdomain:	dc.b	'Pdomain',0
.psigreturn:	dc.b	'Psigreturn',0
.pfork:	dc.b	'Pfork',0
.pwait3:	dc.b	'Pwait3',0
.fselect:	dc.b	'Fselect',0
.prusage:	dc.b	'Prusage',0
.psetlimit:	dc.b	'Psetlimit',0
.talarm:	dc.b	'Talarm',0
.pause:	dc.b	'Pause',0
.sysconf:	dc.b	'Sysconf',0
.psigpending:	dc.b	'Psigpending',0
.dpathconf:	dc.b	'Dpathconf',0
.pmsg:	dc.b	'Pmsg',0
.fmidipipe:	dc.b	'Fmidipipe',0
.prenice:	dc.b	'Prenice',0
.dopendir:	dc.b	'Dopendir',0
.dreaddir:	dc.b	'Dreaddir',0
.drewinddir:	dc.b	'Drewinddir',0
.dclosedir:	dc.b	'Dclosedir',0
.fxattr:	dc.b	'Fxattr',0
.flink:	dc.b	'Flink',0
.fsymlink:	dc.b	'Fsymlink',0
.freadlink:	dc.b	'Freadlink',0
.dcntl:	dc.b	'Dcntl',0
.fchown:	dc.b	'Fchown',0
.fchmod:	dc.b	'Fchmod',0
.pumask:	dc.b	'Pumask',0
.psemaphore:	dc.b	'Psemaphore',0
.dlock:	dc.b	'Dlock',0
.psigpause:	dc.b	'Psigpause',0
	even

tdtab:
	dc.w	(.last-tdtab-2)/4-1
	dc.w	0,.getmbp-tdtab
	dc.w	1,.bconstat-tdtab
	dc.w	2,.bconin-tdtab
	dc.w	3,.bconout-tdtab
	dc.w	4,.rwabs-tdtab
	dc.w	5,.setexec-tdtab
	dc.w	6,.tickcal-tdtab
	dc.w	7,.getbpb-tdtab
	dc.w	8,.bcostat-tdtab
	dc.w	9,.mediach-tdtab
	dc.w	$a,.drvmap-tdtab
	dc.w	$b,.kbshift-tdtab
.last:

.getmbp:	dc.b	'Getmpb',0
.bconstat:	dc.b	'Bconstat',0
.bconin:	dc.b	'Bconin',0
.bconout:	dc.b	'Bconout',0
.rwabs:	dc.b	'Rwabs',0
.setexec:	dc.b	'Setexec',0
.tickcal:	dc.b	'Tickcal',0
.getbpb:	dc.b	'Getbpb',0
.bcostat:	dc.b	'Bcostat',0
.mediach:	dc.b	'Mediach',0
.drvmap:	dc.b	'Drvmap',0
.kbshift:	dc.b	'Kbshift',0
	even

tetab:
	dc.w	(.last-tetab-2)/4-1
	dc.w	0,.initmous-tetab
	dc.w	1,.ssbrk-tetab
	dc.w	2,.physbase-tetab
	dc.w	3,.logbase-tetab
	dc.w	4,.getrez-tetab
	dc.w	5,.setscreen-tetab
	dc.w	6,.setpalette-tetab
	dc.w	7,.setcolor-tetab
	dc.w	8,.floprd-tetab
	dc.w	9,.flopwr-tetab
	dc.w	$a,.flopfmt-tetab
	dc.w	$b,.midiws-tetab
	dc.w	$d,.mfpint-tetab
	dc.w	$e,.iorec-tetab
	dc.w	$f,.rsconf-tetab
	dc.w	$10,.keytbl-tetab
	dc.w	$11,.random-tetab
	dc.w	$12,.protobt-tetab
	dc.w	$13,.flopver-tetab
	dc.w	$14,.scrdmp-tetab
	dc.w	$15,.cursconf-tetab
	dc.w	$16,.settime-tetab
	dc.w	$17,.gettime-tetab
	dc.w	$18,.bioskeys-tetab
	dc.w	$19,.ikbdws-tetab
	dc.w	$1a,.jdisint-tetab
	dc.w	$1b,.jenabint-tetab
	dc.w	$1c,.giaccess-tetab
	dc.w	$1d,.offgibit-tetab
	dc.w	$1e,.ongibit-tetab
	dc.w	$1f,.xbtimer-tetab
	dc.w	$20,.dosound-tetab
	dc.w	$21,.setprt-tetab
	dc.w	$22,.kvdvbase-tetab
	dc.w	$23,.kbrate-tetab
	dc.w	$24,.ptrblk-tetab
	dc.w	$25,.vsync-tetab
	dc.w	$26,.supexec-tetab
	dc.w	$27,.puntaes-tetab
	dc.w	$28,.floprate-tetab
	dc.w	$2a,.DMAread-tetab
	dc.w	$2b,.DMAwrite-tetab
	dc.w	$2c,.bconmap-tetab
	dc.w	$2d,.NVMaccess-tetab
	dc.w	$40,.blitmode-tetab
	dc.w	$51,._Esetshift-tetab
	dc.w	$52,._Egetshift-tetab
	dc.w	$53,._Esetbank-tetab
	dc.w	$54,._Esetcolor-tetab
	dc.w	$55,._Esetpalette-tetab
	dc.w	$56,._Egetpalette-tetab
	dc.w	$57,._Esetgray-tetab
;	dc.w	$58,._Esetsmear-tetab
	dc.w	$58,.Vsetmode-tetab		;Falcon video
	dc.w	$59,.Vmontype-tetab
	dc.w	$5a,.Vsetsync-tetab
	dc.w	$5b,.Vgetsize-tetab
	dc.w	$5c,.Vsetvars-tetab
	dc.w	$5d,.VsetRGB-tetab
	dc.w	$5e,.VgetRGB-tetab
	dc.w	$96,.Vsetmask-tetab
DSP_START	equ	$60	;$60	;500		;Falcon DSP
	dc.w	DSP_START,.dspdoblock-tetab
	dc.w	DSP_START+1,.dspblkhandshake-tetab
	dc.w	DSP_START+2,.dspblkunpacked-tetab
	dc.w	DSP_START+3,.dspinstream-tetab
	dc.w	DSP_START+4,.dspoutstream-tetab
	dc.w	DSP_START+5,.dspiostream-tetab
	dc.w	DSP_START+6,.dspremoveinterrupts-tetab
	dc.w	DSP_START+7,.dspgetwordsize-tetab
	dc.w	DSP_START+8,.dsplock-tetab
	dc.w	DSP_START+9,.dspunlock-tetab
	dc.w	DSP_START+10,.dspavailable-tetab
	dc.w	DSP_START+11,.dspreserve-tetab
	dc.w	DSP_START+12,.dsploadprog-tetab
	dc.w	DSP_START+13,.dspexecprog-tetab
	dc.w	DSP_START+14,.dspexecboot-tetab
	dc.w	DSP_START+15,.dsplodtobinary-tetab
	dc.w	DSP_START+16,.dsptriggerhc-tetab
	dc.w	DSP_START+17,.dsprequestuniqueability-tetab
	dc.w	DSP_START+18,.dspgetprogability-tetab
	dc.w	DSP_START+19,.dspflushsubroutines-tetab
	dc.w	DSP_START+20,.dsploadsubroutine-tetab
	dc.w	DSP_START+21,.dspinqsubrability-tetab
	dc.w	DSP_START+22,.dsprunsubroutine-tetab
	dc.w	DSP_START+23,.dsphf0-tetab
	dc.w	DSP_START+24,.dsphf1-tetab
	dc.w	DSP_START+25,.dsphf2-tetab
	dc.w	DSP_START+26,.dsphf3-tetab
	dc.w	DSP_START+27,.dspblkwords-tetab
	dc.w	DSP_START+28,.dspblkbytes-tetab
	dc.w	DSP_START+29,.dsphstat-tetab
	dc.w	DSP_START+30,.dspsetvectors-tetab
	dc.w	DSP_START+31,.dspmultblocks-tetab
SND_START	equ	$80			;Falcon sound
	dc.w	SND_START,.sndlock-tetab
	dc.w	SND_START+1,.sndunlock-tetab
	dc.w	SND_START+2,.sndcmd-tetab
	dc.w	SND_START+3,.sndsetbuffer-tetab
	dc.w	SND_START+4,.sndsetmode-tetab
	dc.w	SND_START+5,.sndsettrack-tetab
	dc.w	SND_START+6,.sndsetmontrack-tetab
	dc.w	SND_START+7,.sndsetinterrupt-tetab
	dc.w	SND_START+8,.sndbufoper-tetab
	dc.w	SND_START+9,.snddsptristate-tetab
	dc.w	SND_START+10,.sndgpio-tetab
	dc.w	SND_START+11,.snddevconnect-tetab
	dc.w	SND_START+12,.sndstatus-tetab
	dc.w	SND_START+13,.sndbufptr-tetab
.last:

.initmous:	dc.b	'Initmous',0
.ssbrk:	dc.b	'Ssbrk',0
.physbase:	dc.b	'Physbase',0
.logbase:	dc.b	'Logbase',0
.getrez:	dc.b	'Getrez',0
.setscreen:	dc.b	'Setscreen',0
.setpalette:	dc.b	'Setpalette',0
.setcolor:	dc.b	'Setcolor',0
.floprd:	dc.b	'Floprd',0
.flopwr:	dc.b	'Flopwr',0
.flopfmt:	dc.b	'Flopfmt',0
.midiws:	dc.b	'Midiws',0
.mfpint:	dc.b	'Mfpint',0
.iorec:	dc.b	'Iorec',0
.rsconf:	dc.b	'Rsconf',0
.keytbl:	dc.b	'Keytbl',0
.random:	dc.b	'Random',0
.protobt:	dc.b	'Protobt',0
.flopver:	dc.b	'Flopver',0
.scrdmp:	dc.b	'Scrdmp',0
.cursconf:	dc.b	'Cursconf',0
.settime:	dc.b	'Settime',0
.gettime:	dc.b	'Gettime',0
.bioskeys:	dc.b	'Bioskeys',0
.ikbdws:	dc.b	'Ikbdws',0
.jdisint:	dc.b	'Jdisint',0
.jenabint:	dc.b	'Jenabint',0
.giaccess:	dc.b	'Giaccess',0
.offgibit:	dc.b	'Offgibit',0
.ongibit:	dc.b	'Ongibit',0
.xbtimer:	dc.b	'Xbtimer',0
.dosound:	dc.b	'Dosound',0
.setprt:	dc.b	'Setprt',0
.kvdvbase:	dc.b	'Kbdvbase',0
.kbrate:	dc.b	'Kbrate',0
.ptrblk:	dc.b	'Ptrblk',0
.vsync:	dc.b	'Vsync',0
.supexec:	dc.b	'Supexec',0
.puntaes:	dc.b	'Puntaes',0
.floprate:	dc.b	'Floprate',0
.blitmode:	dc.b	'Blitmode',0
.DMAread:	dc.b	'DMAread',0
.DMAwrite:	dc.b	'DMAwrite',0
.bconmap:	dc.b	'Bconmap',0
.NVMaccess:	dc.b	'NVMaccess',0
._Esetshift:	dc.b	'_Esetshift',0
._Egetshift:	dc.b	'_Egetshift',0
._Esetbank:	dc.b	'_Esetbank',0
._Esetcolor:	dc.b	'_Esetcolor',0
._Esetpalette:	dc.b	'_Esetpalette',0
._Egetpalette:	dc.b	'_Egetpalette',0
._Esetgray:	dc.b	'_Esetgray',0
._Esetsmear:	dc.b	'_Esetsmear',0
.Vsetmode:	dc.b	'Vsetmode',0
.Vmontype:	dc.b	'Vmontype',0
.Vsetsync:	dc.b	'Vsetsync',0
.Vgetsize:	dc.b	'Vgetsize',0
.Vsetvars:	dc.b	'Vsetvars',0
.VsetRGB:	dc.b	'VsetRGB',0
.VgetRGB:	dc.b	'VgetRGB',0
.Vsetmask:	dc.b	'Vsetmask',0
.dspdoblock:	dc.b	'DspDoBlock',0
.dspblkhandshake:	dc.b	'DspBlkHandShake',0
.dspblkunpacked:	dc.b	'DspBlkUnpacked',0
.dspinstream:	dc.b	'DspInStream',0
.dspoutstream:	dc.b	'DspOutStream',0
.dspiostream:	dc.b	'DspIOStream',0
.dspremoveinterrupts:	dc.b	'DspRemoveInterrupts',0
.dspgetwordsize:	dc.b	'DspGetWordSize',0
.dsplock:	dc.b	'DspLock',0
.dspunlock:	dc.b	'DspUnlock',0
.dspavailable:	dc.b	'DspAvailable',0
.dspreserve:	dc.b	'DspReserve',0
.dsploadprog:	dc.b	'DspLoadProg',0
.dspexecprog:	dc.b	'DspExecProg',0
.dspexecboot:	dc.b	'DspExecBoot',0
.dsplodtobinary:	dc.b	'DspLodToBinary',0
.dsptriggerhc:	dc.b	'DspTriggerHC',0
.dsprequestuniqueability:	dc.b	'DspRequestUniqueAbility',0
.dspgetprogability:	dc.b	'DspGetProgAbility',0
.dspflushsubroutines:	dc.b	'DspFlushSubroutines',0
.dsploadsubroutine:	dc.b	'DspLoadSubroutine',0
.dspinqsubrability:	dc.b	'DspInqSubrAbility',0
.dsprunsubroutine:	dc.b	'DspRunSubroutine',0
.dsphf0:	dc.b	'DspHf0',0
.dsphf1:	dc.b	'DspHf1',0
.dsphf2:	dc.b	'DspHf2',0
.dsphf3:	dc.b	'DspHf3',0
.dspblkwords:	dc.b	'DspBlkWords',0
.dspblkbytes:	dc.b	'DspBlkBytes',0
.dsphstat:	dc.b	'DspHStat',0
.dspsetvectors:	dc.b	'DspSetVectors',0
.dspmultblocks:	dc.b	'DspMultBlocks',0
.sndlock:	dc.b	'SndLock',0
.sndunlock:	dc.b	'SndUnlock',0
.sndcmd:	dc.b	'SndCmd',0
.sndsetbuffer:	dc.b	'SndSetBuffer',0
.sndsetmode:	dc.b	'SndSetMode',0
.sndsettrack:	dc.b	'SndSetTrack',0
.sndsetmontrack:	dc.b	'SndSetMonTrack',0
.sndsetinterrupt:	dc.b	'SndSetInterrupt',0
.sndbufoper:	dc.b	'SndBufOper',0
.snddsptristate:	dc.b	'SndDspTriState',0
.sndgpio:	dc.b	'SndGpio',0
.snddevconnect:	dc.b	'SndDevConnect',0
.sndstatus:	dc.b	'SndStatus',0
.sndbufptr:	dc.b	'SndBufPtr',0
	even
	ENDC ;d'ATARIST

_move_usp:
 move.w #ID_move_usp,_I_ID_instruction(a5)
 moveq #'L',d0
 move.w d0,_I_format(a5)
 st _I_priv(a5)
 lea move_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 btst #3,d1
 bne.s .usp_to_an
.an_to_usp:
 bset #3,d1
 and.w #$f,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 lea usp_dat,a2
 bsr Copy_String
 bra End_Disassemble_line
.usp_to_an:
 lea usp_dat,a2
 bsr Copy_String
 move.b #',',(a0)+
 and.w #$f,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_swap:
 move.w #ID_swap,_I_ID_instruction(a5)
 lea swap_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 bsr Force_Mode_Register
 bra End_Disassemble_line

_link_word:
 move.w #ID_link,_I_ID_instruction(a5)
 lea link_word_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 bset #3,d1
 and.w #$f,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w 2(a1),d0
 bsr dat_to_asc_ws
 addq.w #2,_I_size(a5)
 bra End_Disassemble_line

 IFNE _68020!_68030
_link_long:
 move.w #ID_link,_I_ID_instruction(a5)
 lea link_long_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 bset #3,d1
 and.w #$f,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.l 2(a1),d0
 bsr dat_to_asc_ls
 addq.w #4,_I_size(a5)
 bra End_Disassemble_line
 ENDC

_unlk:
 move.w #ID_unlk,_I_ID_instruction(a5)
 lea unlk_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 and.w #$f,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_chk_w:
 moveq #'W',d0
 bra general_chk
 IFNE _68020!_68030
_chk_l:
 moveq #'L',d0
 ENDC
general_chk:
 move.w #ID_chk,_I_ID_instruction(a5)
 lea chk_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _101111111111111111,a2
 move.w (a1),d1
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 move.b #',',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

 IFNE _68020!_68030
_mulul:
 lea mulu_dat,a2
 bra.s internal_mull

_mull:
 move.w 2(a1),d0
 and.w #$8bf8,d0
 beq.s _mulul
 cmp.w #$0800,d0
 beq.s _mulsl
 bra Error_Disassemble_line
_mulsl:
 lea muls_dat,a2
internal_mull:
 move.w #4,_I_size(a5)
 bsr Copy_String
 move.w 2(a1),d0
 btst #10,d0
 beq.s .short
.long:
 move.b #'.',(a0)+
 moveq #'L',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _101111111111111111,a2
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w 2(a1),d1
 bsr Force_Mode_Register
 move.b #':',(a0)+
 move.w 2(a1),d1
 moveq #12,d0
 lsr.w d0,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line
.short:
 move.b #'.',(a0)+
 moveq #'L',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _101111111111111111,a2
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w 2(a1),d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

 ENDC

 IFNE _68020!_68030
_divl:
 move.w 2(a1),d0
 and.w #$8bf8,d0
 beq.s _divul
 cmp.w #$0800,d0
 beq.s _divsl
 bra Error_Disassemble_line
_divsl:
 move.w #ID_divsl,_I_ID_instruction(a5)
 lea divs_dat,a2
 bra.s internal_divl

_divul:
 move.w #ID_divul,_I_ID_instruction(a5)
 lea divu_dat,a2
internal_divl:
 move.w #4,_I_size(a5)
 bsr Copy_String
 move.w 2(a1),d0
 btst #10,d0
 beq.s .short
.long:
 move.b #'.',(a0)+
 moveq #'L',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _101111111111111111,a2
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w 2(a1),d1
 bsr Force_Mode_Register
 move.b #':',(a0)+
 move.w 2(a1),d1
 moveq #12,d2
 lsr.w d2,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line
.short:
 move.l a0,-(sp)	;save for DIVL.L
 move.b #'.',(a0)+
 moveq #'L',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _101111111111111111,a2
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi.s .err
 move.b #',',(a0)+
 move.w 2(a1),d1
 bsr Force_Mode_Register
 move.l (sp)+,a2	;restore for DIVL.L
 move.w d1,d2
 move.w 2(a1),d1
 moveq #12,d0
 lsr.w d0,d1
 cmp.b d1,d2
 beq.s .end
 move.l a0,d0
 sub.l a2,d0
 subq.w #1,d0
 move.l a0,a2
.l1:
 move.b -(a2),1(a2)
 dbf d0,.l1
 move.b #'L',(a2)
 addq.w #1,a0
 move.b #':',(a0)+
 bsr Force_Mode_Register
.end:
 bra End_Disassemble_line
.err:
 addq.w #4,sp
 bra Error_Disassemble_line
 ENDC

_extbw:
 move.w #ID_ext,_I_ID_instruction(a5)
 lea ext_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'W',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
general_ext:
 move.b #' ',(a0)+
 bsr Force_Mode_Register
 bra End_Disassemble_line

_extwl:
 move.w #ID_ext,_I_ID_instruction(a5)
 lea ext_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'L',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 bra.s general_ext

 IFNE _68020!_68030
_extbl:
 move.w #ID_extb,_I_ID_instruction(a5)
 lea extb_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'L',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 bra.s general_ext
 ENDC

_move_from_sr:
 move.w #ID_move_from_sr,_I_ID_instruction(a5)
 tst.b disassembly_type(a6)
 beq.s .68000
 st _I_priv(a5)
.68000:
 moveq #'W',d0
 move.w d0,_I_format(a5)
 lea move_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 lea sr_dat,a2
 bsr Copy_String
 move.b #',',(a0)+
 lea _101111111111000000,a2
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

 IFNE _68010!_68020!_68030
_move_from_ccr:
 move.w #ID_move_from_ccr,_I_ID_instruction(a5)
 moveq #'W',d0
 move.w d0,_I_format(a5)
 lea move_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 lea ccr_dat,a2
 bsr Copy_String
 move.b #',',(a0)+
 lea _101111111111000000,a2
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line
 ENDC

_move_to_ccr:
 move.w #ID_move_to_ccr,_I_ID_instruction(a5)
 moveq #'W',d0
 move.w d0,_I_format(a5)
 lea move_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 lea _101111111111111111,a2
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 lea ccr_dat,a2
 bsr Copy_String
 bra End_Disassemble_line

_move_to_sr:
 move.w #ID_move_to_sr,_I_ID_instruction(a5)
 tst.b disassembly_type(a6)
 beq.s .68000
 st _I_priv(a5)
.68000:
 moveq #'W',d0
 move.w d0,_I_format(a5)
 lea move_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 lea _101111111111111111,a2
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 lea sr_dat,a2
 bsr Copy_String
 bra End_Disassemble_line

_nbcd:
 move.w #ID_nbcd,_I_ID_instruction(a5)
 lea nbcd_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 lea _101111111111000000,a2
 move.w (a1),d1
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_pea:
 move.w #ID_pea,_I_ID_instruction(a5)
 lea pea_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 lea _001001111111011111,a2
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_tas:
 move.w #ID_tas,_I_ID_instruction(a5)
 lea tas_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 lea _101111111111000000,a2
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_jmp:
 move.w #ID_jmp,_I_ID_instruction(a5)
 lea jmp_dat,a2
 bsr Copy_String
_internal_jmp_jsr:
 move.b #' ',(a0)+
 lea _001001111111011111,a2
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 st _I_branchf(a5)
 st _I_branchyn(a5)
 move.l _I_sourceaddr(a5),_I_branchaddr(a5)
 tst.b pc_pointer_flag(a6)
 beq.s .no_watch
 bsr modify_arrow
.no_watch:
 bra End_Disassemble_line

_jsr:
 move.w #ID_jsr,_I_ID_instruction(a5)
 lea jsr_dat,a2
 bsr Copy_String
 bra.s _internal_jmp_jsr

_lea:
 move.w #ID_lea,_I_ID_instruction(a5)
 lea lea_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 lea _001001111111011111,a2
 move.w (a1),d1
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 or.w #$8,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_movem_rm:
 move.w #ID_movem,_I_ID_instruction(a5)
 move.w #4,_I_size(a5)
 lea movem_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'L',d0
 btst #6,d1
 bne.s .long
.word:
 moveq #'W',d0
.long:
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w 2(a1),d1
 move.w d1,d0
 bsr internal_movem
 move.b #',',(a0)+
 lea _001011111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_movem_mr:
 move.w #ID_movem,_I_ID_instruction(a5)
 move.w #4,_I_size(a5)
 lea movem_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'L',d0
 btst #6,d1
 bne.s .long
.word:
 moveq #'W',d0
.long:
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _001101111111011111,a2
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.w 2(a1),d1
 move.w d1,d0
 move.b #',',(a0)+
 bsr internal_movem
 bra End_Disassemble_line

internal_movem:
 movem.l d6-d7/a2,-(sp)
 tst.w d0
 bne.s .register
.no_register:
 move.b #178,(a0)+
 movem.l (sp)+,d6-d7/a2
 rts
.register:
 sf save_movem(a6)
 sf movem_flag(a6)
 sf first_movem(a6)
 moveq #15,d6
 lea movem_table,a2
 clr.w d7
 move.w (a1),d6
 and.w #$38,d6
 cmp.w #$20,d6
 bne.s .0
 moveq #15,d7
 st save_movem(a6)
.0:
 moveq #15,d6
.1:
 btst d7,d0
 beq.s .no
 sf first_movem(a6)
 _TAS movem_flag(a6)
 bne.s .2
 move.b (a2),(a0)+
 move.b 1(a2),(a0)+
 move.b #"-",(a0)+
 st first_movem(a6)
 bra.s .2
.no:
 tst.b movem_flag(a6)
 bne.s .6
 sf first_movem(a6)
 bra.s .2
.6:
 tst.b first_movem(a6)
 bne.s .5
 move.b -2(a2),(a0)+
 move.b -1(a2),(a0)+
 move.b #'/',(a0)+
 sf movem_flag(a6)
 sf first_movem(a6)
 bra.s .2
.5:
 move.b #'/',-1(a0)
 sf movem_flag(a6)
 sf first_movem(a6)
.2:
 addq.w #2,a2
 tst.b save_movem(a6)
 bne.s .3
 addq.w #1,d7
 dbf d6,.1
 bra.s .4
.3:
 subq.w #1,d7
 dbf d6,.1
.4:
 tst.b movem_flag(a6)
 beq.s .7
 tst.b first_movem(a6)
 bne.s .7
 move.b -2(a2),(a0)+
 move.b -1(a2),(a0)+
 move.b #'/',(a0)+
.7:
 clr.b -(a0)
 movem.l (sp)+,d6-d7/a2
 rts

_clr_b:
 moveq #'B',d0
 bra.s general_clr
_clr_w:
 moveq #'W',d0
 bra.s general_clr
_clr_l:
 moveq #'L',d0
general_clr:
 move.w #ID_clr,_I_ID_instruction(a5)
 move.w d0,_I_format(a5)
 lea clr_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _101111111111000000,a2
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_neg_b:
 moveq #'B',d0
 bra.s general_neg
_neg_w:
 moveq #'W',d0
 bra.s general_neg
_neg_l:
 moveq #'L',d0
general_neg:
 move.w #ID_neg,_I_ID_instruction(a5)
 lea neg_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _101111111111000000,a2
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_negx_b:
 moveq #'B',d0
 bra.s _negx
_negx_w:
 moveq #'W',d0
 bra.s _negx
_negx_l:
 moveq #'L',d0
_negx:
 move.w #ID_negx,_I_ID_instruction(a5)
 lea negx_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _101111111111000000,a2
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_not_b:
 moveq #'B',d0
 bra.s general_not
_not_w:
 moveq #'W',d0
 bra.s general_not
_not_l:
 moveq #'L',d0
general_not:
 move.w #ID_not,_I_ID_instruction(a5)
 lea not_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _101111111111000000,a2
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_tst_b:
 moveq #'B',d0
 bra.s general_tst
_tst_w:
 moveq #'W',d0
 bra.s general_tst
_tst_l:
 moveq #'L',d0
general_tst:
 move.w #ID_tst,_I_ID_instruction(a5)
 lea tst_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 IFNE _68020|68030
 lea _111111111111111111,a2
 ELSEIF
 lea _101111011111001111,a2
 ENDC ;_68020|68030
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

;  #] 0100:
;  #[ 0101:

; ADDQ*, DBcc*, Scc*, SUBQ*, TRAPcc*
_0101:
 move.w (a1),d1
 move.w d1,d0
 and.w #$f0ff,d0
 cmp.w #$50fa,d0
 beq _trapccw
 cmp.w #$50fb,d0
 beq _trapccl
 cmp.w #$50fc,d0
 beq _trapcc
 and.w #$f0f8,d0
 cmp.w #$50c8,d0
 beq _dbcc
 and.w #$f0c0,d0
 cmp.w #$50c0,d0
 beq _scc
 move.w d1,d0
 btst #8,d1
 beq _addq

_subq:
 move.w #ID_subq,_I_ID_instruction(a5)
 lea subq_dat,a2
internal_addq_subq:
 bsr Copy_String
 move.b d1,d0
 and.b #$c0,d0
 beq.s .byte
 bpl.s .word
 cmp.b #$80,d0
 bne Error_Disassemble_line
.long:
 lea _111111111111000000,a2
 move.b #'.',(a0)+
 moveq #'L',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w d1,d0
 rol.w #7,d0
 and.w #7,d0
 bne.s .not_8
 moveq #8,d0
 bra.s .not_8
.word:
 lea _111111111111000000,a2
 move.b #'.',(a0)+
 moveq #'W',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w d1,d0
 rol.w #7,d0
 and.w #7,d0
 bne.s .not_8
 moveq #8,d0
 bra.s .not_8
.byte:
 lea _101111111111000000,a2
 move.b #'.',(a0)+
 moveq #'B',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w d1,d0
 rol.w #7,d0
 and.w #7,d0
 bne.s .not_8
 moveq #8,d0
.not_8:
 bsr dat_to_asc_bu
 move.b #',',(a0)+
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_addq:
 move.w #ID_addq,_I_ID_instruction(a5)
 lea addq_dat,a2
 bra internal_addq_subq

_trapcc:
; tst.b disassembly_type(a6)
; beq Error_Disassemble_line
 move.w #ID_trapcc,_I_ID_instruction(a5)
 st _I_exc(a5)
 st _I_branchf(a5)
 lea trap_dat,a2
 bsr Copy_String
 move.w d1,d0
 lsr.w #8,d0
 and.w #$f,d0
 bsr cc_management
 bsr cc_test
 tst.w d0
 beq .1
 st _I_branchyn(a5)
.1:
 sub.l a2,a2
 lea $1c(a2),a2
 move.l a1,-(sp)
 move.l a2,a1
 bsr test_if_readable
 tst.l readable_buffer(a6)
 bne.s .error
 move.l (a1),d0
 move.l (sp)+,a1
 move.l d0,_I_branchaddr(a5)
 bra End_Disassemble_line
.error:
 move.l (sp)+,a1
 bra Error_Disassemble_line

_trapccw:
; tst.b disassembly_type(a6)
; beq Error_Disassemble_line
 move.w #ID_trapcc,_I_ID_instruction(a5)
 st _I_exc(a5)
 st _I_branchf(a5)
 move.w #4,_I_size(a5)
 lea trap_dat,a2
 bsr Copy_String
 move.w d1,d0
 lsr.w #8,d0
 and.w #$f,d0
 bsr cc_management
 bsr cc_test
 tst.w d0
 beq.s .1
 st _I_branchyn(a5)
.1:
 sub.l a2,a2
 lea $1c(a2),a2
 move.l a1,-(sp)
 move.l a2,a1
 bsr test_if_readable
 tst.l readable_buffer(a6)
 bne.s .error
 move.l (a1),d0
 move.l (sp)+,a1
 move.l d0,_I_branchaddr(a5)
 move.b #'.',(a0)+
 moveq #'W',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w 2(a1),d0
 bsr dat_to_asc_wu
 bra End_Disassemble_line
.error:
 move.l (sp)+,a1
 bra Error_Disassemble_line

_trapccl:
; tst.b disassembly_type(a6)
; beq Error_Disassemble_line
 move.w #ID_trapcc,_I_ID_instruction(a5)
 st _I_exc(a5)
 move.w #6,_I_size(a5)
 st _I_branchf(a5)
 lea trap_dat,a2
 bsr Copy_String
 move.w d1,d0
 lsr.w #8,d0
 and.w #$f,d0
 bsr cc_management
 bsr cc_test
 tst.w d0
 beq.s .1
 st _I_branchyn(a5)
.1:
 sub.l a2,a2
 lea $1c(a2),a2
 move.l a1,-(sp)
 move.l a2,a1
 bsr test_if_readable
 tst.l readable_buffer(a6)
 bne.s .error
 move.l (a1),d0
 move.l (sp)+,a1
 move.l d0,_I_branchaddr(a5)
 move.b #'.',(a0)+
 moveq #'L',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.l 2(a1),d0
 bsr dat_to_asc_lu
 bra End_Disassemble_line
.error:
 move.l (sp)+,a1
 bra Error_Disassemble_line

_dbcc:
 move.w #ID_dbcc,_I_ID_instruction(a5)
 st _I_branchf(a5)
 move.w #1,_I_sourceformat(a5)
 lea dbcc_dat,a2
 bsr Copy_String
 move.w d1,d0
 lsr.w #8,d0
 and.w #$f,d0
 bsr cc_management
 bsr dbcc_test
 tst.w d0
 beq.s .1
 st _I_branchyn(a5)
.1:
 move.b #' ',(a0)+
 and.w #7,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w 2(a1),d0
 ext.l d0
 add.l test_instruction(a6),d0
 addq.l #2,d0
 move.l d0,_I_branchaddr(a5)
 move.l d0,_I_sourceaddr(a5)
 tst.b _I_branchyn(a5)
 beq.s .2
 bsr modify_arrow
.2:
 cmp.l test_instruction(a6),d0
 bne.s .notpc
 move.b #'*',(a0)+
 bra.s .end
.notpc:
 bsr addr_to_asc_lu
.end:
 addq.w #2,_I_size(a5)
 bra End_Disassemble_line

_scc:
 move.w #ID_scc,_I_ID_instruction(a5)
 lea scc_dat,a2
 bsr Copy_String
 move.w d1,d0
 lsr.w #8,d0
 and.w #$f,d0
 bsr cc_management
 move.b #' ',(a0)+
 lea _101111111111000000,a2
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

cc_management:
 lea condition_codes_dat,a2
 move.w d0,-(sp)
 mulu #3,d0
 add.w d0,a2
 move.w (sp)+,d0
 bsr Copy_String
 rts

cc_test:
 movem.l d1-d2,-(sp)
 move.w d0,d2
 move.w sr_buf(a6),d1
 lsl.w #2,d2
 moveq #0,d0
 jsr internal_cc_test(pc,d2.w)
 movem.l (sp)+,d1-d2
 rts

 _NOOPTI
internal_cc_test:
 bra .t_arrow
 bra .f_arrow
 bra .hi_arrow
 bra .ls_arrow
 bra .cc_arrow
 bra .cs_arrow
 bra .ne_arrow
 bra .eq_arrow
 bra .vc_arrow
 bra .vs_arrow
 bra .pl_arrow
 bra .mi_arrow
 bra .ge_arrow
 bra .lt_arrow
 bra .gt_arrow
 bra .le_arrow
 _OPTI

.t_arrow:
.done:
 moveq #-1,d0
.f_arrow:
 rts
.hi_arrow:
 btst #_C,d1
 bne.s .end
 btst #_Z,d1
 beq .done
.end:
 rts
.ls_arrow:
 btst #_C,d1
 bne .done
 btst #_Z,d1
 bne.s .done
 rts
.cc_arrow:
 btst #_C,d1
 beq.s .done
 rts
.cs_arrow:
 btst #_C,d1
 bne.s .done
 rts
.ne_arrow:
 btst #_Z,d1
 beq.s .done
 rts
.eq_arrow:
 btst #_Z,d1
 bne.s .done
 rts
.vc_arrow:
 btst #_V,d1
 beq.s .done
 rts
.vs_arrow:
 btst #_V,d1
 bne.s .done
 rts
.pl_arrow:
 btst #_N,d1
 beq.s .done
 rts
.mi_arrow:
 btst #_N,d1
 bne.s .done
 rts
.ge_arrow:
 btst #_V,d1
 beq.s .ge_1
 btst #_N,d1
 bne.s .done
 rts
.ge_1:
 btst #_N,d1
 beq.s .done
 rts
.lt_arrow:
 btst #_V,d1
 beq.s .lt_1
 btst #_N,d1
 beq .done
 rts
.lt_1:
 btst #_N,d1
 bne .done
 rts
.gt_arrow:
 btst #_Z,d1
 beq .ge_arrow
 rts
.le_arrow:
 btst #_Z,d1
 beq .lt_arrow
 bra .done

dbcc_test:
 tst.w d0
 beq.s .true
 cmp.w #1,d0
 beq.s .false
 bsr cc_test
 not.l d0
 rts
.true:
 move.l a2,-(sp)
 move.w (a1),d0
 and.w #7,d0
 add.w d0,d0
 add.w d0,d0
 lea d0_buf(a6),a2
 tst.l 0(a2,d0.w)
 bne.s .branch_not_taken
 bra.s .branch_taken
.false:
 move.l a2,-(sp)
 move.w (a1),d0
 and.w #7,d0
 add.w d0,d0
 add.w d0,d0
 lea d0_buf(a6),a2
 tst.l 0(a2,d0.w)
 beq.s .branch_not_taken
.branch_taken:
 move.l (sp)+,a2
 moveq #-1,d0
 rts
.branch_not_taken:
 move.l (sp)+,a2
 moveq #0,d0
 rts

;  #] 0101:
;  #[ 0110:

; Bcc*, BRA*, BSR*
_0110:
 move.w (a1),d1
 move.w d1,d0
 rol.w #8,d0
 cmp.b #$60,d0
 beq _bra
 cmp.b #$61,d0
 beq _bsr
_bcc:
 move.w #ID_bcc,_I_ID_instruction(a5)
 st _I_branchf(a5)
 lea bcc_dat,a2
 bsr Copy_String
 and.w #$f,d0
 bsr cc_management
 bsr cc_test
 tst.w d0
 beq.s internal_bxx
 st _I_branchyn(a5)
internal_bxx:
 move.w #1,_I_sourceformat(a5)
 tst.b d1
 beq.s .16_bits
 cmp.b #-1,d1
 beq .32_bits
.8_bits:
 move.b #'.',(a0)+
 moveq #'B',d0
 move.w d0,_I_format(a5)
 IFEQ _68020!_68030
 move.b #'S',(a0)+
 ELSEIF
 move.b d0,(a0)+
 ENDC
 move.b #' ',(a0)+
 ext.w d1
 ext.l d1
 add.l test_instruction(a6),d1
 addq.l #2,d1
 move.l d1,d0
 move.l d0,_I_branchaddr(a5)
 move.l d0,_I_sourceaddr(a5)
 tst.b _I_branchyn(a5)
 beq.s .no_8bits_branch
 bsr modify_arrow
.no_8bits_branch:
 cmp.l test_instruction(a6),d0
 bne.s .notpc8
.onpc:
 move.b #'*',(a0)+
 bra End_Disassemble_line
.notpc8:
 bsr addr_to_asc_lu
 bra End_Disassemble_line
.16_bits:
 move.w #4,_I_size(a5)
 move.b #' ',(a0)+
 move.w 2(a1),d1
 ext.l d1
 add.l test_instruction(a6),d1
 addq.l #2,d1
 move.l d1,d0
 move.l d0,_I_branchaddr(a5)
 tst.b _I_branchyn(a5)
 beq.s .no_16bits_branch
 bsr modify_arrow
.no_16bits_branch:
 cmp.l test_instruction(a6),d0
 beq.s .onpc
 bsr addr_to_asc_lu
 bra End_Disassemble_line
.32_bits:
 move.w #6,_I_size(a5)
 move.b #'.',(a0)+
 moveq #'L',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.l 2(a1),d1
 add.l test_instruction(a6),d1
 addq.l #2,d1
 move.l d1,d0
 move.l d0,_I_branchaddr(a5)
 tst.b _I_branchyn(a5)
 beq.s .no_32bits_branch
 bsr modify_arrow
.no_32bits_branch:
 cmp.l test_instruction(a6),d0
 beq.s .onpc
 bsr addr_to_asc_lu
 bra End_Disassemble_line

_bra:
 move.w #ID_bra,_I_ID_instruction(a5)
 st _I_branchf(a5)
 st _I_branchyn(a5)
 lea bra_dat,a2
 bsr Copy_String
 bra internal_bxx

_bsr:
 move.w #ID_bsr,_I_ID_instruction(a5)
 st _I_branchf(a5)
 st _I_branchyn(a5)
 lea bsr_dat,a2
 bsr Copy_String
 bra internal_bxx

;  #] 0110:
;  #[ 0111:

; MOVEQ*
_0111:
 move.w #ID_moveq,_I_ID_instruction(a5)
 move.w (a1),d1
 move.w d1,d0
 and.w #$f100,d0
 cmp.w #$7000,d0
 bne Error_Disassemble_line
 lea moveq_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 move.b d1,d0
 bsr dat_to_asc_bs
 move.b #',',(a0)+
 rol.w #7,d1
 and.w #7,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

;  #] 0111:
;  #[ 1000:

; DIVS (w)*, DIVU (w)*, OR*, PACK*, SBCD*, UNPK*
_1000:
 move.w (a1),d1
 move.w d1,d0
 and.w #$f1c0,d0
 cmp.w #$80c0,d0
 beq _divu_w
 cmp.w #$81c0,d0
 beq _divs_w
 move.w d1,d0
 and.w #$f1f8,d0
 cmp.w #$8100,d0
 beq _sbcd_dx
 cmp.w #$8108,d0
 beq _sbcd_addr

 IFNE _68020!_68030
 cmp.w #$8140,d0
 beq _pack_dx
 cmp.w #$8148,d0
 beq _pack_addr
 cmp.w #$8180,d0
 beq _unpk_dx
 cmp.w #$8188,d0
 beq _unpk_addr
 ENDC

 and.w #$f1c0,d0
 cmp.w #$8000,d0
 beq _or_ea_dn_b
 cmp.w #$8040,d0
 beq _or_ea_dn_w
 cmp.w #$8080,d0
 beq _or_ea_dn_l
 cmp.w #$8100,d0
 beq _or_dn_ea_b
 cmp.w #$8140,d0
 beq _or_dn_ea_w
 cmp.w #$8180,d0
 beq _or_dn_ea_l
 bra Error_Disassemble_line

_or_ea_dn_b:
 move.w #ID_or,_I_ID_instruction(a5)
 lea or_dat,a2
 moveq #'B',d0
 bra.s general_ea_dn

_or_ea_dn_w:
 move.w #ID_or,_I_ID_instruction(a5)
 lea or_dat,a2
 moveq #'W',d0
 bra.s general_ea_dn

_or_ea_dn_l:
 move.w #ID_or,_I_ID_instruction(a5)
 lea or_dat,a2
 moveq #'L',d0
 bra.s general_ea_dn

_or_dn_ea_b:
 move.w #ID_or,_I_ID_instruction(a5)
 lea _001111111111000000,a2
 move.l a2,-(sp)
 lea or_dat,a2
 moveq #'B',d0
 bra.s general_dn_ea

_or_dn_ea_w:
 move.w #ID_or,_I_ID_instruction(a5)
 lea _001111111111000000,a2
 move.l a2,-(sp)
 lea or_dat,a2
 moveq #'W',d0
 bra.s general_dn_ea

_or_dn_ea_l:
 move.w #ID_or,_I_ID_instruction(a5)
 lea _001111111111000000,a2
 move.l a2,-(sp)
 lea or_dat,a2
 moveq #'L',d0
 bra.s general_dn_ea

general_ea_dn:
 bsr Copy_String
 move.b #'.',(a0)+
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _101111111111111111,a2
 move.w (a1),d1
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

general_dn_ea:
 bsr Copy_String
 move.b #'.',(a0)+
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.l (sp)+,a2
 move.w (a1),d1
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_divs_w:
 move.w #ID_divs,_I_ID_instruction(a5)
 lea divs_dat,a2
 bra.s _div_w
_divu_w:
 move.w #ID_divu,_I_ID_instruction(a5)
 lea divu_dat,a2
_div_w:
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'W',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _101111111111111111,a2
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_sbcd_dx:
 move.w #ID_sbcd,_I_ID_instruction(a5)
 lea sbcd_dat,a2
 bsr xbcd_dx
 bra End_Disassemble_line

_sbcd_addr:
 move.w #ID_sbcd,_I_ID_instruction(a5)
 lea sbcd_dat,a2
 bsr xbcd_addr
 bra End_Disassemble_line

 IFNE _68020!_68030
_pack_dx:
 move.w #ID_pack,_I_ID_instruction(a5)
 move.w #4,_I_size(a5)
 lea pack_dat,a2
 bsr xbcd_dx
 move.b #',',(a0)+
 move.w 2(a1),d1
 move.w d1,d0
 bsr dat_to_asc_wu
 bra End_Disassemble_line

_pack_addr:
 move.w #ID_pack,_I_ID_instruction(a5)
 move.w #4,_I_size(a5)
 lea pack_dat,a2
 bsr xbcd_addr
 move.b #',',(a0)+
 move.w 2(a1),d1
 move.w d1,d0
 bsr dat_to_asc_wu
 bra End_Disassemble_line
 ENDC

 IFNE _68020!_68030
_unpk_dx:
 move.w #ID_unpk,_I_ID_instruction(a5)
 move.w #4,_I_size(a5)
 lea unpk_dat,a2
 bsr xbcd_dx
 move.b #',',(a0)+
 move.w 2(a1),d1
 move.w d1,d0
 bsr dat_to_asc_wu
 bra End_Disassemble_line

_unpk_addr:
 move.w #ID_unpk,_I_ID_instruction(a5)
 move.w #4,_I_size(a5)
 lea unpk_dat,a2
 bsr xbcd_addr
 move.b #',',(a0)+
 move.w 2(a1),d1
 move.w d1,d0
 bsr dat_to_asc_wu
 bra End_Disassemble_line
 ENDC

;  #] 1000:
;  #[ 1001:

; SUB*, SUBA*, SUBX*
_1001:
 move.w (a1),d1
 move.w d1,d0
 and.w #$f1f0,d0
 cmp.w #$9100,d0
 beq _subx_b
 cmp.w #$9140,d0
 beq _subx_w
 cmp.w #$9180,d0
 beq _subx_l
 and.w #$f1c0,d0
 cmp.w #$9000,d0
 beq sub_b_ea_dn
 cmp.w #$9040,d0
 beq sub_w_ea_dn
 cmp.w #$9080,d0
 beq sub_l_ea_dn
 cmp.w #$9100,d0
 beq sub_b_dn_ea
 cmp.w #$9140,d0
 beq sub_w_dn_ea
 cmp.w #$9180,d0
 beq sub_l_dn_ea
 cmp.w #$90c0,d0
 beq _suba_w
 cmp.w #$91c0,d0
 beq _suba_l
 bra Error_Disassemble_line

_suba_w:
 move.w #ID_suba,_I_ID_instruction(a5)
 moveq #'W',d0
 lea suba_dat,a2
 bra.s internal_a
_suba_l:
 move.w #ID_suba,_I_ID_instruction(a5)
 moveq #'L',d0
 lea suba_dat,a2
internal_a:
 move.w d0,_I_format(a5)
 bsr Copy_String
 move.b #'.',(a0)+
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _111111111111111111,a2
 move.w (a1),d1
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 or.w #8,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

sub_b_ea_dn:
 move.w #ID_sub,_I_ID_instruction(a5)
 move.w #'B',-(sp)
 lea sub_dat,a2
 move.l a2,d0
 lea _101111111111111111,a2
 bra.s internal_ea_dn
sub_w_ea_dn:
 move.w #ID_sub,_I_ID_instruction(a5)
 move.w #'W',-(sp)
 lea sub_dat,a2
 move.l a2,d0
 lea _111111111111111111,a2
 bra.s internal_ea_dn
sub_l_ea_dn:
 move.w #ID_sub,_I_ID_instruction(a5)
 move.w #'L',-(sp)
 lea sub_dat,a2
 move.l a2,d0
 lea _111111111111111111,a2
internal_ea_dn:
 move.l a2,-(sp)
 move.l d0,a2
 bsr Copy_String
 move.l (sp)+,a2
 move.b #'.',(a0)+
 move.w (sp)+,d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w (a1),d1
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

sub_b_dn_ea:
 move.w #ID_sub,_I_ID_instruction(a5)
 move.w #'B',-(sp)
 lea sub_dat,a2
 move.l a2,d0
 lea _001111111111000000,a2
 bra.s internal_dn_ea
sub_w_dn_ea:
 move.w #ID_sub,_I_ID_instruction(a5)
 move.w #'W',-(sp)
 lea sub_dat,a2
 move.l a2,d0
 lea _001111111111000000,a2
 bra.s internal_dn_ea
sub_l_dn_ea:
 move.w #ID_sub,_I_ID_instruction(a5)
 move.w #'L',-(sp)
 lea sub_dat,a2
 move.l a2,d0
 lea _001111111111000000,a2
internal_dn_ea:
 move.l a2,-(sp)
 move.l d0,a2
 bsr Copy_String
 move.l (sp)+,a2
 move.b #'.',(a0)+
 move.w (sp)+,d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 rol.w #7,d1
 and.w #7,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w (a1),d1
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_subx_b:
 moveq #'B',d0
 bra.s _subx
_subx_w:
 moveq #'W',d0
 bra.s _subx
_subx_l:
 moveq #'L',d0
_subx:
 move.w #ID_subx,_I_ID_instruction(a5)
 lea subx_dat,a2
 bra internal_x

;  #] 1001:
;  #[ 1010:

; DC.W
_1010:
 bsr Dc_w
 IFNE	ATARIST
 moveq #0,d0
 move.w (a1),d0
 cmp.l #$a000,d0
 blt.s .no_comment
 cmp.l #$a00f,d0
 bgt.s .no_comment
 sub.w #$a000,d0
 add.w d0,d0
 add.w d0,d0
 lea _internal_linea_table(pc),a2
 move.l 0(a2,d0.w),_I_Comment(a5)
.no_comment:
 ENDC	;d'ATARIST
 bra End_Disassemble_line

 IFNE	ATARIST
_internal_linea_table:
 dc.l .init
 dc.l .putpix
 dc.l .getpix
 dc.l .abline
 dc.l .hebline
 dc.l .rectfill
 dc.l .polyfill
 dc.l .bitblt
 dc.l .textblt
 dc.l .showcur
 dc.l .hidecur
 dc.l .chgcur
 dc.l .drsprite
 dc.l .unsprite
 dc.l .copystr
 dc.l .seedfill

.linea_messages:
.init:
 dc.b 'INIT',0
.putpix:
 dc.b 'PUTPIX',0
.getpix:
 dc.b 'GETPIX',0
.abline:
 dc.b 'ABLINE',0
.hebline:
 dc.b 'HABLINE',0
.rectfill:
 dc.b 'RECTFILL',0
.polyfill:
 dc.b 'POLYFILL',0
.bitblt:
 dc.b 'BITBLT',0
.textblt:
 dc.b 'TEXTBLT',0
.showcur:
 dc.b 'SHOWCUR',0
.hidecur:
 dc.b 'HIDECUR',0
.chgcur:
 dc.b 'CHGCUR',0
.drsprite:
 dc.b 'DRSPRITE',0
.unsprite:
 dc.b 'UNSPRITE',0
.copystr:
 dc.b 'COPYSTR',0
.seedfill:
 dc.b 'SEEDFILL',0
 ENDC	;d'ATARIST
 even

;  #] 1010:
;  #[ 1011:

; CMP*, CMPA*, CMPM*, EOR*
_1011:
 move.w (a1),d1
 move.w d1,d0
 and.w #$f1f8,d0
 cmp.w #$b108,d0
 beq _cmpm_b
 cmp.w #$b148,d0
 beq _cmpm_w
 cmp.w #$b188,d0
 beq _cmpm_l
 and.w #$f1c0,d0
 cmp.w #$b000,d0
 beq _cmp_b
 cmp.w #$b040,d0
 beq _cmp_w
 cmp.w #$b080,d0
 beq _cmp_l
 cmp.w #$b0c0,d0
 beq _cmpa_w
 cmp.w #$b100,d0
 beq _eor_dn_ea_b
 cmp.w #$b140,d0
 beq _eor_dn_ea_w
 cmp.w #$b180,d0
 beq _eor_dn_ea_l
 cmp.w #$b1c0,d0
 beq _cmpa_l
 bra Error_Disassemble_line

_cmpm_b:
 moveq #'B',d0
 bra.s general_cmpm
_cmpm_w:
 moveq #'W',d0
 bra.s general_cmpm
_cmpm_l:
 moveq #'L',d0
general_cmpm:
 move.w #ID_cmpm,_I_ID_instruction(a5)
 lea cmpm_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w (a1),d1
 and.w #7,d1
 or.w #$18,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 or.w #$18,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_cmp_b:
 moveq #'B',d0
 lea _101111111111111111,a2
 bra.s general_cmp
_cmp_w:
 moveq #'W',d0
 lea _111111111111111111,a2
 bra.s general_cmp
_cmp_l:
 moveq #'L',d0
 lea _111111111111111111,a2
general_cmp:
 move.w #ID_cmp,_I_ID_instruction(a5)
 move.l a2,-(sp)
 lea cmp_dat,a2
 bsr Copy_String
 move.l (sp)+,a2
 move.b #'.',(a0)+
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_cmpa_w:
 moveq #'W',d0
 bra.s general_cmpa
_cmpa_l:
 moveq #'L',d0
general_cmpa:
 move.w #ID_cmpa,_I_ID_instruction(a5)
 lea cmpa_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _111111111111111111,a2
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 or.w #8,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_eor_dn_ea_b:
 move.w #ID_eor,_I_ID_instruction(a5)
 lea _101111111111000000,a2
 move.l a2,-(sp)
 lea eor_dat,a2
 moveq #'B',d0
 bra general_dn_ea

_eor_dn_ea_w:
 move.w #ID_eor,_I_ID_instruction(a5)
 lea _101111111111000000,a2
 move.l a2,-(sp)
 lea eor_dat,a2
 moveq #'W',d0
 bra general_dn_ea

_eor_dn_ea_l:
 move.w #ID_eor,_I_ID_instruction(a5)
 lea _101111111111000000,a2
 move.l a2,-(sp)
 lea eor_dat,a2
 moveq #'L',d0
 bra general_dn_ea

;  #] 1011:
;  #[ 1100:

; ABCD*, AND*, EXG*, MULS (w)*, MULU (w)*
_1100:
 move.w (a1),d1
 move.w d1,d0
 and.w #$f1f8,d0
 cmp.w #$c140,d0
 beq _exg_dat_dat
 cmp.w #$c148,d0
 beq _exg_addr_addr
 cmp.w #$c188,d0
 beq _exg_dat_addr
 move.w d1,d0
 and.w #$f1f8,d0
 cmp.w #$c100,d0
 beq.s _abcd_dx
 cmp.w #$c108,d0
 beq _abcd_addr
 move.w d1,d0
 and.w #$f1c0,d0
 cmp.w #$c1c0,d0
 beq _muls_w
 cmp.w #$c0c0,d0
 beq _mulu_w
 cmp.w #$c000,d0
 beq _and_ea_dn_b
 cmp.w #$c040,d0
 beq _and_ea_dn_w
 cmp.w #$c080,d0
 beq _and_ea_dn_l
 cmp.w #$c100,d0
 beq _and_dn_ea_b
 cmp.w #$c140,d0
 beq _and_dn_ea_w
 cmp.w #$c180,d0
 beq _and_dn_ea_l
 bra Error_Disassemble_line

_abcd_dx:
 move.w #ID_abcd,_I_ID_instruction(a5)
 lea abcd_dat,a2
 bsr xbcd_dx
 bra End_Disassemble_line

xbcd_dx:
 bsr Copy_String
 move.b #' ',(a0)+
 and.w #7,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 bsr Force_Mode_Register
 rts

_abcd_addr:
 move.w #ID_abcd,_I_ID_instruction(a5)
 lea abcd_dat,a2
 bsr xbcd_addr
 bra End_Disassemble_line

xbcd_addr:
 bsr Copy_String
 move.b #' ',(a0)+
 and.w #7,d1
 or.w #$20,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 or.w #$20,d1
 bsr Force_Mode_Register
 rts

_and_ea_dn_b:
 move.w #ID_and,_I_ID_instruction(a5)
 lea and_dat,a2
 moveq #'B',d0
 bra general_ea_dn

_and_ea_dn_w:
 move.w #ID_and,_I_ID_instruction(a5)
 lea and_dat,a2
 moveq #'W',d0
 bra general_ea_dn

_and_ea_dn_l:
 move.w #ID_and,_I_ID_instruction(a5)
 lea and_dat,a2
 moveq #'L',d0
 bra general_ea_dn

_and_dn_ea_b:
 move.w #ID_and,_I_ID_instruction(a5)
 lea _001111111111000000,a2
 move.l a2,-(sp)
 lea and_dat,a2
 moveq #'B',d0
 bra general_dn_ea

_and_dn_ea_w:
 move.w #ID_and,_I_ID_instruction(a5)
 lea _001111111111000000,a2
 move.l a2,-(sp)
 lea and_dat,a2
 moveq #'W',d0
 bra general_dn_ea

_and_dn_ea_l:
 move.w #ID_and,_I_ID_instruction(a5)
 lea _001111111111000000,a2
 move.l a2,-(sp)
 lea and_dat,a2
 moveq #'L',d0
 bra general_dn_ea

_exg_dat_dat:
 move.w #ID_exg,_I_ID_instruction(a5)
 lea exg_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 rol.w #7,d1
 and.w #7,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w (a1),d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_exg_addr_addr:
 move.w #ID_exg,_I_ID_instruction(a5)
 lea exg_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 rol.w #7,d1
 and.w #7,d1
 or.b #8,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w (a1),d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_exg_dat_addr:
 move.w #ID_exg,_I_ID_instruction(a5)
 lea exg_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 rol.w #7,d1
 and.w #7,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w (a1),d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_muls_w:
 move.w #ID_muls,_I_ID_instruction(a5)
 lea muls_dat,a2
 bra.s _mul_w
_mulu_w:
 move.w #ID_mulu,_I_ID_instruction(a5)
 lea mulu_dat,a2
_mul_w:
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'W',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _101111111111111111,a2
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

;  #] 1100:
;  #[ 1101:

; ADD*, ADDA*, ADDX*
_1101:
 move.w (a1),d1
 move.w d1,d0
 and.w #$f1f0,d0
 cmp.w #$d100,d0
 beq _addx_b
 cmp.w #$d140,d0
 beq _addx_w
 cmp.w #$d180,d0
 beq _addx_l
 move.w d1,d0
 and.w #$f1c0,d0
 cmp.w #$d000,d0
 beq add_b_ea_dn
 cmp.w #$d040,d0
 beq add_w_ea_dn
 cmp.w #$d080,d0
 beq add_l_ea_dn
 cmp.w #$d100,d0
 beq add_b_dn_ea
 cmp.w #$d140,d0
 beq add_w_dn_ea
 cmp.w #$d180,d0
 beq add_l_dn_ea
 cmp.w #$d0c0,d0
 beq _adda_w
 cmp.w #$d1c0,d0
 beq _adda_l
 bra Error_Disassemble_line

add_b_ea_dn:
 move.w #ID_add,_I_ID_instruction(a5)
 move.w #'B',-(sp)
 lea add_dat,a2
 move.l a2,d0
 lea _101111111111111111,a2
 bra internal_ea_dn
add_w_ea_dn:
 move.w #ID_add,_I_ID_instruction(a5)
 move.w #'W',-(sp)
 lea add_dat,a2
 move.l a2,d0
 lea _111111111111111111,a2
 bra internal_ea_dn
add_l_ea_dn:
 move.w #ID_add,_I_ID_instruction(a5)
 move.w #'L',-(sp)
 lea add_dat,a2
 move.l a2,d0
 lea _111111111111111111,a2
 bra internal_ea_dn
add_b_dn_ea:
 move.w #ID_add,_I_ID_instruction(a5)
 move.w #'B',-(sp)
 lea add_dat,a2
 move.l a2,d0
 lea _001111111111000000,a2
 bra internal_dn_ea
add_w_dn_ea:
 move.w #ID_add,_I_ID_instruction(a5)
 move.w #'W',-(sp)
 lea add_dat,a2
 move.l a2,d0
 lea _001111111111000000,a2
 bra internal_dn_ea
add_l_dn_ea:
 move.w #ID_add,_I_ID_instruction(a5)
 move.w #'L',-(sp)
 lea add_dat,a2
 move.l a2,d0
 lea _001111111111000000,a2
 bra internal_dn_ea

_adda_w:
 move.w #ID_adda,_I_ID_instruction(a5)
 moveq #'W',d0
 lea adda_dat,a2
 bra internal_a
_adda_l:
 move.w #ID_adda,_I_ID_instruction(a5)
 moveq #'L',d0
 lea adda_dat,a2
 bra internal_a

_addx_b:
 move.w #ID_addx,_I_ID_instruction(a5)
 moveq #'B',d0
 bra.s _addx
_addx_w:
 move.w #ID_addx,_I_ID_instruction(a5)
 moveq #'W',d0
 bra.s _addx
_addx_l:
 move.w #ID_addx,_I_ID_instruction(a5)
 moveq #'L',d0
_addx:
 lea addx_dat,a2
internal_x:
 bsr Copy_String
 move.b #'.',(a0)+
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 btst #3,d1
 bne.s .addr
.data:
 and.w #7,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line
.addr:
 and.w #7,d1
 or.w #$20,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w (a1),d1
 rol.w #7,d1
 and.w #7,d1
 or.w #$20,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

;  #] 1101:
;  #[ 1110:

; ASL*, ASR*, BFCHG*, BFCLR*, BFEXTS*, BFEXTU*, BFFFO*, BFINS*, BFSET*
; BFTST*, LSL*, LSR*, ROL*, ROR*, ROXL*, ROXR*
_1110:
 move.w (a1),d1
 move.w d1,d0
 and.w #$f1d8,d0
 cmp.w #$e000,d0
 beq _asr_b
 cmp.w #$e040,d0
 beq _asr_w
 cmp.w #$e080,d0
 beq _asr_l
 cmp.w #$e100,d0
 beq _asl_b
 cmp.w #$e140,d0
 beq _asl_w
 cmp.w #$e180,d0
 beq _asl_l
 cmp.w #$e008,d0
 beq _lsr_b
 cmp.w #$e048,d0
 beq _lsr_w
 cmp.w #$e088,d0
 beq _lsr_l
 cmp.w #$e108,d0
 beq _lsl_b
 cmp.w #$e148,d0
 beq _lsl_w
 cmp.w #$e188,d0
 beq _lsl_l
 cmp.w #$e010,d0
 beq _roxr_b
 cmp.w #$e050,d0
 beq _roxr_w
 cmp.w #$e090,d0
 beq _roxr_l
 cmp.w #$e110,d0
 beq _roxl_b
 cmp.w #$e150,d0
 beq _roxl_w
 cmp.w #$e190,d0
 beq _roxl_l
 cmp.w #$e018,d0
 beq _ror_b
 cmp.w #$e058,d0
 beq _ror_w
 cmp.w #$e098,d0
 beq _ror_l
 cmp.w #$e118,d0
 beq _rol_b
 cmp.w #$e158,d0
 beq _rol_w
 cmp.w #$e198,d0
 beq _rol_l
 move.w d1,d0
 and.w #$ffc0,d0
 cmp.w #$e0c0,d0
 beq _asr_ea
 cmp.w #$e1c0,d0
 beq _asl_ea
 cmp.w #$e2c0,d0
 beq _lsr_ea
 cmp.w #$e3c0,d0
 beq _lsl_ea
 cmp.w #$e4c0,d0
 beq _roxr_ea
 cmp.w #$e5c0,d0
 beq _roxl_ea
 cmp.w #$e6c0,d0
 beq _ror_ea
 cmp.w #$e7c0,d0
 beq _rol_ea

 IFNE _68020!_68030
 move.w d1,d0
 and.w #$ffc0,d0
 cmp.w #$e8c0,d0
 beq _bftst
 cmp.w #$e9c0,d0
 beq _bfextu
 cmp.w #$eac0,d0
 beq _bfchg
 cmp.w #$ebc0,d0
 beq _bfexts
 cmp.w #$ecc0,d0
 beq _bfclr
 cmp.w #$edc0,d0
 beq _bfffo
 cmp.w #$eec0,d0
 beq _bfset
 cmp.w #$efc0,d0
 beq _bfins
 ENDC

 bra Error_Disassemble_line

_asr_b:
 move.w #ID_asr,_I_ID_instruction(a5)
 moveq #'B',d0
 lea asr_dat,a2
 bra general_sft

_asr_w:
 move.w #ID_asr,_I_ID_instruction(a5)
 moveq #'W',d0
 lea asr_dat,a2
 bra general_sft

_asr_l:
 move.w #ID_asr,_I_ID_instruction(a5)
 moveq #'L',d0
 lea asr_dat,a2
 bra general_sft

_asl_b:
 move.w #ID_asl,_I_ID_instruction(a5)
 moveq #'B',d0
 lea asl_dat,a2
 bra general_sft

_asl_w:
 move.w #ID_asl,_I_ID_instruction(a5)
 moveq #'W',d0
 lea asl_dat,a2
 bra general_sft

_asl_l:
 move.w #ID_asl,_I_ID_instruction(a5)
 moveq #'L',d0
 lea asl_dat,a2
 bra general_sft

_lsr_b:
 move.w #ID_lsr,_I_ID_instruction(a5)
 moveq #'B',d0
 lea lsr_dat,a2
 bra general_sft

_lsr_w:
 move.w #ID_lsr,_I_ID_instruction(a5)
 moveq #'W',d0
 lea lsr_dat,a2
 bra general_sft

_lsr_l:
 move.w #ID_lsr,_I_ID_instruction(a5)
 moveq #'L',d0
 lea lsr_dat,a2
 bra general_sft

_lsl_b:
 move.w #ID_lsl,_I_ID_instruction(a5)
 moveq #'B',d0
 lea lsl_dat,a2
 bra general_sft

_lsl_w:
 move.w #ID_lsl,_I_ID_instruction(a5)
 moveq #'W',d0
 lea lsl_dat,a2
 bra general_sft

_lsl_l:
 move.w #ID_lsl,_I_ID_instruction(a5)
 moveq #'L',d0
 lea lsl_dat,a2
 bra general_sft

_roxr_b:
 move.w #ID_roxr,_I_ID_instruction(a5)
 moveq #'B',d0
 lea roxr_dat,a2
 bra general_sft

_roxr_w:
 move.w #ID_roxr,_I_ID_instruction(a5)
 moveq #'W',d0
 lea roxr_dat,a2
 bra general_sft

_roxr_l:
 move.w #ID_roxr,_I_ID_instruction(a5)
 moveq #'L',d0
 lea roxr_dat,a2
 bra general_sft

_roxl_b:
 move.w #ID_roxl,_I_ID_instruction(a5)
 moveq #'B',d0
 lea roxl_dat,a2
 bra general_sft

_roxl_w:
 move.w #ID_roxl,_I_ID_instruction(a5)
 moveq #'W',d0
 lea roxl_dat,a2
 bra general_sft

_roxl_l:
 move.w #ID_roxl,_I_ID_instruction(a5)
 moveq #'L',d0
 lea roxl_dat,a2
 bra general_sft

_ror_b:
 move.w #ID_ror,_I_ID_instruction(a5)
 moveq #'B',d0
 lea ror_dat,a2
 bra general_sft

_ror_w:
 move.w #ID_ror,_I_ID_instruction(a5)
 moveq #'W',d0
 lea ror_dat,a2
 bra general_sft

_ror_l:
 move.w #ID_ror,_I_ID_instruction(a5)
 moveq #'L',d0
 lea ror_dat,a2
 bra general_sft

_rol_b:
 move.w #ID_rol,_I_ID_instruction(a5)
 moveq #'B',d0
 lea rol_dat,a2
 bra general_sft

_rol_w:
 move.w #ID_rol,_I_ID_instruction(a5)
 moveq #'W',d0
 lea rol_dat,a2
 bra general_sft

_rol_l:
 move.w #ID_rol,_I_ID_instruction(a5)
 moveq #'L',d0
 lea rol_dat,a2
 bra general_sft

general_sft:
 bsr Copy_String
 move.b #'.',(a0)+
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w d1,d0
 rol.w #7,d0
 btst #5,d1
 bne.s .data_reg
.immediate:
 and.w #7,d0
 bne.s .not_8
 moveq #8,d0
.not_8:
 bsr dat_to_asc_bu
 bra.s .1
.data_reg:
 move.b #'D',(a0)+
 and.w #7,d0
 add.b #'0',d0
 move.b d0,(a0)+
.1:
 move.b #',',(a0)+
 and.w #7,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_asl_ea:
 move.w #ID_asl,_I_ID_instruction(a5)
 lea asl_dat,a2
 bra.s internal_sft_ea

_asr_ea:
 move.w #ID_asr,_I_ID_instruction(a5)
 lea asr_dat,a2
internal_sft_ea:
 bsr Copy_String
 move.b #' ',(a0)+
 lea _001111111111000000,a2
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_lsl_ea:
 move.w #ID_lsl,_I_ID_instruction(a5)
 lea lsl_dat,a2
 bra.s internal_sft_ea

_lsr_ea:
 move.w #ID_lsr,_I_ID_instruction(a5)
 lea lsr_dat,a2
 bra.s internal_sft_ea

_rol_ea:
 move.w #ID_rol,_I_ID_instruction(a5)
 lea rol_dat,a2
 bra.s internal_sft_ea

_ror_ea:
 move.w #ID_ror,_I_ID_instruction(a5)
 lea ror_dat,a2
 bra.s internal_sft_ea

_roxl_ea:
 move.w #ID_roxl,_I_ID_instruction(a5)
 lea roxl_dat,a2
 bra.s internal_sft_ea

_roxr_ea:
 move.w #ID_roxr,_I_ID_instruction(a5)
 lea roxr_dat,a2
 bra.s internal_sft_ea

 IFNE _68020!_68030
_bftst:
 move.w #ID_bftst,_I_ID_instruction(a5)
 lea bftst_dat,a2
 bsr _bfcc_ea
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_bfcc_ea:
 bsr Copy_String
 move.w #'U',_I_format(a5)
 move.b #' ',(a0)+
_bfcc_ea2:
 moveq #2,d7
 lea _101001111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi .error
 move.w 2(a1),d1
 bsr Offset_Width
.error:
 rts

_bfextu:
 move.w #ID_bfextu,_I_ID_instruction(a5)
 lea bfextu_dat,a2
 bsr _bfcc_ea
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w 2(a1),d1
 rol.w #4,d1
 and.w #7,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_bfchg:
 move.w #ID_bfchg,_I_ID_instruction(a5)
 lea bfchg_dat,a2
 bsr _bfcc_ea
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_bfexts:
 move.w #ID_bfexts,_I_ID_instruction(a5)
 lea bfexts_dat,a2
 bsr _bfcc_ea
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w 2(a1),d1
 rol.w #4,d1
 and.w #7,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_bfclr:
 move.w #ID_bfclr,_I_ID_instruction(a5)
 lea bfclr_dat,a2
 bsr _bfcc_ea
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_bfffo:
 move.w #ID_bfffo,_I_ID_instruction(a5)
 lea bfffo_dat,a2
 bsr _bfcc_ea
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w 2(a1),d1
 rol.w #4,d1
 and.w #7,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_bfset:
 move.w #ID_bfset,_I_ID_instruction(a5)
 lea bfset_dat,a2
 bsr _bfcc_ea
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_bfins:
 move.w #ID_bfins,_I_ID_instruction(a5)
 lea bfins_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 move.w 2(a1),d1
 rol.w #4,d1
 and.w #7,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w #'U',_I_format(a5)
 bsr _bfcc_ea2
 bmi Error_Disassemble_line
 bra End_Disassemble_line

Offset_Width:
 move.b #'{',(a0)+
.offset:
 move.w d1,d0
 ror.w #6,d0
 btst #11,d1
 bne.s .offset_data
.offset_immediate:
 and.w #$1f,d0
 bne.s .not_o32
.o32:
 moveq #$20,d0
.not_o32:
 bsr hex_to_asc_bu
 bra.s .width
.offset_data:
 and.w #7,d0
 move.b #'D',(a0)+
 add.b #'0',d0
 move.b d0,(a0)+
.width:
 move.w d1,d0
 move.b #':',(a0)+
 btst #5,d1
 bne.s .width_data
.width_immediate:
 and.w #$1f,d0
 bne.s .not_w32
.w32:
 moveq #$20,d0
.not_w32:
 bsr hex_to_asc_bu
 bra.s .end
.width_data:
 and.w #7,d0
 move.b #'D',(a0)+
 add.b #'0',d0
 move.b d0,(a0)+
.end:
 move.b #'}',(a0)+
 moveq #0,d0
 addq.w #2,_I_size(a5)
 rts
.error:
 moveq #-1,d0
 rts
 ENDC

;  #] 1110:
;  #[ 1111:

; MOVE16*, LPSTOP*, PFLUSH*, PLOAD*, PMOVE*, PTEST*
; 68881/68882 Instructions
_1111:
 move.w (a1),d1
 IFNE _CPU32
 cmp.w #$f800,d1
 bne.s .not_lpstop
 move.w 2(a1),d0
 cmp.w #$01c0,d0
 beq _lpstop
.not_lpstop:
 ENDC ;_CPU32
 IFNE _68040
 move.w d1,d0
 and.w #$fff8,d0
 cmp.w #$f620,d0
 bne.s .not_moves16_reg_reg
 move.w 2(a1),d0
 and.w #$8fff,d0
 cmp.w #$8000,d0
 beq _move16_reg_reg
.not_moves16_reg_reg:
 cmp.w #$f600,d0
 beq _move16_reg_mem
 cmp.w #$f608,d0
 beq _move16_mem_reg
 cmp.w #$f610,d0
 beq _move16_reg_mem
 cmp.w #$f618,d0
 beq _move16_mem_reg
 ENDC
 IFNE _68020!_68030
 move.w d1,d0
 and.w #$fe00,d0
 cmp.w #$f000,d0
 beq.s _pmmu_instructions
 cmp.w #$f200,d0
 beq _fpu_instructions
 ENDC
 IFNE _CPU32
 move.w d1,d0
 and.w #$ffc0,d0
 cmp.w #$f800,d0
 beq _cpu32_instructions
 ENDC ;_CPU32
 bra Error_Disassemble_line

 IFNE _68020!_68030
_pmmu_instructions:
 st _I_coproc(a5)
 clr.w _I_idnumber(a5)
 move.w 2(a1),d1
 move.w d1,d0
 and.w #$ffe0,d0
 cmp.w #$2000,d0
 beq _ploadw
 cmp.w #$2200,d0
 beq _ploadr
 move.w d1,d0
 and.w #$fc00,d0
 cmp.w #$2400,d0
 beq _pflusha
 cmp.w #$3000,d0
 beq _pflush_m
 cmp.w #$3800,d0
 beq _pflush_m_ea
 move.w d1,d0
 and.w #$e300,d0
 cmp.w #$8000,d0
 beq _ptestw
 cmp.w #$8100,d0
 beq _ptestw_a
 cmp.w #$8200,d0
 beq _ptestr
 cmp.w #$8300,d0
 beq _ptestr_a
 and.w #$e000,d0
 beq.s _pmove_tt
 cmp.w #$4000,d0
 beq _pmove_others
 cmp.w #$6000,d0
 beq _pmove_mmusr
 bra Error_Disassemble_line

_pmove_tt:
 move.w #ID_pmove,_I_ID_instruction(a5)
 lea pmove_dat,a2
 bsr Copy_String
 btst #8,d1
 beq.s .no_flush
 move.b #'F',(a0)+
 move.b #'D',(a0)+
.no_flush:
 move.b #' ',(a0)+
 btst #9,d1
 bne.s .tt_to_mem
.mem_to_tt:
 lea _001001111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 bsr tt_reg
 bmi Error_Disassemble_line
 addq.w #2,_I_size(a5)
 bra End_Disassemble_line
.tt_to_mem:
 bsr.s tt_reg
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 lea _001001111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 addq.w #2,_I_size(a5)
 bra End_Disassemble_line

tt_reg:
 move.w 2(a1),d1
 rol.w #6,d1
 and.w #7,d1
 cmp.w #2,d1
 bne.s .not_tt0
 lea tt0_dat,a2
 bra.s .end
.not_tt0:
 cmp.w #3,d1
 bne .error
 lea tt1_dat,a2
.end:
 bsr Copy_String
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts

_pmove_others:
 move.w #ID_pmove,_I_ID_instruction(a5)
 lea pmove_dat,a2
 bsr Copy_String
 btst #8,d1
 beq.s .no_flush
 move.b #'F',(a0)+
 move.b #'D',(a0)+
.no_flush:
 move.b #' ',(a0)+
 btst #9,d1
 bne.s .others_to_mem
.mem_to_others:
 lea _001001111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 bsr.s others_reg
 bmi Error_Disassemble_line
 addq.w #2,_I_size(a5)
 bra End_Disassemble_line
.others_to_mem:
 bsr.s others_reg
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 lea _001001111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 addq.w #2,_I_size(a5)
 bra End_Disassemble_line

others_reg:
 move.w 2(a1),d1
 rol.w #6,d1
 and.w #7,d1
 bne.s .not_tc
 lea tc_dat,a2
 bra.s .end
.not_tc:
 cmp.w #2,d1
 bne.s .not_srp
 lea srp_dat,a2
 bra.s .end
.not_srp:
 cmp.w #3,d1
 bne.s .error
 lea crp_dat,a2
.end:
 bsr Copy_String
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts

_pmove_mmusr:
 move.w #ID_pmove,_I_ID_instruction(a5)
 lea pmove_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 btst #9,d1
 beq.s .mem_to_mmusr
.mmusr_to_mem:
 lea mmusr_dat,a2
 bsr Copy_String
 move.b #',',(a0)+
 lea _001001111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 addq.w #2,_I_size(a5)
 bra End_Disassemble_line
.mem_to_mmusr:
 lea _001001111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 lea mmusr_dat,a2
 bsr Copy_String
 addq.w #2,_I_size(a5)
 bra End_Disassemble_line

_ptestw:
 move.w #ID_ptest,_I_ID_instruction(a5)
 lea ptestw_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 bsr function_code_reg
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 lea _001001111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w 2(a1),d1
 move.w d1,d0
 rol.w #6,d0
 and.w #7,d0
 bsr dat_to_asc_bu
 addq.w #2,_I_size(a5)
 ror.w #4,d0
 and.w #$f,d0
 bne Error_Disassemble_line
 bra End_Disassemble_line

_ptestw_a:
 move.w #ID_ptest,_I_ID_instruction(a5)
 lea ptestw_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 bsr function_code_reg
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 lea _001001111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w 2(a1),d1
 move.w d1,d0
 rol.w #6,d0
 and.w #7,d0
 bsr dat_to_asc_bu
 addq.w #2,_I_size(a5)
 move.b #',',(a0)+
 ror.w #5,d1
 and.w #$f,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_ptestr:
 move.w #ID_ptest,_I_ID_instruction(a5)
 lea ptestr_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 bsr function_code_reg
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 lea _001001111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w 2(a1),d1
 move.w d1,d0
 rol.w #6,d0
 and.w #7,d0
 bsr dat_to_asc_bu
 addq.w #2,_I_size(a5)
 ror.w #4,d0
 and.w #$f,d0
 bne Error_Disassemble_line
 bra End_Disassemble_line

_ptestr_a:
 move.w #ID_ptest,_I_ID_instruction(a5)
 lea ptestr_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 bsr function_code_reg
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 lea _001001111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w 2(a1),d1
 move.w d1,d0
 rol.w #6,d0
 and.w #7,d0
 bsr dat_to_asc_bu
 addq.w #2,_I_size(a5)
 move.b #',',(a0)+
 ror.w #5,d1
 and.w #$f,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_ploadw:
 lea ploadw_dat,a2
 bra.s general_pload
_ploadr:
 lea ploadr_dat,a2
general_pload:
 move.w #ID_pload,_I_ID_instruction(a5)
 bsr Copy_String
 move.b #' ',(a0)+
 bsr function_code_reg
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 lea _001001111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 addq.w #2,_I_size(a5)
 bra End_Disassemble_line

_pflusha:
 move.w #ID_pflusha,_I_ID_instruction(a5)
 move.w 2(a1),d1
 and.w #$3ff,d1
 bne Error_Disassemble_line
 lea pflusha_dat,a2
 bsr Copy_String
 addq.w #2,_I_size(a5)
 bra End_Disassemble_line

_pflush_m:
 move.w #ID_pflush,_I_ID_instruction(a5)
 lea pflush_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 bsr function_code_reg
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w 2(a1),d0
 ror.w #5,d0
 and.w #7,d0
 bsr dat_to_asc_bu
 addq.w #2,_I_size(a5)
 bra End_Disassemble_line

_pflush_m_ea:
 move.w #ID_pflush,_I_ID_instruction(a5)
 lea pflush_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 bsr function_code_reg
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w 2(a1),d0
 ror.w #5,d0
 and.w #7,d0
 bsr dat_to_asc_bu
 addq.w #2,_I_size(a5)
 move.b #',',(a0)+
 lea _001001111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

function_code_reg:
 move.w 2(a1),d1
 and.w #$1f,d1
 move.w d1,d0
 beq.s .sfc
 cmp.w #1,d0
 beq.s .dfc
 and.w #$18,d0
 cmp.w #$10,d0
 beq.s .bits_xxx
 cmp.w #$8,d0
 bne.s .error
.datareg_ddd:
 move.b #'D',(a0)+
 and.w #7,d1
 add.b #'0',d1
 move.b d1,(a0)+
 bra.s .really_end
.bits_xxx:
 move.b #'#',(a0)+
 and.w #7,d1
 add.b #'0',d1
 move.b d1,(a0)+
 bra.s .really_end
.sfc:
 lea sfc_dat,a2
 bra.s .end
.dfc:
 lea dfc_dat,a2
.end:
 bsr Copy_String
.really_end:
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts
 ENDC

 IFNE _CPU32
_lpstop:
 lea lpstop_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 move.w 4(a1),d0
 bsr dat_to_asc_wu
 move.w #6,_I_size(a5)
 bra End_Disassemble_line
 ENDC ;_CPU32

 IFNE _68040
_move16_reg_reg:
 move.w #ID_move16,_I_ID_instruction(a5)
 lea move16_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 move.w (a1),d1
 and.w #7,d1
 or.w #$18,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w 2(a1),d1
 rol.w #4,d1
 and.w #7,d1
 or.w #$18,d1
 bsr Force_Mode_Register
 move.w #4,_I_size(a5)
 bra End_Disassemble_line

_move16_mem_reg:
 move.w #ID_move16,_I_ID_instruction(a5)
 lea move16_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 move.l 2(a1),d0
 bsr hex_to_asc_lu
 move.b #',',(a0)+
 move.w (a1),d1
 move.w d1,d0
 and.w #7,d0
 lsr.w #1,d1
 and.w #$fff8,d1
 or.w d0,d1
 or.w #$10,d1
 bchg #3,d1
 bsr Force_Mode_Register
 move.w #6,_I_size(a5)
 bra End_Disassemble_line

_move16_reg_mem:
 move.w #ID_move16,_I_ID_instruction(a5)
 lea move16_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 move.w (a1),d1
 move.w d1,d0
 and.w #7,d0
 lsr.w #1,d1
 and.w #$fff8,d1
 or.w d0,d1
 or.w #$10,d1
 bchg #3,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.l 2(a1),d0
 bsr hex_to_asc_lu
 move.w #6,_I_size(a5)
 bra End_Disassemble_line
 ENDC
 IFNE _CPU32
_cpu32_instructions:
 move.w 2(a1),d0
 and.w #$8f38,d0
 cmp.w #$0100,d0
 beq _tblu_table
 cmp.w #$0500,d0
 beq _tblun_table
 cmp.w #$0000,d0
 beq _tblu_reg
 cmp.w #$0400,d0
 beq _tblun_reg
 cmp.w #$0900,d0
 beq.s _tbls_table
 cmp.w #$0d00,d0
 beq.s _tlbsn_table
 cmp.w #$0800,d0
 beq _tbls_reg
 cmp.w #$0c00,d0
 beq _tblsn_reg
 bra Error_Disassemble_line

_tblu_table:
 move.w #ID_tblu,_I_ID_instruction(a5)
 lea tblu_dat,a2
 bsr Copy_String
 bra.s _internal_cpu32_table

_tblun_table:
 move.w #ID_tblun,_I_ID_instruction(a5)
 lea tblun_dat,a2
 bsr Copy_String
 bra.s _internal_cpu32_table

_tbls_table:
 move.w #ID_tbls,_I_ID_instruction(a5)
 lea tbls_dat,a2
 bsr Copy_String
 bra.s _internal_cpu32_table

_tlbsn_table:
 move.w #ID_tblsn,_I_ID_instruction(a5)
 lea tblsn_dat,a2
 bsr Copy_String
_internal_cpu32_table:
 move.b #'.',(a0)+
 move.w 2(a1),d0
 and.b #$c0,d0
 beq.s .byte
 bpl.s .word
 cmp.w #$c0,d0
 beq Error_Disassemble_line
.long:
 moveq #'L',d0
 bra.s .after_size
.word:
 moveq #'W',d0
 bra.s .after_size
.byte:
 moveq #'B',d0
.after_size:
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 moveq #2,d7
 lea _000011110011011100,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w 2(a1),d1
 rol.w #4,d1
 and.w #7,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line

_tblu_reg:
 move.w #ID_tblu,_I_ID_instruction(a5)
 lea tblu_dat,a2
 bsr Copy_String
 bra.s _internal_cpu32_reg

_tblun_reg:
 move.w #ID_tblun,_I_ID_instruction(a5)
 lea tblun_dat,a2
 bsr Copy_String
 bra.s _internal_cpu32_reg

_tbls_reg:
 move.w #ID_tbls,_I_ID_instruction(a5)
 lea tbls_dat,a2
 bsr Copy_String
 bra.s _internal_cpu32_reg

_tblsn_reg:
 move.w #ID_tblsn,_I_ID_instruction(a5)
 lea tblsn_dat,a2
 bsr Copy_String
_internal_cpu32_reg:
 move.b #'.',(a0)+
 move.w 2(a1),d0
 and.b #$c0,d0
 beq.s .byte
 bpl.s .word
 cmp.w #$c0,d0
 beq Error_Disassemble_line
.long:
 moveq #'L',d0
 bra.s .after_size
.word:
 moveq #'W',d0
 bra.s .after_size
.byte:
 moveq #'B',d0
.after_size:
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w (a1),d1
 and.w #7,d1
 bsr Force_Mode_Register
 move.b #':',(a0)+
 move.w 2(a1),d1
 and.w #7,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w 2(a1),d1
 rol.w #4,d1
 and.w #7,d1
 bsr Force_Mode_Register
 bra End_Disassemble_line
 ENDC ;_CPU32

; FABS*, FACOS*, FADD*, FASIN*, FATAN*, FATANH*, FBcc*, FCMP*, FCOS*, FCOSH*
; FDBcc*, FDIV*, FETOX*, FETOXM1*, FGETEXP*, FGETMAN*, FINT*, FINTRZ*
; FLOG10*, FLOG2*, FLOGN*, FLOGNP1*, FMOD*, FMOVE*, FMOVECR*, FMOVEM*
; FMUL*, FNEG*, FNOP*, FREM*, FRESTORE*, FSAVE*, FSCALE*, FScc*, FSGLDIV*
; FSGLMUL*, FSIN*, FSINCOS*, FSINH*, FSQRT*, FSUB*, FTAN*, FTANH*, FTENTOX*
; FTRAPcc*, FTST*, FTWOTOX*
 IFNE _68020!_68030
_fpu_instructions:
; tst.b fpu_disassembly(a6)
; beq Error_Disassemble_line
 st _I_coproc(a5)
 move.w #1,_I_idnumber(a5)
 move.w (a1),d1
 cmp.w #$f27c,d1
 beq _ftrapcc
 cmp.w #$f27a,d1
 beq _ftrapcc_w
 cmp.w #$f27b,d1
 beq _ftrapcc_l
 cmp.w #$f280,d1
 bne.s .not_fnop
 move.w 2(a1),d0
 beq _fnop
.not_fnop:
 move.w (a1),d1
 and.w #$fff8,d1
 cmp.w #$f248,d1
 bne.s .not_fdbcc
 cmp.w #$1f,2(a1)
 bls _fdbcc
.not_fdbcc:
 move.w (a1),d1
 and.w #$ffc0,d1
 cmp.w #$f240,d1
 bne.s .not_fscc
 move.w 2(a1),d0
 cmp.w #$1f,d0
 bls _fscc
.not_fscc:
 move.w (a1),d1
 and.w #$ffc0,d1
 cmp.w #$f280,d1
 beq _fbcc_w
 cmp.w #$f2c0,d1
 beq _fbcc_l
 move.w (a1),d1
 and.w #$ffc0,d1
 cmp.w #$f300,d1
 beq _fsave
 cmp.w #$f340,d1
 beq _frestore
 cmp.w #$f200,d1
 bne.s .not_fmovecr
 move.w 2(a1),d1
 and.w #$fc00,d1
 cmp.w #$5c00,d1
 beq _fmovecr
.not_fmovecr:
 move.w 2(a1),d1
 cmp.w #$a400,d1
 beq _fmove_fpiar_ea
 cmp.w #$8400,d1
 beq _fmove_ea_fpiar
 cmp.w #$a800,d1
 beq _fmove_fpsr_ea
 cmp.w #$8800,d1
 beq _fmove_ea_fpsr
 cmp.w #$b000,d1
 beq _fmove_fpcr_ea
 cmp.w #$9000,d1
 beq _fmove_ea_fpcr
 move.w d1,d0
 and.w #$e3ff,d0
 cmp.w #$c000,d0
 beq _fmoveml_mem_reg
 cmp.w #$e000,d0
 beq _fmoveml_reg_mem
 move.w 2(a1),d1
 and.w #$e7ff,d1
 tst.b d1
 beq.s .not_fmovem
 and.w #$ff00,d1
 cmp.w #$c000,d1
 beq _fmovemx_mem_reg
 cmp.w #$e000,d1
 beq _fmovemx_reg_mem
.not_fmovem:
 move.w 2(a1),d1
 move.w d1,d0
 and.w #$e07f,d0
 lea FPU_instructions_table,a2
 moveq #73,d2
.loop:
 move.w (a2)+,d1
 cmp.w d1,d0
 beq.s .this
 addq.w #4,a2
 dbf d2,.loop
.end:
 and.w #$e078,d0
 cmp.w #$0030,d0
 beq _fsincos_reg_reg
 cmp.w #$4030,d0
 beq _fsincos_ea_reg
 and.w #$e000,d0
 cmp.w #$6000,d0
 beq _fmove_reg_ea_k
 bra Error_Disassemble_line
.this:
 move.l (a2),a2
 jmp (a2)

_ftrapcc:
 st _I_exc(a5)
 addq.w #2,_I_size(a5)
 lea ftrapcc_dat,a2
 bsr Copy_String
 move.w 2(a1),d1
 bsr FPU_cc_management
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_ftrapcc_w:
 st _I_exc(a5)
 addq.w #4,_I_size(a5)
 lea ftrapcc_dat,a2
 bsr Copy_String
 move.w 2(a1),d1
 bsr FPU_cc_management
 bmi Error_Disassemble_line
 move.b #'.',(a0)+
 moveq #'W',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w 4(a1),d1
 move.w d1,d0
 bsr dat_to_asc_wu
 bra End_Disassemble_line

_ftrapcc_l:
 st _I_exc(a5)
 addq.w #6,_I_size(a5)
 lea ftrapcc_dat,a2
 bsr Copy_String
 move.w 2(a1),d1
 bsr FPU_cc_management
 bmi Error_Disassemble_line
 move.b #'.',(a0)+
 moveq #'L',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.l 4(a1),d1
 move.l d1,d0
 bsr dat_to_asc_lu
 bra End_Disassemble_line

_fdbcc:
 st _I_branchf(a5)
 addq.w #4,_I_size(a5)
 lea fdbcc_dat,a2
 bsr Copy_String
 move.w 2(a1),d1
 bsr FPU_cc_management
 move.b #' ',(a0)+
 move.w (a1),d1
 and.w #7,d1
 bsr Force_Mode_Register
 move.b #',',(a0)+
 move.w 4(a1),d0
 ext.l d0
 add.l test_instruction(a6),d0
 addq.l #2,d0
 move.l d0,_I_branchaddr(a5)
 bsr addr_to_asc_lu
 bra End_Disassemble_line

_fscc:
 addq.w #2,_I_size(a5)
 lea fscc_dat,a2
 bsr Copy_String
 move.w 2(a1),d1
 bsr FPU_cc_management
 move.b #' ',(a0)+
 lea _101111111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_fbcc_w:
 addq.w #2,_I_size(a5)
 lea fbcc_dat,a2
 bsr Copy_String
 move.w (a1),d1
 bsr FPU_cc_management
 move.b #'.',(a0)+
 moveq #'W',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w 2(a1),d0
 ext.l d0
 add.l test_instruction(a6),d0
 addq.l #2,d0
 move.l d0,_I_branchaddr(a5)
 bsr addr_to_asc_lu
 bra End_Disassemble_line

_fbcc_l:
 addq.w #4,_I_size(a5)
 lea fbcc_dat,a2
 bsr Copy_String
 move.w (a1),d1
 bsr FPU_cc_management
 move.b #'.',(a0)+
 moveq #'L',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.l 2(a1),d0
 add.l test_instruction(a6),d0
 addq.l #2,d0
 move.l d0,_I_branchaddr(a5)
 bsr addr_to_asc_lu
 bra End_Disassemble_line

_fnop:
 lea fnop_dat,a2
 bsr Copy_String
 addq.w #2,_I_size(a5)
 bra End_Disassemble_line

_fsave:
 lea fsave_dat,a2
 st _I_priv(a5)
 bsr Copy_String
 move.b #' ',(a0)+
 lea _001011111111000000,a2
 move.w (a1),d1
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_frestore:
 lea frestore_dat,a2
 st _I_priv(a5)
 bsr Copy_String
 move.b #' ',(a0)+
 lea _001101111111011111,a2
 move.w (a1),d1
 move.l 2(a1),d2
 move.l 6(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_fmovecr:
 addq.w #2,_I_size(a5)
 lea fmovecr_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 move.b #'X',(a0)+
 move.b #' ',(a0)+
 move.w 2(a1),d1
 move.w d1,d0
 and.w #$3f,d0
 move.w d1,-(sp)
 lea _fmovecr_comment_table,a2
.fmovecr_loop:
 move.w (a2)+,d1
 bmi.s .end_search
 cmp.w d0,d1
 beq.s .search_completed
 addq.w #4,a2
 bra.s .fmovecr_loop
.search_completed:
 move.l (a2)+,_I_Comment(a5)
 bra.s .after_search
.end_search:
 lea _fmovecr_reserved_comment,a2
 move.l a2,_I_Comment(a5)
.after_search:
 move.w (sp)+,d1
 bsr dat_to_asc_bu
 move.b #',',(a0)+
 bsr FPU_Destination_register
 bra End_Disassemble_line

_ftst_reg:
 addq.w #2,_I_size(a5)
 lea ftst_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 move.b #'X',(a0)+
 move.b #' ',(a0)+
 bsr FPU_Source_specifier
 bra End_Disassemble_line

_ftst_ea:
 addq.w #2,_I_size(a5)
 lea ftst_dat,a2
 bsr Copy_String
 bsr FPU_Get_Size
 tst.w d0
 beq Error_Disassemble_line
 move.w d0,_I_format(a5)
 move.b #' ',(a0)+
 bsr FPU_Mode_Register_management
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_fint_reg_reg:
 lea fint_dat,a2
 bra fpu_reg_reg_management

_fint_ea_reg:
 lea fint_dat,a2
 bra fpu_ea_reg_management

_fsinh_reg_reg:
 lea fsinh_dat,a2
 bra fpu_reg_reg_management

_fsinh_ea_reg:
 lea fsinh_dat,a2
 bra fpu_ea_reg_management

_fintrz_reg_reg:
 lea fintrz_dat,a2
 bra fpu_reg_reg_management

_fintrz_ea_reg:
 lea fintrz_dat,a2
 bra fpu_ea_reg_management

_fsqrt_reg_reg:
 lea fsqrt_dat,a2
 bra fpu_reg_reg_management

_fsqrt_ea_reg:
 lea fsqrt_dat,a2
 bra fpu_ea_reg_management

_flognp1_reg_reg:
 lea flognp1_dat,a2
 bra fpu_reg_reg_management

_flognp1_ea_reg:
 lea flognp1_dat,a2
 bra fpu_ea_reg_management

_fetoxm1_reg_reg:
 lea fetoxm1_dat,a2
 bra fpu_reg_reg_management

_fetoxm1_ea_reg:
 lea fetoxm1_dat,a2
 bra fpu_ea_reg_management

_ftanh_reg_reg:
 lea ftanh_dat,a2
 bra fpu_reg_reg_management

_ftanh_ea_reg:
 lea ftanh_dat,a2
 bra fpu_ea_reg_management

_fatan_reg_reg:
 lea fatan_dat,a2
 bra fpu_reg_reg_management

_fatan_ea_reg:
 lea fatan_dat,a2
 bra fpu_ea_reg_management

_fasin_reg_reg:
 lea fasin_dat,a2
 bra fpu_reg_reg_management

_fasin_ea_reg:
 lea fasin_dat,a2
 bra fpu_ea_reg_management

_fatanh_reg_reg:
 lea fatanh_dat,a2
 bra fpu_reg_reg_management

_fatanh_ea_reg:
 lea fatanh_dat,a2
 bra fpu_ea_reg_management

_fsin_reg_reg:
 lea fsin_dat,a2
 bra fpu_reg_reg_management

_fsin_ea_reg:
 lea fsin_dat,a2
 bra fpu_ea_reg_management

_ftan_reg_reg:
 lea ftan_dat,a2
 bra fpu_reg_reg_management

_ftan_ea_reg:
 lea ftan_dat,a2
 bra fpu_ea_reg_management

_fetox_reg_reg:
 lea fetox_dat,a2
 bra fpu_reg_reg_management

_fetox_ea_reg:
 lea fetox_dat,a2
 bra fpu_ea_reg_management

_ftwotox_reg_reg:
 lea ftwotox_dat,a2
 bra fpu_reg_reg_management

_ftwotox_ea_reg:
 lea ftwotox_dat,a2
 bra fpu_ea_reg_management

_ftentox_reg_reg:
 lea ftentox_dat,a2
 bra fpu_reg_reg_management

_ftentox_ea_reg:
 lea ftentox_dat,a2
 bra fpu_ea_reg_management

_flogn_reg_reg:
 lea flogn_dat,a2
 bra fpu_reg_reg_management

_flogn_ea_reg:
 lea flogn_dat,a2
 bra fpu_ea_reg_management

_flog10_reg_reg:
 lea flog10_dat,a2
 bra fpu_reg_reg_management

_flog10_ea_reg:
 lea flog10_dat,a2
 bra fpu_ea_reg_management

_flog2_reg_reg:
 lea flog2_dat,a2
 bra fpu_reg_reg_management

_flog2_ea_reg:
 lea flog2_dat,a2
 bra fpu_ea_reg_management

_fabs_reg_reg:
 lea fabs_dat,a2
 bra fpu_reg_reg_management

_fabs_ea_reg:
 lea fabs_dat,a2
 bra fpu_ea_reg_management

_fcosh_reg_reg:
 lea fcosh_dat,a2
 bra fpu_reg_reg_management

_fcosh_ea_reg:
 lea fcosh_dat,a2
 bra fpu_ea_reg_management

_fneg_reg_reg:
 lea fneg_dat,a2
 bra fpu_reg_reg_management

_fneg_ea_reg:
 lea fneg_dat,a2
 bra fpu_ea_reg_management

_facos_reg_reg:
 lea facos_dat,a2
 bra fpu_reg_reg_management

_facos_ea_reg:
 lea facos_dat,a2
 bra fpu_ea_reg_management

_fgetexp_reg_reg:
 lea fgetexp_dat,a2
 bra fpu_reg_reg_management

_fgetexp_ea_reg:
 lea fgetexp_dat,a2
 bra fpu_ea_reg_management

_fgetman_reg_reg:
 lea fgetman_dat,a2
 bra fpu_reg_reg_management

_fgetman_ea_reg:
 lea fgetman_dat,a2
 bra fpu_ea_reg_management

_fdiv_reg_reg:
 lea fdiv_dat,a2
 bra fpu_reg_reg_management2

_fdiv_ea_reg:
 lea fdiv_dat,a2
 bra fpu_ea_reg_management

_fmod_reg_reg:
 lea fmod_dat,a2
 bra fpu_reg_reg_management

_fmod_ea_reg:
 lea fmod_dat,a2
 bra fpu_ea_reg_management

_fadd_reg_reg:
 lea fadd_dat,a2
 bra fpu_reg_reg_management2

_fadd_ea_reg:
 lea fadd_dat,a2
 bra fpu_ea_reg_management

_fmul_reg_reg:
 lea fmul_dat,a2
 bra fpu_reg_reg_management2

_fmul_ea_reg:
 lea fmul_dat,a2
 bra fpu_ea_reg_management

_fsgldiv_reg_reg:
 lea fsgldiv_dat,a2
 bra fpu_reg_reg_management2

_fsgldiv_ea_reg:
 lea fsgldiv_dat,a2
 bra fpu_ea_reg_management

_frem_reg_reg:
 lea frem_dat,a2
 bra fpu_reg_reg_management2

_frem_ea_reg:
 lea frem_dat,a2
 bra fpu_ea_reg_management

_fscale_reg_reg:
 lea fscale_dat,a2
 bra fpu_reg_reg_management2

_fscale_ea_reg:
 lea fscale_dat,a2
 bra fpu_ea_reg_management

_fsglmul_reg_reg:
 lea fsglmul_dat,a2
 bra fpu_reg_reg_management2

_fsglmul_ea_reg:
 lea fsglmul_dat,a2
 bra fpu_ea_reg_management

_fsub_reg_reg:
 lea fsub_dat,a2
 bra fpu_reg_reg_management2

_fsub_ea_reg:
 lea fsub_dat,a2
 bra fpu_ea_reg_management

_fcmp_reg_reg:
 lea fcmp_dat,a2
 bra fpu_reg_reg_management2

_fcmp_ea_cmp:
 lea fcmp_dat,a2
 bra fpu_ea_reg_management

_fmove_reg_reg:
 lea fmove_dat,a2
 bra fpu_reg_reg_management2

_fmove_ea_reg:
 lea fmove_dat,a2
 bra fpu_ea_reg_management

_fcos_reg_reg:
 lea fcos_dat,a2
fpu_reg_reg_management:
 addq.w #2,_I_size(a5)
 addq.w #2,d7
 bsr Copy_String
 move.b #'.',(a0)+
 move.b #'X',(a0)+
 move.b #' ',(a0)+
 bsr FPU_test_Source_Destination
 beq.s .monadic_operand
.dyadic_operand:
 bsr FPU_Source_specifier
 move.b #',',(a0)+
 bsr FPU_Destination_register
 bra End_Disassemble_line

.monadic_operand:
 bsr FPU_Source_specifier
 bra End_Disassemble_line

_fcos_ea_reg:
 lea fcos_dat,a2
fpu_ea_reg_management:
 addq.w #2,_I_size(a5)
 bsr Copy_String
 bsr FPU_Get_Size
 tst.w d0
 beq Error_Disassemble_line
 move.w d0,_I_format(a5)
 move.b #' ',(a0)+
 bsr FPU_Mode_Register_management
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 bsr FPU_Destination_register
 bra End_Disassemble_line

_fsincos_reg_reg:
 addq.w #2,_I_size(a5)
 lea fsincos_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 move.w #'X',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 bsr FPU_Source_specifier
 move.b #',',(a0)+
 move.w 2(a1),d1
 and.w #7,d1
 move.b #'F',(a0)+
 move.b #'P',(a0)+
 add.b #'0',d1
 move.b d1,(a0)+
 move.b #':',(a0)+
 bsr FPU_Destination_register
 bra End_Disassemble_line

_fsincos_ea_reg:
 lea fsincos_dat,a2
 bsr Copy_String
 addq.w #2,_I_size(a5)
 bsr FPU_Get_Size
 tst.w d0
 beq Error_Disassemble_line
 move.w d0,_I_format(a5)
 move.b #' ',(a0)+
 bsr FPU_Mode_Register_management
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 move.w 2(a1),d1
 and.w #7,d1
 move.b #'F',(a0)+
 move.b #'P',(a0)+
 add.b #'0',d1
 move.b d1,(a0)+
 move.b #':',(a0)+
 bsr FPU_Destination_register
 bra End_Disassemble_line

_fmove_reg_ea_k:
 addq.w #2,_I_size(a5)
 lea fmove_dat,a2
 bsr Copy_String
 bsr FPU_fmove_Get_Size
 move.w d0,_I_format(a5)
 move.b #' ',(a0)+
 bsr FPU_Destination_register
 move.b #',',(a0)+
 lea _101111111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 cmp.w #'P',_I_format(a5)
 bne End_Disassemble_line
 move.w 2(a1),d1
 rol.w #6,d1
 and.w #7,d1
 cmp.w #3,d1
 beq.s .k
.data:
 move.b #'{',(a0)+
 move.w 2(a1),d1
 ror.w #4,d1
 and.w #7,d1
 move.b #'D',(a0)+
 add.b #'0',d1
 move.b d1,(a0)+
 move.b #'}',(a0)+
 bra End_Disassemble_line
.k:
 move.b #'{',(a0)+
 move.w 2(a1),d1
 move.w d1,d0
 and.w #$7f,d0
 btst #6,d1
 beq.s .1
 bset #7,d0
.1:
 bsr dat_to_asc_bs
 move.b #'}',(a0)+
 bra End_Disassemble_line

_fmove_fpiar_ea:
 addq.w #2,_I_size(a5)
 lea fmove_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'L',d0
 move.b d0,(a0)+
 move.w d0,_I_format(a5)
 move.b #' ',(a0)+
 lea fpiar_dat,a2
 bsr Copy_String
 move.b #',',(a0)+
 lea _111111111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_fmove_ea_fpiar:
 addq.w #2,_I_size(a5)
 lea fmove_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'L',d0
 move.b d0,(a0)+
 move.w d0,_I_format(a5)
 move.b #' ',(a0)+
 lea _111111111111111111,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 lea fpiar_dat,a2
 bsr Copy_String
 bra End_Disassemble_line

_fmove_fpsr_ea:
 addq.w #2,_I_size(a5)
 lea fmove_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'L',d0
 move.b d0,(a0)+
 move.w d0,_I_format(a5)
 move.b #' ',(a0)+
 lea fpsr_dat,a2
 bsr Copy_String
 move.b #',',(a0)+
 lea _101111111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_fmove_ea_fpsr:
 addq.w #2,_I_size(a5)
 lea fmove_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'L',d0
 move.b d0,(a0)+
 move.w d0,_I_format(a5)
 move.b #' ',(a0)+
 lea _111111111111111111,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 lea fpsr_dat,a2
 bsr Copy_String
 bra End_Disassemble_line

_fmove_fpcr_ea:
 addq.w #2,_I_size(a5)
 lea fmove_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'L',d0
 move.b d0,(a0)+
 move.w d0,_I_format(a5)
 move.b #' ',(a0)+
 lea fpcr_dat,a2
 bsr Copy_String
 move.b #',',(a0)+
 lea _101111111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_fmove_ea_fpcr:
 addq.w #2,_I_size(a5)
 lea fmove_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'L',d0
 move.b d0,(a0)+
 move.w d0,_I_format(a5)
 move.b #' ',(a0)+
 lea _111111111111111111,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 lea fpcr_dat,a2
 bsr Copy_String
 bra End_Disassemble_line

_fmoveml_mem_reg:
 addq.w #2,_I_size(a5)
 lea fmovem_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'L',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _001111111111111111,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 move.b #',',(a0)+
 bsr.s internal_fmovem_reg
 bra End_Disassemble_line

internal_fmovem_reg:
 move.w 2(a1),d1
 btst #12,d1
 beq.s .not_fpcr
 lea fpcr_dat,a2
 bsr Copy_String
 move.b #'/',(a0)+
.not_fpcr:
 btst #11,d1
 beq.s .not_fpsr
 lea fpsr_dat,a2
 bsr Copy_String
 move.b #'/',(a0)+
.not_fpsr:
 btst #10,d1
 beq.s .not_fpiar
 lea fpiar_dat,a2
 bsr Copy_String
 move.b #'/',(a0)+
.not_fpiar:
 clr.b -(a0)
 rts

_fmoveml_reg_mem:
 addq.w #2,_I_size(a5)
 lea fmovem_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'L',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 bsr.s internal_fmovem_reg
 move.b #',',(a0)+
 lea _001111111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi Error_Disassemble_line
 bra End_Disassemble_line

_fmovemx_reg_mem:
 addq.w #2,_I_size(a5)
 lea fmovem_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'X',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 move.w 2(a1),d0
 btst #11,d0
 bne.s .dynamic
.static:
 bsr.s internal_fpx_mem
 bmi.s .err
 bra.s .1
.dynamic:
 ror.w #4,d0
 and.w #7,d0
 add.b #'0',d0
 move.b #'D',(a0)+
 move.b d0,(a0)+
.1:
 move.b #',',(a0)+
 lea _001011111111000000,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
.err:
 bmi Error_Disassemble_line
 bra End_Disassemble_line

internal_fpx_mem:
 movem.l d6-d7/a2,-(sp)
 tst.b d0
 bne.s .register
.no_register:
 move.b #178,(a0)+
 movem.l (sp)+,d6-d7/a2
 rts
.register:
 sf save_movem(a6)
 sf movem_flag(a6)
 sf first_movem(a6)
 moveq #7,d6
 lea fmovem_table,a2
 clr.w d7
 move.w (a1),d6
 and.w #$38,d6
 cmp.w #$20,d6
 bne.s .0
 moveq #7,d7
 st save_movem(a6)
; bchg #4,2(a1)
; bne .error
.0:
; btst #4,2(a1)
; bne .error
 moveq #7,d6
.1:
 btst d7,d0
 beq.s .no
 sf first_movem(a6)
 _TAS movem_flag(a6)
 bne.s .2
 move.b (a2),(a0)+
 move.b 1(a2),(a0)+
 move.b 2(a2),(a0)+
 move.b #"-",(a0)+
 st first_movem(a6)
 bra.s .2
.no:
 tst.b movem_flag(a6)
 bne.s .6
 sf first_movem(a6)
 bra.s .2
.6:
 tst.b first_movem(a6)
 bne.s .5
 move.b -3(a2),(a0)+
 move.b -2(a2),(a0)+
 move.b -1(a2),(a0)+
 move.b #'/',(a0)+
 sf movem_flag(a6)
 sf first_movem(a6)
 bra.s .2
.5:
 move.b #'/',-1(a0)
 sf movem_flag(a6)
 sf first_movem(a6)
.2:
 addq.w #3,a2
 tst.b save_movem(a6)
 bne.s .3
 addq.w #1,d7
 dbf d6,.1
 bra.s .4
.3:
 subq.w #1,d7
 dbf d6,.1
.4:
 tst.b movem_flag(a6)
 beq.s .7
 tst.b first_movem(a6)
 bne.s .7
 move.b -3(a2),(a0)+
 move.b -2(a2),(a0)+
 move.b -1(a2),(a0)+
 move.b #'/',(a0)+
.7:
 clr.b -(a0)
 movem.l (sp)+,d6-d7/a2
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 movem.l (sp)+,d6-d7/a2
 rts

_fmovemx_mem_reg:
 addq.w #2,_I_size(a5)
 lea fmovem_dat,a2
 bsr Copy_String
 move.b #'.',(a0)+
 moveq #'X',d0
 move.w d0,_I_format(a5)
 move.b d0,(a0)+
 move.b #' ',(a0)+
 lea _001101111111011111,a2
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 bmi.s .err
 move.b #',',(a0)+
 move.w 2(a1),d0
 btst #11,d0
 bne.s .dynamic
.static:
 bsr.s internal_mem_fpx
 bpl.s .end
 bra.s .err
.dynamic:
 ror.w #4,d0
 and.w #7,d0
 add.b #'0',d0
 move.b #'D',(a0)+
 move.b d0,(a0)+
.end:
 bra End_Disassemble_line
.err:
 bra Error_Disassemble_line

internal_mem_fpx:
 movem.l d6-d7/a2,-(sp)
 tst.b d0
 bne.s .register
.no_register:
 move.b #178,(a0)+
 movem.l (sp)+,d6-d7/a2
 rts
.register:
 sf save_movem(a6)
 sf movem_flag(a6)
 sf first_movem(a6)
 moveq #7,d6
 lea fmovem_table,a2
 clr.w d7
 move.w (a1),d6
 and.w #$38,d6
 cmp.w #$20,d6
 bne.s .0
 moveq #7,d7
 st save_movem(a6)
; bchg #4,2(a1)
; bne .error
.0:
; btst #4,2(a1)
; bne .error
 moveq #7,d6
.1:
 btst d7,d0
 beq.s .no
 sf first_movem(a6)
 _TAS movem_flag(a6)
 bne.s .2
 move.b (a2),(a0)+
 move.b 1(a2),(a0)+
 move.b 2(a2),(a0)+
 move.b #"-",(a0)+
 st first_movem(a6)
 bra.s .2
.no:
 tst.b movem_flag(a6)
 bne.s .6
 sf first_movem(a6)
 bra.s .2
.6:
 tst.b first_movem(a6)
 bne.s .5
 move.b -3(a2),(a0)+
 move.b -2(a2),(a0)+
 move.b -1(a2),(a0)+
 move.b #'/',(a0)+
 sf movem_flag(a6)
 sf first_movem(a6)
 bra.s .2
.5:
 move.b #'/',-1(a0)
 sf movem_flag(a6)
 sf first_movem(a6)
.2:
 addq.w #3,a2
 tst.b save_movem(a6)
 bne.s .3
 addq.w #1,d7
 dbf d6,.1
 bra.s .4
.3:
 subq.w #1,d7
 dbf d6,.1
.4:
 tst.b movem_flag(a6)
 beq.s .7
 tst.b first_movem(a6)
 bne.s .7
 move.b -3(a2),(a0)+
 move.b -2(a2),(a0)+
 move.b -1(a2),(a0)+
 move.b #'/',(a0)+
.7:
 clr.b -(a0)
 movem.l (sp)+,d6-d7/a2
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 movem.l (sp)+,d6-d7/a2
 rts

fpu_reg_reg_management2:
 addq.w #2,_I_size(a5)
 addq.w #2,d7
 bsr Copy_String
 move.b #'.',(a0)+
 move.b #'X',(a0)+
 move.b #' ',(a0)+
.dyadic_operand:
 bsr FPU_Source_specifier
 move.b #',',(a0)+
 bsr FPU_Destination_register
 bra End_Disassemble_line

FPU_test_Source_Destination:
 move.w 2(a1),d1
 move.w d1,d0
 rol.w #6,d0
 and.w #7,d0
 ror.w #7,d1
 and.w #7,d1
 sub.w d0,d1
 rts

FPU_Source_specifier:
 move.w 2(a1),d1
 rol.w #6,d1
 and.w #7,d1
 move.b #'F',(a0)+
 move.b #'P',(a0)+
 add.b #'0',d1
 move.b d1,(a0)+
 rts

FPU_Destination_register:
 move.w 2(a1),d1
 ror.w #7,d1
 and.w #7,d1
 move.b #'F',(a0)+
 move.b #'P',(a0)+
 add.b #'0',d1
 move.b d1,(a0)+
 rts

FPU_fmove_Get_Size:
 move.b #'.',(a0)+
 move.w 2(a1),d1
 rol.w #6,d1
 and.w #7,d1
 mulu #6,d1
 jmp .FPU_fmove_size(pc,d1.w)
.FPU_fmove_size:
 moveq #'L',d0
 move.b d0,(a0)+
 rts
 moveq #'S',d0
 move.b d0,(a0)+
 rts
 moveq #'X',d0
 move.b d0,(a0)+
 rts
 moveq #'P',d0
 move.b d0,(a0)+
 rts
 moveq #'W',d0
 move.b d0,(a0)+
 rts
 moveq #'D',d0
 move.b d0,(a0)+
 rts
 moveq #'B',d0
 move.b d0,(a0)+
 rts
 moveq #'P',d0
 move.b d0,(a0)+
 rts

FPU_Get_Size:
 move.b #'.',(a0)+
 move.w 2(a1),d1
 rol.w #6,d1
 and.w #7,d1
 mulu #6,d1
 jmp .FPU_size(pc,d1.w)
.FPU_size:
 moveq #'L',d0
 move.b d0,(a0)+
 rts
 moveq #'S',d0
 move.b d0,(a0)+
 rts
 moveq #'X',d0
 move.b d0,(a0)+
 rts
 moveq #'P',d0
 move.b d0,(a0)+
 rts
 moveq #'W',d0
 move.b d0,(a0)+
 rts
 moveq #'D',d0
 move.b d0,(a0)+
 rts
 moveq #'B',d0
 move.b d0,(a0)+
 rts
 moveq #0,d0
 rts

FPU_cc_management:
 and.w #$3f,d1
 cmp.w #$1f,d1
 bhi.s .error
 mulu #5,d1
 lea FPU_condition_codes_dat,a2
 add.w d1,a2
 bsr Copy_String
.end:
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts

FPU_Mode_Register_management:
 lea _101111111111111111,a2
 cmp.w #'B',_I_format(a5)
 beq.s .1
 cmp.w #'W',_I_format(a5)
 beq.s .1
 cmp.w #'L',_I_format(a5)
 beq.s .1
 cmp.w #'S',_I_format(a5)
 beq.s .1
 lea _001111111111111111,a2
.1:
 move.w (a1),d1
 move.l 4(a1),d2
 move.l 8(a1),d3
 bsr Mode_Register
 rts
 ENDC

;  #] 1111:
;  #] Disassemble routines:
;  #[ Exit:

Error_Disassemble_line:
 move.w #2,_I_size(a5)
 move.l start_of_line_buffer(a6),a0
 bsr Dc_w
 clr.b (a0)
End_Disassemble_line:
 moveq #0,d0
 lea instruction_size(a6),a1
 move.w _I_size(a5),(a1)
 sf illegal_instruction_flag(a6)
 tst.w _I_unimplemented(a5)
 beq.s .not_illegal
 st illegal_instruction_flag(a6)
.not_illegal:
 move.l a0,d0
 movem.l (sp)+,d1-a5
 move.l d0,a0
 clr.b (a0)
 moveq #0,d0
 rts

_D_Read_Error:
 sf dont_remove_break_flag(a6)
 move.l (sp)+,a0
 move.b #'*',(a0)+
 move.b #'*',(a0)+
 clr.b (a0)
 move.l a0,d0
 movem.l (sp)+,d1-a5
 move.l d0,a0
 moveq #-1,d0
 rts

Disassemble_line_test_berror:
 IFNE	ATARIST
 movem.l d1-d2/a0-a3,-(sp)
 moveq #0,d0
 sub.l a0,a0
 lea 8(a0),a0
 move.l (a0),d1
 lea .my_berror,a2
 move.l a2,(a0)
 rept 22
 move.b (a1)+,d2
 move.b d2,(a3)+
 endr
 move.l d1,(a0)
 movem.l (sp)+,d1-d2/a0-a3
 move.l a3,a1
 rts
.my_berror:
 moveq #-1,d0
 tst.b chip_type(a6)
 beq.s .68000_2
.68030_2:
 bclr #0,$a(sp)
 rte
.68000_2:
 addq.w #8,sp
 rte
 ENDC	;d'ATARIST
 IFNE	AMIGA
 movem.l a0/a2/a3,-(sp)
 move.l	a1,a2
 bsr	test_if_readable4 ;10 octets
 lea	readable_buffer(a6),a0
 tst.l	(a0)+
 bne.s	.not_readable
 tst.l	(a0)+
 bne.s	.not_readable
 tst.w	(a0)+
 bne.s	.not_readable
 REPT	5
 move.w	(a2)+,(a3)+
 ENDR
 bsr	test_if_readable4 ;10 octets
 lea	readable_buffer(a6),a0
 tst.l	(a0)+
 bne.s	.not_readable
 tst.l	(a0)+
 bne.s	.not_readable
 tst.w	(a0)+
 bne.s	.not_readable
 REPT	5
 move.w	(a2)+,(a3)+
 ENDR
 moveq	#0,d0
 bra.s	.end
.not_readable:
 moveq	#-1,d0
.end:
 movem.l (sp)+,a0/a2/a3
 move.l a3,a1
 rts
 ENDC	;d'AMIGA
;  #] Exit:
;  #[ <ea> management:

Force_Mode_Register:
 lea _111111111111111111,a2
Mode_Register:
 movem.l d1-d3,-(sp)
 move.w d1,d0
 lsr.b #1,d0
 and.w #$1c,d0
 jmp .1(pc,d0.w)

 _NOOPTI
.1:
 bra data_reg_dir			; 000 (done)
 bra addr_reg_dir			; 001 (done)
 bra addr_reg_ind			; 010 (done+interpretation)
 bra addr_reg_ind_post			; 011 (done)
 bra addr_reg_ind_pred			; 100 (done)
 bra addr_reg_ind_disp			; 101 (done+interpretation)
 bra others1				; 110 (done)
 bra others2				; 111 (done)
 _OPTI

data_reg_dir:
 btst #1,(a2)
 beq Mode_Register_error
 move.b #'D',(a0)+
 and.b #7,d1
 add.b #'0',d1
 move.b d1,(a0)+
 bra Mode_Register_end

addr_reg_dir:
 btst #0,(a2)
 beq Mode_Register_error
 move.b #'A',(a0)+
 and.b #7,d1
 add.b #'0',d1
 move.b d1,(a0)+
 bra Mode_Register_end

addr_reg_ind:
 btst #7,1(a2)
 beq Mode_Register_error
 move.b #'(',(a0)+
 move.b #'A',(a0)+
 and.w #7,d1
 add.b #'0',d1
 move.b d1,(a0)+
 move.b #')',(a0)+
 sub.b #'0',d1
 lsl.w #2,d1
 lea a0_buf(a6),a2
 add.w d1,a2
 move.w #4,_I_sourcesize(a5)
 _TAS _I_sourcef(a5)
 bne.s .dest
.source:
 lea _I_sourceaddr(a5),a4
 bra.s .end
.dest:
 clr.w _I_destformat(a5)
 lea _I_destaddr(a5),a4
.end:
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
 bra Mode_Register_end

addr_reg_ind_post:
 btst #6,1(a2)
 beq Mode_Register_error
 move.b #'(',(a0)+
 move.b #'A',(a0)+
 and.w #7,d1
 add.b #'0',d1
 move.b d1,(a0)+
 move.b #')',(a0)+
 move.b #'+',(a0)+
 bra Mode_Register_end

addr_reg_ind_pred:
 btst #5,1(a2)
 beq Mode_Register_error
 move.b #'-',(a0)+
 move.b #'(',(a0)+
 move.b #'A',(a0)+
 and.w #7,d1
 add.b #'0',d1
 move.b d1,(a0)+
 move.b #')',(a0)+
 bra Mode_Register_end

addr_reg_ind_disp:
 btst #4,1(a2)
 beq Mode_Register_error

 move.l d2,d0
 swap d0
 tst.b relative_offset_flag(a6)
 beq.s .no_index
 movem.l d0-d2/a1-a2,-(sp)
; st operande_flag(a6)
 ext.l d0
 and.w #7,d1
 add.w d1,d1
 add.w d1,d1
 lea a0_buf(a6),a2
 add.l 0(a2,d1.w),d0
 _JSR find_in_table2
 bne.s .no_symbol_search
 move.l VAR_NAME(a2),a2
.l1:
 move.b (a2)+,(a0)+
 bne.s .l1
 subq.w #1,a0
 movem.l (sp)+,d0-d2/a1-a2
 bra.s .symbol_found
.no_symbol_search:
 movem.l (sp)+,d0-d2/a1-a2
.no_index:
 bsr hex_to_asc_ws
.symbol_found:
 move.b #'(',(a0)+
 move.b #'A',(a0)+
 and.w #7,d1
 add.b #'0',d1
 move.b d1,(a0)+
 move.b #')',(a0)+
 sub.b #'0',d1
 lsl.w #2,d1
 lea a0_buf(a6),a2
 add.w d1,a2
 move.w #4,_I_sourcesize(a5)
 move.l d2,d0
 swap d0
 ext.l d0
 _TAS _I_sourcef(a5)
 bne.s .dest
.source:
 lea _I_sourceaddr(a5),a4
 bra.s .after_analyse
.dest:
 clr.w _I_destformat(a5)
 lea _I_destaddr(a5),a4
.after_analyse:
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)+
 add.l d0,-4(a4)
 addq.w #2,d7
 addq.w #2,_I_size(a5)
 bra Mode_Register_end

others1:
 move.l d2,d0
 swap d0
 btst #8,d0
 beq ax_brief_format

 IFNE _68020!_68030
.full_format:
 addq.w #2,d7
 addq.w #2,_I_size(a5)
 clr.w -(sp)
 btst #6,d0
 beq.s .no_is
.is:
 bset #3,1(sp)
.no_is:
 and.w #7,d0
 or.w d0,(sp)
 move.w (sp)+,d0
 add.w d0,d0
 add.w d0,d0
 jmp .others1(pc,d0.w)

 _NOOPTI
.others1:
 bra no_memory_indirection_with_index		; (done+interpretation)
 bra indirect_preindexed_null_outer		; (done+interpretation)
 bra indirect_preindexed_outer			; (done+interpretation)
 bra indirect_preindexed_outer			; (done+interpretation)
 bra Mode_Register_error			; (done)
 bra indirect_postindexed_null_outer		; (done+interpretation)
 bra indirect_postindexed_outer			; (done+interpretation)
 bra indirect_postindexed_outer			; (done+interpretation)
 bra no_memory_indirection_no_index		; (done+interpretation)
 bra memory_indirect_null_outer			; (done+interpretation)
 bra memory_indirect_outer			; (done+interpretation)
 bra memory_indirect_outer			; (done+interpretation)
 bra Mode_Register_error			; (done)
 bra Mode_Register_error			; (done)
 bra Mode_Register_error			; (done)
 bra Mode_Register_error			; (done)
 _OPTI

no_memory_indirection_with_index:
 bsr _set_addr_flag
 btst #2,1(a2)
 beq Mode_Register_error
 move.b #'(',(a0)+
 bsr base_displacement_management
 bmi Mode_Register_error
 bsr Add_comma
 bsr base_register_management
 bsr Add_comma
 move.l d2,d0
 swap d0
 bsr index_register_management
 move.b #')',(a0)+
 tst.b _I_destf(a5)
 bne.s .dest
.source:
 move.l _I_sbasedisp(a5),d0
 add.l _I_sbasereg(a5),d0
 add.l _I_sindexreg(a5),d0
 move.l d0,_I_sourceaddr(a5)
 bra Mode_Register_end
.dest:
 move.l _I_dbasedisp(a5),d0
 add.l _I_dbasereg(a5),d0
 add.l _I_dindexreg(a5),d0
 move.l d0,_I_destaddr(a5)
 bra Mode_Register_end

indirect_preindexed_null_outer:
 bsr _set_addr_flag
 btst #1,1(a2)
 beq Mode_Register_error
 move.b #'(',(a0)+
 move.b #'[',(a0)+
 bsr base_displacement_management
 bsr Add_comma
 bsr base_register_management
 bsr Add_comma
 bsr index_register_management
 bsr Close_bracket_par
 tst.b _I_destf(a5)
 bne.s .dest
.source:
 move.l _I_sbasedisp(a5),d0
 add.l _I_sbasereg(a5),d0
 add.l _I_sindexreg(a5),d0
 lea _I_sourceaddr(a5),a4
 bra.s .do
.dest:
 move.l _I_dbasedisp(a5),d0
 add.l _I_dbasereg(a5),d0
 add.l _I_dindexreg(a5),d0
 lea _I_destaddr(a5),a4
.do:
 move.l d0,a2
 bsr ea_test_if_readable
 bmi.s .end
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
.end:
 bra Mode_Register_end

indirect_preindexed_outer:
 bsr _set_addr_flag
 btst #1,1(a2)
 beq Mode_Register_error
 move.b #'(',(a0)+
 move.b #'[',(a0)+
 bsr base_displacement_management
 bsr Add_comma
 bsr base_register_management
 bsr Add_comma
 bsr index_register_management
 bsr Close_bracket
 move.b #',',(a0)+
 bsr outer_displacement_management
 bsr Close_par
 tst.b _I_destf(a5)
 bne.s .dest
.source:
 move.l _I_sbasedisp(a5),d0
 add.l _I_sbasereg(a5),d0
 add.l _I_sindexreg(a5),d0
 move.l d0,a2
 bsr ea_test_if_readable
; bmi Mode_Register_error
 bmi.s .end
 lea _I_sourceaddr(a5),a4
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
 move.l _I_souterdisp(a5),d0
 add.l d0,_I_sourceaddr(a5)
 bra Mode_Register_end
.dest:
 move.l _I_dbasedisp(a5),d0
 add.l _I_dbasereg(a5),d0
 add.l _I_dindexreg(a5),d0
 move.l d0,a2
 bsr ea_test_if_readable
; bmi Mode_Register_error
 bmi.s .end
 lea _I_destaddr(a5),a4
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
 move.l _I_douterdisp(a5),d0
 add.l d0,_I_destaddr(a5)
.end:
 bra Mode_Register_end

indirect_postindexed_null_outer:
 bsr _set_addr_flag
 btst #0,1(a2)
 beq Mode_Register_error
 move.b #'(',(a0)+
 move.b #'[',(a0)+
 bsr base_displacement_management
 bsr Add_comma
 bsr base_register_management
 bsr Close_bracket
 move.b #',',(a0)+
 bsr index_register_management
 bsr Close_par
 tst.b _I_destf(a5)
 bne.s .dest
.source:
 move.l _I_sbasedisp(a5),d0
 add.l _I_sbasereg(a5),d0
 move.l d0,a2
 bsr ea_test_if_readable
; bmi Mode_Register_error
 bmi.s .end
 lea _I_sourceaddr(a5),a4
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
 move.l _I_sindexreg(a5),d0
 add.l d0,_I_sourceaddr(a5)
 bra Mode_Register_end
.dest:
 move.l _I_dbasedisp(a5),d0
 add.l _I_dbasereg(a5),d0
 move.l d0,a2
 bsr ea_test_if_readable
; bmi Mode_Register_error
 bmi.s .end
 lea _I_destaddr(a5),a4
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
 move.l _I_dindexreg(a5),d0
 add.l d0,_I_destaddr(a5)
.end:
 bra Mode_Register_end

indirect_postindexed_outer:
 bsr _set_addr_flag
 btst #0,1(a2)
 beq Mode_Register_error
 move.b #'(',(a0)+
 move.b #'[',(a0)+
 bsr base_displacement_management
 bsr Add_comma
 bsr base_register_management
 bsr Close_bracket
 move.b #',',(a0)+
 bsr index_register_management
 bsr Add_comma
 bsr outer_displacement_management
 bsr Close_par
 tst.b _I_destf(a5)
 bne.s .dest
.source:
 move.l _I_sbasedisp(a5),d0
 add.l _I_sbasereg(a5),d0
 move.l d0,a2
 bsr ea_test_if_readable
; bmi Mode_Register_error
 bmi.s .end
 lea _I_sourceaddr(a5),a4
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
 move.l _I_sindexreg(a5),d0
 add.l _I_souterdisp(a5),d0
 add.l d0,_I_sourceaddr(a5)
 bra Mode_Register_end
.dest:
 move.l _I_dbasedisp(a5),d0
 add.l _I_dbasereg(a5),d0
 move.l d0,a2
 bsr ea_test_if_readable
; bmi Mode_Register_error
 bmi.s .end
 lea _I_destaddr(a5),a4
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
 move.l _I_dindexreg(a5),d0
 add.l _I_douterdisp(a5),d0
 add.l d0,_I_destaddr(a5)
.end:
 bra Mode_Register_end

no_memory_indirection_no_index:
 bsr _set_addr_flag
 btst #2,1(a2)
 beq Mode_Register_error
 move.b #'(',(a0)+
 bsr base_displacement_management
 bmi Mode_Register_error
 bsr Add_comma
 bsr base_register_management
 bsr Close_par
 tst.b _I_destf(a5)
 bne.s .dest
.source:
 move.l _I_sbasedisp(a5),d0
 add.l _I_sbasereg(a5),d0
 move.l d0,_I_sourceaddr(a5)
 bra Mode_Register_end
.dest:
 move.l _I_dbasedisp(a5),d0
 add.l _I_dbasereg(a5),d0
 move.l d0,_I_destaddr(a5)
 bra Mode_Register_end

memory_indirect_null_outer:
 bsr _set_addr_flag
 btst #1,1(a2)
 beq Mode_Register_error
 move.b #'(',(a0)+
 move.b #'[',(a0)+
 bsr base_displacement_management
 bmi Mode_Register_error
 bsr Add_comma
 and.w #7,d1
 or.w #8,d1
 bsr base_register_management
 bsr Close_bracket_par
 tst.b _I_destf(a5)
 bne.s .dest
.source:
 move.l _I_sbasedisp(a5),d0
 add.l _I_sbasereg(a5),d0
 lea _I_sourceaddr(a5),a4
 bra.s .do
.dest:
 move.l _I_dbasedisp(a5),d0
 add.l _I_dbasereg(a5),d0
 lea _I_destaddr(a5),a4
.do:
 move.l d0,a2
 bsr ea_test_if_readable
 bmi.s .end
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
.end:
 bra Mode_Register_end

memory_indirect_outer:
 bsr _set_addr_flag
 btst #1,1(a2)
 beq Mode_Register_error
 move.b #'(',(a0)+
 move.b #'[',(a0)+
 bsr base_displacement_management
 bmi Mode_Register_error
 bsr Add_comma
 and.w #7,d1
 or.w #8,d1
 bsr base_register_management
 bsr Close_bracket
 move.b #',',(a0)+
 bsr outer_displacement_management
 bsr Close_par
 tst.b _I_destf(a5)
 bne.s .dest
.source:
 move.l _I_sbasedisp(a5),d0
 add.l _I_sbasereg(a5),d0
 move.l d0,a2
 bsr ea_test_if_readable
; bmi Mode_Register_error
 bmi.s .end
 lea _I_sourceaddr(a5),a4
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
 move.l _I_souterdisp(a5),d0
 add.l d0,_I_sourceaddr(a5)
 bra Mode_Register_end
.dest:
 move.l _I_dbasedisp(a5),d0
 add.l _I_dbasereg(a5),d0
 move.l d0,a2
 bsr ea_test_if_readable
; bmi Mode_Register_error
 bmi.s .end
 lea _I_destaddr(a5),a4
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
 move.l _I_douterdisp(a5),d0
 add.l d0,_I_destaddr(a5)
.end:
 bra Mode_Register_end

base_displacement_management:
 move.l d2,d0
 swap d0
 ror.w #4,d0
 and.w #3,d0
 beq.s .error
 add.w d0,d0
 jmp .base_size-2(pc,d0.w)

 _NOOPTI
.base_size:
 bra.s .end
 bra.s .word
 bra.s .long
 _OPTI

.word:
 move.w d2,d0
 ext.l d0
 bsr .add_to_addr
 bsr hex_to_asc_ws
 move.b #'.',(a0)+
 move.b #'W',(a0)+
 addq.w #2,d7
 addq.w #2,_I_size(a5)
 bra.s .end
.long:
 move.w d2,d0
 swap d0
 swap d3
 move.w d3,d0
 swap d3
 bsr .add_to_addr
 bsr hex_to_asc_ls
 move.b #'.',(a0)+
 move.b #'L',(a0)+
 addq.w #4,d7
 addq.w #4,_I_size(a5)
.end:
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts

.add_to_addr:
 tst.b _I_destf(a5)
 bne.s .dest_store
.source_store:
 move.l d0,_I_sbasedisp(a5)
 rts
.dest_store:
 move.l d0,_I_dbasedisp(a5)
 rts

bd_pc_management:
 move.l d2,d0
 swap d0
 ror.w #4,d0
 and.w #3,d0
 beq.s .error
 add.w d0,d0
 jmp .base_size-2(pc,d0.w)

 _NOOPTI
.base_size:
 bra.s .end
 bra.s .word
 bra.s .long
 _OPTI

.word:
 move.w d2,d0
 ext.l d0
 bsr .add_to_addr
 add.l test_instruction(a6),d0
 addq.l #2,d0
 bsr addr_to_asc_lu
 move.b #'.',(a0)+
 move.b #'W',(a0)+
 addq.w #2,d7
 addq.w #2,_I_size(a5)
 bra.s .end
.long:
 move.w d2,d0
 swap d0
 swap d3
 move.w d3,d0
 swap d3
 add.l test_instruction(a6),d0
 addq.l #2,d0
 bsr .add_to_addr
 bsr addr_to_asc_lu
 move.b #'.',(a0)+
 move.b #'L',(a0)+
 addq.w #4,d7
 addq.w #4,_I_size(a5)
.end:
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts

.add_to_addr:
 tst.b _I_destf(a5)
 bne.s .dest_store
.source_store:
 move.l d0,_I_sbasedisp(a5)
 rts
.dest_store:
 move.l d0,_I_dbasedisp(a5)
 rts

base_register_management:
 btst #23,d2
 bne.s .no_base_register
 move.w d1,-(sp)
 and.w #7,d1
 movem.l d1/a1,-(sp)
 lea a0_buf(a6),a1
 cmp.w #7,d1
 bne.s .not_stack_pointer
 bsr _find_real_sp
 bra.s .after_stack_test
.not_stack_pointer:
 lsl.w #2,d1
 move.l 0(a1,d1.w),d1
.after_stack_test:
 tst.b _I_destaddr(a5)
 bne.s .add_to_dest
.add_to_source:
 move.l d1,_I_sbasereg(a5)
 bra.s .after_add
.add_to_dest:
 move.l d1,_I_dbasereg(a5)
.after_add:
 movem.l (sp)+,d1/a1
 or.w #8,d1
 bsr Force_Mode_Register
 move.w (sp)+,d1
.no_base_register:
 rts


outer_displacement_management:
 move.l d2,d0
 swap d0
 and.w #3,d0
 add.w d0,d0
 jmp .outer_size(pc,d0.w)
.outer_size:

 _NOOPTI
 bra.s .error
 bra.s .error
 bra.s .word_outer
 bra.s .long_outer
 _OPTI

.error:
 moveq #-1,d0
 rts
.word_outer:
 move.w 2(a1,d7.w),d0
 ext.l d0
 bsr .add_to_addr
 bsr hex_to_asc_ls
 move.b #'.',(a0)+
 move.b #'W',(a0)+
 addq.w #2,d7
 addq.w #2,_I_size(a5)
 moveq #0,d0
 rts
.long_outer:
 move.l 2(a1,d7.w),d0
 bsr .add_to_addr
 bsr hex_to_asc_ls
 move.b #'.',(a0)+
 move.b #'L',(a0)+
 addq.w #4,d7
 addq.w #4,_I_size(a5)
 moveq #0,d0
 rts

.add_to_addr:
 tst.b _I_destf(a5)
 bne.s .dest
.source:
 move.l d0,_I_souterdisp(a5)
 rts
.dest:
 move.l d0,_I_douterdisp(a5)
 rts

 ELSEIF
 bra Mode_Register_error
 ENDC

index_register_management:
 move.w d1,-(sp)
 move.l d2,d1
 swap d1
 rol.w #4,d1
 and.w #$f,d1
 movem.l d0-d1/a1,-(sp)
 lea d0_buf(a6),a1
 cmp.w #$f,d1
 bne.s .not_sp
.sp:
 move.l a7_buf(a6),d0
 btst #5,sr_buf(a6)
 beq.s .sp_done
 IFNE _68020!_68030
 move.l isp_buf(a6),d0
 btst #4,sr_buf(a6)
 beq.s .sp_done
 move.l msp_buf(a6),d0
 ELSEIF
 move.l ssp_buf(a6),d0
 ENDC
.sp_done:
 bsr .set_addr
 bra.s .after_analyse
.not_sp:
 lsl.w #2,d1
 move.l 0(a1,d1.w),d0
 bsr .set_addr
.after_analyse:
 movem.l (sp)+,d0-d1/a1
 bsr Force_Mode_Register
 move.b #'.',(a0)+
 btst #27,d2
 bne.s .long
.word:
 move.b #'W',(a0)+
 bsr .get_addr
 ext.l d0
 bsr .set_addr
 bra.s .after_size
.long:
 move.b #'L',(a0)+
.after_size:
 move.w (sp)+,d1
 IFNE _68020!_68030
 move.l d2,d0
 swap d0
 rol.w #7,d0
 and.w #3,d0
 add.w d0,d0
 jmp .scale(pc,d0.w)

 _NOOPTI
.scale:
 bra.s .1
 bra.s .2
 bra.s .4
 bra.s .8
 _OPTI

.1:
 rts
.2:
 move.b #'*',(a0)+
 move.b #'2',(a0)+
 bsr.s .get_addr
 add.l d0,d0
 bsr.s .set_addr
 rts
.4:
 move.b #'*',(a0)+
 move.b #'4',(a0)+
 bsr.s .get_addr
 add.l d0,d0
 add.l d0,d0
 bsr.s .set_addr
 rts
.8:
 move.b #'*',(a0)+
 move.b #'8',(a0)+
 bsr.s .get_addr
 lsl.l #3,d0
 bsr.s .set_addr
 rts

.get_addr:
 tst.b _I_destf(a5)
 bne.s .get_dest
.get_source:
 move.l _I_sindexreg(a5),d0
 rts
.get_dest:
 move.l _I_dindexreg(a5),d0
 rts

.set_addr:
 tst.b _I_destf(a5)
 bne.s .set_dest
.set_source:
 move.l d0,_I_sindexreg(a5)
 rts
.set_dest:
 move.l d0,_I_dindexreg(a5)
 rts

 ELSEIF
 rts

.get_addr:
 tst.b _I_destf(a5)
 bne.s .get_dest
.get_source:
 move.l _I_sindexreg(a5),d0
 rts
.get_dest:
 move.l _I_dindexreg(a5),d0
 rts

.set_addr:
 tst.b _I_destf(a5)
 bne.s .set_dest
.set_source:
 move.l d0,_I_sindexreg(a5)
 rts
.set_dest:
 move.l d0,_I_dindexreg(a5)
 rts

 ENDC

ax_brief_format:
; bra addr_reg_ind_index_8bit		; 110 (done+displacement)

addr_reg_ind_index_8bit:
 btst #3,1(a2)
 beq Mode_Register_error

 move.l d2,d0
 swap d0
 ext.w d0
 ext.l d0
 bsr .basedisp_set_addr
 and.w #7,d1
 tst.b relative_offset_flag(a6)
 beq.s .no_index
 movem.l d0-d1/a2,-(sp)
; st operande_flag(a6)
 ext.l d0
 add.w d1,d1
 add.w d1,d1
 lea a0_buf(a6),a2
 add.l 0(a2,d1.w),d0
 _JSR find_in_table2
 bne.s .no_symbol_search
 move.l VAR_NAME(a2),a2
.l1:
 move.b (a2)+,(a0)+
 bne.s .l1
 subq.w #1,a0
 movem.l (sp)+,d0-d1/a2
 bra.s .symbol_found
.no_symbol_search:
 movem.l (sp)+,d0-d1/a2
.no_index:
 bsr hex_to_asc_bs
.symbol_found:
 move.b #'(',(a0)+
 move.b #'A',(a0)+
 move.w d1,d0
 add.b #'0',d0
 move.b d0,(a0)+
 move.l a1,-(sp)
 sub.b #'0',d0
 cmp.w #7,d0
 bne.s .not_sp
.sp:
 IFNE _68020!_68030
 move.l a7_buf(a6),d0
 btst #5,sr_buf(a6)
 beq.s .after_basereg
 move.l isp_buf(a6),d0
 btst #4,sr_buf(a6)
 beq.s .after_basereg
 move.l msp_buf(a6),d0
 bra.s .after_basereg
 ELSEIF
 move.l a7_buf(a6),d0
 btst #5,sr_buf(a6)
 beq.s .after_basereg
 move.l ssp_buf(a6),d0
 bra.s .after_basereg
 ENDC
.not_sp:
 lsl.w #2,d0
 lea a0_buf(a6),a1
 move.l 0(a1,d0.w),d0
.after_basereg:
 bsr .basereg_set_addr
 move.l (sp)+,a1
 move.b #',',(a0)+
 bsr index_register_management
 move.b #')',(a0)+
 addq #2,d7
 addq.w #2,_I_size(a5)
 tst.b _I_destf(a5)
 bne.s .build_dest
.build_source:
 move.l _I_sbasedisp(a5),d0
 add.l _I_sbasereg(a5),d0
 add.l _I_sindexreg(a5),d0
 move.l d0,_I_sourceaddr(a5)
 bra Mode_Register_end
.build_dest:
 move.l _I_dbasedisp(a5),d0
 add.l _I_dbasereg(a5),d0
 add.l _I_dindexreg(a5),d0
 move.l d0,_I_destaddr(a5)
 bra Mode_Register_end

.basedisp_set_addr:
 tst.b _I_destf(a5)
 bne.s .dest
.source:
 move.l d0,_I_sbasedisp(a5)
 rts
.dest:
 move.l d0,_I_dbasedisp(a5)
 rts

.basereg_set_addr:
 tst.b _I_destf(a5)
 bne.s .dest_basereg
.source_basereg:
 move.l d0,_I_sbasereg(a5)
 rts
.dest_basereg:
 move.l d0,_I_dbasereg(a5)
 rts

others2:
 move.w d1,d0
 lsl.b #2,d0
 and.w #$1c,d0
 jmp .1(pc,d0.w)

 _NOOPTI
.1:
 bra abs_short				; 000 (done+interpretation)
 bra abs_long				; 001 (done+interpretation)
 bra pc_ind_disp			; 010 (done+interpretation)
 bra others3				; 011 (done)
 bra immediate				; 100 (done)
 bra Mode_Register_error		; 101 (done)
 bra Mode_Register_error		; 110 (done)
 bra Mode_Register_error		; 111 (done)
 _OPTI

abs_short:
 btst #7,2(a2)
 beq Mode_Register_error
 move.l d2,d0
 swap d0
 ext.l d0
 bsr addr_to_asc_lu
 move.b #'.',(a0)+
 move.b #'W',(a0)+
 addq.w #2,d7
 addq.w #2,_I_size(a5)
 _TAS _I_sourcef(a5)
 bne.s .dest
.source:
 move.w #4,_I_sourcesize(a5)
 move.w #1,_I_sourceformat(a5)
 move.l d0,_I_sourceaddr(a5)
 bra Mode_Register_end
.dest:
 st _I_destf(a5)
 move.w #4,_I_destsize(a5)
 move.w #1,_I_destformat(a5)
 move.l d0,_I_destaddr(a5)
 bra Mode_Register_end

abs_long:
 btst #6,2(a2)
 beq Mode_Register_error
 move.l d2,d0
 bsr addr_to_asc_lu
 addq.w #4,d7
 addq.w #4,_I_size(a5)
 _TAS _I_sourcef(a5)
 bne.s .dest
.source:
 move.w #4,_I_sourcesize(a5)
 move.w #1,_I_sourceformat(a5)
 move.l d0,_I_sourceaddr(a5)
 bra Mode_Register_end
.dest:
 st _I_destf(a5)
 move.w #4,_I_destsize(a5)
 move.w #1,_I_destformat(a5)
 move.l d0,_I_destaddr(a5)
 bra Mode_Register_end

pc_ind_disp:
 btst #4,2(a2)
 beq Mode_Register_error

 move.l d2,d0
 clr.w d0
 swap d0
 ext.l d0
 add.l test_instruction(a6),d0
 addq.l #2,d0
 _TAS _I_sourcef(a5)
 bne.s .dest_disp
.source_disp:
 move.w #1,_I_sourceformat(a5)
 move.l d0,_I_sourceaddr(a5)
 bra.s .after_disp
.dest_disp:
 st _I_destf(a5)
 move.w #1,_I_destformat(a5)
 move.l d0,_I_destaddr(a5)
.after_disp:
 bsr addr_to_asc_lu
 move.b #'(',(a0)+
 lea pc_dat,a2
 bsr Copy_String
 move.b #')',(a0)+
 addq.w #2,d7
 addq.w #2,_I_size(a5)
 bra Mode_Register_end

immediate:
 btst #5,2(a2)
 beq Mode_Register_error
 cmp.w #'W',_I_format(a5)
 beq.s .word
 cmp.w #'L',_I_format(a5)
 beq .long
 cmp.w #'B',_I_format(a5)
 beq.s .byte
 tst.b fpu_disassembly(a6)
 beq Mode_Register_error
 cmp.w #'S',_I_format(a5)
 beq .single
 cmp.w #'D',_I_format(a5)
 beq .double
 cmp.w #'X',_I_format(a5)
 beq .extended
 cmp.w #'P',_I_format(a5)
 beq .packed
 bra Mode_Register_error

.byte:
 move.l d2,d0
 swap d0
 bsr dat_to_asc_bs
 addq #2,d7
 addq.w #2,_I_size(a5)
 bra Mode_Register_end

.word:
 move.l d2,d0
 swap d0
 cmp.w #ID_move_from_ccr,_I_ID_instruction(a5)
 beq.s .unsigned_word
 cmp.w #ID_move_to_ccr,_I_ID_instruction(a5)
 beq.s .unsigned_word
 cmp.w #ID_move_from_sr,_I_ID_instruction(a5)
 beq.s .unsigned_word
 cmp.w #ID_move_to_sr,_I_ID_instruction(a5)
 beq.s .unsigned_word
 bsr dat_to_asc_ws
 addq #2,d7
 addq.w #2,_I_size(a5)
 bra Mode_Register_end
.unsigned_word:
 bsr dat_to_asc_wu
 addq #2,d7
 addq.w #2,_I_size(a5)
 bra Mode_Register_end

.long:
 move.l d2,d0
 bsr addr_to_asc_ls
 addq #4,d7
 addq.w #4,_I_size(a5)
 bra Mode_Register_end

.single:
 addq #4,d7
 addq.w #4,_I_size(a5)
 moveq #1,d1
 bra.s .hexa_to_fpu_convert
.double:
 addq #8,d7
 addq.w #8,_I_size(a5)
 moveq #2,d1
 bra.s .hexa_to_fpu_convert
.extended:
 add.w #12,d7
 add.w #12,_I_size(a5)
 moveq #3,d1
.hexa_to_fpu_convert:
 move.l d2,-(sp)
 move.b #'#',(a0)+
 dc.w $f217,$4400	;fmove.s (sp),fp0
 lea -$c(sp),sp
 dc.w $f217,$6c11	;fmove.p fp0,(sp){#17}
 tst.b (sp)
 bpl.s .single_positive_mantissa
 move.b #'-',(a0)+
.single_positive_mantissa:
 move.b 3(sp),d0
 and.w #$f,d0
 add.w #'0',d0
 move.b d0,(a0)+
 move.b #'.',(a0)+
 addq.w #4,sp
 move.l sp,d2
.single_convert_loop:
 move.b (sp),d0
 lsr.b #4,d0
 add.b #'0',d0
 move.b d0,(a0)+
 move.b (sp),d0
 and.b #$f,d0
 add.b #'0',d0
 move.b d0,(a0)+
 move.b 1(sp),d0
 lsr.b #4,d0
 add.b #'0',d0
 move.b d0,(a0)+
 move.b 1(sp),d0
 and.b #$f,d0
 add.b #'0',d0
 move.b d0,(a0)+
 lea 2(sp),sp
 dbf d1,.single_convert_loop
 move.l d2,sp
.single_cut_string:
 cmp.b #'0',-(a0)
 beq.s .single_cut_string
 cmp.b #'.',(a0)
 beq.s .null_decimal
.not_null_decimal:
 addq.w #1,a0
.null_decimal:
 lea -4(sp),sp
 move.b #'E',(a0)+
 btst #6,(sp)
 beq.s .single_positive_exponant
 move.b #'-',(a0)+
.single_positive_exponant:
 move.b 2(sp),d0
 lsr.b #4,d0
 and.b #$f,d0
 beq.s .single_exp2
 add.b #"0",d0
 move.b d0,(a0)+
.single_exp2:
 move.b (sp),d0
 and.b #$f,d0
 beq.s .single_exp1
 add.b #"0",d0
 move.b d0,(a0)+
.single_exp1:
 move.b 1(sp),d0
 lsr.b #4,d0
 and.b #$f,d0
 beq.s .single_exp0
 add.b #"0",d0
 move.b d0,(a0)+
.single_exp0:
 move.b 1(sp),d0
 and.b #$f,d0
 beq.s .single_end_exp
 add.b #"0",d0
 move.b d0,(a0)+
.single_end_exp:
 cmp.b #'E',-1(a0)
 bne.s .not_null_exponant
 subq.w #1,a0
.not_null_exponant:
 lea $c(sp),sp
 addq.w #4,sp
 bra Mode_Register_end

.packed:
 move.l d2,d0
 move.l d3,d1
 move.l d4,d2
 move.l a2,-(sp)
 move.l a0,a2
 bsr get_packed
.copying_string:
 move.b (a0)+,d0
 beq.s .end_copy_string
 move.b d0,(a2)+
 bra.s .copying_string
.end_copy_string:
 move.l a2,a0
 move.l (sp)+,a2
 add.w #$c,d7
 add.w #$c,_I_size(a5)
 bra Mode_Register_end

others3:
 move.l d2,d0
 swap d0
 btst #8,d0
 beq pc_brief_format

 IFNE _68020|_68030
.full_format:
 addq.w #2,d7
 addq.w #2,_I_size(a5)
 clr.w -(sp)
 btst #6,d0
 beq.s .no_is
.is:
 bset #3,1(sp)
.no_is:
 and.w #7,d0
 or.w d0,(sp)
 move.w (sp)+,d0
 add.w d0,d0
 add.w d0,d0
 jmp .others3(pc,d0.w)

 _NOOPTI
.others3:
 bra pc_no_memory_indirection_with_index	; (done+interpretation)
 bra pc_indirect_preindexed_null_outer		; (done+interpretation)
 bra pc_indirect_preindexed_outer		; (done+interpretation)
 bra pc_indirect_preindexed_outer		; (done+interpretation)
 bra Mode_Register_error			; (done)
 bra pc_indirect_postindexed_null_outer		; (done+interpretation)
 bra pc_indirect_postindexed_outer		; (done+interpretation)
 bra pc_indirect_postindexed_outer		; (done+interpretation)
 bra pc_no_memory_indirection_no_index		; (done+interpretation)
 bra pc_memory_indirect_null_outer		; (done+interpretation)
 bra pc_memory_indirect_outer			; (done+interpretation)
 bra pc_memory_indirect_outer			; (done+interpretation)
 bra Mode_Register_error			; (done)
 bra Mode_Register_error			; (done)
 bra Mode_Register_error			; (done)
 bra Mode_Register_error			; (done)
 _OPTI

 ELSEIF
 bra Mode_Register_error
 ENDC

pc_brief_format:
; bra pc_reg_ind_index_8bit			; 111 (done+interpretation)

;pc_reg_ind_index_8bit:
; btst #3,2(a2)
; beq Mode_Register_error
;
; move.l d2,d0
; swap d0
; ext.w d0
; ext.l d0
; bsr .add_8bit
;
; tst.b relative_offset_flag(a6)
; beq.s .do_hex
; movem.l d0-d1/a2,-(sp)
;; st operande_flag(a6)
; ext.l d0
; and.w #7,d1
; add.w d1,d1
; add.w d1,d1
; add.l test_instruction(a6),d0
; addq.l #2,d0
; move.l d0,-(sp)
; _JSR find_in_table2
; movem.l (sp)+,d0
; bmi.b .no_symbol
; beq.b .on_symbol
; tst.b offset_symbols_flag(a6)
; beq.b .no_symbol
; sub.l VAR_VALUE(a2),d0
; move.l VAR_NAME(a2),a2
;.l1:
; move.b (a2)+,(a0)+
; bne.s .l1
; move.b #'+',-1(a0)
; addq.w #4,sp		;gross kludge to keep d0
; movem.l (sp)+,d1/a2
; bsr hex_to_asc_bu
; bra.s .symbol_found
;.on_symbol:
; move.l VAR_NAME(a2),a2
;.l2:
; move.b (a2)+,(a0)+
; bne.s .l2
; subq.w #1,a0
; movem.l (sp)+,d0-d1/a2
; bra.s .symbol_found
;.no_symbol:
; movem.l (sp)+,d0-d1/a2
;.do_hex:
; bsr hex_to_asc_bs
;.symbol_found:
;
; move.b #'(',(a0)+
; move.b #'P',(a0)+
; move.b #'C',(a0)+
; bsr .add_pc
; move.b #',',(a0)+
; bsr index_register_management
; move.b #')',(a0)+
; addq #2,d7
; addq.w #2,_I_size(a5)
; tst.b _I_destf(a5)
; bne.s .dest
;.source:
; move.l _I_sbasedisp(a5),d0
; add.l _I_spc(a5),d0
; add.l _I_sindexreg(a5),d0
; move.l d0,_I_sourceaddr(a5)
; bra Mode_Register_end
;.dest:
; move.l _I_dbasedisp(a5),d0
; add.l _I_dpc(a5),d0
; add.l _I_dindexreg(a5),d0
; move.l d0,_I_destaddr(a5)
; bra Mode_Register_end
;
;.add_pc:
; move.l test_instruction(a6),d0
; addq.l #2,d0
; tst.b _I_destf(a5)
; bne.s .dest_pc
;.source_pc:
; move.l d0,_I_spc(a5)
; rts
;.dest_pc:
; move.l d0,_I_dpc(a5)
; rts
;
;.add_8bit:
; tst.b _I_destf(a5)
; bne.s .dest_8bit
;.source_8bit:
; move.l d0,_I_sbasedisp(a5)
; rts
;.dest_8bit:
; move.l d0,_I_dbasedisp(a5)
; rts

pc_reg_ind_index_8bit:
 btst #3,2(a2)
 beq Mode_Register_error

 move.l d2,d0
 swap d0
 ext.w d0
 ext.l d0
 move.l test_instruction(a6),d1
 addq.l #2,d1

 tst.b _I_destf(a5)
 bne.s .dest_8bit
.source_8bit:
 move.l d0,_I_sbasedisp(a5)
 move.l d1,_I_spc(a5)
 bra.s .adest
.dest_8bit:
 move.l d0,_I_dbasedisp(a5)
 move.l d1,_I_dpc(a5)
.adest:
 add.l d1,d0
 bsr addr_to_asc_lu
 move.b #'(',(a0)+
 move.b #'P',(a0)+
 move.b #'C',(a0)+
 move.b #',',(a0)+
 bsr index_register_management
 move.b #')',(a0)+
 addq.w #2,d7
 addq.w #2,_I_size(a5)
 tst.b _I_destf(a5)
 bne.s .dest
.source:
 move.l _I_sbasedisp(a5),d0
 add.l _I_spc(a5),d0
 add.l _I_sindexreg(a5),d0
 move.l d0,_I_sourceaddr(a5)
 bra Mode_Register_end
.dest:
 move.l _I_dbasedisp(a5),d0
 add.l _I_dpc(a5),d0
 add.l _I_dindexreg(a5),d0
 move.l d0,_I_destaddr(a5)
 bra Mode_Register_end

 IFNE _68020!_68030
pc_no_memory_indirection_with_index:
 btst #2,2(a2)
 beq Mode_Register_error
 move.b #'(',(a0)+
 bsr bd_pc_management
 bmi Mode_Register_error
 bsr Add_comma
 bsr program_counter_management
 bsr Add_comma
 move.l d2,d0
 swap d0
 bsr index_register_management
 bsr Close_par
 tst.b _I_destf(a5)
 bne.s .dest
.source:
 move.l _I_sbasedisp(a5),d0
 add.l _I_spc(a5),d0
 add.l _I_sindexreg(a5),d0
 move.l d0,_I_sourceaddr(a5)
 bra Mode_Register_end
.dest:
 move.l _I_dbasedisp(a5),d0
 add.l _I_dpc(a5),d0
 add.l _I_dindexreg(a5),d0
 move.l d0,_I_destaddr(a5)
 bra Mode_Register_end

pc_indirect_preindexed_null_outer:
 btst #1,2(a2)
 beq Mode_Register_error
 move.b #'(',(a0)+
 move.b #'[',(a0)+
 bsr bd_pc_management
 bmi Mode_Register_error
 bsr Add_comma
 bsr program_counter_management
 bsr Add_comma
 bsr index_register_management
 bsr Close_bracket_par
 tst.b _I_destf(a5)
 bne.s .dest
.source:
 move.l _I_sbasedisp(a5),d0
 add.l _I_spc(a5),d0
 add.l _I_sindexreg(a5),d0
 lea _I_sourceaddr(a5),a4
 bra.s .do
.dest:
 move.l _I_dbasedisp(a5),d0
 add.l _I_dpc(a5),d0
 add.l _I_dindexreg(a5),d0
 lea _I_destaddr(a5),a4
.do:
 move.l d0,a2
 bsr ea_test_if_readable
 bmi.s .end
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
.end:
 bra Mode_Register_end

pc_indirect_preindexed_outer:
 btst #1,2(a2)
 beq Mode_Register_error
 move.b #'(',(a0)+
 move.b #'[',(a0)+
 bsr bd_pc_management
 bmi Mode_Register_error
 bsr Add_comma
 bsr program_counter_management
 bsr Add_comma
 bsr index_register_management
 bsr Close_bracket
 move.b #',',(a0)+
 bsr outer_displacement_management
 bsr Close_par
 tst.b _I_destf(a5)
 bne.s .dest
.source:
 move.l _I_sbasedisp(a5),d0
 add.l _I_spc(a5),d0
 add.l _I_sindexreg(a5),d0
 move.l d0,a2
 bsr ea_test_if_readable
; bmi Mode_Register_error
 bmi.s .end
 lea _I_sourceaddr(a5),a4
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
 move.l _I_souterdisp(a5),d0
 add.l d0,_I_sourceaddr(a5)
 bra Mode_Register_end
.dest:
 move.l _I_dbasedisp(a5),d0
 add.l _I_dpc(a5),d0
 add.l _I_dindexreg(a5),d0
 move.l d0,a2
 bsr ea_test_if_readable
; bmi Mode_Register_error
 bmi.s .end
 lea _I_destaddr(a5),a4
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
 move.l _I_douterdisp(a5),d0
 add.l d0,_I_destaddr(a5)
.end:
 bra Mode_Register_end

pc_indirect_postindexed_null_outer:
 btst #0,2(a2)
 beq Mode_Register_error
 move.b #'(',(a0)+
 move.b #'[',(a0)+
 bsr bd_pc_management
 bmi Mode_Register_error
 bsr Add_comma
 bsr program_counter_management
 bsr Close_bracket
 move.b #',',(a0)+
 bsr index_register_management
 bsr Close_par
 tst.b _I_destf(a5)
 bne.s .dest
.source:
 move.l _I_sbasedisp(a5),d0
 add.l _I_spc(a5),d0
 move.l d0,a2
 bsr ea_test_if_readable
; bmi Mode_Register_error
 bmi.s .end
 lea _I_sourceaddr(a5),a4
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
 move.l _I_sindexreg(a5),d0
 add.l d0,_I_sourceaddr(a5)
 bra Mode_Register_end
.dest:
 move.l _I_dbasedisp(a5),d0
 add.l _I_dpc(a5),d0
 move.l d0,a2
 bsr ea_test_if_readable
; bmi Mode_Register_error
 bmi.s .end
 lea _I_destaddr(a5),a4
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
 move.l _I_dindexreg(a5),d0
 add.l d0,_I_destaddr(a5)
.end:
 bra Mode_Register_end

pc_indirect_postindexed_outer:
 btst #0,2(a2)
 beq Mode_Register_error
 move.b #'(',(a0)+
 move.b #'[',(a0)+
 bsr bd_pc_management
 bmi Mode_Register_error
 bsr Add_comma
 bsr program_counter_management
 bsr Close_bracket
 move.b #',',(a0)+
 bsr index_register_management
 bsr Add_comma
 bsr outer_displacement_management
 bsr Close_par
 tst.b _I_destf(a5)
 bne.s .dest
.source:
 move.l _I_sbasedisp(a5),d0
 add.l _I_spc(a5),d0
 move.l d0,a2
 bsr ea_test_if_readable
; bmi Mode_Register_error
 bmi.s .end
 lea _I_sourceaddr(a5),a4
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
 move.l _I_sindexreg(a5),d0
 add.l _I_souterdisp(a5),d0
 add.l d0,_I_sourceaddr(a5)
 bra Mode_Register_end
.dest:
 move.l _I_dbasedisp(a5),d0
 add.l _I_dpc(a5),d0
 move.l d0,a2
 bsr ea_test_if_readable
; bmi Mode_Register_error
 bmi.s .end
 lea _I_destaddr(a5),a4
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
 move.l _I_dindexreg(a5),d0
 add.l _I_douterdisp(a5),d0
 add.l d0,_I_destaddr(a5)
.end:
 bra Mode_Register_end

pc_no_memory_indirection_no_index:
 btst #2,2(a2)
 beq Mode_Register_error
 move.b #'(',(a0)+
 bsr bd_pc_management
 bmi Mode_Register_error
 bsr Add_comma
 bsr program_counter_management
 bsr Close_par
 tst.b _I_destf(a5)
 bne.s .dest
.source:
 move.l _I_sbasedisp(a5),d0
 add.l _I_spc(a5),d0
 move.l d0,_I_sourceaddr(a5)
 bra Mode_Register_end
.dest:
 move.l _I_dbasedisp(a5),d0
 add.l _I_dpc(a5),d0
 move.l d0,_I_destaddr(a5)
 bra Mode_Register_end

pc_memory_indirect_null_outer:
 btst #1,2(a2)
 beq Mode_Register_error
 move.b #'(',(a0)+
 move.b #'[',(a0)+
 bsr bd_pc_management
 bmi Mode_Register_error
 bsr Add_comma
 bsr program_counter_management
 bsr Close_bracket_par
 tst.b _I_destf(a5)
 bne.s .dest
.source:
 move.l _I_sbasedisp(a5),d0
 add.l _I_spc(a5),d0
 lea _I_sourceaddr(a5),a4
 bra.s .do
.dest:
 move.l _I_dbasedisp(a5),d0
 add.l _I_dpc(a5),d0
 lea _I_destaddr(a5),a4
.do:
 move.l d0,a2
 bsr ea_test_if_readable
 bmi.s .end
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
.end:
 bra Mode_Register_end

pc_memory_indirect_outer:
 btst #1,2(a2)
 beq Mode_Register_error
 move.b #'(',(a0)+
 move.b #'[',(a0)+
 bsr bd_pc_management
 bmi Mode_Register_error
 bsr Add_comma
 bsr program_counter_management
 bsr Close_bracket
 move.b #',',(a0)+
 bsr outer_displacement_management
 bsr Close_par
 tst.b _I_destf(a5)
 bne.s .dest
.source:
 move.l _I_sbasedisp(a5),d0
 add.l _I_spc(a5),d0
 move.l d0,a2
 bsr ea_test_if_readable
; bmi Mode_Register_error
 bmi.s .end
 lea _I_sourceaddr(a5),a4
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
 move.l _I_souterdisp(a5),d0
 add.l d0,_I_sourceaddr(a5)
 bra Mode_Register_end
.dest:
 move.l _I_dbasedisp(a5),d0
 add.l _I_dpc(a5),d0
 move.l d0,a2
 bsr ea_test_if_readable
; bmi Mode_Register_error
 bmi.s .end
 lea _I_destaddr(a5),a4
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2)+,(a4)+
 move.b (a2),(a4)
 move.l _I_douterdisp(a5),d0
 add.l d0,_I_destaddr(a5)
.end:
 bra Mode_Register_end

program_counter_management:
 btst #23,d2
 beq.s .add_pc
.suppress_pc:
 move.b #'Z',(a0)+
.add_pc:
 move.b #'P',(a0)+
 move.b #'C',(a0)+
 move.l d0,-(sp)
 tst.b _I_destf(a5)
 bne.s .dest_pc
.source_pc:
 move.l test_instruction(a6),d0
 addq.l #2,d0
 move.l d0,_I_spc(a5)
 bra.s .after_pc
.dest_pc:
 move.l test_instruction(a6),d0
 addq.l #2,d0
 move.l d0,_I_dpc(a5)
.after_pc:
 move.l (sp)+,d0
 rts
 ENDC

Mode_Register_error:
 movem.l (sp)+,d1-d3
 moveq #-1,d0
 rts

Mode_Register_end:
 movem.l (sp)+,d1-d3
 moveq #0,d0
 rts

Add_comma:
 cmp.b #'[',-1(a0)
 beq.s .no_comma
 cmp.b #'(',-1(a0)
 beq.s .no_comma
 cmp.b #',',-1(a0)
 beq.s .no_comma
 move.b #',',(a0)+
.no_comma:
 rts

Close_bracket:
 cmp.b #',',-1(a0)
 bne.s .1
 subq.w #1,a0
.1:
 move.b #']',(a0)+
 rts

Close_par:
 cmp.b #',',-1(a0)
 bne.s .1
 subq.w #1,a0
.1:
 move.b #')',(a0)+
 rts

Close_bracket_par:
 cmp.b #',',-1(a0)
 bne.s .1
 subq.w #1,a0
.1:
 move.b #']',(a0)+
 move.b #')',(a0)+
 rts

_set_addr_flag:
 _TAS _I_sourcef(a5)
 beq.s .after_analyse
 st _I_destf(a5)
.after_analyse:
 rts

_find_real_sp:
 btst #5,sr_buf(a6)
 beq.s .usp
.ssp:
 IFNE _68020!_68030
 btst #4,sr_buf(a6)
 beq.s .isp
.msp:
 move.l msp_buf(a6),d1
 rts
.isp:
 move.l isp_buf(a6),d1
 ELSEIF
 move.l ssp_buf(a6),d1
 ENDC
 rts
.usp:
 move.l a7_buf(a6),d1
 rts

ea_test_if_readable:
 movem.l d0/a1,-(sp)
 move.l a2,a1
 bsr test_if_readable
 tst.l readable_buffer(a6)
 bne.s .error
 moveq #0,d0
 movem.l (sp)+,d0/a1
 rts
.error:
 moveq #-1,d0
 movem.l (sp)+,d0/a1
 rts

;  #] <ea> management:
;  #[ Miscellaneous:

Dc_w:
 move.w #ID_dc_w,_I_ID_instruction(a5)
 lea dc_w_dat,a2
 bsr Copy_String
 move.b #' ',(a0)+
 move.w (a1),d0
 bsr hex_to_asc_wu
 move.w #2,_I_size(a5)
 st _I_unimplemented(a5)
 st _I_exc(a5)
 sub.l a2,a2
 move.l a1,-(sp)
 lea $10(a2),a1
 bsr test_if_readable
 tst.l readable_buffer(a6)
 bne.s .error
 move.l (a1),d0
 move.l (sp)+,a1
 move.l d0,_I_branchaddr(a5)
 move.w #4,_I_exc_type(a5)
 rts
.error:
 move.l (sp)+,a1
 bra Error_Disassemble_line

Copy_String:
 move.b (a2),(a0)+
 tst.b (a2)+
 bne.s Copy_String
 subq.w #1,a0
 rts

_get_reti_routine:
 movem.l d0/a1,-(sp)
 btst #5,sr_buf(a6)
 bne.s .super
.user:
 tst.b d1
 bne.s .priv_violation
 move.l a7_buf(a6),a1
.test:
 addq.w #2,a1
 bsr test_if_readable
 tst.l readable_buffer(a6)
 bne.s .berror
 move.l (a1),_I_branchaddr(a5)
 movem.l (sp)+,d0/a1
 st _I_branchf(a5)
 st _I_branchyn(a5)
 rts
.super:
 IFNE _68020!_68030
 move.l isp_buf(a6),a1
 btst #4,sr_buf(a6)
 beq.s .test
 move.l msp_buf(a6),a1
 bra.s .test
 ELSEIF
 move.l ssp_buf(a6),a1
 addq.w #2,a1
 bra.s .test
 ENDC
.berror:
 lea 8.w,a1
 move.l (a1),_I_branchaddr(a5)
 movem.l (sp)+,d0/a1
 st _I_branchf(a5)
 st _I_branchyn(a5)
 rts
.priv_violation:
 lea $20.w,a1
 move.l (a1),_I_branchaddr(a5)
 movem.l (sp)+,d0/a1
 st _I_branchf(a5)
 st _I_branchyn(a5)
 rts

_get_rets_routine:
 movem.l d0/a1,-(sp)
 btst #5,sr_buf(a6)
 bne.s .super
.user:
 move.l a7_buf(a6),a1
.test:
 bsr test_if_readable
 tst.l readable_buffer(a6)
 bne.s .berror
 move.b (a1)+,_I_branchaddr(a5)
 move.b (a1)+,_I_branchaddr+1(a5)
 move.b (a1)+,_I_branchaddr+2(a5)
 move.b (a1)+,_I_branchaddr+3(a5)
 movem.l (sp)+,d0/a1
 st _I_branchf(a5)
 st _I_branchyn(a5)
 rts
.super:
 IFNE _68020!_68030
 move.l isp_buf(a6),a1
 btst #4,sr_buf(a6)
 beq.s .test
 move.l msp_buf(a6),a1
 bra.s .test
 ELSEIF
 move.l ssp_buf(a6),a1
 addq.w #2,a1
 bra.s .test
 ENDC
.berror:
 move.l 8.w,a1
 move.l (a1),_I_branchaddr(a5)
 movem.l (sp)+,d0/a1
 st _I_branchf(a5)
 st _I_branchyn(a5)
 rts

;  #] Miscellaneous:
;  #[ unsigned convertion:

dat_to_asc_bu:
 move.b #'#',(a0)+
hex_to_asc_bu:
 movem.l d0-d2/a2,-(sp)
 moveq #1,d2
 cmp.b #9,d0
 bls.s .1
 move.b #'$',(a0)+
.1:
 lsl.w #8,d0
 swap d0
 lea conversion_buffer(a6),a2
 move.l a2,-(sp)
general_dat_to_asc:
 rol.l #4,d0
 move.b d0,d1
 and.b #$f,d1
 add.b #'0',d1
 cmp.b #'9',d1
 ble.s .1
 addq.w #7,d1
.1:
 move.b d1,(a2)+
 dbf d2,general_dat_to_asc
 clr.b (a2)
 tst.b optimize_address(a6)
 beq.s .2
 move.l (sp),a2
.3:
 move.b (a2)+,d0
 beq.s .2
 cmp.b #'0',d0
 bne.s .2
 addq.l #1,(sp)
 bra.s .3
.2:
 move.l (sp)+,a2
 tst.b (a2)
 bne.s .4
 subq.w #1,a2
.4:
 bsr Copy_String
 movem.l (sp)+,d0-d2/a2
 rts

dat_to_asc_wu:
 move.b #'#',(a0)+
hex_to_asc_wu:
 movem.l d0-d2/a2,-(sp)
 moveq #3,d2
 cmp.w #9,d0
 bls.s .1
 move.b #'$',(a0)+
.1:
 swap d0
 lea conversion_buffer(a6),a2
 move.l a2,-(sp)
 bra.s general_dat_to_asc

dat_to_asc_lu:
 move.b #'#',(a0)+
hex_to_asc_lu:
 movem.l d0-d2/a2,-(sp)
 moveq #7,d2
 cmp.l #9,d0
 bls.s .1
 move.b #'$',(a0)+
.1:
 lea conversion_buffer(a6),a2
 move.l a2,-(sp)
 bra.s general_dat_to_asc

;  #] unsigned convertion:
;  #[ signed convertion:

dat_to_asc_bs:
 move.b #'#',(a0)+
hex_to_asc_bs:
 movem.l d0-d2/a2,-(sp)
 moveq #1,d2
 tst.b d0
 bpl.s .plus
 neg.b d0
 move.b #'-',(a0)+
.plus:
 cmp.b #9,d0
 bls.s .1
 move.b #'$',(a0)+
.1:
 lsl.w #8,d0
 swap d0
 lea conversion_buffer(a6),a2
 move.l a2,-(sp)
 bra general_dat_to_asc

dat_to_asc_ws:
 move.b #'#',(a0)+
hex_to_asc_ws:
 movem.l d0-d2/a2,-(sp)
 moveq #3,d2
 tst.w d0
 bpl.s .plus
 neg.w d0
 move.b #'-',(a0)+
.plus:
 cmp.w #9,d0
 bls.s .1
 move.b #'$',(a0)+
.1:
 swap d0
 lea conversion_buffer(a6),a2
 move.l a2,-(sp)
 bra general_dat_to_asc

dat_to_asc_ls:
 move.b #'#',(a0)+
hex_to_asc_ls:
 movem.l d0-d2/a2,-(sp)
 moveq #7,d2
 tst.l d0
 bpl.s .plus
 neg.l d0
 move.b #'-',(a0)+
.plus:
 cmp.l #9,d0
 bls.s .1
 move.b #'$',(a0)+
.1:
 lea conversion_buffer(a6),a2
 move.l a2,-(sp)
 bra general_dat_to_asc

dat_to_asc_w_3:
 movem.l a2-a3,-(sp)
_43:
 lea addr_buffer_2(a6),a3
 clr.l (a3)
 clr.l 4(a3)
 lea addr_buffer_1(a6),a2
 bsr test_if_readable2
 move.w #"**",(a2)
 tst.b readable_buffer(a6)
 bne.s .1
 move.b (a1),(a2)
.1:
 tst.b readable_buffer+1(a6)
 bne.s .2
 move.b 1(a1),1(a2)
.2:
 moveq #1,d1
 bra _0

dat_to_asc_l_3:			; datas
 clr.l readable_buffer(a6)
 movem.l a2-a3,-(sp)
 lea addr_buffer_2(a6),a3
 clr.l (a3)
 clr.l 4(a3)
 lea addr_buffer_1(a6),a2
 move.b (a1),(a2)
 move.b 1(a1),1(a2)
 move.b 2(a1),2(a2)
 move.b 3(a1),3(a2)
 tst.b optimise_address(a6)
 beq.s .2
 subq.w #1,a0
 tst.l (a2)
 bmi.s .1
 cmp.l #$a,(a2)
 blt.s .2
.1:
 addq.w #1,a0
.2:
 moveq #3,d1
_0:
 move.l a4,-(sp)
 lea readable_buffer(a6),a4
_1:
 move.b (a2),d0
 lsr.b #4,d0
 cmp.b #$a,d0
 bge.s .1
 add.b #$30,d0
 bra.s .2
.1:
 add.b #$37,d0
.2:
 move.b d0,(a3)+
 move.b (a2)+,d0
 and.w #$f,d0
 cmp.b #$a,d0
 bge.s .3
 add.b #$30,d0
 bra.s .4
.3:
 add.b #$37,d0
.4:
 move.b d0,(a3)+
;
 tst.b (a4)+
 beq.s .13
 move.b #"*",-2(a3)
 move.b #"*",-1(a3)
.13:
;
 dbf d1,_1
 tst.b optimise_address(a6)
 beq.s .10
 lea addr_buffer_2(a6),a3
.6:
 cmp.b #$30,(a3)+
 beq.s .6
 tst.b -1(a3)
 bne.s .9
 subq.w #1,a3
.9:
 subq.w #1,a3
 tst.b print_bloc_flag(a6)
 beq.s .8
 tst.b pb_allowed_flag(a6)
 beq.s .8
 subq.w #1,a0
 move.b #"L",(a0)+
.8:
 move.b (a3)+,d0
 beq.s .11
 move.b d0,(a0)+
 bra.s .8
.10:
 lea addr_buffer_2(a6),a3
.12:
 move.b (a3)+,d0
 beq.s .11
 move.b d0,(a0)+
 bra.s .12
.11:
 move.l (sp)+,a4
symbol_founded:
 sf pb_allowed_flag(a6)
 movem.l (sp)+,a2-a3
 rts

;  #] signed convertion:
;  #[ address convertion:

addr_to_asc_lu:
 movem.l d0-d2/a2,-(sp)
 move.l d0,-(sp)
; st operande_flag(a6)
 _JSR find_in_table2
 movem.l (sp)+,d0
 bmi.b .no_symbol
 beq.b .on_symbol
 tst.b offset_symbols_flag(a6)
 beq.b .no_symbol
 sub.l VAR_VALUE(a2),d0
 move.l VAR_NAME(a2),a2
.l1:
 move.b (a2)+,(a0)+
 bne.s .l1
 move.b #'+',-1(a0)
 tst.l d0
 bmi.s .no_symbol
 moveq #9,d1
 cmp.l d1,d0
 bls.s .no_dollar
.no_symbol:
 move.b #'$',(a0)+
.no_dollar:
 moveq #7,d2
 lea conversion_buffer(a6),a2
 move.l a2,-(sp)
 bra general_dat_to_asc
.on_symbol:
 move.l VAR_NAME(a2),a2
.l2:
 move.b (a2)+,(a0)+
 bne.s .l2
 subq.w #1,a0
 sf pb_allowed_flag(a6)
 movem.l (sp)+,d0-d2/a2
 rts

addr_to_asc_ls:
 move.b #'#',(a0)+
 movem.l d0-d2/a2,-(sp)
 move.l d0,-(sp)
; st operande_flag(a6)
 _JSR find_in_table2
 movem.l (sp)+,d0
 bmi.b .no_symbol
 beq.b .on_symbol
 tst.b offset_symbols_flag(a6)
 beq.b .no_symbol
 sub.l VAR_VALUE(a2),d0
 move.l VAR_NAME(a2),a2
.l1:
 move.b (a2)+,(a0)+
 bne.s .l1
 move.b #'+',-1(a0)
.no_symbol:
; moveq #7,d2
 lea conversion_buffer(a6),a2
 bsr hex_to_asc_ls
 movem.l (sp)+,d0-d2/a2
 rts
.on_symbol:
 move.l VAR_NAME(a2),a2
.l2:
 move.b (a2)+,(a0)+
 bne.s .l2
 subq.w #1,a0
 sf pb_allowed_flag(a6)
 movem.l (sp)+,d0-d2/a2
 rts

get_packed:
 movem.l d0-d2,-(sp)
 lea evaluator_buffer(a6),a0
 move.l d0,(a0)
 move.l d1,4(a0)
 move.l d2,8(a0)
; fmove.x (a0),fp0
 dc.w $f210,$4800
 moveq #49,d0
.cls_buffer:
 clr.l (a0)+
 dbf d0,.cls_buffer
 lea evaluator_buffer(a6),a0
 lea -$c(sp),sp
; fmove.p fp0,(sp){#17}
 dc.w $f217,$6c11
 moveq #3,d1
 tst.b (sp)
 bpl.s .packed_positive_mantissa
 move.b #'-',(a0)+
.packed_positive_mantissa:
 move.b 3(sp),d0
 and.w #$f,d0
 add.w #'0',d0
 move.b d0,(a0)+
 move.b #'.',(a0)+
 addq.w #4,sp
 move.l sp,d2
.packed_convert_loop:
 move.b (sp),d0
 lsr.b #4,d0
 add.b #'0',d0
 move.b d0,(a0)+
 move.b (sp),d0
 and.b #$f,d0
 add.b #'0',d0
 move.b d0,(a0)+
 move.b 1(sp),d0
 lsr.b #4,d0
 add.b #'0',d0
 move.b d0,(a0)+
 move.b 1(sp),d0
 and.b #$f,d0
 add.b #'0',d0
 move.b d0,(a0)+
 lea 2(sp),sp
 dbf d1,.packed_convert_loop
 move.l d2,sp
.packed_cut_string:
 cmp.b #'0',-(a0)
 beq.s .packed_cut_string
 cmp.b #'.',(a0)
 beq.s .null_decimal
.not_null_decimal:
 addq.w #1,a0
.null_decimal:
 lea -4(sp),sp
 move.b #'E',(a0)+
 btst #6,(sp)
 beq.s .packed_positive_exponant
 move.b #'-',(a0)+
.packed_positive_exponant:
 move.b 2(sp),d0
 lsr.b #4,d0
 and.b #$f,d0
 beq.s .packed_exp2
 add.b #"0",d0
 move.b d0,(a0)+
.packed_exp2:
 move.b (sp),d0
 and.b #$f,d0
 beq.s .packed_exp1
 add.b #"0",d0
 move.b d0,(a0)+
.packed_exp1:
 move.b 1(sp),d0
 lsr.b #4,d0
 and.b #$f,d0
 beq.s .packed_exp0
 add.b #"0",d0
 move.b d0,(a0)+
.packed_exp0:
 move.b 1(sp),d0
 and.b #$f,d0
 beq.s .packed_end_exp
 add.b #"0",d0
 move.b d0,(a0)+
.packed_end_exp:
 cmp.b #'E',-1(a0)
 bne.s .not_null_exponant
 subq.w #1,a0
.not_null_exponant:
 lea $c(sp),sp
 lea evaluator_buffer(a6),a0
 movem.l (sp)+,d0-d2
 rts

;  #] address convertion:
;  #[ Undo management:

Undo_management:
;
;
;
 rts

;  #] Undo management:
;  #[ Exceptions management:

can_t_read_4:
 move.b #"*",(a0)+
 move.b #"*",(a0)+
can_t_read_2:
 move.b #"*",(a0)+
can_t_read_1:
 move.b #"*",(a0)+
 rts

 IFNE	ATARIST
test_if_readable:
 movem.l d6-d7/a0-a1/a4,-(sp)
 bsr save_for_readable
 bra.s test_4
test_10:
 tst.b (a1)
 nop
 addq.w #1,a1
 addq.w #1,a4
 tst.b (a1)
 nop
 addq.w #1,a1
 addq.w #1,a4
 tst.b (a1)
 nop
 addq.w #1,a1
 addq.w #1,a4
 tst.b (a1)
 nop
 addq.w #1,a1
 addq.w #1,a4
 tst.b (a1)
 nop
 addq.w #1,a1
 addq.w #1,a4
 tst.b (a1)
 nop
 addq.w #1,a1
 addq.w #1,a4
test_4:
 tst.b (a1)
 nop
 addq.w #1,a1
 addq.w #1,a4
 tst.b (a1)
 nop
 addq.w #1,a1
 addq.w #1,a4
test_2:
 tst.b (a1)
 nop
 addq.w #1,a1
 addq.w #1,a4
test_1:
 tst.b (a1)
 nop
 bsr get_vbr
 move.l d7,8(a0)
 move.l d6,$60(a0)
 movem.l (sp)+,d6-d7/a0-a1/a4
 rts

test_if_readable2:
 movem.l d6-d7/a0-a1/a4,-(sp)
 bsr.s save_for_readable
 bra.s test_2

test_if_readable3:
 movem.l d6-d7/a0-a1/a4,-(sp)
 bsr.s save_for_readable
 move.l $c+4(sp),a1
 bra.s test_1

test_if_readable4:
 movem.l d6-d7/a0-a1/a4,-(sp)
 bsr.s save_for_readable
 move.l a2,a1
 bra test_10

test_if_readable5:
 movem.l d6-d7/a0-a1/a4,-(sp)
 bsr.s save_for_readable
 bra.s test_1

save_for_readable:
 movem.l a0-a1,-(sp)
 bsr.s get_vbr
 move.l 8(a0),d7
 move.l $60(a0),d6
 lea no_readable(pc),a1
 move.l a1,8(a0)
 lea internal_spurious(pc),a1
 move.l a1,$60(a0)
 lea readable_buffer(a6),a4
 clr.l (a4)
 clr.l 4(a4)
 clr.w 8(a4)
 movem.l (sp)+,a0-a1
 rts

 ENDC ; de ATARIST
 
	IFNE	AMIGA
test_if_readable:
	jmp	amig_test_if_readable
test_if_readable3:
	jmp	amig_test_if_readable3
test_if_readable4:
	jmp	amig_test_if_readable4
test_if_readable5:
	jmp	amig_test_if_readable5
test_if_readable2:
	jmp	amig_test_if_readable2
	ENDC	; d'AMIGA

no_readable:
 st (a4)
 IFNE _68030
 tst.b chip_type(a6)
 beq.s .68000
 bclr #0,$a(sp)
 rte
.68000:
 ENDC
 addq.w #8,sp
 rte

;returns in a0 vbr @ (0 on 68000)
get_vbr:
	suba.l a0,a0
	IFNE _68030
	tst.b chip_type(a6)
	beq.s .ok
 	IFNE	A3000
 	move.l	d0,-(sp)
 	jsr	super_on
 	dc.l	$4e7a8801	;movec vbr,a0
 	tst.l	d0
 	beq.s	.already_super
 	move.l	a0,-(sp)
 	move.l	d0,a0
 	jsr	super_off
 	move.l	(sp)+,a0
 .already_super:
 	move.l	(sp)+,d0
 	ELSEIF
	_20
	movec vbr,a0
	_00
	nop
	ENDC ; de A3000
.ok:
	ENDC ; de _68030
 rts

internal_spurious:
 st (a4)
 IFNE _68030
 tst.b chip_type(a6)
 beq.s .68000
 _JSR flash
 bclr #0,$a(sp)
.68000:
 ENDC
 rte

;  #] Exceptions management:
;  #[ Arrow management:

modify_arrow:
 tst.b pc_pointer_flag(a6)
 beq.s .end
 tst.b _I_branchyn(a5)
 beq.s .end
 move.l _I_branchaddr(a5),d0
 move.l d0,-(sp)
 move.l arrow_addr(a6),a2
 cmp.l pc_buf(a6),d0
 blt.s .up
 bgt.s .down
.none:
 IFNE	ATARIST
 moveq #$df,d0
 ENDC
 IFNE	AMIGA
 moveq	#$e,d0
 ENDC
 bra.s .poke_pc
.end:
 rts
.up:
 moveq #1,d0
 bra.s .poke_pc
.down:
 moveq #2,d0
.poke_pc:
 move.b d0,-2(a2)
 move.b d0,pc_marker(a6)
 move.b #' ',-1(a2)
 move.l (sp)+,d0
 rts

dbt_arrow:
dbf_arrow:
dbhi_arrow:
dbls_arrow:
dbcc_arrow:
dbcs_arrow:
dbne_arrow:
dbeq_arrow:
dbvc_arrow:
dbvs_arrow:
dbpl_arrow:
dbmi_arrow:
dbge_arrow:
dblt_arrow:
dbgt_arrow:
dble_arrow:
hi_arrow:
ls_arrow:
cc_arrow:
cs_arrow:
ne_arrow:
eq_arrow:
vc_arrow:
vs_arrow:
pl_arrow:
mi_arrow:
ge_arrow:
lt_arrow:
gt_arrow:
le_arrow:
 rts

;  #] Arrow management:
; DATA
 IFNE ATARIST!ATARITT
;  #[ TRAP #2 comments:
;
; VDI table
;
 dc.b 0
vdi_text_table:
 dc.b -1,-2,"vq_gdos",0
 dc.b -1,-1,"v_set_app_buff",0	;FSM Gdos
 dc.b -1,1,'v_opnwk',0
 dc.b -1,2,'v_clswk',0
 dc.b -1,3,'v_clrwk',0
 dc.b -1,4,'v_updwk',0
 dc.b -1,6,'v_pline',0
 dc.b -1,7,'v_pmarker',0
 dc.b -1,8,'v_gtext',0
 dc.b -1,9,'v_fillarea',0
 dc.b -1,10,'v_cellarray',0
 dc.b -1,11,'v_bez',0		;FSM Gdos
 dc.b -1,12,'vst_height',0
 dc.b -1,13,'vst_rotation',0
 dc.b -1,14,'vs_color',0
 dc.b -1,15,'vsl_type',0
 dc.b -1,16,'vsl_width',0
 dc.b -1,17,'vsl_color',0
 dc.b -1,18,'vsm_type',0
 dc.b -1,19,'vsm_height',0
 dc.b -1,20,'vsm_color',0
 dc.b -1,21,'vst_font',0
 dc.b -1,22,'vst_color',0
 dc.b -1,23,'vsf_interior',0
 dc.b -1,24,'vsf_style',0
 dc.b -1,25,'vsf_color',0
 dc.b -1,26,'vq_color',0
 dc.b -1,27,'vq_cellarray',0
 dc.b -1,28,'v_locator',0
 dc.b -1,29,'v_valuator',0
 dc.b -1,30,'v_choice',0
 dc.b -1,31,'v_string',0
 dc.b -1,32,'vswr_mode',0
 dc.b -1,33,'vsin_mode',0
 dc.b -1,35,'vql_attributes',0
 dc.b -1,36,'vqm_attributes',0
 dc.b -1,37,'vqf_attributes',0
 dc.b -1,38,'vqt_attributes',0
 dc.b -1,39,'vst_alignment',0
 dc.b -1,100,'v_opnvwk',0
 dc.b -1,101,'v_clsvwk',0
 dc.b -1,102,'vq_extnd',0
 dc.b -1,103,'v_contourfill',0
 dc.b -1,104,'vsf_perimeter',0
 dc.b -1,105,'v_get_pixel',0
 dc.b -1,106,'vst_effects',0
 dc.b -1,107,'vst_point',0
 dc.b -1,108,'vsl_ends',0
 dc.b -1,109,'vro_cpyfm',0
 dc.b -1,110,'vr_trnfm',0
 dc.b -1,111,'vsc_form',0
 dc.b -1,112,'vsf_udpat',0
 dc.b -1,113,'vsl_udsty',0
 dc.b -1,114,'vr_recfl',0
 dc.b -1,115,'vqin_mode',0
 dc.b -1,116,'vqt_extent',0
 dc.b -1,117,'vqt_width',0
 dc.b -1,118,'vex_timv',0
 dc.b -1,119,'vst_load_fonts',0
 dc.b -1,120,'vst_unload_fonts',0
 dc.b -1,121,'vrt_cpyfm',0
 dc.b -1,122,'v_show_c',0
 dc.b -1,123,'v_hide_c',0
 dc.b -1,124,'vq_mouse',0
 dc.b -1,125,'vex_butv',0
 dc.b -1,126,'vex_motv',0
 dc.b -1,127,'vex_curv',0
 dc.b -1,128,'vq_key_s',0
 dc.b -1,129,'vs_clip',0
 dc.b -1,130,'vqt_name',0
 dc.b -1,131,'vqt_fontinfo',0
;FSM Gdos
 dc.b -1,240,"vqt_f_extent",0
 dc.b -1,241,"v_ftext",0
 dc.b -1,242,"v_killoutline",0
 dc.b -1,243,"v_getoutline",0
 dc.b -1,244,"vst_scratch",0
 dc.b -1,245,"vst_error",0
 dc.b -1,246,"vst_arbpt",0
 dc.b -1,247,"vqt_advance",0
 dc.b -1,248,"vqt_devinfo",0
 dc.b -1,249,"v_savecache",0
 dc.b -1,250,"v_loadcache",0
 dc.b -1,251,"v_flushcache",0
 dc.b -1,252,"vst_setsize",0
 dc.b -1,253,"vst_skew",0
 dc.b -1,254,"vqt_get_tables",0
 dc.b -1,255,"vqt_cachesize",0

; 5 = escapes_text_table
 dc.b 1,5,'vq_chcells',0
 dc.b 2,5,'v_exit_cur',0
 dc.b 3,5,'v_enter_cur',0
 dc.b 4,5,'v_curup',0
 dc.b 5,5,'v_curdown',0
 dc.b 6,5,'v_curright',0
 dc.b 7,5,'v_curleft',0
 dc.b 8,5,'v_curhome',0
 dc.b 9,5,'v_eeos',0
 dc.b 10,5,'v_eeol',0
 dc.b 11,5,'vs_curaddress',0
 dc.b 12,5,'v_curtext',0
 dc.b 13,5,'v_rvon',0
 dc.b 14,5,'v_rvoff',0
 dc.b 15,5,'vq_curaddress',0
 dc.b 16,5,'vq_tabstatus',0
 dc.b 17,5,'v_hardcopy',0
 dc.b 18,5,'v_dspcur',0
 dc.b 19,5,'v_rmcur',0
 dc.b 20,5,'v_form_adv',0
 dc.b 21,5,'v_output_window',0
 dc.b 22,5,'v_clear_disp_list',0
 dc.b 23,5,'v_bit_image',0
 dc.b 24,5,'vq_scan',0
 dc.b 25,5,'v_alpha_text',0
 dc.b 32,5,'v_bez_qual',0	;FSM Gdos
 dc.b 60,5,'vs_palette',0
 dc.b 61,5,'v_sound',0
 dc.b 62,5,'vs_mute',0
 dc.b 82,5,'vt_axis',0
 dc.b 83,5,'vt_origin',0
 dc.b 84,5,'vqt_dimension',0
 dc.b 85,5,'vt_alignment',0
 dc.b 91,5,'vqp_films',0
 dc.b 92,5,'vqp_state',0
 dc.b 93,5,'vsp_state',0
 dc.b 94,5,'vsp_save',0
 dc.b 95,5,'vsp_message',0
 dc.b 96,5,'vqp_error',0
 dc.b 98,5,'v_meta_extents',0
 dc.b 99,5,'v_write_meta',0
 dc.b 100,5,'vm_filename',0
 dc.b 208,5,"vs_pgcount",0	;Esc 2000

; 11 = graphics_text_table
 dc.b 1,11,'v_bar',0
 dc.b 2,11,'v_arc',0
 dc.b 3,11,'v_pieslice',0
 dc.b 4,11,'v_circle',0
 dc.b 5,11,'v_ellipse',0
 dc.b 6,11,'v_ellarc',0
 dc.b 7,11,'v_ellpie',0
 dc.b 8,11,'v_rbox',0
 dc.b 9,11,'v_rfbox',0
 dc.b 10,11,'v_justified',0
 dc.b 0,0

;
; AES table
;
 dc.b 0
aes_text_table:
 dc.b -1,10,'appl_init',0
 dc.b -1,11,'appl_read',0
 dc.b -1,12,'appl_write',0
 dc.b -1,13,'appl_find',0
 dc.b -1,14,'appl_tplay',0
 dc.b -1,15,'appl_trecord',0
 dc.b -1,18,'appl_search',0	;4.0
 dc.b -1,19,'appl_exit',0
 dc.b -1,20,'evnt_keybd',0
 dc.b -1,21,'evnt_button',0
 dc.b -1,22,'evnt_mouse',0
 dc.b -1,23,'evnt_mesag',0
 dc.b -1,24,'evnt_timer',0
 dc.b -1,25,'evnt_multi',0
 dc.b -1,26,'evnt_dclick',0
 dc.b -1,30,'menu_bar',0
 dc.b -1,31,'menu_icheck',0
 dc.b -1,32,'menu_ienable',0
 dc.b -1,33,'menu_tnormal',0
 dc.b -1,34,'menu_text',0
 dc.b -1,35,'menu_register',0
 dc.b -1,40,'objc_add',0
 dc.b -1,41,'objc_delete',0
 dc.b -1,42,'objc_draw',0
 dc.b -1,43,'objc_find',0
 dc.b -1,44,'objc_offset',0
 dc.b -1,45,'objc_order',0
 dc.b -1,46,'objc_edit',0
 dc.b -1,47,'objc_change',0
 dc.b -1,50,'form_do',0
 dc.b -1,51,'form_dial',0
 dc.b -1,52,'form_alert',0
 dc.b -1,53,'form_error',0
 dc.b -1,54,'form_center',0
 dc.b -1,70,'graf_rubberbox',0
 dc.b -1,71,'graf_dragbox',0
 dc.b -1,72,'graf_movebox',0
 dc.b -1,73,'graf_growbox',0
 dc.b -1,74,'graf_shrinkbox',0
 dc.b -1,75,'graf_watchbox',0
 dc.b -1,76,'graf_slidebox',0
 dc.b -1,77,'graf_handle',0
 dc.b -1,78,'graf_mouse',0
 dc.b -1,79,'graf_mkstate',0
 dc.b -1,80,'scrp_read',0
 dc.b -1,81,'scrp_write',0
 dc.b -1,90,'fsel_input',0
 dc.b -1,91,'fsel_exinput',0	;3.0
 dc.b -1,100,'wind_create',0
 dc.b -1,101,'wind_open',0
 dc.b -1,102,'wind_close',0
 dc.b -1,103,'wind_delete',0
 dc.b -1,104,'wind_get',0
 dc.b -1,105,'wind_set',0
 dc.b -1,106,'wind_find',0
 dc.b -1,107,'wind_update',0
 dc.b -1,108,'wind_calc',0
 dc.b -1,109,'wind_new',0	;3.0
 dc.b -1,110,'rsrc_load',0
 dc.b -1,111,'rsrc_free',0
 dc.b -1,112,'rsrc_gaddr',0
 dc.b -1,113,'rsrc_saddr',0
 dc.b -1,114,'rsrc_obfix',0
 dc.b -1,115,'rsrc_rcfix',0	;4.0
 dc.b -1,120,'shel_read',0
 dc.b -1,121,'shel_write',0
 dc.b -1,122,'shel_get',0
 dc.b -1,123,'shel_put',0
 dc.b -1,124,'shel_find',0
 dc.b -1,125,'shel_envrn',0
 dc.b 0,0

;  #] TRAP #2 comments:
 ENDC
 IFNE AMIGA
;  #[ Libs comments:

; Exec lib

; Dos lib

; Graphic lib

;  #] Libs comments:
 ENDC
 even
;  #[ Strings:
;branch_condition:
; dc.b "T",0,0,0			; true
; dc.l $deadbeef
; dc.b "F",0,0,0			; false
; dc.l $deadbeef
; dc.b "HI",0,0			; higher
; dc.l hi_arrow
; dc.b "LS",0,0			; lower or same
; dc.l ls_arrow
; dc.b "CC",0,0			; carry clear
; dc.l cc_arrow
; dc.b "CS",0,0			; carry set
; dc.l cs_arrow
; dc.b "NE",0,0			; not equal
; dc.l ne_arrow
; dc.b "EQ",0,0			; equal
; dc.l eq_arrow
; dc.b "VC",0,0			; overflow clear
; dc.l vc_arrow
; dc.b "VS",0,0			; overflow set
; dc.l vs_arrow
; dc.b "PL",0,0			; plus
; dc.l pl_arrow
; dc.b "MI",0,0			; minus
; dc.l mi_arrow
; dc.b "GE",0,0			; greater or equal
; dc.l ge_arrow
; dc.b "LT",0,0			; lower than
; dc.l lt_arrow
; dc.b "GT",0,0			; greater than
; dc.l gt_arrow
; dc.b "LE",0,0			; lower or equal
; dc.l le_arrow
;
; even
;
;dbcc_condition:
; dc.l dbt_arrow
; dc.l dbf_arrow
; dc.l dbhi_arrow
; dc.l dbls_arrow
; dc.l dbcc_arrow
; dc.l dbcs_arrow
; dc.l dbne_arrow
; dc.l dbeq_arrow
; dc.l dbvc_arrow
; dc.l dbvs_arrow
; dc.l dbpl_arrow
; dc.l dbmi_arrow
; dc.l dbge_arrow
; dc.l dblt_arrow
; dc.l dbgt_arrow
; dc.l dble_arrow

 IFNE _68020!_68030
FPU_instructions_table:
 dc.w $0001				; 1
 dc.l _fint_reg_reg
 dc.w $4001				; 2
 dc.l _fint_ea_reg
 dc.w $0002				; 3
 dc.l _fsinh_reg_reg
 dc.w $4002				; 4
 dc.l _fsinh_ea_reg
 dc.w $0003				; 5
 dc.l _fintrz_reg_reg
 dc.w $4003				; 6
 dc.l _fintrz_ea_reg
 dc.w $0004				; 7
 dc.l _fsqrt_reg_reg
 dc.w $4004				; 8
 dc.l _fsqrt_ea_reg
 dc.w $0006				; 9
 dc.l _flognp1_reg_reg
 dc.w $4006				; 10
 dc.l _flognp1_ea_reg
 dc.w $0008				; 11
 dc.l _fetoxm1_reg_reg
 dc.w $4008				; 12
 dc.l _fetoxm1_ea_reg
 dc.w $0009				; 13
 dc.l _ftanh_reg_reg
 dc.w $4009				; 14
 dc.l _ftanh_ea_reg
 dc.w $000a				; 15
 dc.l _fatan_reg_reg
 dc.w $400a				; 16
 dc.l _fatan_ea_reg
 dc.w $000c				; 17
 dc.l _fasin_reg_reg
 dc.w $400c				; 18
 dc.l _fasin_ea_reg
 dc.w $000d				; 19
 dc.l _fatanh_reg_reg
 dc.w $400d				; 20
 dc.l _fatanh_ea_reg
 dc.w $000e				; 21
 dc.l _fsin_reg_reg
 dc.w $400e				; 22
 dc.l _fsin_ea_reg
 dc.w $000f				; 23
 dc.l _ftan_reg_reg
 dc.w $400f				; 24
 dc.l _ftan_ea_reg
 dc.w $0010				; 25
 dc.l _fetox_reg_reg
 dc.w $4010				; 26
 dc.l _fetox_ea_reg
 dc.w $0011				; 27
 dc.l _ftwotox_reg_reg
 dc.w $4011				; 28
 dc.l _ftwotox_ea_reg
 dc.w $0012				; 29
 dc.l _ftentox_reg_reg
 dc.w $4012				; 30
 dc.l _ftentox_ea_reg
 dc.w $0014				; 31
 dc.l _flogn_reg_reg
 dc.w $4014				; 32
 dc.l _flogn_ea_reg
 dc.w $0015				; 33
 dc.l _flog10_reg_reg
 dc.w $4015				; 34
 dc.l _flog10_ea_reg
 dc.w $0016				; 35
 dc.l _flog2_reg_reg
 dc.w $4016				; 36
 dc.l _flog2_ea_reg
 dc.w $0018				; 37
 dc.l _fabs_reg_reg
 dc.w $4018				; 38
 dc.l _fabs_ea_reg
 dc.w $0019				; 39
 dc.l _fcosh_reg_reg
 dc.w $4019				; 40
 dc.l _fcosh_ea_reg
 dc.w $001a				; 41
 dc.l _fneg_reg_reg
 dc.w $401a				; 42
 dc.l _fneg_ea_reg
 dc.w $001c				; 43
 dc.l _facos_reg_reg
 dc.w $401c				; 44
 dc.l _facos_ea_reg
 dc.w $001d				; 45
 dc.l _fcos_reg_reg
 dc.w $401d				; 46
 dc.l _fcos_ea_reg
 dc.w $001e				; 47
 dc.l _fgetexp_reg_reg
 dc.w $401e				; 48
 dc.l _fgetexp_ea_reg
 dc.w $001f				; 49
 dc.l _fgetman_reg_reg
 dc.w $401f				; 50
 dc.l _fgetman_ea_reg
 dc.w $0020				; 51
 dc.l _fdiv_reg_reg
 dc.w $4020				; 52
 dc.l _fdiv_ea_reg
 dc.w $0021				; 53
 dc.l _fmod_reg_reg
 dc.w $4021				; 54
 dc.l _fmod_ea_reg
 dc.w $0022				; 55
 dc.l _fadd_reg_reg
 dc.w $4022				; 56
 dc.l _fadd_ea_reg
 dc.w $0023				; 57
 dc.l _fmul_reg_reg
 dc.w $4023				; 58
 dc.l _fmul_ea_reg
 dc.w $0024				; 59
 dc.l _fsgldiv_reg_reg
 dc.w $4024				; 60
 dc.l _fsgldiv_ea_reg
 dc.w $0025				; 61
 dc.l _frem_reg_reg
 dc.w $4025				; 62
 dc.l _frem_ea_reg
 dc.w $0026				; 63
 dc.l _fscale_reg_reg
 dc.w $4026				; 64
 dc.l _fscale_ea_reg
 dc.w $0027				; 65
 dc.l _fsglmul_reg_reg
 dc.w $4027				; 66
 dc.l _fsglmul_ea_reg
 dc.w $0028				; 67
 dc.l _fsub_reg_reg
 dc.w $4028				; 68
 dc.l _fsub_ea_reg
 dc.w $0038				; 69
 dc.l _fcmp_reg_reg
 dc.w $4038				; 70
 dc.l _fcmp_ea_cmp
 dc.w $003a				; 71
 dc.l _ftst_reg
 dc.w $403a				; 72
 dc.l _ftst_ea
 dc.w $0000				; 73
 dc.l _fmove_reg_reg
 dc.w $4000				; 74
 dc.l _fmove_ea_reg
 ENDC

 IFNE _68020!_68030
fmovem_table:
 dc.b 'FP0FP1FP2FP3FP4FP5FP6FP7'
 ENDC

 even

movem_table:
 dc.b 'D0D1D2D3D4D5D6D7A0A1A2A3A4A5A6A7'

sfc_dat:
 dc.b 'SFC',0,0
dfc_dat:
 dc.b 'DFC',0,0
cacr_dat:
 dc.b 'CACR',0
usp_dat:
 dc.b 'USP',0,0
vbr_dat:
 dc.b 'VBR',0,0
caar_dat:
 dc.b 'CAAR',0
msp_dat:
 dc.b 'MSP',0,0
isp_dat:
 dc.b 'ISP',0,0
srp_dat:
 dc.b 'SRP',0
crp_dat:
 dc.b 'CRP',0
tc_dat:
 dc.b 'TC',0
mmusr_dat:
 dc.b 'MMUSR',0
tt0_dat:
 dc.b 'TT0',0
tt1_dat:
 dc.b 'TT1',0
ccr_dat:
 dc.b 'CCR',0
sr_dat:
 dc.b 'SR',0
pc_dat:
 dc.b 'PC',0
fpcr_dat:
 dc.b 'FPCR',0
fpsr_dat:
 dc.b 'FPSR',0
fpiar_dat:
 dc.b 'FPIAR',0

condition_codes_dat:
t_dat:
 dc.b 'T',0,0
f_dat:
 dc.b 'F',0,0
hi_dat:
 dc.b 'HI',0
ls_dat:
 dc.b 'LS',0
cc_dat:
 dc.b 'CC',0
cs_dat:
 dc.b 'CS',0
ne_dat:
 dc.b 'NE',0
eq_dat:
 dc.b 'EQ',0
vc_dat:
 dc.b 'VC',0
vs_dat:
 dc.b 'VS',0
pl_dat:
 dc.b 'PL',0
mi_dat:
 dc.b 'MI',0
ge_dat:
 dc.b 'GE',0
lt_dat:
 dc.b 'LT',0
gt_dat:
 dc.b 'GT',0
le_dat:
 dc.b 'LE',0

 IFNE _68020!_68030
FPU_condition_codes_dat:
FPU_f_dat:		;000000
 dc.b 'F',0,0,0,0
FPU_eq_dat:		;000001
 dc.b 'EQ',0,0,0
FPU_ogt_dat:		;000010
 dc.b 'OGT',0,0
FPU_oge_dat:		;000011
 dc.b 'OGE',0,0
FPU_olt_dat:		;000100
 dc.b 'OLT',0,0
FPU_ole_dat:		;000101
 dc.b 'OLE',0,0
FPU_ogl_dat:		;000110
 dc.b 'OGL',0,0
FPU_or_dat:		;000111
 dc.b 'OR',0,0,0
FPU_un_dat:		;001000
 dc.b 'UN',0,0,0
FPU_ueq_dat:		;001001
 dc.b 'UEQ',0,0
FPU_ugt_dat:		;001010
 dc.b 'UGT',0,0
FPU_uge_dat:		;001011
 dc.b 'UGE',0,0
FPU_ult_dat:		;001100
 dc.b 'ULT',0,0
FPU_ule_dat:		;001101
 dc.b 'ULE',0,0
FPU_ne_dat:		;001110
 dc.b 'NE',0,0,0
FPU_t_dat:		;001111
 dc.b 'T',0,0,0,0
FPU_sf_dat:		;010000
 dc.b 'SF',0,0,0
FPU_seq_dat:		;010001
 dc.b 'SEQ',0,0
FPU_gt_dat:		;010010
 dc.b 'GT',0,0,0
FPU_ge_dat:		;010011
 dc.b 'GE',0,0,0
FPU_lt_dat:		;010100
 dc.b 'LT',0,0,0
FPU_le_dat:		;010101
 dc.b 'LE',0,0,0
FPU_gl_dat:		;010110
 dc.b 'GL',0,0,0
FPU_gle_dat:		;010111
 dc.b 'GLE',0,0
FPU_ngle_dat:		;011000
 dc.b 'NGLE',0
FPU_ngl_dat:		;011001
 dc.b 'NGL',0,0
FPU_nle_dat:		;011010
 dc.b 'NLE',0,0
FPU_nlt_dat:		;011011
 dc.b 'NLT',0,0
FPU_nge_dat:		;011100
 dc.b 'NGE',0,0
FPU_ngt_dat:		;011101
 dc.b 'NGT',0,0
FPU_sne_dat:		;011110
 dc.b 'SNE',0,0
FPU_st_dat:		;011111
 dc.b 'ST',0,0,0

fabs_dat:
 dc.b 'FABS',0
facos_dat:
 dc.b 'FACOS',0
fadd_dat:
 dc.b 'FADD',0
fasin_dat:
 dc.b 'FASIN',0
fatan_dat:
 dc.b 'FATAN',0
fatanh_dat:
 dc.b 'FATANH',0
fbcc_dat:
 dc.b 'FB',0
fcmp_dat:
 dc.b 'FCMP',0
fcos_dat:
 dc.b 'FCOS',0
fcosh_dat:
 dc.b 'FCOSH',0
fdbcc_dat:
 dc.b 'FDB',0
fdiv_dat:
 dc.b 'FDIV',0
fetox_dat:
 dc.b 'FETOX',0
fetoxm1_dat:
 dc.b 'FETOXM1',0
fgetexp_dat:
 dc.b 'FGETEXP',0
fgetman_dat:
 dc.b 'FGETMAN',0
fint_dat:
 dc.b 'FINT',0
fintrz_dat:
 dc.b 'FINTRZ',0
flog10_dat:
 dc.b 'FLOG10',0
flog2_dat:
 dc.b 'FLOG2',0
flogn_dat:
 dc.b 'FLOGN',0
flognp1_dat:
 dc.b 'FLOGNP1',0
fmod_dat:
 dc.b 'FMOD',0
fmove_dat:
 dc.b 'FMOVE',0
fmovecr_dat:
 dc.b 'FMOVECR',0
fmovem_dat:
 dc.b 'FMOVEM',0
fmul_dat:
 dc.b 'FMUL',0
fneg_dat:
 dc.b 'FNEG',0
fnop_dat:
 dc.b 'FNOP',0
frem_dat:
 dc.b 'FREM',0
frestore_dat:
 dc.b 'FRESTORE',0
fsave_dat:
 dc.b 'FSAVE',0
fscale_dat:
 dc.b 'FSCALE',0
fscc_dat:
 dc.b 'FS',0
fsgldiv_dat:
 dc.b 'FSGLDIV',0
fsglmul_dat:
 dc.b 'FSGLMUL',0
fsin_dat:
 dc.b 'FSIN',0
fsincos_dat:
 dc.b 'FSINCOS',0
fsinh_dat:
 dc.b 'FSINH',0
fsqrt_dat:
 dc.b 'FSQRT',0
fsub_dat:
 dc.b 'FSUB',0
ftan_dat:
 dc.b 'FTAN',0
ftanh_dat:
 dc.b 'FTANH',0
ftentox_dat:
 dc.b 'FTENTOX',0
ftrapcc_dat:
 dc.b 'FTRAP',0
ftst_dat:
 dc.b 'FTST',0
ftwotox_dat:
 dc.b 'FTWOTOX',0
 ENDC

abcd_dat:
 dc.b 'ABCD',0
add_dat:
 dc.b 'ADD',0
adda_dat:
 dc.b 'ADDA',0
addi_dat:
 dc.b 'ADDI',0
addq_dat:
 dc.b 'ADDQ',0
addx_dat:
 dc.b 'ADDX',0
and_dat:
 dc.b 'AND',0
andi_dat:
 dc.b 'ANDI',0
asl_dat:
 dc.b 'ASL',0
asr_dat:
 dc.b 'ASR',0
bcc_dat:
 dc.b 'B',0
bchg_dat:
 dc.b 'BCHG',0
bclr_dat:
 dc.b 'BCLR',0
bfchg_dat:
 dc.b 'BFCHG',0
bfclr_dat:
 dc.b 'BFCLR',0
bfexts_dat:
 dc.b 'BFEXTS',0
bfextu_dat:
 dc.b 'BFEXTU',0
bfffo_dat:
 dc.b 'BFFFO',0
bfins_dat:
 dc.b 'BFINS',0
bfset_dat:
 dc.b 'BFSET',0
bftst_dat:
 dc.b 'BFTST',0
bgnd_dat:
 dc.b 'BGND',0
bkpt_dat:
 dc.b 'BKPT',0
bra_dat:
 dc.b 'BRA',0
bset_dat:
 dc.b 'BSET',0
bsr_dat:
 dc.b 'BSR',0
btst_dat:
 dc.b 'BTST',0
cas_dat:
 dc.b 'CAS',0
cas2:
 dc.b 'CAS2',0
chk_dat:
 dc.b 'CHK',0
chk2_dat:
 dc.b 'CHK2',0
clr_dat:
 dc.b 'CLR',0
cmp_dat:
 dc.b 'CMP',0
cmpa_dat:
 dc.b 'CMPA',0
cmpi_dat:
 dc.b 'CMPI',0
cmpm_dat:
 dc.b 'CMPM',0
cmp2_dat:
 dc.b 'CMP2',0
dbcc_dat:
 dc.b 'DB',0
dc_b_dat:
 dc.b 'DC.B',0
dc_w_dat:
 dc.b 'DC.W',0
divs_dat:
 dc.b 'DIVS',0
divu_dat:
 dc.b 'DIVU',0
eor_dat:
 dc.b 'EOR',0
eori_dat:
 dc.b 'EORI',0
exg_dat:
 dc.b 'EXG',0
ext_dat:
 dc.b 'EXT',0
extb_dat:
 dc.b 'EXTB',0
illegal_dat:
 dc.b 'ILLEGAL',0
jmp_dat:
 dc.b 'JMP',0
jsr_dat:
 dc.b 'JSR',0
lea_dat:
 dc.b 'LEA',0
link_word_dat:
 dc.b 'LINK',0
link_long_dat:
 dc.b 'LINK.L',0
 IFNE _CPU32
lpstop_dat:
 dc.b 'LPSTOP',0
 ENDC ;_CPU32
lsl_dat:
 dc.b 'LSL',0
lsr_dat:
 dc.b 'LSR',0
move_dat:
 dc.b 'MOVE',0
 IFNE _68040
move16_dat:
 dc.b 'MOVE16',0
 ENDC
movea_dat:
 dc.b 'MOVEA',0
move_from_ccr_dat:
 dc.b 'MOVE CCR',0
move_from_sr_dat:
 dc.b 'MOVE SR',0
movec_dat:
 dc.b 'MOVEC',0
movem_dat:
 dc.b 'MOVEM',0
movep_dat:
 dc.b 'MOVEP',0
moveq_dat:
 dc.b 'MOVEQ',0
moves_dat:
 dc.b 'MOVES',0
muls_dat:
 dc.b 'MULS',0
mulu_dat:
 dc.b 'MULU',0
nbcd_dat:
 dc.b 'NBCD',0
neg_dat:
 dc.b 'NEG',0
negx_dat:
 dc.b 'NEGX',0
nop_dat:
 dc.b 'NOP',0
not_dat:
 dc.b 'NOT',0
or_dat:
 dc.b 'OR',0
ori_dat:
 dc.b 'ORI',0
pack_dat:
 dc.b 'PACK',0
pea_dat:
 dc.b 'PEA',0
pflush_dat:
 dc.b 'PFLUSH',0
pflusha_dat:
 dc.b 'PFLUSHA',0
ploadr_dat:
 dc.b 'PLOADR',0
ploadw_dat:
 dc.b 'PLOADW',0
pmove_dat:
 dc.b 'PMOVE',0
pmovefd_dat:
 dc.b 'PMOVEFD',0
ptestr_dat:
 dc.b 'PTESTR',0
ptestw_dat:
 dc.b 'PTESTW',0
reset_dat:
 dc.b 'RESET',0
rol_dat:
 dc.b 'ROL',0
ror_dat:
 dc.b 'ROR',0
roxl_dat:
 dc.b 'ROXL',0
roxr_dat:
 dc.b 'ROXR',0
rtd_dat:
 dc.b 'RTD',0
rte_dat:
 dc.b 'RTE',0
rtr_dat:
 dc.b 'RTR',0
rts_dat:
 dc.b 'RTS',0
sbcd_dat:
 dc.b 'SBCD',0
scc_dat:
 dc.b 'S',0
stop_dat:
 dc.b 'STOP',0
sub_dat:
 dc.b 'SUB',0
suba_dat:
 dc.b 'SUBA',0
subi_dat:
 dc.b 'SUBI',0
subq_dat:
 dc.b 'SUBQ',0
subx_dat:
 dc.b 'SUBX',0
swap_dat:
 dc.b 'SWAP',0
tas_dat:
 dc.b 'TAS',0
 IFNE _CPU32
tbls_dat:
 dc.b 'TBLS',0
tblsn_dat:
 dc.b 'TBLSN',0
tblu_dat:
 dc.b 'TBLU',0
tblun_dat:
 dc.b 'TBLUN',0
 ENDC ;_CPU32
trap_dat:
 dc.b 'TRAP',0
trapv_dat:
 dc.b 'TRAPV',0
tst_dat:
 dc.b 'TST',0
unlk_dat:
 dc.b 'UNLK',0
unpk_dat:
 dc.b 'UNPK',0

 IFNE _68020!_68030
_pi_text:
 dc.b $e3,0
_log10_2_text:
 dc.b 'Log10(2)',0
_e_text:
 dc.b 'e',0
_log2_e_text:
 dc.b 'Log2(e)',0
_log10_e_text:
 dc.b 'Log10(e)',0
_0_text:
 dc.b '0.0',0
_ln_2_text:
 dc.b 'ln(2)',0
_ln_10_text:
 dc.b 'ln(10)',0
_10_0_text:
 dc.b '1',0
_10_1_text:
 dc.b '1E1',0
_10_2_text:
 dc.b '1E2',0
_10_4_text:
 dc.b '1E4',0
_10_8_text:
 dc.b '1E8',0
_10_16_text:
 dc.b '1E16',0
_10_32_text:
 dc.b '1E32',0
_10_64_text:
 dc.b '1E64',0
_10_128_text:
 dc.b '1E128',0
_10_256_text:
 dc.b '1E256',0
_10_512_text:
 dc.b '1E512',0
_10_1024_text:
 dc.b '1E1024',0
_10_2048_text:
 dc.b '1E2048',0
_10_4096_text:
 dc.b '1E4096',0
_fmovecr_reserved_comment:
 dc.b 'Reserved',0
 ENDC

_001011111111000000:
 dc.b %00000000,%10111111,%11000000
_001101111111011111:
 dc.b %00000000,%11011111,%11011111
_111111111111111111:
 dc.b %00000011,%11111111,%11111111
_001001111111011111:
 dc.b %00000000,%10011111,%11011111
_001111111111000000:
 dc.b %00000000,%11111111,%11000000
_101111111111000000:
 dc.b %00000010,%11111111,%11000000
_111111111111000000:
 dc.b %00000011,%11111111,%11000000
_101111111111111111:
 dc.b %00000010,%11111111,%11111111
_101001111111000000:
 dc.b %00000010,%10011111,%11000000
_101001111111011111:
 dc.b %00000010,%10011111,%11011111
_001001111111000000:
 dc.b %00000000,%10011111,%11000000
_101111111111011111:
 dc.b %00000010,%11111111,%11011111	;BTST only
_001111111111111111:
 dc.b %00000000,%11111111,%11111111
_000011110011011100:
 dc.b %00000000,%00111100,%11011100
_101111111111001000:
 dc.b %00000010,%11111111,%11010000	;Alex pour CMPI (PC)
_101111011111001111:
 dc.b %00000010,%11111111,%11001111	;TST 68000 only

 even

 IFNE _68020!_68030
_fmovecr_comment_table:
 dc.w $00
 dc.l _pi_text
 dc.w $0b
 dc.l _log10_2_text
 dc.w $0c
 dc.l _e_text
 dc.w $0d
 dc.l _log2_e_text
 dc.w $0e
 dc.l _log10_e_text
 dc.w $0f
 dc.l _0_text
 dc.w $30
 dc.l _ln_2_text
 dc.w $31
 dc.l _ln_10_text
 dc.w $32
 dc.l _10_0_text
 dc.w $33
 dc.l _10_1_text
 dc.w $34
 dc.l _10_2_text
 dc.w $35
 dc.l _10_4_text
 dc.w $36
 dc.l _10_8_text
 dc.w $37
 dc.l _10_16_text
 dc.w $38
 dc.l _10_32_text
 dc.w $39
 dc.l _10_64_text
 dc.w $3a
 dc.l _10_128_text
 dc.w $3b
 dc.l _10_256_text
 dc.w $3c
 dc.l _10_512_text
 dc.w $3d
 dc.l _10_1024_text
 dc.w $3e
 dc.l _10_2048_text
 dc.w $3f
 dc.l _10_4096_text
 dc.w -1
 ENDC	;de _68020!_68030

;  #] Strings:
; TEXT

