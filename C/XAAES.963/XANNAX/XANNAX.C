/* (c) 1997,2000 by H.Robbers Amsterdam
 *  Manipulate with auto folder name's to ease switching between
 *  MiNT/N.AES, MiNT/XaAES & TOS
 */

#include <stdio.h>
#include <string.h>
#include <tos.h>

/* The program can handle up to six autofolders */
/* 3 OS'S each 2 variants */
/* to see what is current */
/*
char nm_a[]="c:\\auto\\n_aes\\n_aes";
char xm_a[]="c:\\auto\\xaaes\\xaaes";
char tm_a[]="c:\\auto\\tos\\tos";
*/
char nc_a[]="c:\\auto\\n_aes\\n_aes";
char xc_a[]="c:\\auto\\xaaes\\xaaes";
char tc_a[]="c:\\auto\\tos\\tos";


/* to change to */
/*
char nm[]="c:\\auto.na";
char xm[]="c:\\auto.xa";
char tm[]="c:\\auto.to";
*/
char nc[]="c:\\auto.na";
char xc[]="c:\\auto.xa";
char tc[]="c:\\auto.to";

/* These are the additional, can also be used for NVDISYS color <--> mono */
char nn[]="c:\\mint.na";
char nx[]="c:\\mint.xa";
char nt[]="c:\\mint.to";

char autonam[]="c:\\auto";
char additnam[]="c:\\mint";

int MagX,MiNT;
long sstack;

typedef struct
{
	long id,val;
} COOKIE;

int get_cookie(long cookie, long *value)
{
	COOKIE *jar;

	(long)sstack = Super(0L);
	jar = *(COOKIE **)0x5a0L; /* JAR (long *)0x5a0L */
	Super(sstack);

	if (!jar)
		return 0;

	while(jar->id)
	{
		if (jar->id == cookie)
		{
			if (value)
				*value = jar->val;
			return 1;
		}
		jar++;
	}
	return 0;
}

long end_ren(long ok, char *now, char *to)
{
	if (ok)
		if (!(MagX|MiNT))
			Bconin(2);
		else ;
	else
	{
		printf("%s --> %s\n",now,to);
/*		Bconin(2);
*/	}
	return ok;
}

long change_auto(char *now, char *to)
{
	long ok1,ok2;

	ok1 = Frename(0,autonam,now);	/* existing auto to what's in it */
	if (ok1 == 0)
		ok2 = Frename(0,to,autonam); /* given auto.ext to auto */

	if (ok1)
		printf("rename from auto failed: %d\n",ok1);
	if (ok2)
		printf("rename to auto failed: %d\n",ok2);
	return end_ren(ok1|ok2,now,to);
}

long change_mint(char *now,char *to)
{
	long ok1,ok2;

	ok1 = Frename(0,additnam,now);
	if (ok1 == 0)
		ok2 = Frename(0,to,additnam);
	if (ok1)
		printf("rename from additional failed: %d\n",ok1);
	if (ok2)
		printf("rename to additional failed: %d\n",ok2);
	return end_ren(ok1|ok2,now,to);
}

long change(char *to,char *ton)	/* find out what is in current auto */
{
	long ok;
/*	
	ok = Fopen(nm_a,0);
	if (ok>0)
		return Fclose(ok), change_mint(nn,ton)|change_auto(nm,to);
	ok = Fopen(xm_a,0);
	if (ok>0)
		return Fclose(ok), change_mint(nx,ton)|change_auto(xm,to);
	ok = Fopen(tm_a,0);
	if (ok>0)
		return Fclose(ok), change_mint(nt,ton)|change_auto(tm,to);
*/
	ok = Fopen(nc_a,0);
	if (ok>0)
		return Fclose(ok), change_mint(nn,ton)|change_auto(nc,to);
	ok = Fopen(xc_a,0);
	if (ok>0)
		return Fclose(ok), change_mint(nx,ton)|change_auto(xc,to);
	ok = Fopen(tc_a,0);
	if (ok>0)
		return Fclose(ok), change_mint(nt,ton)|change_auto(tc,to);

	printf("auto &| mint names messed up\n");
	if (!(MagX|MiNT))
		Bconin(2);
	return 1;
}

int main(int argc, char *argv[])
{
	long fl;
	MagX=get_cookie('MagX',0L);
	MiNT=get_cookie('MiNT',0L);

	if (argc > 1)
	{
		strlwr(argv[1]);
		printf("name -=%s=-\n",argv[1]);
	
		if (   strncmp(argv[1],autonam,strlen(autonam)) == 0
		    && *(argv[1] + strlen(autonam)) == '.'
		    )
		{
			char *s = argv[1];
			while (*s && *s != '.') s++;
			s++;
			/* The argv tells what we want to have.
			   that name must change to "auto".
			   But before that we must look what is in the current "auto"
			   && change that "auto" to what's mentioned within it.
			   This is determined in 'change()'
			*/
			if (*(s+2) == 0 || *(s+2) == '\\')
			{
/*				if (*s == 'n' && *(s+1) == 'a')	/* N.AES */
					return change(nm,nn);

				if (*s == 'x' && *(s+1) == 'a')	/* XaAES  */
					return change(xm,nx);

				if (*s == 't' && *(s+1) == 'o') /* tos */
					return change(tm,nt);
*/
				if (*s == 'n' && *(s+1) == 'a')	/* N.AES */
					return change(nc,nn);

				if (*s == 'x' && *(s+1) == 'a')	/* XaAES  */
					return change(xc,nx);

				if (*s == 't' && *(s+1) == 'o') /* tos */
					return change(tc,nt);

			}
			printf("needs one of .na, .xa, || .to\n");
			if (!(MagX|MiNT))
				Bconin(2);
			return 1;
		}

		printf("needs suitable c:\\auto.....\n");
		if (!(MagX|MiNT))
			Bconin(2);
		return 1;
	}
	else
	{
		printf("needs argument\n");
		if (!(MagX|MiNT))
			Bconin(2);
		return 1;
	}
}
