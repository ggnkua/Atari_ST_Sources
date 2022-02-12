/* RTF 2 HTML converter. Source code (C)1997 by J.Smith. Freeware */
/* I made some minor changes to make the code more ANSI C. -Levien */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*void addtostring(char,int);*/
void bracketedcommand ();
void checktags();
void dotags();
void filecopy ();
void getcommand();
void getdate();
void killcolon ();
void killendbracket ();
void loadinpos();
void saveinpos();
void loadoutpos();
void saveoutpos();
void printbracket ();
void printcolon ();
void printdate();
void printfootnotes();
void printtags();
void resetdate();
void runcommand ();
void rununtilbracket();
FILE *inp,*outp;
int
fonton=0,fselected=0,justdonebold=0,justdoneitalic=0,justdoneunderline=0,
cellon=0,tableon=2,footnote=0,valerie=0,sparec=0,paron=0,endcommandbyte=0,
date=0,hour=0,minute=0,month=0,year=0,donecommand=0,realnumber=0,
bracketon=0,c,italicon=0,boldon=0,underlineon=0,centeron=0,justdonecenter=0,
fontsize=0, justdonefontsize=0,lastfontsize=0;
char
monthstring[100],number[100],command[100],inputfilename[128],outputfilename[128],fontname[20][100];
long infilepos,outfilepos,footnotefilepos[1000];

main(int argc,char *argv[])
{
/*if (argc<2) exit(0);*/

printf("RTF 2 HTML converter Version 1.0\n");
printf("Does RTF bookmarks, tables, Headings, Bold Underline Italic, \
document header info, etc\n");
printf("Fontsize 8=h6 11=h5 14=h4 18=h3 24=h2 28=h1.\n");
printf("\nThis is FREEWARE by SnakeSoft\n");
printf("fargoenterpris@geocities.com\n");
printf("http://www.geocities.com/soho/7691/\n");
printf("Thanks to Levien van Zon for compiling this!!\n");
printf("lvzon@bio.vu.nl\nhttp://huizen.dds.nl/~levjenno/\n");
printf("\n---Instructions:---\n");
printf("Enter Input Filename (or enter at the command line)\n");
printf("Enter Output Filename.\n");
printf("Away you go...\n\n");

if (argc<2)
{
printf("Please enter input path and filename:");
scanf("%s",inputfilename);

if((inp=fopen(inputfilename,"r+b"))==NULL)
{
printf("Can't find the input file.\n");
exit(0);
}

}
else
{
if((inp=fopen(argv[1],"r+b"))==NULL)
{printf("Can't find the input file.\n");
exit(0);
}
};


printf("Please enter output path and filename:\n");
printf("(This will overwrite existing files with the same name) ");
scanf("%s",outputfilename);

if((stricmp(inputfilename,outputfilename))==0)
{
printf("Sorry, that would ERASE the input file... Exiting...");
exit(0);
};

if((stricmp(argv[1],outputfilename))==0)
{
printf("Sorry, that would ERASE the input file... Exiting...");
exit(0);
};

if((outp=fopen(outputfilename,"w+b"))==NULL)
{
printf("No output. Quitting.\n");
exit(0);
}

filecopy ();
fclose (inp);
fclose (outp);
return(0);
}

void addtostring(str,endchar)
char *str;
int endchar;
{
int stringpos;
stringpos=0;
while ((c=getc(inp))!=EOF)
{
if (c==endchar) break;
str[stringpos]=c;
stringpos++;
};
str[stringpos]='\0';
};

void checktags()
{
if (boldon==1) fprintf(outp,"</b>");
if (underlineon==1) fprintf(outp,"</u>");
if (italicon==1) fprintf(outp,"</i>");
};

void closemeta()
{
fprintf(outp,"\">");
};


void dosize()
{
/*if (fontsize==16) fprintf(outp,"</h6>");
if (fontsize==21) fprintf(outp,"</h5>");
if (fontsize==28) fprintf(outp,"</h4>");
if (fontsize==36) fprintf(outp,"</h3>");
if (fontsize==48) fprintf(outp,"</h2>");
if (fontsize==56) fprintf(outp,"</h1>");

lastfontsize=0;
*/
};

