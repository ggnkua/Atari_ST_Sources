/* Headerfile zu 'dublong.c' */

typedef struct {
  long          high;
  unsigned long low;
} dublong;
                             /* Parameter :   */
extern dublong *dl_todl();   /* ( l, &dl )    */
extern long     dl_tolong(); /* ( dl )        */
extern dublong *dl_neg();    /* ( &dl )       */
extern dublong *dl_add();    /* ( dl,dl,&dl ) */
extern dublong *dl_sub();    /* ( dl,dl,&dl ) */
extern dublong *dl_mul();    /* ( l, l, &dl ) */
extern dublong *dl_mul2();   /* ( dl,dl,&dl ) */
extern long     dl_div();    /* ( dl, l, &l ) */
extern dublong *atodl();     /* ( str, &dl )  */

