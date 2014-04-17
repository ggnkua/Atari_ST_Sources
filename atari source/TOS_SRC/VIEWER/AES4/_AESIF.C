/* _aesif.c - replacement for Lattice _AESif
 *=======================================================================
 * 920628 kbad
 */
#include <aes.h>
int __regargs _aes(short,void*);
int __regargs _AESif(unsigned int fn) { return _aes((short)fn, _AESpb); }
