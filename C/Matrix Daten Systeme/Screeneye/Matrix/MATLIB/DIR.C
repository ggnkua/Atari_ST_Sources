# define MAIN 0

# include <stdlib.h>
# include <stdio.h>
# include <errno.h>
# include <string.h>
# include <ext.h>
# include <tos.h>
# include <ctype.h>

# include "global.h"
# include "ascii.h"
# include "error.h"

# include "dir.h"


/*------------------------------------------------ remove_dir ------*/
int remove_dir ( char *path ) 
{
	return Ddelete ( path ) == 0 ? OK : CANTdeleteDir ;
}

/*------------------------------------------------ make_dir --------*/
int make_dir ( char *path ) 
{
	return Dcreate ( path ) == 0 ? OK : CANTmakeDir ;
}

/*------------------------------------------- get_cd ---*/
int get_cd ( char *path )
{
	int result ;
	char sp[80] ;
	
	result = Dgetpath ( sp, 0 ) ;
	if ( result != OK )
	{
		strcpy ( sp, "???" ) ;
		result = GETpathError ;
	}
	sprintf ( path, "%c:%s", Dgetdrv()+'A', sp ) ;
	return ( result ) ;
}
						
/*---------------------------------------------- pwd ---*/
int pwd ( void )
{
	int result ;
	char path[80] ;
	
	result = get_cd ( path ) ;
	printf ( "%s\n", path ) ;
	return ( result ) ;
}
						
/*---------------------------------------------- cd ----------------*/
int cd ( char *path )
{
	int result ;
	int drive ;

	drive = tolower ( *path ) - 'a' ;
	
	if ( drive >= 0 && drive <= 15 && path[1] == ':' )
	{
		if ( ( Dsetdrv ( drive ) & (1<<drive) ) == 0 )
			return ( SETdriveError ) ;	/*	drive not mounted	*/
		path += 2 ;
		if ( *path == EOS )
			strcat ( path, "\\" ) ;
	}

	result = Dsetpath ( path ) ;
	if ( result != OK )
		result = SETpathError ;
	return ( result ) ;
} 


# if 0
# define _bootdev 0x446
char boot_drive_num ;

/*------------------------------------ set_boot_drive --------------*/
long set_boot_drive(void)
{
	boot_drive_num = *(int *)_bootdev ;
	return ( 0 ) ;
}
# endif

# define DAY(d)		((d)&0x1f)
# define MONTH(d)	(((d)>>5)&0x0f)
# define YEAR(d)	((((d)>>9)&0x7f)+80)

# define SEC(t)		(((t)&0x1f)*2)
# define MIN(t)		(((t)>>5)&0x3f)
# define HOUR(t)	(((t)>>11)&0x1f)


/*------------------------------------ scan_dir_tree -------------*/
int scan_dir_tree ( char *path, char *wild, unsigned flags,
					   DIR_PROC *dirproc, void *par )
{
	DTA myDTA, *olddta ;
	int result, n ;
	char wild_sel[128] ;
	char oldpath[128], subdir[128] ;
	bool stop ;
		
	result = Dgetpath ( subdir, 0 ) ;
	oldpath[0] = Dgetdrv()+'A' ;
	oldpath[1] = ':' ;
	oldpath[2] = NUL ;
	strcat ( oldpath, subdir ) ;

	if ( ( result = cd ( path ) ) == OK )
	{
		olddta = Fgetdta() ;
		Fsetdta ( &myDTA ) ;
	
		if ( *path == EOS )	/* no path, only filename specified */
			strcpy ( wild_sel, oldpath ) ;
		else if ( *path != '\\' && strchr ( path, ':' ) == NULL )
		{		/* subdirectory of working directory specified */
			strcpy ( wild_sel, oldpath ) ;
			strcat ( wild_sel, "\\\0" ) ;
			strcat ( wild_sel, path ) ;
		}
		else	/* disk (+path) specified */
			strcpy ( wild_sel, path ) ;

		if ( wild_sel[ strlen (wild_sel)-1] != '\\' )		
			strcat ( wild_sel, "\\\0" ) ;
		strcat ( wild_sel, wild ) ;
	
		result = Fsfirst ( wild_sel, 0xff ) ;
		stop = FALSE ;
		for ( n = 0; result == OK && ! stop; n++ )
		{
			(*dirproc) ( &myDTA, n, flags, par ) ;
			if ( (flags & SUB_DIR) && ( myDTA.d_attrib & FA_SUBDIR ) && ( *myDTA.d_fname != '.'  ) )
			{
				strcpy ( subdir, myDTA.d_fname ) ;
				result = scan_dir_tree ( subdir, wild, flags, dirproc, par ) ;
				Fsetdta ( &myDTA ) ;
			}
			stop = Fsnext() != OK ;
		}

		Fsetdta ( olddta ) ;	/* set dta to safe global variable	*/
	}
	
	cd ( oldpath ) ;		/* restore original path */
	return ( result ) ;
}

