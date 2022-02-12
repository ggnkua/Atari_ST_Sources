/* Prototypes */

/* mdbdis.c */
_PROTOTYPE(long dasm , (long addr , int cnt , int symflg ));

/* mdbexp.c */
_PROTOTYPE(char *addr_to_name , (long rel_addr , long *off_p ));
_PROTOTYPE(long reg_addr , (char *s ));
_PROTOTYPE(void symbolic , (long addr , int sep ));
_PROTOTYPE(char *getexp , (char *buf , long *exp_p , int *seg_p ));
_PROTOTYPE(void getsyms , (char *file ));

