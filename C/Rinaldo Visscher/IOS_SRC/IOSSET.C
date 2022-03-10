#include <stdio.h>
#include <ext.h>
#include <vdi.h>
#include <stdlib.h>
#include <my.h>
#include <string.h>

#define NIL 0

extern int   handle;
extern void  clear_gets   (SCHERM *,int);
extern void  add_gets     (SCHERM *,char *,int,int,int,PFI,PFI);
extern int   screen_input (SCHERM *,int);
       void  main         (void);
       int   x1           (void);
       int   x2           (void);
       int   x3           (void);
       int   x4           (void);
       int   x5           (void);
       int   x6           (void);
       int   x7           (void);
       int   x8           (void);
       int   x9           (void);
       int   x10           (void);
       int   x11           (void);
     
       int   t2           (void);
       int   t3           (int);
       void  box          (int,int,int,int);

char nodestr[40], naam[35], password[10], netmail[128], inbound[128], outbound[128];
char lzh[128], arc[128], zip[128];

char *inb = "E:\\MAIL\\INBOUND";
char *out = "E:\\MAIL\\OUTBOUND";

unsigned int zone, net, node, point;
char fnd[4], bink[4], arcmail[4];

SCHERM scherm[14], *sptr;
FILE *fp;

void term (int ex) {
	printf ("\nERROR Press any key to exit...");
	while (kbhit());
	exit (ex);
}

char *skip_blanks(char *string)
{
	while (*string && isspace(*string)) string++;
	return(string);
}
/*
char get_bink() {
	char buffer [250], *p;
	char count = 0;
	int i;
	
	if (fp = fopen ("BINKLEY.CFG", "r")) == NULL) {
		return (0);
	}
	
	while (fgets (buffer, 250, fp)) {
	
		p = skip_blanks (buffer);
		if (*p == ';') continue;
		if ((i = strlen (buffer)) < 3) continue;
		
		p = &p [--i];
		*p = '\0';
		
		if ((p = strchr (buffer, ';')) != NULL) *p = '\0';
		
		p = skip_blanks (buffer);
		
		if (!strnicmp (p, "netfile", 7)) {
			p = skip_blanks (&p[7]);
			
			strncpy (inbound, p, 127);
			count++;
		}
		
		if (!strnicmp (p, "hold", 4)) {
			p = skip_blanks (&p[4]);
			
			strncpy (out, p, 128);
			count ++;
		}
		
		if (count >= 2) break;);
	}
	
	fclose (fp);
	
	if (count >= 2) return (1);
	return (0);
}
*/

void get_node (char *line) {
	char *q;
	
	if ((q = strchr(line, ':')) == NULL) {
		term (3);
	}
	
	*q = '\0';
	q++;
	
	zone = atoi (line);
	line = q;
	
	if (!strlen (line)) term (3);
	
	if ((q = strchr (line, '/')) == NULL) term (3);
	*q = '\0';
	q++;
	
	net = atoi (line);
	line = q;
	
	if (!strlen (q)) term (3);
	
	if ((q = strchr (line, '.')) == NULL) term (3);
	*q = '\0';
	q++;
	
	node = atoi (line);
	
	if (!strlen (q)) term (3);
	
	point = atoi (q);
}

