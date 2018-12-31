#ifndef CAT_H
#define CAT_H

#define catgets(catd,set,msg,s) s

#define USAGE         catgets(catd,1,1,"Usage: cs [-bdu] [-f file] [-s directory] [file ...]\n")
#define FILESTR       catgets(catd,1,2,"File")
#define FUNCTION      catgets(catd,1,3,"Function")
#define LINE          catgets(catd,1,4,"Line")
#define FINDID        catgets(catd,1,5,"Find C symbol:")
#define FINDCALLER    catgets(catd,1,6,"Find functions calling this function:")
#define FINDCALLEE    catgets(catd,1,7,"Find functions called by this function:")
#define FINDLIT       catgets(catd,1,8,"Find literal:")
#define FINDINCLUDE   catgets(catd,1,8,"Find files #including this file:")
#define FINDFILE      catgets(catd,1,9,"Find file:")
#define FINDPOSIX     catgets(catd,1,10,"Find POSIX naming violation:")
#define SHELLCMD      catgets(catd,1,11,"Shell command:")
#define CLOSEFAIL     catgets(catd,1,12,"cs: closing %s failed: %s\n")
#define NOTREGDIR     catgets(catd,1,13,"cs: %s is not a regular file or directory\n")
#define CREATEFAIL    catgets(catd,1,14,"cs: can not create %s: %s\n")
#define STATFAIL      catgets(catd,1,15,"cs: can not stat %s: %s\n")
#define OPENFAIL      catgets(catd,1,16,"cs: can not open %s: %s\n")
#define OUTOFMEM      catgets(catd,1,17,"cs: out of memory\n")

#endif
