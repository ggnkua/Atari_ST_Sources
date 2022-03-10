/* IO.H

   Copyright (c)  Heimsoeth & Borland  1988

*/


int access(const char *filename, int amode);

/* WARNING: The following functions are not yet supported ! */

int _chmod(const char *filename, int func, ...);
int chmod(const char *filename, int func);
int _creat(const char *filename, int attrib);
int creat(const char *filename, ...);
int creatnew(const char *filename, int attrib);
int eof(int handle);
int ioctl(int handle, int cmd, ...);
int _open(const char *pathname, int access);
int open(const char *pathname, int access, ...);
int _setmode(int handle, int mode);
int unlink(const char *filename);


