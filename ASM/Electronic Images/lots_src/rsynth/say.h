/* $Id: say.h,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $
*/
extern unsigned xlate_string PROTO((char *string,darray_ptr phone));
extern void say_string PROTO((char *s));
extern char *concat_args PROTO((int argc,char *argv[]));
extern void say_phones PROTO((char *phone,int len));
extern int suspect_word PROTO((char *s,int n));
extern unsigned spell_out PROTO((char *word,int n,darray_ptr phone));
extern unsigned xlate_ordinal PROTO((long int value,darray_ptr phone));
extern unsigned xlate_cardinal PROTO((long int value,darray_ptr phone));

