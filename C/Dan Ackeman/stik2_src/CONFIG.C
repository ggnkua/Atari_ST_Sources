/*  config.c             (c) Steve Adam 1995         steve@netinfo.com.au
 *
 *      This module loads a config file (currently only `default.cfg')
 *  into memory and sets an array of (char *) to point to the start
 *  of lines that contain a config string. (ie: isalpha(line[0]) == TRUE)
 *
 *      Also the function extern getvstr() returns a pointer to the start
 *  of a variable.
 *
 *      The format of the config file is lines that are VARIABLE = VALUE
 *  Any line that does not start with a [a-zA-Z] is ignored, *but still
 *  kept in memory*.
 *
 *      That's all...  Easy, huh??
 *
 *	** NOTE **	This module also contains the array of TCP functions
 *	for export, as well as the code to put the pointer in the CJAR
 */

#include "lattice.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <tos.h>
#include "device.h"

#include "globdefs.h"
#include "globdecl.h"
#include "display.h"
#include "tpl.h"

#define STIK 0x5354694BL

#define CFG_ENTRIES 100 /*  100 entries should be enough to begin with..    */
static char *ON  = "1\0";
static char *OFF = "0\0";

/*static char *cv[CFG_ENTRIES + 1];    Extra slot is for End of List (0)    */

char *cfgptr;   /* This is where the file is loaded */

extern int CFGmeminit(unsigned long nbytes);
extern char * cdecl CFGmalloc(unsigned long reqsize);extern int cdecl CFGfree(char *ap);
/* size file returns size of a file or -1L if not found
 */

static int32 size_file(char *f)
{
    DTA dta, *saved;

    saved = (DTA *)Fgetdta();
    Fsetdta(&dta);

    if ((Fsfirst(f, 0xff)) != 0) 
    {
        Fsetdta(saved);
        return ((int32)-1);
    }

    Fsetdta(saved);

    return ((int32)dta.d_length);
}

int16 
init_cfg(char *fname)
{
    int16 i,cnt;
   	char l[100];
	FILE *fp;
	char *s = NULL; /* Used to track position */

    if (!CFGmeminit(4096)) {
		printf("Can't allocate Config memory buffer");
        return (-1);
    }

	if ((fp = fopen(fname,"r")) == (FILE *)NULL) 
	{
		disp_info("Can't Open %s",fname);
		return ((int16)-1);
	}

    i = 0;

	while ((fgets(l, (int)100,  fp) != (char *)NULL) &&
		(i < CFG_ENTRIES))
	{
		if (!isalpha(l[0]))
			continue;

		if((config.cv[i] = CFGmalloc(strlen(l)+1)) != (char *)NULL)
		{
			/* Now we need to clean up the end of l 
			 * No spaces, tabs or returns or CRLF's
			 */

			cnt = (int)strlen(l) - 1;
			s = (char *)&l[cnt];

			while(cnt > 0)
			{
	           if (*s == '\r' || *s == '\n' || *s == ' ' || *s == '\t')
	                s -= 1;
	            else
	                break;
	           
	           cnt= cnt-1;
			}
			 
	        s += 1; /* First whitespace character   */

	        while (*s == '\r' || *s == '\n' || *s == ' ' || *s == '\t')
	            *s++ = '\0';

			strcpy(config.cv[i],l);
		}
		else
		{
			i += 1;
			disp_info("No more memory in config buffer");
			goto conf_fclose;
		}
			
		i += 1;		
	}

conf_fclose:

	fclose(fp);

    config.cv[i] = (char *)NULL;

    return (0);
}

/* old way to Read the config file
 */
 
int16 
oldinit_cfg(char *fname)
{
    int32 fsize;
    int32 stat;
    int16 fd;
    char  *s, *sstart;
    int16 i;

    fsize = size_file(fname);

    if (fsize < 0)
        return ((int16)-1);

    stat = Fopen(fname, 0);
    if (stat < 0)
        return ((int16)-1);

    cfgptr = (char *)Malloc(fsize + 3);
    if (cfgptr == (char *)NULL)
        return ((int16)-1);

    fd = (int16)stat;
    stat = Fread(fd, fsize, cfgptr);
    Fclose(fd);
    if (stat != fsize)
        return ((int16)-1);

    strcpy(&cfgptr[fsize], "\r\n"); /* Append CRLF to file (just in case)   */

    /* OK, the file is loaded.  Now set the cv pointers to point
     * to valid variable lines.  (Any line starting with [a-zA-Z]);
     * Also, null terminate each line (at \r, or \n, or both)
     */

    s = cfgptr;
    i = 0;
    while (s < &cfgptr[fsize] && i < CFG_ENTRIES) 
    {
        if (isalpha(*s))
            config.cv[i++] = sstart = s;

        while (*s && *s != '\r' && *s != '\n')  /* Find eol */
            ++s;

        /* Trim blanks and tabs from end of value string (every line!!)     */

        while (s > sstart) 
        {    /* Find last non-whitespace     */
            if (*s == '\r' || *s == '\n' || *s == ' ' || *s == '\t')
                s -= 1;
            else
                break;
        }
        s += 1; /* First whitespace character   */

        while (*s == '\r' || *s == '\n' || *s == ' ' || *s == '\t')
            *s++ = '\0';
    }
    config.cv[i] = (char *)NULL;

    return (0);
}

/* Test a string to see if they match
 * case independant
 */
int16 
equ_txtn(char *s1, char *s2, int16 n)
{
    while (n--) {
        if (toupper(*s1) != toupper(*s2)) {
            return (FALSE);
        }
        if (*s1 == '\0')
            break;

        s1 += 1;
        s2 += 1;
    }
    return (TRUE);
}

