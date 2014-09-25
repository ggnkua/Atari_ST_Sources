/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 

#include "perform.h"
#pragma hdrstop
#include "creek.hh"



#ifdef atarist


char *jkitoa(long x, char *xx, int base=10, int width=16 )
{
  int wrksiz=100+width;

  if( wrksiz>256 )
  {
        *xx=0;
        return xx;
  }

  char* e = xx + wrksiz - 1;
  char* s = e;

  *--s = 0;
  char sgn = 0;

  if (x == 0)
    *--s = '0';
  else
  {
    int z;
    if (x < 0)
    {
      sgn = '-';
      z = -x;
    }
    else
      z = x;
    while (z != 0)
    {
      char ch = z % base;
      z = z / base;
      if (ch >= 10)
        ch += 'a' - 10;
      else
        ch += '0';
      *--s = ch;
    }
  }

  if (sgn) *--s = sgn;
  int w = e - s - 1;
  while (w++ < width)
    *--s = ' ';
  return xx;
}

creek::creek( short dev )
{
	device=dev;
}



void creek::put(register const char* s )
{
	if( s )
		while( *s )
			Bconout( device, *s++ );
}


void creek::put( int i )
{
	char s[32];
	jkitoa(i,s);
	put( s );
}



int creek::get( register char *s, short max_len, Boolean echo=TRUE )
{
	short pos=0;
	short ch;
	Boolean finished=FALSE;

	do
	{
		ch=Bconin(device) &0xff;
		if( ch=='\r' )
			break;
		if( ch==8 )
		{
			if( pos>0 ) pos--;
			{
				if( echo )
				{
					Bconout( device, 8 );
					Bconout( device, ' ' );
					Bconout( device, 8 );
				}
			}
			continue;
		}

		if( pos<max_len-2 )
		{
			if( echo )
				Bconout( device, ch );
			s[pos++]=ch;
		}

	} while( !finished );
	s[pos++]='\0';
	return pos;
}
/*
creek &creek::operator<<(short i)
{
	char s[16];
	put( jkitoa(i,s) );
	return *this;
}

creek &creek::operator<<(int i)
{
	put( itoa(i) );
	return *this;
}


creek& creek::operator>>(short&  n)
{
	char s[16];
	get( s, 16 );
	n= (short) strtol(s, (char **)0, 10);
}

creek& creek::operator>>(int&    n)
{
	char s[16];
	get( s, 16 );
	n= (int) strtol(s, (char **)0, 10);
}


*/



//
// creekvt52 class contains methods for vt52 cursor control.
//


creekvt52::creekvt52( short dev ) : creek(dev)
{

}

void creekvt52::goto_xy(char x,char y )
{
	put( (char)'\033' );
	put( (char)'Y' );
	put( (char)y+32 );
	put( (char)x+32 );
}


void creekvt52::cursor_up()
{
	put( (char)'\033' );
	put( (char)'A' );
}

void creekvt52::cursor_down()
{
	put( (char)'\033' );
	put( (char)'B' );
}


void creekvt52::cursor_left()
{
	put( (char)'\033' );
	put( (char)'D' );
}


void creekvt52::cursor_right()
{
	put( (char)'\033' );
	put( (char)'C' );
}


void creekvt52::cursor_home()
{
	put( (char)'\033' );
	put( (char)'H' );
}


void creekvt52::cursor_up_scroll()
{
	put( (char)'\033' );
	put( (char)'I' );
}


void creekvt52::cursor_save()
{
	put( (char)'\033' );
	put( (char)'j' );
}


void creekvt52::cursor_restore()
{
	put( (char)'\033' );
	put( (char)'k' );       
}

	
void creekvt52::clear_screen()
{
	put( (char)'\033' );
	put( (char)'E' );
}


void creekvt52::clear_eop()
{
	put( (char)'\033' );
	put( (char)'J' );               
}


void creekvt52::clear_eol()
{
	put( (char)'\033' );
	put( (char)'K' );               
}


void creekvt52::clear_top()
{
	put( (char)'\033' );
	put( (char)'d' );               
}


void creekvt52::clear_line()
{
	put( (char)'\033' );
	put( (char)'l' );               
}


void creekvt52::clear_beginning()
{
	put( (char)'\033' );
	put( (char)'o' );               
}

	
void creekvt52::insert_line()
{
	put( (char)'\033' );
	put( (char)'L' );               
}

void creekvt52::delete_line()
{
	put( (char)'\033' );
	put( (char)'M' );               
}

	
void creekvt52::reverse_on()
{
	put( (char)'\033' );
	put( (char)'p' );               
}


void creekvt52::reverse_off()
{
	put( (char)'\033' );
	put( (char)'q' );               
}

void creekvt52::cursor_on()
{
	put( (char)'\033' );
	put( (char)'e' );               
}

void creekvt52::cursor_off()
{
	put( (char)'\033' );
	put( (char)'f' );
}


void creekvt52::overflow_on()
{
	put( (char)'\033' );
	put( (char)'v' );
}

void creekvt52::overflow_off()
{
	put( (char)'\033' );
	put( (char)'w' );
}

void creekvt52::char_col( char c )
{
	put( (char)'\033' );
	put( (char)'b' );
	put( (char)c );
}


void creekvt52::back_col( char c )
{
	put( (char)'\033' );
	put( (char)'c' );
	put( (char)c );
}


#else

#ifndef _WINDOWS

creek::creek()
{
}



void creek::put(register const char* s )
{
	if( s )
		while( *s )
			putch( *s++ );
}


void creek::put( int i )
{
	char s[16];
	put( jitoa(i,s) );
}



int creek::get( register char *s, short max_len, Boolean echo )
{
	short pos=0;
	short ch;
	Boolean finished=FALSE;

	do
	{
		ch=get()&0xff;
		if( ch=='\r' )
			break;
		if( ch==8 )
		{
			if( pos>0 ) pos--;
			{
				if( echo )
				{
					putch( 8 );
					putch( ' ' );
					putch( 8 );
				}
			}
			continue;
		}

		if( pos<max_len-2 )
		{
			if( echo )
				putch( ch );
			s[pos++]=ch;
		}

	} while( !finished );
	s[pos++]='\0';
	return pos;
}

#endif
#endif

