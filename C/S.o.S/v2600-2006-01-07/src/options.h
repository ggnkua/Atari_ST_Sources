#ifndef OPTIONS_H
#define OPTIONS_H

#define NTSC 0
#define PAL 1
#define SECAM 2

/* Options common to all ports of x2600 */
extern struct BaseOptions {
  int rr;
  int tvtype;
  int lcon;
  int rcon;
  int bank;
  int magstep;
  char filename[80];
  int sound;
  int swap;
  int realjoy;
  int limit;
  int mousey;
  int mitshm;
  int dbg_level;
} base_opts;

int 
parse_options(int argc, char **argv);

#endif