void dotags()
{
if (boldon==1) fprintf(outp,"</b>");
if (underlineon==1) fprintf(outp,"</u>");
if (italicon==1) fprintf(outp,"</i>");
boldon=0;
underlineon=0;
italicon=0;

if ((justdonecenter==0)&&(centeron==1))
{
fprintf(outp,"</center>");
centeron=0;
};
};


int findslash()
{
sparec=c;
saveinpos();
while ((c=getc(inp))!=EOF)
{
if (c=='\\') return(1);
}
loadinpos();
c=sparec;
return(0);
};


void getcommand()
{
extern int date,month,hour,minute,year;
extern char monthstring[];
int commandlength,nomorecommands,numberlength;
numberlength=0;
commandlength=0;

while ((c=getc(inp))!=EOF)
{

if ((c>='0')&&(c<='9'))
{
number[numberlength]=c;
numberlength++;
}
else
{
command[commandlength]=c;
commandlength++;
}


if (c=='\\') break;
if (c==' ') break;
if (c==13) break;
if (c==10) break;
if (c=='\t') break;
if (c=='{') break;
if (c=='}') break;
if (commandlength>99) break;
}

number[numberlength]='\0';
realnumber=atoi(number);
command[commandlength-1]='\0';

if ((c==' ')||(c=='\t')||(c==13)||(c==10)||(c=='}')) donecommand=1;
endcommandbyte=c;
c=0;
}


void killcolon()
{
while ((c=getc(inp))!=EOF)
{
if (c==';') break;
};
c=0;
};

void killendbracket()
{
while ((c=getc(inp))!=EOF)
{
if (c=='}') break;
};
c=0;
};


void loadinpos()
{
fseek(inp,infilepos,SEEK_SET);
};

void loadoutpos()
{
fseek(outp,outfilepos,SEEK_SET);
};

void openmeta(char metastring[100])
{
fprintf(outp,"\n<META NAME=\"%s\" CONTENT=\"",metastring);
};

void printbracket()
{
while ((c=getc(inp))!=EOF)
{
if (c=='}') break;
fprintf(outp,"%c",c);
};
c=0;
};

void printcolon()
{
while ((c=getc(inp))!=EOF)
{
if (c==';') break;
fprintf(outp,"%c",c);
};
c=0;
};


void printdate()
{
if (hour<=9) fprintf(outp,"0");
fprintf(outp,"%d:",hour);
if (minute<=9) fprintf(outp,"0");
fprintf(outp,"%d %d %s %d",minute,date,monthstring,year);
};

void printfootnotes()
{
int footnotezero;
footnotezero=0;

while (footnotezero!=footnote)
{
fprintf(outp,"\n<hr><b><a name=\"footnote%d\"></a><sup>Footnote \
%d:</b></sup><p>\n",footnotezero+1,footnotezero+1);
fseek(inp,footnotefilepos[footnotezero],SEEK_SET);
printbracket();
footnotezero++;
}
};

void printtags()
{
if (boldon==1) fprintf(outp,"<b>");
if (underlineon==1) fprintf(outp,"<u>");
if (italicon==1) fprintf(outp,"<i>");
};

void resetdate()
{
date=0;
minute=0;
month=0;
hour=0;
year=0;
};

void rununtilbracket()
{
while (endcommandbyte!='}')
{
getcommand();
runcommand();
};
};

void saveinpos()
{
infilepos=ftell(inp);
};

void saveoutpos()
{
outfilepos=ftell(outp);
};


