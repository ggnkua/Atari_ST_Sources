/*
 *	readenv() - set macro values from the environment
 */
#include <stdio.h>

readenv()
{
	extern long	_base;
	char	*envp, *p, *strchr();
	char	buf[256];

	envp = *((char **) (_base + 0x2c));

	for (; strncmp(envp, "ARGV=", 5) != 0 ; envp += strlen(envp) + 1) {
		strcpy(buf, envp);
		if ((p = strchr(buf, '=')) == NULL)
			return;
		*p++ = '\0';
		setmacro(buf, p);
	}
}
