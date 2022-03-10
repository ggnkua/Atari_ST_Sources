###    This is a flex input file but should be edited in -*-C-*- mode
###
###    C++2LaTeX: Produce prettyprinted LaTeX files from  C++ or C sources.
###    Copyright (C) 1990 Norbert Kiesel
###
###    This program is free software; you can redistribute it and/or modify
###    it under the terms of the GNU General Public License as published by
###    the Free Software Foundation; either version 1, or (at your option)
###    any later version.
###
###    This program is distributed in the hope that it will be useful,
###    but WITHOUT ANY WARRANTY; without even the implied warranty of
###    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
###    GNU General Public License for more details.
###
###    You should have received a copy of the GNU General Public License
###    along with this program; if not, write to the Free Software
###    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
###
###    Norbert Kiesel     
###    RWTH Aachen / Institut f. Informatik III
###    Ahornstr. 55
###    D-5100 Aachen
###    West Germany  
###
###    Phone:  +49 241 80-7266
###    EUNET:  norbert@rwthi3.uucp
###    USENET: ...!mcvax!unido!rwthi3!norbert
###    X.400:  norbert@rwthi3.informatik.rwth-aachen.de
###
###    Please contact me for any bugs you find in this code or any
###    improvements! I'd also be very happy to get feedback where and
###    how frequently this program is used (just drop a little mail :-).

%x STRING BCOMMENT INCLUDE
%s CPLUSPLUS

%{
#define KEY	printf ("{\\%s %s}", keyword_font, yytext)
#define CPP	printf ("{\\%s \\%s}", cpp_font, yytext)
#define SYM(x)	printf ("$\\%s$", x)
#define OUT(x)	printf ("%s", x)
#define SUB(x)	substitute(x)
#define IND	indent(yytext)

#include <stdio.h>

#ifdef ANSI_C
  #ifdef C_PLUSPLUS
    #error ANSI_C and C_PLUSPLUS are mutually exclusive
  #else
    int cplusplus_mode = 0;
  #endif
#else /* CPLUSPLUS or default */
  int cplusplus_mode = 1;
#endif

int complete_file = 0;
int header = 0;
int tabtotab = 8;
int piped = 0;
char * font_size = "11";
char * indentation = "0.5em";
char * comment_font = "it";
char * keyword_font = "bf";
char * header_font = "sl";
char * cpp_font = "tt";
char * string_font = "tt";
void substitute(const char *);
void indent(const char *);
void newpage(int);
void usage(const char *);
%}

%%

	if (cplusplus_mode)
	  BEGIN (CPLUSPLUS);


"#"[ \t]*"include"	{ CPP; BEGIN (INCLUDE); }
"#"[ \t]*"define"	|
"#"[ \t]*"undef"	|
"#"[ \t]*"if"		|
"#"[ \t]*"ifdef"	|
"#"[ \t]*"ifndef"       |
"#"[ \t]*"elif"		|
"#"[ \t]*"else"		|
"#"[ \t]*"endif"	CPP;

<INCLUDE>"<"[^>]*/">"	{ OUT ("$<${\\"); OUT (string_font);
			  OUT ("{}"); SUB (yytext+1); OUT ("}$>$");
			  input(); BEGIN (INITIAL); }
<INCLUDE>\"[^\"]*/\"	{ OUT ("\"{\\"); OUT (string_font);
			  OUT ("{}"); SUB (yytext+1); OUT ("}\"");
			  input(); BEGIN (INITIAL); }
<INCLUDE>[ \t]+		ECHO;
<INCLUDE>[\n]		OUT ("\\mbox{}\\\\\n");
<INCLUDE>.		{ yyless (0); BEGIN (INITIAL); }

