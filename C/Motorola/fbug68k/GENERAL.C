#include"userdef.h"

/* ***************************************************** */

insertbr()
{
register int i;
extern struct breakelem brtable[];

	for (i = 0; i < MAXBR; i++)
	{
		brtable[i].tempcount = brtable[i].count;
		if (brtable[i].count >= 0)
		{
			brtable[i].inst1 = get16(brtable[i].address);
			put16(brtable[i].address, BRTRAP);
		}
	}
}

/* ***************************************************** */

whitesp(ch) /* see if ch is a whitespace character */
char ch;
{
	if (ch == ' ' || ch == '\t' || ch == '\n' || ch == ENDSTR)
		return(TRUE);
	else
		return(FALSE);
}

/* ***************************************************** */

shiftarg(str,num) /* shift the string str, num characters to the left */
char *str;
int num;
{
register int i;

	for (i=0;str[i] != ENDSTR;i++)
		str[i] = str[i+num];
}

/* ***************************************************** */

striparg(str) /* strip characters from front of string until nonwhitespace */
char *str;
{
register int j ;
	for ( j = 0;!whitesp(str[j]); j++)
		;
	while(whitesp(str[j]))
		 j++;
	shiftarg(str, j);
}

/* ***************************************************** */
/*
getnum routine converts an expression into number.
It will continue to add and subtract until it reaches a special charachter or
an error. If an error is found, a global flag, error, is set to TRUE. If no
error is found, then the global flag error is set to FALSE. 
The numbers in the expressiong string are converted according to DEFAULTSCALE,
unless overridden by a delimiter in the string.
*/
/* ***************************************************** */

getnum(str,err,iscale)
char *str;
char err[];
int iscale;
{
extern int error;		/* global error flag */
extern struct symbelem symb[];	/* symbol table */
register int scale;		/* scale to convert numbers */
register int final;		/* final sum of the expression */
register int num;		/* temporary number holder */
register int sign;		/* plus or minus */
register int i,j;		/* loop counters */;

	scale = iscale;
	num = 0;
	sign = 1;
	final = 0;
	while (!whitesp(str[0]))
	{
		switch (str[0])
		{
			case '[':
			case ']':
			case '<':
			case '>':
			case '{':
			case '}':
			case '(':
			case ')':
			case COUNTDEL:
			case ADDRDEL:
				final = final + sign * num;
				error = FALSE;
				return(final);
			case BINDEL:
				scale = 2;
				num = 0;
				break;
			case OCTDEL:
				scale = 8;
				num = 0;
				break;
			case DECDEL:
				scale = 10;
				num = 0;
				break;
			case HEXDEL:
				scale = 16;
				num = 0;
				break;
			case PLUSDEL:
				final = final + sign * num;
				num = 0;
				sign = 1;
				scale = iscale;
				break;
			case MINUSDEL:
				final = final + sign * num;
				num = 0;
				sign = -1;
				scale = iscale;
				break;
			case SYMBOLDEL:
				for (i = 0; i < MAXSYMBOL;i++)
				{
					for (j=0; j < MAXSYMBLEN; j++)
						if (whitesp(symb[i].name[j]) || symb[i].name[j] != str[j])
							break;
					if (whitesp(symb[i].name[j]))
					{
						final = final + sign * symb[i].value;
						num = 0;
						sign = 1;
						scale = iscale;
						shiftarg(str,--j);
						break;
					}
					if (i == MAXSYMBOL)
					{
						error = TRUE;
						print(err);
						return(-1);
					}
				}
				break;
			case '0':
			case '1':
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				num = num * scale + str[0] - '0';
				break;
			case 'a':
			case 'b':
			case 'c':
			case 'd':
			case 'e':
			case 'f':
				num = num * scale + str[0] - 'a' + 10;
				break;
			case 'A':
			case 'B':
			case 'C':
			case 'D':
			case 'E':
			case 'F':
				num = num * scale + str[0] - 'A' + 10;
				break;	
			default:
				error = TRUE;
				print(err);
				return(-1);
		}
		shiftarg(str,1);
	}
	final = final + sign * num;
	stripwhite(str);
	error = FALSE;
	return(final);
}

/* ***************************************************** */
/* 
getsize returns the byte equivalent from the <size> option.
It returns BYTE for -b, WORD for -w, HALF for -h, LONG for -l and DFSIZE if
no option was expressed.
*/
/* ***************************************************** */

getsize(str,err) /* get option size from command line */
char *str;	/* string with possible option on it */
char err[];	/* error message to print if error */
{

	if (str[0] == OPTDEL)
	{
		switch (str[1])
		{
			case 'w':
			case 'W':
				striparg(str);
				return(WORD);
			case 'B':
			case 'b':
				striparg(str);
				return(BYTE);
			case 'L':
			case 'l':
				striparg(str);
				return(LONG);
			case 'H':
			case 'h':
				striparg(str);
				return(HALF);
			default:
				print(err);
				return(-1);
		}
	}
	else
		return(DFSIZE);
}

