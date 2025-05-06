/* This is the source for extra library functions */

atoi(x)
char *x;
  {
   int fact,pos,sta,n;
   char c;
   n=0;
   if (x==0) return n;
   pos=0;
   while ( isspace(*(x+pos)) ) ++pos;
   sta=pos;
   while ( isdigit(*(x+pos)) ) ++pos;
   --pos; fact=1;
   while (pos>=sta)
	{
	 n += fact*( *(x+pos)-'0' );
	 fact *= 10;
	 --pos;
	}
   return n;
  }

isalnum(x)
char x;
  {
   if ( (x>='a' & x<='z') | (x>='A' & x<='Z') | (x>='0' & x <='9') )
	return 1;
   else
	return 0;
  }

isdigit(x)
char x;
  {
   if ( x>='0' & x<='9' )
	return 1;
   else
	return 0;
  }

isprint(x)
char x;
  {
   if ( x>31 & x<127 )
	return 1;
   else
	return 0;
}

isspace(x)
char x;
  {
   if ( (x>8 & x<14) | (x==' ') )
	return 1;
   else
	return 0;
  }

islower(x)
char x;
  {
   if ( x>='a' & x<='z' )
     	return 1;
   else
	return 0;
  }


isupper(x)
char x;
  {
   if ( x>='A' & x<='Z' )
	return 1;
   else
	return 0;
  }

toupper(x)
char x;
  {
   return x-32;
  }

tolower(x)
char x;
  {
   return x+32;
  }


/* Non standard functions */

ask(prompt,place,max)
char *prompt,*place;
int max;
{
 int n;
 char c;
 n=0; --max;
 printf("%s ",prompt);
 do {
	c=getchar();
	switch(c)
	{
	 case 8:	if (n>0) { place[n]=0;
				   --n;
				   printf(" %c",8);
				 }
			else printf(" %c",7);
			break;
	 case '\n':	place[n]=0;
			putchar(8);
			break;
	 default:	if (n>max)
			    printf("%c %c%c",8,7,8);
			else
			  { place[n]=c;
			    ++n;
			    break;
			  }
	}
     }
 while (c!='\n');
}
