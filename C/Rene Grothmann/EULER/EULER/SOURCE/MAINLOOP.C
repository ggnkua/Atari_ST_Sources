#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <float.h>
#include <stdarg.h>

#include "header.h"
#include "sysdep.h"
#include "funcs.h"
#include "graphics.h"
	
char *ramstart,*ramend,*udfend,*startlocal,*endlocal,*newram,
	*varstart,*udframend;
char *next,*udfline;

FILE *metafile=0;

double epsilon;

char titel[]="This is EULER, Version 3.04 compiled %s.\n\n"
	"Type help(Return) for help.\n"
	"Enter command: (%ld Bytes free.)\n\n";

int error,quit,surpressed,udf=0,errorout,outputing=1,stringon=0,
	trace=0;
char line[1024];

long loopindex=0;

int fieldw=15,linew=5;
double maxexpo=1.0e5,minexpo=1.0e-7;
char expoformat[16]=" %14.5e";
char fixedformat[16]=" %14.7f";

int nosubmref=0;

FILE *infile=0,*outfile=0;

header commandheader;
int commandtype;

/* dumping to file */

void output (char *s)
{	text_mode();
	if (outputing || error) gprint(s);
	if (outfile)
	{	fprintf(outfile,"%s",s);
		if (ferror(outfile))
		{	output("Error on dump file (disk full?).\n");
			error=200;
			fclose(outfile); outfile=0;
		}
	}
}

void output1 (char *s, ...)
{	char text [1024];
	va_list v;
	text_mode();
	va_start(v,s);
	vsprintf(text,s,v);
	if (outputing || error) gprint(text);
	if (outfile)
	{	vfprintf(outfile,s,v);
		if (ferror(outfile))
		{	output("Error on dump file (disk full?).\n");
			error=200;
			fclose(outfile); outfile=0;
		}
	}
}

/* help */

extern commandtyp command_list[];

int dohelp (char start[256], char extend[16][16])
/* dohelp
Extend a start string in up to 16 ways to a command or function.
This function is called from the line editor, whenever the HELP
key is pressed.
*/
{	int count=0,ln,l;
	header *hd=(header *)ramstart;
	builtintyp *b=builtin_list;
	commandtyp *c=command_list;
	ln=(int)strlen(start);
	while (b->name)
	{	if (!strncmp(start,b->name,ln))
		{	l=(int)strlen(b->name)-ln;
			if (l>0 && l<16)
			{	strcpy(extend[count],b->name+ln);
				count++;
			}
			if (count>=16) return count;
		}
		b++;
	}
	while (hd<(header *)udfend)
	{	if (!strncmp(start,hd->name,ln))
		{	l=(int)strlen(hd->name)-ln;
			if (l>0 && l<16)
			{	strcpy(extend[count],hd->name+ln);
				count++;
			}
			if (count>=16) return count;
		}
		hd=nextof(hd);
	}
	while (c->name)
	{	if (!strncmp(start,c->name,ln))
		{	l=(int)strlen(c->name)-ln;
			if (l>0 && l<16)
			{	strcpy(extend[count],c->name+ln);
				count++;
			}
			if (count>=16) return count;
		}
		c++;
	}
	return count;
}

/* functions that manipulate the stack */

void kill_local (char *name);
void clear (void)
/***** clear
	clears the stack and remove all variables and functions.
*****/
{	char name[32];
	scan_space();
	if (*next==';' || *next==',' || *next==0)
	{	endlocal=startlocal;
	}
	else
	while(1)
	{	scan_name(name); if (error) return;
		kill_local(name);
		scan_space();
		if (*next==',') { next++; continue; }
		else break;
	}
}

int xor (char *n)
/***** xor
	compute a hashcode for the name n.
*****/
{	int r=0;
	while (*n) r^=*n++;
	return r;
}

void *make_header (stacktyp type, size_t size, char *name)
/***** make_header
	pushes a new element on the stack.
	return the position after the header.
******/
{	header *hd;
	char *erg;
#ifdef SPECIAL_ALIGNMENT
	size=(((size-1)/8)+1)*8;
#endif
	hd=(header *)(newram);
	if (newram+size>ramend)
	{	output("Stack overflow!\n"); error=2;
		return 0;
	}
	hd=(header *)newram;
	hd->size=size;
	hd->type=type;
	hd->flags=0;
	if (*name)
	{	strcpy(hd->name,name);
		hd->xor=xor(name);
	}
	else
	{	*(hd->name)=0;
		hd->xor=0;
	}
	erg=newram+sizeof(header);
	newram+=size;
	return erg;
}

header *new_matrix (int rows, int columns, char *name)
/***** new_matrix
	pops a new matrix on the stack.
*****/
{	size_t size;
	dims *d;
	header *hd=(header *)newram;
	size=matrixsize(rows,columns);
	d=(dims *)make_header(s_matrix,size,name);
	if (d) { d->c=columns; d->r=rows; }
	return hd;
}

header *new_cmatrix (int rows, int columns, char *name)
/***** new_matrix
	pops a new matrix on the stack.
*****/
{	size_t size;
	dims *d;
	header *hd=(header *)newram;
	size=matrixsize(rows,2*columns);
	d=(dims *)make_header(s_cmatrix,size,name);
	if (d) { d->c=columns; d->r=rows; }
	return hd;
}

header *new_command (int no)
/***** new_command
	pops a command on stack.
*****/
{	size_t size;
	int *d;
	header *hd=(header *)newram;
	size=sizeof(header)+sizeof(int);
	d=(int *)make_header(s_command,size,"");
	if (d) *d=no;
	return hd;
}

header *new_real (double x, char *name)
/***** new real
	pops a double on stack.
*****/
{	size_t size;
	double *d;
	header *hd=(header *)newram;
	size=sizeof(header)+sizeof(double);
	d=(double *)make_header(s_real,size,name);
	if (d) *d=x;
	return hd;
}

header *new_string (char *s, size_t length, char *name)
/***** new real
	pops a string on stack.
*****/
{	size_t size;
	char *d;
	header *hd=(header *)newram;
	size=sizeof(header)+((int)(length+1)/2+1)*2;
	d=(char *)make_header(s_string,size,name);
	if (d) strncpy(d,s,length); d[length]=0;
	return hd;
}

header *new_udf (char *name)
/***** new real
	pops a udf on stack.
*****/
{	size_t size;
	size_t *d;
	header *hd=(header *)newram;
    size=sizeof(header)+sizeof(size_t)+(LONG)2;
	d=(size_t *)make_header(s_udf,size,name);
	if (d) { *d=sizeof(header)+sizeof(size_t); *((char *)(d+1))=0; }
	return hd;
}

header *new_complex (double x, double y, char *name)
/***** new real
	pushes a complex on stack.
*****/
{	size_t size;
	double *d;
	header *hd=(header *)newram;
	size=sizeof(header)+2*sizeof(double);
	d=(double *)make_header(s_complex,size,name);
	if (d) *d=x; *(d+1)=y;
	return hd;
}

header *new_reference (header *ref, char *name)
{	size_t size;
	header **d;
	header *hd=(header *)newram;
	size=sizeof(header)+sizeof(header *);
	d=(header **)make_header(s_reference,size,name);
	if (d) *d=ref;
	return hd;
}

header *new_subm (header *var, LONG l, char *name)
/* makes a new submatrix, which is a single element */
{	size_t size;
	header **d,*hd=(header *)newram;
	dims *dim;
	int *n,r,c;
	size=sizeof(header)+sizeof(header *)+
		sizeof(dims)+2*sizeof(int);
	d=(header **)make_header(s_submatrix,size,name);
	if (d) *d=var;
	else return hd;
	dim=(dims *)(d+1);
	dim->r=1; dim->c=1;
	n=(int *)(dim+1);
	c=dimsof(var)->c;
	if (c==0 || dimsof(var)->r==0)
	{	output("Matrix is empty!\n"); error=1031; return hd;
	}
	else r=(int)(l/c);
	*n++=r;
	*n=(int)(l-(LONG)r*c-1);
	return hd;
}

header *new_csubm (header *var, LONG l, char *name)
/* makes a new submatrix, which is a single element */
{	size_t size;
	header **d,*hd=(header *)newram;
	dims *dim;
	int *n,r,c;
	size=sizeof(header)+sizeof(header *)+
		sizeof(dims)+2*sizeof(int);
	d=(header **)make_header(s_csubmatrix,size,name);
	if (d) *d=var;
	else return hd;
	dim=(dims *)(d+1);
	dim->r=1; dim->c=1;
	n=(int *)(dim+1);
	c=dimsof(var)->c;
	if (c==0 || dimsof(var)->r==0)
	{	output("Matrix is empty!\n"); error=1031; return hd;
	}
	else r=(int)(l/c);
	*n++=r;
	*n=(int)(l-r*c-1);
	return hd;
}