/* ***************************************************** */
/* 
this returns the number of "size" large units in the memory area described
by <range>. If <range> is two addresses, then the memory is divided into
"size" large units. If <range> is a count, then the count is the number
following the COUNTDEL. 
*/
/* ***************************************************** */

getcount(str,size,strt,err)
char *str;	/* string with <range> on it */
int size;	/* 1,2 or 4; the number of bytes from <size> */
int strt;	/* starting address */
char err[];	/* error message to print if in error */
{
register int gansw;

	switch (str[0])
	{
		case COUNTDEL:
			shiftarg(str,1);
			gansw = getnum(str,err,COUNTSCALE);
			return(gansw);
		case ADDRDEL:
			shiftarg(str,1);
			gansw =(getnum(str,err,DEFAULTSCALE) - strt + 1) / size;
			return(gansw);
		default:	
			print(err);
			return(-1);
	}
}

/* ***************************************************** */

stripwhite(str)
char *str;
{
	while (str[0] == ' ' || str[0] == '\t' || str[0] == '\n')
		shiftarg(str,1);
}

/* ***************************************************** */

check()
{
register char ch1;
	ch1 = 0; /* get8(TERMINAL); */
	if (ch1 == STOPCHAR)
		return(TRUE);
	else if (ch1 == HALTCHAR)
		while (ch1 != CONTCHAR)
			if (ch1 == STOPCHAR)
				return(TRUE);
			else
				ch1 = get8(TERMINAL); 
	return(FALSE);
}

/* ***************************************************** */
	

findport(str,err)
char *str;
char *err;
{
register int i,j;
extern struct port_element p[];

	for(i=0;p[i].name != LASTCMD;i++)
	{
		for (j=0;p[i].name[j] != ENDCMD && p[i].name[j] == str[j];j++)
				;
		if (p[i].name[j] == ENDCMD && whitesp(str[j]))
			return(i);
	}
	print(err);
	return(-1);
}

/* ***************************************************** */

#if(DEVICE==68040 || COPROCESSOR==TRUE)

printfpu()
{
extern struct regelem mpu[];
register int i,j;

	for (i = 0;mpu[i].name[0] != 'F' && mpu[i].name[1] != 'P';i++)
		;

	print("\n");
	for (;mpu[i].name != LASTCMD;i++)
	{
		if (mpu[i].name[0] == BREAK)
			print("\n");
		else if (mpu[i].name[2] >= '0' && mpu[i].name[2] <= '7')
		{
			if (mpu[i].name[2] == '0')
				print("\n");
			print(mpu[i].name);
			print("=%c%8x%8x%8x   ",HEXDEL,mpu[i].value,mpu[i+1].value,mpu[i+2].value);
			printFPx(i);
			i++;
			i++;
			j = 0;
			print("\n");
		}
		else
		{
			print(mpu[i].name);
			print("=%c%8x   ",HEXDEL,mpu[i].value);
			j++;
		}
		check();
	}
	print("\n");
}

/* ************************************************************************* */
/* ROUTINE: printFPx							     */
/* ************************************************************************* */

printFPx(mpu_entry)
int mpu_entry;
{

extern struct regelem mpu[];
int f0_fp,f1_fp,f2_fp;

	f0_fp=mpu[mpu_entry].value;
	f1_fp=mpu[mpu_entry+1].value;
	f2_fp=mpu[mpu_entry+2].value;
	print("     ");
	if(bitnum(31,31,f0_fp))
		print("-");
	print("%d_%8x%8x_E%d",bitnum(31,31,f1_fp),(bitnum(30,0,f1_fp)<<1),bitnum(31,0,f2_fp),bitnum(30,16,f0_fp)-16383);
}

#endif

/* ***************************************************** */

printreg(reg)
struct regelem reg[];
{
register int i,j;

	j = 0;
	for (i = 0;reg[i].name != LASTCMD && reg[i].name[0] != 'F';i++)
	{
		if (reg[i].name[0] == BREAK)
		{
			j = 0;
			print("\n");
		}
#if(DEVICE<68020)/* ie. 68010 */
		else if(i==4 || i==7 || i==8)
			;
#endif
#if(DEVICE<68010)/* ie. 68000,68008 */
		else if(i==6 || i==9 || i==10)
			;
#endif
#if(DEVICE>=68030)
		else if(reg[i].name[1] == 'R' && reg[i].name[2]!=' ')
		{
			print(reg[i].name);
			print("=%c%8x%8x    ",HEXDEL,reg[i].value,reg[i+1].value);
			i++;
			j++;
		}
		else if((reg[i].name[0] == 'S' && reg[i].name[1]=='R') ||
			(reg[i].name[1] == 'S' && reg[i].name[2]=='R')) 
		{
			print(reg[i].name);
			print("=%c%4x   ",HEXDEL,reg[i].value);
			j++;
		}
#endif
		else
		{
			print(reg[i].name);
			print("=%c%8x   ",HEXDEL,reg[i].value);
			j++;
		}
		if (j == REGPERLINE)
		{
			j = 0;
			print("\n");
		}
		else if (i != 0 && (i % REGPERSCREEN) == 0)
		{
			j = 0;
			print("\n");
		}
		check();
	}
	print("\n");
}

