#include <stdio.h>
#include <unistd.h>
#include <mint/osbind.h>
#include <sys/types.h>
#include "lib.h"

#ifdef STDIO_MAP_NEWLINE
# define BUFSIZE  8192
#endif /* defined STDIO_MAP_NEWLINE */

size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream)
{
    long rc;

#ifdef STDIO_MAP_NEWLINE
    int  fd = (int)FILE_GET_HANDLE(stream);

    if (stream->__mode.__binary)
    {
        rc = Fwrite(fd, size * nmemb, ptr);
    } else
    {
        const unsigned char* str = ptr;
        size_t n = size * nmemb;

        rc = 0;

        while (n > 0)
        {
            char buffer[BUFSIZE];
            register size_t put;
            register size_t got;
            size_t limit = (BUFSIZE > n) ? n : BUFSIZE;
            long addcr = 0; /* count automatically added carriage returns */

            for (put = 0, got = 0; put < limit && got < n; put++, got++)
            {
                if (str[got] == '\n')
                {
                    if (got == 0 || str[got - 1] != '\r')
                    {
                        if (got > 0 || stream->__last_char != '\r')
                        {
                            buffer[put++] = '\r';
                            ++addcr;
                        }
                    }
                }
                stream->__last_char = buffer[put] = str[got];
            }

            if (put > 0)
            {
                long count;

                count = Fwrite(fd, put, buffer);

                if (count < 0)
                {
                    rc = count;
                    break;
                } else
                    rc += count - addcr;
            }

            str += got;
            n -= got;
        }
    }
#else
    rc = Fwrite((int)FILE_GET_HANDLE(stream), size * nmemb, ptr);
#endif /* defined STDIO_MAP_NEWLINE */

	if (rc < 0)
	{
		stream->__error = 1;
		__set_errno(-rc);
		rc = 0;
	} else
	{
		rc /= size;
	}

	return rc;
}
