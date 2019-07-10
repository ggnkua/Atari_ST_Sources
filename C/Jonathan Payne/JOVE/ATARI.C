/***************************************************************************
 * This program is Copyright (C) 1986, 1987, 1988 by Jonathan Payne.  JOVE *
 * is provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is    *
 * included in all the files.                                              *
 ***************************************************************************/

#ifdef ATARI
#include "jove.h"
#include "io.h"
#include "termcap.h"
#include <vt52.h>
#include <osbind.h>
#include <string.h>
char	UP[] ="";	/* Scroll reverse, or up */
char	CS[] ="";	/* If on vt100 */
char	SO[] ="";	/* Start standout */
char	SE[] ="";	/* End standout */
char	CM[] ="";	/* The cursor motion string */
char	CL[] ="";	/* Clear screen */
char	CE[] ="";	/* Clear to end of line */
char	HO[] ="";	/* Home cursor */
char	AL[] ="";	/* Addline (insert line) */
char	DL[] ="";	/* Delete line */
char	VS[] ="";	/* Visual start */
char	VE[] ="";	/* Visual end */
char	KS[] ="";	/* Keypad mode start */
char	KE[] ="";	/* Keypad mode end */
char	TI[] ="";	/* Cursor addressing start */
char	TE[] ="";	/* Cursor addressing end */
char	IC[] ="";	/* Insert char */
char	DC[] ="";	/* Delete char */
char	IM[] ="";	/* Insert mode */
char	EI[] ="";	/* End insert mode */
char	LL[] ="";	/* Last line; first column */
char	M_IC[] ="";	/* Insert char with arg */
char	M_DC[] ="";	/* Delete char with arg */
char	M_AL[] ="";	/* Insert line with arg */
char	M_DL[] ="";	/* Delete line with arg */
char	SF[] ="";	/* Scroll forward */
char	SR[] ="";	/* Scroll reverse */
char	SP[] ="";	/* Send cursor position */
char	VB[] ="";	/* visible bell */
char	BL[] ="\007";	/* audible bell */
char	IP[] ="";	/* insert pad after character inserted */
char	lPC[]="";
char	NL[] ="";	/* newline character (usually \n) */


int	LI = 25;		/* number of lines */
int	ILI= 23;		/* number of internal lines */
int	CO=80;		/* number of columns */

int	UL= FALSE;		/* underscores don't replace chars already on screen */
int	MI= FALSE;	/* okay to move while in insert mode */
int	SG= 0;		/* number of magic cookies left by SO and SE */

int	TABS = FALSE;		/* whether we are in tabs mode */
int	UPlen= 0;		/* length of the UP string */
int	HOlen= 0;		/* length of Home string */
int	LLlen= 0;		/* length of lower string */


char	PC;
char	*BC='\010';		/* back space */

short	ospeed;

int	phystab	= 8;
long _stksize = 20000L;
void ResetTerm(){}

void UnsetTerm(s)
char *s;
{
}

void _splitpath(source,drive,dir,file,extention)
char 	*source,
	*drive,
	*dir,
	*file,
	*extention;
	{
	char *i,*TempDir;
	TempDir=dir;
	if (source[1] == ':')
		{
		*drive++ = *source++;
		*drive++ = ':';
		++source;
		}
	*drive = '\0';
	if ((i=rindex(source,'/'))==NULL)	/* no path */
		{
		*dir == '\0';
		}
	else					/* path	*/
		{
		while (source <= i)
			*dir++ = *source++;
		*dir = '\0';
		}
	i = source;
	if ((i= rindex(source,'.')) == NULL)
		{
		strcpy(file,source);
		*extention= '\0';
		}
	else
		{
		while (source != i)
			*file++ = *source++;
		*file= '\0';
		strcpy(extention, i);
		}
		
	}

char *getcwd(dir,size)
char 	*dir;
int	size;
	{
	int drv;
	char *pp = dir;
	if (dir == NULL)
		dir = malloc(size + 1);
	pp = dir;
	*dir++ = (drv = Dgetdrv())+'a'; 
	*dir++ = ':';
	Dgetpath(dir, drv+1);
	strcat(pp,"/");
	return (pp);
	}
	
char *strlwr(p)
char *p;
	{
	char *pp = p;
	while(*p)
		{
		if ((*p >= 'A') && (*p <= 'Z'))
			*p = *p + 'a' - 'A' ;
		p++;
		}
	return(pp);
	}

char *AtariPath(p)
char *p;
	{
	char *pp = p;
	while(*p)
		{
		if (*p == '/')
			*p = '\\';
		p++;
		}
	return(pp);
	}

void _makepath(dest, drive, path, file, extention)
char 	*dest,
	*drive,
	*path,
	*file,
	*extention;
	{
	*dest='\0';
	if (*drive != '\0');
		{
		strcat(dest,drive);
		if (drive[1] != ':')
			strcat(dest,":");
		}
	strcat(dest,path);
	if ( (path[strlen(path)-1] != '/') && (path[strlen(path)-1] != '\\') )
		strcat(dest,"/");
	strcat(dest,file);
	if( *extention != '\0')
		{
		if (*extention !='.')
			{
			strcat(dest,".");
			strcat(dest,extention);
			}
		else
			strcat(dest,extention);
		}
	}

int dummy(){}

int (*signal(sig,func))()
int sig;
int (*func)();
{
	return(&dummy);
}
dorecover() {}

/* Routines that are needed */
void bzero(f,count)
register char *f;
register int count;
	{
	register int i;
	for (i=0;i<count;i++)
		f[i]='\0';
	}
/*cursor routines*/
void Placur(line,col)
int line, col;
{
	CapCol = col;
	CapLine = line;
	Pos_Cursor(col,line);
	Show_Cursor();
}

void NPlacur(line,col)
int line, col;
{	
	CapCol = col;
	CapLine = line;
	Pos_Cursor(col,line);
	Hide_Cursor();
}
void dellines(num,bottom)
int num,bottom;
{	
	int i;
	for(i=0;i<num;i++)
		Delete_Line();
}	
		
void inslines(num,bottom)
int num,bottom;
{	
	int i;
	for(i=0;i<num;i++)
		Insert_Line();
}	
		
void i_lines(top, bottom, num)
int top, bottom, num;
{
	Placur(bottom - num + 1, 0);
	dellines(num,bottom);
	Placur(top, 0);
	inslines(num,bottom);
}

void d_lines(top, bottom, num)
int top, bottom, num;
{
	Placur(top, 0);
	dellines(num,bottom);
	Placur(bottom + 1 - num, 0);
	inslines(num,bottom);
}


void clr_page()
{
	Clear_Home();
}

void clr_eoln()
{
	Clear_Eol();
}

void SO_on()
{
	Inverse_On();
}

void SO_off()
{
	Inverse_Off();
}
void InitCM()
{
}
int res;
void StInit()
	{
	res = Getrez();
	if(res == 2  || res == 1) /* High or medium */
		return;
	Setscreen(-1L,-1L,1);
	}
void StShutDown()
	{
	if (res == 0)
	Setscreen(-1L,-1L,0);
	}
#endif ATARI
