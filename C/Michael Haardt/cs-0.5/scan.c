/* #includes */ /*{{{C}}}*//*{{{*/
#ifndef NO_POSIX_SOURCE
#undef  _POSIX_SOURCE
#define _POSIX_SOURCE   1
#undef  _POSIX_C_SOURCE
#define _POSIX_C_SOURCE 2
#endif

#include <sys/types.h>
#include <sys/stat.h>
#include <assert.h>
#include <ctype.h>
#ifdef BERKELEY_DB
#include <db.h>
#endif
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "alloc.h"
#include "cat.h"
#include "db.h"
#include "getline.h"
#include "scan.h"
/*}}}*/

/* #defines */ /*{{{*/
#define RC(ifd) \
  (buf_ug ? buf_ug=0,buf_ugc : \
  ((buf_off==buf_len ? buf_len=read(ifd,&buf_buf,1024),buf_off=0 : 0),\
  (buf_len>0 ? buf_buf[buf_off++] : EOF)))

#define UC(ch) \
  (buf_ug=1,buf_ugc=ch)

#define GC(fd) \
  if ((scantoken=RC(fd))=='\\') { if ((scantoken=RC(fd))=='\n') ++line; newline=0; } \
  else if (scantoken=='\n') { ++line; indef=0; newline=1; } \
  else if (indef==0 && scantoken=='#' && newline) { indef=1; newline=0; } \
  else newline=0;

/* nexttok    -- go to next scantoken */ 
#define NEXTTOK(device,inode) \
  do \
  while (scantoken!=EOF) \
  { \
    if (!isspace(scantoken)) \
    { \
      if ('/' == scantoken) \
      { \
        scantoken=RC(ifd); \
        if ('*' == scantoken) comment(device,inode); \
        else { UC(scantoken); scantoken = '/'; break; } \
      } \
      else if ('\'' == scantoken || '"' == scantoken) string(device,inode); \
      else if (indef && scantoken=='#') { cpp(device,inode); break; } \
      else break; \
    } \
    GC(ifd); \
  } \
  while (0)
/*}}}*/
/* types */ /*{{{*/
struct Ident
{
  char *ident;
  struct Ident *next;
};
/*}}}*/

/* variables */ /*{{{*/
static int scantoken;
static char identifier[128];
static char function[128];
static int line;
static int indef;
static int newline;
static FILE *ofp;
static int ifd;
static char buf_buf[1024];
static int buf_len,buf_off,buf_ug,buf_ugc;

static const char
res_auto[]="auto",         res_break[]="break",       res_case[]="case",
res_char[]="char",         res_const[]="const",       res_continue[]="continue",
res_default[]="default",   res_do[]="do",             res_double[]="double",
res_else[]="else",         res_enum[]="enum",         res_extern[]="extern",
res_float[]="float",       res_for[]="for",           res_fortran[]="fortran",
res_goto[]="goto",         res_if[]="if",             res_int[]="int",
res_long[]="long",         res_register[]="register", res_return[]="return",
res_short[]="short",       res_sizeof[]="sizeof",     res_static[]="static",
res_struct[]="struct",     res_switch[]="switch",     res_typedef[]="typedef",
res_union[]="union",       res_unsigned[]="unsigned", res_void[]="void",
res_volatile[]="volatile", res_while[]="while";

static const char *decl[] = 
{
  res_auto, res_char, res_const, res_static, res_double, res_enum,
  res_extern, res_float, res_int, res_long, res_register, res_short,
  res_static, res_struct, res_typedef, res_union, res_unsigned,
  res_volatile, res_void, (const char *)0
};
/*}}}*/

