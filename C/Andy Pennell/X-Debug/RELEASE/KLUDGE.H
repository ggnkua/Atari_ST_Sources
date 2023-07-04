
/* before including this define KLUDGE to be a unique name within
the caller source file e.g.
#define KLUDGE(x) __junk ## x
*/
	
char near KLUDGE(1);
char near KLUDGE(2) = 1;
char far KLUDGE(3);
char far KLUDGE(4) = 1;
