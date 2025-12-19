 
int file_putc(char c, FILE *f)
 {
   putc(c,f);
   if (ferror(f)) return EOF;
   return 0;
 }
#define putc file_putc
 
