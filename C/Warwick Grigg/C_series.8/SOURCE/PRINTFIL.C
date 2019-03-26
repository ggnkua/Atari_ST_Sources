
#include <stdio.h>

main()
{
     char fname[60];
     int c;
     FILE *f, *p;   /* file handle and printer handle */

     p = fopen("PRN:", "w");  /* open printer for writing */
     if (p==NULL) {
          fprintf(stderr, "I can't open the printer device\n");
          exit(1);
     }
     fprintf(stdout, "Please enter file name : ");
     fgets(&fname[0], 60, stdin);
     fname[strlen(&fname[0])-1] = '\0';
     fprintf(stdout, "\n");
     f = fopen(&fname[0], "r");  /* open file for reading */
     if (f==NULL) {
          fprintf(stderr, "I can't open the file you specified\n");
          exit(2);
     }
     c = fgetc(f);       /* get first character from file */
     while (c!=EOF) {    /* while not end of file */
          fputc(c, p);   /* print character */
          c = fgetc(f);  /* get next character from file */
     }
     exit(0);
}
