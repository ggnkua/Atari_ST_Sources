#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <utime.h>

_PROTOTYPE(int main, (int argc, char **argv));
_PROTOTYPE(void convert, (char *name));

void p_err(char *s)
{
  write(2, s, strlen(s));
}

void convert(name)
char *name;
{
    int fd;
    char olddata[8];
    char newdata[8];
    struct stat st;
    struct utimbuf ut;

    if (stat(name, &st) < 0) {
	perror("cannot stat");
	return;
    }

    fd = open(name, O_RDWR);
    if (fd < 0) {
	perror("cannot open");
	return;
    }
    if (read(fd, olddata, 8) != 8) {
	perror("error reading");
	close(fd);
	return;
    }
    if ((olddata[0] != 1) || (olddata[1] != 3))
    {
	p_err(name);
	p_err(": not an old style executable\n");
        close(fd);
        return;
    }
    newdata[0] = olddata[3];
    newdata[1] = olddata[2];
    newdata[2] = olddata[1];
    newdata[3] = olddata[0];
    newdata[4] = olddata[7];
    newdata[5] = olddata[6];
    newdata[6] = olddata[5];
    newdata[7] = olddata[4];
    
    lseek(fd, 0, SEEK_SET);

    if (write(fd, newdata, 8) != 8) {
	perror("write error");
    }
    close(fd);
    ut.actime = st.st_atime;
    ut.modtime = st.st_mtime;
    utime(name, &ut);
    
}

int main(argc, argv)
int argc;
char **argv;
{
    if (argc == 1)
    {
        p_err("usage: binconv <file list>\n");
        exit(1);
    }
    argc--;
    argv++;
    while (argc)
    {
        convert(*argv);
	argc--;
	argv++;
    }
    return(0);
}

