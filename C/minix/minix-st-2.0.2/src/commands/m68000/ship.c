/*
 * ship <n>: Parke Laufwerk mit SCSI-ID n.
 *
 * VS 09.01.2011
 */
 
#include <sys/types.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

void Write(int stream, char *s)
{
	write(stream, s, strlen(s));
}

void usage(char *name)
{
	Write(2, "Benutzung: ");
	Write(2, name);
	Write(2, " <n>. Parke Laufwerk <n>\n");
	exit(1);
}

void main(int argc, char *argv[])
{
  int i, fd;
  char *device = "/dev/hd0p";

  if (argc != 2) 
	usage(argv[0]);
  
  i = atoi(argv[1]);
  if (i < 0 || i > 6)
	usage(argv[0]);

  device[7] = i + '0';

  if ((fd = open(device, O_RDONLY)) < 0) {
	Write(2, "open schlug fehl\n");
  	exit(1);
  }

  close(fd);

  Write(1, "Laufwerk ");
  Write(1, device);
  Write(1, " wurde geparkt\n");
  exit(0);
}
