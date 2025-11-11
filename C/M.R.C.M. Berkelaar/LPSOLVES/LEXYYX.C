# include "stdio.h"
# define U(x) x
# define NLSTATE yyprevious=YYNEWLINE
# define BEGIN yybgin = yysvec + 1 +
# define INITIAL 0
# define YYLERR yysvec
# define YYSTATE (yyestate-yysvec-1)
# define YYOPTIM 1
# define YYLMAX BUFSIZ
# define output(c) putc(c,yyout)
# define input() (((yytchar=yysptr>yysbuf?U(*--yysptr):getc(yyin))==10?(yylineno++,yytchar):yytchar)==EOF?0:yytchar)
# define unput(c) {yytchar= (c);if(yytchar=='\n')yylineno--;*yysptr++=yytchar;}
# define yymore() (yymorfg=1)
# define ECHO fprintf(yyout, "%s",yytext)
# define REJECT { nstr = yyreject(); goto yyfussy;}
int yyleng; extern char yytext[];
int yymorfg;
extern char *yysptr, yysbuf[];
int yytchar;
FILE *yyin = {stdin}, *yyout = {stdout};
extern int yylineno;
struct yysvf { 
	struct yywork *yystoff;
	struct yysvf *yyother;
	int *yystops;};
struct yysvf *yyestate;
extern struct yysvf yysvec[], *yybgin;
# define COMMENT 2
# define YYNEWLINE 10
yylex(){
int nstr; extern int yyprevious;
while((nstr = yylook()) >= 0)
yyfussy: switch(nstr){
case 0:
if(yywrap()) return(0); break;
case 1:
			{
           BEGIN COMMENT;		}
break;
case 2:
			{
           BEGIN INITIAL;		}
break;
case 3:
                             {
                                        }
break;
case 4:
                            {
                                        }
break;
case 5:
                          {
                                        }
break;
case 6:
                           {
	return(COMMA);
                                        }
break;
case 7:
			{
        sscanf(yytext,"%lf",&f);
        return(CONS);                  
                                        }
break;
case 8:
					{ Sign=0;
					  for(x=0;x<yyleng;x++)
					    if(yytext[x]=='-'||yytext[x]=='+')
					      Sign=(Sign==(yytext[x]=='+'));
					  return (SIGN);
					/* Sign is TRUE if the sign-string
					   represents a '-'. Otherwise Sign
					   is FALSE */
					}
break;
case 9:
			{
          {strcpy(Last_var, yytext);}
          return(VAR);
                                        }
break;
case 10:
			{
          return(AR_M_OP);		}
break;
case 11:
				{
          return(RE_OP);		}
break;
case 12:
			{
          return(END_C);		}
break;
case 13:
			{
          fprintf(stderr,"LEX ERROR : %s lineno %d \n" ,yytext,yylineno);     }
break;
case -1:
break;
default:
fprintf(yyout,"bad switch yylook %d",nstr);
} return(0); }
/* end of yylex */
int yyvstop[] = {
0,

11,
0,

11,
0,

11,
0,

11,
0,

13,
0,

5,
8,
13,
0,

5,
8,
0,

10,
13,
0,

8,
13,
0,

6,
13,
0,

13,
0,

13,
0,

7,
13,
0,

12,
13,
0,

11,
13,
0,

11,
13,
0,

9,
13,
0,

3,
0,

4,
0,

3,
0,

8,
0,

7,
0,

1,
0,

7,
0,

11,
0,

9,
0,

9,
0,

2,
0,

7,
0,
0};
# define YYTYPE char
struct yywork { YYTYPE verify, advance; } yycrank[] = {
0,0,	0,0,	1,5,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	1,6,	1,7,	
9,21,	9,21,	21,21,	21,21,	
3,18,	6,7,	6,7,	0,0,	
0,0,	0,0,	0,0,	0,0,	
3,18,	3,19,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	9,21,	
0,0,	21,21,	0,0,	0,0,	
6,7,	0,0,	0,0,	1,8,	
1,9,	1,10,	4,20,	1,11,	
1,12,	1,13,	2,8,	6,21,	
2,10,	6,21,	2,11,	2,12,	
12,23,	3,20,	3,18,	20,30,	
1,14,	1,15,	1,16,	3,18,	
15,27,	0,0,	1,17,	2,14,	
0,0,	2,16,	1,17,	0,0,	
0,0,	0,0,	0,0,	3,18,	
22,26,	0,0,	0,0,	0,0,	
3,18,	0,0,	0,0,	0,0,	
3,18,	11,22,	11,22,	11,22,	
11,22,	11,22,	11,22,	11,22,	
11,22,	11,22,	11,22,	13,24,	
1,5,	13,25,	13,25,	13,25,	
13,25,	13,25,	13,25,	13,25,	
13,25,	13,25,	13,25,	0,0,	
22,26,	0,0,	3,18,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	13,26,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	17,28,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	17,29,	17,29,	
17,29,	17,29,	17,29,	17,29,	
17,29,	17,29,	17,29,	17,29,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	13,26,	17,29,	
17,29,	17,29,	17,29,	17,29,	
17,29,	17,29,	17,29,	17,29,	
17,29,	17,29,	17,29,	17,29,	
17,29,	17,29,	17,29,	17,29,	
17,29,	17,29,	17,29,	17,29,	
17,29,	17,29,	17,29,	17,29,	
17,29,	0,0,	0,0,	0,0,	
0,0,	17,29,	0,0,	17,29,	
17,29,	17,29,	17,29,	17,29,	
17,29,	17,29,	17,29,	17,29,	
17,29,	17,29,	17,29,	17,29,	
17,29,	17,29,	17,29,	17,29,	
17,29,	17,29,	17,29,	17,29,	
17,29,	17,29,	17,29,	17,29,	
17,29,	26,31,	0,0,	26,31,	
0,0,	0,0,	26,32,	26,32,	
26,32,	26,32,	26,32,	26,32,	
26,32,	26,32,	26,32,	26,32,	
31,32,	31,32,	31,32,	31,32,	
31,32,	31,32,	31,32,	31,32,	
31,32,	31,32,	0,0,	0,0,	
0,0};
struct yysvf yysvec[] = {
0,	0,	0,
yycrank+-1,	0,		yyvstop+1,
yycrank+-8,	yysvec+1,	yyvstop+3,
yycrank+-15,	0,		yyvstop+5,
yycrank+-4,	yysvec+3,	yyvstop+7,
yycrank+0,	0,		yyvstop+9,
yycrank+8,	0,		yyvstop+11,
yycrank+0,	yysvec+6,	yyvstop+15,
yycrank+0,	0,		yyvstop+18,
yycrank+3,	yysvec+6,	yyvstop+21,
yycrank+0,	0,		yyvstop+24,
yycrank+37,	0,		yyvstop+27,
yycrank+14,	0,		yyvstop+29,
yycrank+49,	0,		yyvstop+31,
yycrank+0,	0,		yyvstop+34,
yycrank+3,	0,		yyvstop+37,
yycrank+0,	0,		yyvstop+40,
yycrank+86,	0,		yyvstop+43,
yycrank+0,	0,		yyvstop+46,
yycrank+0,	0,		yyvstop+48,
yycrank+12,	0,		yyvstop+50,
yycrank+5,	yysvec+6,	yyvstop+52,
yycrank+7,	yysvec+11,	yyvstop+54,
yycrank+0,	0,		yyvstop+56,
yycrank+0,	yysvec+11,	0,	
yycrank+0,	yysvec+13,	yyvstop+58,
yycrank+166,	0,		0,	
yycrank+0,	0,		yyvstop+60,
yycrank+0,	0,		yyvstop+62,
yycrank+0,	yysvec+17,	yyvstop+64,
yycrank+0,	0,		yyvstop+66,
yycrank+176,	0,		0,	
yycrank+0,	yysvec+31,	yyvstop+68,
0,	0,	0};
struct yywork *yytop = yycrank+233;
struct yysvf *yybgin = yysvec+1;
char yymatch[] = {
00  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,011 ,012 ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
011 ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,'+' ,01  ,'+' ,01  ,01  ,
'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,
'0' ,'0' ,01  ,01  ,'<' ,01  ,'<' ,01  ,
01  ,'A' ,'A' ,'A' ,'A' ,'E' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,01  ,01  ,01  ,01  ,'_' ,
01  ,'A' ,'A' ,'A' ,'A' ,'E' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,01  ,01  ,01  ,01  ,01  ,
0};
char yyextra[] = {
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0};
#ifndef lint
static	char ncform_sccsid[] = "@(#)ncform 1.6 88/02/08 SMI"; /* from S5R2 1.2 */
#endif