# define ifc(b,c)	( dta->d_attrib & b ? c : '.' )

/*------------------------------------ print_dir_entry -------------*/
int print_dir_entry ( DTA *dta, int n, unsigned flags, void *par )
{
	par = par ;
	if ( n == 0 )
		printf ( "\n" ) ;
	if ( flags & HEX_LIST )
	{
		int i ;
		for ( i = 21; i > 0 ; i-- )
			printf ( "%2.2x ", dta->d_reserved[i] ) ;
	}
	if ( (flags & NO_TEXT) == 0 )
	{
		printf ( "%2d %-14s %c%c%c%c%c%c  %02d:%02d:%02d  %02d.%02d.%02d %10ld\n",
			 n,
			 dta->d_fname,
			 ifc( FA_READONLY,	'R' ),
			 ifc( FA_HIDDEN,	'H' ),
			 ifc( FA_SYSTEM,	'S' ),
			 ifc( FA_VOLUME,	'V' ),
			 ifc( FA_SUBDIR,	'D' ),
			 ifc( FA_ARCHIVE,	'A' ),
			 HOUR(dta->d_time), MIN(dta->d_time), SEC(dta->d_time),
			 DAY(dta->d_date), MONTH(dta->d_date), YEAR(dta->d_date),
			 dta->d_length   ) ;
	}
	else
		printf ( "\n" ) ;
	return ( OK ) ;
}

/*------------------------------------ strlchr --------------*/
char *strlchr ( char *s, char c )
{
	char *p0 ;

	do
	{
		p0 = s ;
		s = strchr ( p0+1, c ) ;
	} while ( s != NULL ) ;
	return ( p0 ) ;
}


/*------------------------------------ dir_list -------------*/
int dir_list ( char *path, unsigned flags )
{
	int result ;
	char pa[128] ;
	char *p,*p0 ;
	
	printf ( "\n- listing of %s:", path ) ;
	strcpy ( pa, path ) ;
	p = strchr ( pa, '\\' ) ;
	if ( p == NULL )
	{
		if ( *pa == 0 )			/* dir 		 */
			result = scan_dir_tree ( "", "*.*", flags, print_dir_entry, NULL ) ;
		else					/* dir x:x.y */
			result = scan_dir_tree ( "", pa, flags, print_dir_entry, NULL ) ;
	}
	else
	{
		p0 = strlchr ( p, '\\' ) ;
		*p0++ = 0 ;
		if ( *p0 == 0 )			/* dir x:\dir\path\	*/
			result = scan_dir_tree ( pa, "*.*", flags, print_dir_entry, NULL ) ;
		else					/* dir x:\dir\path\x.y	*/
			result = scan_dir_tree ( pa, p0, flags, print_dir_entry, NULL ) ;
	}
	printf ( "\n" ) ;
	return ( result ) ;
}


/*------------------------------------------ disk_info -------------*/
int disk_info ( int driveno, ulong *free, ulong *total )
{
	DISKINFO info ;
	ulong cluster_size ;
	
	
	if ( Dfree ( &info, driveno ) == 0 )
	{
		cluster_size = info.b_secsiz * info.b_clsiz ;
# if 0
		printf (
"\033Y0 drive %d : b_secsiz = %lu, b_clsiz = %lu, b_free = %lu, b_total = %lu; cluster_size = %lu\n",
			driveno,
			info.b_secsiz, info.b_clsiz, info.b_free, info.b_total,
			cluster_size ) ;
# endif
		*free  = info.b_free  * cluster_size ;
		*total = info.b_total * cluster_size ;
		return OK ;
	}
	else
	{
		*free  = 0 ;
		*total = 0 ;
		return DISKinfoError ;
	}
}

# if MAIN
/*----------------------------------------------------- main -------*/
int main(int argc,char *argv[])
{
	int n ;
	
# if 0
	Supexec ( set_boot_drive ) ;
# endif

	for ( n = 1; n < argc; n++ )
 	{
 		dir_list ( argv[n], SUB_DIR ) ;
	}
	return ( OK ) ;
}
# endif

