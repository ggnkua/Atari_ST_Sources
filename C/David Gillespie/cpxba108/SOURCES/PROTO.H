#if defined(__STDC__) || defined(__cplusplus)
# define _P(s) s
#else
# define _P(s) ()
#endif


/* basic.c */
Static Void restoredata _P((void));
Static Void clearloops _P((void));
Static long arraysize _P((varrec *v));
Static Void clearvar _P((varrec *v));
Static Void clearvars _P((void));
Static Char *numtostr _P((Char *Result, double n));
Static Void parse _P((Char *inbuf, tokenrec **buf));
#undef toklengthStatic Void listtokens _P((FILE *f, tokenrec *buf));
Static Void disposetokens _P((tokenrec **tok));
Static Void parseinput _P((tokenrec **buf));
Static Void errormsg _P((Char *s));
Static Void snerr _P((void));
Static Void tmerr _P((void));
Static Void badsubscr _P((void));
Local double realfactor _P((struct LOC_exec *LINK));
Local Char *strfactor _P((struct LOC_exec *LINK));
Local Char *stringfactor _P((Char *Result, struct LOC_exec *LINK));
Local long intfactor _P((struct LOC_exec *LINK));
Local double realexpr _P((struct LOC_exec *LINK));
Local Char *strexpr _P((struct LOC_exec *LINK));
Local Char *stringexpr _P((Char *Result, struct LOC_exec *LINK));
Local long intexpr _P((struct LOC_exec *LINK));
Local Void require _P((int k, struct LOC_exec *LINK));
Local Void skipparen _P((struct LOC_exec *LINK));
Local varrec *findvar _P((struct LOC_exec *LINK));
Local long inot _P((long i, struct LOC_exec *LINK));
Local long ixor _P((long a, long b, struct LOC_exec *LINK));
Local valrec factor _P((struct LOC_exec *LINK));
Local valrec upexpr _P((struct LOC_exec *LINK));
Local valrec term _P((struct LOC_exec *LINK));
Local valrec sexpr _P((struct LOC_exec *LINK));
Local valrec relexpr _P((struct LOC_exec *LINK));
Local valrec andexpr _P((struct LOC_exec *LINK));
Local valrec expr _P((struct LOC_exec *LINK));
Local Void checkextra _P((struct LOC_exec *LINK));
Local boolean iseos _P((struct LOC_exec *LINK));
Local Void skiptoeos _P((struct LOC_exec *LINK));
Local linerec *findline _P((long n, struct LOC_exec *LINK));
Local linerec *mustfindline _P((long n, struct LOC_exec *LINK));
Local Void cmdend _P((struct LOC_exec *LINK));
Local Void cmdnew _P((struct LOC_exec *LINK));
Local Void cmdlist _P((struct LOC_exec *LINK));
Local Void cmdload _P((boolean merging, Char *name, struct LOC_exec *LINK));
Local Void cmdrun _P((struct LOC_exec *LINK));
Local Void cmdsave _P((struct LOC_exec *LINK));
Local Void cmdbye _P((struct LOC_exec *LINK));
Local Void cmddel _P((struct LOC_exec *LINK));
Local Void cmdrenum _P((struct LOC_exec *LINK));
Local Void cmdprint _P((struct LOC_exec *LINK));
Local Void cmdinput _P((struct LOC_exec *LINK));
Local Void cmdlet _P((boolean implied, struct LOC_exec *LINK));
Local Void cmdgoto _P((struct LOC_exec *LINK));
Local Void cmdif _P((struct LOC_exec *LINK));
Local Void cmdelse _P((struct LOC_exec *LINK));
Local boolean skiploop _P((int up, int dn, struct LOC_exec *LINK));
Local Void cmdfor _P((struct LOC_exec *LINK));
Local Void cmdnext _P((struct LOC_exec *LINK));
Local Void cmdwhile _P((struct LOC_exec *LINK));
Local Void cmdwend _P((struct LOC_exec *LINK));
Local Void cmdgosub _P((struct LOC_exec *LINK));
Local Void cmdreturn _P((struct LOC_exec *LINK));
Local Void cmdread _P((struct LOC_exec *LINK));
Local Void cmddata _P((struct LOC_exec *LINK));
Local Void cmdrestore _P((struct LOC_exec *LINK));
Local Void cmdgotoxy _P((struct LOC_exec *LINK));
Local Void cmdon _P((struct LOC_exec *LINK));
Local Void cmddim _P((struct LOC_exec *LINK));
Local Void cmdpoke _P((struct LOC_exec *LINK));
Local Void cmdusing(struct LOC_exec *LINK,int string);
Static Void exec _P((void));
int main _P((int argc, Char *argv[]));
