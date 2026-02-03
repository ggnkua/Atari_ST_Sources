#include <signal.h>
#include <atarierr.h>

#ifdef __GNUC__
#include <fcntl.h>
#include <ioctl.h>
#include <osbind.h>
#endif

#ifdef __TURBOC__
#include "mintbind.h"	/* Geht seltsamerweise nur mit der eigenen Version */
#endif

#include <stdlib.h>
#include <string.h>

#include "treiber.h"

#define FALSE 0
#define TRUE 1

#define _SHOW_PRT_	/* Fortgang anzeigen */

/********************************************************************/
/* Externe routinen in Assembler (FAST_DVI.S) */
extern long	prn_byte( char *ptr, long byte );
extern void	exstall( void );

extern volatile long	old_vec;
/* 22.1.93 */

/********************************************************************/

/* Pufferspeicher */
static char	*puffer, *druck_puffer;
long	max_puffer_laenge = 8192L;	/* Kann vom Programm modifiziert werden */
static long	puffer_laenge = 0L;

/* Shared Memory */
char				shm_name[128];
static int	shm;
static char	*memory;

/* Name des temporÑren Files */
char 				tmp_file[256];
long				MiNT;

#ifdef _SHOW_PRT_
char	*disp_status="\033Hp";
char	*char_status="/-\\|"; /* Kann man auch durch vier eigene Symbole ersetzen */
char	rot_status;
#endif

extern char	*drucker_ext;	/* Name des Druckers, z.B. HPD */

/********************************************************************/
/* Einige Routinen zum Druck */


void	disp_wait( void )
{
	while(  old_vec!=0L  ||  Bcostat(0)==0  )
	{
		(void)Fselect( 500, 0L, 0L, 0L );
#ifdef _SHOW_PRT_
		disp_status[2] = char_status[rot_status++];
		rot_status &= 3;
		Cconws( disp_status );
#endif
	}
}


	/* Gibt Puffer aus (SCHNELL!!) */
void	flush_block( void )
{
	Psignal( SIGINT, SIG_DFL );
	Psignal( SIGTERM, SIG_DFL );
	if(  puffer_laenge>0  )
	{
		disp_wait();
		memcpy( druck_puffer, puffer, puffer_laenge );
		prn_byte( druck_puffer, puffer_laenge );
	}
	puffer_laenge = 0;
	disp_wait();
}
/* 23.1.93 */



	/* Gibt an aus (SCHNELL! Åber Spooler) */
long	print_block( long laenge, char *blk, short fh )
{
	if(  fh!=3  )
		return Fwrite( fh, laenge, blk );
	if(  laenge+puffer_laenge>=max_puffer_laenge  )
	{
		disp_wait();
		if(  puffer_laenge>0  )
		{
			memcpy( druck_puffer, puffer, puffer_laenge );
			prn_byte( druck_puffer, puffer_laenge );
		}
		puffer_laenge = 0L;
	}

		/* Zu lang... */
	if(  laenge>=max_puffer_laenge  )
	{
		prn_byte( blk, laenge );
		disp_wait();
	}
	else
	{
		memcpy( puffer+puffer_laenge, blk, laenge );
		puffer_laenge += laenge;
	}
	return laenge;
}
/* 22.1.93 */


long	print_str( char *str, short fh )
{
	return print_block( strlen(str), str, fh );
}
/* 3.9.94 */





/* Versucht Drucker zu ôffnen und zu Verriegeln! */ 
int	open_printer( void )
{
	int devh=5;

	puffer = Malloc( max_puffer_laenge );	/* Speicher holen */
	druck_puffer = Malloc( max_puffer_laenge );
	if(  druck_puffer<=0  ||  puffer<=0  )
		return -1;

	if(  MiNT  )
	{	/* Druckersemaphore bekommen! (Wird bei Beendigung automatisch frei) */
		devh = (int)Psemaphore( 0, 0x50524E3AL /*PRN:*/, -1 /*Kein Timeout*/ );
		if(  devh!=0  )
			Psemaphore( 2, 0x50524E3AL /*PRN:*/, -1 /*Kein Timeout*/ );
	}

#ifdef _SHOW_PRT_
	disp_status[2] = '|';
	Cconws( disp_status );
#endif

	if(  MiNT  )
	{
		while(  (devh=(int)Fopen( "U:\\dev\\prn", O_WRONLY ))==EACCDN  )
			(void)Fselect( 100, 0L, 0L, 0L );
		Psignal( SIGINT, (long)exstall );
		Psignal( SIGTERM, (long)exstall );
	}
	return devh;
}
/* 6.2.93 */



