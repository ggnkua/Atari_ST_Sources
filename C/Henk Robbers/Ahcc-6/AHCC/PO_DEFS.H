/* Copyright (c) 1990 - present by H. Robbers.   ANSI upgrade.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* po_defs.h
 *
 * optimizer now integrated part of compiler
 */

#undef podef

/*
 * Defines for the instructions (1995: for integrated (simple) assembler)
 */
#if DEF_PO_ENUM
	#define podef(t,cc,sz,c,rr,ra,rd,e) e,
#elif DEF_PO_PROTO
	#define podef(t,cc,sz,c,rr,ra,rd,e) o_A o_ ## e;
#elif DEF_PO_OP
	#define podef(t,cc,sz,c,rr,ra,rd,e) {t,o_ ## e,sz,cc,c,rr,ra,rd},
#elif DEF_PO_CODE
	#define podef(t,cc,sz,c,rr,ra,rd,e) #e,
#endif

/*     t     cc     sz      c           rr          ra          rd           e     */
/*    text   cc     defsz   iflag       regf        argf        dstf         opr   */
podef("mov", 0,		DOT_W,	0,			0,			REF,		SET			,MOV )
podef("sto", 0,		DOT_W,	REVDD,		REF,		SET,		0			,STO )
podef("ldx", 0,		DOT_W,	0,			SET,		REF,		0			,LDX )
podef("ors", 0,		DOT_W,	REVDD,		REF,		REF|SET,	0			,ORS )
podef("orx", 0,		DOT_W,	0,			REF|SET,	REF,		0			,ORX )
podef("ans", 0,		DOT_W,	REVDD,		REF,		REF|SET,	0			,ANS )
podef("anx", 0,		DOT_W,	0,			REF|SET,	REF,		0			,ANX )
podef("sbs", 0,		DOT_W,	REVDD,		REF,		REF|SET,	0			,SBS )
podef("sbx", 0,		DOT_W,	0,			REF|SET,	REF,		0			,SBX )
podef("ads", 0,		DOT_W,	REVDD,		REF,		REF|SET,	0			,ADS )
podef("adx", 0,		DOT_W,	0,			REF|SET,	REF,		0			,ADX )
podef("ers", 0,		DOT_W,	REVDD,		REF,		REF|SET,	0			,ERS )
podef("erx", 0,		DOT_W,	0,			REF|SET,	REF,		0			,ERX )
podef("wmvz",0,		DOT_B,	0,			SET,		REF,		0			,WMVZ )
podef("mvz", 0,		DOT_W,	0,			SET,		REF,		0			,MVZ )
podef("wmvs",0,		DOT_B,	0,			SET,		REF,		0			,WMVS )
podef("mvs", 0,		DOT_W,	0,			SET,		REF,		0			,MVS )
#if COLDFIRE
podef("m3q", 0,		DOT_L,	0,			0,			REF,		SET			,M3Q )
#endif
podef("adj", 0,		DOT_W,	SIDE,		REF|SET,	REF,		0			,ADJ )
podef("sdj", 0,		DOT_W,	SIDE,		REF|SET,	REF,		0			,SDJ )

/* store and extract bit fields 68020 and higher */
podef("ldbu",0,		0,		0,			SET,		REF,		0			,LDBU )
podef("ldbs",0,		0,		0,			SET,		REF,		0			,LDBS )
podef("stb", 0,		0,		0,			REF,		SET,		0			,STB )

#if COLDFIRE
/* store and extract 1 bit  */
podef("bset",0,		0,		0,			REF,		SET,		0			,BSET )
podef("bclr",0,		0,		0,			REF,		SET,		0			,BCLR )
/* nog even over denken
podef("lfx", 0,		0,		0,			SET,		REF,		REF			,LFX )
*/
#endif

