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
#include <curses.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pwd.h>
#include <unistd.h>

#include "alloc.h"
#include "cat.h"
#include "pager.h"
/*}}}*/
/* #defines */ /*{{{*/
#ifndef _PATH_VI
#define _PATH_VI "/usr/bin/vi"
#endif

#define PAGELINES     (LINES-PROMPTS-1)
/*}}}*/

/* variables */ /*{{{*/
static struct
{
  const char *editor, *flag;
}
gotoLine[]=
{
  { "vi", "+%d" },
  { "origami", "-l%d" },
  { "modeori", "-l%d" },
  { "emori", "-l%d" },
  { "emacs", "+%d" },
  { "cemacs", "+%d" },
  { "Xemacs", "+%d" },
  { "xemacs", "+%d" },
  { "jmacs", "+%d" },
  { "joe", "+%d" },
  { "jed", "+%d" },
  { "fe", "-l%d" },
  { "vim", "+%d" }
};

int linemode;
/*}}}*/

/* edit */ /*{{{*/
static void edit(const char *file, int line)
{
  pid_t pid;

  refresh();
#ifdef HAS_VFORK
  switch (pid=vfork())
#else
  switch (pid=fork())
#endif
  {
    /*      -1 */ /*{{{*/
    case -1: break; /* shit happens */
    /*}}}*/
    /*       0 */ /*{{{*/
    case 0:
    {
      const char *shell;
      const char *editor;
      size_t editorlen;
      char linestr[20];
      int i;

      if ((shell=getenv("SHELL"))==(const char*)0)
      {
        struct passwd *pwd;

        if ((pwd=getpwuid(getuid()))==(struct passwd*)0)
        {
          shell="/bin/sh";
        }
        else
        {
          shell=pwd->pw_shell;
        }
      }
      editor=getenv("CSCOPE_VIEWER");
      if (editor==(const char*)0) editor=getenv("VISUAL");
      if (editor==(const char*)0) editor=getenv("EDITOR");
      if (editor==(const char*)0) editor=_PATH_VI;
      editorlen=strlen(editor);
      linestr[0]='\0';
      for (i=0; i<sizeof(gotoLine)/sizeof(gotoLine[0]); ++i)
      {
        size_t l;
         
        if (editorlen>=(l=strlen(gotoLine[i].editor)) && strcmp(editor+editorlen-l,gotoLine[i].editor)==0)
        {
          sprintf(linestr,gotoLine[i].flag,line);
          break;
        }
      }
      move(LINES-1,0);
      curs_set(1);
      refresh();
      reset_shell_mode();
      write(1,"\n",1);
      if (file)
      {
        if (linestr[0]) execlp(editor,editor,linestr,file,(const char*)0);
        else execlp(editor,editor,file,(const char*)0); 
      }
      else execlp(shell,shell,(const char*)0);
      exit(127);
      break;
    }
    /*}}}*/
    /* default */ /*{{{*/
    default:
    {
      pid_t r;
      int status;

      while ((r=wait(&status))!=-1 && r!=pid);
      reset_prog_mode();
      keypad(stdscr,TRUE); /* for compatibility with cursed curses' */
      touchwin(curscr);
      wrefresh(curscr);
    }
    /*}}}*/
  }
}
/*}}}*/
/* showlines */ /*{{{*/
static void showlines(struct Lines *lines, int cury, int offy, int showcur)
{
  int y,filelen,funlen;

  /* determine file and function field width */ /*{{{*/
  filelen=strlen(FILESTR);
  funlen=strlen(FUNCTION);
  for (y=offy; y<(offy+PAGELINES); ++y)
  {
    if (y<lines->lines)
    {
      if (((int)strlen(lines->s[y].filename))>filelen) filelen=strlen(lines->s[y].filename);
      if (lines->s[y].function && ((int)strlen(lines->s[y].function))>funlen) funlen=strlen(lines->s[y].function);
    }
  }
  /*}}}*/
  mvprintw(0,0,"%-*s %-*s %s",filelen,FILESTR,funlen,FUNCTION,LINE);
  clrtoeol();
  for (y=offy; y<offy+PAGELINES; ++y)
  {
    move(1+y-offy,0);
    clrtoeol();
    if (y<lines->lines)
    {
      int curx,foo;
      unsigned const char *s;

      assert(lines->s[y].source!=(char*)0);
      if (showcur && y==cury) attron(A_REVERSE);
      printw("%-*s %-*s ",filelen,lines->s[y].filename,funlen,lines->s[y].function ? lines->s[y].function : "");
      if (lines->s[y].line>=0) printw("%d ",lines->s[y].line);
      s=(unsigned const char*)lines->s[y].source;
      getyx(stdscr,foo,curx);
      for (; *s && curx<COLS; ++curx) { addch((chtype)*s); ++s; }
      for (; curx<COLS; ++curx) addch(' ');
      if (showcur && y==cury) attroff(A_REVERSE);
    }
  }
  move(1+cury-offy,0);
}    
/*}}}*/