int		get_tempfile( void )
{
	/* Aus FILESYS.H */
	#define F_GETLK		5
	#define F_SETLK		6
	struct flock 
	{
	    short   l_type;     /* type of lock                   */
	    #define F_RDLCK 0
	    #define F_WRLCK 1
	    #define F_UNLCK 3
	    short   l_whence;   /* 0:file start, 1:current, 2:EOF */
	    long    l_start;    /* offset of locked region        */
	    long    l_len;      /* 0 for rest of file             */
	    short   l_pid;      /* set by F_GETLK                 */
	} fl;
	/* Eigener Mist */
	char	*p;
	long	lz;
	int		th;

	if(  tmp_file[0]==0  )
	{
		/* In temporÑre Datei drucken! */
		if(  (p=getenv("TMPDIR"))!=0L  )
		{
			strcat( tmp_file, p );
			if(  p[strlen(p-1)]!='\\'  )
				strcat( tmp_file, "\\" );
		}
		strcat( tmp_file, "print00." );
		lz = strlen(tmp_file)-2;
		strcat( tmp_file, drucker_ext );
		while(  (th=(int)Fopen(tmp_file,O_WRONLY))>0  )
		{
			Fclose( th );
			if(  (++(tmp_file[lz]))=='9'  )
			{
				++(tmp_file[lz-1]);
				tmp_file[lz] = '0';
			}
		}
		th = -32;
	}
	else
	{	/* Tempfile wird nur geoeffnet, wenn Datei explizit angegeben */
		th = (int)Fopen( tmp_file, O_WRONLY );
		if(  th>0  )
			Fseek( 0L, th, 2 );
	}
	if(  th<=-32  ) /* Kein BIOS-Fehler */
		th = (int)Fcreate( tmp_file, 0 );
	if(  th>0  )
	{	/* Funktioniert vielleicht */
		fl.l_type = F_WRLCK;
		fl.l_whence = fl.l_start = fl.l_len = 0;
		while(  ELOCKED==Fcntl( th, F_SETLK, &fl )  )
			(void)Fselect( 500, 0l, 0l, 0l );
	}
#ifdef _SHOW_PRT_
	if(  th>=0  )
		Cconws( disp_status );
#endif
	return th;
}
/* 6.2.93 */



/********************************************************************/
/* Routinen fÅr Optimierung */


/* Ist diese Zeile Leerzeile? */
int	ist_leerzeile( char *ptr, long offset )
{
	long	i;
	for(  i=0;  i<offset;  i++  )
		if(  *ptr++!=0  )
			return FALSE;
	return TRUE;
}
/* 16.1.93 */



/* Sind in den nÑchsten #next Zeilen Zeichen? */
int	ist_next_leer( char *ptr, long offset, long next )
{
	while(  next-->0  )
	{
		if(  *ptr!=0  )
			return FALSE;
		ptr += offset;
	}
	return TRUE;
}
/* 16.1.93 */



/********************************************************************/
/* Hauptprogramm */


int	main( int argc, const char *argv[] )
{
	long	i, x, y;
	int		ret, th, devh, flag;
	extern long	CookieJar( long cooks_name );

	if(  argc<6  )
	{
		Cconws( "Zuwenig Argumente!\xD\xA" );
		Cconws( "Richtig: shared_mem_file weite hoehe hdpi vdpi (file)\xD\xA" );
		return 0;
	}

	MiNT = CookieJar( 0x4D694E54L /*'MiNT'*/ );
	Psignal( SIGUSR1, SIG_IGN );
	old_vec = 0L;

		/* Diese Routine mit Parameter versehen! */
		/* Es wird mit Shared Memory gearbeitet */
		/* Wenn der erste Buchstabe eine Zahl ist, */
		/* dann wird diese als Adresse angenommen */
	strcpy( shm_name, (char *)argv[1] );
	if(  shm_name[0]>='0'  &&  shm_name[0]<='9'  )
	{
		memory = (char *)atol( shm_name );
		shm_name[0] = 0;
	}
	else
	{
		shm = (int)Fopen( shm_name, O_RDONLY );
		if(  shm<0  )
			return -1;
		memory = (char *)Fcntl( shm, 0L, SHMGETBLK );
	}
	if(  memory<=0  )
		return 0;

	tmp_file[0] = 0;
	flag = 7;
	x = y = 0;
	i = 2;
	if(  argv[2][0]=='-'  )
	{	/* Mehrere Teile */
		x = -atol(argv[2]);
		/* Mehrere Teile */
		y = -atol(argv[3]);
		flag = (2 + ((y==0) && (x==0)));
		i = 4;
	}

	th = 3;
	/* Evt. Zieldatei îffnen */
	if(  argv[i+4]>0L  )
	{
		strcpy( tmp_file, argv[i+4] );
		th = get_tempfile();
	}
	else
		if(  open_printer()<0  )
			return -1;

		/* Und endlich drucken */
	if(  (long)memory==1L  )
		ret = drucke( 0L, 0, 0, 0, 0, 0, 0, th, 4 );
	else
		ret = drucke( memory, x, y, atol(argv[i]), atol(argv[i+1]), atol(argv[i+2]), atol(argv[i+3]), th, flag );

	if(  shm_name[0]>0  )
	{
		Fclose( shm );
		Mfree( memory );	/* so kann der Speicher wieder freigegeben werden */
		Fdelete( shm_name );
		shm = 0;
	}
	if(  ret<=0  ||  ret==3  ) /* || nach && umgewandelt 6.5.93 MH */
	{	/* Hier bei Fehler oder Funktion gibt selber aus! */
		/* Nur Datei erzeugen? */
		if(  th>0  )
			Fclose( th );
		if(  th==3  )
			flush_block();
		if(  ret<0  )
			Fdelete( tmp_file );
		Cconws( "\033H " );
		return 0;
	}

		/* Ab hier wird es ernst */
	if(  th>5  )
		return Fclose(th);
	while(  (devh=open_printer())==-1  &&  max_puffer_laenge>128  )
		max_puffer_laenge /= 2L;	/* Puffer halbieren */
	if(  devh<0  )
		return -1;

	Fseek( 0L, th, 0 );
	i = max_puffer_laenge;
	do
	{
		disp_wait();
		i = Fread( th, i, druck_puffer );
		if(  i>0  )
			prn_byte( druck_puffer, i );
	}
	while(  i>0  );

	Fclose( th );
	if(  tmp_file[0]>0  )
		Fdelete( tmp_file );
	Fclose( devh );
	Cconws( "\033H " );
	return 1;
}
/* 17.1.93 */
