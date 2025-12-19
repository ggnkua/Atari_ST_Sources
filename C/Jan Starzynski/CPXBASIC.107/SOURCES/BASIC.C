/* Output from p2c, the Pascal-to-C translator      */
/* From input file "dist/examples/basic.p"          */
/* strongly optimized and extended by O.T,T.D,J.S */

#include <time.h>
#include <stdlib.h>
#include <tos.h>
#include "p2c.h"
#include "glo.h"
#include "tokstr.h"

Local char filename[255];
Local long fileposition;
Local boolean binary;
Local int useprec;
Local int useprec_;
Local int usewidth;
Local int usewidth_;
Local int useleft;
Local int useleft_;
Local char *adress;
Local long wert;
Local int bytes;
Local boolean tron;

extern char *cpx_buffer;

#define checking        true
#define varnamelen      20
#define maxdims         4

typedef Char varnamestring[varnamelen + 1];
typedef Char string255[256];

typedef double numarray[];
typedef Char *strarray[];

enum {forloop,whileloop,gosubloop};
enum {CHDIR,MKDIR,RMDIR};

typedef struct tokenrec {
    struct tokenrec *next;
    short kind;
    union {
        struct varrec *vp;
        double num;
        Char *sp;
        Char snch;
    } UU;
} tokenrec;

typedef struct linerec {
    long num, num2;
    tokenrec *txt;
    struct linerec *next;
} linerec;

typedef struct varrec {
    varnamestring name;
    struct varrec *next;
    long dims[maxdims];
    char numdims;
    boolean stringvar;
    union {
        struct {
            double *arr;
            double *val, rv;
        } U0;
        struct {
            Char **sarr;
            Char **sval, *sv;
        } U1;
    } UU;
} varrec;

typedef struct valrec {
    boolean stringval;
    union {
        double val;
        Char *sval;
    } UU;
} valrec;

typedef struct looprec {
    struct looprec *next;
    linerec *homeline;
    tokenrec *hometok;
    short kind;
    union {
        struct {
            varrec *vp;
            double max, step;
        } U0;
    } UU;
} looprec;

typedef struct contsave 
{
	linerec *saveline;
	tokenrec *savetok;
	boolean savegoto,saveelse,flagcont;
	int cm;
	char rev_mode;
} contsave;

Static contsave contvar;
	
Static Char inbuf[256];

Static linerec *linebase;
Static varrec *varbase;
Static looprec *loopbase;

Static long curline;
Static linerec *stmtline, *dataline;
Static tokenrec *stmttok, *datatok, *buf;

Static boolean exitflag;

extern long EXCP_LINE;
extern int esc,cx,cy,cm,chc;
extern char rev_mode,rev_off;

#include "proto.h"

Static Void disposetokens( tokenrec **tok );

/* Feststellen, ob Buchstabe ein Variablenbezeichner sein kann */
int isvar(int a)
{
	return a=='$'||a=='_'||a=='.'||isalnum(a);
}

int isvarstr(int a)
{
	return a=='"'||a=='\''||isvar(a);
}

Local int unit;

/* unit in radiant umrechnen */
Local double to_rad(double x)
{
    switch(unit)
    {
        case tokdegree:
            x*=M_PI/180.;
            break;
        case tokgrad:
            x*=M_PI/200.;
            break;
    }
    return x;
}

/* Radiant in unit umrechnen */
Local double from_rad(double x)
{
    switch(unit)
    {
        case tokdegree:
            x*=180./M_PI;
            break;
        case tokgrad:
            x*=200./M_PI;
            break;
    }
    return x;
}

/* Dezimalgrad in Grad,Min,Sec umrechnen */
Local char *dms(char *s,double x)
{
    char *p;
    long h;
    int min,sec;
    h=(long)x;
    x-=h;
    if(x<0) x=-x;
    x*=60.;
    min=(int)x;
    x-=min;
    x*=60.;
    sec=(int)x;
    x-=sec;
    x*=1000;
    sprintf(s,"%ld:%02d:%02d,%01d",h,min,sec,(int)x);
    p=s;
    while(p[1]) p++;
    while(*p=='0') p--;
    if(*p==',') p--;
    p[1]=0;
    return s;
}

/* String der Form HH:MM:SS,msec in Dezimalgrad umrechnen */
Local double deg(char *s)
{
    double erg=0,fac=1.;
    int i=3,vorz=0;
    char *p,save;
    if(*s=='-')
    {
        vorz=1;
        s++;
    }
    if(*s=='+') s++;
    while(*s&&i-->0)
    {
        p=s;
        while(*s&&isdigit(*s)) s++;
        save=*s;
        *s=0;
        erg+=atol(p)*fac;
        fac*=+(1./60.);
        if((*s=save)!=0) s++;
    }
    if(*s)
    {
        fac=+(1./36000.);
        while(*s&&isdigit(*s))
        {
            erg+=(*s++-'0')*fac;
            fac*=.1;
        }
    }
    return vorz?-erg:erg;
}

Local void set_path(int what)
{
    int drvbit;
    static char buffer[200];
    static int olddrv;

    if(what)
    {
        olddrv=Dgetdrv();
        Dgetpath(buffer,0);
        drvbit=(int)Dsetdrv(cpx_buffer[0]);
        if((drvbit&(1<<cpx_buffer[0]))==0) Dsetdrv(0);
        Dsetpath(cpx_buffer+1);
    }
    else
    {
        Dsetdrv(olddrv);
        Dsetpath(buffer);
    }
}

Static Void restoredata( Void )
{
    dataline = NULL;
    datatok = NULL;
}

Static Void clearloops( Void )
{
    looprec *l;
	contsave *cont=&contvar;

	disposetokens(&(cont->savetok));
	cont->flagcont=false;
    while (loopbase != NULL)
    {
        l = loopbase->next;
        Free(loopbase);
        loopbase = l;
    }
}

Static Void clearvar( varrec *v )
{
    if (v->numdims != 0)
        Free(v->UU.U0.arr);
    else if (v->stringvar && v->UU.U1.sv != NULL)
        Free(v->UU.U1.sv);
    v->numdims = 0;
    if (v->stringvar)
    {
        v->UU.U1.sv = NULL;
        v->UU.U1.sval = &v->UU.U1.sv;
    }
    else
    {
        v->UU.U0.rv = 0.0;
        v->UU.U0.val = &v->UU.U0.rv;
    }
}

Static Void clearvars( Void )
{
    varrec *v;

    v = varbase;
    while (v != NULL)
    {
        clearvar(v);
        v = v->next;
    }
}

Static Char *numtostr( Char *Result, double n )
{
	char *s,*p;
	double x=fabs(n);
    if (n == 0 || ( x>=pow(10,-useprec) && x>=1e-4 && x<1e7 ))
		sprintf(Result, "%#.*lf",useprec,n);
	else
	{
	    sprintf(Result, "%#.*lE",useprec,n);
	    s=Result;
	    while(*s&&*s++!='E');
	    while(*s&&*s!='0') s++;
	    p=s;
	    while(*s&&*s=='0') s++;
		while((*p++=*s++)!=0);
	}
	s=Result;
    while(*s!=0&&*s!='E') s++;
    p=s--;
    while(*s=='0') *s--=' ';
    if(*s=='.') *s--=' ';
	s++;
	while(*p!=0) *s++=*p++;
	while(*s!=0) *s++=' ';
	if(usewidth==0)
	{
		s=Result;
		while(*s&&*s!=' ') s++;
		*s=0;
	}
    return Result;
}

#define toklength  20
typedef long chset[9];

/*
** compare strings 
** l„žt bei all=true Abkrzungen zu
** bei all=false wird nur auf L„nge von cmp verglichen
*/

int Sstrcmp(char *inp,char *cmp,int all)
{
    while(1)
    {
    	if(all&&*inp=='.')
    	{
    		inp++;
    		while(*cmp!=0 && *inp!=*cmp) cmp++;
    	}
    	if(*inp!=*cmp) return all?1:*cmp;
    	if(*inp==0) return 0;
        inp++;
        cmp++;
    }
}

/*
**	modus:	==0 nichtalphanumersische Zeichen
**			!=0 alphanumerische Zeichen
*/
int find_token(char *token,int num,int modus)
{
    char **tok_ptr,*ptr=token;
    char buf[256];
    if(modus!=0) ptr=strupr(strcpy(buf,token));
    tok_ptr=tok_strings+num;
    while(Sstrcmp(ptr,*tok_ptr--,modus) && --num>=0);
    return num;
}

/*
** Wandele einen Ascii in eine Zahl um
** wenn diese aužerhalb des Wertebereiches liegt, Ergebnis<0
*/

static int getnum(int base,int ch)
{
    if(ch>='a')		 ch-='a'-10;
	else if(ch>='A') ch-='A'-10;
    else if(ch<='9') ch-='0';
	if(ch>=base) ch=-1;
	return ch;
}

