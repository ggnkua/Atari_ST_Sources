#include <sys/types.h>
#include <minix/config.h>
#include <fcntl.h>
#include <sgtty.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

_PROTOTYPE(int main, (int argc, char **argv));

int main(argc, argv)
int argc;
char **argv;
{
    FILE *f;
    struct fnthdr hdr;
    void *fntptr;
    size_t size;
    int fd;
    
    if (argc != 2) 
    {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        exit(-1);
    }
    f = fopen(argv[1], "r");
    if (f == (FILE *)NULL)
    {
        perror(argv[1]);
        exit(-1);
    }
    fread(&hdr.width, (size_t)1, (size_t)1, f);
    fread(&hdr.heigth, (size_t)1, (size_t)1, f);
    size = (128 / 8) * hdr.width * hdr.heigth;
    fntptr = (void *)malloc(size);
    if (fread(fntptr, (size_t)1, size, f) != size)
    {
        fprintf(stderr, "font file too short\n");
        exit(-1);
    }
    hdr.addr = fntptr;
    
    fd = open("/dev/tty", 1);
    if (fd < 0)
    {
        perror("/dev/tty");
        exit(-1);
    }
    if (ioctl(fd, VDU_LOADFONT, (struct sgttyb *)&hdr) != 0)
    {
        fprintf(stderr, "failed\n");
        exit(-1);
    }
    close(fd);
    free(fntptr);
    return(0);
}
