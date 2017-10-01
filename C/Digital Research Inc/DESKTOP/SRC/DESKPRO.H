#ifndef DESKPRO_H

#define DESKPRO_H

#if MULTIAPP
EXTERN	VOID pro_chcalc(LONG appsize, LONG *begaddr, LONG *chsize);
#endif
EXTERN	WORD pro_chdir(WORD drv, BYTE *ppath);
EXTERN	WORD pro_cmd(BYTE *psubcmd, BYTE *psubtail, WORD exitflag);
EXTERN	WORD pro_run(WORD isgraf, WORD isover, WORD wh, WORD curr);
EXTERN	WORD pro_exec(WORD isgraf, WORD isover, LONG pcmd, LONG ptail);
EXTERN	WORD pro_exit(LONG pcmd, LONG ptail);

#endif