/* cpp        -- cpp control line */ /*{{{*/
static void cpp(dev_t device, ino_t inode)
{
  do
  {
    GC(ifd);
  } while (scantoken!=EOF && !isalpha(scantoken) && scantoken!='\n');
  if (scantoken!=EOF && isalpha(scantoken))
  {
    char *s;  
    int i=0;

    s=identifier;
    do
    {
      if (i<(sizeof(identifier)-1)) { *s=scantoken; ++i; ++s; }
      GC(ifd);
    } while (scantoken!=EOF && isalpha(scantoken));
    *s='\0';
    if (strcmp(identifier,"include")==0) /* process include */ /*{{{*/
    {
      while (scantoken!=EOF && isspace(scantoken))
      {
        GC(ifd);
        if (scantoken=='\n') break;
      }
      if (scantoken=='"' || scantoken=='<')
      {
        char match;
        char hdr[128],*h=hdr;

        match=(scantoken=='<' ? '>' : '"');
        do
        {
          scantoken=RC(ifd);
          if (scantoken!=match && scantoken!=EOF) *h++=scantoken;
        } while (scantoken!='\n' && scantoken!=match && scantoken!=EOF);
        *h='\0';
        writerec(ofp,INCLUDE_HEADER,device,inode,line,function,hdr);
        if (scantoken=='\n') { ++line; newline=1; }
      }
    }
    /*}}}*/
    else if (strcmp(identifier,"define")==0) indef=1;
  }
}
/*}}}*/
/* string     -- process a string or character literal */ /*{{{*/
static void string(dev_t device, ino_t inode)
{
  int f,strl,strc=256;
  char *str=malloc(strc),*st=str;

  *st++=scantoken;
  while (scantoken != (f = RC(ifd)) && f!=EOF)
  {
    if ((st-str+3)>=strc)
    {
      strl=st-str;
      str=realloc(str,strc*=3);
      st=str+strl;
    }
    if ('\\'==f)
    {
      if ((f=RC(ifd))=='\n') ++line;
      else { *st++='\\'; *st++=f; }
    }
    else if (f=='\n') { *st++='\\'; *st++='n'; }
    else *st++=f;
  }
  *st++=scantoken;
  *st='\0';
  writerec(ofp,LITERAL,device,inode,line,function,str);
  scantoken=f;
  newline=0;
  free(str);
}
/*}}}*/
/* comment    -- gp to end of comment */ /*{{{*/
static void comment(dev_t device, ino_t inode)
        {
          if ((scantoken=RC(ifd))=='\n') ++line;
          while (scantoken!=EOF)
          {
            while (scantoken != '*' && scantoken != EOF) if ((scantoken=RC(ifd))=='\n') ++line;
            if ((scantoken=RC(ifd))=='\n') ++line;
            else if (scantoken=='/') break;
          }
          newline=0;
        }
