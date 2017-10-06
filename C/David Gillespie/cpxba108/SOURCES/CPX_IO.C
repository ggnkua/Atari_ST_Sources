#include <stdarg.h>
#include <ctype.h>
#include <ext.h>
#include <stdio.h>

#include "p2c.h"
#include "glo.h"

/********************************************************************/
#if TRUE!=1
#undef TRUE
#define TRUE 1
#endif

#if FALSE!=0
#undef FALSE
#define FALSE 0
#endif

#define POSITION_CURSOR			2
#define SET_FOREGROUND_COLOR	3
#define SET_BACKGROUND_COLOR	4

/********************************************************************/
LOCAL	VOID	OutChar( WORD ch );

/********************************************************************/
LOCAL	BYTE	buf[512];
GLOBAL	WORD	cx, cy, cm, esc, chc;
GLOBAL	WORD	ocx, ocy,discard;
GLOBAL  int interactive;
extern char rev_mode;
extern void	cls(void),clline(int line);
extern void cllines(int von,int bis),delxy(int line,int von,int bis);
extern void ScrollUpR(int line),ScrollDownR(int line);
/********************************************************************/

GLOBAL BYTE *FGets(FILE *fp, BYTE *string)
{
	WORD off=0, key;
	char *s;
	*string=0;
	if(fp==stdin)
	{
		interactive=1;
		woff=roff; /* Tastaturpuffer leeren */
		while(1)
		{
			while(roff==woff)
			{
				WaitBASIC();
				if(ctrl) return 0; /* CTRL-C */
			}
	
			key=KeyBuffer[roff++];
			if(roff>=KB_SIZE)
				roff=0;
	
			switch(key)
			{
			case 0:
				break;
			case 8:
			case 127:
				if(off>0)
				{
					OutChar(8);
					string[--off]=0;
				}
				break;
	
			case 13:
				OutChar(10);
				OutChar(13);
				interactive=0;
				return string;
	
			default:
				if(off<255)
				{
					string[off++]=key;
					string[off	]=0;
				}
				OutChar(key);
				break;
			}
		}
	}
	if((s=fgets(string,255,fp))!=NULL)
	{
		while(*s&&*s!='\r'&&*s!='\n') s++;
		*s=0;
	}
	else
	{
		fileerror=1;
	}
	return string;
}

GLOBAL BYTE *Gets( BYTE *string)
{
	return FGets(stdin,string);
}

GLOBAL VOID Putchar( WORD ch )
{
	void Bconout (int dev, int c);
	if( ch==10 )
	{
		OutChar( 10 );
		OutChar( 13 );
	}
	else if(ch=='\a')
	{
		Bconout(2,'\a');
	}
	else
	{
		OutChar( ch );
	}
}

GLOBAL WORD VFPRINTF(FILE *fp, BYTE *string, va_list arg )
{
	vsprintf(buf, string, arg);
	FPUTS(buf,fp);
	return (int)strlen(buf);
}

GLOBAL WORD Printf( BYTE *string, ... )
{
	int r;
    va_list arg;
    va_start(arg, string);
	r=VFPRINTF(stdout, string, arg);
    va_end(arg);
    return r;
}

GLOBAL WORD FPRINTF( FILE *f, char *string, ...)
{
    int     r;
    va_list arg;

    va_start(arg, string);
    r=VFPRINTF(f,string,arg);
    va_end(arg);
    return r;
}

GLOBAL WORD PUTC(WORD ch, FILE *f)
{
	int r;
    if(f==stdout)
    {
        Putchar(ch);
        return ch;
    }
    else
    {
    	r=putc(ch,f);
    	if(r<0) fileerror=1;
        return r;
    }
}

GLOBAL WORD FPUTS(char *string, FILE *f)
{
	while(*string) PUTC(*string++,f);
    return *(string-1);
}

