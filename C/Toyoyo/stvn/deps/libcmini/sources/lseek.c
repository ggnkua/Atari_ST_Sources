#include <mint/osbind.h>
#include <unistd.h>


off_t lseek(int fd, off_t offset, int whence)
{
	return Fseek(offset, fd, whence);
}
