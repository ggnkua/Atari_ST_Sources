/* xsproto.h - prototypes for all of the external functions */
/*	Copyright (c) 1991, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

/* xscheme.c */
void xlmain(int argc,char **argv);
void xlload(void);
void xlcontinue(void);
void xlbreak(void);
void xlcleanup(void);
void xltoplevel(void);
void xlfail(char *msg);
void xlerror(char *msg,LVAL arg);
void callerrorhandler(void);
void xlabort(char *msg);
void xlfatal(char *msg);
void xlwrapup(void);

/* xscom.c */
LVAL xlcompile(LVAL expr,LVAL ctenv);
LVAL xlfunction(LVAL fun,LVAL fargs,LVAL body,LVAL ctenv);
int length(LVAL list);
void decode_procedure(LVAL fptr,LVAL fun);
int decode_instruction(LVAL fptr,LVAL code,int lc,LVAL env);

/* xsdmem.c */
LVAL cons(LVAL x,LVAL y);
LVAL newframe(LVAL parent,int size);
LVAL cvstring(char *str);
LVAL cvsymbol(char *pname);
LVAL cvfixnum(FIXTYPE n);
LVAL cvflonum(FLOTYPE n);
LVAL cvchar(int ch);
LVAL cvclosure(LVAL code,LVAL env);
LVAL cvpromise(LVAL code,LVAL env);
LVAL cvmethod(LVAL code,LVAL class);
LVAL cvsubr(int type,LVAL (*fcn)(),int offset);
LVAL cvport(FILE *fp,int flags);
LVAL newvector(int size);
LVAL newstring(int size);
LVAL newcode(int nlits);
LVAL newcontinuation(int size);
LVAL newobject(LVAL cls,int size);
int nexpand(int size);
int checkvmemory(int size);
int makevmemory(int size);
int vexpand(int size);
NSEGMENT *newnsegment(unsigned int n);
VSEGMENT *newvsegment(unsigned int n);
void gc(void);
void xlminit(unsigned int ssize);

/* xsftab.c */
LVAL curinput(void);
LVAL curoutput(void);
int eq(LVAL arg1,LVAL arg2);
int eqv(LVAL arg1,LVAL arg2);
int equal(LVAL arg1,LVAL arg2);
int vectorequal(LVAL v1,LVAL v2);
LVAL xltoofew(void);
void xltoomany(void);
LVAL xlbadtype(LVAL val);