header *hnew_submatrix (header *var, header *rows, header *cols, 
	char *name, int type)
{	size_t size;
	header **d;
	double *mr,*mc=0,x,*mvar;
	dims *dim;
	int c,r,*n,i,c0,r0,cvar,rvar,allc=0,allr=0;
	header *hd=(header *)newram;
	getmatrix(var,&rvar,&cvar,&mvar);
	if (rows->type==s_matrix)
	{	if (dimsof(rows)->r==1) r=dimsof(rows)->c;
		else if (dimsof(rows)->c==1) r=dimsof(rows)->r;
		else
		{	output("Illegal index!\n"); error=41; return 0;
		}
		mr=matrixof(rows);
	}
	else if (rows->type==s_real)
	{	r=1; mr=realof(rows);
	}
	else if (rows->type==s_command && *commandof(rows)==c_allv)
	{	allr=1; r=rvar;
	}
	else
	{	output("Illegal index!\n"); error=41; return 0;
	}
	if (cols->type==s_matrix)
	{	if (dimsof(cols)->r==1) c=dimsof(cols)->c;
		else if (dimsof(cols)->c==1) c=dimsof(cols)->r;
		else
		{	output("Illegal index!\n"); error=41; return 0;
		}
		mc=matrixof(cols);
	}
	else if (cols->type==s_real)
	{	c=1; mc=realof(cols);
	}
	else if (cols->type==s_command && *commandof(cols)==c_allv)
	{	allc=1; c=cvar;
	}
	else
	{	output("Illegal index!\n"); error=41; return 0;
	}
	size=sizeof(header)+sizeof(header *)+
		sizeof(dims)+((LONG)r+c)*sizeof(int);
	d=(header **)make_header(type,size,name);
	if (d) *d=var;
	else return hd;
	dim = (dims *)(d+1);
	n=(int *)(dim+1);
	r0=0;
	if (allr)
	{	for (i=0; i<rvar; i++) *n++=i;
		r0=rvar;
	}
	else for (i=0; i<r; i++)
	{	x=(*mr++)-1;
		if (!((x<0.0) || (x>=rvar)) )
		{	*n++=(int)x; r0++;
		}
	}
	c0=0;
	if (allc)
	{	for (i=0; i<cvar; i++) *n++=i;
		c0=cvar;
	}
	else for (i=0; i<c; i++) 
	{	x=(*mc++)-1;
		if (!((x<0.0) || (x>=cvar))) 
		{	*n++=(int)x; c0++;
		}
	}
	dim->r=r0; dim->c=c0;
	size=(char *)n-(char *)hd;
#ifdef SPECIAL_ALIGNMENT
	size=((size-1)/8+1)*8;
#endif
	newram=(char *)hd;
	hd->size=size;
	return hd;
}

header *built_csmatrix (header *var, header *rows, header *cols)
/***** built_csmatrix
	built a complex submatrix from the matrix hd on the stack.
*****/
{	double *mr,*mc=0,*mvar,*mh,*m;
	int n,c,r,c0,r0,i,j,cvar,rvar,allc=0,allr=0,*pc,*pr,*nc,*nr;
	header *hd;
	char *ram;
	getmatrix(var,&rvar,&cvar,&mvar);
	if (rows->type==s_matrix)
	{	if (dimsof(rows)->r==1) r=dimsof(rows)->c;
		else if (dimsof(rows)->c==1) r=dimsof(rows)->r;
		else
		{	output("Illegal index!\n"); error=41; return 0;
		}
		mr=matrixof(rows);
	}
	else if (rows->type==s_real)
	{	r=1; mr=realof(rows);
	}
	else if (rows->type==s_command && *commandof(rows)==c_allv)
	{	allr=1; r=rvar;
	}
	else
	{	output("Illegal index!\n"); error=41; return 0;
	}
	if (cols->type==s_matrix)
	{	if (dimsof(cols)->r==1) c=dimsof(cols)->c;
		else if (dimsof(cols)->c==1) c=dimsof(cols)->r;
		else
		{	output("Illegal index!\n"); error=41; return 0;
		}
		mc=matrixof(cols);
	}
	else if (cols->type==s_real)
	{	c=1; mc=realof(cols);
	}
	else if (cols->type==s_command && *commandof(cols)==c_allv)
	{	allc=1; c=cvar;
	}
	else
	{	output("Illegal index!\n"); error=41; return 0;
	}
	ram=newram;
	if (ram+((LONG)(c)+(LONG)(r))*sizeof(int)>ramend)
	{	output("Out of memory!\n"); error=710; return 0;
	}
	nr=pr=(int *)ram; nc=pc=pr+r; newram=(char *)(pc+c);
	c0=0; r0=0;
	if (allc) { for (i=0; i<c; i++) pc[i]=i; c0=c; }
	else for (i=0; i<c; i++)
	{	n=(int)(*mc++)-1;
		if (n>=0 && n<cvar) { *nc++=n; c0++; }
	}
	if (allr) { for (i=0; i<r; i++) pr[i]=i; r0=r; }
	else for (i=0; i<r; i++) 
	{	n=(int)(*mr++)-1;
		if (n>=0 && n<rvar) { *nr++=n; r0++; }
	}
	if (c0==1 && r0==1)
	{	m=cmat(mvar,cvar,pr[0],pc[0]);
		return new_complex(*m,*(m+1),"");
	}
	hd=new_cmatrix(r0,c0,""); if (error) return 0;
	m=matrixof(hd);
	for (i=0; i<r0; i++)
		for (j=0; j<c0; j++)
		{	mh=cmat(mvar,cvar,pr[i],pc[j]);
			*m++=*mh++;
			*m++=*mh;
		}
	return hd;
}

header *built_smatrix (header *var, header *rows, header *cols)
/***** built_smatrix
	built a submatrix from the matrix hd on the stack.
*****/
{	double *mr,*mc=0,*mvar,*m;
	int n,c,r,c0,r0,i,j,cvar,rvar,allc=0,allr=0,*pr,*pc,*nc,*nr;
	header *hd;
	char *ram;
	getmatrix(var,&rvar,&cvar,&mvar);
	if (rows->type==s_matrix)
	{	if (dimsof(rows)->r==1) r=dimsof(rows)->c;
		else if (dimsof(rows)->c==1) r=dimsof(rows)->r;
		else
		{	output("Illegal index!\n"); error=41; return 0;
		}
		mr=matrixof(rows);
	}
	else if (rows->type==s_real)
	{	r=1; mr=realof(rows);
	}
	else if (rows->type==s_command && *commandof(rows)==c_allv)
	{	allr=1; r=rvar;
	}
	else
	{	output("Illegal index!\n"); error=41; return 0;
	}
	if (cols->type==s_matrix)
	{	if (dimsof(cols)->r==1) c=dimsof(cols)->c;
		else if (dimsof(cols)->c==1) c=dimsof(cols)->r;
		else
		{	output("Illegal index!\n"); error=41; return 0;
		}
		mc=matrixof(cols);
	}
	else if (cols->type==s_real)
	{	c=1; mc=realof(cols);
	}
	else if (cols->type==s_command && *commandof(cols)==c_allv)
	{	allc=1; c=cvar;
	}
	else
	{	output("Illegal index!\n"); error=41; return 0;
	}
	ram=newram;
	if (ram+((LONG)(c)+(LONG)(r))*sizeof(int)>ramend)
	{	output("Out of memory!\n"); error=710; return 0;
	}
	nr=pr=(int *)ram; nc=pc=pr+r; newram=(char *)(pc+c);
	c0=0; r0=0;
	if (allc) { for (i=0; i<c; i++) pc[i]=i; c0=c; }
	else for (i=0; i<c; i++)
	{	n=(int)(*mc++)-1;
		if (n>=0 && n<cvar) { *nc++=n; c0++; }
	}
	if (allr) { for (i=0; i<r; i++) pr[i]=i; r0=r; }
	else for (i=0; i<r; i++) 
	{	n=(int)(*mr++)-1;
		if (n>=0 && n<rvar) { *nr++=n; r0++; }
	}
	if (c0==1 && r0==1)
	{	return new_real(*mat(mvar,cvar,pr[0],pc[0]),"");
	}
	hd=new_matrix(r0,c0,""); if (error) return 0;
	m=matrixof(hd);
	for (i=0; i<r0; i++)
		for (j=0; j<c0; j++)
			*m++=*mat(mvar,cvar,pr[i],pc[j]);
	return hd;
}

