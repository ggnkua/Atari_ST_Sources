/* Copyright (c) 2004 - present by H. Robbers.
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

/*
 * assembler opcode definitions
 *
 */

#undef as_kw
#undef as_P_kw
#undef asdef
#undef asPdef
#undef asbdef

#ifdef PRELUDE_H
#if ! __ABC__
#undef and
#undef or
#undef not
#undef elif
#endif
#endif

/*
 * Defines for the instructions (1995: for integrated (simple) assembler)
 */
#if DEF_AS_ENUM
	#define as_kw(t) A_ ## t,
	#define as_P_kw(t) A_ ## t,
	#define asdef(t,  cc, sz, cpu, f) A_ ## t,
	#define asPdef(t, cc, sz, cpu, f) A_ ## t,
	#define asbdef(t, cc, sz, cpu, f) A_ ## t,
#elif DEF_AS_PROTO
	#define as_kw(t)  p_A P_ ## t; w_A W_ ## t;
	#define as_P_kw(t)  p_A P_ ## t;
	#define asdef(t,  cc, sz, cpu, f) p_A P_ ## t; w_A W_ ## t;
	#define asPdef(t, cc, sz, cpu, f) p_A P_ ## t;
	#define asbdef(t, cc, sz, cpu, f)
#elif DEF_AS_OP
	#define as_kw(t) {#t, P_ ## t, W_ ## t, 0, 0, 0, 0},
	#define as_P_kw(t) {#t, P_ ## t, nil, 0, 0, 0, 0},
	#define asdef(t, cc, sz, cpu, f) {#t, P_ ## t, W_ ## t, sz, cc, cpu, f},
	#define asPdef(t, cc, sz, cpu, f) {#t, P_ ## t, 0, sz, cc, cpu, f},
	#define asbdef(t, cc, sz, cpu, f) {#t, 0, 0, sz, cc, cpu, f},
#elif DEF_AS_CODE
	#define as_kw(t) "A_" #t,
	#define as_P_kw(t) "A_" #t,
	#define asdef(t, cc, sz, cpu, f) "A_" #t,
	#define asPdef(t, cc, sz, cpu, f) "A_" #t,
	#define asbdef(t, cc, sz, cpu, f) "A_" #t,
#endif

/* P in macro name: only Parse routine required (avoids dummy write routines) */

/*    t     	cc  sz  cpu	flag */
as_kw(end)
as_P_kw(globl)
#undef global
as_P_kw(global)
#define global
as_P_kw(import)
as_P_kw(xref)
as_P_kw(export)
as_P_kw(xdef)
as_P_kw(extern)
as_P_kw(local)
as_kw(module)
as_kw(area)
as_kw(endmod)
as_kw(text)
as_kw(data)
as_kw(bss)
as_kw(offset)
as_kw(org)
as_kw(ds)
as_kw(dc)
as_kw(dcb)					/* 05'11 HR */
as_kw(ascii)
as_kw(asciil)
as_kw(asciiz)
as_kw(even)
as_kw(align)				/* 04'12 HR */
as_kw(incbin)

as_P_kw(equ)
as_P_kw(set)
as_P_kw(section)
as_P_kw(include)
as_P_kw(macro)
as_P_kw(define)
as_P_kw(repeat)
as_P_kw(rept)

asPdef(if,		0,	0,	0,	1)
asPdef(ifne,	0,	0,	0,	1)
asPdef(iff,		0,	0,	0,	1)
asPdef(ifeq,	0,	0,	0,	1)
asPdef(ifle,	0,	0,	0,	1)
asPdef(iflt,	0,	0,	0,	1)
asPdef(ifge,	0,	0,	0,	1)
asPdef(ifgt,	0,	0,	0,	1)

asPdef(ifdef,	0,	0,	0,	1)
asPdef(ifd,		0,	0,	0,	1)
asPdef(ifndef,	0,	0,	0,	1)
asPdef(ifnd,	0,	0,	0,	1)
asPdef(else,	0,	0,	0,	1)
asPdef(elif,	0,	0,	0,	1)
asPdef(fi,		0,	0,	0,	1)
asPdef(endif,	0,	0,	0,	1)
asPdef(endc,	0,	0,	0,	1)