Static Void parse( Char *inbuf, tokenrec **buf )
{
    int j;
    Char token[toklength + 1];
    tokenrec *t, *tptr;
    varrec *v;
    int ch,i;
    double  d,d1,n,rcpbase;
	char *s;

    tptr = NULL;
    *buf = NULL;
	do
    {
        while (*inbuf && *inbuf == ' '|| *inbuf=='\t') inbuf++;
        if(*inbuf)
        {
	        ch=*inbuf;
    	    t = (tokenrec *)BASalloc(sizeof(tokenrec));
            if (tptr == NULL)
                *buf = t;
            else
                tptr->next = t;
	        tptr = t;
	   	    t->next = NULL;
			t->kind=-1;
	   	    if(ch=='"'||ch=='\'')
	   	    {
	            t->kind = tokstr;
	            s=t->UU.sp = (Char *)BASalloc(256);
	            j = 0;
	            inbuf++;
	            while (*inbuf && *inbuf != ch)
	            {
	                *s++ = *inbuf++;
	            }
	            inbuf++;
			}
			else
			{
				t->kind=j=find_token(inbuf,TOK_ALPHA-1,0);
				if(j>=0)
				{
					inbuf+=strlen(tok_strings[j]);
				}
				else
				{
					inbuf++;
					if(isalpha(ch))
	            	{
		                inbuf--;
			            j = 0;
		    	        token[toklength] = '\0';
		                while(*inbuf &&isvar(*inbuf))
		                {
		                    if(j<toklength) token[j++] = *inbuf;
		                    inbuf++;
		                }
		                token[j] = '\0';
		                t->kind=j=find_token(token,NUM_TOKS-1,1);
		                if (j==tokrem)
		                {
		                    t->UU.sp = (Char *)BASalloc(256);
		                    sprintf(t->UU.sp, "%s", inbuf);
		                    while(*inbuf) inbuf++;
		                }
		                if(j<0)
		                {
		                    t->kind = tokvar;
		                    v = varbase;
		                    while (v != NULL && strcmp(v->name, token))
		                        v = v->next;
		                    if (v == NULL) {
		                        v = (varrec *)BASalloc(sizeof(varrec));
		                        v->next = varbase;
		                        varbase = v;
		                        strcpy(v->name, token);
		                        v->numdims = 0;
		                        if (token[strlen(token) - 1] == '$') {
		                            v->stringvar = true;
		                            v->UU.U1.sv = NULL;
		                            v->UU.U1.sval = &v->UU.U1.sv;
		                        } else {
		                            v->stringvar = false;
		                            v->UU.U0.rv = 0.0;
		                            v->UU.U0.val = &v->UU.U0.rv;
		                        }
		                    }
		                    t->UU.vp = v;
						}
		            }
			    	else if(isdigit(ch)||ch == '.'||ch == '$'||
			    					ch =='%'||ch=='&')
			    	{
		            	int base=10;
		                t->kind = tokdec;
		                switch(ch)
		                {
		                	case '$':
			                    base=16;
			                    t->kind = tokhex;
			                    break;
		                	case '&':
			                    base=8;
			                    t->kind = tokoct;
			                   	break;
		                	case '%':
			                    base=2;
			                    t->kind = tokbin;
		                }
		                if(base==10) inbuf--;
						rcpbase=1./base;
		                d=0;
		                while(*inbuf)
		                {
		                	if((ch=getnum(base,*inbuf))<0) break;
		                    d=d*base+ch;
		                    inbuf++;
		                }
	                    if(*inbuf=='.')
	                    {
	                        inbuf++;
	                        d1=0;
	                        n=rcpbase;
	                        while(*inbuf)
	                        {
	                        	if((ch=getnum(base,*inbuf))<0) break;
	                            d1=d1+ch*n;
	                            n*=rcpbase;
	                            inbuf++;
	                        }
	                        d+=d1;
	                    }
	                    if(*inbuf=='e'||*inbuf=='E'||*inbuf=='@')
	                    {
	                        inbuf++;
	                        n=base;
	                        if(*inbuf=='-'||*inbuf=='+')
	                        {
	                            if(*inbuf++=='-') n=rcpbase;
	                        }
	                        i=0;
	                        while(*inbuf)
	                        {
	                        	if((ch=getnum(base,*inbuf))<0)break;
	                        	i=i*base+ch;
	                        	inbuf++;
	                        }
	                        while(i-->0) d*=n;
	                    }
		                t->UU.num = d;
		            }
		            else
	    	        {
				    	t->kind = toksnerr;
			    	    t->UU.snch = ch;
					}
				}
			}
		    switch(t->kind)
		    {
		    	case tokatan:
		    		t->kind=tokarctan;break;
				case toklog:
		    		t->kind=tokln;break;
		        case toksqr:
		    		t->kind=toksqu;break;
		        case toklps:
		    		t->kind=toklp;break;
		        case tokrps:
		    		t->kind=tokrp;break;
		        case tokprints:
		    		t->kind=tokprint;break;
		        case tokinputs:
		    		t->kind=tokinput;break;
		    	case tokcd:
		    		t->kind=tokchdir;break;
		    }
        }
    }
    while (*inbuf);
    BreakBASIC();
}

#undef toklength

static int ins;

Static Void listtokens( FILE *f, tokenrec *buf )
{
    int tok;
    Char STR1[256],*s;
    int lastchar=0,oldprec=useprec;
	
	useprec=10;
    while (buf != NULL)
    {
        tok=buf->kind;
        if(tok==tokfor||tok==tokwhile) ins+=2;
        if(tok==toknext||tok==tokwend)
        {
        	if((ins-=2)<=0) ins=2;
        }
        switch (tok)
        {
        case tokvar:
            strcpy(STR1,buf->UU.vp->name);
            break;
        case tokdec:
            numtostr(STR1, buf->UU.num);
            s=STR1;
            while(*s!=' ') s++;
            *s=0;
            break;
        case tokoct:
            sprintf(STR1,"&%lo",(long)buf->UU.num);
            break;
        case tokhex:
            sprintf(STR1,"$%lX",(long)buf->UU.num);
            break;
        case tokbin:
        	*STR1='%';
            ltoa((long)buf->UU.num,STR1+1,2);
            break;
        case tokstr:
        	tok='\'';
        	s=buf->UU.sp;
        	if(strchr(s,'\'')!=NULL) tok='"';
            sprintf(STR1, "%c%s%c",tok,s,tok);
            break;
        case toksnerr:
            sprintf(STR1, "{%c}", buf->UU.snch);
            break;
        case tokrem:
            sprintf(STR1, "REM%s", buf->UU.sp);
            break;
        default:
            strcpy(STR1,tok_strings[tok]);
        }
        buf = buf->next;
    	s=STR1;
    	if(isvarstr(*s)&&isvarstr(lastchar)) PUTC(' ',f);
        while(*s++);
        lastchar=*(s-2);
	    FPUTS(STR1,f);
    }
    useprec=oldprec;
	BreakBASIC();
}

Static Void disposetokens( tokenrec **tok )
{
    tokenrec *tok1;

    while (*tok != NULL)
    {
        tok1 = (*tok)->next;
        if ((*tok)->kind == tokrem || (*tok)->kind == tokstr)
            Free((*tok)->UU.sp);
        Free(*tok);
        *tok = tok1;
    }
}

Static Void parseinput( tokenrec **buf )
{
    linerec *l, *l0, *l1;
    Char *s=inbuf;

    while(isspace(*s))s++;
    strcpy(inbuf,s);
    curline = 0;
    while (*inbuf != '\0' && isdigit(inbuf[0]))
    {
        curline = curline * 10 + inbuf[0] - '0';
        strcpy(inbuf, inbuf + 1);
    }
    parse(inbuf, buf);
    if (curline == 0) return;
    l = linebase;
    l0 = NULL;
    while (l != NULL && l->num < curline)
    {
        l0 = l;
        l = l->next;
    }
    if (l != NULL && l->num == curline)
    {
        l1 = l;
        l = l->next;
        if (l0 == NULL)
            linebase = l;
        else
            l0->next = l;
        disposetokens(&l1->txt);
        Free(l1);
    }
    if (*buf != NULL)
    {
        l1 = (linerec *)BASalloc(sizeof(linerec));
        l1->next = l;
        if (l0 == NULL)
            linebase = l1;
        else
            l0->next = l1;
        l1->num = curline;
        l1->txt = *buf;
    }
    clearloops();
    restoredata();
}

Static Void errormsg( Char *s )
{
    Printf("\007%s", s);
    _Escape(42);
}

Static Void snerr( Void )
{
    errormsg("Syntax error");
}

Static Void tmerr( Void )
{
    errormsg("Type mismatch error");
}

Static Void badsubscr( Void )
{
    errormsg("Bad subscript");
}

/* Local variables for exec: */
struct LOC_exec {
    boolean gotoflag, elseflag;
    tokenrec *t;
};

Local valrec factor PP((struct LOC_exec *LINK));
Local valrec expr PP((struct LOC_exec *LINK));

Local double realfactor( struct LOC_exec *LINK )
{
    valrec n;

    n = factor(LINK);
    if (n.stringval)
        tmerr();
    return (n.UU.val);
}

Local Char *strfactor( struct LOC_exec *LINK )
{
    valrec n;

    n = factor(LINK);
    if (!n.stringval)
        tmerr();
    return (n.UU.sval);
}

Local Char *stringfactor( Char *Result, struct LOC_exec *LINK )
{
    valrec n;

    n = factor(LINK);
    if (!n.stringval)
        tmerr();
    strcpy(Result, n.UU.sval);
    Free(n.UU.sval);
    return Result;
}

Local long intfactor( struct LOC_exec *LINK )
{
    return (long)round(realfactor(LINK));
}

Local double realexpr( struct LOC_exec *LINK )
{
    valrec n;

    n = expr(LINK);
    if (n.stringval)
        tmerr();
    return (n.UU.val);
}

