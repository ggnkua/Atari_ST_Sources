/*	screendump 1.1 - dump the contents of the console
 *							Author: Kees J. Bot
 *								16 Dec 1994
 */
#define nil 0
#include <sys/types.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h>

#define BIOS_CRTBASE	0x00463L	/* BIOS parameters: CRT base. */
#define CRTBASE_MONO	0x03B4		/* Value of CRT base for mono mode. */

#define MONO_BASE	0xB0000L	/* Screen memory in monochrome mode. */
#define COLOR_BASE	0xB8000L	/* ... colour mode. */

#define COLUMNS		80
#define LINES		25

char MEMORY[] =		"/dev/mem";	/* Memory device to read screen. */
int mfd;				/* Open memory device. */

void tell(const char *message)
{
	write(2, message, strlen(message));
}

void fatal(const char *label)
{
	const char *err= strerror(errno);

	tell("screendump: ");
	tell(label);
	tell(": ");
	tell(err);
	tell("\n");
	exit(1);
}

long video_base(void)
/* Is it monochrome or colour? */
{
	static unsigned short bios_crtbase;

	if (lseek(mfd, (off_t) BIOS_CRTBASE, SEEK_SET) == -1) fatal(MEMORY);
	switch (read(mfd, &bios_crtbase, sizeof(bios_crtbase))) {
	case -1:
		fatal(MEMORY);
	default:
		tell("screendump: can't obtain BIOS parameter: short read\n");
		exit(1);
	case sizeof(bios_crtbase):
		/* Fine */;
	}

	return bios_crtbase == CRTBASE_MONO ? MONO_BASE : COLOR_BASE;
}

void main(void)
{
	unsigned char screen[COLUMNS * LINES * 2];
	unsigned char *ps;
	long base;
	int row;

	/* Open the memory device. */
	if ((mfd= open(MEMORY, O_RDONLY)) < 0) fatal(MEMORY);

	base= video_base();

	/* Read screen memory. */
	if (lseek(mfd, base, SEEK_SET) == -1) fatal(MEMORY);

	switch (read(mfd, screen, sizeof(screen))) {
	case -1:
		fatal(MEMORY);
	default:
		tell("screendump: can't obtain screen dump: short read\n");
		exit(1);
	case sizeof(screen):
		/* Fine */;
	}

	/* Print the contents of the screen line by line.  Omit trailing
	 * blanks.  Note that screen memory consists of pairs of characters
	 * and attribute bytes.
	 */
	ps= screen;
	for (row= 0; row < LINES; row++) {
		char line[COLUMNS + 1];
		char *pl= line;
		int column;
		int blanks= 0;

		for (column= 0; column < COLUMNS; column++) {
			if (*ps <= ' ') {
				/* Skip trailing junk. */
				blanks++;
			} else {
				/* Reinsert blanks and add a character. */
				while (blanks > 0) { *pl++= ' '; blanks--; }
				*pl++= *ps;
			}
			/* Skip character and attribute byte. */
			ps+= 2;
		}
		*pl++= '\n';
		if (write(1, line, pl - line) < 0) fatal("stdout");
	}
	exit(0);
}
