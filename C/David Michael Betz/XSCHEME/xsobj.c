/* xsobj.c - xscheme object-oriented programming support */
/*	Copyright (c) 1988, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xscheme.h"

/* external variables */
extern LVAL xlenv,xlval;
extern LVAL s_stdout;

/* local variables */
static LVAL s_self,k_isnew;
static LVAL class,object;

/* instance variable numbers for the class 'Class' */
#define MESSAGES	1	/* list of messages */
#define IVARS		2	/* list of instance variable names */
#define CVARS		3	/* ctenv containing class variable names */
#define CVALS		4	/* env containing class variable values */
#define SUPERCLASS	5	/* pointer to the superclass */
#define IVARCNT		6	/* number of class instance variables */
#define IVARTOTAL	7	/* total number of instance variables */

/* number of instance variables for the class 'Class' */
#define CLASSSIZE	7

/* forward declarations */
FORWARD LVAL entermsg();
FORWARD LVAL copylists();

/* xlsend - send a message to an object */
xlsend(obj,sym)
  LVAL obj,sym;
{
    LVAL msg,cls,p;

    /* look for the message in the class or superclasses */
    for (cls = getclass(obj); cls; cls = getivar(cls,SUPERCLASS))
	for (p = getivar(cls,MESSAGES); p; p = cdr(p))
	    if ((msg = car(p)) && car(msg) == sym) {
		push(obj); ++xlargc; /* insert 'self' argument */
		xlval = cdr(msg);    /* get the method */
		xlapply();	     /* invoke the method */
		return;
	    }

    /* message not found */
    xlerror("no method for this message",sym);
}

/* xsendsuper - built-in function 'send-super' */
xsendsuper()
{
    LVAL obj,sym,msg,cls,p;

    /* get the message selector */
    sym = xlgasymbol();
    
    /* find the 'self' object */
    for (obj = xlenv; obj; obj = cdr(obj))
	if (ntype(car(obj)) == OBJECT)
	    goto find_method;
    xlerror("not in a method",sym);

find_method:
    /* get the message class and the 'self' object */
    cls = getivar(getelement(car(cdr(obj)),0),SUPERCLASS);
    obj = car(obj);
    
    /* look for the message in the class or superclasses */
    for (; cls; cls = getivar(cls,SUPERCLASS))
	for (p = getivar(cls,MESSAGES); p; p = cdr(p))
	    if ((msg = car(p)) && car(msg) == sym) {
		push(obj); ++xlargc; /* insert 'self' argument */
		xlval = cdr(msg);    /* get the method */
		xlapply();	     /* invoke the method */
		return;
	    }

    /* message not found */
    xlerror("no method for this message",sym);
}

/* obisnew - default 'isnew' method */
LVAL obisnew()
{
    LVAL self;
    self = xlgaobject();
    xllastarg();
    return (self);
}

/* obclass - get the class of an object */
LVAL obclass()
{
    LVAL self;
    self = xlgaobject();
    xllastarg();
    return (getclass(self));
}

/* obshow - show the instance variables of an object */
LVAL obshow()
{
    LVAL self,fptr,cls,names;
    int maxi,i;

    /* get self and the file pointer */
    self = xlgaobject();
    fptr = (moreargs() ? xlgaoport() : getvalue(s_stdout));
    xllastarg();

    /* get the object's class */
    cls = getclass(self);

    /* print the object and class */
    xlputstr(fptr,"Object is ");
    xlprin1(self,fptr);
    xlputstr(fptr,", Class is ");
    xlprin1(cls,fptr);
    xlterpri(fptr);

    /* print the object's instance variables */
    names = cdr(getivar(cls,IVARS));
    maxi = getivcnt(cls,IVARTOTAL);
    for (i = 1; i <= maxi; ++i) {
	xlputstr(fptr,"  ");
	xlprin1(car(names),fptr);
	xlputstr(fptr," = ");
	xlprin1(getivar(self,i),fptr);
	xlterpri(fptr);
	names = cdr(names);
    }

    /* return the object */
    return (self);
}

/* clnew - create a new object instance */
clnew()
{
    LVAL self;

    /* create a new object */
    self = xlgaobject();
    xlval = newobject(self,getivcnt(self,IVARTOTAL));

    /* send the 'isnew' message */
    xlsend(xlval,k_isnew);
}

/* clisnew - initialize a new class */
LVAL clisnew()
{
    LVAL self,ivars,cvars,super;
    int n;

    /* get self, the ivars, cvars and superclass */
    self = xlgaobject();
    ivars = xlgalist();
    cvars = (moreargs() ? xlgalist() : NIL);
    super = (moreargs() ? xlgaobject() : object);
    xllastarg();

    /* create the class variable compile-time environment */
    xlval = cons(xlenter("%%CLASS"),copylists(cvars,NIL));
    cpush(cons(xlval,getivar(super,CVARS)));
    
    /* create the class variable environment */
    xlval = newvector(listlength(xlval)); setelement(xlval,0,self);
    cpush(cons(xlval,getivar(super,CVALS)));

    /* store the instance and class variable lists and the superclass */
    setivar(self,IVARS,copylists(getivar(super,IVARS),ivars));
    setivar(self,CVALS,pop());
    setivar(self,CVARS,pop());
    setivar(self,SUPERCLASS,super);

    /* compute the instance variable count */
    n = listlength(ivars);
    setivar(self,IVARCNT,cvfixnum((FIXTYPE)n));
    n += getivcnt(super,IVARTOTAL);
    setivar(self,IVARTOTAL,cvfixnum((FIXTYPE)n));

    /* return the new class object */
    return (self);
}

