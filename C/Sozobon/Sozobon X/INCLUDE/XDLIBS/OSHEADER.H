
/* 
 * OSHEADER
 * 
 * 
 */

#ifndef _OS_HEADER
#define	_OS_HEADER
#ifndef _BASEP_H
#include	<basepage.h>
#endif

typedef struct _osheader {
	unsigned int	os_entry;
	unsigned int	os_version;
	void			*reseth;
	struct	_osheader *os_beg;
	void			*os_end;
	long			os_rsv1;
	void			*os_magic;	/* (GEM_MUPB *) */
	long			os_date;
	unsigned int	os_conf;
	unsigned int	os_dosdate;
		/* if (os_version >= 0x102)	*/
	char			**p_root;
	unsigned char	**pkbshift;
	BASEPAGE		**p_run;	/* (* -> act_pd)	*/
	char			*p_rsv2;
}	OSHEADER;

	/* a Gemdos Program Header	*/

typedef	struct Ph {
	unsigned int	ph_branch;
	long	ph_tlen;
	long	ph_dlen;
	long	ph_blen;
	long	ph_slen;
	unsigned long	ph_res1;
	unsigned long	ph_prgflags;
	unsigned int	ph_absflag;
}	PH;

#endif