void myprog() {
   int x;
   v_clrwk(handle);
   sptr=&scherm[0];

	printf ("\033EIOSmail setup program V 0.1 Copyright Rinaldo Visscher\n\n");
	
	printf ("You must fill in several questions. Please read the first part of the manual\nfirst. Keep the manual near you, and fill out the questions this program ask.\n");
	printf ("If you can't answer the questions, type ESC key, and reread the manual first.\nThis setup is NOT suitable in a multipoint setup nor a node setup.\n");
	printf ("This setup program helps you to get you started for the\ntime being. For more details and options refer to the manual in the package.\n");
	printf ("Be sure that you are aware of the pathnames and filenames of your\narchivers. This may be asked. If you aren't sure, write them down.\n\n");
	
	printf ("How to use this setup :\n\nESC key quits the program without saving.\nBackspace & Delete for correcting typos.\nRETURN to confirm.\nCTRL-Delete, delete line, Undo repairs.\nUp & Down arrow moves trough fields.\n\n");
	printf ("Press any key, ESC ends program.\r");
	
	while (kbhit());
	
	x = getch();
	
	if (x == 0x1b) exit (0);

	v_clrwk (handle);
	
	strcpy (naam, "Rinaldo Visscher");
	strcpy (nodestr, "2:280/301.1");
	strcpy (password, "NONE");
	strcpy (netmail, "E:\\MAIL\\MSGS\\");
	strcpy (inbound, "E:\\MAIL\\INBOUND\\");
	strcpy (outbound, "E:\\MAIL\\OUTBOUND\\");
	strcpy (lzh, "C:\\ARCHIVE\\LHARC.TTP");
	strcpy (zip, "C:\\ARCHIVE\\ZIPJR.TTP");
	strcpy (arc, "C:\\ARCHIVE\\ARC.TTP");
	strcpy (fnd, "No");
	strcpy (bink, fnd);
	strcpy (arcmail, "LZH");
	
	start:
	
   clear_gets(sptr,14);

   box(1,3,60,14);
   vs_curaddress(handle,3,10); printf("IOSmail setup program V 0.2");
   vs_curaddress(handle,5,3);  printf("Name             :");
   vs_curaddress(handle,6,3);  printf("Node             :");
   vs_curaddress(handle,7,3);  printf("Password         :");
   vs_curaddress(handle,8,3);  printf("Netmail          :");
   vs_curaddress(handle,9,3);  printf("Inbound          :");
   vs_curaddress(handle,10,3);  printf("Outbound         :");
   vs_curaddress(handle,11,3);  printf("Lharc            :");
   vs_curaddress(handle,12,3);  printf("Zip              :");
   vs_curaddress(handle,13,3);  printf("Arc              :");
   box(2,14,45,18);
   vs_curaddress(handle,15,4);  printf("Does your boss use Frontdoor  :");
   vs_curaddress(handle,16,4);  printf("What kind of arcmail you send :");
   vs_curaddress(handle,17,4);  printf("Do you use Binkley > 3.0      :");


   add_gets(sptr,naam,32,22,5,x1,t2);     /* plaats de in te voeren */
   add_gets(sptr,nodestr,38,22,6,x2,t2);     /* plaats de in te voeren */
   add_gets(sptr,password,8,22,7,x3,t2);     /* plaats de in te voeren */
   add_gets(sptr,netmail,38,22,8,x4,t2);     /* plaats de in te voeren */
   add_gets(sptr,inbound,38,22,9,x5,t2);     /* plaats de in te voeren */
   add_gets(sptr,outbound,38,22,10,x6,t2);     /* plaats de in te voeren */
   add_gets(sptr,lzh,38,22,11,x7,t2);     /* plaats de in te voeren */
   add_gets(sptr,zip,38,22,12,x8,t2);     /* plaats de in te voeren */
   add_gets(sptr,arc,38,22,13,x9,t2);     /* plaats de in te voeren */

   add_gets(sptr,fnd,3,37,15,x11,t2);     /* plaats de in te voeren */
   add_gets(sptr,arcmail,3,37,16,x10,t2);     /* plaats de in te voeren */
   add_gets(sptr,bink,3,37,17,x11,t2);     /* plaats de in te voeren */

   x=screen_input(sptr,0);                    /* daar gaat-ie           */

	if (x != -1) exit (1);

   vs_curaddress(handle,20,1); v_eeol(handle);
   printf("Is above information correct ? .\b");
	
	do {
		if (kbhit ()) {
			x = getch ();
			
			if (x == 'N' || x == 'n') goto start;
			else if (x == 'Y' || x == 'y') break;
			printf ("\b");
		}
	} while (1);
	get_node (nodestr);

	if ((fp = fopen ("IOSMAIL.CFG", "r")) != NULL) {
		fclose (fp);
		rename ("IOSMAIL.CFG", "IOSMAIL.CFB");
	}
	
	fp = fopen ("IOSMAIL.CFG", "w");

	fprintf (fp, "; IOSmail configuration, created by IOSmail setup V 0.2\n");
	fprintf (fp, "; This configfile belongs to %s. For more setup possibilities\n", naam);
	fprintf (fp, "; read the manual. This setup has created an simple config\n");
	fprintf (fp, "; for IOSmail, to allow a point to start. Have fun.\n;\n");
	fprintf (fp, "SysOp         %s\n", naam);
	fprintf (fp, ";\n; Your single point address\n;\n");
	fprintf (fp, "Address       %u:%u/%u.%u 0\n", zone, net, node, point);
	fprintf (fp, ";\n; You have an password at node %d:%d/%d, below is some information.\n", zone, net, node);
	fprintf (fp, "; The # sign is to get 2+ packetheaders, ask your boss he can handle 2+.\n");
	fprintf (fp, "; If your boss can handle only 2.0 packetheaders, delete the # sign.\n");
	fprintf (fp, "; For more detailed information about packetheaders, read the manual about this.\n");
	if (*fnd == 'Y' || *fnd =='y') {
		fprintf (fp, ";\n; Your boss is using FrontDoor (tm) mailer. Ask him if he is using TosScan.\n");
		fprintf (fp, "; If so, type the letter 'T' after the # sign.\n");
	}
	fprintf (fp, ";\n");
	fprintf (fp, "Password      %u:%u/%u.0 %s # ", zone, net, node, password);

	switch (*arcmail) {
		case 'Z':
		case 'z':
			fprintf (fp, "%cZIPmail\n", '%');
		break;
		case 'A':
		case 'a':
			fprintf (fp, "%cARCmail\n", '%');
		break;
		case 'L':
		case 'l':
			fprintf (fp, "%cLZHmail\n", '%');
		break;
		default:
			fprintf (fp, "%c{YOU MUST FILL IN LZHmail, ZIPmail or ARCmail}\n", '%');
		break;
	}

	fprintf (fp, ";\n; Here are your paths to your archivers.\n;\n");
	fprintf (fp, "Lzharchive    %s\n", lzh);
	fprintf (fp, "Ziparchive    %s\n", zip);
	fprintf (fp, "Arcarchive    %s\n", arc);

	if (*fnd == 'Y' || *fnd == 'y') {
		fprintf (fp, "NoNetmailpack\n");
		fprintf (fp, "SendAlwaysPKT\n");
	}

	fprintf (fp, ";\n; This is your messagebuffer. If you have an large memory,\n");
	fprintf (fp, "; you can increase the amount of it.\n;\n");
	fprintf (fp, "Messagebuffer 32768\n");
	fprintf (fp, "Logfile       IOSMAIL.LOG\nLoglevel      5\n");
	fprintf (fp, "Netmail       %s9999\n", netmail);
	fprintf (fp, ";\n; The two paths belong must correspond with your mailer paths\n;\n");
	fprintf (fp, "Inbound       %s\n", inbound);
	fprintf (fp, "Outbound      %s\n", outbound);
	fprintf (fp, ";\n; File attached netmail can be send to everyone.\n;\n");
	fprintf (fp, "File-to       *\n");
	fprintf (fp, ";\n; Arced mail only to your boss.\n;\n");
	fprintf (fp, "Arc-for       %u:%u/%u\n", zone, net, node);
	fprintf (fp, "Prepare-poll  %u:%u/%u\n", zone, net, node);
	fprintf (fp, ";\n; The areas will created by IOS if you don't have this area attached to\n");
	fprintf (fp, "; your areas. THIS WILL ONLY WORK IN FULL VERSION.\n;\n");
	fprintf (fp, "Auto-addareas\n");
	fprintf (fp, "Savelocal\n");
	fprintf (fp, "Deny-exept    *\n");
	fprintf (fp, "RedirectNetmail\n");
	fprintf (fp, "DefaultPKT    2+\n");
	fprintf (fp, "MaxMessages   5\n");
	fprintf (fp, "NiceOutput\n");
		
	if (*bink == 'Y' || *bink == 'y') {
		fprintf (fp, "NewBinkley\n");
	}
	
	fclose (fp);
	
	fp = fopen ("AREAS.BBS", "w");
	
	fprintf (fp, "Main origin line of IOSmail.\n");
	fprintf (fp, "-Keep\n");
	fprintf (fp, "%s9999 MAIL\n", netmail);
	fprintf (fp, "-Days 2\n");
	fprintf (fp, "%s9998 TRASHAREA\n", netmail);
	
	fclose (fp);
}

