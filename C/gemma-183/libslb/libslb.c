/* Statically linked SLB loader
 *
 * (c) 2000 Draco/YC
 *
 * Must be compiled with -mshort, but as far as I can tell
 * may be linked even if the program is compiled without -mshort.
 *
 */

# include <mintbind.h>

long
_slbopen(char *fname, char *path, long ver, void *hnd, void *exec)
{
	return Slbopen(fname, path, ver, hnd, exec);
}

/* EOF */