Local Char *strexpr( struct LOC_exec *LINK )
{
    valrec n;

    n = expr(LINK);
    if (!n.stringval)
        tmerr();
    return (n.UU.sval);
}

Local Char *stringexpr( Char *Result, struct LOC_exec *LINK )
{
    valrec n;

    n = expr(LINK);
    if (!n.stringval)
        tmerr();
    strcpy(Result, n.UU.sval);
    Free(n.UU.sval);
    return Result;
}

Local long intexpr( struct LOC_exec *LINK )
{
    return (long)round(realexpr(LINK));
}

Local Void require( short k, struct LOC_exec *LINK )
{
    int w;
    if (LINK->t == NULL) snerr();
    else
    {
        w=LINK->t->kind;
        if(w>=tokbin&&w<=tokhex) w=tokdec;
        if( w != k)
            snerr();
        LINK->t = LINK->t->next;
    }
}

Local Void skipparen( struct LOC_exec *LINK )
{
    do {
        if (LINK->t == NULL)
            snerr();
        if (LINK->t->kind == tokrp || LINK->t->kind == tokcomma)
            goto _L1;
        if (LINK->t->kind == toklp) {
            LINK->t = LINK->t->next;
            skipparen(LINK);
        }
        LINK->t = LINK->t->next;
    } while (true);
_L1:
    ;
}

Local varrec *findvar( struct LOC_exec *LINK )
{
    varrec *v;
    long i, j, k;
    tokenrec *tok;
    long FORLIM;

    if (LINK->t == NULL || LINK->t->kind != tokvar)
        snerr();
    v = LINK->t->UU.vp;
    LINK->t = LINK->t->next;
    if (LINK->t == NULL || LINK->t->kind != toklp)
    {
        if (v->numdims != 0)
            badsubscr();
        return v;
    }
    if (v->numdims == 0)
    {
        tok = LINK->t;
        i = 0;
        j = 1;
        do
        {
            if (i >= maxdims) badsubscr();
            LINK->t = LINK->t->next;
            skipparen(LINK);
            j *= 11;
            i++;
            v->dims[i - 1] = 11;
        } while (LINK->t->kind != tokrp);
        v->numdims = i;
        if (v->stringvar)
        {
            v->UU.U1.sarr = (Char **)BASalloc(j * sizeof(char*));
            for (k = 0; k < j; k++) v->UU.U1.sarr[k] = NULL;
        }
        else
        {
            v->UU.U0.arr = (double *)BASalloc(j * sizeof(double));
            for (k = 0; k < j; k++) v->UU.U0.arr[k] = 0.0;
        }
        LINK->t = tok;
    }
    k = 0;
    LINK->t = LINK->t->next;
    FORLIM = v->numdims;
    for (i = 1; i <= FORLIM; i++)
    {
        j = intexpr(LINK);
        if ((unsigned long)j >= v->dims[i - 1])
            badsubscr();
        k = k * v->dims[i - 1] + j;
        if (i < v->numdims)
            require(tokcomma, LINK);
    }
    require(tokrp, LINK);
    if (v->stringvar)
        v->UU.U1.sval = &v->UU.U1.sarr[k];
    else
        v->UU.U0.val = &v->UU.U0.arr[k];
    return v;
}

long peek(void)
{
	register d=bytes;
	register char *s=adress,*t=(char*)&wert+4-d;
	wert=0;
	peekpoke(s,t,d);
	return wert;
}

Local boolean iseos( struct LOC_exec *LINK )
{
	int kind;
	if(LINK->t==NULL) return TRUE;
	kind=LINK->t->kind;
    return (kind == tokelse || kind== tokcolon);
}

boolean isseparator( struct LOC_exec *LINK )
{
    return (iseos(LINK) || LINK->t->kind<TOK_ALPHA);
}
	
typedef struct DEVHNDL
{
	int stat;
	int io;
}
DEVHNDL;

DEVHNDL *find_dev(char *s)
{
	static DEVHNDL dev;
	static char *dev_str[]=
	{
		"PRN",
		"AUX",
		"CON",
		"MIDI",
		"IKBD",
		"RCON",
		"MOD1",
		"MOD2",
		"SER1",
		"SER2"
	};
	char **t=dev_str+NUM_EL(dev_str)-1;
	int i=(int)NUM_EL(dev_str);
	strupr(s);
	while(--i>=0 && strcmp(s,*t--));
	dev.stat=dev.io=i;
	if(i==3) dev.stat=4;
	else if(i==4) dev.stat=3;
	return &dev;
}

Local int cmdoutbyte(struct LOC_exec *LINK,char *TEMPS)
{
	DEVHNDL *dev;
	int erg=-1;
	long TEMPI;
	require(tokcomma,LINK);
	TEMPI=intfactor(LINK);
	dev=find_dev(TEMPS);
	if(dev->io>=0 && Bcostat(dev->stat))
	{
		Bconout(dev->io,(int)TEMPI&0xff);
		erg=0;
	}
	return erg;
}

Local int cmdinbyte(char *TEMPS)
{
	int erg=-1;
	DEVHNDL *dev;
	dev=find_dev(TEMPS);
	if(dev->io>=0 && Bconstat(dev->io)) erg=(int)Bconin(dev->io)&0xff;
	return erg;
}