as_P_kw(cpu)
as_P_kw(user)
as_P_kw(super)
as_P_kw(mc68000)
as_P_kw(mc68010)
as_P_kw(mc68020)
as_P_kw(mc68030)
as_P_kw(mc68040)
as_P_kw(mc68060)
as_P_kw(mc68851)
#if FLOAT
as_P_kw(mc68881)
#endif
as_P_kw(page)
as_P_kw(coldfire)

as_kw(aline)				/* 04'12 HR */
as_kw(abcd)
as_kw(nbcd)
as_kw(sbcd)

as_kw(add)
as_kw(adda)
as_kw(addi)
as_kw(addq)
as_kw(addx)
as_kw(sub)
as_kw(suba)
as_kw(subi)
as_kw(subq)
as_kw(subx)

as_kw(and)
as_kw(andi)
as_kw(asl)
as_kw(asr)
as_kw(lsl)
as_kw(lsr)
as_kw(rol)
as_kw(ror)
as_kw(roxl)
as_kw(roxr)

asdef(bra,		000,0,	0,	0)
asbdef(bf,		001,0,	0,	0)
asbdef(bhi,		002,0,	0,	0)
asbdef(bls,		003,0,	0,	0)
asbdef(bcc,		004,0,	0,	0)
asbdef(bhs,		004,0,	0,	0)
asbdef(bcs,		005,0,	0,	0)
asbdef(blo,		005,0,	0,	0)
asbdef(bne,		006,0,	0,	0)
asbdef(beq,		007,0,	0,	0)
asbdef(bvc,		010,0,	0,	0)
asbdef(bvs,		011,0,	0,	0)
asbdef(bpl,		012,0,	0,	0)
asbdef(bmi,		013,0,	0,	0)
asbdef(bge,		014,0,	0,	0)
asbdef(blt,		015,0,	0,	0)
asbdef(bgt,		016,0,	0,	0)
asbdef(ble,		017,0,	0,	0)

asdef(dbra,		001,0,	0,	0)
asbdef(dbt,		000,0,	0,	0)
asbdef(dbf,		001,0,	0,	0)
asbdef(dbhi,	002,0,	0,	0)
asbdef(dbls,	003,0,	0,	0)
asbdef(dbcc,	004,0,	0,	0)
asbdef(dbcs,	005,0,	0,	0)
asbdef(dbne,	006,0,	0,	0)
asbdef(dbeq,	007,0,	0,	0)
asbdef(dbvc,	010,0,	0,	0)
asbdef(dbvs,	011,0,	0,	0)
asbdef(dbpl,	012,0,	0,	0)
asbdef(dbmi,	013,0,	0,	0)
asbdef(dbge,	014,0,	0,	0)
asbdef(dblt,	015,0,	0,	0)
asbdef(dbgt,	016,0,	0,	0)
asbdef(dble,	017,0,	0,	0)

asdef(st,		000,0,	0,	0)
asbdef(sf,		001,0,	0,	0)
asbdef(shi,		002,0,	0,	0)
asbdef(sls,		003,0,	0,	0)
asbdef(scc,		004,0,	0,	0)
asbdef(scs,		005,0,	0,	0)
asbdef(sne,		006,0,	0,	0)
asbdef(seq,		007,0,	0,	0)
asbdef(svc,		010,0,	0,	0)
asbdef(svs,		011,0,	0,	0)
asbdef(spl,		012,0,	0,	0)
asbdef(smi,		013,0,	0,	0)
asbdef(sge,		014,0,	0,	0)
asbdef(slt,		015,0,	0,	0)
asbdef(sgt,		016,0,	0,	0)
asbdef(sle,		017,0,	0,	0)

asdef(trapt,	000,0,	_H,	0)
asbdef(trapf,	001,0,	_H,	0)
asbdef(traphi,	002,0,	_H,	0)
asbdef(trapls,	003,0,	_H,	0)
asbdef(trapcc,	004,0,	_H,	0)
asbdef(trapcs,	005,0,	_H,	0)
asbdef(trapne,	006,0,	_H,	0)
asbdef(trapeq,	007,0,	_H,	0)
asbdef(trapvc,	010,0,	_H,	0)
asbdef(trapvs,	011,0,	_H,	0)
asbdef(trappl,	012,0,	_H,	0)
asbdef(trapmi,	013,0,	_H,	0)
asbdef(trapge,	014,0,	_H,	0)
asbdef(traplt,	015,0,	_H,	0)
asbdef(trapgt,	016,0,	_H,	0)
asbdef(traple,	017,0,	_H,	0)

