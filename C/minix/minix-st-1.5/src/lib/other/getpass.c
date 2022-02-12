#include <lib.h>
#include <sgtty.h>
#include <unistd.h>
#include <stdio.h>


PRIVATE char pwdbuf[9];

char *getpass(prompt)
char *prompt;
{
  int i = 0, save;
  struct sgttyb tty;

  prints(prompt);
  ioctl(0, TIOCGETP, &tty);
  save = tty.sg_flags;
  tty.sg_flags = tty.sg_flags & ~ECHO;
  ioctl(0, TIOCSETP, &tty);
  i = read(0, pwdbuf, 9);
  while (pwdbuf[i - 1] != '\n') read(0, &pwdbuf[i - 1], 1);
  pwdbuf[i - 1] = '\0';
  tty.sg_flags = save;
  ioctl(0, TIOCSETP, &tty);
  prints("\n");
  return(pwdbuf);
}