Local valrec factor( struct LOC_exec *LINK )
{
    varrec *v;
    tokenrec *facttok;
    valrec n;
    long i, j;
    tokenrec *tok, *tok1;
    static char pfad[140],name[14];
    Char *TEMPS,*t;
    double TEMP;
    long TEMPI;
    int kind,fsel;
	time_t zeit;

    if (LINK->t == NULL) snerr();
    facttok = LINK->t;
    LINK->t = LINK->t->next;
    n.stringval = false;
    kind=facttok->kind;

	if(kind==tokmid_)
	{
        n.stringval = true;
        require(toklp, LINK);
        n.UU.sval=strexpr(LINK);
        require(tokcomma, LINK);
        i = intexpr(LINK)-1;
        if (i<0) i=0;
        j = 255;
        if (LINK->t != NULL && LINK->t->kind == tokcomma)
        {
            LINK->t = LINK->t->next;
            j = intexpr(LINK);
        }
        TEMPS=n.UU.sval;
        if (i < strlen(TEMPS))
        {
        	while(j-->0&&(*TEMPS=TEMPS[i])!=0) TEMPS++;
        }
        *TEMPS= '\0';
        require(tokrp, LINK);
	}	
	else
	{
		TEMPS=NULL;
		/* wenn String als Ergebnis, diesen einrichten */
		if( kind==tokstr
			||(kind<NUM_TOKS&&strchr(tok_strings[kind],'$')))
		{
			n.stringval=true;
			t=n.UU.sval=BASalloc(256);
		}

		if(kind>=REAL_TOKS)
		{
			if(kind<END_REAL)
			{
				TEMP=realfactor(LINK);
			}
			else if(kind<END_INT)
			{
				TEMPI=intfactor(LINK);
			}
			else if(kind<END_STRING)
			{
				TEMPS=strfactor(LINK);
			}
		}
		switch(kind)
	    {
		    case toklp:
		        n = expr(LINK);
		        require(tokrp, LINK);
		        break;
	        case tokminus:
	            n.UU.val = -TEMP;
	            break;
	        case tokplus:
	            n.UU.val = TEMP;
	            break;
			case tokint:
				n.UU.val = (long)TEMP;
				break;
	        case toksqu:
	            n.UU.val = TEMP * TEMP;
	            break;
	        case tokrcp:
	            n.UU.val = 1./TEMP;
	            break;
	        case toksqrt:
	            n.UU.val = sqrt(TEMP);
	            break;
	        case toksin:
	            n.UU.val = sin(to_rad(TEMP));
	            break;
	        case toksinh:
	            n.UU.val = sinh(TEMP);
	            break;
	        case tokasin:
	            n.UU.val = from_rad(asin(TEMP));
	            break;
	        case tokasinh:
	            n.UU.val = asinh(TEMP);
	            break;
	        case tokcos:
	            n.UU.val = cos(to_rad(TEMP));
	            break;
	        case tokcosh:
	            n.UU.val = cosh(TEMP);
	            break;
	        case tokacos:
	            n.UU.val = from_rad(acos(TEMP));
	            break;
	        case tokacosh:
	            n.UU.val = acosh(TEMP);
	            break;
	     	case toktan:
	            n.UU.val = tan(to_rad(TEMP));
	            break;
	        case toktanh:
	            n.UU.val = tanh(TEMP);
	            break;
	        case tokarctan:
	            n.UU.val = from_rad(atan(TEMP));
	            break;
	        case tokatanh:
	            n.UU.val = atanh(TEMP);
	            break;
	        case tokln:
	            n.UU.val = log(TEMP);
	            break;
	        case tokexp:
	            n.UU.val = exp(TEMP);
	            break;
	        case toklg:
	            n.UU.val = log10(TEMP);
	            break;
	        case tokten:
	            n.UU.val = pow(10,TEMP);
	            break;
	        case tokld:
	            n.UU.val = log(TEMP)/M_LN2;
	            break;
	        case tokpow2:
	            n.UU.val = pow(2,TEMP);
	            break;
	        case tokabs:
	            n.UU.val = fabs(TEMP);
	            break;
	        case toksgn:
	            n.UU.val = TEMP < 0;
	            break;
	        case tokstr_:
	            numtostr(n.UU.sval, TEMP);
	            break;
			case tokdms_:
	            dms(n.UU.sval, TEMP);
	            break;
		    case toknot:
			    n.UU.val = ~TEMPI;
		    	break;
			case tokfact:
				TEMP=1.;
				while(TEMPI>1) TEMP*=TEMPI--;
				n.UU.val=TEMP;
				break;
		    case tokchr_:
		        n.UU.sval[0] = (char)TEMPI;
		        if(TEMPI==0) make0byte(n.UU.sval+1);
		        break;
		    case tokbin_:
		        n.UU.sval[0]='%';
		        ultoa((unsigned long)TEMPI,n.UU.sval+1,2);
		        break;
		    case tokoct_:
		        n.UU.sval[0]='&';
		        ultoa((unsigned long)TEMPI,n.UU.sval+1,8);
		        break;
		    case tokhex_:
		        n.UU.sval[0]='$';
		        ultoa((unsigned long)TEMPI,n.UU.sval+1,16);
		        break;
			case tokpeekl: bytes=4; goto peek;
			case tokpeekw: bytes=2; goto peek;
		    case tokpeek:  bytes=1;
peek:	        adress = (char*) TEMPI;
		        n.UU.val = Supexec(peek);
		        break;
		    case tokval:
		        tok1 = LINK->t;
		        parse(TEMPS, &LINK->t);
		        tok = LINK->t;
		        if (tok == NULL)
		            n.UU.val = 0.0;
		        else
		            n = expr(LINK);
		        disposetokens(&tok);
		        LINK->t = tok1;
		        break;
			case toklabel:
				n.UU.val=TEMPI;
				break;
			case tokdeg:
				n.UU.val=deg(TEMPS);
				break;
		    case tokasc:
		        n.UU.val = *TEMPS;
		        break;
		    case toklen:
		        n.UU.val = strlen(TEMPS);
		        break;
			case tokfsel_:
				set_path(1);
				if(*pfad==0)
				{
					*pfad=cpx_buffer[0]+'A';
					pfad[1]=':';
					strcpy(pfad+2,cpx_buffer+1);
					strcat(pfad,"\\");
				}
				t=strrchr(pfad,'\\');
				if(!isseparator(LINK)) TEMPS=strfactor(LINK);
				if(t!=NULL) strcpy(t+1,TEMPS!=NULL?TEMPS:"*.*");
				fsel_input(pfad,name,&fsel);
				if(fsel)
				{
					t=n.UU.sval;
					strcpy(t,pfad);
					t=strrchr(t,'\\');
					if(t!=NULL) strcpy(t+1,name);
				}
				set_path(0);
				break;
			case tokrand:
				if(!isseparator(LINK))
				{
					n.UU.val=Random()%intfactor(LINK);
				}
				else
				{
					n.UU.val=(double)Random()/(double)0x00FFFFFFL;
				}
				break;
			case tokpi:
				n.UU.val=M_PI;
				break;
			case tokerrno:
				n.UU.val=fileerror;
				fileerror=0;
				break;
            case tokinkey_:
                    if(woff!=roff)
                    {
                            n.UU.sval[0]=KeyBuffer[roff++];
                            if(roff>=KB_SIZE) roff=0;
                    }
                    else WaitBASIC();
                    break;
			case tokpath_:
				n.UU.sval[0]=cpx_buffer[0]+'A';
				n.UU.sval[1]=':';
				strcpy(t+2,cpx_buffer+1);
				break;
			case toktime_:
				time(&zeit);
				strcpy(t,ctime(&zeit));
				break;
			case toktimer:
				n.UU.val = (double)clock();
				break;
			case tokalert:
		        require(toklp, LINK);
    		    i=intexpr(LINK);
		        require(tokcomma, LINK);
		        TEMPS=strexpr(LINK);
		        require(tokrp, LINK);
		        n.UU.val=(double)form_alert((int)i,TEMPS);
				break;
			case tokinbyte:
				n.UU.val=cmdinbyte(TEMPS);
				break;
			case tokoutbyte:
				n.UU.val=cmdoutbyte(LINK,TEMPS);
				break;
		    case tokhex:
		    case tokoct:
	    	case tokbin:
		    case tokdec:
			       n.UU.val = facttok->UU.num;
			       break;
		    case tokvar:
		        LINK->t = facttok;
		        v = findvar(LINK);
		        n.stringval = v->stringvar;
		        if (n.stringval)
		        {
		            n.UU.sval = (Char *)BASalloc(256);
		            strcpy(n.UU.sval, *v->UU.U1.sval);
		        } else
		            n.UU.val = *v->UU.U0.val;
		        break;
		    case tokstr:
		        strcpy(n.UU.sval, facttok->UU.sp);
		        break;
		    default:
		    	snerr();
		}
		if(TEMPS!=NULL) Free(TEMPS);
    }
    return n;
}

Local valrec upexpr( struct LOC_exec *LINK )
{
    valrec n, n2;

    n = factor(LINK);
    while (LINK->t != NULL && LINK->t->kind == tokup)
    {
        if (n.stringval)
            tmerr();
        LINK->t = LINK->t->next;
        n2 = upexpr(LINK);
        if (n2.stringval) tmerr();
        n.UU.val = pow(n.UU.val,n2.UU.val);
    }
    return n;
}

Local valrec term( struct LOC_exec *LINK )
{
    valrec n, n2;
    short k;

    n = upexpr(LINK);
    while (LINK->t != NULL &&
    		((k=LINK->t->kind)==toktimes||k==tokdiv||k==tokmod)
          )
    {
        LINK->t = LINK->t->next;
        n2 = upexpr(LINK);
        if (n.stringval || n2.stringval)
            tmerr();
        if (k == tokmod)
        {
            n.UU.val = (long)round(n.UU.val) % (long)round(n2.UU.val);
        } else if (k == toktimes)
            n.UU.val *= n2.UU.val;
        else
            n.UU.val /= n2.UU.val;
    }
    return n;
}

Local valrec sexpr( struct LOC_exec *LINK )
{
    valrec n, n2;
    short k;

    n = term(LINK);
    while (LINK->t != NULL &&
        ((k=LINK->t->kind)==tokplus||k==tokminus))
    {
        LINK->t = LINK->t->next;
        n2 = term(LINK);
        if (n.stringval != n2.stringval)
            tmerr();
        if (k == tokplus) {
            if (n.stringval) {
                strcat(n.UU.sval, n2.UU.sval);
                Free(n2.UU.sval);
            } else
                n.UU.val += n2.UU.val;
        } else {
            if (n.stringval)
                tmerr();
            else
                n.UU.val -= n2.UU.val;
        }
    }
    return n;
}

Local valrec relexpr( struct LOC_exec *LINK )
{
    valrec n, n2;
    boolean f;
    short k;
    int erg;
    double cmp;
    
    n = sexpr(LINK);
    while (LINK->t != NULL && ((k=LINK->t->kind)<=tokne&&k>=tokeq))
    {
        k = LINK->t->kind;
        LINK->t = LINK->t->next;
        n2 = sexpr(LINK);
        if (n.stringval != n2.stringval)
            tmerr();
        if (n.stringval)
        {
        	erg = strcmp(n.UU.sval, n2.UU.sval);
            Free(n.UU.sval);
            Free(n2.UU.sval);
        }
        else
        {
        	cmp=n.UU.val-n2.UU.val;
        	erg=0;
        	if(cmp>0) erg=1;
        	if(cmp<0) erg=-1;
        }
        switch(k)
        {
	       	case tokeq:
        		f=erg==0;break;
        	case tokge:
        		f=erg>=0;break;
        	case tokle:
        		f=erg<=0;break;
        	case toklt:
        		f=erg<0;break;
        	case tokne:
        		f=erg!=0;break;
        	case tokgt:
        		f=erg>0;break;
        }
		n.stringval=false;
        n.UU.val = f;
    }
    return n;
}

Local valrec andexpr( struct LOC_exec *LINK )
{
    valrec n, n2;

    n = relexpr(LINK);
    while (LINK->t != NULL && LINK->t->kind == tokand)
    {
        LINK->t = LINK->t->next;
        n2 = relexpr(LINK);
        if (n.stringval || n2.stringval)
            tmerr();
        n.UU.val = ((long)n.UU.val) & ((long)n2.UU.val);
    }
    return n;
}

Local valrec expr( struct LOC_exec *LINK )
{
    valrec n, n2;
    short k;

    n = andexpr(LINK);
    while (LINK->t != NULL && 
    		((k=LINK->t->kind)==tokor|| k==tokxor)
    	  )
   {
        LINK->t = LINK->t->next;
        n2 = andexpr(LINK);
        if (n.stringval || n2.stringval)
            tmerr();
        if (k == tokor)
            n.UU.val = ((long)n.UU.val) | ((long)n2.UU.val);
        else
            n.UU.val = ((long)n.UU.val) ^ ((long)n2.UU.val);
    }
    return n;
}

Local Void checkextra( struct LOC_exec *LINK )
{
    if (LINK->t != NULL) errormsg("Extra information on line");
}

Local Void skiptoeos( struct LOC_exec *LINK )
{
    while (!iseos(LINK))
        LINK->t = LINK->t->next;
}

Local linerec *findline( long n)
{
    linerec *l;

    l = linebase;
    while (l != NULL && l->num != n)
        l = l->next;
    return l;
}

Local linerec *mustfindline( long n)
{
    linerec *l;

    l = findline(n);
    if (l == NULL)
        errormsg("Undefined line");
    return l;
}

