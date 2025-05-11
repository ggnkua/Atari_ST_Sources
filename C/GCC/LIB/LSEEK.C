/* seek to a position in a file */

#ifdef DEBUG
extern int stderr;
#endif

int lseek(fd, offset, mode)
int fd;
long offset;
int mode; 
{
  int result = trap_1_wlww(0x42, offset, fd, mode);
#ifdef DEBUG
  fprintf(stderr, "lseek(%d, %d, %d)->%d\n", fd, offset, mode);
#endif
  return(result);
}
