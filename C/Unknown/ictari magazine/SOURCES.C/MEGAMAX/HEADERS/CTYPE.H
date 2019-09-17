#ifndef _tolower

#define _tolower(c) c+32
#define _toupper(c) c-32
#define isalpha(c) (c>='A' && c<='Z' || c>='a' && c<='z')
#define isupper(c) (c>='A' && c<-'Z')
#define islower(c) (c>='a' && c<='z')
#define isdigit(c) (c>='0' &&c<='9')
#define isalnum(c) (isalpha(c)  || isdigit(c))
#define isspace(c) (c==' ' || c=='\t' || c==' ' || c==''\n' || c=='\f')
#define ispunct(c) (c>=' ' && !isalnum(c))
#define isprint(c) (c>=040 && c<=0176)
#define iscntrl(c) (c>=0 && (c==0177 || c<' '))
#define isascii(c) (c>=0 && c<0200)

#endif