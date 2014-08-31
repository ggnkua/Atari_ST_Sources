/*--------------------------------------------------------------------------*/
/* File name:	TermWinC.H		Revision date:	1993.06.01	    */
/* Created by:	Ulf Ronald Andersson	Creation date:	1993.04.02	    */
/*--------------------------------------------------------------------------*/
/* Version:	0.9 (Beta)						    */
/*--------------------------------------------------------------------------*/
/* Purpose:	Pure/Turbo C Header file for use of TermWinC.O functions.   */
/*--------------------------------------------------------------------------*/

short	tw_init(short tw_lim,short wshandle,long glob_p);
void	tw_exit();
long	tw_cell(long font,short satt);
long	tw_menkey(short code);
long	tw_genkey(long code);
short	win_create(short gad,char *tp,char *ip,GRECT pixbox);
short	tw_open(short whd,short gad,short cols,short rows);
short	tw_close(short	thd);
long	tw_update(short *mesag_p);
short	gem2tw_(short whd);
short	tw_2gem(short thd);
short	tw_voff(short flag);
short	tw_lock(short thd,short lock);
short	tw_escf(short thd);
short	tw_showc(short thd);
short	tw_hidec(short thd);
short	tw_prot(short thd,short prot);
short	tw_font(short thd,long font);	/* font number or ptr to GDOS font */
short	tw_satt(short thd,short satt);
short	tw_inv(short thd,short inv);
short	tw_wrap(short thd,short wrap);
short	tw_colr(short thd,short colr);
short	tw_cdif(short thd,short cdif);
short	tw_ibm_c(short thd,short flag);
void	tw_setw(short thd,short x,short y,short w,short h);
void	tw_fixo(short thd,short x,short y,short w,short h);
short	tw_find(short x,short y);
short	tw_pich(short thd,short x,short y);
short	tw_cich(short thd,short col,short row);
void	tw_seto(short thd);
void	tw_cout(short thd,short data);
void	tw_pout(short thd,char *data_p);
void	tw_del(short thd,short cnt);
void	tw_ins(short thd,short cnt);
void	tw_ldel(short thd,short cnt);
void	tw_lins(short thd,short cnt);
void	tw_clrs(short thd,short code);
void	tw_clrl(short thd,short code);
void	tw_at(short thd,short column,short row);
short	tw_rowx(short thd);
short	tw_colx(short thd);
short	tw_caplk(short thd,short filehand);
short	tw_capmd(short thd,short mode);

/*--------------------------------------------------------------------------*/
/* End of file:	TermWinC.H						    */