Local Void cmdend( struct LOC_exec *LINK )
{
    stmtline = NULL;
    LINK->t = NULL;
}

Local Void cmdnew( struct LOC_exec *LINK )
{
    Anyptr p;

    cmdend(LINK);
    clearloops();
    restoredata();
    while (linebase != NULL) {
        p = (Anyptr)linebase->next;
        disposetokens(&linebase->txt);
        Free(linebase);
        linebase = (linerec *)p;
    }
    while (varbase != NULL) {
        p = (Anyptr)varbase->next;
        if (varbase->stringvar) {
            if (*varbase->UU.U1.sval != NULL)
                Free(*varbase->UU.U1.sval);
        }
        Free(varbase);
        varbase = (varrec *)p;
    }
}

Local Void cmdlist( struct LOC_exec *LINK )
{
    linerec *l;
    long n1, n2;
    int kind;

    do
    {
        n1 = 0;
        n2 = LONG_MAX;
        if (LINK->t != NULL)
        {
	        kind=LINK->t->kind;
         	if(kind >= tokbin && kind<=tokhex)
         	{
            	n1 = (long)LINK->t->UU.num;
	            LINK->t = LINK->t->next;
    	        if (LINK->t == NULL || LINK->t->kind != tokminus)
        	        n2 = n1;
			}
        }
        if (LINK->t != NULL && LINK->t->kind == tokminus)
        {
            LINK->t = LINK->t->next;
            if (LINK->t != NULL)
            {
                kind=LINK->t->kind;
                if(kind<=tokhex&&kind>=tokbin)
                {
                    n2 = (long)LINK->t->UU.num;
                    LINK->t = LINK->t->next;
                }
                else
                    n2 = LONG_MAX;
            }
        }
        l = linebase;
        while (l != NULL && l->num <= n2) {
            if (l->num >= n1) {
                Printf("%ld ", l->num);
                listtokens(stdout, l->txt);
                Putchar('\n');
                if(ctrl) break;
            }
            l = l->next;
        }
        if (!iseos(LINK))
            require(tokcomma, LINK);
    } while (!iseos(LINK));
}

#define MYBUFSIZ (4*1024)

#if MYBUFSIZ<BUFSIZ
#  undef MYBUFSIZ
#  define MYBUFSIZ BUFSIZ
#endif

Local FILE *BUFfopen(char *ptr,char *mode)
{
	FILE *fp;
    set_path(1);
	fp=fopen(ptr,mode);
	if(fp!=NULL) setvbuf(fp,NULL,_IOFBF,MYBUFSIZ);
    set_path(0);
	return fp;
}

Local FILE *BASfopen(Char *ptr,char *str)
{
    FILE *fp;
    char *s,temp[256];
    strcpy(temp,ptr);
    s=strrchr(temp,'\\');
    if(s==NULL) s=temp;
    s=strrchr(s,'.');
    if(s==NULL) strcat(temp,".BAS");
    fp=BUFfopen(temp,str);
    return fp;
}

Local Void cmdload( boolean merging, Char *name, struct LOC_exec *LINK )
{
    FILE *f;
    tokenrec *buf;
    Char *TEMP;
	int linenum=0;

    if (!merging) cmdnew(LINK);
    f = BASfopen(name, "r");
    if (f == NULL) _EscIO(FileNotFound);
    while (fgets(inbuf, 256, f) != NULL)
    {
    	linenum++;
        TEMP = strchr(inbuf, '\n');
        if (TEMP != NULL) *TEMP = 0;
        if(*inbuf!=0)
        {
	        parseinput(&buf);
    	    if (curline == 0)
    	    {
        	    Printf("Bad line %d in file\n",linenum);
            	disposetokens(&buf);
           	}
        }
    }
    if (f != NULL) fclose(f);
}

void clearall(void)
{
	clearvars();
	clearloops();
	restoredata();
}

Local Void cmdrun( struct LOC_exec *LINK )
{
    linerec *l;
    long i;
    string255 s;
    int kind;

    l = linebase;
    if (!iseos(LINK)) {
        kind=LINK->t->kind;
        if (kind<=tokhex&&kind>=tokbin)
            l = mustfindline(intexpr(LINK));
        else {
            stringexpr(s, LINK);
            i = 0;
            if (!iseos(LINK)) {
                require(tokcomma, LINK);
                i = intexpr(LINK);
            }
            checkextra(LINK);
            cmdload(false, s, LINK);
            if (i == 0)
                l = linebase;
            else
                l = mustfindline(i);
        }
    }
    stmtline = l;
    LINK->gotoflag = true;
	clearall();
}

Local Void cmdsave( struct LOC_exec *LINK )
{
    FILE *f;
    linerec *l;
    Char STR1[256];
	int tok,thisins;
	long line;

	ins=2;
    f = BASfopen(stringexpr(STR1, LINK), "w");
    if (f == NULL)  _EscIO(FileNotFound);
    l = linebase;
    line=0;
    while (l != NULL)
    {
    	if(l->num>line) line=l->num;
    	l=l->next;
    }
    line=strlen(ltoa(line,STR1,10));
    l = linebase;
    while (l != NULL)
    {
    	tok=l->txt->kind;
    	thisins=ins;
        if(tok==toknext||tok==tokwend)
        {
        	if((thisins-=2)<=0) thisins=2;
        }
        FPRINTF(f, "%-*ld%*c",(int)line,l->num,thisins,' ');
        listtokens(f, l->txt);
        PUTC('\n', f);
        l = l->next;
    }
    if (f != NULL) fclose(f);
}

Local Void cmddel( struct LOC_exec *LINK )
{
    linerec *l, *l0, *l1;
    long n1, n2;
    int kind;

    do {
        if (iseos(LINK))
            snerr();
        n1 = 0;
        n2 = LONG_MAX;
        if (LINK->t != NULL)
        {
            kind=LINK->t->kind;
            if( kind<=tokhex&&kind>=tokbin )
            {
                n1 = (long)LINK->t->UU.num;
                LINK->t = LINK->t->next;
                if (LINK->t == NULL || LINK->t->kind != tokminus)
                    n2 = n1;
            }
        }
        if (LINK->t != NULL && LINK->t->kind == tokminus) {
            LINK->t = LINK->t->next;
            if (LINK->t != NULL)
            {
                kind=LINK->t->kind;
                if(kind<=tokhex&&kind>=tokbin)
                {
                    n2 = (long)LINK->t->UU.num;
                    LINK->t = LINK->t->next;
                } else
                    n2 = LONG_MAX;
            }
        }
        l = linebase;
        l0 = NULL;
        while (l != NULL && l->num <= n2) {
            l1 = l->next;
            if (l->num >= n1) {
                if (l == stmtline) {
                    cmdend(LINK);
                    clearloops();
                    restoredata();
                }
                if (l0 == NULL)
                    linebase = l->next;
                else
                    l0->next = l->next;
                disposetokens(&l->txt);
                Free(l);
            } else
                l0 = l;
            l = l1;
        }
        if (!iseos(LINK))
            require(tokcomma, LINK);
    } while (!iseos(LINK));
}

Local Void cmdrenum( struct LOC_exec *LINK )
{
    linerec *l, *l1;
    tokenrec *tok;
    long lnum, step;

    lnum = 10;
    step = 10;
    if (!iseos(LINK)) {
        lnum = intexpr(LINK);
        if (!iseos(LINK)) {
            require(tokcomma, LINK);
            step = intexpr(LINK);
        }
    }
    l = linebase;
    if (l == NULL)
        return;
    while (l != NULL) {
        l->num2 = lnum;
        lnum += step;
        l = l->next;
    }
    l = linebase;
    do {
        tok = l->txt;
        do {
            if (tok->kind == tokdel || tok->kind == tokrestore ||
                tok->kind == toklist || tok->kind == tokrun ||
                tok->kind == tokelse || tok->kind == tokthen ||
                tok->kind == tokgosub || tok->kind == tokgoto ||
                tok->kind == toklabel)
            {
                while (tok->next != NULL && tok->next->kind >= tokbin
                            && tok->next->kind <= tokhex)
                {
                    tok = tok->next;
                    lnum = (long)round(tok->UU.num);
                    l1 = linebase;
                    while (l1 != NULL && l1->num != lnum)
                        l1 = l1->next;
                    if (l1 == NULL)
                        Printf("Undefined line %ld in line %ld\n", lnum, l->num2);
                    else
                        tok->UU.num = l1->num2;
                    if (tok->next != NULL && tok->next->kind == tokcomma)
                        tok = tok->next;
                }
            }
            tok = tok->next;
        } while (tok != NULL);
        l = l->next;
    } while (l != NULL);
    l = linebase;
    while (l != NULL) {
        l->num = l->num2;
        l = l->next;
    }
}

int skipcomma(struct LOC_exec *LINK)
{
	int kind;
	if(LINK->t!=NULL)
	{
		kind=LINK->t->kind;
		if(kind==toksemi||kind==tokcomma)
		{
			LINK->t=LINK->t->next;
			return 1;
		}
	}
	return 0;
}