"auto"			|
"double"		|
"int"			|
"struct"		|
"break"			|
"else"			|
"long"			|
"switch"		|
"case"			|
"enum"			|
"register"		|
"typedef"		|
"char"			|
"extern"		|
"return"		|
"union"			|
"const"			|
"float"			|
"short"			|
"unsigned"		|
"continue"		|
"for"			|
"signed"		|
"void"			|
"default"		|
"goto"			|
"sizeof"		|
"volatile"		|
"do"			|
"if"			|
"static"		|
"while"			|
<CPLUSPLUS>"new"	|
<CPLUSPLUS>"delete"	|
<CPLUSPLUS>"this"	|
<CPLUSPLUS>"operator"	|
<CPLUSPLUS>"class"	|
<CPLUSPLUS>"public"	|
<CPLUSPLUS>"protected"	|
<CPLUSPLUS>"private"	|
<CPLUSPLUS>"virtual"	|
<CPLUSPLUS>"friend"	|
<CPLUSPLUS>"inline"	|
<CPLUSPLUS>"overload"	KEY;
"->"			SYM ("rightarrow");
"<<"			SYM ("ll");
">>"			SYM ("gg");
"<="			SYM ("leq");
">="			SYM ("geq");
"!="			SYM ("neq");
"||"			SYM ("mid\\mid");
"..."			SYM ("ldots");
"*="			SYM ("ast=");
"<<="			SYM ("ll=");
">>="			SYM ("gg=");
"^="			SYM ("vee=");
"|="			SYM ("mid=");
"~"			SYM ("sim");
"*"			SYM ("ast");
"^"			SYM ("wedge");
"|"			SYM ("mid");
<CPLUSPLUS>"->*"	SYM ("rightarrow\\ast");
"/"			OUT ("$/$");
"<"			OUT ("$<$");
">"			OUT ("$>$");
"&&"			OUT ("\\&\\&");
"%="			OUT ("\\%=");
"&="			OUT ("\\&=");
"{"			OUT ("\\{");
"}"			OUT ("\\}");
"&"			OUT ("\\&");
"%"			OUT ("\\%");
"--"			OUT ("-{}-");
<CPLUSPLUS>".*"		OUT (".$\\ast$");
"?"			|
":"			|
"="			|
","			|
"."			|
";"			|
"!"			|
"-"			|
"+"			|
"/="			|
"=="			|
"++"			|
"+="			|
"-="			|
"("			|
")"			|
"["			|
"]"			|
<CPLUSPLUS>"::"		ECHO;

<CPLUSPLUS>[a-zA-Z_$][a-zA-Z_$0-9]*	|
[a-zA-Z_][a-zA-Z_0-9]*			SUB (yytext);

"/*"				{ BEGIN (BCOMMENT); OUT ("{$/\\ast$\\");
				  OUT (comment_font); OUT ("{}"); }
<BCOMMENT>"*/"			{ BEGIN (INITIAL); OUT ("$\\ast/$}"); }
<BCOMMENT>"\n"			OUT ("\\mbox{}\\\\\n");
<BCOMMENT>^[ \t]+		IND;
<BCOMMENT>.			SUB (yytext);


L?\" 				{ BEGIN (STRING); OUT ("{\\");
				  OUT (string_font); OUT ("\""); }
<STRING>\\\\			OUT ("$\\backslash\\backslash$");
<STRING>\\[bfnrtv'"]		{ OUT ("$\\backslash$"); SUB (yytext+1); }
<STRING>\"			{ BEGIN (INITIAL); OUT ("\"}"); }
<STRING>"\n"			OUT ("\\mbox{}\\\\\n");
<STRING>^[ \t]+			IND;
<STRING>.			SUB (yytext);

([0-9]*\.[0-9]+[fFlL]?)		 |
([0-9]+\.[0-9]*[fFlL]?)		 |
([0-9]*\.?[0-9]+[eE][+-]?[0-9]+) |
([0-9]+\.?[0-9]*[eE][+-]?[0-9]+) ECHO;

[0-9]+[uUlL]?			ECHO;

L?'[ -~]'			SUB (yytext);
L?'\\[ntvbrfa\\?'"]'		|
L?'\\[0-7]{1,3}'		|
L?'\\x[0-9a-fA-F]{1,2}'		ECHO;

0[0-7]+[uUlL]?			ECHO;

0x[0-9a-fA-F]+[uUlL]?		ECHO;

"\\\n"				OUT ("$\\backslash$\\\\\n");
^[ \t]+				IND;
[ \t]+				ECHO;
"\f"[\n]?			OUT ("\\newpage\n");
"\n"				OUT ("\\mbox{}\\\\\n");

%%