podef("udvx",0,		DOT_W,	0,			REF|SET,	REF,		0			,UDVX )
podef("dvx",0,		DOT_W,	0,			REF|SET,	REF,		0			,DVX )
podef("umdx",0,		DOT_W,	0,			REF|SET,	REF,		0			,UMDX )
podef("mdx",0,		DOT_W,	0,			REF|SET,	REF,		0			,MDX )
#if  COLDFIRE || FLOAT
podef("urmx",0,		DOT_L,	0,			SET,		REF,		REF			,URMX )
podef("rmx",0,		DOT_L,	0,			SET,		REF,		REF			,RMX )
#endif
podef("umpx",0,		DOT_W,	0,			REF|SET,	REF,		0			,UMPX )
podef("mpx",0,		DOT_W,	0,			REF|SET,	REF,		0			,MPX)
podef("uscx",0,		DOT_W,	0,			REF|SET,	REF,		0			,USCX )
podef("scx",0,		DOT_W,	0,			REF|SET,	REF,		0			,SCX )
/* ------------------------------------------------------------ */
/* the ..i must have same order as the ..x resp ..s equivalents */
podef("ori", 0,		DOT_W,	0,			0,			REF,		REF|SET		,ORI )
podef("ani", 0,		DOT_W,	0,			0,			REF,		REF|SET		,ANI )
podef("sbi", 0,		DOT_W,	0,			0,			REF,		REF|SET		,SBI )
podef("adi", 0,		DOT_W,	0,			0,			REF,		REF|SET		,ADI )
podef("eri", 0,		DOT_W,	0,			0,			REF,		REF|SET		,ERI )
/* ------------------------------------------------------------ */
podef("cpx", 0,		DOT_W,	0,			REF,		REF,		0			,CPX )
podef("cpi", 0,		DOT_W,	0,			0,			REF,		REF			,CPI )
podef("laa", 0,		0,		LEA|SIDE,	SET,		REF,		0			,LAA )
podef("lax", 0,		0,		LEA|SIDE,	SET,		REF,		0			,LAX )
podef("lmx", 0,		0,		LEA|SIDE,	SET,		REF,		0			,LMX )

#if FLOAT
/* 2 mnemonics to ease registerization of 12 byte reals   68881 only */
podef("fasn",0,		DOT_X,	0,			0,			REF,		SET			,FASN)
podef("fpsh",0,		DOT_X,	SIDE,		0,			REF,		0			,FPSH)
#endif
/*                                                              */
/*     t     cc     sz      c           rr          ra          rd           e     */
/*    text   cc     defsz   iflag       regf        argf        dstf         opr   */
podef("cls", 0,		DOT_W,	REVD|SX,	0,			SET,		0			,CLS )
podef("clx", 0,		DOT_W,	SX,			SET,		0,			0			,CLX )
podef("ngs", 0,		DOT_W,	REVD|SX,	0,			REF|SET,	0			,NGS )
podef("ngx", 0,		DOT_W,	SX,			REF|SET,	0,			0			,NGX )
podef("nos", 0,		DOT_W,	REVD|SX,	0,			REF|SET,	0			,NOS )
podef("nox", 0,		DOT_W,	SX,			REF|SET,	0,			0			,NOX )
podef("swx", 0,		0,		SX,			REF|SET,	0,			0			,SWX )
podef("pea", 0,		0,		LEA|SIDE,	0,			REF,		0			,PEA )
podef("psh", 0,		DOT_W,	SIDE,		0,			REF,		0			,PSH )
podef("pll", 0,		DOT_W,	SIDE,		0,			SET,		0			,PLL )
podef("exx", 0,		DOT_W,	0,			REF|SET,	0,			0			,EXX )
podef("mms", 0,		0,		SIDE|USG,	0,			REF,		0			,MMS )
podef("mmx", 0,		0,		SIDE|USG,	0,			SET,		0			,MMX )
podef("tst", 0,		DOT_W,	SX,			0,			REF,		0			,TST )
podef("tsp", 0,		DOT_W,	SX,			0,			REF,		0			,TSP )
podef("tsx", 0,		DOT_W,	SX,			REF,		0,			0			,TSX )

/* The REVDD must precede the ...x codes */
podef("lsrs",0,		DOT_W,	REVDD,		REF,		REF|SET,	0			,LSRS )
podef("lsrx",0,		DOT_W,	0,			REF|SET,	REF,		0			,LSRX )
podef("lsls",0,		DOT_W,	REVDD,		REF,		REF|SET,	0			,LSLS )
podef("lslx",0,		DOT_W,	0,			REF|SET,	REF,		0			,LSLX )
podef("asrs",0,		DOT_W,	REVDD,		REF,		REF|SET,	0			,ASRS )
podef("asrx",0,		DOT_W,	0,			REF|SET,	REF,		0			,ASRX )
podef("asls",0,		DOT_W,	REVDD,		REF,		REF|SET,	0			,ASLS )
podef("aslx",0,		DOT_W,	0,			REF|SET,	REF,		0			,ASLX )
podef("rors",0,		DOT_W,	REVDD,		REF,		REF|SET,	0			,RORS )
podef("rorx",0,		DOT_W,	0,			REF|SET,	REF,		0			,RORX )
podef("rols",0,		DOT_W,	REVDD,		REF,		REF|SET,	0			,ROLS )
podef("rolx",0,		DOT_W,	0,			REF|SET,	REF,		0			,ROLX )

