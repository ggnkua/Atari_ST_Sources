#ifndef DESKDIR_H

#define DESKDIR_H

EXTERN	VOID draw_dial(LONG tree);
EXTERN	VOID show_hide(WORD fmd, LONG tree);
EXTERN	VOID do_namecon(VOID);
EXTERN	VOID draw_fld(LONG tree, WORD obj);
EXTERN	BYTE *scan_slsh(BYTE *path);
EXTERN	VOID add_path(BYTE *path, BYTE *new_name);
EXTERN	VOID sub_path(BYTE *path);
EXTERN	VOID add_fname(BYTE *path, BYTE *new_name);
EXTERN	WORD fold_wind(BYTE *path);
EXTERN	VOID like_parent(BYTE *path, BYTE *new_name);
EXTERN	WORD same_fold(BYTE *psrc, BYTE *pdst);
EXTERN	VOID del_fname(BYTE *pstr);
EXTERN	VOID get_fname(BYTE *pstr, BYTE *newstr);
EXTERN	WORD d_errmsg(VOID);
EXTERN	WORD d_dofdel(BYTE *ppath);
EXTERN	WORD d_dofcopy(BYTE *psrc_file, BYTE *pdst_file, WORD time, WORD date, WORD attr);
EXTERN	WORD d_doop(WORD op, LONG tree, WORD obj, BYTE *psrc_path, BYTE *pdst_path,
	WORD *pfcnt, WORD *pdcnt, WORD flag);
EXTERN	BYTE *ret_path(REG BYTE *pcurr);
EXTERN	WORD par_chk(BYTE *psrc_path, FNODE *pflist, BYTE *pdst_path);
EXTERN	WORD dir_op(WORD op, BYTE *psrc_path, FNODE *pflist, BYTE *pdst_path,
	WORD *pfcnt, WORD *pdcnt, LONG *psize, WORD dulx, WORD duly,
	WORD from_disk, WORD src_ob);
EXTERN	VOID blank_it(WORD obid);
EXTERN	VOID move_icon(WORD obj, WORD dulx, WORD duly);

#endif
