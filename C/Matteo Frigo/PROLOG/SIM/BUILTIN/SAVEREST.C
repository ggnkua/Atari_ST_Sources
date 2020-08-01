/************************************************************************
*									*
* The SB-Prolog System							*
* Copyright SUNY at Stony Brook, 1986; University of Arizona, 1987	*
*									*
************************************************************************/

/*-----------------------------------------------------------------
SB-Prolog is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY.  No author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.  Refer to the SB-Prolog General Public
License for full details.

Everyone is granted permission to copy, modify and redistribute
SB-Prolog, but only under the conditions described in the
SB-Prolog General Public License.   A copy of this license is
supposed to have been given to you along with SB-Prolog so you
can know your rights and responsibilities.  It should be in a
file named COPYING.  Among other things, the copyright notice
and this notice must be preserved on all copies. 
------------------------------------------------------------------ */
/* saverest.c */

#include <sys/file.h>
#include "builtin.h"

b_SAVE()    /* reg1 points to PSC entry for constant giving file name */
{
   register LONG     op1;
   register LONG_PTR top;
   PSC_REC_PTR       psc_ptr;
   CHAR              fname[256];

   op1 = reg[1];  DEREF(op1);
   psc_ptr = GET_STR_PSC(op1);
   namestring(psc_ptr, fname);
   if (save(fname) < 0) {
      printf("Cannot save to file '%s'\n",fname);
      FAIL0;
   }
}


save(filename)
CHAR_PTR filename;
{
   int  fd, i;
   LONG space;

   fd = open(filename, (O_WRONLY | O_CREAT), 0644);
   if (fd < 0)
      return fd;
   else {
      i = 19;                  /* "magic no. for saved states */
      write(fd, &i, 4);
      write(fd, &maxpspace, 4);
      write(fd, &maxmem, 4);
      write(fd, &maxtrail, 4);
      write(fd, &pspace, 4);
      write(fd, &memory, 4);
      write(fd, &tstack, 4);
      write(fd, &curr_fence, 4);
      write(fd, &breg, 4);
      write(fd, &ereg, 4);
      write(fd, &hreg, 4);
      write(fd, &trreg, 4);
      write(fd, &hbreg, 4);
      write(fd, &cpreg, 4);
      write(fd, &pcreg, 4);
      write(fd, &nil_sym, 4);
      write(fd, &list_str, 4);
      write(fd, &list_psc, 4);
      write(fd, &comma_psc, 4);
      write(fd, &interrupt_psc, 4);
      write(fd, &trap_vector[0], 4);
      write(fd, &trap_vector[1], 4);

      for (i = 0; i < 10; i++)
         write(fd, &flags[i], 4);

      space = (LONG)curr_fence - (LONG)pspace;
      i = write(fd, pspace, space);
      if (i < space) {
         close(fd);
         return -1;
      }
      space = (LONG)hreg - (LONG)heap_bottom;
      i = write(fd, heap_bottom, space);
      if (i < space) {
         close(fd);
         return -1;
      }
      space = (LONG)local_bottom - ((LONG)ereg - 1040);
      i = write(fd, ((LONG)ereg-1040), space);
      if (i < space) {
         close(fd);
         return -1;
      }
      space = (LONG)trail_bottom - (LONG)trreg;
      i = write(fd, trreg, space);
      if (i < space) {
         close(fd);
         return -1;
      }
      close(fd);
      return 1;
    }
}


b_RESTORE()     /* reg1 points to PSC entry for constant giving file name */
{
    register LONG     op1;
    register LONG_PTR top;
    int               n;
    PSC_REC_PTR       psc_ptr;
    CHAR              fname[256];

    op1 = reg[1];  DEREF(op1);
    psc_ptr = GET_STR_PSC(op1);
    namestring(psc_ptr, fname);
    n = restore(fname);
    if (n == -1) {
       char errormsg[128];
       sprintf(errormsg, "Cannot restore file '%s'\n",fname);
       quit(errormsg);
    }
    else if (n == -2)
       quit(
         "Saved state parameters do not match current values\n");
}


restore(fname)
CHAR_PTR fname;
{
   int      fd, i;
   LONG     space;
   LONG_PTR npspace, nmemory, ntrail;

   fd = open(fname, O_RDONLY, 0644);
   if (fd < 0)
      return fd;
   else {
      read(fd, &i, 4);
      if (i != 19) {
         printf("restore: file '%s' is not an SB-Prolog saved state\n",fname);
         return -1;
      }
      read(fd, &maxpspace, 4);
      read(fd, &maxmem, 4);
      read(fd, &maxtrail, 4);
      read(fd, &npspace, 4);
      read(fd, &nmemory, 4);
      read(fd, &ntrail, 4);
      read(fd, &curr_fence, 4);
      read(fd, &breg, 4);
      read(fd, &ereg, 4);
      read(fd, &hreg, 4);
      read(fd, &trreg, 4);
      read(fd, &hbreg, 4);
      read(fd, &cpreg, 4);
      read(fd, &pcreg, 4);
      read(fd, &nil_sym, 4);
      read(fd, &list_str, 4);
      read(fd, &list_psc, 4);
      read(fd, &comma_psc, 4);
      read(fd, &interrupt_psc, 4);
      read(fd, &trap_vector[0], 4);
      read(fd, &trap_vector[1], 4);

      for (i = 0; i < 10; i++)
         read(fd, &flags[i], 4);

      if (pspace != npspace)
	 return -2;
      if (memory != nmemory)
	 return -2;
      if (tstack != ntrail)
	 return -2;
      space = (LONG)curr_fence - (LONG)pspace;
      i = read(fd, pspace, space);
      if (i != space)
	 return -1;
      space = (LONG)hreg - (LONG)heap_bottom;
      i = read(fd, heap_bottom, space);
      if (i != space)
	 return -1;
      space = (LONG)local_bottom - ((LONG)ereg-1040); /* AR has at most 256
                                                         pvars, + misc info */
      i = read(fd, ((LONG)ereg-1040), space);
      if (i != space)
	 return -1;
      space = (LONG)trail_bottom - (LONG)trreg;
      i = read(fd, trreg, space);
      if (i != space)
	 return -1;
      return 1;
    }
}
