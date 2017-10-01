#ifndef DESKINF_H

#define DESKINF_H

EXTERN	VOID my_itoa(UWORD number, BYTE *pnumstr);
EXTERN	VOID fmt_time(UWORD time, BYTE *ptime);
EXTERN	VOID fmt_date(UWORD date, BYTE *pdate);
EXTERN	WORD ob_sfcb(LONG psfcb, BYTE *pfmt);
EXTERN	WORD dr_fnode(UWORD last_state, UWORD curr_state,
	WORD x, WORD y, WORD w, WORD h, LONG psfcb);
EXTERN	WORD dr_code(LONG pparms);
EXTERN	WORD inf_show(LONG tree, WORD start);
EXTERN	VOID inf_finish(LONG tree, WORD dl_ok);
EXTERN	WORD inf_fifo(LONG tree, WORD dl_fi, WORD dl_fo, BYTE *ppath);
EXTERN	VOID inf_dttmsz(LONG tree, FNODE *pf, WORD dl_dt, WORD dl_tm, WORD dl_sz, LONG *psize);
EXTERN	WORD inf_file(BYTE *ppath, FNODE *pfnode);
EXTERN	WORD inf_folder(BYTE *ppath, FNODE *pf);
EXTERN	WORD inf_disk(BYTE dr_id);
EXTERN	WORD inf_pref(VOID);
EXTERN	WORD opn_appl(BYTE *papname, BYTE *papparms, BYTE *pcmd, BYTE *ptail);

#endif
