#ifndef OPTIMIZE_H

#define OPTIMIZE_H

#if GEM & (GEM2 | GEM3 | XGEM)
EXTERN	WORD sound(WORD isfreq, WORD freq, WORD dura);
#endif
EXTERN	WORD bit_num(UWORD flag);
EXTERN	WORD mid(WORD lo, WORD val, WORD hi);
EXTERN	BYTE *strscn(BYTE *ps, BYTE *pd, BYTE stop);
EXTERN	VOID fmt_str(BYTE *instr, BYTE *outstr);
EXTERN	VOID unfmt_str(BYTE *instr, BYTE *outstr);
EXTERN	VOID fs_sset(LONG tree, WORD obj, LONG pstr, LONG *ptext, WORD *ptxtlen);
EXTERN	VOID inf_sset(LONG tree, WORD obj, BYTE *pstr);
EXTERN	VOID fs_sget(LONG tree, WORD obj, LONG pstr);
EXTERN	VOID inf_sget(LONG tree, WORD obj, BYTE *pstr);
EXTERN	VOID inf_fldset(LONG tree, WORD obj, UWORD testfld, UWORD testbit, UWORD truestate, UWORD falsestate);
EXTERN	WORD inf_gindex(LONG tree, WORD baseobj, WORD numobj);
EXTERN	WORD inf_what(LONG tree, WORD ok, WORD cncl);
EXTERN	WORD wildcmp(BYTE *pwld, BYTE *ptst);
EXTERN	VOID ins_char(REG BYTE *str, WORD pos, BYTE chr, REG WORD tot_len);
EXTERN	BYTE *scasb(BYTE *p, BYTE b);

#endif