/* shift bit field into position in register  06'11 HR: arg flags -->SET !!!! */
podef("flx", 0,		DOT_W,	0,			REF|SET,	SET,		REF			,FLX )
podef("lflx",0,		DOT_W,	0,			REF|SET,	SET,		REF			,LFLX )
podef("fld", 0,		DOT_W,	0,			REF|SET,	SET,		REF			,FLD )
podef("lfld",0,		DOT_W,	0,			REF|SET,	SET,		REF			,LFLD )
podef("afld",0,		DOT_W,	0,			REF|SET,	SET,		REF			,AFLD )

podef("lkx", 0,		0,		SIDE|USG,	REF|SET,	REF,		0			,LKX )
podef("ulx", 0,		0,		SIDE|USG,	REF|SET,	0,		 	0			,ULX )
podef("rta", 0,		0,		SIDE|RTN|USG,0,			0,			0			,RTA )
podef("rtad",0,		0,		SIDE|RTN|USG,0,			0,			0			,RTAD )
#if FLOAT
podef("rtf", 0,		0,		SIDE|RTN|USG,0,			0,			0			,RTF )
#endif
podef("rts", 0,		0,		SIDE|RTN|USG,0,			0,			0			,RTS )
podef("rtv", 0,		0,		SIDE|RTN|USG,0,			0,			0			,RTV )
podef("bsr", 0,		0,		SIDE,		0,			REF,		0			,BSR )
podef("jsr", 0,		0,		SIDE,		0,			REF,		0			,JSR )
podef("jsl", 0,		0,		SIDE,		0,			REF,		0			,JSL )
podef("inlv",0,		0,		SIDE,		REF,		REF,		0			,INLV)
podef("trap",0,		0,		SIDE,		0,			0,			0			,TRAP)
podef("jmp", 0,		0,		0,			0,			REF,		0			,JMP )
podef("ldct",0,		0,		0,			SET,		REG,		0			,LDCT)
podef("bct", 0,		0,		SIDE,		REF|SET,	REF,		0			,BCT )
podef("dbx", 0,		0,		SIDE,		REF|SET,	REF,		0			,DBF )

podef("shi", 002,	0,		CCU,		SET,		0,			0			,SHI )
podef("sls", 003,	0,		CCU,		SET,		0,			0			,SLS )
podef("scc", 004,	0,		CCU,		SET,		0,			0			,TSCC )
podef("scs", 005,	0,		CCU,		SET,		0,			0			,SCS )
podef("sne", 006,	0,		CCU,		SET,		0,			0			,SNE )
podef("seq", 007,	0,		CCU,		SET,		0,			0			,SEQ )
podef("sge", 014,	0,		CCU,		SET,		0,			0			,SGE )
podef("slt", 015,	0,		CCU,		SET,		0,			0			,SLT )
podef("sgt", 016,	0,		CCU,		SET,		0,			0			,SGT )
podef("sle", 017,	0,		CCU,		SET,		0,			0			,SLE )

/*     t     cc     sz      c           rr          ra          rd           e     */
/*    text   cc     defsz   iflag       regf        argf        dstf         opr   */
#if FLOAT
podef("fsne",016,	0,		CCU,		SET,		0,			0			,FSNE )
podef("fseq",001,	0,		CCU,		SET,		0,			0			,FSEQ )
podef("fsge",023,	0,		CCU,		SET,		0,			0			,FSGE )
podef("fslt",024,	0,		CCU,		SET,		0,			0			,FSLT )
podef("fsgt",022,	0,		CCU,		SET,		0,			0			,FSGT )
podef("fsle",025,	0,		CCU,		SET,		0,			0			,FSLE )

