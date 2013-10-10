#ifndef DESKFUN_H

#define DESKFUN_H

EXTERN	WORD fun_alert(WORD defbut, WORD stnum, BYTE *pvarstr);
EXTERN	VOID fun_msg(WORD type, WORD w3, WORD w4, WORD w5, WORD w6, WORD w7);
EXTERN	VOID fun_rebld(WNODE *pwin);
EXTERN	WORD fun_mkdir(WNODE *pw_node);
EXTERN	WORD fun_op(WORD op, PNODE *pspath, BYTE *pdest,
	WORD dulx, WORD duly, WORD from_disk, WORD src_ob);
EXTERN	WORD fun_wdst(PNODE *pspath, BYTE *pdspec, WORD datype, FNODE *pdf,
	WORD dulx, WORD duly, WORD from_disk, WORD src_ob, WORD *pdo_both);
EXTERN	WORD fun_disk(WORD src_ob, WNODE *pdw, WORD datype,
	FNODE *pdf, WORD dulx, WORD duly);
EXTERN	VOID fun_drag(WORD src_wh, WORD dst_wh, WORD dst_ob, WORD dulx, WORD duly);
EXTERN	VOID fun_del(WNODE *pdw);
EXTERN	WORD cmp_names(BYTE *psrc, BYTE *pdst);

#endif
