/* "pi.c", program for computing digits of numerical value of PI.
Copyright (C) 1991 Aubrey Jaffer.
See the file "COPYING" for terms applying to this program.

(pi <n> <d>) prints out <n> digits of pi in groups of <d> digits.

'Spigot' algorithm origionally due to Stanly Rabinowitz.
This algorithm takes time proportional to the square of <n>/<d>.
This fact can make comparisons of computational speed between systems
of vastly differring performances quicker and more accurate.

Try (pi 100 5)
The digit size <d> will have to be reduced for larger <n> or an
overflow error will occur. */

short *calloc();
main(c,v)
int c;char **v;{
  int n=200,j=0,m,b=2,k=0,t,r=1,d=5;
  long q;
  short *a;
  if(c>1)n=atoi(v[1]);
  if(c>2)d=atoi(v[2]);
  while(k++<d)r=r*10;
  n=n/d+1;
  k=m=3.322*n*d;
  a=calloc(1+m,2);
  while(k)a[--k]=2;
  for(a[m]=4;j<n;b=q%r){
    q=0;
    for(k=m;k;){
      q+=a[k]*r;
      t=(2*k+1);
      a[k]=q%t;
      q=q/t;
      q*=k--;}
    printf("%0*d%s",d,b+q/r,++j%10?"  ":"\n");}
  puts("");}
