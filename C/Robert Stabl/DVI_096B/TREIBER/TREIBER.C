#include <mintbind.h>
#include <filesys.h>
#include <signal.h>
#include <atarierr.h>

#include <stdlib.h>
#include <string.h>

#include <treiber.h>

#define FALSE 0
#define TRUE 1


/********************************************************************/
/* Externe routinen in Assembler (FAST_DVI.S) */
extern long	prn_byte( char *ptr, unsigned long byte );
extern void	exstall( void );

extern volatile long	anzahl, old_vec;
extern volatile char	*ptr;
/* 22.1.93 */

/********************************************************************/

/* Pufferspeicher */
static char	buf[8192], r[8192];
static long	buflen = 0L;

/* Shared Memory */
char				*shm_name;
static int	shm;
static char	*memory;

/* Name des temporÑren Files */
char 				tmp_file[256];

/********************************************************************/
/* Einige Routinen zum Druck */

	/* Gibt Puffer aus (SCHNELL!!) */
void	flush_block( void )
{
	/* Shared Memory freigeben */
	if(  shm>0  )
	{
		Fclose( shm );
		Fdelete( shm_name );
		Mfree( memory );	/* so kann der Speicher wieder freigegeben werden */
	}
	shm = 0;

	if(  buflen>0  )
	{
		while( old_vec  )
			Fselect( 500, 0L, 0L, 0L );
		memcpy( r, buf, buflen );
		prn_byte( r, buflen );
		buflen = 0;
	}
	while( old_vec  )
		Fselect( 500, 0L, 0L, 0L );
}
/* 23.1.93 */



	/* Gibt an Spooler aus (SCHNELL!!) */
void	print_block( long len, char *blk )
{
	if(  len+buflen>8192L  )
	{
		while( old_vec  )
			Fselect( 500, 0L, 0L, 0L );
		memcpy( r, buf, buflen );
		prn_byte( r, buflen );
		buflen = 0;
	}
	memcpy( buf+buflen, blk, len );
	buflen += len;
}
/* 22.1.93 */



/* Versucht Drucker zu ôffnen und zu Verriegeln! */ 
int	open_printer( void )
{
	int devh;

		/* Druckersemaphore bekommen! (Wird bei Beendigung automatisch frei) */
	devh = (int)Psemaphore( 0, 0x50524E3AL /*PRN:*/, -1 /*Kein Timeout*/ );
	if(  devh!=0  )
		Psemaphore( 2, 0x50524E3AL /*PRN:*/, -1 /*Kein Timeout*/ );

	while(  (devh=(int)Fopen( "U:\\dev\\prn", O_WRONLY ))==EACCDN  )
		;
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

	if(  argc<6  )
	{
		Cconws( "Zuwenig Argumente!\xD\xA" );
		Cconws( "Richtig: shared_mem_file weite hoehe hdpi vdpi (file)\xD\xA" );
		return 0;
	}

 	/* Starte Ausdruck */
	ptr = 0L;
	Psignal( SIGINT, (long)exstall );
	Psignal( SIGTERM, (long)exstall );

		/* Diese Routine mit Parameter versehen! */
		/* Es wird mit Shared Memory gearbeitet */
	shm_name = (char *)argv[1];
	shm = (int)Fopen( shm_name, O_RDONLY );
	if(  shm<0  )
		return -1;
	memory = (char *)Fcntl( shm, 0L, SHMGETBLK );
	if(  memory<=0  )
		return 0;
 	tmp_file[0] = 0;
	if(  argv[6]>0L  )
		strcpy( tmp_file, argv[6] );
	th = drucke( memory, atol(argv[2]), atol(argv[3]), atol(argv[4]), atol(argv[5]) );
	Fclose( shm );
	shm = 0;
	Mfree( memory );	/* so kann der Speicher wieder freigegeben werden */
	if(  th<=0  ||  argv[6]>0  )
	{
		/* Hier bei Fehler oder Funktion gibt selber aus! */
		Cconws( "\033H " );
		if(  th<0  )
			Fdelete( tmp_file );
		return th;
	}

	/* Nur Datei erzeugen? */
	if(  argv[6]>0L  )
		return Fclose( th );

		/* Ab hier wird es ernst */
	if(  (devh=open_printer())<0  ||  th<0  )
		return 0;
	Fseek( 0L, th, 0 );
	i = 8192L;
	buflen = 0L;
	do
	{
		while( old_vec  )
			Fselect( 500, 0L, 0L, 0L );
		i = Fread( th, i, r );
		if(  i>0  )
			prn_byte( r, i );
	}
	while(  i>0  );

	Fclose( th );
	if(  tmp_file[0]>0  )
		Fdelete( tmp_file );
	while( anzahl>0  )
	{
		Talarm( 1 );
		Pause();
	}
	Fclose( devh );
	Cconws( "\033H " );
	return 1;
}
/* 17.1.93 */
