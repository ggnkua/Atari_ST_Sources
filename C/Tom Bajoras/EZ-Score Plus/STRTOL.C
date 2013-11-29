#include <stdio.h>

static int skipwhite(ptr)
char **ptr;
{
    int ch = *(*ptr)++;

    while (ch == ' ' || ch == '\t' || ch == '\n')
	ch = *(*ptr)++;
    return ch;
}

static int val(ch, base)
int ch, base;
{
    int result = -1;

    if ((ch == 'x' || ch == 'X') && base == 16) return 0;
    if (ch >= '0' && ch <= '9') result = ch - '0';
    else if (ch >= 'a') result = ch - 'a'+10;
    else if (ch >= 'A') result = ch - 'A'+10;
    if (result > base) return -1;
    else return result;
}

long strtol(str, ptr, base)
char *str;
char **ptr;
int base;
{
    int ch, temp, neg = 0;
    long result = 0;

    ch = skipwhite(&str);

    if (ch == '-')
	neg = 1, ch = *str++;
    while ((temp = val(ch, base)) != -1) {
	result = result*base + temp;
	ch = *str++;
    }
    if (ptr != (char **)NULL)
	*ptr = str;
    return neg ? -result : result;
}

long atol(str)
char *str;
{
    return strtol(str, (char **)NULL, 10);
}

long atoi(str)
char *str;
{
    return (int)strtol(str, (char **)NULL, 10);
}
