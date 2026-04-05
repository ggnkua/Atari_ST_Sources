#include <string.h>
#include <stdlib.h>

char *strndup(const char *src, size_t n)
{
  char* result;
  size_t length = strlen (src);
  if (length > n)
    length = n;
  
  result = malloc (length + 1);
  if (result == NULL)
    return NULL;
  
  result[length] = '\0';
  return memcpy (result, src, length);
}