/*}}}*/
/* balance    -- go to balancing character */ /*{{{*/
static void balance(dev_t device, ino_t inode, char l, char r, int needscantoken)
{
  int level = needscantoken;

  do
  {
    if (needscantoken) GC(ifd);
    NEXTTOK(device,inode);
    needscantoken=1;
  } while ((level += (l == scantoken) - (r == scantoken)) && scantoken!=EOF);
}
/*}}}*/
/* getid      -- return variable(0), function(1) or keyword(2) */ /*{{{*/
static int getid(const char **keyword)
{
  int i;
  char *s;

  i=0;
  s=identifier;
  do
  {
    if (i<(sizeof(identifier)-1)) { *s++=scantoken; ++i; }
    GC(ifd);
  } while ((scantoken>='a' && scantoken<='z') || (scantoken>='A' && scantoken<='Z') || (scantoken>='0' && scantoken<='9') || '_' == scantoken);
  *s='\0';
  switch (identifier[0])
  {
    case 'a': /*{{{*/
    {
      if (identifier[1]=='u' && identifier[2]=='t' && identifier[3]=='o' && identifier[4]=='\0') { *keyword=res_auto; return 2; }
      else break;
    }
    /*}}}*/
    case 'b': /*{{{*/
    {
      if (identifier[1]=='r' && identifier[2]=='e' && identifier[3]=='a' && identifier[4]=='k' && identifier[5]=='\0') { *keyword=res_break; return 2; }
      else break;
    }
    /*}}}*/
    case 'c': /*{{{*/
    {
      switch (identifier[1])
      {
        case 'a':
        {
          if (strcmp(identifier,res_case)==0) { *keyword=res_case; return 2; }
          else break;
        }
        case 'h':
        {
          if (strcmp(identifier,res_char)==0) { *keyword=res_char; return 2; }
          else break;
        }
        case 'o':
        {
          if (strcmp(identifier,res_const)==0) { *keyword=res_const; return 2; }
          else if (strcmp(identifier,res_continue)==0) { *keyword=res_continue; return 2; }
          else break;
        }
      }
      break;
    }
    /*}}}*/
    case 'd': /*{{{*/
    {
      switch (identifier[1])
      {
        case 'e':
        {
          if (strcmp(identifier,res_default)==0) { *keyword=res_default; return 2; }
          else break;
        }
        case 'o':
        {
          if (identifier[3]=='\0') { *keyword=res_do; return 2; }
          else if (strcmp(identifier,res_double)==0) { *keyword=res_double; return 2; }
          break;
        }
      }
      break;
    }
    /*}}}*/
    case 'e': /*{{{*/
    {
      switch (identifier[1])
      {
        case 'l':
        {
          if (strcmp(identifier,res_else)==0) { *keyword=res_else; return 2; }
          else break;
        }
        case 'n':
        {
          if (strcmp(identifier,res_enum)==0) { *keyword=res_enum; return 2; }
          else break;
        }
        case 'x':
        {
          if (strcmp(identifier,res_extern)==0) { *keyword=res_extern; return 2; }
          else break;
        }
      }
      break;
    }
    /*}}}*/
    case 'f': /*{{{*/
    {
      switch (identifier[1])
      {
        case 'l':
        {
          if (strcmp(identifier,res_float)==0) { *keyword=res_float; return 2; }
          else break;
        }
        case 'o':
        {
          if (strcmp(identifier,res_for)==0) { *keyword=res_for; return 2; }
          else if (strcmp(identifier,res_fortran)==0) { *keyword=res_fortran; return 2; }
          else break;
        }
      }
      break;
    }
    /*}}}*/
    case 'g': /*{{{*/
    {
      if (identifier[1]=='o' && identifier[2]=='t' && identifier[3]=='o' && identifier[4]=='\0') { *keyword=res_goto; return 2; }
      else break;
    }
    /*}}}*/
    case 'i': /*{{{*/
    {
      switch (identifier[1])
      {
        case 'f':
        {
          if (identifier[2]=='\0') { *keyword=res_if; return 2; }
          else break;
        }
        case 'n':
        {
          if (identifier[2]=='t' && identifier[3]=='\0') { *keyword=res_int; return 2; }
          break;
        }
      }
      break;
    }
    /*}}}*/
    case 'l': /*{{{*/
    {
      if (identifier[1]=='o' && identifier[2]=='n' && identifier[3]=='g' && identifier[4]=='\0') { *keyword=res_long; return 2; }
      else break;
    }
    /*}}}*/
    case 'r': /*{{{*/
    {
      switch (identifier[1])
      {
        case 'e':
        {
          if (strcmp(identifier,res_register)==0) { *keyword=res_register; return 2; }
          else if (strcmp(identifier,res_return)==0) { *keyword=res_return; return 2; }
          else break;
        }
      }
      break;
    }
    /*}}}*/
    case 's': /*{{{*/
    {
      switch (identifier[1])
      {
        case 'h':
        {
          if (strcmp(identifier,res_short)==0) { *keyword=res_short; return 2; }
          else break;
        }
        case 'i':
        {
          if (strcmp(identifier,res_sizeof)==0) { *keyword=res_sizeof; return 2; }
          else break;
        }
        case 't':
        {
          if (strcmp(identifier,res_static)==0) { *keyword=res_static; return 2; }
          else if (strcmp(identifier,res_struct)==0) { *keyword=res_struct; return 2; }
          else break;
        }
        case 'w':
        {
          if (strcmp(identifier,res_switch)==0) { *keyword=res_switch; return 2; }
          else break;
        }
      }
      break;
    }
    /*}}}*/
    case 't': /*{{{*/
    {
      if (identifier[1]=='y' && strcmp(identifier,res_typedef)==0) { *keyword=res_typedef; return 2; }
      else break;
    }
    /*}}}*/
    case 'u': /*{{{*/
    {
      switch (identifier[1])
      {
        case 'n':
        {
          if (strcmp(identifier,res_union)==0) { *keyword=res_union; return 2; }
          else if (strcmp(identifier,res_unsigned)==0) { *keyword=res_unsigned; return 2; }
          else break;
        }
      }
      break;
    }
    /*}}}*/
    case 'v': /*{{{*/
    {
      switch (identifier[1])
      {
        case 'o':
        {
          if (strcmp(identifier,res_void)==0) { *keyword=res_void; return 2; }
          else if (strcmp(identifier,res_volatile)==0) { *keyword=res_volatile; return 2; }
          else break;
        }
      }
      break;
    }
    /*}}}*/
  }
  return (indef ? 0 : scantoken=='(');
}
/*}}}*/
/* eatdecl    -- eat anything that starts with any keyword listed */ /*{{{*/
static void eatdecl(dev_t device, ino_t inode, const char *keyword)
{
  register const char **psb = decl;

  while (*psb && *psb!=keyword) ++psb;
  if (*psb) 
  {
    while (scantoken!='=' && scantoken!=';' && scantoken!=')' && scantoken!=EOF)
    {
      if ('{' == scantoken) balance(device,inode,'{', '}', 1);
      else if ('(' == scantoken) balance(device,inode,'(', ')', 1);
      GC(ifd);
      NEXTTOK(device,inode);
    }
  }
}
/*}}}*/

