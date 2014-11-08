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
	while(*string) PUTC(*string=stdout)
    {
  rn ch;
    }
ra		{
			vfvir=ft\stringaPUTC(WORD ch, FILxr;
}

GLr(ch);
  m)=fg
		ursor mu� gel�scht werd{
r;
yBuffDraw	ursor(
GLOB******);
D	o1;
		woff
D	o!= FAL==woff)
			case 0D	o1;
break;
			ca#define SET_FOR			{
	, ose
	{
	cx=ch-320;
				 CTRx   
	cx=00;
				 CTRx>=MAX_CX)
	cx=MAX_CX-1(key);
				brch );
{
		cy=ch-320;
				* CTRy   
	cy=00;
				* CTRy>=MAX_CY)
	cy=MAX_CX-1(key);
				Oak;
			ca3
#define SET_BACKG:ak;
			ca3
#
/**************:(off<255)
				{
	csc=efine(key);
	if((s=fgets(strinrch );
{=key;
break;
			ca'A':g
		ursor upy);
				Oak;
			ca'B':g
		ursor d***y);
	{
				Oak;
			ca'C':g
		ursor forwera);
	{
				Oak;
			ca'D':g
		ursor backwera);
]cx--;ase 13:
				Oak;
			ca'E':g
		le   screen);
			line);ase 13:
				Oak;
			ca'H':g
	Home cursor	);
			:
				Oak;
			ca'I':g
	Rever		BcALSx);
{
/******e);ase 13:
				Oak;
			ca'J':g
	Er		cato  r;s;
			'K':g
		le   to  r;s;
GMAX_CXr=f; 8:
			case 127:
			'L':g
	Insert L,de
/********c
		}
	}cx=00;
					case 127:
			'M':g
	Delete L,de
/**ownRc
		}
	}cx=00;
					case 1 127:
			'Y':g
	Position cursor	);
	, o=00;
					case 1 127:
			'b':g
	Set foregroFAL color	)eyBuffe*csc=3
#define SET_BACKG;		{
	, o=00;
					case 1 127:
			'c':g
	Set backgroFAL color	)eyBuffe*csc=3
#
/**************;		{
	, o=00;
					case 1 127:
			'd':g
	Er		cabeginnfvis;
			'o':g
	Er		cabeginnfvis;
			case 1 127:
			'e':g
	Enable cursor	);
	if((s 127:
			'f':g
	Disable cursor	);
	if((s 127:
			'j':g
	Save cursor position;
	if((s 127:
			'k':g
	Restore cursor position;
	if((s 127:
			'l':g
	Er		caentire ),de
			lirn vocyf; 8:
			case 1 127:
			'p':g
	Enrofid	cer		Bvideo s(vo
			'q':g
	Exitid	cer		Bvideo s(vo
					case 127:
			'v':g
	Wrap at  r;s;
					case 127:
			'w':g
	Distera at  r;s;
			case 1 127:255)
				{
	
	if((s=fgets(string,25
		BconintnBAL0ch;1;
		wof	case 0ch;;
b		wof
					{
		
	else
	{ch;
 					case 127
				if(of>0)
				{
		 CTRxhar(8);

GLOB
Gint' ')((s=fgets(s			case 1 127
			9:ak;
	x+=8e 127:
			10	{
		 CT(++cyf>=MAX_CY)(8);
/**ow()((s=fgets(s			case 1 127
			12:ak;
	ine);ase 1cx=cy=00;
				case 1 127
			13:ak;
	x=00;
				case 1 127
						{
		csc= FAL(key);		case 127}tChar( ch );
	}
}P

GLOB
 chint
Rx>=MAX_CX)Buf		wof
 nintera==woff)
			x=00;
		cyse
	{
/**ow()((s=}ch);
  m)=fg
		ursor neu Zeichn{
r;
yBuffDraw	ursor(
GLOB****FPR**, intfourfoldf( chx0id Scy0id Scxid ScyGLr(ch)plotpod S(x0+x,y0+yf; 8:plotpod S(x0-y,y0+xf; 8:plotpod S(x0-x,y0-yf; 8:plotpod S(x0+y,y0-x****FPR**, inteightfoldf( chx0id Scy0id Scxid ScyGLr(ch)fourfoldfx0iy0ix,yf; 8:fourfoldfx0iy0ix,-B****FPR**, intcirclef( chx0id Scy0id Scr(f==stdout)x,y,q; 8:x=00;
y=q=L WO	doBuf		wofeightfoldfx0iy0ix,yf; 8:	q-=x+x+1(key)xse
	{
q<0==woff)
		y--;ase 1q+=y+y
	{