/* xsfun1.c */
LVAL xcons(void);
LVAL xcar(void);
LVAL xicar(void);
LVAL xcdr(void);
LVAL xicdr(void);
LVAL xcaar(void);
LVAL xcadr(void);
LVAL xcdar(void);
LVAL xcddr(void);
LVAL xcaaar(void);
LVAL xcaadr(void);
LVAL xcadar(void);
LVAL xcaddr(void);
LVAL xcdaar(void);
LVAL xcdadr(void);
LVAL xcddar(void);
LVAL xcdddr(void);
LVAL xcaaaar(void);
LVAL xcaaadr(void);
LVAL xcaadar(void);
LVAL xcaaddr(void);
LVAL xcadaar(void);
LVAL xcadadr(void);
LVAL xcaddar(void);
LVAL xcadddr(void);
LVAL xcdaaar(void);
LVAL xcdaadr(void);
LVAL xcdadar(void);
LVAL xcdaddr(void);
LVAL xcddaar(void);
LVAL xcddadr(void);
LVAL xcdddar(void);
LVAL xcddddr(void);
LVAL xsetcar(void);
LVAL xisetcar(void);
LVAL xsetcdr(void);
LVAL xisetcdr(void);
LVAL xlist(void);
LVAL xliststar(void);
LVAL xappend(void);
LVAL xreverse(void);
LVAL xlastpair(void);
LVAL xlength(void);
LVAL xmember(void);
LVAL xmemv(void);
LVAL xmemq(void);
LVAL xassoc(void);
LVAL xassv(void);
LVAL xassq(void);
LVAL xlistref(void);
LVAL xlisttail(void);
LVAL xboundp(void);
LVAL xsymvalue(void);
LVAL xsetsymvalue(void);
LVAL xsymplist(void);
LVAL xsetsymplist(void);
LVAL xget(void);
LVAL xput(void);
LVAL xtheenvironment(void);
LVAL xprocenvironment(void);
LVAL xenvp(void);
LVAL xenvbindings(void);
LVAL xenvparent(void);
LVAL xvector(void);
LVAL xmakevector(void);
LVAL xvlength(void);
LVAL xivlength(void);
LVAL xvref(void);
LVAL xivref(void);
LVAL xvset(void);
LVAL xivset(void);
LVAL xvectlist(void);
LVAL xlistvect(void);
LVAL xmakearray(void);
LVAL makearray1(int argc,LVAL *argv);
LVAL xaref(void);
LVAL xaset(void);
LVAL xnull(void);
LVAL xatom(void);
LVAL xlistp(void);
LVAL xnumberp(void);
LVAL xbooleanp(void);
LVAL xpairp(void);
LVAL xsymbolp(void);
LVAL xintegerp(void);
LVAL xrealp(void);
LVAL xcharp(void);
LVAL xstringp(void);
LVAL xvectorp(void);
LVAL xprocedurep(void);
LVAL xobjectp(void);
LVAL xdefaultobjectp(void);
LVAL xeq(void);
LVAL xeqv(void);
LVAL xequal(void);
LVAL xgensym(void);

/* xsfun2.c */
void xapply(void);
void xcallcc(void);
void xmap(void);
void xmap1(void);
void xforeach(void);
void xforeach1(void);
void xcallwi(void);
void xcallwo(void);
void xwithfile1(void);
void xload(void);
void xloadnoisily(void);
void xload1(void);
void xforce(void);
void xforce1(void);
LVAL xsymstr(void);
LVAL xstrsym(void);
LVAL xread(void);
LVAL xrdchar(void);
LVAL xrdbyte(void);
LVAL xrdshort(void);
LVAL xrdlong(void);
LVAL xeofobjectp(void);
LVAL xwrite(void);
LVAL xprint(void);
LVAL xwrchar(void);
LVAL xwrbyte(void);
LVAL xwrshort(void);
LVAL xwrlong(void);
LVAL xdisplay(void);
LVAL xnewline(void);
LVAL xprbreadth(void);
LVAL xprdepth(void);
LVAL xopeni(void);
LVAL xopeno(void);
LVAL xopena(void);
LVAL xopenu(void);
LVAL xclose(void);
LVAL xclosei(void);
LVAL xcloseo(void);
LVAL xgetfposition(void);
LVAL xsetfposition(void);
LVAL xcurinput(void);
LVAL xcuroutput(void);
LVAL xportp(void);
LVAL xinputportp(void);
LVAL xoutputportp(void);
LVAL xtranson(void);
LVAL xtransoff(void);
LVAL xstrlen(void);
LVAL xstrnullp(void);
LVAL xstrappend(void);
LVAL xstrref(void);
LVAL xsubstring(void);
LVAL xstrlist(void);
LVAL xliststring(void);
LVAL xstrlss(void);
LVAL xstrleq(void);
LVAL xstreql(void);
LVAL xstrgeq(void);
LVAL xstrgtr(void);
LVAL xstrilss(void);
LVAL xstrileq(void);
LVAL xstrieql(void);
LVAL xstrigeq(void);
LVAL xstrigtr(void);
LVAL xcharint(void);
LVAL xintchar(void);
LVAL xchrlss(void);
LVAL xchrleq(void);
LVAL xchreql(void);
LVAL xchrgeq(void);
LVAL xchrgtr(void);
LVAL xchrilss(void);
LVAL xchrileq(void);
LVAL xchrieql(void);
LVAL xchrigeq(void);
LVAL xchrigtr(void);
LVAL xcompile(void);
LVAL xdecompile(void);
LVAL xsave(void);
LVAL xrestore(void);
LVAL xgc(void);
LVAL xerror(void);
LVAL xreset(void);
LVAL xgetarg(void);
LVAL xexit(void);