podef("acos",0,		0,		SX,			SET,		REF,		0			,OACOS )
podef("asin",0,		0,		SX,			SET,		REF,		0			,OASIN )
podef("atan",0,		0,		SX,			SET,		REF,		0			,OATAN )
podef("atanh",0,	0,		SX,			SET,		REF,		0			,OATANH )
podef("cos", 0,		0,		SX,			SET,		REF,		0			,OCOS )

podef("cosh",0,		0,		SX,			SET,		REF,		0			,OCOSH )
podef("etox",0,		0,		SX,			SET,		REF,		0			,OETOX )
podef("etoxm1",0,	0,		SX,			SET,		REF,		0			,OETOXM1 )
podef("abs", 0,		0,		SX,			SET,		REF,		0			,OABS )
podef("intrz", 0,	0,		SX,			SET,		REF,		0			,OINTRZ )

podef("int",  0,	0,		SX,			SET,		REF,		0			,OINT )
podef("getexp",0,	0,		SX,			SET,		REF,		0			,OGEXP )
podef("getman",0,	0,		SX,			SET,		REF,		0			,OGMAN )
podef("logn",0,		0,		SX,			SET,		REF,		0			,OLOGN )
podef("lognp1",0,	0,		SX,			SET,		REF,		0			,OLOGNP1 )

podef("log10",0,	0,		SX,			SET,		REF,		0			,OLOG10 )
podef("log2",0,		0,		SX,			SET,		REF,		0			,OLOG2 )
podef("sin", 0,		0,		SX,			SET,		REF,		0			,OSIN )
podef("sinh",0,		0,		SX,			SET,		REF,		0			,OSINH )
podef("sqrt",0,		0,		SX,			SET,		REF,		0			,OSQRT )

podef("tan", 0,		0,		SX,			SET,		REF,		0			,OTAN )
podef("tanh",0,		0,		SX,			SET,		REF,		0			,OTANH )
podef("tentox",0,	0,		SX,			SET,		REF,		0			,OTENTOX )
podef("twotox",0,	0,		SX,			SET,		REF,		0			,OTWOTOX )
podef("neg",  0,	0,		SX,			SET,		REF,		0			,ONEG )
#endif

podef("swt", 0,		0,		SIDE,		REF|SET,	SET,		0			,SWT )
podef("bra", 0,		0,		0,			0,			REF,		0			,BRA )
podef("brb", 0,		0,		0,			0,			REF,		0			,BRB )	/* 05'16 HR v5.4 */
podef("brf", 0,		0,		0,			0,			REF,		0			,BRF )	/* 05'16 HR v5.4 */
podef("bne", 006,	0,		0,			0,			REF,		0			,BNE )
podef("beq", 007,	0,		0,			0,			REF,		0			,BEQ )
podef("bge", 014,	0,		0,			0,			REF,		0			,BGE )
podef("blt", 015,	0,		0,			0,			REF,		0			,BLT )
podef("bgt", 016,	0,		0,			0,			REF,		0			,BGT )
podef("ble", 017,	0,		0,			0,			REF,		0			,BLE )
podef("bhi", 002,	0,		0,			0,			REF,		0			,BHI )
podef("bls", 003,	0,		0,			0,			REF,		0			,BLS )
podef("bcc", 004,	0,		0,			0,			REF,		0			,BCC )
podef("bcs", 005,	0,		0,			0,			REF,		0			,BCS )
podef("bvc", 010,	0,		0,			0,			REF,		0			,BVC )
podef("bvs", 011,	0,		0,			0,			REF,		0			,BVS )
podef("bpl", 012,	0,		0,			0,			REF,		0			,BPL )
podef("bmi", 013,	0,		0,			0,			REF,		0			,BMI )
#if FLOAT
podef("fbne",016,	0,		0,			0,			REF,		0			,FBNE )
podef("fbeq",001,	0,		0,			0,			REF,		0			,FBEQ )
podef("fbge",023,	0,		0,			0,			REF,		0			,FBGE )
podef("fblt",024,	0,		0,			0,			REF,		0			,FBLT )
podef("fbgt",022,	0,		0,			0,			REF,		0			,FBGT )
podef("fble",025,	0,		0,			0,			REF,		0			,FBLE )
#endif
/*     t     cc     sz      c           rr          ra          rd           e     */
/*    text   cc     defsz   iflag       regf        argf        dstf         opr   */
podef("sva", 0,		DOT_W,	0,			REF,		SET,		0			,SVA )
podef("pla", 0,		DOT_W,	SIDE,		SET,		0,			0			,PLA )
podef("dcs", 0,		DOT_L,	0,			0,			0,			0			,DCS  )		/* for switches */
podef("vrd", 0,		DOT_W,	0,			0,			0,			0			,VARD)
podef("vra", 0,		DOT_W,	0,			0,			0,			0			,VARA)
podef("var", 0,		DOT_W,	0,			0,			0,			0			,VARX)
#if FLOAT
podef("vrf", 0,		DOT_X,	0,			0,			0,			0			,VARF)
#endif
podef("rgd", 0,		DOT_W,	0,			0,			0,			0			,RGD )
podef("rga", 0,		DOT_W,	0,			0,			0,			0			,RGA )
#if FLOAT
podef("rgf", 0,		DOT_X,	0,			0,			0,			0			,RGF )
#endif
/* notion REG already in use. */
podef("reg", 0,		0,		0,			0,			0,			0			,RGL )
podef("loc", 0,		0,		0,			0,			0,			0			,LOC )
podef("begin",0,	0,		0,			0,			REF,		0			,BEGIN )
podef("end", 0,		0,		0,			0,			REF,		0			,END )
podef("loop",0,		0,		0,			0,			0,			0			,LOOP )