/* variables */ /*{{{*/
static int stored_line=-1;
static struct Ident *ident,**run;
/*}}}*/
/* zapidentd  -- zap identifier index */ /*{{{*/
static void zapidents(void)
{
  struct Ident *next;

  stored_line=-1;
  while (ident)
  {
    free(ident->ident);
    next=ident->next;
    free(ident);
    ident=next;
  }
}
/*}}}*/
/* indexident -- print an identifier, but only once per line */ /*{{{*/
static void indexident(dev_t device, ino_t inode, FILE *ofp)
{
  if (line-newline!=stored_line || stored_line==-1) zapidents();
  stored_line=line-newline;
  for (run=&ident; *run && strcmp((*run)->ident,identifier); run=&((*run)->next));
  if (*run==(struct Ident*)0)
  {
    *run=xmalloc(sizeof(struct Ident));
    (*run)->ident=mystrsave(identifier);
    (*run)->next=(struct Ident*)0;
    writerec(ofp,IDENTIFIER,device,inode,line-newline,function,identifier);
  }
}
/*}}}*/

/* parsefile  -- parse a file */ /*{{{*/
int parsefile(dev_t device, ino_t inode, const char *filename, FILE *outfp)
{
  /* variables */ /*{{{*/
  const char *keyword;
  int parens = 0;
  int private = 0;
  /*}}}*/

  getline(filename,0); /* zap file line offset cache */
  ofp=outfp;
  function[0]='\0';
  if ((ifd=open(filename,O_RDONLY))==-1) return -1;
  buf_off=0; buf_len=0; buf_ug=0;
  line=1;
  scantoken = ' '; newline=1;
  do /* look for and parse a function definition */ /*{{{*/
  {
    if (isalpha(scantoken) || '_' == scantoken) 
    {
      switch (getid(&keyword)) 
      {
        /* 1 -- function definition */ /*{{{*/
        case 1:
        {
          strcpy(function,identifier);
          writerec(ofp,private ? STATIC_FUNCTION : GLOBAL_FUNCTION,device,inode,line,"",identifier);
          private=0;
          NEXTTOK(device,inode);
          balance(device,inode,'(',')',0);
          for (;;)
          {
            GC(ifd);
            NEXTTOK(device,inode);
            if (scantoken == '(') { balance(device,inode,'(', ')',1); continue; }
            else if (scantoken=='[') { balance(device,inode,'[', ']',1); continue; }
            else break;
          }
          if (',' != scantoken && ';' != scantoken)
          {
            int brace = 0;
            int declp = 1;
            const char *keyword;

            while (scantoken!=EOF && (brace || declp))
            {
              if (isalpha(scantoken) || '_' == scantoken) 
              {
                switch (getid(&keyword)) 
                {
                  /* 1 -- function */ /*{{{*/
                  case 1:
                  {
                    writerec(ofp,FUNCTION_CALL,device,inode,line,function,identifier);
                    NEXTTOK(device,inode);
                    break;
                  }
                  /*}}}*/
                  /* 2 -- try to eat declaration */ /*{{{*/
                  case 2:
                  {
                    NEXTTOK(device,inode);
                    eatdecl(device,inode,keyword);
                    break;
                  }
                  /*}}}*/
                  /* 0 -- ignore identifier */ /*{{{*/
                  case 0:
                  {
                    indexident(device,inode,ofp);
                    NEXTTOK(device,inode);
                    break;
                  }
                  /*}}}*/
                }
              }
              else 
              {
                if ('{' == scantoken) { declp = 0; ++brace; }
                else if ('}' == scantoken) --brace;
                GC(ifd);
                NEXTTOK(device,inode);
              }
            }
          }
          zapidents();
          function[0]='\0';
          if (scantoken!=EOF) continue;
        }
        /*}}}*/
        /* 2 -- keyword */ /*{{{*/
        case 2:
        {
          NEXTTOK(device,inode);
          if (keyword==res_static) private=1;
          continue;
        }
        /*}}}*/
        /* 0 -- general identifier */ /*{{{*/
        case 0:
        {
          indexident(device,inode,ofp);
          NEXTTOK(device,inode);
          continue;
        }
        /*}}}*/
      }
    }
    else if (!indef && '{' == scantoken) balance(device,inode,'{', '}',1);
    else if ('(' == scantoken) ++parens;
    else if (')' == scantoken) --parens;
    else if ('*' != scantoken) private = 0;
    GC(ifd);
    NEXTTOK(device,inode);
  }
  /*}}}*/
  while (scantoken!=EOF);
  zapidents();
  close(ifd);
  return 0;
}
/*}}}*/


