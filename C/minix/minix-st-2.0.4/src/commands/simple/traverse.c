/* traverse - traverse a tree		Author:	Gary Perlman */

#include <sys/types.h>
#include <sys/dir.h>
#include <string.h>
#include <limits.h>
#include <unistd.h>
#include <stdio.h>

#define STANDALONE

#define	DIR	FILE
#define	MAXNAME (NAME_MAX+2)
#define	opendir(path) fopen (path, "r")
#define closedir(dirp) fclose (dirp)
#define readdir myreaddir	/* someday this should use the library
				 * dirent routines, and report errors */

_PROTOTYPE(int main, (int argc, char **argv));
_PROTOTYPE(struct direct *readdir, (DIR *dirp));
_PROTOTYPE(char *namedir, (struct direct *entry));
_PROTOTYPE(void traverse, (char *path, void (*func)(char *, int, int)));
_PROTOTYPE(void tryverse, (char *file, int type, int pos));

struct direct *readdir(dirp)
DIR *dirp;
{
  static struct direct entry;
  if (dirp == NULL) return(NULL);
  for (;;) {
	if (fread(&entry, sizeof(struct direct), (size_t)1, dirp) == 0)
		return(NULL);
	if (entry.d_ino) return(&entry);
  }
}

char *namedir(entry)
struct direct *entry;
{
  static char name[MAXNAME];
  return(strncpy(name, entry->d_name, (size_t)NAME_MAX));
}


#include <sys/stat.h>
#define	isdir(path) (stat(path, &buf) ? 0 : (buf.st_mode&S_IFMT)==S_IFDIR)

void traverse(path, func)
char *path;
#ifdef __STDC__
void (*func) (char *, int, int);
#else
void (*func) ();
#endif
{
  DIR *dirp;
  struct direct *entry;
  struct stat buf;
  int filetype = isdir(path) ? 'd' : 'f';
  (*func) (path, filetype, 0);
  if (filetype == 'd') {
	if (chdir(path) == 0) {
		if (dirp = opendir(".")) {
			while (entry = readdir(dirp)) {
				char name[MAXNAME];
				(void) strcpy(name, namedir(entry));
				if (strcmp(name, ".") && strcmp(name, ".."))
					traverse(name, func);
			}
			(void) closedir(dirp);
		}
		(void) chdir("..");
	}
  }
  (*func) (path, filetype, 1);
}

#ifdef STANDALONE

static Indent = 0;

void tryverse(file, type, pos)
char *file;
int type;
int pos;
{
  int in;
  if (pos == 0) {
	for (in = 0; in < Indent; in++) putchar('\t');
	if (type == 'd') {
		printf("%s/\n", file);
		Indent++;
	} else
		puts(file);
  } else if (type == 'd')
	Indent--;
}

int main(argc, argv)
int argc;
char **argv;
{
  char *root = argc > 1 ? argv[1] : ".";
  traverse(root, tryverse);
  return(0);
}

#endif
