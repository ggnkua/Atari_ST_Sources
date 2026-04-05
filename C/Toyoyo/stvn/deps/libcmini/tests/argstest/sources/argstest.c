/*
 * malltest.c
 *
 *  Created on: 01.06.2013
 *      Author: mfro
 */

#include <stdio.h>
#include <stdlib.h>
#include <mint/osbind.h>
#include <mint/basepage.h>

extern struct basep *_BasPag;

int main(int argc, char *argv[], char *envp[])
{
	int i;

	while (Cconis()) Cconin();

	printf("cmdline=%s\r\n", (char *) (_BasPag->p_cmdlin) + 1);
	printf("argc=%d\r\n", argc);
	for (i = 0; i < argc; i++)
		printf("argv[%d] = %s\r\n", i, argv[i]);

	printf("press any key\r\n");
	Cconin();
	
	i = 0;

	while (envp[i] != NULL)
	{
		printf("envp[%d] = %s\r\n", i, envp[i]);
		i++;
	}
	i++;

	(void) Cconws("press a key to return to desktop\r\n");
	Cconin();

	return 0;
}

