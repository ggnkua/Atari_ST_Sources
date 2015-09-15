/* ------------------------------------------------------------------------- */
/* ----- fsel_inp.h ------------------------ (c) 1992 by Oliver Scheel ----- */
/* ------------------------------------------------------------------------- */

#ifndef __FSELLIB__
#define __FSELLIB__

#include <tos.h>
#include <aes.h>

#define CMD_FILES_OUT	0x01		/* return filelist */
#define CFG_ONESTRING	0x02		/* return list in one string */
#define CFG_FIRSTNEXT	0x08

/* ------------------------------------------------------------------------- */
/* ----- Selectric Structure ----------------------------------------------- */
/* ------------------------------------------------------------------------- */

typedef struct
{
	unsigned long	id;		/* Selectric ID (SLCT)		*/
	unsigned int	version;	/* version (BCD-Format)		*/
	struct
	{
                unsigned           : 7;    /* reserved                     */
                unsigned todaytime : 1;
                unsigned pthsav    : 1;    /* save GEMDOS paths            */
                unsigned stdest    : 1;    /* stay in destination path     */
                unsigned           : 1;    /* reserved                     */
                unsigned numsrt    : 1;    /* numsort                      */
                unsigned lower     : 1;    /* use lowercase letters        */
                unsigned dclick    : 1;    /* open folder on dclick        */
                unsigned hidden    : 1;    /* show hidden files            */
                unsigned bypass    : 1;    /* Selectric ON/OFF             */
	} config;
	int	sort;			/* sort-mode (neg. = rev.)	*/
	int	num_ext;		/* number of extensions		*/
	char	*(*ext)[];		/* preset extensions		*/
	int	num_paths;		/* number of paths		*/
	char	*(*paths)[];		/* preset paths			*/
	int	comm;			/* communication word		*/
	int	in_count;		/* input counter		*/
	void	*in_ptr;		/* input pointer		*/
	int	out_count;		/* output counter		*/
	void	*out_ptr;		/* output pointer		*/
	int	cdecl	(*get_first)(DTA *dta, int attrib);
	int	cdecl 	(*get_next)(DTA *dta);
	int	cdecl	(*release_dir)(void);
} SLCT_STR;

/* ------------------------------------------------------------------------- */

extern SLCT_STR	*slct;

long *get_cookie(long cookie);
int fsel_check(void);
int slct_check(unsigned int version);
int file_select(char *pfname, char *pname, char *fname, const char *ext, char *title);
int slct_extpath(int ext_num, char *(*ext)[], int path_num, char *(*paths)[]);
int slct_morenames(int mode, int num, void *str);
int slct_first(DTA *mydta, int attr);
int slct_next(DTA *mydta);
int slct_release(void);

#endif
