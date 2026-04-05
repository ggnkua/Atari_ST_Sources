#include <getopt.h>
#include <stdio.h>

int main(int argc, char **argv)
{
     const char *optstring = "abc:def:gh";
     char ch;
     while ((ch = getopt(argc, argv, optstring)) != -1) { 
         if (optarg) printf("ch = '%c', optarg = '%s'\r\n", ch, optarg);
         else printf("ch = '%c'\r\n", ch);
         if (ch == '?') break;
     }
     return 0;
}