int x1()    /* demo van een voorafgaande procedure; in dit geval om een */
{           /* verklarende tekst af te drukken                          */
   vs_curaddress(handle,20,1); v_eeol(handle);
   printf("Please enter your name.");
   return(0);
}

int x2()    /* demo van een voorafgaande procedure; in dit geval om een */
{           /* verklarende tekst af te drukken                          */
   vs_curaddress(handle,20,1); v_eeol(handle);
   printf("Please enter your node and pointnumber. I.e. 2:280/301.1");
   return(0);
}

int x3()    /* demo van een voorafgaande procedure; in dit geval om een */
{           /* verklarende tekst af te drukken                          */
   vs_curaddress(handle,20,1); v_eeol(handle);
   printf("Please enter your password as agreed with your boss.");
   return(0);
}

int x4()    /* demo van een voorafgaande procedure; in dit geval om een */
{           /* verklarende tekst af te drukken                          */
   vs_curaddress(handle,20,1); v_eeol(handle);
   printf("Please enter your the path your netmail.");
   return(0);
}

int x5()    /* demo van een voorafgaande procedure; in dit geval om een */
{           /* verklarende tekst af te drukken                          */
   vs_curaddress(handle,20,1); v_eeol(handle);
   printf("Please enter the path to your incoming mail. See Binkley config.");
   return(0);
}

