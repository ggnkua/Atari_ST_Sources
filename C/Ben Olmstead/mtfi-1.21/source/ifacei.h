/**********************************************************************/
/* MTFI 1.21 ifacei.h

 Interface header file--stuff that doesn't belong in iface.h.

 Copyright 1998 Ben Olmstead
*/

#ifndef IFACEI_H_INCLUDED
#define IFACEI_H_INCLUDED

int load( FILE *f, const char *fn, fdat *l, struct fmach *funge, int ip );

struct insset
{
  unsigned short maxmode;
  int (*set[5][96])( struct thread**, fdat, struct fmach* );
};

#endif /* IFACEI_H_INCLUDED */