/* **************************************************** */

findreg(reg,strng,query,argv)
char *strng;
struct regelem reg[];
int query;
char *argv;
{
register int i,j;
extern int error;
#if(DEVICE>=68030 || COPROCESSOR==TRUE)
int k,l;
char upper[9];
#endif

	for (i = 0;reg[i].name != LASTCMD;i++)
	{
		for (j = 0;reg[i].name[j] != ENDCMD && ((CONVCAP && reg[i].name[j] == strng[j] - 0x20) || reg[i].name[j] == strng[j]);j++)
			;
		if (reg[i].name[j] == ENDCMD && (strng[j]==ENDSTR && !query) || (query && strng[j]== ENDCMD))
			break;
	}
	if (reg[i].name == LASTCMD)
	{
		print("ERROR 17:Invalid Register\n");
		return(0);
	}
	striparg(strng);
#if(DEVICE<68020)/* ie. 68010 */
		if(i==4 || i==7 || i==8)
			{
				print("ERROR 12:Unimplemented Register\n");
				return(0);
			}
#endif
#if(DEVICE<68010)/* ie. 68000,68008 */
		if(i==6 || i==9 || i==10)
			{
				print("ERROR 12:Unimplemented Register\n");
				return(0);
			}
#endif
	if(!query)
		print(reg[i].name);
#if(DEVICE>=68030)
	if(reg[i].name[1] == 'R' && reg[i].name[2] != ' ')
		/* set up to fill the register up with
		   the existing routines */
	{
		if(!query)
			print("=%c%8x%8x New value? ",HEXDEL,reg[i].value,reg[i+1].value);
		if(query)
			strng = argv;
		else if(getline(strng) != 1)
		{
			print(ERR01);
			return;
		}
		stripwhite(strng);
		if(strng[0]=='&' || strng[0]=='@')
			{
			print("\nHex Base must be used\n");
			return;
			}
		else if(strng[0]==HEXDEL)
			shiftarg(strng,1);
		for(k=0;strng[k]!=ENDSTR;k++)
			;
		if(k>16)
			{
			print(ERR03);
			return;
			}
		else if(k>8)
			{
			for(l=0;l<=k-9;l++)
				upper[l]=strng[l];
			upper[l]=ENDSTR;
			reg[i].value = getnum(upper,ERR03,DEFAULTSCALE);
			if (error)
				return;
			shiftarg(strng,k-8);
			}
		else
			reg[i].value = 0;
		i++;
		reg[i].value = getnum(strng,ERR03,DEFAULTSCALE);
		return;
	}
	if((reg[i].name[0] == 'S' && reg[i].name[1] == 'R') ||
		(reg[i].name[1] == 'S' && reg[i].name[2] == 'R'))
	{
		if(!query)
			print("=%c%4x New value? ",HEXDEL,reg[i].value);
		if(query)
			strng = argv;
		else if(getline(strng) != 1)
		{
			print(ERR01);
			return(0);
		}
		reg[i].value = getnum(strng,ERR03,DEFAULTSCALE);
		return;
	}
#endif
#if(DEVICE==68040 || COPROCESSOR==TRUE)
	if(reg[i].name[1] == 'P' 
		&& reg[i].name[2] >= '0' 
		&& reg[i].name[2] <= '7')
	{
		if(!query)
			print("=%c%8x%8x%8x New value? ",HEXDEL,reg[i].value,reg[i+1].value,reg[i+2].value);
		if(query)
			strng = argv;
		else if(getline(strng) != 1)
		{
			print(ERR01);
			return;
		}
		stripwhite(strng);
		if(strng[0]=='&' || strng[0]=='@')
			{
			print("\nHex Base must be used\n");
			return;
			}
		else if(strng[0]==HEXDEL)
			shiftarg(strng,1);
		for(k=0;strng[k]!=ENDSTR;k++)
			;
		if(k>24)
			{
			print(ERR03);
			return;
			}
		if(k>16)
			{
			for(l=0;l<=k-17;l++)
				upper[l]=strng[l];
			upper[l]=ENDSTR;
			reg[i++].value = getnum(upper,ERR03,DEFAULTSCALE);
			if (error)
				return;
			shiftarg(strng,k-16);
			k = k-8;
			}
		else
			reg[i++].value = 0;
		if(k>8)
			{
			for(l=0;l<=k-9;l++)
				upper[l]=strng[l];
			upper[l]=ENDSTR;
			reg[i++].value = getnum(upper,ERR03,DEFAULTSCALE);
			if (error)
				return;
			shiftarg(strng,k-8);
			k = k-8;
			}
		else
			reg[i++].value = 0;
		reg[i].value = getnum(strng,ERR03,DEFAULTSCALE);
		return;
	}
#endif
	if(!query)
		print("=%c%8x New value? ",HEXDEL,reg[i].value);
	if(query)
		strng = argv;
	else if(getline(strng) != 1)
	{
		print(ERR01);
		return(0);
	}
	reg[i].value = getnum(strng,ERR03,DEFAULTSCALE);
}

/* ****************************************************** */