header *new_submatrix (header *hd, header *rows, header *cols, 
	char *name)
{	if (nosubmref) return built_smatrix(hd,rows,cols);
	return hnew_submatrix(hd,rows,cols,name,s_submatrix);
}

header *new_csubmatrix (header *hd, header *rows, header *cols, 
	char *name)
{	if (nosubmref) return built_csmatrix(hd,rows,cols);
	return hnew_submatrix(hd,rows,cols,name,s_csubmatrix);
}

/***************** support functions ************************/

void print_error (char *p)
{	int i;
	char *q,outline[1024];
	double x;
	commandtyp *com;
	if (errorout) return;
	if (line<=p && line+1024>p)
	{	output1("error in:\n%s\n",line);
		if ((int)(p-line)<linelength-2)
			for (i=0; i<(int)(p-line); i++) output(" ");
		output("^\n");
	}
	else if (udfon)
	{	q=outline; p=udfline;
		while (*p)
		{	if (*p==2)
			{	p++; memmove((char *)(&x),p,sizeof(double));
				p+=sizeof(double);
				sprintf(q,"%g",x);
				q+=strlen(q);
			}
			else if (*p==3)
			{	p++;
				memmove((char *)(&com),p,sizeof(commandtyp *));
				p+=sizeof(commandtyp *);
				sprintf(q,"%s",com->name);
				q+=strlen(q);
			}
			else *q++=*p++;
			if (q>outline+1022)
			{	q=outline+1023;
				break;
			}
		}
		*q++=0;
		output1("Error in :\n%s\n",outline); output("\n");
	}
	errorout=1;
}

void read_line (char *line)
{	int count=0,input;
	char *p=line;
	while(1)
	{	input=getc(infile);
		if (input==EOF)
		{	fclose(infile); *p++=1; infile=0;
			break; 
		}
		if (input=='\n') break;
		if (count>=1023) 
		{	output("Line to long!\n"); error=50; *line=0; return;
		}
		if ((char)input>=' ' || (signed char)input<0 || (char)input==TAB)
		{	*p++=(char)input; count++;
		}
	}
	*p=0;
}

char *type_udfline (char *start)
{	char outline[1024],*p=start,*q;
	double x;
	commandtyp *com;
	q=outline;
	while (*p)
	{	if (*p==2)
		{	p++; memmove((char *)(&x),p,sizeof(double));
			p+=sizeof(double);
			sprintf(q,"%g",x);
			q+=strlen(q);
		}
		else if (*p==3)
		{	p++;
			memmove((char *)(&com),p,sizeof(commandtyp *));
			p+=sizeof(commandtyp *);
			sprintf(q,"%s",com->name);
			q+=strlen(q);
		}
		else *q++=*p++;
		if (q>outline+1022)
		{	q=outline+1023;
			break;
		}
	}
	*q++=0;
	output(outline); output("\n");
	return p+1;
}

void minput (header *hd);

void trace_udfline (char *next)
{	int scan,oldtrace;
	extern header *running;
	header *hd,*res;
	output1("%s: ",running->name); type_udfline(next);
	again: wait_key(&scan);
	switch (scan)
	{	case fk1 :
		case cursor_down :
			break;
		case fk2 :
		case cursor_up :
			trace=2; break;
		case fk3 :
		case cursor_right :
			trace=0; break;
		case fk4 :
		case help :
			hd=(header *)newram;
			oldtrace=trace; trace=0;
			new_string("Expression",12,""); if (error) goto cont;
			minput(hd); if (error) goto cont;
			res=getvalue(hd); if (error) goto cont;
			give_out(res);
			cont : newram=(char *)hd;
			trace=oldtrace;
			goto again;
		case fk9 :
		case escape :
			output("Trace interrupted\n"); error=11010; break;
		case fk10 :
			trace=-1; break;
		default :
			output(
				"\nKeys:\n"
				"F1 (cursor_down)  Single step\n"
				"F2 (cursor_up)    Step over subroutines\n"
				"F3 (cursor_right) Go until return\n"
				"F4 (help)         Evaluate expression\n"
				"F9 (escape)       Abort execution\n"
				"F10               End trace\n\n");
			goto again;
	}
}

void next_line (void)
/**** next_line
	read a line from keyboard or file.
****/
{	if (udfon)
	{	while (*next) next++;
		next++;
		if (*next==1) udfon=0; else udfline=next;
		if (trace>0) trace_udfline(next);
		return;
	}
	else
	{	if (trace==-1) trace=1;
		if (stringon)
		{	error=2300; output("Input ended in string!\n");
			return;
		}
		if (!infile) edit(line);
		else read_line(line);
		next=line;
	}
}

void scan_space (void)
{	start: while (*next==' ' || *next==TAB) next++;
	if (!udfon && *next=='.' && *(next+1)=='.')
		{	next_line(); if (error) return; goto start; }
}

void do_end (void);
void do_loop (void);
void do_repeat (void);
void do_for (void);

void scan_end (void)
/***** scan_end
	scan for "end".
*****/
{	commandtyp *com;
	char *oldline=udfline;
	while (1)
	{	switch (*next)
		{	case 1 : 
				output("End missing!\n");
				error=110; udfline=oldline; return;
			case 0 : udfline=next+1; next++; break;
			case 2 : next+=1+sizeof(double); break;
			case 3 : next++; 
				memmove((char *)(&com),next,sizeof(commandtyp *));
				next+=sizeof(commandtyp *);
				if (com->f==do_end)
				{	if (trace>0) trace_udfline(udfline);
					return;
				}
				else if (com->f==do_repeat || com->f==do_loop ||
					com->f==do_for)
				{	scan_end(); if (error) return; }
				break;
			default : next++;
		}
	}
}

void do_endif (void);
void do_else (void);
void do_if (void);

void scan_endif (void)
/***** scan_endif
	scan for "endif".
*****/
{	commandtyp *com;
	char *oldline=udfline;
	while (1)
	{	switch (*next)
		{	case 1 : 
				output("Endif missing, searching for endif!\n");
				error=110; udfline=oldline; return;
			case 0 : udfline=next+1; next++; break;
			case 2 : next+=1+sizeof(double); break;
			case 3 : next++; 
				memmove((char *)(&com),next,sizeof(commandtyp *));
				next+=sizeof(commandtyp *);
				if (com->f==do_endif)
				{	if (trace>0) trace_udfline(udfline);
					return;
				}
				else if (com->f==do_if)
				{	scan_endif(); if (error) return; }
				break;
			default : next++;
		}
	}
}

void scan_else (void)
/***** scan_else
	scan for "else".
*****/
{	commandtyp *com;
	char *oldline=udfline;
	while (1)
	{	switch (*next)
		{	case 1 : 
				output("Endif missing, searching for else!\n");
				error=110; udfline=oldline; return;
			case 0 : udfline=next+1; next++; break;
			case 2 : next+=1+sizeof(double); break;
			case 3 : next++; 
				memmove((char *)(&com),next,sizeof(commandtyp *));
				next+=sizeof(commandtyp *);
				if (com->f==do_endif || com->f==do_else)
				{	if (trace>0) trace_udfline(udfline);
					return;
				}
				else if (com->f==do_if)
				{	scan_endif(); if (error) return; }
				break;
			default : next++;
		}
	}
}

void scan_name (char *name)
{	int count=0;
	if (!isalpha(*next))
	{	error=11; *name=0; return;
	}
	while (isalpha(*next) || isdigit(*next))
	{	*name++=*next++; count++;
		if (count>=15)
		{	output("Name to long!\n");
			error=11; break;
		}
	}
	*name=0;
}

void getmatrix (header *hd, int *r, int *c, double **m)
/***** getmatrix
	get rows and columns from a matrix.
*****/
{	dims *d;
	if (hd->type==s_real || hd->type==s_complex)
	{	*r=*c=1;
		*m=realof(hd);
	}
	else
	{	d=dimsof(hd);
		*m=matrixof(hd);
		*r=d->r; *c=d->c;
	}
}