LOCAL VOID OutChar( WORD ch )
{
	if(!cm)			/* Cursor muá gel”scht werden ...		*/
		DrawCursor(cx, cy);

	if(esc)
	{
		if(esc!=TRUE)
		{
			switch(esc)
			{
			case POSITION_CURSOR:
				chc++;
				if(chc==1)
				{
					cx=ch-32;
					if(cx<0)			cx=0;
					if(cx>=MAX_CX)		cx=MAX_CX-1;
				}
				else
					if(chc==2)
					{
						cy=ch-32;
						if(cy<0)			cy=0;
						if(cy>=MAX_CY)		cy=MAX_CX-1;
						esc=FALSE;
					}
				break;

			case SET_FOREGROUND_COLOR:
			case SET_BACKGROUND_COLOR:
			default:
				esc=FALSE;
				break;
			}
		}
		else
		{
			esc=FALSE;
			switch(ch)
			{
			case 'A':	/*	Cursor up					*/
				if(cy>0) cy--;
				break;

			case 'B':	/*	Cursor down					*/
				if(cy<(MAX_CY-1))
					cy++;
				break;

			case 'C':	/*	Cursor forward				*/
				if(cx<(MAX_CX-1))
					cx++;
				break;

			case 'D':	/*	Cursor backward				*/
				if(cx>0)
					cx--;
				break;

			case 'E':	/*	Clear screen				*/
				cx=cy=0;
				cls();
				break;

			case 'H':	/*	Home cursor					*/
				cx=cy=0;
				break;

			case 'I':	/*	Reverse index				*/
				if(cy>0)
					cy--;
				else
					ScrollDown();
				break;

			case 'J':	/*	Erase to end of page		*/
				cllines(cy+1,MAX_CY-1);
			case 'K':	/*	Clear to end of line		*/
				delxy(cy,cx,MAX_CX-1);
				break;
			case 'L':	/*	Insert Line					*/
				ScrollDownR(cy);
				cx=0;
				break;
			case 'M':	/*	Delete Line					*/
				ScrollUpR(cy);
				cx=0;
				break;

			case 'Y':	/*	Position cursor				*/
				esc=POSITION_CURSOR;
				chc=0;
				break;

			case 'b':	/*	Set foreground color		*/
				esc=SET_FOREGROUND_COLOR;
				chc=0;
				break;

			case 'c':	/*	Set background color		*/
				esc=SET_BACKGROUND_COLOR;
				chc=0;
				break;

			case 'd':	/*	Erase beginning of display	*/
				cllines(0,cy-1);
			case 'o':	/*	Erase beginning of line		*/
				delxy(cy,0,cx-1);
				break;

			case 'e':	/*	Enable cursor				*/
				cm=FALSE;
				break;

			case 'f':	/*	Disable cursor				*/
				cm=TRUE;
				break;

			case 'j':	/*	Save cursor position		*/
				ocx=cx;
				ocy=cy;
				break;

			case 'k':	/*	Restore cursor position		*/
				cx=ocx;
				cy=ocy;
				break;

			case 'l':	/*	Erase entire line			*/
				cx=0;
				clline(cy);
				break;

			case 'p':	/*	Enter reverse video mode	*/
				rev_mode=-1;
				break;
			case 'q':	/*	Exit reverse video mode		*/
				rev_mode=0;
				break;
			case 'v':	/*	Wrap at end of line			*/
				discard=0;
				break;
			case 'w':	/*	Discard at end of line		*/
				discard=1;
				break;

			default:
				break;
			}
		}
	}
	else if(iscntrl(ch))
	{
		switch(ch)
		{
		case 7:
			Bconout(2,ch);
			break;
		case 8:
		case 127:
			if(cx>0)
			{
				cx--;
				PutChar(cx,cy,' ');
			}
			break;

		case 9:
			cx+=8;
			cx/=8;
			cx*=8;
			if(cx>=MAX_CX)
				cx=MAX_CX-1;
			break;

		case 10:
			if((++cy)>=MAX_CY)
			{
				cy=MAX_CY-1;
				ScrollUp();
			}
			break;

		case 12:
			cls();
			cx=cy=0;
			break;

		case 13:
			cx=0;
			break;

		case 27:
			esc=TRUE;
			break;
		}
	}
	else
	{
		PutChar(cx++,cy,ch);
	}

	if(cx>=MAX_CX)
	{
		cx=MAX_CY-1;
		if(!discard)
		{
			cx=0;
			cy++;
		}
	}
	if(cy>=MAX_CY)
	{
		cy=MAX_CY-1;
		ScrollUp();
	}
	if(!cm)			/* Cursor neu Zeichnen ...			*/
		DrawCursor(cx, cy);
}

void fourfold(int x0,int y0,int x,int y)
{
	plotpoint(x0+x,y0+y);
	plotpoint(x0-y,y0+x);
	plotpoint(x0-x,y0-y);
	plotpoint(x0+y,y0-x);
}

void eightfold(int x0,int y0,int x,int y)
{
	fourfold(x0,y0,x,y);
	fourfold(x0,y0,x,-y);
}

void circle(int x0,int y0,int r)
{
	int x,y,q;
	x=0;
	y=q=r;
	do
	{
		eightfold(x0,y0,x,y);
		q-=x+x+1;
		x++;
		if(q<0)
		{
			y--;
			q+=y+y;
		}
	}
	while(x<=y);
}
