/* Output from p2c, the Pascal-to-C translator */
/* From input file "dist/examples/self.p" */


#include <p2c/p2c.h>


typedef Char s[256];

typedef long n;


Static s a[100];
Static long i, j;


Static long t(a)
long a;
{
  if (a < 7)
    return a;
  else
    return (a + 11);
}


Static Char *q(Result, a_)
Char *Result, *a_;
{
  s a;
  n j;
  Char STR1[256];

  strcpy(a, a_);
  for (j = strlen(a) - 1; j >= 0; j--) {
    if (a[j] == '\'') {
      sprintf(STR1, "'%s", a + j);
      strcpy(a + j, STR1);
    }
  }
  return strcpy(Result, a);
}


main(argc, argv)
int argc;
Char *argv[];
{
  Char STR2[256];

  PASCAL_MAIN(argc, argv);
  strcpy(a[0], "program self(input, output);");
  strcpy(a[1], "type s = string[255]; n=integer;");
  strcpy(a[2], "var a : array [1..100] of s; i,j : integer;");
  strcpy(a[3],
    "function t(a:integer):integer; begin if a<7 then t:=a else t:=a+11 end; function q(a:s):s;");
  strcpy(a[4],
    " var j:n;begin for j:=strlen(a)downto 1 do if a[j]=#39 then strinsert(#39,a,j);q:=a;end;");
  strcpy(a[5], "begin");
  strcpy(a[17], "   for i := 1 to 11 do begin setstrlen(a[i+6], 0);");
  strcpy(a[18],
    "      strwrite(a[i+6],1,j,'   a[',t(i):1,'] := ''', q(a[t(i)]), ''';');");
  strcpy(a[19], "   end;");
  strcpy(a[20], "   for i := 1 to 22 do writeln(a[i]);");
  strcpy(a[21], "end.");
  for (i = 1; i <= 11; i++) {
    sprintf(a[i + 5], "   a[%ld] := '%s';", t(i), q(STR2, a[t(i) - 1]));
    j = strlen(a[i + 5]) + 1;
  }
  for (i = 1; i <= 22; i++)
    puts(a[i - 1]);
  exit(EXIT_SUCCESS);
}



/* End. */