as_kw(bchg)
as_kw(bclr)
as_kw(btst)
asdef(bfchg,	0,	0,	_H,	0)
asdef(bfclr,	0,	0,	_H,	0)
asdef(bfexts,	0,	0,	_H,	0)
asdef(bfextu,	0,	0,	_H,	0)
asdef(bfffo,	0,	0,	_H,	0)
asdef(bfins,	0,	0,	_H,	0)
asdef(bfset,	0,	0,	_H,	0)
asdef(bftst,	0,	0,	_H,	0)
asdef(bkpt,		0,	0,	036,0)
as_kw(bset)
as_kw(bsr)
asdef(callm,	0,	0,	_2,	0)
asdef(cas,		0,	0,	_H,	0)
asdef(cas2,		0,	0,	_H,	0)
as_kw(chk)
asdef(chk2,		0,	0,	_H,	0)
as_kw(clr)
as_kw(tst)
as_kw(cmp)
as_kw(cmpa)
as_kw(cmpi)
as_kw(cmpm)
asdef(cmp2,		0,	0,	_H,	0)
as_kw(divs)
#if FLOAT			/* !FLOAT implies 68000 */
asdef(divsl,	0,	0,	_H,	0)
#endif
as_kw(divu)
#if FLOAT			/* !FLOAT implies 68000 */
asdef(divul,	0,	0,	_H,	0)
#endif
as_kw(eor)
as_kw(eori)
as_kw(exg)
as_kw(ext)
asdef(extb,		0,	0,	_H,	0)
as_kw(illegal)
as_kw(jmp)
as_kw(jsr)
as_kw(lea)
as_kw(pea)
as_kw(link)
as_kw(unlk)
as_kw(move)
as_kw(movea)
asdef(move16,	0,	0,	_4,	0)
as_kw(movem)
as_kw(xsave)		/* 05'12 HR: for Coldfire */
as_kw(xrest)		/* 05'12 HR: for Coldfire */
as_kw(movep)
as_kw(moveq)
as_kw(muls)
as_kw(mulu)
as_kw(neg)
as_kw(negx)
as_kw(nop)
as_kw(not)
as_kw(or)
as_kw(ori)
asdef(pack,		0,	0,	_H,	0)
asdef(unpk,		0,	0,	_H,	0)
asdef(pvalid,	0,	0,	_5,	0)
asdef(rtd,		0,	0,	_H,	0)
asdef(rtm,		0,	0,	_2,	0)
as_kw(rtr)
as_kw(rts)
as_kw(swap)
as_kw(tas)
as_kw(trap)
as_kw(trapv)

asdef(cinvl,	0,	0,	_S|_4,	0)
asdef(cinvp,	0,	0,	_S|_4,	0)
asdef(cinva,	0,	0,	_S|_4,	0)
asdef(cpushl,	0,	0,	_S|_4,	0)
asdef(cpushp,	0,	0,	_S|_4,	0)
asdef(cpusha,	0,	0,	_S|_4,	0)
#if FLOAT
asdef(frestore,	0,	0,	_S|_4|_8,	0)
asdef(fsave,	0,	0,	_S|_4|_8,	0)
#endif

asdef(movec,	0,	0,	_S|_1|_H|_CF,	0)
asdef(moves,	0,	0,	_S|_1|_H,	0)

asdef(pbbs,		000,0,	_S|_5,	0)
asbdef(pbbc,	001,0,	_S|_5,	0)
asbdef(pbls,	002,0,	_S|_5,	0)
asbdef(pblc,	003,0,	_S|_5,	0)
asbdef(pbss,	004,0,	_S|_5,	0)
asbdef(pbsc,	005,0,	_S|_5,	0)
asbdef(pbas,	006,0,	_S|_5,	0)
asbdef(pbac,	007,0,	_S|_5,	0)
asbdef(pbws,	010,0,	_S|_5,	0)
asbdef(pbwc,	011,0,	_S|_5,	0)
asbdef(pbis,	012,0,	_S|_5,	0)
asbdef(pbic,	013,0,	_S|_5,	0)
asbdef(pbgs,	014,0,	_S|_5,	0)
asbdef(pbgc,	015,0,	_S|_5,	0)
asbdef(pbcs,	016,0,	_S|_5,	0)
asbdef(pbcc,	017,0,	_S|_5,	0)