/* freelines  -- empty line array */ /*{{{*/
void freelines(struct Lines *l)
{
  assert(l!=(struct Lines*)0);
  assert(l->lines>=0);
  while (l->lines>0)
  {
    --l->lines;
    if (l->s[l->lines].function) free(l->s[l->lines].function);
    free(l->s[l->lines].source);
    free(l->s[l->lines].filename);
  }
}
/*}}}*/
/* printline  -- add one line of output */ /*{{{*/
void printline(struct Lines *l, const char *file, int line, const char *function, char *s)
{
  assert(l!=(struct Lines*)0);
  assert(file!=(const char*)0);
  assert(s!=(const char*)0);
  if (linemode)
  {
    printf("%s %s %d %s\n", file, function ? function : "(null)", line, s);
    fflush(stdout);
  }
  else
  {
    if (l->lines==l->linesz) l->s=xrealloc(l->s,(l->linesz+=256)*sizeof(l->s[0]));
    l->s[l->lines].filename=mystrsave(file);
    l->s[l->lines].line=line;
    l->s[l->lines].function=function ? mystrsave(function) : (char*)0;
    l->s[l->lines].source=s;
    ++l->lines;
  }
}
/*}}}*/
/* pagelines  -- page through lines */ /*{{{*/
chtype pagelines(struct Lines *lines)
{
  /* variables */ /*{{{*/
  int offy,browse,cury;
  chtype ch;
  /*}}}*/

  assert(lines!=(struct Lines*)0);
  curs_set(0);
  browse=1;
  cury=0;
  offy=0;
  do
  {
    showlines(lines,cury,offy,1);
    refresh();
    switch (ch=wgetch(stdscr))
    {
      /* space, +, next page     -- go to next page */ /*{{{*/
      case ' ':
      case '+':
      case KEY_NPAGE:
      {
        if (offy+PAGELINES<lines->lines) offy+=PAGELINES;
        cury+=PAGELINES;
        if (cury>lines->lines-1) cury=lines->lines-1;
        break;
      }
      /*}}}*/
      /* backspace, -, prev page -- go to previous page */ /*{{{*/
      case KEY_BACKSPACE:
      case '\010':
      case '-': 
      case KEY_PPAGE:
      {
        if (offy>PAGELINES) offy-=PAGELINES; 
        else offy=0; 
        cury-=PAGELINES;
        if (cury<0) cury=0;
        break;
      }
      /*}}}*/
      /* C-p, cursor up          -- move to previous line */ /*{{{*/
      case KEY_UP:
      case '\020':
      {
        if (cury>0) --cury;
        if (cury<offy) --offy;
        break;
      }
      /*}}}*/
      /* C-n, cursor down        -- move to next line */ /*{{{*/
      case KEY_DOWN:
      case '\016':
      {
        if (cury<(lines->lines-1)) ++cury;
        if (cury>=(offy+PAGELINES)) ++offy;
        break;
      }
      /*}}}*/
      /* return                  -- edit specified file, or fall through */ /*{{{*/
      case '\n':
      case '\r':
      {
        if (cury<lines->lines && lines->s[cury].filename[0])
        {
          edit(lines->s[cury].filename,lines->s[cury].line);
          curs_set(0);
        }
        break;
      }
      /*}}}*/
      /* any other key           -- exit pager */ /*{{{*/
      default: browse=0;
      /*}}}*/
    }
  } while (browse);
  showlines(lines,cury,offy,0);
  curs_set(1);
  return ch;
}
/*}}}*/