podef("glob",0,		0,		0,			0,			REF,		0			,GLOB )
podef("text",0,		0,		0,			0,			0,			0			,TEXT )
podef("data",0,		0,		0,			0,			0,			0			,DATA )
podef("gdata",0,	0,		0,			0,			0,			0			,GDATA )
podef("bss",0,		0,		0,			0,			0,			0			,BSS )
podef("gbss",0,		0,		0,			0,			0,			0			,GBSS )
podef("gproc",0,	0,		0,			0,			REF,		0			,GPROC )
podef("proc",0,		0,		0,			0,			REF,		0			,SPROC )
podef("pend",0,		0,		0,			0,			0,			0			,PEND )
podef("constants",0,0,		0,			0,			0,			0			,CONSTANTS )
podef("strings",0,	0,		0,			0,			0,			0			,STRS )
podef("ds",0,		0,		0,			0,			REF,		0			,DS )
podef("dc",0,		0,		0,			0,			REF,		0			,DC )
podef("even",0,		0,		0,			0,			0,			0			,EVEN )
podef("line",0,		DOT_L,	SIDE,		0,			REF,		0			,SLINE )

/* Special or privileged instruction for operating systems                         */
/*     t     cc     sz      c           rr          ra          rd           e     */
/*    text   cc     defsz   iflag       regf        argf        dstf         opr   */
podef("nop", 0,		0,		SIDE,		0,			0,			0			,NOP )
podef("stop",0,		0,		SIDE,		0,			REF,		0			,STOP )
podef("stsr",0,		DOT_W,	SIDE,		0,			REF,		0			,STSR )
podef("ldsr",0,		DOT_W,	SIDE,		0,			REF|SET,	0			,LDSR )
podef("stcr",0,		DOT_W,	SIDE,		0,			REF,		0			,STCR )
podef("ldcr",0,		DOT_W,	SIDE,		0,			REF|SET,	0			,LDCR )
#if FLOAT
podef("ldfcr",0,	DOT_L,	SIDE,		0,			REF|SET,	0			,LDFCR )
podef("stfcr",0,	DOT_L,	SIDE,		0,			REF,		0			,STFCR )
podef("ldfsr",0,	DOT_L,	SIDE,		0,			REF|SET,	0			,LDFSR )
podef("stfsr",0,	DOT_L,	SIDE,		0,			REF,		0			,STFSR )
#endif
/* 06'16 v5.5: discard is a nop without SIDE, so it really can be discarded */
podef("discard",0,	0,		0,			0,			0,			0			,DISCARD)

/* special to keep certain registers alive during testing to prevent
	too much optimization from happening */
podef("live",0,		0,		SIDE,		0,			REF,		0			,LIV )

#undef DEF_PO_ENUM
#undef DEF_PO_ASOP

#undef DEF_PO_ENUM
#undef DEF_PO_PROTO
#undef DEF_PO_OP
#undef DEF_PO_CODE
