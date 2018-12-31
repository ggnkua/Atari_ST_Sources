/* #includes */ /*{{{C}}}*//*{{{*/
#ifndef NO_POSIX_SOURCE
#undef  _POSIX_SOURCE
#define _POSIX_SOURCE   1
#undef  _POSIX_C_SOURCE
#define _POSIX_C_SOURCE 2
#endif

#include <sys/types.h>
#include <sys/wait.h>
#include <assert.h>
#include <ctype.h>
#include <curses.h>
#include <errno.h>
#include <limits.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
extern char *optarg;
extern int optind,opterr,optopt;
int getopt(int argc, char * const *argv, const char *optstring);
#include <string.h>
#include <unistd.h>

#include "alloc.h"
#include "cat.h"
#include "db.h"
#include "misc.h"
#include "pager.h"
/*}}}*/

/* line editor function */ /*{{{*/
static void editline(int y, int promptlen, char *buf, size_t size, chtype initch)
{
  /* variables */ /*{{{*/
  size_t x,offx;
  int i,mx,my,insert;
  chtype c;
  /*}}}*/

  /* asserts */ /*{{{*/
  assert(buf!=(char*)0);
  /*}}}*/
  x=0;
  offx=0;
  mx=COLS;
  my=LINES;
  insert=1;
  do
  {
    /* correct offx to cursor stays visible */ /*{{{*/
    if (x<offx) offx=x;
    if ((x-offx)>(mx-promptlen-1)) offx=x-mx+promptlen+1;
    /*}}}*/
    /* display buffer */ /*{{{*/
    move(y,(int)promptlen);
    for (i=promptlen; buf[i-promptlen+offx]!='\0' && i<COLS; ++i) waddch(stdscr,(chtype)((unsigned char)buf[i-promptlen+offx]));
    if (i!=mx) wclrtoeol(stdscr);
    /*}}}*/
    /* show cursor */ /*{{{*/
    move(y,(int)(x-offx+promptlen));
    /*}}}*/
    refresh();
    c=(initch ? initch : getch());
    initch='\0';
    switch (c) 
    {
      /* LEFT */ /*{{{*/
      case '\02':
      case KEY_LEFT: if (x>0) --(x); break;
      /*}}}*/
      /* RIGHT */ /*{{{*/
      case '\06':
      case KEY_RIGHT: if (x<strlen(buf)) ++(x); break;
      /*}}}*/
      /* BACKSPACE      */ /*{{{*/
      case '\010':
      case KEY_BACKSPACE:
      {
        if (x>0)
        {
          memmove(buf+x-1,buf+x,strlen(buf+x)+1);
          --(x);
        }
        break;
      }
      /*}}}*/
      /* DC */ /*{{{*/
      case '\04':
      case '\177':
      case KEY_DC:
      {
        if (x<strlen(buf)) memmove(buf+x,buf+x+1,strlen(buf+x));
        break;
      }
      /*}}}*/
      /* BEG */ /*{{{*/
      case KEY_BEG:
      {
        x=0;
        break;
      }  
      /*}}}*/
      /* END */ /*{{{*/
      case KEY_END:
      {
        x=strlen(buf);
        break;
      }  
      /*}}}*/
      /* IC */ /*{{{*/
      case KEY_IC:
      {
        insert=1-insert;
        break;
      }  
      /*}}}*/
      /* EIC */ /*{{{*/
      case KEY_EIC:
      {
        insert=0;
        break;
      }
      /*}}}*/
      /* control t */ /*{{{*/
      case '\024':
      {
        if (x>0 && (strlen(buf)<(size-1) || x!=strlen(buf)))
        {
          char c;

          c=*(buf+x);
          *(buf+x)=*(buf+x-1);
          if (c=='\0')
          {
            c=' ';
            *(buf+x+1)='\0';
          }
          *(buf+x-1)=c;
          ++(x);
        }
        break;
      }
      /*}}}*/
      /* DL */ /*{{{*/
      case KEY_DL:
      {
        *(buf+x)='\0';
        break;
      }
      /*}}}*/
      /* default */ /*{{{*/
      default:
      {
        if (((unsigned)c)<' ' || ((unsigned)c)>=256 || strlen(buf)==(size-1)) break;
        if (insert) memmove(buf+x+1,buf+x,strlen(buf)-x+1);
        else if (x==strlen(buf)) *(buf+x+1)='\0';
        *(buf+x)=(char)c;
        ++(x);
        break;
      }
      /*}}}*/
    }
  } while (buf[0]!='\0' && c!=KEY_ENTER && c!='\r' && c!='\n');
  wmove(stdscr,y,promptlen);
  clrtoeol();
}
/*}}}*/
/* start sub shell */ /*{{{*/
static void shellcmd(struct Lines *l, const char *cmd)
{
  /* variables */ /*{{{*/
  pid_t pid;
  int fd[2];
  /*}}}*/

  refresh();
  if (pipe(fd)==-1)
  {
    printline(l,"",-1,(const char*)0,mystrsave(strerror(errno)));
    return;
  }
#ifdef HAS_VFORK
  switch (pid=vfork())
#else
  switch (pid=fork())
#endif
  {
    case -1: /* fork failed */ /*{{{*/
    {
      close(fd[0]);
      close(fd[1]);
      printline(l,"",-1,(const char*)0,mystrsave(strerror(errno)));
      break;
    }
    /*}}}*/
    case 0:
    {
      close(fd[0]);
      move(LINES-1,0);
      refresh();
      reset_shell_mode();
      write(1,"\n",1);
      dup2(fd[1],1);
      dup2(fd[1],2);
      close(fd[1]);
      if (cmd) execlp("/bin/sh","/bin/sh","-c",cmd,(const char*)0);
      else execlp("/bin/sh","/bin/sh",(const char*)0);
      exit(127);
      break;
    }
    default:
    {
      pid_t r;
      int status;
      char ln[128];
      FILE *fp;

      close(fd[1]);
      fp=fdopen(fd[0],"r");
      while (fgets(ln,sizeof(ln),fp))
      {
        size_t s;

        s=strlen(ln);
        if (s>0 && ln[s-1]=='\n') ln[s-1]='\0';
        printline(l,"",-1,(const char*)0,mystrsave(ln));
        fputs(ln,stdout);
        putchar('\n');
      }
      while ((r=wait(&status))!=-1 && r!=pid);
      fclose(fp);
      reset_prog_mode();
      touchwin(curscr);
      wrefresh(curscr);
    }
  }
}
/*}}}*/

