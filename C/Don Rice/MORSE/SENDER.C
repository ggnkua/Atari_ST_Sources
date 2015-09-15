#include <stdio.h>
#include <gemlib.h>
#include <sender.h>
#include <morse.c>
#include <sendgem.c>

#define RSRC_FILENAME	"SENDER.RSC"
#define MAX_DEPTH	10
#define BLANKLINE	-1
#define MORSE_CHARS	"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.,?-/"

char	buf[132];
short	skipblank = TRUE, filter = TRUE, cspeed, sspeed, csspeed, tbox[4];

main()
{
	short done, item;

	gem_init();
	clear_window( ywork );
	dirspec[0] = '\0';
	item = (wwork - gl_wchar*40)/2;
	if( item < 0 ) terminate( "[3][Insufficient screen resolution!][Abort]" );
	tbox[0] = xwork+item;
	tbox[2] = xwork+wwork-item;
	item = (hwork - gl_hchar*7)/2;
	tbox[1] = ywork+item;
	tbox[3] = ywork+hwork-item;

	if( !rsrc_load( RSRC_FILENAME ) )
		terminate( no_rsc_file );
	if( rsrc_gaddr( 0, 0, &resrcs ) == 0 )
		terminate( bad_rsc_file );
	rsrc_gaddr( R_TREE, TREE1, &resrcs );

	done = FALSE;
	while( !done )
	{
		form_center( resrcs, &xobj, &yobj, &wobj, &hobj );
		form_dial( 0, xobj, yobj, wobj, hobj );
		form_dial( 1, 1, 1, 1, 1, xobj, yobj, wobj, hobj );

		graf_mouse( ARROW, 0x0L );
		objc_draw( resrcs, 0, MAX_DEPTH, 0, 0, wdesk, hdesk );

		if( filter ) select( T1FILTER );
		item = form_do( resrcs, TREE1 );
		if( item == T1EXIT ) done = TRUE;
		else
		{
			form_dial( 2, 1, 1, 1, 1, xobj, yobj, wobj, hobj );
			form_dial( 3, xobj, yobj, wobj, hobj );
			deselect( T1SEND );
			clear_window( ywork );

			analyze_form( resrcs );
			send_file();
		}
	}
	rsrc_free();
	terminate( NULL );
}	/* main */

adjust_speed()
{
	short element;

	if( csspeed < 1 ) return( FALSE );
	sspeed += csspeed;
	if( sspeed > cspeed ) sspeed = cspeed;
	element = 1200/sspeed;
	l_char = element<<1;
	l_word = element<<2;
}	/* adjust_speed */

analyze_form( tree )
long tree;
{
	short element;

	/* Check speed settings */
	cspeed = atoi( (char *) (*TE_PTEXT( (*OB_SPEC( T1CSPEED )) )) );
	if( cspeed < 5 ) cspeed = 5;
	l_dot = l_el = 1200/cspeed;
	l_dash = 3*l_dot;
	sspeed = atoi( (char *) (*TE_PTEXT( (*OB_SPEC( T1SSPEED )) )) );
	if( sspeed < 1 ) sspeed = 1;
	element = 1200/sspeed;
	l_char = element<<1;
	l_word = element<<2;
	csspeed = atoi( (char *) (*TE_PTEXT( (*OB_SPEC( T1CSSPD )) )) );

	/* Check file filter option */
	if( (*OB_STATE( T1FILTER )) & SELECTED ) filter = TRUE;
	else filter = FALSE;
}	/* analyze_form */

fetch( str, in )
char *str;
FILE *in;
{
	short i, j, skipspace;

	while( fgets( buf, 132, in ) != NULL )
	{
		skipspace = TRUE;
		for( i=j=0; i<strlen( buf ); i++ )
			if( !filter ) str[j++] = buf[i];
			else if( isspace( buf[i] ) && !skipspace )
			{
				str[j++] = ' ';
				skipspace = TRUE;
			}
			else if( strchr( MORSE_CHARS, toupper(buf[i]) ) != NULL )
			{
				str[j++] = buf[i];
				skipspace = FALSE;
			}
		str[j] = '\0';
		while( --j >= 0 )
			if( str[j] == ' ' ) str[j] = '\0';
			else break;
		if( j < 0 )
			if( skipblank ) continue;
			else
			{
				skipblank = TRUE;
				return( BLANKLINE );
			}
		skipblank = FALSE;
		strcat( str, " " );	/* Treat \n as space */
		return( TRUE );
	}
	return( FALSE );
}	/* fetch */

print_info()
{
	char text[128];

	textbox( tbox );
	graf_mouse( M_OFF, 0x0L );
	wputs( "Morse Code Sender" );
	ypos += gl_hchar;
	sprintf( text, "Sending: %s", infile );
	wputs( text );
	sprintf( text, "Speed:   %2d WPM", cspeed );
	wputs( text );
	if( sspeed != cspeed )
	{
		sprintf( text, "Spacing: %2d WPM", sspeed );
		wputs( text );
	}
	wputs( "Press any key to interrupt sending." );
	graf_mouse( M_ON, 0x0L );
}	/* print_info */

send_file()
{
	char text[128];
	FILE *in;
	short ans, stat, i, send_morse();

	if( !getfspec( dirspec, infile, "\\*.*" ) ) return( FALSE );

	if( (in = fopen( infile, "r" )) == NULL )
	{
		sprintf( text, "[2][Unable to open input file %s][Try again]",
		  infile );
		form_alert( 1, text );
		return( FALSE );
	}

	graf_mouse( BUSYBEE, 0x0L );
	print_info();

	stat = TRUE;
	while( stat != FALSE )
	{
		stat = fetch( text, in );
		if( stat == FALSE )
			if( filter ) strcpy( text, "[SK]" );
			else continue;
		if( stat == BLANKLINE )
		{
			if( filter ) strcpy( text, "[AR]  " );
			else strcpy( text, "  " );
			ans = sspeed;
			if( sspeed < cspeed ) adjust_speed();
			if( ans != sspeed ) print_info();
		}
		i = send_morse( text );
		if( ev_mkreturn != 0 )
		{
			graf_mouse( ARROW, 0x0L );
			ans = form_alert( 1, "[1][Code practice interrupted!][Continue|Stop]" );
			if( ans == 2 )
			{
				fclose( in );
				return( FALSE );
			}
			else
			{
				graf_mouse( BUSYBEE, 0x0L );
				if( i > 5 ) i -= 5;
				else i = 0;
				send_morse( &text[i] );
			}
			ev_mkreturn = 0;
		}
	}
	fclose( in );
	graf_mouse( ARROW, 0x0L );
	return( TRUE );
}	/* send_file */