/* clanswer - define a method for answering a message */
LVAL clanswer()
{
    extern LVAL xlfunction();
    LVAL self,msg,fargs,code,mptr;

    /* message symbol, formal argument list and code */
    self = xlgaobject();
    msg = xlgasymbol();
    fargs = xlgetarg();
    code = xlgalist();
    xllastarg();

    /* make a new message list entry */
    mptr = entermsg(self,msg);

    /* add 'self' to the argument list */
    cpush(cons(s_self,fargs));

    /* extend the class variable environment with the instance variables */
    xlval = cons(getivar(self,IVARS),getivar(self,CVARS));
    
    /* compile and store the method */
    xlval = xlfunction(msg,top(),code,xlval);
    rplacd(mptr,cvmethod(xlval,getivar(self,CVALS)));
    drop(1);

    /* return the object */
    return (self);
}

/* addivar - enter an instance variable */
LOCAL addivar(cls,var)
  LVAL cls; char *var;
{
    setivar(cls,IVARS,cons(xlenter(var),getivar(cls,IVARS)));
}

/* addmsg - add a message to a class */
LOCAL addmsg(cls,msg,fname)
  LVAL cls; char *msg,*fname;
{
    LVAL mptr;

    /* enter the message selector */
    mptr = entermsg(cls,xlenter(msg));

    /* store the method for this message */
    rplacd(mptr,getvalue(xlenter(fname)));
}

/* entermsg - add a message to a class */
LOCAL LVAL entermsg(cls,msg)
  LVAL cls,msg;
{
    LVAL lptr,mptr;

    /* lookup the message */
    for (lptr = getivar(cls,MESSAGES); lptr; lptr = cdr(lptr))
	if (car(mptr = car(lptr)) == msg)
	    return (mptr);

    /* allocate a new message entry if one wasn't found */
    cpush(cons(msg,NIL));
    setivar(cls,MESSAGES,cons(top(),getivar(cls,MESSAGES)));

    /* return the symbol node */
    return (pop());
}

/* getivcnt - get the number of instance variables for a class */
LOCAL int getivcnt(cls,ivar)
  LVAL cls; int ivar;
{
    LVAL cnt;
    if ((cnt = getivar(cls,ivar)) == NIL || !fixp(cnt))
	xlerror("bad value for instance variable count",cnt);
    return ((int)getfixnum(cnt));
}

/* copylist - make a copy of a list */
LOCAL LVAL copylists(list1,list2)
  LVAL list1,list2;
{
    LVAL last,next;
    
    /* initialize */
    cpush(NIL); last = NIL;
    
    /* copy the first list */
    for (; consp(list1); list1 = cdr(list1)) {
	next = cons(car(list1),NIL);
	if (last) rplacd(last,next);
	else settop(next);
	last = next;
    }
    
    /* append the second list */
    for (; consp(list2); list2 = cdr(list2)) {
	next = cons(car(list2),NIL);
	if (last) rplacd(last,next);
	else settop(next);
	last = next;
    }
    return (pop());
}

/* listlength - find the length of a list */
LOCAL int listlength(list)
  LVAL list;
{
    int len;
    for (len = 0; consp(list); len++)
	list = cdr(list);
    return (len);
}

/* obsymbols - initialize symbols */
obsymbols()
{
    /* enter the object related symbols */
    s_self  = xlenter("SELF");
    k_isnew = xlenter("ISNEW");

    /* get the Object and Class symbol values */
    object = getvalue(xlenter("OBJECT"));
    class  = getvalue(xlenter("CLASS"));
}

/* xloinit - object function initialization routine */
xloinit()
{
    LVAL sym;
    
    /* create the 'Object' object */
    sym = xlenter("OBJECT");
    object = newobject(NIL,CLASSSIZE);
    setvalue(sym,object);
    setivar(object,IVARS,cons(xlenter("%%CLASS"),NIL));
    setivar(object,IVARCNT,cvfixnum((FIXTYPE)0));
    setivar(object,IVARTOTAL,cvfixnum((FIXTYPE)0));
    addmsg(object,"ISNEW","%OBJECT-ISNEW");
    addmsg(object,"CLASS","%OBJECT-CLASS");
    addmsg(object,"SHOW","%OBJECT-SHOW");
    
    /* create the 'Class' object */
    sym = xlenter("CLASS");
    class = newobject(NIL,CLASSSIZE);
    setvalue(sym,class);
    addivar(class,"IVARTOTAL");	/* ivar number 7 */
    addivar(class,"IVARCNT");	/* ivar number 6 */
    addivar(class,"SUPERCLASS");/* ivar number 5 */
    addivar(class,"CVALS");	/* ivar number 4 */
    addivar(class,"CVARS");	/* ivar number 3 */
    addivar(class,"IVARS");	/* ivar number 2 */
    addivar(class,"MESSAGES");	/* ivar number 1 */
    setivar(class,IVARS,cons(xlenter("%%CLASS"),getivar(class,IVARS)));
    setivar(class,IVARCNT,cvfixnum((FIXTYPE)CLASSSIZE));
    setivar(class,IVARTOTAL,cvfixnum((FIXTYPE)CLASSSIZE));
    setivar(class,SUPERCLASS,object);
    addmsg(class,"NEW","%CLASS-NEW");
    addmsg(class,"ISNEW","%CLASS-ISNEW");
    addmsg(class,"ANSWER","%CLASS-ANSWER");

    /* patch the class into 'object' and 'class' */
    setclass(object,class);
    setclass(class,class);
}