asdef(psbs,		000,0,	_S|_5,	0)
asbdef(psbc,	001,0,	_S|_5,	0)
asbdef(psls,	002,0,	_S|_5,	0)
asbdef(pslc,	003,0,	_S|_5,	0)
asbdef(psss,	004,0,	_S|_5,	0)
asbdef(pssc,	005,0,	_S|_5,	0)
asbdef(psas,	006,0,	_S|_5,	0)
asbdef(psac,	007,0,	_S|_5,	0)
asbdef(psws,	010,0,	_S|_5,	0)
asbdef(pswc,	011,0,	_S|_5,	0)
asbdef(psis,	012,0,	_S|_5,	0)
asbdef(psic,	013,0,	_S|_5,	0)
asbdef(psgs,	014,0,	_S|_5,	0)
asbdef(psgc,	015,0,	_S|_5,	0)
asbdef(pscs,	016,0,	_S|_5,	0)
asbdef(pscc,	017,0,	_S|_5,	0)

asdef(pdbbs,	000,0,	_S|_5,	0)
asbdef(pdbbc,	001,0,	_S|_5,	0)
asbdef(pdbls,	002,0,	_S|_5,	0)
asbdef(pdblc,	003,0,	_S|_5,	0)
asbdef(pdbss,	004,0,	_S|_5,	0)
asbdef(pdbsc,	005,0,	_S|_5,	0)
asbdef(pdbas,	006,0,	_S|_5,	0)
asbdef(pdbac,	007,0,	_S|_5,	0)
asbdef(pdbws,	010,0,	_S|_5,	0)
asbdef(pdbwc,	011,0,	_S|_5,	0)
asbdef(pdbis,	012,0,	_S|_5,	0)
asbdef(pdbic,	013,0,	_S|_5,	0)
asbdef(pdbgs,	014,0,	_S|_5,	0)
asbdef(pdbgc,	015,0,	_S|_5,	0)
asbdef(pdbcs,	016,0,	_S|_5,	0)
asbdef(pdbcc,	017,0,	_S|_5,	0)

asdef(ptrapbs,	000,0,	_S|_5,	0)
asbdef(ptrapbc,	001,0,	_S|_5,	0)
asbdef(ptrapls,	002,0,	_S|_5,	0)
asbdef(ptraplc,	003,0,	_S|_5,	0)
asbdef(ptrapss,	004,0,	_S|_5,	0)
asbdef(ptrapsc,	005,0,	_S|_5,	0)
asbdef(ptrapas,	006,0,	_S|_5,	0)
asbdef(ptrapac,	007,0,	_S|_5,	0)
asbdef(ptrapws,	010,0,	_S|_5,	0)
asbdef(ptrapwc,	011,0,	_S|_5,	0)
asbdef(ptrapis,	012,0,	_S|_5,	0)
asbdef(ptrapic,	013,0,	_S|_5,	0)
asbdef(ptrapgs,	014,0,	_S|_5,	0)
asbdef(ptrapgc,	015,0,	_S|_5,	0)
asbdef(ptrapcs,	016,0,	_S|_5,	0)
asbdef(ptrapcc,	017,0,	_S|_5,	0)

