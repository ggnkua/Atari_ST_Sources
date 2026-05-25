/* d‚finition des allocations m‚moire */
__EXTERN void *my_Malloc __PROTO((long taille));
__EXTERN void my_Free __PROTO((void *pt_mem));
__EXTERN void Freeall __PROTO((void));
__EXTERN void *my_calloc __PROTO((unsigned int t1, unsigned int t2));