header *searchvar (char *name)
/***** searchvar
	search a local variable, named "name".
	return 0, if not found.
*****/
{	int r;
	header *hd=(header *)startlocal;
	r=xor(name);
	while ((char *)hd<endlocal)
	{	if (r==hd->xor && !strcmp(hd->name,name)) return hd;
		hd=nextof(hd);
	}
	return 0;
}

header *searchudf (char *name)
/***** searchudf
	search a udf, named "name".
	return 0, if not found.
*****/
{	header *hd;
	int r;
	r=xor(name);
	hd=(header *)ramstart;
	while ((char *)hd<udfend && hd->type==s_udf)
	{	if (r==hd->xor && !strcmp(hd->name,name)) return hd;
		hd=nextof(hd);
	}
	return 0;
}

void kill_local (char *name)
/***** kill_local
	kill a loal variable name, if there is one.
*****/
{	size_t size,rest;
	header *hd=(header *)startlocal;
	while ((char *)hd<endlocal)
	{	if (!strcmp(hd->name,name)) /* found! */
		{	size=hd->size;
			rest=newram-(char *)hd-size;
			if (size) memmove((char *)hd,(char *)hd+size,rest);
			endlocal-=size; newram-=size;
			return;
		}
		hd=(header *)((char *)hd+hd->size);
	}
}

void kill_udf (char *name)
/***** kill_udf
	kill a local variable name, if there is one.
*****/
{	size_t size,rest;
	header *hd=(header *)ramstart;
	while ((char *)hd<udfend)
	{	if (!strcmp(hd->name,name)) /* found! */
		{	size=hd->size;
#ifndef SPLIT_MEM
			rest=newram-(char *)hd-size;
			if (size && rest) memmove((char *)hd,(char *)hd+size,rest);
			endlocal-=size; startlocal-=size; newram-=size;
#else
			rest=udfend-(char *)hd-size;
			if (size && rest) memmove((char *)hd,(char *)hd+size,rest);
#endif
			udfend-=size;
			return;
		}
		hd=(header *)((char *)hd+hd->size);
	}
}

int sametype (header *hd1, header *hd2)
/***** sametype
	returns true, if hd1 and hd2 have the same type and dimensions.
*****/
{	dims *d1,*d2;
	if (hd1->type!=hd2->type || hd1->size!=hd2->size) return 0;
	if (hd1->type==s_matrix)
	{	d1=dimsof(hd1); d2=dimsof(hd2);
			if (d1->r!=d2->r) return 0;
	}
	return 1;
}

header *assign (header *var, header *value)
/***** assign
	assign the value to the variable.
*****/
{	char name[16],*nextvar;
	size_t size,dif;
	double *m,*mv,*m1,*m2;
	int i,j,c,r,cv,rv,*rind,*cind;
	dims *d;
	header *help,*orig;
	if (error) return 0;
	size=value->size;
	if (var->type==s_reference && !referenceof(var))
		/* seems to be a new variable */
	{	strcpy(name,var->name);
		if (value->type==s_udf)
		{	strcpy(value->name,name);
			value->xor=xor(name);
#ifndef SPLIT_MEM
			if (newram+size>ramend)
			{	output("Memory overflow.\n"); error=500; return value;
			}
			memmove(ramstart+size,ramstart,newram-ramstart);
			newram+=size; endlocal+=size; startlocal+=size;
			value=(header *)((char *)value+size);
#else
			if (udfend+size>udframend)
			{	output("Memory overflow.\n"); error=500; return value;
			}
			memmove(ramstart+size,ramstart,udfend-ramstart);
#endif
			udfend+=size;
			memmove(ramstart,(char *)value,size);
			return (header *)ramstart;
		}
		memmove(endlocal+size,endlocal,newram-endlocal);
		value=(header *)((char *)value+size);
		newram+=size;
		memmove(endlocal,(char *)value,size);
		strcpy(((header *)endlocal)->name,name);
		((header *)endlocal)->xor=xor(name);
		value=(header *)endlocal;
		endlocal+=size;
		return value;
	}
	else
	{	while (var && var->type==s_reference) var=referenceof(var);
		if (!var)
		{	error=43; output("Internal variable error!\n"); return 0;
		}
		if (var->type!=s_udf && value->type==s_udf)
		{	output("Cannot assign a UDF to a variable!\n"); error=320;
			return var;
		}
		if (var->type==s_submatrix)
		{	d=submdimsof(var);
			if (value->type==s_complex || value->type==s_cmatrix)
			{	orig=submrefof(var);
				help=new_reference(orig,""); 
				if (error) return 0;
					mcomplex(help); if (error) return 0;
				var->type=s_csubmatrix;
				submrefof(var)=help;
				assign(var,value); if (error) return 0;
				submrefof(var)=orig;
				assign(orig,help); 
				return orig;
			}
			else if (value->type!=s_real && value->type!=s_matrix)
			{	output("Illegal assignment!\n"); error=45; return 0;
			}
			getmatrix(value,&rv,&cv,&mv);
			getmatrix(submrefof(var),&r,&c,&m);
			if (d->r!=rv || d->c!=cv)
			{	output("Illegal assignment!\n"); error=45; return 0;
			}
			rind=rowsof(var); cind=colsof(var);
			for (i=0; i<d->r; i++)
			{	m1=mat(m,c,rind[i],0);
				m2=mat(mv,cv,i,0);
				for (j=0; j<d->c; j++)
				{	m1[cind[j]]=*m2++;
				}
			}
			return submrefof(var);
		}
		else if (var->type==s_csubmatrix)
		{	d=submdimsof(var);
			if (value->type==s_real || value->type==s_matrix)
			{	help=new_reference(value,""); if (error) return 0;
				mcomplex(help); if (error) return 0;
				assign(var,help);
				return submrefof(var);
			}
			if (value->type!=s_complex && value->type!=s_cmatrix)
			{	output("Illegal assignment!\n"); error=45; return 0;
			}
			getmatrix(value,&rv,&cv,&mv);
			getmatrix(submrefof(var),&r,&c,&m);
			if (d->r!=rv || d->c!=cv)
			{	output("Illegal assignment!\n"); error=45; return 0;
			}
			rind=rowsof(var); cind=colsof(var);
			for (i=0; i<d->r; i++)
			{	m1=cmat(m,c,rind[i],0);
				m2=cmat(mv,cv,i,0);
				for (j=0; j<d->c; j++)
                {   copy_complex(m1+(LONG)2*cind[j],m2); m2+=2;
				}
			}
			return submrefof(var);
		}		
		else 
		{	if ((char *)var<startlocal || (char *)var>endlocal) 
			/* its not a local variable! */
			{	if (!sametype(var,value))
				{	output1("Cannot change type of non-local variable %s!\n",
						var->name);
					error=12; return 0;
				}
				memcpy((char *)(var+1),(char *)(value+1),
					value->size-sizeof(header));
				return var;
			}
			dif=value->size-var->size;
			if (newram+dif>ramend)
			{	output("Memory overflow\n"); error=501; return value;
			}
			nextvar=(char *)var+var->size;
			if (dif!=0)
				memmove(nextvar+dif,nextvar,newram-nextvar);
			newram+=dif; endlocal+=dif;
			value=(header *)((char *)value+dif);
			strcpy(value->name,var->name);
			value->xor=var->xor;
			memmove((char *)var,(char *)value,value->size);
		}
	}
	return var;
}

header *next_param (header *hd)
/***** next_param
	get the next value on stack, if there is one
*****/
{	hd=(header *)((char *)hd+hd->size);
	if ((char *)hd>=newram) return 0;
	else return hd;
}

/********************* interpreter **************************/

void double_out (double x)
/***** double_out
	print a double number.
*****/
{	if ((fabs(x)>maxexpo || fabs(x)<minexpo) && x!=0.0) 
		output1(expoformat,x);
	else if (x==0.0) output1(fixedformat,0.0); /* take care of -0 */
	else output1(fixedformat,x);
}

void out_matrix (header *hd)
/***** out_matrix
   print a matrix.
*****/
{	int c,r,i,j,c0,cend;
	double *m,*x;
	getmatrix(hd,&r,&c,&m);
	for (c0=0; c0<c; c0+=linew)
	{	cend=c0+linew-1; 
		if (cend>=c) cend=c-1;
		if (c>linew) output2("Column %d to %d:\n",c0+1,cend+1);
		for (i=0; i<r; i++)
		{	x=mat(m,c,i,c0);
			for (j=c0; j<=cend; j++) double_out(*x++);
			output("\n");
			if (test_key()==escape) return;
		}
	}
}