void runcommand()
{
if((stricmp(command,"\\"))==0)
{
fprintf(outp,"\\");
};

if((stricmp(command,"'"))==0)
{
if (realnumber==85) fprintf(outp,"...");
};

if((stricmp(command,"{"))==0)
{
fprintf(outp,"{");
};

if((stricmp(command,"}"))==0)
{
fprintf(outp,"}");
};

if((stricmp(command,"additive"))==0)
{
killcolon();
};

if((stricmp(command,"author"))==0)
{
openmeta("AUTHOR");
printbracket();
closemeta();
};

if((stricmp(command,"b"))==0)
{
if (boldon==0) fprintf(outp,"<b>");
boldon=1;
justdonebold=1;
};

if((stricmp(command,"cell"))==0)
{
if (boldon==1) fprintf(outp,"</B>");
if (underlineon==1) fprintf(outp,"</U>");
if (italicon==1) fprintf(outp,"</I>");
if ((tableon==1)&&(cellon==0)) fprintf(outp,"<TD>\t");
if (boldon==1) fprintf(outp,"<B>");
if (underlineon==1) fprintf(outp,"<U>");
if (italicon==1) fprintf(outp,"<I>");
cellon=1;
};

if((stricmp(command,"company"))==0)
{
openmeta("COMPANY");
printbracket();
closemeta();
};

if((stricmp(command,"creatim"))==0)
{
resetdate();
openmeta("CREATED");
rununtilbracket();
printdate();
closemeta();
};


if((stricmp(command,"dy"))==0)
{
date=realnumber;
};

if((stricmp(command,"edmins"))==0)
{
openmeta("EDITING MINUTES");
fprintf(outp,"%d",realnumber);
closemeta();
};


if((stricmp(command,"f"))==0)
{

/*if (fonton==1) fprintf(outp,"</FONT>\n");*/
fselected=realnumber;
/*fprintf(outp,"<FONT FACE=\"%s\"
SIZE=%d>",fontname[fselected],fontsize/4);*/
/*fonton=1;*/

if ((justdonebold==0)&&(boldon==1))
{
fprintf(outp,"</B>");
boldon=0;
};
if ((justdoneunderline==0)&&(underlineon==1))
{
fprintf(outp,"</U>");
underlineon=0;
};
if ((justdoneitalic==0)&&(italicon==1))
{
fprintf(outp,"</I>");
italicon=0;
};
};

/*
if((stricmp(command,"fcharset"))==0)
{
killcolon();
};
*/

/*if((stricmp(command,"fnil"))==0)
{
killcolon();
};
*/

if((stricmp(command,"footnote"))==0)
{
killendbracket();
footnotefilepos[footnote]=ftell(inp);
footnote++;
fprintf(outp,"<a href=\"#footnote%d\"><sup>%d</sup></a>",footnote,footnote);
killendbracket();
killendbracket();
};

if((stricmp(command,"fprq"))==0)
{
addtostring(fontname[fselected],';');
};

if((stricmp(command,"fs"))==0)
{
lastfontsize=fontsize;
fontsize=realnumber;

if (lastfontsize!=0)
{
if (lastfontsize==16) fprintf(outp,"</h6>");
if (lastfontsize==22) fprintf(outp,"</h5>");
if (lastfontsize==28) fprintf(outp,"</h4>");
if (lastfontsize==36) fprintf(outp,"</h3>");
if (lastfontsize==48) fprintf(outp,"</h2>");
if (lastfontsize==56) fprintf(outp,"</h1>");
lastfontsize=0;
}
if (fontsize==16) fprintf(outp,"<h6>");
if (fontsize==22) fprintf(outp,"<h5>");
if (fontsize==28) fprintf(outp,"<h4>");
if (fontsize==36) fprintf(outp,"<h3>");
if (fontsize==48) fprintf(outp,"<h2>");
if (fontsize==56) fprintf(outp,"<h1>");
justdonefontsize=1;
}

if((stricmp(command,"hr"))==0)
{
hour=realnumber;
};

if((stricmp(command,"i"))==0)
{
if (italicon==0) fprintf(outp,"<i>");
italicon=1;
justdoneitalic=1;
};

if((stricmp(command,"intbl"))==0)
{
if (boldon==1) fprintf(outp,"</B>");
if (underlineon==1) fprintf(outp,"</U>");
if (italicon==1) fprintf(outp,"</I>");
if ((tableon==1)&&(cellon==0)) fprintf(outp,"<TD>\t");
if (boldon==1) fprintf(outp,"<B>");
if (underlineon==1) fprintf(outp,"<U>");
if (italicon==1) fprintf(outp,"<I>");
cellon=1;
};

if((stricmp(command,"lquote"))==0)
{
fprintf(outp,"`");
};

if((stricmp(command,"min"))==0)
{
minute=realnumber;
};

if((stricmp(command,"mo"))==0)
{
if (realnumber==1) strcpy(monthstring,"January");
if (realnumber==2) strcpy(monthstring,"February");
if (realnumber==3) strcpy(monthstring,"March");
if (realnumber==4) strcpy(monthstring,"April");
if (realnumber==5) strcpy(monthstring,"May");
if (realnumber==6) strcpy(monthstring,"June");
if (realnumber==7) strcpy(monthstring,"July");
if (realnumber==8) strcpy(monthstring,"August");
if (realnumber==9) strcpy(monthstring,"September");
if (realnumber==10) strcpy(monthstring,"October");
if (realnumber==11) strcpy(monthstring,"November");
if (realnumber==12) strcpy(monthstring,"December");
};


if((stricmp(command,"nofchars"))==0)
{
openmeta("CHARACTERS");
fprintf(outp,"%d",realnumber);
closemeta();
};

if((stricmp(command,"nofpages"))==0)
{
openmeta("PAGES");
fprintf(outp,"%d",realnumber);
closemeta();
};

if((stricmp(command,"nofwords"))==0)
{
openmeta("WORDS");
fprintf(outp,"%d",realnumber);
closemeta();
};

if((stricmp(command,"nowidctlpar"))==0)
{
if (tableon==1) fprintf(outp,"\n</TABLE>");
tableon=0;
};


if((stricmp(command,"objdata"))==0)
{
killendbracket();
};

if((stricmp(command,"operator"))==0)
{
openmeta("OPERATOR");
printbracket();
closemeta();
};


if((stricmp(command,"par"))==0)
{
dotags();
dosize();
if (paron==1)
{
loadoutpos();
fprintf(outp,"\n\n<p>\n");
};

if (paron==0)
{
paron=1;
saveoutpos();
fprintf(outp,"\n<br>\n");
};
};

if((stricmp(command,"pichgoal"))==0)
{
killendbracket();
};

if((stricmp(command,"plain"))==0)
{
dotags();
dosize();
};

if((stricmp(command,"qc"))==0)
{
if (centeron==1) fprintf(outp,"</center>");
fprintf(outp,"<center>");
justdonecenter=1;
centeron=1;
};

if((stricmp(command,"revtim"))==0)
{
resetdate();
openmeta("REVISED");
rununtilbracket();
printdate();
closemeta();
};

if((stricmp(command,"row"))==0)
{
if (tableon==1) fprintf(outp,"\n<TR>");
cellon=0;
};

if((stricmp(command,"rquote"))==0)
{
fprintf(outp,"'");
};

if((stricmp(command,"snext"))==0)
{
killcolon();
};

if((stricmp(command,"ul"))==0)
{
if (underlineon==0) fprintf(outp,"<u>");
underlineon=1;
justdoneunderline=1;
};

if((stricmp(command,"version"))==0)
{
openmeta("VERSION");
fprintf(outp,"%d",realnumber);
closemeta();
};

if((stricmp(command,"widctlpar"))==0)
{
if (tableon==0) fprintf(outp,"\n\n<TABLE BORDER>\n");
tableon=1;
};

if((stricmp(command,"yr"))==0)
{
year=realnumber;
};



};


void filecopy()
{
while ((c=getc(inp))!=EOF)
{
if ((c=='{')||(c=='}')) c=0;

bracketon=0;
if (c=='&')
{
fprintf(outp,"&amp;");
paron=0;
c=0;
};

if (c=='\\')
{
while (donecommand==0)
{
getcommand();
runcommand();
};
donecommand=0;
justdonefontsize=0;
justdonecenter=0;
justdonebold=0;
justdoneitalic=0;
justdoneunderline=0;
}

if (c!=0)
{
if ((c!=0x0a)&&(c!=0x0d))
{
fprintf(outp,"%c",c);
paron=0;
cellon=0;
};
};
}
printfootnotes();
};

