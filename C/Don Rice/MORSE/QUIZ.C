#include <stdio.h>
#include <gemlib.h>
#include <morse.c>
#include <sendgem.c>

short ytext[4], yprompt[4];

main()
{
	short i, done, speed, score;
	char text[132];

	gem_init();
	clear_window( ywork );

	/* Define box for explanatory text */
	i = (wwork - 40*gl_wchar)/2;
	if( i < 0 )
		terminate( "[3][Insufficient screen resolution!][Abort]" );
	ytext[0] = xwork+i;
	ytext[2] = xwork+wwork-i;
	ytext[1] = ywork+gl_hchar;
	ytext[3] = ytext[1] + (gl_hchar<<3) + gl_hchar;

	/* Define box for prompts and messages */
	yprompt[0] = ytext[0];
	yprompt[2] = ytext[2];
	yprompt[1] = ytext[3] + (gl_hchar<<2);
	yprompt[3] = yprompt[1] + (gl_hchar<<2);

	i = form_alert( 1, "[1][What level are you practicing for?][Novice|General|Extra]" );
	if( i == 1 ) speed = 7;
	else if( i == 2 ) speed = 15;
	else if( i == 3 ) speed = 25;

	done = FALSE;
	while( !done )
	{
		score = code_quiz( speed );
		graf_mouse( M_ON, 0x0L );
		graf_mouse( ARROW, 0x0L );
		sprintf( text, "[3][Quiz completed!|Your score: %d%%][Repeat|Quit]", score );
		if( form_alert( 2, text ) == 2 )
			done = TRUE;
	}

	terminate( NULL );
}	/* main */

code_quiz( speed )	/* Perform code quiz */
short speed;
{
	char qstr[44], codech[2], ans, get_answer();
	short lastch, guessflag, nw, nr;
	long i;

	clear_window( ywork );
	graf_mouse( M_OFF, 0x0L );

	/* Set timing values */
	l_dot = l_el = 1200/speed;
	l_dash = l_char = l_dot*3;
	l_word = l_dot*7;

	/* Initialize test string */
	strcpy( qstr, "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.,?+*=/" );
	lastch = 42;
	codech[1] = '\0';

	/* Write messages */
	textbox( ytext );
	wputs( "Type the character that you hear." );
	wputs( "Special codes:" );
	wputs( "   + is AR (end of message)" );
	wputs( "   * is SK (end of work)" );
	wputs( "   = is BT" );
	wputs( "The test covers 0-9, A-Z, AR, SK, BT," );
	wputs( "?, /, period, and comma." );
	wputs( "Press UNDO to interrupt the quiz." );
	m_wait( 2000 );

	nw = nr = 0;
	while( lastch >= 0 )
	{
		guessflag = 0;
		textbox( yprompt );
		wputs( "Identify this one." );
		i = Random() % (lastch+1);
		codech[0] = qstr[i];
		while( guessflag >= 0 )
		{
			ev_mkreturn = 0;
			send_morse( codech );
			ans = toupper( get_answer() );
			if( ans == 0 )	/* assume UNDO, quit */
				return( nr ? (nr*100)/(nr+nw) : 0 );
			textbox( yprompt );
			if( ans != codech[0] )
			{
				nw++;
				wputs( "No, that isn't right." );
				if( ++guessflag > 2 )
				{
					wputs( "The character was:" );
					wputs( codech );
					guessflag = -1;
					m_wait( 1000 );
				}
				else wputs( "Try that one again." );
			}
			else
			{
				nr++;
				wputs( "That is correct." );
				if( guessflag == 0 )
					qstr[i] = qstr[lastch--];
				guessflag = -1;
			}
			m_wait( 2000 );
		}
	}
	return( (nr*100)/(nr+nw) );
}	/* code_quiz */

char get_answer()
{
	if( ev_mkreturn == 0 ) ev_mkreturn = evnt_keybd();
	return( (char) (ev_mkreturn & 0x0ff) );
}	/* get_answer */