void complex_out (double x, double y)
/***** double_out
	print a complex number.
*****/
{	if ((fabs(x)>maxexpo || fabs(x)<minexpo) && x!=0.0) 
		output1(expoformat,x);
	else output1(fixedformat,x);
	output("+");
	if ((fabs(y)>maxexpo || fabs(y)<minexpo) && y!=0.0) 
		output1(expoformat,y);
	else output1(fixedformat,y);
	output("i ");
}

void out_cmatrix (header *hd)
/***** out_matrix
   print a complex matrix.
*****/
{	int c,r,i,j,c0,cend;
	double *m,*x;
	getmatrix(hd,&r,&c,&m);
	for (c0=0; c0<c; c0+=linew/2)
	{	cend=c0+linew/2-1; 
		if (cend>=c) cend=c-1;
		if (c>linew/2) output2("Column %d to %d:\n",c0+1,cend+1);
		for (i=0; i<r; i++)
		{	x=cmat(m,c,i,c0);
			for (j=c0; j<=cend; j++) { complex_out(*x,*(x+1)); 
				x+=2; }
			output("\n");
			if (test_key()==escape) return;
		}
	}
}

void give_out (header *hd)
/***** give_out
	print a value.
*****/
{	switch(hd->type)
	{	case s_real : double_out(*realof(hd)); output("\n"); break;
		case s_complex : complex_out(*realof(hd),*(realof(hd)+1));
			output("\n"); break;
		case s_matrix : out_matrix(hd); break;
		case s_cmatrix : out_cmatrix(hd); break;
		case s_string : output(stringof(hd)); output("\n"); break;
		default : output("?\n");
	}
}

/***************** some builtin commands *****************/

void load_file (void)
/***** load_file
	inerpret a file.
*****/
{	header *filename;
	char oldline[1024],fn[256],*oldnext;
	FILE *oldinfile;
	filename=scan_value(); if (error) return;
	if (filename->type!=s_string)
	{	output("Illegal filename!\n"); error=52; return;
	}
	if (udfon)
	{	output("Cannot load a file in a function!\n");
		error=221; return;
	}
	oldinfile=infile;
	infile=fopen(stringof(filename),"r");
	if (!infile)
	{	strcpy(fn,stringof(filename));
		strcat(fn,EXTENSION);
		infile=fopen(fn,"r");
		if (!infile)
		{	output1("Could not open %s!\n",stringof(filename));
			error=53; infile=oldinfile; return;
		}
	}
	strcpy(oldline,line); oldnext=next;
	*line=0; next=line;
	while (!error && infile && !quit) command();
	if (infile) fclose(infile);
	infile=oldinfile;
	strcpy(line,oldline); next=oldnext;
}

commandtyp *preview_command (size_t *l);

void get_udf (void)
/***** get_udf
	define a user defined function.
*****/
{	char name[16],argu[16],*p,*firstchar,*startp;
	int *ph,*phh,count=0,n;
	size_t l;
	header *var,*result,*hd;
	FILE *actfile=infile;
	commandtyp *com;
	double x;
	if (udfon==1)
	{	output("Cannot define a function in a function!\n");
		error=60; return;
	}
	scan_space(); scan_name(name); if (error) return;
	kill_udf(name);
	var=new_reference(0,name); if (error) return;
	result=new_udf(""); if (error) return;
	p=udfof(result); udf=1; /* udf is for the prompt! */
	scan_space(); 
	ph=(int *)p; p+=sizeof(int);
	if (*next=='(')
	{	while(1)
		{	next++;
			scan_space();
			if (*next==')') break;
			phh=(int *)p; *phh=0; p+=sizeof(int);
			scan_name(argu); if (error) goto aborted;
			count++;
			strcpy(p,argu); p+=16; 
			*((int *)p)=xor(argu); p+=sizeof(int);
			test: scan_space();
			if (*next==')') break;
			else if (*next=='=')
			{	next++;
				*phh=1;
				newram=p;
				hd=(header *)p;
				scan_value(); if (error) goto aborted;
				strcpy(hd->name,argu);
				hd->xor=xor(argu);
				p=newram;
				goto test;
			}
			else if (*next==',') continue;
			else 
			{	output("Error in parameter list!\n"); error=701;
				goto aborted;
			}
		}
		next++;
	}
	*ph=count;
	if (*next==0) { next_line(); }
	while (1) /* help section of the udf */
	{	if (*next=='#' && *(next+1)=='#')
		{	while (*next)
			{	*p++=*next++;
				if (p>=ramend)
				{	output("Memory overflow!\n"); error=210; goto stop;
				}
			}
			*p++=0; next_line();
		}
		else break;
		if (actfile!=infile)
		{	output("End of file reached in function definition!\n");
			error=2200; goto stop;
		}
	}
	*udfstartof(result)=(p-(char *)result);
	startp=p;
	firstchar=next;
	while (1)
	{	if (error) goto stop;
		if (!strncmp(next,"endfunction",strlen("endfunction")))
		{	if (p==startp || *(p-1)) *p++=0;
			*p++=1; next+=strlen("endfunction"); break;
		}
		if (actfile!=infile)
		{	output("End of file reached in function definition!\n");
			error=2200; goto stop;
		}
		if (*next=='#' && *(next+1)=='#')
		{	*p++=0; next_line(); firstchar=next;
		}
		else 
		if (*next) 
		{	if (*next=='"')
			{	*p++=*next++;
				while (*next!='"' && *next) *p++=*next++;
				if (*next=='"') *p++=*next++;
			}
			else if (isdigit(*next) || 
				     	(*next=='.' && isdigit(*(next+1))) )
			{	if (next!=firstchar && isalpha(*(next-1)))
				{	*p++=*next++;
					while (isdigit(*next)) *p++=*next++;
				}
				else
				{
					if ((p-(char *)result)%2==0) *p++=' ';
					*p++=2;
		   			sscanf(next,"%lg%n",&x,&n);
		   			next+=n;
		   			memmove(p,(char *)(&x),sizeof(double));
		   			p+=sizeof(double);
			   	}
			}
			else if (isalpha(*next) &&
				(next==firstchar || !isalpha(*(next-1))) &&
				(com=preview_command(&l))!=0)
			/* Try to find a builtin command */
			{	
				if ((p-(char *)result)%2==0) *p++=' ';
				*p++=3;
				memmove(p,(char *)(&com),sizeof(commandtyp *));
				p+=sizeof(commandtyp *);
				next+=l;
			}
			else if (*next=='.' && *(next+1)=='.')
			{	*p++=' '; next_line(); firstchar=next;
			}
			else *p++=*next++;
		}
		else { *p++=0; next_line(); firstchar=next; }
		if (p>=ramend-80)
		{	output("Memory overflow!\n"); error=210; goto stop;
		}
	}
	stop:
	udf=0; if (error) return;
	result->size=((p-(char *)result)/2+1)*2;
#ifdef SPECIAL_ALIGNMENT
	result->size=((result->size-1)/8+1)*8;
#endif
	newram=(char *)result+result->size;
	assign(var,result);
	aborted:
	udf=0;
}

void do_return (void)
{	if (!udfon)
	{	output("No user defined function active!\n");
		error=56; return;
	}
	else udfon=2;
}

void do_break (void)
{	if (!udfon)
	{	output("End only allowed in functions!\n"); error=57;
	}
}

