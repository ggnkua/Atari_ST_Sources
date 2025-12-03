
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "global.h"

struct file_state {
  char *old_curfile;
  char *old_curdir;
  FILE *old_inf;
  unsigned long old_lastline, old_thisline, old_nextline;
};

#define MAX_BLANK_LINES 5

/*
   sync_line() -- generate a synchronization line of the form "# line-num
   filename", where line-num is determined by |this_line|. Sets |last_line|
   to |this_line|.  |n| is an additional parameter to print on the line, 1
   when you enter a file and 2 when you leave it; normally it is 0 and not
   printed
*/
void sync_line(n)
  int n;
{
  switch (sl_style) {
  case SL_NONE:
    break;
  case SL_LINE:
    fprintf(outf, "#line %lu \"%s\"\n", this_line, cur_file);
    break;
  case SL_NORMAL:
    switch (n) {
    case 0:
      fprintf(outf, "# %lu \"%s\"\n", this_line, cur_file);
      break;
    case 1:
    case 2:
      fprintf(outf, "# %lu \"%s\" %d\n", this_line, cur_file, n);
      break;
    default:
      bugchk("can't sync_line(%lu,%d)\n", this_line, n);
      exit(1);
    }
    break;
  }
  last_line = this_line;
}

/*
   synchronize() -- synchronize the line number in the output file with the
   input file, either by spitting line feeds or generating a synch line.
   This should not be used if the filename has changed; use sync_line() for
   that.
*/
void synchronize()
{
  if (last_line > this_line || this_line - last_line > MAX_BLANK_LINES)
    sync_line(0);
  else
    for (; last_line < this_line; last_line++)
      fputc('\n', outf);
}

/*
   process_line() -- read a line from the input file token by token, doing
   the appropriate thing
*/
static int process_line()
{
  TokenP T;
  Macro *M;
  int start_of_line = 1;

  for (;;) {

    /*
       we must be careful here -- the '#' for a directive cannot come from a
       macro expansion
    */
    T = (start_of_line ? token(): exp_token());
    if (T->type == EOF_) {
      free_token(T);
      return 0;
    }
    if (T->type == EOL) {
      if (keep_comments)
	print_token(T);
      else
	fputc('\n', outf);
      last_line++;
      free_token(T);
      if (start_of_line)
	continue;
      else
	break;
    }
    synchronize();
    if (start_of_line) {
      /* check for preprocessor directive */
      if (T->type == POUND) {
	free_token(T);
	directive();
	continue;
      }

      /*
         if we're in the false branch of an #ifdef and we're not a
         preprocessor directive, just pitch the line and get the next one.
      */
      if (!cond_true()) {
	free_token(T);
	flush_line();
	continue;
      }

      /*
         If we get here, we're dealing with a normal line.  We push back the
         token we just read and re-read it with exp_token() to make sure it
         gets expanded.
      */
      start_of_line = 0;
      push_tlist(T);
      T = exp_token();
    }
    print_token(T);
    free_token(T);
  }
  return 1;
}

/* path_of_file() -- extract the pathlist from filename |fnam| */
static char *path_of_file(fnam)
  char *fnam;
{
  char *s, *path;

  if (!(s = strrchr(fnam, PATH_SEP))) {
    path = mallok(2);
    path[0] = '.';
    path[1] = '\0';
  } else
    path = copy_filename(fnam, (int)(s - fnam));
  return path;
}

/*
   save_state() -- save various values particular to the current input file,
   just before opening a new file to process
*/
static void save_state(FS)
  struct file_state *FS;
{
  FS->old_curfile = cur_file;
  FS->old_curdir = I_list[0];
  FS->old_lastline = last_line;
  FS->old_thisline = this_line;
  FS->old_nextline = next_line;
  FS->old_inf = inf;
}

/* restore_state() -- restore values saved with save_state() */
static void restore_state(FS)
  struct file_state *FS;
{
  cur_file = FS->old_curfile;
  I_list[0] = FS->old_curdir;
  last_line = FS->old_lastline;
  this_line = FS->old_thisline;
  next_line = FS->old_nextline;
  inf = FS->old_inf;
}

/* process_file() -- open and process file |fnam| */
void process_file(fnam)
  char *fnam;
{
  struct file_state FS;

  /* save state values from the previous file */
  save_state(&FS);
  if (streq(fnam, STDIN_NAME))
    inf = stdin;
  else if (!(inf = xfopen(fnam, "r")))
    fatal("cannot open input file %s", fnam);
  cur_file = strdup(fnam);
  I_list[0] = path_of_file(fnam);
  this_line = next_line = 1;
  sync_line(1);
  while (process_line()) ;
  if (include_level == 0)
    endif_check();
  if (inf != stdin)
    fclose(inf);
  free(cur_file);
  free(I_list[0]);
  restore_state(&FS);
}
