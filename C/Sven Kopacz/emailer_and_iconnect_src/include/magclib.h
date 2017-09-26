/* scrollable textedit objects */ 
 
typedef struct _xted { 
  char    *xte_ptmplt; 
  char    *xte_pvalid; 
  WORD    xte_vislen; 
  WORD    xte_scroll; 
} XTED; 


/*extern ULONG *get_cookie(ULONG val);*/
extern WORD get_MagiC_ver(ULONG *crdate);
extern void init_scrlted(OBJECT *o, WORD is_scroll, XTED *xted,
				char *txt, char *tmplt, WORD len);