Local Void cmdprint(FILE *fp, struct LOC_exec *LINK )
{
    boolean semiflag;
    valrec n;
    Char STR1[256],*s,*format,*ptr,save;

    while (1)
    {
		semiflag = skipcomma(LINK);
		if(iseos(LINK)) break;
        n = expr(LINK);
        if (n.stringval)
        {
        	if((ptr=s=n.UU.sval)!=NULL)
	        {
	        	format="%*.*s";
    	    	if(useleft_) format="%-*.*s";
				while(1)
	   	    	{
	        		while(*ptr++);
	        		save=*ptr;
	        		*ptr=0;
		            FPRINTF(fp,format,usewidth_,useprec_,s);
					*ptr=save;
					if(!binary || !is0byte(ptr)) break;
					PUTC(0,fp);
					s=ptr+4;
				}
	        	Free(n.UU.sval);
	        }
        }
        else
        {
        	format="%*s ";
        	if(useleft) format="%-*s ";
            FPRINTF(fp,format,usewidth>0?usewidth-1:1
            		,numtostr(STR1, n.UU.val));
        }
    }
    if (!semiflag) PUTC('\n',fp);
}

Local Void cmdinput(FILE *fp, struct LOC_exec *LINK )
{
    varrec *v;
    string255 s;
    tokenrec *tok, *tok0, *tok1;
    boolean strflag;
    char *prompt;

   	tok=tok0=NULL;
	while (1)
    {
    	prompt="? ";
	    if (LINK->t != NULL && LINK->t->kind == tokstr)
	    {
	    	prompt=LINK->t->UU.sp;
	    	LINK->t = LINK->t->next;
	        skipcomma(LINK);
	    }
        v = findvar(LINK);
        strflag=v->stringvar;
        while(tok == NULL)
        {
            disposetokens(&tok0);
           	if(fp==stdin) Printf("%s",prompt);
            FGets(fp,s);
            if(ctrl) return;
			if(fileerror&&fp!=stdin)
			{
				s[0]=0;
				if(!strflag)
				{
					s[0]='0';
					s[1]=0;
				}
			}
			if(strflag) break;
           	parse(s, &tok);
           	tok0 = tok;
        }
        if(strflag)
        {
            if (*v->UU.U1.sval != NULL)
                Free(*v->UU.U1.sval);
            *v->UU.U1.sval = (Char *)BASalloc(256);
            strcpy(*v->UU.U1.sval, s);
        }
        else
        {
	        tok1 = LINK->t;
	        LINK->t = tok;
	        *v->UU.U0.val = realexpr(LINK);
	        if (LINK->t != NULL)
	        {
	            if (LINK->t->kind == tokcomma)
	                LINK->t = LINK->t->next;
	        }
	        tok = LINK->t;
	        LINK->t = tok1;
        }
        if (iseos(LINK)) break;
        skipcomma(LINK);
    }
    disposetokens(&tok0);
}

Local Void cmdlet( boolean implied, struct LOC_exec *LINK )
{
    varrec *v;
    Char *old;

    if (implied) LINK->t = stmttok;
    v = findvar(LINK);
    require(tokeq, LINK);
    if (!v->stringvar)
    {
        *v->UU.U0.val = realexpr(LINK);
        return;
    }
    old = *v->UU.U1.sval;
    *v->UU.U1.sval = strexpr(LINK);
    if (old != NULL) Free(old);
}

Local Void cmdgoto( struct LOC_exec *LINK )
{
    stmtline = mustfindline(intexpr(LINK));
    LINK->t = NULL;
    LINK->gotoflag = true;
}

Local Void cmdif( struct LOC_exec *LINK )
{
    double n;
    long i;
    int kind;

    n = realexpr(LINK);
    require(tokthen, LINK);
    if (n == 0)
    {
        i = 0;
        do {
            if (LINK->t != NULL) {
                if (LINK->t->kind == tokif)
                    i++;
                if (LINK->t->kind == tokelse)
                    i--;
                LINK->t = LINK->t->next;
            }
        } while (LINK->t != NULL && i >= 0);
    }
    if (LINK->t != NULL)
    {
        kind=LINK->t->kind;
        if(kind >= tokbin && kind <= tokhex)
            cmdgoto(LINK);
        else
            LINK->elseflag = true;
    }
}

Local Void cmdelse( struct LOC_exec *LINK )
{
    LINK->t = NULL;
}

Local boolean skiploop( short up, short dn, struct LOC_exec *LINK )
{
    boolean Result;
    long i;
    linerec *saveline;

    saveline = stmtline;
    i = 0;
    do {
        while (LINK->t == NULL) {
            if (stmtline == NULL || stmtline->next == NULL) {
                Result = false;
                stmtline = saveline;
                goto _L1;
            }
            stmtline = stmtline->next;
            LINK->t = stmtline->txt;
        }
        if (LINK->t->kind == up)
            i++;
        if (LINK->t->kind == dn)
            i--;
        LINK->t = LINK->t->next;
    } while (i >= 0);
    Result = true;
_L1:
    return Result;
}

Local Void cmdfor( struct LOC_exec *LINK )
{
    looprec *l, lr;
    linerec *saveline;
    long i, j;

    lr.UU.U0.vp = findvar(LINK);
    if (lr.UU.U0.vp->stringvar)
        snerr();
    require(tokeq, LINK);
    *lr.UU.U0.vp->UU.U0.val = realexpr(LINK);
    require(tokto, LINK);
    lr.UU.U0.max = realexpr(LINK);
    if (LINK->t != NULL && LINK->t->kind == tokstep) {
        LINK->t = LINK->t->next;
        lr.UU.U0.step = realexpr(LINK);
    } else
        lr.UU.U0.step = 1.0;
    lr.homeline = stmtline;
    lr.hometok = LINK->t;
    lr.kind = forloop;
    lr.next = loopbase;
    if (lr.UU.U0.step >= 0 && *lr.UU.U0.vp->UU.U0.val > lr.UU.U0.max ||
        lr.UU.U0.step <= 0 && *lr.UU.U0.vp->UU.U0.val < lr.UU.U0.max) {
        saveline = stmtline;
        i = 0;
        j = 0;
        do {
            while (LINK->t == NULL) {
                if (stmtline == NULL || stmtline->next == NULL) {
                    stmtline = saveline;
                    errormsg("FOR without NEXT");
                }
                stmtline = stmtline->next;
                LINK->t = stmtline->txt;
            }
            if (LINK->t->kind == tokfor) {
                if (LINK->t->next != NULL && LINK->t->next->kind == tokvar &&
                    LINK->t->next->UU.vp == lr.UU.U0.vp)
                    j++;
                else
                    i++;
            }
            if (LINK->t->kind == toknext) {
                if (LINK->t->next != NULL && LINK->t->next->kind == tokvar &&
                    LINK->t->next->UU.vp == lr.UU.U0.vp)
                    j--;
                else
                    i--;
            }
            LINK->t = LINK->t->next;
        } while (i >= 0 && j >= 0);
        skiptoeos(LINK);
        return;
    }
    l = (looprec *)BASalloc(sizeof(looprec));
    *l = lr;
    loopbase = l;
}

Local Void cmdnext( struct LOC_exec *LINK )
{
    varrec *v;
    boolean found;
    looprec *l, *WITH;

    if (!iseos(LINK))
        v = findvar(LINK);
    else
        v = NULL;
    do {
        if (loopbase == NULL || loopbase->kind == gosubloop)
            errormsg("NEXT without FOR");
        found = (loopbase->kind == forloop &&
            (v == NULL || loopbase->UU.U0.vp == v));
        if (!found) {
            l = loopbase->next;
            Free(loopbase);
            loopbase = l;
        }
    } while (!found);
    WITH = loopbase;
    *WITH->UU.U0.vp->UU.U0.val += WITH->UU.U0.step;
    if ((WITH->UU.U0.step < 0 || *WITH->UU.U0.vp->UU.U0.val <= WITH->UU.U0.max) &&
        (WITH->UU.U0.step > 0 || *WITH->UU.U0.vp->UU.U0.val >= WITH->UU.U0.max)) {
        stmtline = WITH->homeline;
        LINK->t = WITH->hometok;
        return;
    }
    l = loopbase->next;
    Free(loopbase);
    loopbase = l;
}

Local Void cmdwhile( struct LOC_exec *LINK )
{
    looprec *l;

    l = (looprec *)BASalloc(sizeof(looprec));
    l->next = loopbase;
    loopbase = l;
    l->kind = whileloop;
    l->homeline = stmtline;
    l->hometok = LINK->t;
    if (iseos(LINK))
        return;
    if (realexpr(LINK) != 0)
        return;
    if (!skiploop(tokwhile, tokwend, LINK))
        errormsg("WHILE without WEND");
    l = loopbase->next;
    Free(loopbase);
    loopbase = l;
    skiptoeos(LINK);
}

Local Void cmdwend( struct LOC_exec *LINK )
{
    tokenrec *tok;
    linerec *tokline;
    looprec *l;
    boolean found;

    do {
        if (loopbase == NULL || loopbase->kind == gosubloop)
            errormsg("WEND without WHILE");
        found = (loopbase->kind == whileloop);
        if (!found) {
            l = loopbase->next;
            Free(loopbase);
            loopbase = l;
        }
    } while (!found);
    if (!iseos(LINK)) {
        if (realexpr(LINK) != 0)
            found = false;
    }
    tok = LINK->t;
    tokline = stmtline;
    if (found) {
        stmtline = loopbase->homeline;
        LINK->t = loopbase->hometok;
        if (!iseos(LINK)) {
            if (realexpr(LINK) == 0)
                found = false;
        }
    }
    if (found)
        return;
    LINK->t = tok;
    stmtline = tokline;
    l = loopbase->next;
    Free(loopbase);
    loopbase = l;
}