int yylineno =1;
# define YYU(x) x
# define NLSTATE yyprevious=YYNEWLINE
char yytext[YYLMAX];
struct yysvf *yylstate [YYLMAX], **yylsp, **yyolsp;
char yysbuf[YYLMAX];
char *yysptr = yysbuf;
int *yyfnd;
extern struct yysvf *yyestate;
int yyprevious = YYNEWLINE;
yylook(){
	register struct yysvf *yystate, **lsp;
	register struct yywork *yyt;
	struct yysvf *yyz;
	int yych, yyfirst;
	struct yywork *yyr;
# ifdef LEXDEBUG
	int debug;
# endif
	char *yylastch;
	/* start off machines */
# ifdef LEXDEBUG
	debug = 0;
# endif
	yyfirst=1;
	if (!yymorfg)
		yylastch = yytext;
	else {
		yymorfg=0;
		yylastch = yytext+yyleng;
		}
	for(;;){
		lsp = yylstate;
		yyestate = yystate = yybgin;
		if (yyprevious==YYNEWLINE) yystate++;
		for (;;){
# ifdef LEXDEBUG
			if(debug)fprintf(yyout,"state %d\n",yystate-yysvec-1);
# endif
			yyt = yystate->yystoff;
			if(yyt == yycrank && !yyfirst){  /* may not be any transitions */
				yyz = yystate->yyother;
				if(yyz == 0)break;
				if(yyz->yystoff == yycrank)break;
				}
			*yylastch++ = yych = input();
			yyfirst=0;
		tryagain:
# ifdef LEXDEBUG
			if(debug){
				fprintf(yyout,"char ");
				allprint(yych);
				putchar('\n');
				}
# endif
			yyr = yyt;
			if ( (int)yyt > (int)yycrank){
				yyt = yyr + yych;
				if (yyt <= yytop && yyt->verify+yysvec == yystate){
					if(yyt->advance+yysvec == YYLERR)	/* error transitions */
						{unput(*--yylastch);break;}
					*lsp++ = yystate = yyt->advance+yysvec;
					goto contin;
					}
				}
# ifdef YYOPTIM
			else if((int)yyt < (int)yycrank) {		/* r < yycrank */
				yyt = yyr = yycrank+(yycrank-yyt);
# ifdef LEXDEBUG
				if(debug)fprintf(yyout,"compressed state\n");
# endif
				yyt = yyt + yych;
				if(yyt <= yytop && yyt->verify+yysvec == yystate){
					if(yyt->advance+yysvec == YYLERR)	/* error transitions */
						{unput(*--yylastch);break;}
					*lsp++ = yystate = yyt->advance+yysvec;
					goto contin;
					}
				yyt = yyr + YYU(yymatch[yych]);
# ifdef LEXDEBUG
				if(debug){
					fprintf(yyout,"try fall back character ");
					allprint(YYU(yymatch[yych]));
					putchar('\n');
					}
# endif
				if(yyt <= yytop && yyt->verify+yysvec == yystate){
					if(yyt->advance+yysvec == YYLERR)	/* error transition */
						{unput(*--yylastch);break;}
					*lsp++ = yystate = yyt->advance+yysvec;
					goto contin;
					}
				}
			if ((yystate = yystate->yyother) && (yyt= yystate->yystoff) != yycrank){
# ifdef LEXDEBUG
				if(debug)fprintf(yyout,"fall back to state %d\n",yystate-yysvec-1);
# endif
				goto tryagain;
				}
# endif
			else
				{unput(*--yylastch);break;}
		contin:
# ifdef LEXDEBUG
			if(debug){
				fprintf(yyout,"state %d char ",yystate-yysvec-1);
				allprint(yych);
				putchar('\n');
				}
# endif
			;
			}
# ifdef LEXDEBUG
		if(debug){
			fprintf(yyout,"stopped at %d with ",*(lsp-1)-yysvec-1);
			allprint(yych);
			putchar('\n');
			}
# endif
		while (lsp-- > yylstate){
			*yylastch-- = 0;
			if (*lsp != 0 && (yyfnd= (*lsp)->yystops) && *yyfnd > 0){
				yyolsp = lsp;
				if(yyextra[*yyfnd]){		/* must backup */
					while(yyback((*lsp)->yystops,-*yyfnd) != 1 && lsp > yylstate){
						lsp--;
						unput(*yylastch--);
						}
					}
				yyprevious = YYU(*yylastch);
				yylsp = lsp;
				yyleng = yylastch-yytext+1;
				yytext[yyleng] = 0;
# ifdef LEXDEBUG
				if(debug){
					fprintf(yyout,"\nmatch ");
					sprint(yytext);
					fprintf(yyout," action %d\n",*yyfnd);
					}
# endif
				return(*yyfnd++);
				}
			unput(*yylastch);
			}
		if (yytext[0] == 0  /* && feof(yyin) */)
			{
			yysptr=yysbuf;
			return(0);
			}
		yyprevious = yytext[0] = input();
		if (yyprevious>0)
			output(yyprevious);
		yylastch=yytext;
# ifdef LEXDEBUG
		if(debug)putchar('\n');
# endif
		}
	}
yyback(p, m)
	int *p;
{
if (p==0) return(0);
while (*p)
	{
	if (*p++ == m)
		return(1);
	}
return(0);
}
	/* the following are only used in the lex library */
yyinput(){
	return(input());
	}
yyoutput(c)
  int c; {
	output(c);
	}
yyunput(c)
   int c; {
	unput(c);
	}