void substitute (const char * input)
{
  while (*input)
    {
      switch (*input)
	{
	case '_':
	case '&':
	case '#':
	case '$':
	case '%':
	case '{':
	case '}':
	  printf ("\\%c", *input);
	  break;
	case '+':
	case '=':
	case '<':
	case '>':
	  printf ("$%c$", *input);
	  break;
	case '*':
	  printf ("$\\ast$");
	  break;
	case '|':
	  printf ("$\\mid$");
	  break;
	case '\\':
	  printf ("$\\backslash$");
	  break;
	case '^':
	  printf ("$\\wedge$");
	  break;
	case '~':
	  printf ("$\\sim$");
	  break;
	default:
	  printf ("%c", *input);
	  break;
	}
      input++;
    }
}

void
indent(const char * blanks)
{
  int i;
  
  i = 0;
  while (*blanks)
    {
      if (*blanks == ' ')
	{
	  i++;
	}
      else			/* *blanks == '\t' */
	{
	  while (++i % tabtotab) ;
	}
      blanks++;
    }
  printf ("\\hspace*{%d\\indentation}", i);
}

#include "getopt.h"
#include <string.h>
#include <fcntl.h>
#include <malloc.h>

extern char * version_string;

static struct option opts[] =
{
  {"ansi-c", 0, 0, 'a'},
  {"c-plusplus", 0, 0, 'p'},
  {"complete-file", 0, 0, 'c'},
  {"font-size", 1, 0, 's'},
  {"indentation", 1, 0, 'i'},
  {"header", 0, 0, 'h'},
  {"piped", 0, 0, 't'},
  {"output", 1, 0, 'o'},
  {"tabstop", 1, 0, 'T'},
  {"comment-font", 1, 0, 'C'},
  {"string-font", 1, 0, 'S'},
  {"keyword-font", 1, 0, 'K'},
  {"header-font", 1, 0, 'H'},
  {"cpp-font", 1, 0, 'P'},
  {"version", 0, 0, 'V'},
  {0, 0, 0, 0}
};