asdef(pflusha,	0,	0,	_S|_3|_4|_5,	0)
asdef(pflushan,	0,	0,	_S|_4,	0)
asdef(pflushs,	0,	0,	_S|_5,	0)
asdef(pflushr,	0,	0,	_S|_5,	0)
asdef(pflush,	0,	0,	_S|_3|_4|_5,	0)
asdef(pflushn,	0,	0,	_S|_4,	0)
asdef(ploadr,	0,	0,	_S|_3|_5,	0)
asdef(ploadw,	0,	0,	_S|_3|_5,	0)
asdef(pmove,	0,	0,	_S|_3|_5,	0)
asdef(pmovefd,	0,	0,	_S|_3,	0)
asdef(prestore,	0,	0,	_S|_5,	0)
asdef(psave,	0,	0,	_S|_5,	0)
asdef(ptestr,	0,	0, (_S|_3|_4|_5) & ~_6,0)	/* exception; _4 implies _6 */
asdef(ptestw,	0,	0, (_S|_3|_4|_5) & ~_6,0)
asdef(reset,	0,	0,	_S,	0)
asdef(rte,		0,	0,	_S,	0)
asdef(stop,		0,	0,	_S,	0)
#if COLDFIRE
asdef(mvs,		0,	0,	/* _CF */ 0, 0)
asdef(mvz,		0,	0,	/* _CF */ 0, 0)
asdef(bitrev,	0,	0,	/* _CF */ 0, 0)
asdef(byterev,	0,	0,	/* _CF */ 0, 0)
asdef(ff1,		0,	0,	/* _CF */ 0, 0)
asdef(mov3q,	0,	0,	/* _CF */ 0, 0)
asdef(rems,		0,	0,	/* _CF */ 0, 0)
asdef(remu,		0,	0,	/* _CF */ 0, 0)
asdef(pulse,	0,	0,	/* _CF */ 0, 0)
asdef(sats,		0,	0,	/* _CF */ 0, 0)
asdef(wddata,	0,	0,	/* _CF */ 0, 0)
asdef(halt,		0,	0,	_S|/* _CF */ 0, 0)
asdef(intouch,	0,	0,	_S|/* _CF */ 0, 0)
asdef(strldsr,	0,	0,	_S|/* _CF */ 0, 0)
asdef(wdebug,	0,	0,	_S|/* _CF */ 0, 0)
#endif

#if FLOAT
asdef(fabs,		0,	0,	_8,	0)
asdef(fadd,		0,	0,	_8,	0)
asdef(fcmp,		0,	0,	_8,	0)
asdef(fdiv,		0,	0,	_8,	0)
asdef(fmove,	0,	0,	_8,	0)
asdef(fmovesr,	0,	0,	_8,	0)
asdef(fmovem,	0,	0,	_8,	0)
asdef(fmul,		0,	0,	_8,	0)
asdef(fneg,		0,	0,	_8,	0)
asdef(fnop,		0,	0,	_8,	0)
asdef(fsqrt,	0,	0,	_8,	0)
asdef(fsub,		0,	0,	_8,	0)
asdef(ftst,		0,	0,	_8,	0)
asdef(facos,	0,	0,	_8,	0)
asdef(fasin,	0,	0,	_8,	0)
asdef(fatan,	0,	0,	_8,	0)
asdef(fatanh,	0,	0,	_8,	0)
asdef(fcos,		0,	0,	_8,	0)
asdef(fcosh,	0,	0,	_8,	0)
asdef(fetox,	0,	0,	_8,	0)
asdef(fetoxm1,	0,	0,	_8,	0)
asdef(fgetexp,	0,	0,	_8,	0)
asdef(fgetman,	0,	0,	_8,	0)
asdef(fint,		0,	0,	_8,	0)
asdef(fintrz,	0,	0,	_8,	0)
asdef(flog10,	0,	0,	_8,	0)
asdef(flog2,	0,	0,	_8,	0)
asdef(flogn,	0,	0,	_8,	0)
asdef(flognp1,	0,	0,	_8,	0)
asdef(fmod,		0,	0,	_8,	0)
asdef(fmovecr,	0,	0,	_8,	0)
asdef(frem,		0,	0,	_8,	0)
asdef(fscale,	0,	0,	_8,	0)
asdef(fsgldiv,	0,	0,	_8,	0)
asdef(fsglmul,	0,	0,	_8,	0)
asdef(fsin,		0,	0,	_8,	0)
asdef(fsincos,	0,	0,	_8,	0)
asdef(fsinh,	0,	0,	_8,	0)
asdef(ftan,		0,	0,	_8,	0)
asdef(ftanh,	0,	0,	_8,	0)
asdef(ftentox,	0,	0,	_8,	0)
asdef(ftwotox,	0,	0,	_8,	0)

asdef(fsabs,	0,	0,	_8|_4|_6,0)
asdef(fsadd,	0,	0,	_8|_4|_6,0)
asdef(fsdiv,	0,	0,	_8|_4|_6,0)
asdef(fsmove,	0,	0,	_8|_4|_6,0)
asdef(fsmul,	0,	0,	_8|_4|_6,0)
asdef(fsneg,	0,	0,	_8|_4|_6,0)
asdef(fssqrt,	0,	0,	_8|_4|_6,0)
asdef(fssub,	0,	0,	_8|_4|_6,0)

