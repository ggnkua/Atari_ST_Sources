#ifndef DESKINS_H

#define DESKINS_H

EXTERN	WORD is_installed(ANODE *pa);
EXTERN	WORD lastdisk(VOID);
EXTERN	VOID ins_posdisk(WORD dx, WORD dy, WORD *pdx, WORD *pdy);
EXTERN	ANODE *get_disk(WORD letter);
EXTERN	WORD ins_disk(ANODE *pa);
EXTERN	VOID insa_icon(LONG tree, WORD obj, WORD nicon, ICONBLK *pic, BYTE *ptext);
EXTERN	VOID insa_elev(LONG tree, WORD nicon, WORD numics);
EXTERN	WORD insa_dial(LONG tree, WORD nicon, WORD numics);
EXTERN	VOID insa_gtypes(LONG tree, BYTE *ptypes);
EXTERN	VOID insa_stypes(LONG tree, BYTE *pdata);
#if MULTIAPP
EXTERN	WORD ins_latoi(LONG st_ad);
#endif
EXTERN	WORD ins_app(BYTE *pfname, ANODE *pa);
EXTERN	VOID ob_actxywh(LONG tree, WORD obj, GRECT *p);
EXTERN	VOID ob_relxywh(LONG tree, WORD obj, GRECT *prect);

#endif
