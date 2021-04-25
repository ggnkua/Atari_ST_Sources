#include <stdio.h>
#include <osbind.h>

#define RETURN 13
#define BACKSP 8
#define MAX 78
#define NOFILE -1
#define CTRL_Z 26

int code;

main()
{
   char filename[15], text[MAX];
   int file;

   file = start_file(filename);
   get_text(file, text);
   close(file);
}

start_file(filename)
char filename[];
{
   int file, ch;

   file = NOFILE;
   while (file == NOFILE) {
      printf("\nFilename: ");
      get_str(filename, 14);
      if ( ( file = open(filename,2) ) == NOFILE )
         file = creat(filename, 0);
      else {
         file = NOFILE;
         printf("File already exists!  Delete it? ");
         if ( (ch = getchar() ) == 'Y' || ch == 'y' )
            file = creat(filename, 0);
      }
   }
   printf("\n");
   return(file);
}

get_text(file, text)
int file;
char text[];
{
   int p;

   printf("Type your message:\n\n");
   code = 0;
   while (code != CTRL_Z) {
      p = get_str(text);
      text[p++] = '\n';
      text[p] = '\0';
      write(file, text, p);
   }
}

get_str(text)
char text[];
{
   int p;

   p = 0;
   code = Cconin();
   while (code != RETURN && code != CTRL_Z && p <= MAX) {
      if (code != BACKSP) {
         text[p++] = code;
      }
      else if (p > 0) {
         text[--p] = '\0';
         putchar(' ');
         putchar(BACKSP);
      }
      code = Cconin();
   }
   printf("\n");
   return(p);
}

      