/* retrieve a variable from the stik config list
 */
 
char * cdecl
getvstr(char *vs)
{
    register int i = 0, len, vi;
    char *s;
    register char *off = "0\0";
    register char *on = "1\0";

    while (config.cv[i] != (char *)NULL) 
    {
        if (equ_txtn(vs, config.cv[i], (int16)strlen(vs))) 
        {
            s = config.cv[i];

            len = (int16)strlen(s);

            vi = (int16)strcspn(s, "=");
            if (vi >= len)
                return (on); /* ON */

            vi += 1;    /* Jump over '='    */

            while (s[vi] && (s[vi] == ' ' || s[vi] == '\t'))
                vi += 1;

            if (s[vi]) 
            {
                if (equ_txtn(&s[vi], "TRUE", 4)||equ_txtn(&s[vi], "ON", 2))
                    return (on); /* ON */

                if (equ_txtn(&s[vi], "FALSE", 5)||equ_txtn(&s[vi], "OFF", 3))
                    return (off);

                return ((char *)&s[vi]);    /* Not boolean, return ptr to value */
            }
            else
                return (off);
        }
        i += 1;
    }
    return (off);
}

/* Set a config variable string */
int16 cdecl 
setvstr(char *vs, char *value)
{
    register int i = 0;
    register char s[100];

    while (config.cv[i] != (char *)NULL)
   	{
   	    if (equ_txtn(vs, config.cv[i], (int16)strlen(vs))) 
    	{
    		CFGfree(config.cv[i]);
    	
			sprintf(s,"%s = %s\0",vs,value);

    		config.cv[i] = CFGmalloc(strlen(s)+1);

			strcpy(config.cv[i],s);
			return(TRUE);
   		}
       	i += 1;
   	}
    	
    if (i < CFG_ENTRIES+1)
   	{
		sprintf(s,"%s = %s\0",vs,value);

   		config.cv[i] = CFGmalloc(strlen(s)+1);
		strcpy(config.cv[i],s);
   		return(TRUE);
   	}
    	
    return (FALSE);
}

int16 cdecl oldsetvstr(char *vs, char *value)
{
    register int i = 0;
    register char *s;

	/*disp_info("setvstr %s %s",vs,value);*/

    while (config.cv[i] != (char *)NULL) 
   	{
   	    if (equ_txtn(vs, config.cv[i], (int16)strlen(vs))) 
    	{
    		s = config.cv[i];
			sprintf(s,"%s = %s",vs,value);
			strcpy(config.cv[i],s);
			return(TRUE);	
   		}
       	i += 1;
   	}
    	
   	/*printf("%d\r\n",i);*/
    	
    if (i < CFG_ENTRIES+1)
   	{
		s = config.cv[i];
		sprintf(s,"%s = %s",vs,value);
		strcpy(config.cv[i],s);
   		return(TRUE);
   	}
    	
    return (FALSE);
}

typedef struct drv_header {
	char *module;
	char *author;
	char *version;
} DRV_HDR;

typedef struct {
    long cktag;
    long ckvalue;
} ck_entry;

struct DRV_LIST {
	char magic[10];
	DRV_HDR * cdecl (*get_dftab)(char *);
	int16     cdecl (*ETM_exec)(char *);
	CONFIG	*config;
	DRV_HDR *drvlist[20];
};

extern struct DRV_LIST *drivers;
extern struct TPL *tpl;

void (*prot_in)(void) = dummyfn;
void (*prot_out)(void) = dummyfn;
void (*prot_kicker)(void) = dummyfn;
void (*prot_term)(void) = dummyfn;
void (*yield)(void) = dummyfn;

/* This is the main routine of STiK
 * called by the interupt
 */

void
stik(void)
{
extern void	tcp_timer(void);
/*extern int16 new_carrier_detect(void);*/	/* from oldmain.c */
extern void close_port(void);

extern void do_resolve(void);

extern unsigned char flagbox[64];

static int wait = 1;
static char lock = 0;
static char *stikstat="xSTIKSTAT";

/* This next line will need to be expanded for more ports */

*stikstat='a';

	if ((set_flag(FL_housekeep)==FALSE))
	{
		/*lock = 1; old turn off*/
			
		if ((wait++)<config.slice)
		{
			clear_flag(FL_housekeep);
			*stikstat = 'h';
			return;
		}
				
		wait = 1;
			
		*stikstat='y';

		if (test_flag(FL_malloc) == TRUE)
		{
			clear_flag(FL_housekeep);
			*stikstat = 'h';
			return;
		}
				
		if (port_open == 1)
		{
			lock = 1;
					
			*stikstat='b';
			
			(*prot_kicker)();

			*stikstat='c';

			(*prot_in)();

			*stikstat='d';

			(*prot_out)();
		}

		*stikstat='e';
	    tcp_timer();
		    
	    *stikstat='f';
	    frag_ttl_check();
		    
		*stikstat='g';

		/* trying to recreate the old resolver / fix it */
		/*do_resolve();*/
			
		{
			extern	int	gdrout;
			
			if (gdrout!=0)
			{
				disp_info("STiK: GEMDOS routine %d called",gdrout);
				gdrout=0;
			}
		}

		/*lock = 0; old turn off*/

		/* If someone closes the port, send a terminate request */
		/* The provider may disconnect us however */
	
		if (!port_open && (lock == 1))
		{
			(*prot_term)();
			(*prot_out)();
			close_port();
			lock = 0;
		}

		clear_flag(FL_housekeep);
	}
	
	*stikstat='h';
}
