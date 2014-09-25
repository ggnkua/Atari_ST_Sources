/*      jk_os.h                                      By Jeff Koftinoff
**                                                     started 3/27/1987
**
**		operating system macros
**		#includes <osbind.h>
**		contains commonly used structures relating to the operating
**		system.
**
*/


#ifndef __JK_OS_H
#define __JK_OS_H


#include <osbind.h>

struct os_keytab 
{		      // keyboard translation tables 
       char *unshift;
       char *shift;
       char *capslock;
};


struct os_maus 
{
       char topmode;
       char buttons;
       char xparam;
       char yparam;
       short xmax, ymax;                 // used only when mouse
       short xinitial, yinitial;         // is in absolute mode
};

struct os_disk_info 
{
       long    b_free;         // # of free clusters  
       long    b_total;        // total # of clusters 
       long    b_secsiz;       // bytes per sector     
       long    b_clsiz;        // sectors per cluster 
};

typedef struct os_dta 
{
       char    system[20];
       unsigned char   attributes;
       short     time;
       short     date;
       long    length;
       char    name[14];
} DTA;


#endif


