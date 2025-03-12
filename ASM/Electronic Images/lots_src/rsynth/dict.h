/* $Id: dict.h,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $
*/
typedef struct
 {char spell[23];
  char pronounce[23];
  char syntax[23];
  char syllables;
  char verb[58];
  char eoln;
 } dictrec_t,*dictrec_ptr;

typedef struct
 {dictrec_ptr base;
  unsigned long size;
  unsigned long entries;
 } dict_t, *dict_ptr;

extern dictrec_ptr spell_find PROTO((dict_ptr d, char *s, unsigned n));
extern int dict_init PROTO((dict_ptr d, char *path));
extern void dict_term PROTO((dict_ptr d));

