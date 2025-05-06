#include "d:\include\osbind.mjh"

main(argc,argv)
  int argc;
  char *argv[];
  { int i,j,k;
    char c,d;

    if (argc != 2)
    { printf("\n useage: auxout [%Sn][%Cn][%Fn]<str>.[[%T<str>.|%U,<str>.|%Wc|%Dn]...]\n\n");
      Pterm(0);
    }

    while (Bconstat(1) != 0) Bconin(1);
    while (Bconstat(2) != 0) Bconin(2);
    while (*argv[1] == '%')
      { argv[1]++;
	switch (*argv[1])
	{  case 'S':
	   case 's':
		argv[1]++;
	        i = *argv[1] - '0';
		if (i == 1) printf("\nSpeed: 9600  ");
		if (i == 4) printf("\nSpeed: 2400  ");
		if (i == 7) printf("\nSpeed: 1200  ");
		Rsconf(i,-1,-1,-1,-1,-1);
		Vsync(); Vsync();
		argv[1]++;
		break;
	   case 'C':
	   case 'c':
		argv[1]++;
		if (*argv[1] == '0') { i = 0x88; printf("\nConfig: 1N8"); }
		if (*argv[1] == '1') { i = 0xAE; printf("\nConfig: 1E7"); }
		if (*argv[1] == '2') { i = 0x8E; printf("\nConfig: 1E8"); }
		Rsconf(-1,-1,i,-1,-1,-1);
		Vsync(); Vsync();
		argv[1]++;
		break;
	   case 'F':
	   case 'f':
		argv[1]++;
		if (*argv[1] == '0') { i = 0x88; printf("\nNo Flow Control"); }
		if (*argv[1] == '1') { i = 0xAE; printf("\n^S^Q Flow Control"); }
		if (*argv[1] == '2') { i = 0x8E; printf("\nCTS/RTS Flow Control"); }
		Rsconf(-1,i,-1,-1,-1,-1);
		Vsync(); Vsync();
		argv[1]++;
		break;
	}
      }
    printf("\nSending string...");
    while (*argv[1] != '.')
      { Bconout(1,(int)*argv[1]);
	printf("%c",*argv[1]);
        argv[1]++;
      }
    argv[1]++;
    Bconout(1,(int)'\r');
    while (*argv[1] == '%')
      { argv[1]++;
	switch (*argv[1])
	{  case 'W':
	   case 'w':
		argv[1]++;
		c = *argv[1];
		printf("\nWaiting for...%c",c);
		if ((c < 0x7B) && (c > 0x60)) {c = c & 0x5F;}
		while (1 == 1) 
		{ if (Bconstat(1) != 0)
		  {  d = Bconin(1) & 0x7F; 
		     if ((d < 0x7B) && (d > 0x60)) {d = d & 0x5F;}
		     if (c == d) goto alpha;
		  }
		  if (Bconstat(2) != 0)
		  {  d = Bconin(2);
		     goto beta;
		  }
		}
alpha:		argv[1]++;
		for (i=k ; i<20 ; i++) { Vsync(); }
		break;
	   case 'T':
   	   case 't':
		argv[1]++;
		printf("\nSending string...");
		while (*argv[1] != '.')
		{ c = *argv[1];
		  if (c == '~') c = ' ';
		  Bconout(1,(int)c);
		  printf("%c",c);
		  argv[1]++;
		}
		argv[1]++;
		Bconout(1,(int)'\r');
		break;
	   case 'U':
   	   case 'u':
		argv[1]++;
		printf("\nSending string...");
		while (*argv[1] != '.')
		{ c = *argv[1];
		  if (c == '~') c = ' ';
		  if ((c < 0x7B) && (c > 0x60)) {c = c & 0x5F;}
		  Bconout(1,(int)c);
		  printf("%c",c);
		  argv[1]++;
		}
		argv[1]++;
		Bconout(1,(int)'\r');
		break;
	   case 'D':
	   case 'd':
		argv[1]++;
		printf("\nDelay...");
		i  = *argv[1] - '0';
		for (j=0 ; j<=i ; j++)
		{ for (k=0 ; k<=30 ; k++) Vsync(); }
		argv[1]++;
		break;
	}
      }
    Bconout(1,(int)'\r');
beta: printf("\n");

    Pterm(0);
  }