/* xsimage.c */
int xlisave(char *fname);
int xlirestore(char *fname);

/* xsinit.c */
void xlinitws(unsigned int ssize);
void xlsymbols(void);

/* xsint.c */
LVAL xtraceon(void);
LVAL xtraceoff(void);
void xlexecute(LVAL fun);
void xlapply(void);
void xlreturn(void);
void gc_protect(void (*protected_fcn)());
void xlstkover(void);

/* xsio.c */
int xlgetc(LVAL fptr);
void xlungetc(LVAL fptr,int ch);
void xlputc(LVAL fptr,int ch);
void xlflush(void);
void stdputstr(char *str);
void errprint(LVAL expr);
void errputstr(char *str);

/* xsmath.c */
LVAL xexactp(void);
LVAL xinexactp(void);
LVAL xatan(void);
LVAL xfloor(void);
LVAL xceiling(void);
LVAL xround(void);
LVAL xtruncate(void);
LVAL xadd(void);
LVAL xmul(void);
LVAL xsub(void);
LVAL xdiv(void);
LVAL xquo(void);
LVAL xrem(void);
LVAL xmin(void);
LVAL xmax(void);
LVAL xexpt(void);
LVAL xlogand(void);
LVAL xlogior(void);
LVAL xlogxor(void);
LVAL xlognot(void);
LVAL xabs(void);
LVAL xadd1(void);
LVAL xsub1(void);
LVAL xsin(void);
LVAL xcos(void);
LVAL xtan(void);
LVAL xasin(void);
LVAL xacos(void);
LVAL xxexp(void);
LVAL xsqrt(void);
LVAL xxlog(void);
LVAL xrandom(void);
LVAL xgcd(void);
LVAL xnegativep(void);
LVAL xzerop(void);
LVAL xpositivep(void);
LVAL xevenp(void);
LVAL xoddp(void);
LVAL xlss(void);
LVAL xleq(void);
LVAL xeql(void);
LVAL xgeq(void);
LVAL xgtr(void);

/* xsobj.c */
void xlsend(LVAL obj,LVAL sym);
void xsendsuper(void);
LVAL obisnew(void);
LVAL obclass(void);
LVAL obshow(void);
void clnew(void);
LVAL clisnew(void);
LVAL clanswer(void);
void obsymbols(void);
void xloinit(void);

/* xsprint.c */
void xlprin1(LVAL expr,LVAL file);
void xlprinc(LVAL expr,LVAL file);
void xlterpri(LVAL fptr);
void xlputstr(LVAL fptr,char *str);

/* xsread.c */
int xlread(LVAL fptr,LVAL *pval);

/* xssym.c */
void xlsubr(char *sname,int type,LVAL (*fcn)(),int offset);
LVAL xlenter(char *name);
LVAL xlgetprop(LVAL sym,LVAL prp);
void xlputprop(LVAL sym,LVAL val,LVAL prp);
int hash(char *str,int len);

/* ??stuff.c */
void osinit(char *banner);
void osfinish(void);
void osinfo(char *msg);
void oserror(char *msg);
int osrand(int n);
FILE *osaopen(char *name,char *mode);
FILE *osbopen(char *name,char *mode);
int osclose(FILE *fp);
long ostell(FILE *fp);
int osseek(FILE *fp,long offset,int whence);
int osagetc(FILE *fp);
int osaputc(int ch,FILE *fp);
int osbgetc(FILE *fp);
int osbputc(int ch,FILE *fp);
int ostgetc(void);
void ostputc(int ch);
void ostputs(char *str);
void osflush(void);
void oscheck(void);
void ossymbols(void);

