
// the demo-only code
#if DEMO
#include "mon.h"

char *demo_program_name = "xdb_demo.prg";

// used in machine.c to load Amiga executables

long create_basepage(void)
{
	return -1L;
}

// used in proc.c to TSR exit - should never happen

word start_tsr(word *x)
{
	internal_error(42);
	return 0;
}

// used in commands.c to load any binary file for execution

word load_bin_exec(void)
{
	return ERRM_NOTINDEMO;
}

char *demo_message = "X-Debug is an advanced debugger for Atari ST/TT \
computers. This demonstration version contains all of the features of \
the full version except that it can only debug one particular program.\n\
X-Debug runs on STs and TTs with any monitor type. 1M of RAM is recommended. \
Written by Andy Pennell, the creator of DevpacST.\n\
X-Debug costs œ24.95 from The ST Club, 2 Broadway, Nottingham, NG1 1PS \
England. Phone (0602) 410241.\n\n\
X-Debug works in all screen modes and supports overscan and external monitors \
such as the Atari SM194 and Reflex cards. (This demo version is more restrictive). \n\
o Single-step & Breakpoint at Assembler level and Source level\r\
o Automatically copes with multiple source files\r\
o Can display code as source, assembler and mixed modes\r\
o Works on all 680x0 processors and 68881/2 co-processors\r\
o Capable of debugging Desk Accessories and CPXs (not demo version)\r\
o Can run from an AUTO folder to catch all exceptions (not demo)\n\@\
This demonstration version of X-Debug cannot load external programs, so \
a sample program is built-in and automatically loaded for you to experiment \
with.\n\
This sample program is taken from the Tutorial section of the manual. It \
contains a deliberate bug that causes a bus error, and the debugging \
process is fully detailed. (The program was compiled with Lattice C 5 \
with the -d2 debug option).\n\
Windows may be moved with the mouse by dragging on the title bar. They \
may be resized by dragging on the bottom right corner. Clicking on the \
body of a window makes it current.\
@Brief Key Summary\n\
The current window is shown with a solid border. Other windows can be \
made current by clicking on them with the mouse, by cycling through them \
with Tab, or by pressing Alt-<digit>. The cursor keys are often useful in \
many types of window\n\
    F8      Source step\r\
    F10     Source step over\n\
    Ctrl-Z  Assembler step\r\
    Ctrl-A  Assembler step over\n\
    F3      Cycle code display mode\r\
    F4      Display other screen\r\
    Alt-A   Set address of current window\r\
    Alt-Q   Quit@\
For this program to work correctly, it must be called XDB_DEMO.PRG. Renaming \
the file will cause it to fail to execute correctly.\n\
Useful commands to try (case insensitive):\r\
EVAL varname         Displays any expression\r\
WINDOW OPEN LOCAL    Displays known local variables\r\
LOAD AGAIN           Restarts program under investigation\r\
HELP command         Further information on any command\r\
LIST HELP            Shows all Help summaries\n\
For further information or to order, contact:\rThe ST Club, 2 Broadway, Nottingham, NG1 1PS \
England. Phone (0602) 410241\n\
The author is available on CIX under the id of 'amp' and welcomes any \
technical enquiries.";

void demo_intro(void)
{
word err;

	err = demo_alert(demo_message);
	
}

// called to find startup files. Hacked to set up offsets and refer
// to this file only

static int get_special_index(char *name)
{
	if (strcmp(name, HELP_STARTUP)==0)
		return 2;
	else if (strcmp(name, SCRIPT_STARTUP)==0)
		return 4;
	return -1;
}

bool find_file(char *raw, char *result, char **extlist)
{
int which;

	which = get_special_index(raw);
	if (which < 0)
		return FALSE;

	strcpy(result, raw);					// just use basename
	return TRUE;
}

static long bytes_left;

FILE *special_fopen(char *name, char *mode)
{
int which;
FILE *fp;

	which = get_special_index(name);
	if (which < 0)
		return NULL;
	
	fp = fopen(demo_program_name, mode);
	if (fp)
		{
		fseek( fp, get_demo_long( which ) - get_demo_long( -1 ), SEEK_SET );
		bytes_left = get_demo_long( which+1 );
		}
	return fp;
}

// used in place of fgets when reading dummy files, to ensure
// EOF reported correctly

char *special_fgets(char *buffer, int length, FILE *fp)
{
char *result;

	if (bytes_left <= 0)
		return NULL;

	result = fgets(buffer, length, fp);
	if (result)
		{
		bytes_left -= strlen(buffer) + 1;			// +1 for CR/LF replacement
		}
	return result;	
}

#endif