asdef(fdabs,	0,	0,	_8|_4|_6,0)
asdef(fdadd,	0,	0,	_8|_4|_6,0)
asdef(fddiv,	0,	0,	_8|_4|_6,0)
asdef(fdmove,	0,	0,	_8|_4|_6,0)
asdef(fdmul,	0,	0,	_8|_4|_6,0)
asdef(fdneg,	0,	0,	_8|_4|_6,0)
asdef(fdsqrt,	0,	0,	_8|_4|_6,0)
asdef(fdsub,	0,	0,	_8|_4|_6,0)
#endif

asdef(plpar,	0,	0,	_6, 0)
asdef(plpaw,	0,	0,	_6, 0)
asdef(lpstop,	0,	0,	_6, 0)

#if FLOAT
asdef(fbf,		000,0,	_8,	0)
asbdef(fbeq,	001,0,	_8,	0)
asbdef(fbogt,	002,0,	_8,	0)
asbdef(fboge,	003,0,	_8,	0)
asbdef(fbolt,	004,0,	_8,	0)
asbdef(fbole,	005,0,	_8,	0)
asbdef(fbogl,	006,0,	_8,	0)
asbdef(fbor,	007,0,	_8,	0)
asbdef(fbun,	010,0,	_8,	0)
asbdef(fbueq,	011,0,	_8,	0)
asbdef(fbugt,	012,0,	_8,	0)
asbdef(fbuge,	013,0,	_8,	0)
asbdef(fbult,	014,0,	_8,	0)
asbdef(fbule,	015,0,	_8,	0)
asbdef(fbne,	016,0,	_8,	0)
asbdef(fbt,		017,0,	_8,	0)
asbdef(fbsf,	020,0,	_8,	0)
asbdef(fbseq,	021,0,	_8,	0)
asbdef(fbgt,	022,0,	_8,	0)
asbdef(fbge,	023,0,	_8,	0)
asbdef(fblt,	024,0,	_8,	0)
asbdef(fble,	025,0,	_8,	0)
asbdef(fbgl,	026,0,	_8,	0)
asbdef(fbgle,	027,0,	_8,	0)
asbdef(fbngle,	030,0,	_8,	0)
asbdef(fbngl,	031,0,	_8,	0)
asbdef(fbnle,	032,0,	_8,	0)
asbdef(fbnlt,	033,0,	_8,	0)
asbdef(fbnge,	034,0,	_8,	0)
asbdef(fbngt,	035,0,	_8,	0)
asbdef(fbsne,	036,0,	_8,	0)
asbdef(fbst,	037,0,	_8,	0)

asdef(fsf,		000,0,	_8,	0)
asbdef(fseq,	001,0,	_8,	0)
asbdef(fsogt,	002,0,	_8,	0)
asbdef(fsoge,	003,0,	_8,	0)
asbdef(fsolt,	004,0,	_8,	0)
asbdef(fsole,	005,0,	_8,	0)
asbdef(fsogl,	006,0,	_8,	0)
asbdef(fsor,	007,0,	_8,	0)
asbdef(fsun,	010,0,	_8,	0)
asbdef(fsueq,	011,0,	_8,	0)
asbdef(fsugt,	012,0,	_8,	0)
asbdef(fsuge,	013,0,	_8,	0)
asbdef(fsult,	014,0,	_8,	0)
asbdef(fsule,	015,0,	_8,	0)
asbdef(fsne,	016,0,	_8,	0)
asbdef(fst,		017,0,	_8,	0)
asbdef(fssf,	020,0,	_8,	0)
asbdef(fsseq,	021,0,	_8,	0)
asbdef(fsgt,	022,0,	_8,	0)
asbdef(fsge,	023,0,	_8,	0)
asbdef(fslt,	024,0,	_8,	0)
asbdef(fsle,	025,0,	_8,	0)
asbdef(fsgl,	026,0,	_8,	0)
asbdef(fsgle,	027,0,	_8,	0)
asbdef(fsngle,	030,0,	_8,	0)
asbdef(fsngl,	031,0,	_8,	0)
asbdef(fsnle,	032,0,	_8,	0)
asbdef(fsnlt,	033,0,	_8,	0)
asbdef(fsnge,	034,0,	_8,	0)
asbdef(fsngt,	035,0,	_8,	0)
asbdef(fssne,	036,0,	_8,	0)
asbdef(fsst,	037,0,	_8,	0)

