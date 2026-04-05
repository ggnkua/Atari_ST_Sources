#include <mint/mintbind.h>
#include <unistd.h>

int isatty (int handle) {
	long r, pos;

	pos = Fseek(0, handle, SEEK_CUR);
	r = Fseek(1, handle, SEEK_SET);
	Fseek(pos, handle, SEEK_SET);
	return r == 0;
}