void do_for (void)
/***** do_for
	do a for command in a UDF.
	for i=value to value step value; .... ; end
*****/
{	int h,signum;
	char name[16],*jump;
	header *hd,*init,*end,*step;
	double vend,vstep;
	struct { header hd; double value; } rv;
	if (!udfon)
	{	output("For only allowed in functions!\n"); error=57; return;
	}
	rv.hd.type=s_real; *rv.hd.name=0;
	rv.hd.size=sizeof(header)+sizeof(double); rv.value=0.0;
	scan_space(); scan_name(name); if (error) return;
	kill_local(name);
	newram=endlocal;
	hd=new_reference(&rv.hd,name); if (error) return;
	endlocal=newram=(char *)hd+hd->size;
	scan_space(); if (*next!='=')
	{	output("Syntax error in for.\n"); error=71; goto end;
	}
	next++; init=scan(); if (error) goto end;
	init=getvalue(init); if (error) goto end;
	if (init->type!=s_real)
	{	output("Startvalue must be real!\n"); error=72; goto end;
	}
	rv.value=*realof(init);
	scan_space(); if (strncmp(next,"to",2))
	{	output("Endvalue missing in for!\n"); error=73; goto end;
	}
	next+=2;
	end=scan(); if (error) goto end;
	end=getvalue(end); if (error) goto end;
	if (end->type!=s_real)
	{	output("Endvalue must be real!\n"); error=73; goto end;
	}
	vend=*realof(end);
	scan_space(); 
	if (!strncmp(next,"step",4))
	{	next+=4;
		step=scan(); if (error) goto end;
		step=getvalue(step); if (error) goto end;
		if (step->type!=s_real)
		{	output("Stepvalue must be real!\n"); error=73; goto end;
		}
		vstep=*realof(step);
	}
	else vstep=1.0;
	signum=(vstep>0);
	if (signum && rv.value>vend) { scan_end(); goto end; }
	else if (!signum && rv.value<vend) { scan_end(); goto end; }
	newram=endlocal;
	scan_space(); if (*next==';' || *next==',') next++;
	jump=next;
	vend=vend+epsilon*vstep;
	while (!error)
	{	if (*next==1)
		{	output("End missing!\n");
			error=401; goto end;
		}
		h=command();
		if (h==c_return) break;
		if (h==c_break) { scan_end(); break; }
		if (h==c_end)
		{	rv.value+=vstep;
			if (signum==1 && rv.value>vend) break;
			else if (!signum && rv.value<vend) break;
			else next=jump;
			if (test_key()==escape) { error=1; break; }
		}
	}
	end : kill_local(name);
}

void do_loop (void)
/***** do_loop
	do a loop command in a UDF.
	loop value to value; .... ; end
*****/
{	int h;
	char *jump;
	header *init,*end;
	long vend,oldindex;
	if (!udfon)
	{	output("Loop only allowed in functions!\n"); error=57; return;
	}
	init=scan(); if (error) return;
	init=getvalue(init); if (error) return;
	if (init->type!=s_real)
	{	output("Startvalue must be real!\n"); error=72; return;
	}
	oldindex=loopindex;
	loopindex=(long)*realof(init);
	scan_space(); if (strncmp(next,"to",2))
	{	output("Endvalue missing in for!\n"); error=73; goto end;
	}
	next+=2;
	end=scan(); if (error) goto end;
	end=getvalue(end); if (error) goto end;
	if (end->type!=s_real)
	{	output("Endvalue must be real!\n"); error=73; goto end;
	}
	vend=(long)*realof(end);
	if (loopindex>vend) { scan_end(); goto end; }
	newram=endlocal;
	scan_space(); if (*next==';' || *next==',') next++;
	jump=next;
	while (!error)
	{	if (*next==1)
		{	output("End missing!\n");
			error=401; goto end;
		}
		h=command();
		if (h==c_return) break;
		if (h==c_break) { scan_end(); break; }
		if (h==c_end)
		{	loopindex++;
			if (loopindex>vend) break;
			else next=jump;
			if (test_key()==escape) { error=1; break; }
		}
	}
	end : loopindex=oldindex;
}

void do_repeat (void)
/***** do_loop
	do a loop command in a UDF.
	for value to value; .... ; endfor
*****/
{	int h;
	char *jump;
	if (!udfon)
	{	output("Loop only allowed in functions!\n"); error=57; return;
	}
	newram=endlocal;
	scan_space(); if (*next==';' || *next==',') next++;
	jump=next;
	while (!error)
	{	if (*next==1)
		{	output("End missing!\n");
			error=401; break;
		}
		h=command();
		if (h==c_return) break;
		if (h==c_break) { scan_end(); break; }
		if (h==c_end)
		{	next=jump;
			if (test_key()==escape) { error=1; break; }
		}
	}
}

void do_end (void)
{	if (!udfon)
	{	output("End only allowed in functions!\n"); error=57;
	}
}

void do_else (void)
{	if (!udfon)
	{	output("Else only allowed in functions!\n"); error=57; return;
	}
	scan_endif();
}

void do_endif (void)
{	if (!udfon)
	{	output("Endif only allowed in functions!\n"); error=57;
	}
}

int ctest (header *hd)
/**** ctest
	test, if a matrix contains nonzero elements.
****/
{	double *m;
	LONG n,i;
	hd=getvalue(hd); if (error) return 0;
	if (hd->type==s_string) return (*stringof(hd)!=0);
	if (hd->type==s_real) return (*realof(hd)!=0.0);
	if (hd->type==s_complex) return (*realof(hd)!=0.0 &&
		*imagof(hd)!=0.0);
	if (hd->type==s_matrix)
	{	n=(LONG)(dimsof(hd)->r)*dimsof(hd)->c;
		m=matrixof(hd);
		for (i=0; i<n; i++) if (*m++==0.0) return 0;
		return 1;
	}
	if (hd->type==s_cmatrix)
	{	n=(LONG)(dimsof(hd)->r)*dimsof(hd)->c;
		m=matrixof(hd);
		for (i=0; i<n; i++) 
		{	if (*m==0.0 && *m==0.0) return 0; m+=2; }
		return 1;
	}
	return 0;
}

void do_if (void)
{	header *cond;
	int flag;
	if (!udfon)
	{	output("If only allowed in functions!\n"); error=111; return;
	}
	cond=scan(); if (error) return;
	flag=ctest(cond); if (error) return;
	if (!flag) scan_else();
}

void do_clg (void)
{	graphic_mode(); clear_graphics(); gflush();
}

void do_cls (void)
{	text_mode(); clear_screen();
}

void do_clear (void)
{	if (udfon)
	{	output("Cannot clear in a function!\n");
		error=120; return;
	}
	clear();
}

void do_quit (void)
{	quit=1;
}

void do_exec (void)
{	header *name;
	char *s;
	name=scan_value(); if (error) return;
	if (name->type!=s_string)
	{	output("Cannot execute a number or matrix!\n");
		error=130; return;
	}
	s=stringof(name);
	while (*s && !isspace(*s)) s++;
	if (*s) *s++=0;
	if (execute(stringof(name),s))
	{	output("Execution failed or program returned a failure!\n");
		error=131;
	}
}

void do_forget (void)
{	char name[16];
	header *hd;
	int r;
	if (udfon)
	{	output("Cannot forget functions in a function!\n");
		error=720; return;
	}
	while (1)
	{	scan_space();
		scan_name(name);
		r=xor(name);
		hd=(header *)ramstart;
		while ((char *)hd<udfend)
		{	if (r==hd->xor && !strcmp(hd->name,name)) break;
			hd=nextof(hd);
		}
		if ((char *)hd>=udfend)
		{	output1("Function %s not found!\n",name);
			error=160; return;
		}
		kill_udf(name);
		scan_space();
		if (*next!=',') break;
		else next++;
	}
}

void do_global (void)
{	char name[16];
	int r;
	header *hd;
	while (1)
	{	scan_space(); scan_name(name); r=xor(name);
#ifdef SPLIT_MEM
		hd=(header *)varstart;
#else
		hd=(header *)udfend;
#endif
		if (hd==(header *)startlocal) break;
		while ((char *)hd<startlocal)
		{	if (r==hd->xor && !strcmp(hd->name,name)) break;
			hd=nextof(hd);
		}
		if ((char *)hd>=startlocal)
		{	output1("Variable %s not found!\n",name);
			error=160; return;
		}
		newram=endlocal;
		hd=new_reference(hd,name);
		newram=endlocal=(char *)nextof(hd);
		scan_space();
		if (*next!=',') break;
		else next++;
	}
}

void print_commands (void);

void do_list (void)
{	header *hd;
	int lcount=0;
	output("  *** Builtin functions:\n");
	print_builtin();
	output("  *** Commands:\n");
	print_commands();
	output("  *** Your functions:\n");
	hd=(header *)ramstart;
	while ((char *)hd<udfend)
	{	if (hd->type!=s_udf) break;
		if (lcount+(int)strlen(hd->name)+2>=linelength) 
			{ lcount=0; output("\n"); }
		output1("%s ",hd->name);
		lcount+=(int)strlen(hd->name)+1; 
		hd=nextof(hd);
	}
	output("\n");
}