asdef(fdbf,		000,0,	_8,	0)
asbdef(fdbeq,	001,0,	_8,	0)
asbdef(fdbogt,	002,0,	_8,	0)
asbdef(fdboge,	003,0,	_8,	0)
asbdef(fdbolt,	004,0,	_8,	0)
asbdef(fdbole,	005,0,	_8,	0)
asbdef(fdbogl,	006,0,	_8,	0)
asbdef(fdbor,	007,0,	_8,	0)
asbdef(fdbun,	010,0,	_8,	0)
asbdef(fdbueq,	011,0,	_8,	0)
asbdef(fdbugt,	012,0,	_8,	0)
asbdef(fdbuge,	013,0,	_8,	0)
asbdef(fdbult,	014,0,	_8,	0)
asbdef(fdbule,	015,0,	_8,	0)
asbdef(fdbne,	016,0,	_8,	0)
asbdef(fdbt,	017,0,	_8,	0)
asbdef(fdbsf,	020,0,	_8,	0)
asbdef(fdbseq,	021,0,	_8,	0)
asbdef(fdbgt,	022,0,	_8,	0)
asbdef(fdbge,	023,0,	_8,	0)
asbdef(fdblt,	024,0,	_8,	0)
asbdef(fdble,	025,0,	_8,	0)
asbdef(fdbgl,	026,0,	_8,	0)
asbdef(fdbgle,	027,0,	_8,	0)
asbdef(fdbngle,	030,0,	_8,	0)
asbdef(fdbngl,	031,0,	_8,	0)
asbdef(fdbnle,	032,0,	_8,	0)
asbdef(fdbnlt,	033,0,	_8,	0)
asbdef(fdbnge,	034,0,	_8,	0)
asbdef(fdbngt,	035,0,	_8,	0)
asbdef(fdbsne,	036,0,	_8,	0)
asbdef(fdbst,	037,0,	_8,	0)

asdef(ftrapf,	000,0,	_8,	0)
asbdef(ftrapeq,	001,0,	_8,	0)
asbdef(ftrapogt,002,0,	_8,	0)
asbdef(ftrapoge,003,0,	_8,	0)
asbdef(ftrapolt,004,0,	_8,	0)
asbdef(ftrapole,005,0,	_8,	0)
asbdef(ftrapogl,006,0,	_8,	0)
asbdef(ftrapor,	007,0,	_8,	0)
asbdef(ftrapun,	010,0,	_8,	0)
asbdef(ftrapueq,011,0,	_8,	0)
asbdef(ftrapugt,012,0,	_8,	0)
asbdef(ftrapuge,013,0,	_8,	0)
asbdef(ftrapult,014,0,	_8,	0)
asbdef(ftrapule,015,0,	_8,	0)
asbdef(ftrapne,	016,0,	_8,	0)
asbdef(ftrapt,	017,0,	_8,	0)
asbdef(ftrapsf,	020,0,	_8,	0)
asbdef(ftrapseq,021,0,	_8,	0)
asbdef(ftrapgt,	022,0,	_8,	0)
asbdef(ftrapge,	023,0,	_8,	0)
asbdef(ftraplt,	024,0,	_8,	0)
asbdef(ftraple,	025,0,	_8,	0)
asbdef(ftrapgl,	026,0,	_8,	0)
asbdef(ftrapgle,027,0,	_8,	0)
asbdef(ftrapngle,030,0,	_8,	0)
asbdef(ftrapngl,031,0,	_8,	0)
asbdef(ftrapnle,032,0,	_8,	0)
asbdef(ftrapnlt,033,0,	_8,	0)
asbdef(ftrapnge,034,0,	_8,	0)
asbdef(ftrapngt,035,0,	_8,	0)
asbdef(ftrapsne,036,0,	_8,	0)
asbdef(ftrapst,	037,0,	_8,	0)
#endif

#undef DEF_AS_ENUM
#undef DEF_AS_PROTO
#undef DEF_AS_OP
#undef DEF_AS_CODE

#ifdef PRELUDE_H
#if ! __ABC__
#define and &&
#define or ||
#define not !
#define elif else if
#endif
#endif
