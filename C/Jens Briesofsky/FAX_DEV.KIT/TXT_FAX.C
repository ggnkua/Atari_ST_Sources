/*
*		FILE:		TXT_FAX.C
*
*		Demo fÅr Faxausgabe mit TeleOffice
*/

#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "fax_out.h"

#define MAX_BUF	128

FAX_OUTPUT *fxout;

int init_fxout( void  )
{
	long oldsp=0L;
	struct cookie *cptr;

	if( Super((void *)1L)==0 ) oldsp = Super( NULL );
	cptr = *(struct cookie **)0x5a0;
	if( oldsp ) Super( (void *)oldsp );
	fxout=NULL;
	if( cptr == NULL ) return -1;	/* altes TOS ohne Cookie Jar! */
	while( cptr->c ){
		if( cptr->c == FAX_COOKIE ) {		/* gefunden */
			fxout = (FAX_OUTPUT *)cptr->v;
			if( fxout->fax_ready==1 ) return 0;
			fxout=NULL;
			return -2;
		}
		cptr++;
	}
	return -1;
}

void txt_fax( char *filename )
{
	FILE *fp;
	char buf[MAX_BUF];
	
	if((fp = fopen( filename,"r" ))==NULL) return;
	while( !feof(fp) ) {
		fgets(buf,MAX_BUF,fp);
		(*fxout->txt_out)( buf ); /* Zeile ausgeben */
		(*fxout->lf)( );		  /* und den Zeilenvorschub nicht vergessen */
		if( fxout->txt_line == fxout->tot_txtlines ) { /* Seitenende erreicht */
			(*fxout->page_break)();
		}
	}
	fclose( fp );
}


int main( int argc, char **argv )
{
	if( init_fxout( ) ) return 1;

	(*fxout->init_app)(1,0,0,0);
		
	while( --argc ) {
		argv++;
		txt_fax( *argv );
	}
	(*fxout->ff)();
	(*fxout->exit_app)();
	return 0;
}