/* main */ /*{{{*/
int main(int argc, char *argv[])
{
  /* variables */ /*{{{*/
  struct Lines lines;
  int c;
  const char **file=(const char**)0;
  int files;
  const char *indexfile="cs.out";
  int interactive;
  int buildindex;
  int force;
  /*}}}*/

  /* parse options */ /*{{{*/
  interactive=1;
  buildindex=1;
  force=0;
  linemode=0;
  while ((c=getopt(argc,argv,"h?bldf:s:u"))!=EOF) switch (c) 
  {
    case 'b': interactive=0; break;
    case 'd': buildindex=0; break;
    case 'f': indexfile=optarg; break;
    case 'u': force=1; break;
    case 'l': linemode=1; interactive=0; break;
    default: fprintf(stderr,USAGE); exit(1);
  }
  if (optind<argc)
  {
    files=0;
    file=xrealloc(file,(files+argc-optind)*(sizeof(char*)));
    for (; optind<argc; ++optind,++files) file[files]=argv[optind];
  }
  else
  {
    files=1;
    file=xmalloc(sizeof(char*));
    file[0]=".";
  }
  /*}}}*/
  update(indexfile,file,files,force);
  if (interactive) /* query database */ /*{{{*/
  {
    /* variables */ /*{{{*/
    int pos;
    int browse;
    chtype ch;
    const char *prompt[PROMPTS];
    /*}}}*/

    /* start curses */ /*{{{*/
    initscr();
    noecho();
    raw();
    nonl();
    keypad(stdscr,TRUE);
    clear();
    /*}}}*/
    /* init output buffer */ /*{{{*/
    lines.lines=0;
    lines.linesz=0;
    lines.s=0;
    /*}}}*/
    /* to do: find assignments to name
       find pattern
       find definition of name
    */
    mvaddstr(LINES-8,0,prompt[0]=FINDID);
    mvaddstr(LINES-7,0,prompt[1]=FINDCALLEE);
    mvaddstr(LINES-6,0,prompt[2]=FINDCALLER);
    mvaddstr(LINES-5,0,prompt[3]=FINDLIT);
    mvaddstr(LINES-4,0,prompt[4]=FINDINCLUDE);
    mvaddstr(LINES-3,0,prompt[5]=FINDFILE);
    mvaddstr(LINES-2,0,prompt[6]=FINDPOSIX);
    mvaddstr(LINES-1,0,prompt[7]=SHELLCMD);
    browse=1;
    pos=0;
    move(LINES-PROMPTS,strlen(prompt[0])+1);
    ch=wgetch(stdscr);
    do
    {
      switch (ch)
      {
        /* C-d                   -- exit browser */ /*{{{*/
        case '\004': browse=0; break;
        /*}}}*/
        /* cursor down, C-n, tab -- next input field */ /*{{{*/
        case KEY_DOWN:
        case '\016':
        case '\t':
        {
          if (++pos==PROMPTS) pos=0; 
          move(LINES-PROMPTS+pos,strlen(prompt[pos])+1);
          ch=wgetch(stdscr);
          break;
        }
        /*}}}*/
        /* C-r                   -- update database */ /*{{{*/
        case '\022':
        {
          freelines(&lines);
          update(indexfile,file,files,0);
          move(LINES-PROMPTS+pos,strlen(prompt[pos])+1);
        }
        /*}}}*/
        /* default               -- edit field and update output buffer */ /*{{{*/
        default:
        {
          static char field[128];

          if (ch!='\022')
          {
            field[0]='\0';
            editline(LINES-PROMPTS+pos,strlen(prompt[pos])+1,field,sizeof(field),ch);
          }
          if (field[0] || pos==6)
          {
            freelines(&lines);
            assert(lines.lines==0);
            switch (pos)
            {
              case 0: findid(&lines,field,indexfile); break;
              case 1: findcallee(&lines,field,indexfile); break;
              case 2: findcaller(&lines,field,indexfile); break;
              case 3: findlit(&lines,field,indexfile); break;
              case 4: findinclude(&lines,field,indexfile); break;
              case 5: findfile(&lines,field); break;
              case 6: findposix(&lines,indexfile); break;
              case 7: shellcmd(&lines,field); break;
            }
            ch=pagelines(&lines);
          }
          else ch=wgetch(stdscr);
        }
        /*}}}*/
      }
    } while (browse);
    /* end curses */ /*{{{*/
    echo();
    noraw();
    endwin();
    write(1,"\n",1);
    /*}}}*/
  }
  else if (linemode)
  {
    /* variables */ /*{{{*/
    char query[128];
    size_t len;
    /*}}}*/

    do
    {
      printf(">>>"); fflush(stdout);
      if (fgets(query,sizeof(query),stdin)==(char*)0) break;
      if ((len=strlen(query))>0 && query[len-1]=='\n') query[len-1]='\0';
      switch (query[0])
      {
        case '0': findid(&lines,&query[1],indexfile); break; 
        case '1': findcallee(&lines,&query[1],indexfile); break; 
        case '2': findcaller(&lines,&query[1],indexfile); break; 
        case '3': findlit(&lines,&query[1],indexfile); break; 
        case '4': findinclude(&lines,&query[1],indexfile); break; 
        case '5': findfile(&lines,&query[1]); break; 
        case '6': findposix(&lines,indexfile); break;
        case '7': shellcmd(&lines,&query[1]); break; 
        case 'r': update(indexfile,file,files,1); break;
        default: printf("unknown command\n");
      }
    } while (query[0]!='q');
  }
  /*}}}*/
  return (0);
}
/*}}}*/