Local Void cmdgosub( struct LOC_exec *LINK )
{
    looprec *l;

    l = (looprec *)BASalloc(sizeof(looprec));
    l->next = loopbase;
    loopbase = l;
    l->kind = gosubloop;
    l->homeline = stmtline;
    l->hometok = LINK->t;
    cmdgoto(LINK);
}

Local Void cmdreturn( struct LOC_exec *LINK )
{
    looprec *l;
    boolean found;

    do {
        if (loopbase == NULL)
            errormsg("RETURN without GOSUB");
        found = (loopbase->kind == gosubloop);
        if (!found) {
            l = loopbase->next;
            Free(loopbase);
            loopbase = l;
        }
    } while (!found);
    stmtline = loopbase->homeline;
    LINK->t = loopbase->hometok;
    l = loopbase->next;
    Free(loopbase);
    loopbase = l;
    skiptoeos(LINK);
}

Local Void cmdread( struct LOC_exec *LINK )
{
    varrec *v;
    tokenrec *tok;
    boolean found;

    do {
        v = findvar(LINK);
        tok = LINK->t;
        LINK->t = datatok;
        if (dataline == NULL) {
            dataline = linebase;
            LINK->t = dataline->txt;
        }
        if (LINK->t == NULL || LINK->t->kind != tokcomma) {
            do {
                while (LINK->t == NULL) {
                    if (dataline == NULL || dataline->next == NULL)
                        errormsg("Out of Data");
                    dataline = dataline->next;
                    LINK->t = dataline->txt;
                }
                found = (LINK->t->kind == tokdata);
                LINK->t = LINK->t->next;
            } while (!found || iseos(LINK));
        } else
            LINK->t = LINK->t->next;
        if (v->stringvar) {
            if (*v->UU.U1.sval != NULL)
                Free(*v->UU.U1.sval);
            *v->UU.U1.sval = strexpr(LINK);
        } else
            *v->UU.U0.val = realexpr(LINK);
        datatok = LINK->t;
        LINK->t = tok;
        if (!iseos(LINK))
            require(tokcomma, LINK);
    } while (!iseos(LINK));
}

Local Void cmddata( struct LOC_exec *LINK )
{
    skiptoeos(LINK);
}

Local Void cmdrestore( struct LOC_exec *LINK )
{
    if (iseos(LINK))
        restoredata();
    else {
        dataline = mustfindline(intexpr(LINK));
        datatok = dataline->txt;
    }
}

Local Void cmdgotoxy( struct LOC_exec *LINK )
{
    long x,y;

    x = intexpr(LINK);
    require(tokcomma, LINK);
    y = intexpr(LINK);

    Putchar(27);
    Putchar('Y');
    Putchar(32+(int)x);
    Putchar(32+(int)y);

}

Local Void cmdon( struct LOC_exec *LINK )
{
    long i;
    looprec *l;

    i = intexpr(LINK);
    if (LINK->t != NULL && LINK->t->kind == tokgosub) {
        l = (looprec *)BASalloc(sizeof(looprec));
        l->next = loopbase;
        loopbase = l;
        l->kind = gosubloop;
        l->homeline = stmtline;
        l->hometok = LINK->t;
        LINK->t = LINK->t->next;
    } else
        require(tokgoto, LINK);
    if (i < 1) {
        skiptoeos(LINK);
        return;
    }
    while (i > 1 && !iseos(LINK)) {
        require(tokdec, LINK);
        if (!iseos(LINK))
            require(tokcomma, LINK);
        i--;
    }
    if (!iseos(LINK))
        cmdgoto(LINK);
}

Local Void cmddim( struct LOC_exec *LINK )
{
    long i, j, k;
    varrec *v;
    boolean done;

    do {
        if (LINK->t == NULL || LINK->t->kind != tokvar)
            snerr();
        v = LINK->t->UU.vp;
        LINK->t = LINK->t->next;
        if (v->numdims != 0) 
            errormsg("Array already dimensioned");
        j = 1;
        i = 0;
        require(toklp, LINK);
        do {
            k = intexpr(LINK) + 1;
            if (k < 1)
                badsubscr();
            if (i >= maxdims)
                badsubscr();
            i++;
            v->dims[i - 1] = k;
            j *= k;
            done = (LINK->t != NULL && LINK->t->kind == tokrp);
            if (!done)
                require(tokcomma, LINK);
        } while (!done);
        LINK->t = LINK->t->next;
        v->numdims = i;

        if (v->stringvar) j*=sizeof(char*);
		else j*=sizeof(double);

		v->UU.U1.sarr = (Char **)BASalloc(j);

        if (!iseos(LINK)) require(tokcomma, LINK);
    } while (!iseos(LINK));
}

void poke(void)
{
	register d=bytes;
	register char *s=adress,*t=(char*)&wert+4-d;
	peekpoke(t,s,d);
}

Local Void cmdpoke( struct LOC_exec *LINK )
{
    adress = (char*)intexpr(LINK);
    require(tokcomma, LINK);
    wert=intexpr(LINK);

	Supexec((long(*)(void))poke);
}

Local Void cmdusing(struct LOC_exec *LINK,int string)
{
	int i;
	int *wp,*pp,*lp;
	if(string)
	{
		wp=&usewidth_;
		pp=&useprec_;
		lp=&useleft_;
		*pp=255;
	}
	else
	{
		wp=&usewidth;
		pp=&useprec;
		lp=&useleft;
		*pp=10;
	}	
	*wp=0;
	*lp=0;
	if(!iseos(LINK))
	{
		if(LINK->t->kind!=tokcomma)
		{
			*pp=(int)intexpr(LINK);
		}
		if(!iseos(LINK)&&LINK->t->kind==tokcomma)
		{
			LINK->t=LINK->t->next;
			i=(int)intexpr(LINK);
			if(i<0)
			{
				*lp=1;
				i=-i;
			}
			*wp=i;
		}
	}
}

Local Void cmdplot(struct LOC_exec *LINK)
{
	int x,y;
	x=(int)intexpr(LINK);
	require(tokcomma,LINK);
	y=(int)intexpr(LINK);
	plotpoint(x,y);
}
	
Local Void cmdline(struct LOC_exec *LINK)
{
	int x0,y0,x1,y1;
	x0=(int)intexpr(LINK);
	require(tokcomma,LINK);
	y0=(int)intexpr(LINK);
	require(tokcomma,LINK);
	x1=(int)intexpr(LINK);
	require(tokcomma,LINK);
	y1=(int)intexpr(LINK);
	line(x0,y0,x1,y1);
}


/* Routinen zur Dateiverwaltung:
** Es wird nach jedem Lesen und Schreiben die Datei physikalisch geschlossen,
** d.h. FOPEN und FCLOSE setzen lediglich Dateinamen und Leseposition
** Damit das nicht zu langsam wird, erfolgt das Schliežen 10 Timer (1/2 sek.)
** nach dem letzten Zugriff, bzw. bie FCLOSE.
** DATAfclose schliežt die Datei in Abh„ngigkeit vom bergebenen Parameter
** oder der verstrichenen Zeit,
** DATAfopen bergibt den bereits eingerichteten Dateizeiger oder ”ffnet
** sonst die Datei und stellt alle Parameter zu Bufferung ein.
*/

Local FILE *thefp;
Local int rw_mode;
int fptime;

/* mode<>0 lesen, ==0 schreiben */
void DATAfclose(int doit)
{
	if(thefp!=NULL)
	{
		if(doit||fptime<=0)
		{
			if(rw_mode!=0) fileposition=ftell(thefp);
			fclose(thefp);
			thefp=NULL;
			fptime=0;
		}
	}
}

/* mode<>0 lesen, ==0 schreiben */
Local FILE *DATAfopen(int mode)
{
	char *modus="a";
	if(mode) modus="r";
	if(binary)
	{
		modus="ab";
		if(mode) modus="rb";
	}
	if(mode!=rw_mode) DATAfclose(1);
	if(thefp==NULL)
	{
		thefp=BUFfopen(filename,modus);
		if(thefp!=NULL&&mode!=0) fseek(thefp,fileposition,SEEK_SET);
		rw_mode=mode;
	}
	fptime=10;
	return thefp;
}

Local Void cmdcircle(struct LOC_exec *LINK)
{
	int x0,y0,r;
	x0=(int)intexpr(LINK);
	require(tokcomma,LINK);
	y0=(int)intexpr(LINK);
	require(tokcomma,LINK);
	r=(int)intexpr(LINK);
	circle(x0,y0,r);
}

Local Void cmddir( struct LOC_exec *LINK, int command )
{
	Char	STR1[256];

	set_path(1);
	stringexpr(STR1, LINK);
	
	if(STR1[1]==':') Dsetdrv(toupper(*STR1) - 'A');
		
	switch(command)
	{
		case MKDIR:
			if(Dcreate(STR1))
				Printf("Can't create folder\n");
			break;
		case RMDIR:
			if(Ddelete(STR1))
				Printf("Can't delete folder\n"); 
			break;
		case CHDIR:
			if(Dsetpath(STR1))
			{
				Printf("Can't change to folder\n");
			}
			else
			{
				cpx_buffer[0]=Dgetdrv();
				Dgetpath(cpx_buffer+1,0);
			}
			break;
	}

	set_path(0);
}

DTA dta;

