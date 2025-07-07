
/* program to accompany X-Debug tutorial */

/* program searches a word list for vowels, but doesn't quite work */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *find_string[] = {
	"first",
	"second",
	"third",
	NULL
	};

/* count how many of a particular character are in a string */

int count_char(char *string, char c)
{
int count = 0;

	for (;;)
		{
		string = strchr(string, c);
		if (string==NULL)
			return count;					// stop if no more
		count++;							// else increase count
		string++;							// and inc pointer to next char
		}
}

/* count how many vowels are in a particualr string */

int count_vowels(char *string)
{
int count;

	count  = count_char(string, 'a');
	count += count_char(string, 'e');
	count += count_char(string, 'i');
	count += count_char(string, 'o');
	count += count_char(string, 'u');

	return count;
}

int main(int argc, char *argv[])
{
char **which;
char *p;

	which = find_string;
	do
		{
		int c;
		
		p = *which++;
		c = count_vowels(p);
		printf("%s:%d\n", p, c);
		}	
	while (p);

	return 0;
}
