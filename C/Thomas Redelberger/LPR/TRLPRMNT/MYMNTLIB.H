/************************************************************************/
/* interface to the MINT kernel because you must nor use GEMDOS or BIOS	*/
/* calls in an XDD														*/
/* Copyright: Dr. Thomas Redelberger, 2000								*/
/* Tab 4																*/
/************************************************************************/
/*
$Id$
 */

/* referenced by transport.h */
typedef struct
{
	char			d_reserved[21];
	unsigned char	d_attrib;
	unsigned int	d_time;
	unsigned int	d_date;
	unsigned long	d_length;
	char			d_fname[14];
} DTA;
typedef struct baspag
{
		void	*p_lowtpa;
		void	*p_hitpa;
		void	*p_tbase;
		long	p_tlen;
		void	*p_dbase;
		long	p_dlen;
		void	*p_bbase;
		long	p_blen;
		DTA 	*p_dta;
		struct baspag *p_parent;
		long	p_resrvd0;
		char	*p_env;
		char	p_stdfh[6];
		char	p_resrvd1;
		char	p_curdrv;
		long	p_resrvd2[18];
		char	p_cmdlin[128];
} BASPAG;


int		Cconws( const char *buf );
long	Dcntl(short a, long b, long c);
int		Tgettime(void);
int		Tgetdate(void);
int		Fcreate(char* a, short b);
int		Fopen(char* a, short b);
int		Fclose(short a);
long	Fread(short a, long b, char* c);
long	Fwrite(short a, long b, char* c);
int		Fdelete(char* a);
int		Fseek(long a, int b, int c);

void	Bconout(int a, int b);
void	_appl_yield(void);
int		Random(void);
long	Supexec( long (*func)() );