Local Void fileprt(void)
{
	char *ff_name=dta.d_fname;
	char *p=ff_name;

	while(*p&&*p!='.') p++;

 	if(p[0]!=0)
 	{
	 	if(p[1]=='.'||p[1]==0) p="";
 		else *p++=0;
 	}

	if (dta.d_attrib & 0x10)
		Printf("%-10s%-6s%10s\n",ff_name,p,"<SUB-DIR>");
	else
		Printf("%-10s%-6s%10ld\n",ff_name,p,dta.d_length);
	WaitBASIC();
}

Local Void cmdfiles( struct LOC_exec *LINK )
{
	Char	STR1[256];
	DTA	*olddta=Fgetdta();
	Fsetdta(&dta);
	
	set_path(1);
	if (iseos( LINK ))
		strcpy(STR1, "*.*");
	else
		stringexpr(STR1, LINK);

	if(Fsfirst(STR1,0x31)==0)
	{
		do
		{
			fileprt();
		}
		while(Fsnext()==0);
	}
	else
	{
		Printf("No files found\n");
	}
	set_path(0);
	Fsetdta(olddta);
}

Static Void exec( Void )
{
    struct LOC_exec V;
	contsave *cont=&contvar;
    Char *ioerrmsg;
    Char STR1[256],*s,*p;
    FILE *fp;

    TRY(try1);
    do
    {
        do
        {
            V.gotoflag = false;
            V.elseflag = false;
            while (stmttok != NULL && stmttok->kind == tokcolon)
                stmttok = stmttok->next;

            V.t = stmttok;
            if (V.t != NULL)
            {
                V.t = V.t->next;
                switch (stmttok->kind)
                {
                case tokrem: /* blank case */
                    break;

				case toktron:
					tron=true;
					break;

				case toktroff:
					tron=false;
					break;

                case toklist:
                    cmdlist(&V);
                    break;

                case tokrun:
                    cmdrun(&V);
                    break;

                case toknew:
                    cmdnew(&V);
                    break;

                case tokload:
                    cmdload(false, stringexpr(STR1, &V), &V);
                    break;

                case tokmerge:
                    cmdload(true, stringexpr(STR1, &V), &V);
                    break;

                case toksave:
                    cmdsave(&V);
                    break;

				case tokfiles:
					cmdfiles(&V);
					break;

				case tokchdir:
					cmddir(&V,CHDIR);
					break;
					
				case tokmkdir:
					cmddir(&V,MKDIR);
					break;
					
				case tokrmdir:
					cmddir(&V,RMDIR);
					break;

                case tokbye:
				    exitflag = true;
                    break;

                case tokdel:
                    cmddel(&V);
                    break;

                case tokrenum:
                    cmdrenum(&V);
                    break;

                case toklet:
                    cmdlet(false, &V);
                    break;

                case tokvar:
                    cmdlet(true, &V);
                    break;

                case tokprint:
                    cmdprint(stdout,&V);
                    break;

                case tokfprint:
                	fp=stdout;
                	if(*filename)
                	{
                		fp=DATAfopen(0);
#ifndef REDEFD
	                	if(fp==NULL) fp=stdout;
#endif
					}
                    cmdprint(fp,&V);
                    break;

                case tokinput:
                    cmdinput(stdin,&V);
                    break;

                case tokfinput:
                	fp=stdin;
                	if(*filename)
                	{
                		fp=DATAfopen(1);
#ifndef REDEFD
						if(fp==NULL) fp=stdin;
#endif
					}
                    cmdinput(fp,&V);
                    break;

                case tokgoto:
                    cmdgoto(&V);
                    break;

                case tokif:
                    cmdif(&V);
                    break;

                case tokelse:
                    cmdelse(&V);
                    break;

                case tokend:
                    cmdend(&V);
                    break;

                case tokstop:
                    ctrl=1;
                    break;

				case tokcont:
					if(cont->flagcont)
					{
						disposetokens(&V.t);
						V.t=cont->savetok;
						stmtline=cont->saveline;
						V.gotoflag=cont->savegoto;
						V.elseflag=cont->saveelse;
						cm=cont->cm;
						rev_mode=cont->rev_mode;
						cont->flagcont=false;
					}
					break;

                case tokfor:
                    cmdfor(&V);
                    break;

                case toknext:
                    cmdnext(&V);
                    break;

                case tokwhile:
                    cmdwhile(&V);
                    break;

                case tokwend:
                    cmdwend(&V);
                    break;

                case tokgosub:
                    cmdgosub(&V);
                    break;

                case tokreturn:
                    cmdreturn(&V);
                    break;

                case tokread:
                    cmdread(&V);
                    break;

                case tokdata:
                    cmddata(&V);
                    break;

                case tokrestore:
                    cmdrestore(&V);
                    break;

                case tokgotoxy:
                    cmdgotoxy(&V);
                    break;

                case tokon:
                    cmdon(&V);
                    break;

                case tokdim:
                    cmddim(&V);
                    break;

                case tokpokel: bytes=4;goto poke;
                case tokpokew: bytes=2;goto poke;
                case tokpoke:  bytes=1;
poke:               cmdpoke(&V);
                    break;

				case tokdegree:
				case tokgrad:
				case tokrad:
					unit=stmttok->kind;
					break;

				case tokcls:
					Printf("\033E");
					break;

				case tokfopen:
					stringexpr(filename,&V);
					binary=false;
					if(!iseos(&V))
					{
						require(tokcomma,&V);
						p=s=strexpr(&V);
						while(*p)
						{
							switch(*p++)
							{
								int Fdelete(const char *);
								case 'b':
								case 'B':
									binary=true;
									break;
								case 'n':
								case 'N':
									Fdelete(filename);
									break;
								default:
									errormsg("bad option for FOPEN");
							}
						}
						Free(s);
					}
					fileposition=0;
					break;

				case tokfclose:
					DATAfclose(1);
					*filename=0;
					break;

				case tokclear:
				    clearall();
					break;

				case tokusing:
					cmdusing(&V,0);
					break;

				case tokusing_:
					cmdusing(&V,1);
					break;

				case tokplot:
					cmdplot(&V);
					break;
				case tokline:
					cmdline(&V);
					break;
				case tokcircle:
					cmdcircle(&V);
					break;
				case tokoutbyte:
					s=strexpr(&V);
					cmdoutbyte(&V,s);
					Free(s);
					break;
                default:
                    errormsg("Illegal command");
                    break;
                }
            }

            if (!V.elseflag && !iseos(&V)) checkextra(&V);
            stmttok = V.t;

            BreakBASIC();       /* Und mal abbrechen ...    @@@ */

			if(ctrl) goto _Ltr1;

        } while ( V.t != NULL);
		
        if(stmtline != NULL)
        {
			if(tron)
			{
				Printf("\nTRON %ld: ",stmtline->num);
				listtokens(stdout,stmtline->txt);
				Gets(STR1);
				if(ctrl) goto _Ltr1;
			}
            if(!V.gotoflag) stmtline = stmtline->next;
            if(stmtline!=NULL) stmttok = stmtline->txt;
        }

    } while(stmtline != NULL);

    RECOVER2(try1,_Ltr1);

    if(ctrl)
    {
    	Printf("\r\n\aBreak");
		disposetokens(&(cont->savetok));
    	cont->savetok=stmttok;
    	cont->saveline=stmtline;
    	cont->savegoto=V.gotoflag;
    	cont->saveelse=V.elseflag;
    	cont->cm=cm;
    	cont->rev_mode=rev_mode;
		cont->flagcont=true;
    }
    else if(P_escapecode != 42)
    {
        switch(P_escapecode)
        {
    	case -2:
    		Printf("Memory fault");
    		break;

        case -10:
            ioerrmsg = (Char *)BASalloc(256);
            sprintf(ioerrmsg, "I/O Error %d", (int)P_ioresult);
            Printf("\007%s", ioerrmsg);
            Free(ioerrmsg);
            break;

        default:
            if(EXCP_LINE != -1)
                Printf(" %ld\n", EXCP_LINE);
            _Escape(P_escapecode);
            break;
        }
    }

    if(stmtline != NULL) Printf(" in %ld", stmtline->num);
    Putchar('\n');
    ENDTRY(try1);
}   /*exec*/

int basic(int argc, Char *argv[])
{
    PASCAL_MAIN(argc, argv);
    linebase = NULL;
    varbase  = NULL;
    loopbase = NULL;
    exitflag = false;
	unit=tokrad;
	*filename=0;
	useprec=10;
	useprec_=255;
	usewidth=0;
	usewidth_=0;
	useleft=0;
	useleft_=0;

    Printf(
    "\033E\033p Chipmunk-BASIC \033q v1.00\n"
    "by David Gillespie\n\n"
    "\033p CPX-BASIC \033q vX.yz\n"
    "by Oliver Teuber, Jan Starzynski"
    "and Torsten Dix\n\n");

    do
    {
        TRY(try2);
        do
        {
    	    while(1)
        	{
	            ctrl=0;
    	        esc=0;
	            Printf("\033q\033e>");
    	        Gets(inbuf);
    	        if(ctrl==0) break;
    	        Putchar('\n');
    	    }
            parseinput(&buf);
            if(curline == 0)
            {
                stmtline = NULL;
                stmttok = buf;
                if(stmttok != NULL) exec();
                if(!ctrl) disposetokens(&buf);
            }
        }
        while(!exitflag);

        RECOVER(try2);
        if(P_escapecode!=-20)
            Printf("Error %d/%d!\n", (int)P_escapecode, (int)P_ioresult);
        else
            Putchar('\n');
        ENDTRY(try2);
    }   while( !exitflag);

    return EXIT_SUCCESS;
}