int x6()    /* demo van een voorafgaande procedure; in dit geval om een */
{           /* verklarende tekst af te drukken                          */
   vs_curaddress(handle,20,1); v_eeol(handle);
   printf("Please enter the path to your outgoing mail. See Binkley config.");
   return(0);
}

int x7()    /* demo van een voorafgaande procedure; in dit geval om een */
{           /* verklarende tekst af te drukken                          */
   vs_curaddress(handle,20,1); v_eeol(handle);
   printf("Please enter where we can find Lharc. Enter path and filename.");
   return(0);
}

int x8()    /* demo van een voorafgaande procedure; in dit geval om een */
{           /* verklarende tekst af te drukken                          */
   vs_curaddress(handle,20,1); v_eeol(handle);
   printf("Please enter where we can find Zip. Enter path and filename.");
   return(0);
}

int x9()    /* demo van een voorafgaande procedure; in dit geval om een */
{           /* verklarende tekst af te drukken                          */
   vs_curaddress(handle,20,1); v_eeol(handle);
   printf("Please enter where we can find Arc. Enter path and filename.");
   return(0);
}

int x10()    /* demo van een voorafgaande procedure; in dit geval om een */
{           /* verklarende tekst af te drukken                          */
   vs_curaddress(handle,20,1); v_eeol(handle);
   printf("Please enter here LZH for Lharc, ZIP for Zip or ARC for Arc.");
   return(0);
}

int x11()    /* demo van een voorafgaande procedure; in dit geval om een */
{           /* verklarende tekst af te drukken                          */
   vs_curaddress(handle,20,1); v_eeol(handle);
   printf("Please enter here Yes or No.");
   return(0);
}

int t2()
{
   vs_curaddress(handle,20,1);
   v_eeol(handle);
   return 1;
}

int t3(x)         /* demo van een in de screen_input geplakte eind_functie */
int x;            /* om de invoer direct te controleren                    */
{                 /* x is de key, waarmee het veld is verlaten.            */
   SCHERM *sptr;
   sptr=&scherm[2];
   vs_curaddress(handle,20,1);v_eeol(handle);
   if (x != 0x4800) /* Arrow Up: laat de controle nog even achterwege */
   {
      if ((*sptr->tptr >= '0') && (*sptr->tptr <= '9'))
         return(1);  /* oke: laat screen_input maar verder gaan */
      else
      {
         printf("FOUT ! ");
         putchar(0x07);
         printf("U heeft waarschijnlijk geen postcode ingetikt!");
         return(0); /* screen_input herhaalt nu de invoer van woonpl */
      }
   }
   else
      return(1);
}

void box(int x1,int y1,int x2,int y2)
{
   int pxy[4];
   pxy[0]=x1*8-4;
   pxy[1]=y1*16-8;
   pxy[2]=x2*8-4;
   pxy[3]=y2*16-8;
   vsf_color(handle,1);
   vswr_mode(handle,1);
   vsf_interior(handle,0);
   vsf_perimeter(handle,1);
   v_bar(handle,pxy);
   pxy[0]+=2; pxy[1]+=2; pxy[2]-=2; pxy[3]-=2;
   v_bar(handle,pxy);
}