void do_type (void)
{	char name[16];
	header *hd;
	char *p,*pnote;
	int i,count,defaults;
	scan_space();
	scan_name(name); hd=searchudf(name);
	if (hd && hd->type==s_udf)
	{	output1("function %s (",name);
		p=helpof(hd);
		count=*((int *)p);
		p+=sizeof(int);
		pnote=p;
		for (i=0; i<count; i++)
		{	defaults=*(int *)p; p+=sizeof(int);
			output1("%s",p);
			p+=16+sizeof(int);
			if (defaults)
			{	output("=...");
				p=(char *)(nextof((header *)p));
			}
			if (i!=count-1) output(",");
		}
		output(")\n");
		p=pnote;
		for (i=0; i<count; i++)
		{	defaults=*(int *)p; p+=sizeof(int);
			if (defaults) output1("## Default for %s :\n",p);
			p+=16+sizeof(int);
			if (defaults)
			{	give_out((header *)p);
				p=(char *)nextof((header *)p);
			}
		}		
		p=udfof(hd);
		while (*p!=1 && p<(char *)nextof(hd))
			p=type_udfline(p);
		output("endfunction\n");
	}
	else
	{	output("No such function!\n"); error=173;
	}
}

void do_help (void)
{	char name[16];
	header *hd;
	int count,i,defaults;
	char *p,*end,*pnote;
	scan_space();
	scan_name(name); hd=searchudf(name);
	if (hd && hd->type==s_udf)
	{	output1("function %s (",name);
		end=udfof(hd);
		p=helpof(hd);
		count=*((int *)p);
		p+=sizeof(int);
		pnote=p;
		for (i=0; i<count; i++)
		{	defaults=*(int *)p; p+=sizeof(int);
			output1("%s",p);
			p+=16+sizeof(int);
			if (defaults)
			{	output("=...");
				p=(char *)nextof((header *)p);
			}
			if (i!=count-1) output(",");
		}
		output(")\n");
		p=pnote;
		for (i=0; i<count; i++)
		{	defaults=*(int *)p; p+=sizeof(int);
			if (defaults) output1("## Default for %s :\n",p);
			p+=16+sizeof(int);
			if (defaults)
			{	give_out((header *)p);
				p=(char *)nextof((header *)p);
			}
		}		
		while (*p!=1 && p<end)
		{	output(p); output("\n");
			p+=strlen(p); p++;
		}
	}
	else
	{	output("\n\n Help needs a function name ,e.g.:"
			"\n >help shortformat\n"
			" You can get a list of all functions with\n >list\n\n"
			" If you need online help for builtin functions enter:\n"
			" >load \"help\""
			"\n\n To run a demo use:\n >load \"demo\"\n >demo()\n"
			"\n >quit\n quits this program.\n\n");
	}
}

void do_dump (void)
{	header *file;
	if (outfile)
	{	if (fclose(outfile))
		{	output("Error while closing dumpfile.\n");
		}
		outfile=0;
	}
	scan_space();
	if (*next==';' || *next==',' || *next==0)
	{	if (*next) next++; return; }
	file=scan_value();
	if (error || file->type!=s_string)
	{	output("Dump needs a filename!\n");
		error=201; return;
	}
	outfile=fopen(stringof(file),"a");
	if (!outfile)
	{	output1("Could not open %s.\n",stringof(file));
	}
}

void do_meta (void)
{	header *file;
	if (metafile)
	{	if (fclose(metafile))
		{	output("Error while closing metafile.\n");
		}
		metafile=0;
	}
	scan_space();
	if (*next==';' || *next==',' || *next==0)
	{	if (*next) next++; return; }
	file=scan_value();
	if (error || file->type!=s_string)
	{	output("Meta needs a filename!\n");
		error=201; return;
	}
	metafile=fopen(stringof(file),"ab");
	if (!metafile)
	{	output1("Could not open %s.\n",stringof(file));
	}
}

void do_remove (void)
{	header *file;
	file=scan_value();
	if (error || file->type!=s_string)
	{	output("Remove needs a string!\n");
		error=202; return;
	}
	remove(stringof(file));
}

void do_do (void)
{	int udfold;
	char name[16];
	char *oldnext=next,*udflineold;
	header *var;
	scan_space(); scan_name(name); if (error) return;
	var=searchudf(name);
	if (!var || var->type!=s_udf)
	{	output("Need a udf!\n"); error=220; return;
	}
	udflineold=udfline; udfline=next=udfof(var); udfold=udfon; udfon=1;
	while (!error && udfon==1)
	{	command();
		if (udfon==2) break;
		if (test_key()==escape) 
		{	output("User interrupted!\n"); error=58; break; 
		}
	}
	if (error) output1("Error in function %s\n",var->name);
	if (udfon==0)
	{	output1("Return missing in %s!\n",var->name); error=55; }
	udfon=udfold; udfline=udflineold;
	if (udfon) next=oldnext;
	else { next=line; *next=0; }
}

void do_mdump (void)
{	header *hd;
#ifndef SPLIT_MEM
	output1("ramstart : 0\nstartlocal : %ld\n",startlocal-ramstart);
	output1("endlocal : %ld\n",endlocal-ramstart);
	output1("newram   : %ld\n",newram-ramstart);
	output1("ramend   : %ld\n",ramend-ramstart);
#else
	output1("ramstart : 0\nstartlocal : %ld\n",startlocal-varstart);
	output1("endlocal : %ld\n",endlocal-varstart);
	output1("newram   : %ld\n",newram-varstart);
	output1("ramend   : %ld\n",ramend-varstart);
#endif
	hd=(header *)ramstart;
#ifdef SPLIT_MEM
	while ((char *)hd<udfend)
	{
		output1("%6ld : %16s, ",(char *)hd-ramstart,hd->name);
		output1("size %6ld ",(long)hd->size);
		output1("type %d\n",hd->type);
		hd=nextof(hd);
	}
	hd=(header *)varstart;
#endif
	while ((char *)hd<newram)
	{
#ifndef SPLIT_MEM
		output1("%6ld : %16s, ",(char *)hd-ramstart,hd->name);
#else
		output1("%6ld : %16s, ",(char *)hd-varstart,hd->name);
#endif
		output1("size %6ld ",(long)hd->size);
		output1("type %d\n",hd->type);
		hd=nextof(hd);
	}
}

void hex_out1 (int n)
{	if (n<10) output1("%c",n+'0');
	else output1("%c",n-10+'A');
}

void hex_out (unsigned int n)
{	hex_out1(n/16);
	hex_out1(n%16);
	output(" ");
}

void string_out (unsigned char *p)
{	int i;
	unsigned char a;
	for (i=0; i<16; i++) 
	{	a=*p++;
		output1("%c",(a<' ')?'_':a);
	}
}

void do_hexdump (void)
{	char name[16];
	unsigned char *p,*end;
	int i=0,j;
	size_t count=0;
	header *hd;
	scan_space(); scan_name(name); if (error) return;
	hd=searchvar(name);
	if (!hd) hd=searchudf(name);
	if (error || hd==0) return;
	p=(unsigned char *)hd; end=p+hd->size;
	output1("\n%5lx ",count);
	while (p<end)
	{	hex_out(*p++); i++; count++;
		if (i>=16) 
		{	i=0; string_out(p-16);
			output1("\n%5lx ",count);
			if (test_key()==escape) break;
		}
	}
	for (j=i; j<16; j++) output("   ");
	string_out(p-i);
	output("\n");
}

void do_output (void)
/**** do_output
	toggles output.
****/
{	scan_space();
	if (!strncmp(next,"off",3))
	{	outputing=0; next+=3;
	}
	else if (!strncmp(next,"on",2))
	{	outputing=1; output("\n"); next+=2;
	}
	else outputing=!outputing;
}

void do_comment (void)
{	FILE *fp=infile;
	if (!fp || udfon)
	{	output("comment illegal at this place");
		error=1001; return;
	}
	while (strncmp(next,"endcomment",10)!=0)
	{	next_line();
		if (infile!=fp)
		{	output("endcomment missing!\n"); error=1002;
			return;
		}
	}
	next_line();
}

void do_trace(void)
/**** do_trace
	toggles tracing or sets the trace bit of a udf.
****/
{	header *f;
	char name[64];
	scan_space();
	if (!strncmp(next,"off",3))
	{	trace=0; next+=3;
	}
	else if (!strncmp(next,"alloff",6))
	{	next+=6;
		f=(header *)ramstart;
		while ((char *)f<udfend && f->type==s_udf)
		{	f->flags&=~1;
			f=nextof(f);
		}
		trace=0;
	}	
	else if (!strncmp(next,"on",2))
	{	trace=1; next+=2;
	}
	else if (*next==';' || *next==',' || *next==0) trace=!trace;
	else
	{	if (*next=='"') next++;
		scan_name(name); if (error) return;
		if (*next=='"') next++;
		f=searchudf(name);
		if (!f || f->type!=s_udf)
		{	output("Function not found!\n");
			error=11021; return;
		}
		f->flags^=1;
		if (f->flags&1) output1("Tracing %s\n",name);
		else output1("No longer tracing %s\n",name);
		scan_space();
	}
	if (*next==';' || *next==',') next++;
}

