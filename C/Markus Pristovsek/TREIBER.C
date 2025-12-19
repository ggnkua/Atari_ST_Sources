#include <signal.h>
#include <atarierr.h>

#ifdef __GNUC__
#include <fcntl.h>
#include <ioctl.h>
#include <osbind.h>
#endif

#ifdef __TURBOC__
#include "mintbind.h"	/* Geht seltsamerweise nur mit der eigenen Version */
#include <filesys.h>
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
char	*char_status="/-\\|";
char	rot_status;
#endif

/********************************************************************/
/* Einige Routinen zum Druck */


void	disp_wait( void )
{
	while(  old_vec!=0L  ||  Bcostat(0)==0  )
	{
		Fselect( 500, 0L, 0L, 0L );
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



	/* Gibt an Spooler aus (SCHNELL!!) */
long	print_block( long laenge, char *blk )
{
	if(  laenge+puffer_laenge>max_puffer_laenge  )
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
	if(  laenge>max_puffer_laenge  )
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
			Fselect( 100, 0L, 0L, 0L );
		Psignal( SIGINT, (long)exstall );
		Psignal( SIGTERM, (long)exstall );
	}
	return devh;
}
/* 6.2.93 */



int		get_tempfile( char *drucker_ext )
{
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
		while(  (th=(int)Fopen(tmp_file,O_RDWR))>0  )
		{
			Fclose( th );
			if(  (++(tmp_file[lz]))=='9'  )
			{
				++(tmp_file[lz-1]);
				tmp_file[lz] = '0';
			}
		}
		th = (int)Fcreate( tmp_file, 0 );
	}
	else
		th = (int)Fopen( tmp_file, O_WRONLY|O_APPEND|O_CREAT );
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
	while(  next>0  )
	{
		if(  *ptr!=0  )
			return FALSE;
		next--;
		ptr += offset;
	}
	return TRUE;
}
/* 16.1.93 */



/********************************************************************/
/* Hauptprogramm */


int	main( int argc, const char *argv[] )
{
	long	i;
	int		th, devh;
	extern long	CookieJar( long cooks_name );

	if(  argc<6  )
	{
		Cconws( "Zuwenig Argumente!\xD\xA" );
		Cconws( "Richtig: shared_mem_file weite hoehe hdpi vdpi (file)\xD\xA" );
		return 0;
	}

	MiNT = CookieJar( 0x4D694E54L /*'MiNT'*/ );
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
	if(  argv[6]>0L  )
		strcpy( tmp_file, argv[6] );

	th = drucke( memory, atol(argv[2]), atol(argv[3]), atol(argv[4]), atol(argv[5]) );
	if(  shm_name[0]>0  )
	{
		Fclose( shm );
		Mfree( memory );	/* so kann der Speicher wieder freigegeben werden */
		Fdelete( shm_name );
		shm = 0;
	}
	Cconws( "\033H " );

	if(  th<=0	&&  argv[6]>(char*)0	) /* || nach && umgewandelt 6.5.93 MH */
	{	/* Hier bei Fehler oder Funktion gibt selber aus! */
		if(  th<0  )
			Fdelete( tmp_file );
		return th;
	}

	/* Nur Datei erzeugen? */
	if(  argv[6]>0L  )
		return Fclose( th );

		/* Ab hier wird es ernst */
	if(  th<=0  )
		return -1;
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
	flush_block();
	Fclose( devh );
	Cconws( "\033H " );
	return 1;
}
/* 17.1.93 */