main (int argc, char** argv)
{
  int c;
  int index;
  int i;
  int has_filename;
  char * input_name;
  char * output_name;
  char * program_name;

  input_name = "Standard Input";
  output_name = 0;

  program_name = strrchr (argv[0], '/');
  if (program_name == NULL)	/* no pathname */
    {
      program_name = argv[0];
    }
  else
    {
      program_name++;
    }
  
#ifdef USE_NAME 
#if defined(ANSI_C) || defined(C_PLUSPLUS)
#error USE_NAME, ANSI_C and C_PLUSPLUS are mutually exclusive
#else
  /* simple heuristic: '+' in name means C++ */
  cplusplus_mode = (strchr (program_name, '+') != 0);
#endif
#endif
  
  while ((c = getopt_long (argc, argv,
			   "acpo:s:i:thT:C:H:S:K:P:V", opts, &index))
	 != EOF)
    {
      if (c == 0)		/* Long option */
	{
	  c = opts[index].val;
	}
      switch (c)
	{
	case 'a':
	  cplusplus_mode = 0;
	  break;
	case 'p':
	  cplusplus_mode = 1;
	  break;
	case 'c':
	  complete_file = 1;
	  break;
	case 'o':
	  if (piped)
	    {
	      fprintf (stderr,
		       "%s: Can't use {-t,+pipe} and {-o,+output} together\n",
		       program_name);
	      exit(5);
	    }
	  output_name = optarg;
	  break;
	case 's':
	  font_size = optarg;
	  break;
	case 'i':
	  indentation = optarg;
	  break;
	case 'T':
	  tabtotab = atoi(optarg);
	  break;
	    case 't':
	      if (output_name != 0)
	    {
	      fprintf (stderr,
		       "%s: Can't use {-t,+pipe} and {-o,+output} together\n",
		       program_name);
	      exit(5);
	    }
	  piped = 1;
	  break;
	case 'h':
	  header = 1;
	  complete_file = 1;	/* header implies complete-file */
	  break;
	case 'C':
	  comment_font = optarg;
	  break;
	case 'H':
	  header_font = optarg;
	  break;
	case 'P':
	  cpp_font = optarg;
	  break;
	case 'S':
	  string_font = optarg;
	  break;
	case 'K':
	  keyword_font = optarg;
	  break;
	case 'V':
	  fprintf (stderr, "%s\n", version_string);
	  break;
	default:
	  usage(program_name);
	}
    }
  has_filename = (argc - optind == 1);
  if (has_filename)		/* last argument is input file name */
    {
      input_name = argv[optind];
      if (freopen (input_name, "r", stdin) == NULL)
	{
	  fprintf (stderr, "%s: Can't open `%s' for reading\n",
		   program_name, input_name);
	  exit (2);
	}
    }
  if ((output_name == 0) && !piped)
    {
      char * tmp;
      if (has_filename)
	{
	  char * point;
	  
	  point = strrchr (input_name, '/');
	  if (point == 0)	/* plain filename */
	    {
	      point = input_name;
	    }
	  else
	    {
	      point++;
	    }
	  tmp = malloc (strlen (point) + 1);
	  if (tmp == 0)
	    {
	      fprintf (stderr, "%s: Virtual memory exhausted\n", program_name);
	      exit (3);
	    }
	  strcpy (tmp, point);
	  point = strrchr (tmp, '.');
	  if (point != 0)
	    {
	      *point = '\0';
	    }
	}
      else
	{
	  tmp = program_name;
	}
      output_name = malloc (strlen (tmp) + 4);
      if (output_name == 0)
	{
	  fprintf (stderr, "%s: Virtual memory exhausted\n", program_name);
	  exit (3);
	}
      strcpy (output_name, tmp);
      strcat (output_name, ".tex");
    }
  if (!piped)
    {
      if (freopen (output_name, "w", stdout) == NULL)
	{
	  fprintf (stderr, "%s: Can't open `%s' for writing\n",
		   program_name, output_name);
	  exit (4);
	}
    }
  printf ("\
%%\n\
%% This file was automatically produced at " __DATE__ ", " __TIME__" by\n\
%% %s", program_name);
  for (i = 1; i < argc; i++)
    {
      printf(" %s", argv[i]);
    }
  if (!has_filename)
    {
      printf(" (from Standard Input)");
    }
  printf("\n%%\n");
  if (complete_file)
    {
      if (header)
	{
	  if (strcmp (font_size, "10") == 0)
	    {
	      printf ("\\documentstyle[fancyheadings]{article}\n");
	    }
	  else
	    {
	      printf ("\\documentstyle[%spt,fancyheadings]{article}\n",
		      font_size);
	    }
	}
      else
	{
	  if (strcmp (font_size, "10") == 0)
	    {
	      printf ("\\documentstyle{article}\n");
	    }
	  else
	    {
	      printf ("\\documentstyle[%spt]{article}\n", font_size);
	    }
	}
      printf ("\\setlength{\\textwidth}{15cm}\n");
      printf ("\\setlength{\\textheight}{22.5cm}\n");
      printf ("\\setlength{\\hoffset}{-2cm}\n");
      printf ("\\setlength{\\voffset}{-2cm}\n");
      if (header)
	{
	  printf ("\\chead{\\%s Produced from ", header_font);
	  substitute(input_name);
	  printf (" at " __DATE__ ", " __TIME__"}\n");
	  printf ("\\cfoot{\\rm\\thepage}\n");
	  printf ("\\addtolength{\\headheight}{14pt}\n");
	  printf ("\\pagestyle{fancy}\n");
	}
      printf ("\\begin{document}\n");
    }
  printf ("\\expandafter\\ifx\\csname indentation\\endcsname\\relax%\n");
  printf ("\\newlength{\\indentation}\\fi\n");
  printf ("\\setlength{\\indentation}{%s}\n", indentation);
  printf ("\\begin{flushleft}\n");
  yylex();
  printf ("\\end{flushleft}\n");
  if (complete_file)
    {
      printf ("\\end{document}\n");
    }
}

void
usage(const char * name)
{
  fprintf (stderr, "%s\n", version_string);
  fprintf (stderr, "\
Usage: %s [-a] [-c] [-h] [-i length] [-o path] [-p] [-s size] [-t]\n\
       [-C font][-H font] [-K font] [-P font] [-S font] [-T wide] [-V]\n\
       [+ansi-c] [+complete-file] [+header] [+indentation length]\n\
       [+output path] [+c-plusplus] [+font-size size] [+pipe]\n\
       [+comment-font font] [+keyword-font font] [+cpp-font font]\n\
       [+header-font font] [+string-font font] [+tabstop wide]\n\
       [+version] [path]\n", name);
  exit (1);
}
