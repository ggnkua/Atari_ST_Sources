/* bobfcn.c - built-in classes and functions */
/*
	Copyright (c) 1991, by David Michael Betz
	All rights reserved
*/

#include "bob.h"

/* argument check macros */
#define argcount(n,cnt)	{ if ((n) < (cnt)) toomany(); \
						  else if ((n) > (cnt)) toofew(); }

/* external variables */
extern VALUE symbols;

/* forward declarations */
int xtypeof();
int xnewvector(),xnewstring(),xsizeof(),xprint(),xgetarg(),xsystem();
int xfopen(),xfclose(),xgetc(),xputc();

/* init_functions - initialize the internal functions */
void init_functions()
{
	add_file("stdin",stdin);
	add_file("stdout",stdout);
	add_file("stderr",stderr);
	add_function("typeof",xtypeof);
	add_function("newvector",xnewvector);
	add_function("newstring",xnewstring);
	add_function("sizeof",xsizeof);
	add_function("fopen",xfopen);
	add_function("fclose",xfclose);
	add_function("getc",xgetc);
	add_function("putc",xputc);
	add_function("print",xprint);
	add_function("getarg",xgetarg);
	add_function("system",xsystem);
}

/* add_function - add a built-in function */
static add_function(name,fcn)
char *name; int (*fcn)();
{
	DICT_ENTRY *sym;
    
	sym = addentry(&symbols,name,ST_SFUNCTION);
	set_code(&sym->de_value,fcn);
}

/* add_file - add a built-in file */
static add_file(name,fp)
char *name; FILE *fp;
{
    DICT_ENTRY *sym;
    
	sym = addentry(&symbols,name,ST_SDATA);
	set_file(&sym->de_value,fp);
}

/* xtypeof - get the data type of a value */
static int xtypeof(argc)
int argc;
{
    argcount(argc,1);
    set_integer(&sp[1],sp->v_type);
    ++sp;
}

/* xnewvector - allocate a new vector */
static int xnewvector(argc)
int argc;
{
	int size;

	argcount(argc,1);
	chktype(0,DT_INTEGER);
	size = sp->v.v_integer;
	set_vector(&sp[1],newvector(size));
	++sp;
}

/* xnewstring - allocate a new string */
static int xnewstring(argc)
int argc;
{
	int size;
		
	argcount(argc,1);
	chktype(0,DT_INTEGER);
	size = sp->v.v_integer;
	set_string(&sp[1],newstring(size));
	++sp;
}

/* xsizeof - get the size of a vector or string */
static int xsizeof(argc)
int argc;
{
    argcount(argc,1);
    switch (sp->v_type) 
    {
    case DT_VECTOR:
		set_integer(&sp[1],sp->v.v_vector->vec_size);
		break;
    case DT_STRING:
		set_integer(&sp[1],sp->v.v_string->str_size);
		break;
    default:
		break;
    }
    ++sp;
}

/* xfopen - open a file */
static int xfopen(argc)
int argc;
{
    char name[50],mode[10];
    FILE *fp;
    
    argcount(argc,2);
    chktype(0,DT_STRING);
    chktype(1,DT_STRING);
    getcstring(name,sizeof(name),&sp[1]);
    getcstring(mode,sizeof(mode),&sp[0]);
    if ((fp = fopen(name,mode)) == NULL)
		set_nil(&sp[2]);
    else
		set_file(&sp[2],fp);
    sp += 2;
}

/* xfclose - close a file */
static int xfclose(argc)
int argc;
{
    argcount(argc,1);
    chktype(0,DT_FILE);
    set_integer(&sp[1],fclose(sp[0].v.v_fp));
    ++sp;
}

/* xgetc - get a character from a file */
static int xgetc(argc)
int argc;
{
    argcount(argc,1);
    chktype(0,DT_FILE);
    set_integer(&sp[1],getc(sp[0].v.v_fp));
    ++sp;
}

/* xputc - output a character to a file */
static int xputc(argc)
int argc;
{
    argcount(argc,2);
    chktype(0,DT_FILE);
    chktype(1,DT_INTEGER);
    set_integer(&sp[2],putc(sp[1].v.v_integer,sp[0].v.v_fp));
    sp += 2;
}

/* xprint - generic print function */
static int xprint(argc)
int argc;
{
    int n;
    
    for (n = argc; --n >= 0; )
		print1(stdout,FALSE,&sp[n]);
    sp += argc;
    set_nil(sp);
}

/* print1 - print one value */
print1(fp,qflag,val)
FILE *fp; int qflag; VALUE *val;
{
    char name[TKNSIZE+1],buf[200],*p;
    VALUE *class;
    int len;
    
    switch (val->v_type) 
    {
    case DT_NIL:
		fputs("nil",fp);
		break;
    case DT_CLASS:
		getcstring(name,sizeof(name),clgetname(val));
		sprintf(buf,"#<Class-%s>",name);
		fputs(buf,fp);
		break;
    case DT_OBJECT:
		sprintf(buf,"#<Object-%lx>",objaddr(val));
		fputs(buf,fp);
		break;
    case DT_VECTOR:
		sprintf(buf,"#<Vector-%lx>",vecaddr(val));
		fputs(buf,fp);
		break;
    case DT_INTEGER:
		sprintf(buf,"%ld",val->v.v_integer);
		fputs(buf,fp);
		break;
    case DT_STRING:
		if (qflag) putc('"',fp);
			p = strgetdata(val);
		len = strgetsize(val);
		while (--len >= 0)
			putc(*p++,fp);
		if (qflag) 
			putc('"',fp);
		break;
    case DT_BYTECODE:
		sprintf(buf,"#<Bytecode-%lx>",vecaddr(val));
		fputs(buf,fp);
		break;
    case DT_CODE:
		sprintf(buf,"#<Code-%lx>",val->v.v_code);
		fputs(buf,fp);
		break;
    case DT_VAR:
		class = digetclass(degetdictionary(val));
		if (!isnil(class)) 
		{
			getcstring(name,sizeof(name),clgetname(class));
			sprintf(buf,"%s::",name);
			fputs(buf,fp);
		}
		getcstring(name,sizeof(name),degetkey(val));
		fputs(name,fp);
		break;
    case DT_FILE:
		sprintf(buf,"#<File-%lx>",val->v.v_fp);
		fputs(buf,fp);
		break;
    default:
		error("Undefined type: %d",valtype(val));
    }
}

/* xgetarg - get an argument from the argument list */
static int xgetarg(argc)
int argc;
{
	extern char **bobargv;
	extern int bobargc;
	int i;
	
	argcount(argc,1);
	chktype(0,DT_INTEGER);
	i = sp[0].v.v_integer;
	if (i >= 0 && i < bobargc)
		set_string(&sp[1],makestring(bobargv[i]));
	else
		set_nil(&sp[1]);
	++sp;
}

/* xsystem - execute a system command */
static int xsystem(argc)
int argc;
{
	char cmd[133];
	
	argcount(argc,1);
	chktype(0,DT_STRING);
	getcstring(cmd,sizeof(cmd),&sp[0]);
	set_integer(&sp[1],system(cmd));
	++sp;
}

/* toofew - too few arguments */
static int toofew()
{
	error("Too few arguments");
	return (FALSE);
}

/* toomany - too many arguments */
static int toomany()
{
	error("Too many arguments");
	return (FALSE);
}