int command_count;

commandtyp command_list[] =
	{{"quit",c_quit,do_quit},
	 {"hold",c_hold,ghold},
	 {"shg",c_shg,show_graphics},
	 {"load",c_load,load_file},
	 {"function",c_udf,get_udf},
	 {"return",c_return,do_return},
	 {"for",c_for,do_for},
	 {"endif",c_endif,do_endif},
	 {"end",c_end,do_end},
	 {"break",c_break,do_break},
	 {"loop",c_loop,do_loop},
	 {"else",c_else,do_else},
	 {"if",c_if,do_if},
	 {"repeat",c_repeat,do_repeat},
	 {"clear",c_clear,do_clear},
	 {"clg",c_clg,do_clg},
	 {"cls",c_cls,do_cls},
	 {"exec",c_exec,do_exec},
	 {"forget",c_forget,do_forget},
	 {"global",c_global,do_global},
	 {"list",c_global,do_list},
	 {"type",c_global,do_type},
	 {"dump",c_global,do_dump},
	 {"remove",c_global,do_remove},
	 {"help",c_global,do_help},
	 {"do",c_global,do_do},
	 {"memorydump",c_global,do_mdump},
	 {"hexdump",c_global,do_hexdump},
	 {"output",c_global,do_output},
	 {"meta",c_global,do_meta},
	 {"comment",c_global,do_comment},
	 {"trace",c_global,do_trace},
	 {0,0,0} };

void print_commands (void)
{	int linel=0,i;
	for (i=0; i<command_count; i++)
	{	if (linel+strlen(command_list[i].name)+2>linelength)
			{ output("\n"); linel=0; }
		output1("%s ",command_list[i].name);
		linel+=(int)strlen(command_list[i].name)+1;
	}
	output("\n");
}

int command_compare (const commandtyp *p1, const commandtyp *p2)
{	return strcmp(p1->name,p2->name);
}

void sort_command (void)
{	command_count=0;
	while (command_list[command_count].name) command_count++;
	qsort(command_list,command_count,sizeof(commandtyp),
		(int (*)(const void *, const void *))command_compare);
}

commandtyp *preview_command (size_t *l)
{	commandtyp h;
	char name[16],*a,*n;
	*l=0;
	a=next; n=name;
	while (*l<15 && isalpha(*a)) { *n++=*a++; *l+=1; }
	*n++=0; if (isalpha(*a)) return 0;
	h.name=name;
	return bsearch(&h,command_list,command_count,sizeof(commandtyp),
		(int (*)(const void *, const void *))command_compare);
}

int builtin (void)
/***** builtin
	interpret a builtin command, number no.
*****/
{	size_t l;
	commandtyp *p;
	if (*next==3)
	{	next++;
#ifdef SPECIAL_ALIGNMENT
		memmove((char *)(&p),next,sizeof(commandtyp *));
#else
		p=*((commandtyp **)next);
#endif
		l=sizeof(commandtyp *);
	}
	else if (udfon) return 0;
	else p=preview_command(&l);
	if (p)
	{	next+=l;
		p->f();
		if (*next==';' || *next==',') next++;
		commandtype=p->nr;
		return 1;
	}
	return 0;
}

header *scan_expression (void)
/***** scan_expression
	scans a variable, a value or a builtin command.
*****/
{	if (builtin()) return &commandheader;
	return scan();
}

#define addsize(hd,size) ((header *)((char *)(hd)+size))

void do_assignment (header *var)
/***** do_assignment
	assign a value to a variable.
*****/
{	header *variable[8],*rightside[8],*rs,*v,*mark;
	int rscount,varcount,i,j;
	size_t offset,oldoffset,dif;
	char *oldendlocal;
	scan_space();
	if (*next=='=')
	{	next++;
		nosubmref=1; rs=scan_value(); nosubmref=0;
		if (error) return;
		varcount=0;
		/* count the variables, that get assigned something */
		while (var<rs)
		{	if (var->type!=s_reference && var->type!=s_submatrix
				&& var->type!=s_csubmatrix)
			{	output("Illegal assignment!\n");
				error=210;
			}
			variable[varcount]=var; var=nextof(var); varcount++;
			if (varcount>=8)
			{	output("To many commas!\n"); error=100; return;
			}
		}
		/* count and note the values, that are assigned to the
			variables */
		rscount=0;
		while (rs<(header *)newram)
		{	rightside[rscount]=rs;
			rs=nextof(rs); rscount++;
			if (rscount>=8)
			{	output("To many commas!\n"); error=101; return;
			}
		}
		/* cannot assign 2 values to 3 variables , e.g. */
		if (rscount>1 && rscount<varcount)
		{	output("Illegal assignment!\n"); error=102; return;
		}
		oldendlocal=endlocal;
		offset=0;
		/* do all the assignments */
		if (varcount==1) var=assign(variable[0],rightside[0]);
		else
		for (i=0; i<varcount; i++)
		{	oldoffset=offset;
			/* assign a variable */
			var=assign(addsize(variable[i],offset),
				addsize(rightside[(rscount>1)?i:0],offset));
			offset=endlocal-oldendlocal;
			if (oldoffset!=offset) /* size of var. changed */
			{	v=addsize(variable[i],offset);
				if (v->type==s_reference) mark=referenceof(v);
				else mark=submrefof(v);
				/* now shift all references of the var.s */
				if (mark) /* not a new variable */
					for (j=i+1; j<varcount; j++)
					{	v=addsize(variable[j],offset);
						dif=offset-oldoffset;
						if (v->type==s_reference && referenceof(v)>mark)
							referenceof(v)=addsize(referenceof(v),dif);
						else if (submrefof(v)>mark)
							submrefof(v)=addsize(submrefof(v),dif);
					}
			}
		}
	}
	else /* just an expression which is a variable */
	{	var=getvalue(var);
	}
	if (error) return;
	if (*next!=';') give_out(var);
	if (*next==',' || *next==' ' || *next==';') next++;
}

int command (void)
/***** command
	scan a command and interpret it.
	return, if the user wants to quit.
*****/
{	header *expr;
	int ret=c_none;
	quit=0; error=0; errorout=0;
	while(1)
	{	scan_space();
		if (*next) break;
		else next_line();
	}
	if (*next==1) return ret;
	expr=scan_expression();
	if (!expr) { newram=endlocal; return ret; }
	if (error) 
	{	newram=endlocal; 
		print_error(next); 
		next=line; line[0]=0; 
		return ret; 
	}
	if (expr==&commandheader)
	{	newram=endlocal;
		return commandtype;
	}
	switch (expr->type)
	{	case s_real :
		case s_complex :
		case s_matrix :
		case s_cmatrix :
		case s_string :
			if (*next!=';') give_out(expr);
			if (*next==',' || *next==' ' || *next==';') next++;
			break;
		case s_reference :
		case s_submatrix :
		case s_csubmatrix :
			do_assignment(expr);
			break;
		default : break;
	}
	if (error) print_error(next);
	newram=endlocal;
	if (error) { next=line; line[0]=0; }
	return ret;
}

/******************* main functions ************************/

void clear_fktext (void)
{	int i;
	for (i=0; i<10; i++) fktext[i][0]=0;
}

void main_loop (int argc, char *argv[])
{	int i;
#ifndef SPLIT_MEM
	output2(titel,__DATE__,(unsigned long)(ramend-ramstart));
#else
	output2(titel,__DATE__,(unsigned long)(ramend-varstart));
#endif
#ifndef SPLIT_MEM
	newram=startlocal=endlocal=ramstart;
#else
	newram=startlocal=endlocal=varstart;
#endif
	udfend=ramstart;
	epsilon=10000*DBL_EPSILON;
	sort_builtin(); sort_command(); make_xors(); clear_fktext();
	next=line;		/* clear input line */
	strcpy(line,"load \"euler.cfg\";");
	for (i=1; i<argc; i++)
	{	strcat(line," load \"");
		strcat(line,argv[i]);
		strcat(line,"\";");
	}
	while (!quit)
	{	command();	/* interpret until "quit" */
		if (trace<0) trace=0;
	}
}

