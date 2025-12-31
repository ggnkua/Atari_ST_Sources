#include <stdio.h>
#include <portab.h>
#include <vdi.h>
#include <aes.h>
#include <stdlib.h>
#include <tos.h>

#define 	TEST	1


extern int colours;
extern MFDB source;


WORD log2( LONG arg)
/* gibt ganzzahligen 2-er Logarithmus zurck von arg				*/
{
register WORD counter=0;

while (arg>1)
	{
	arg/=2;
	printf
	counter++;
	}
return (counter);
}


#if TEST
/* Variablen globale */
WORD contrl[12];    /* control input          */
WORD intin[128];    /* max string length       */
WORD ptsin[128];    /* polygon fill points     */
WORD intout[128];   /* open workstation output */
WORD ptsout[128];
WORD work_in[11];
WORD work_out[57];
WORD handle;
LONG screenbytes;
	int colours;
	MFDB source,target;
	
static int open_vwork()		/* opens virtuall work station */
{
  register int i;

  static int background[]= { 0,0,429 };
  static int foreground[]= { 572,572,572 };
  static int stdcolours[][3]={  {143,0,0}, {286,143,0}, {429,143,0},
                   {429,286,0}, {572,286,0}, {572,429,0}, {715,429,0},
                   {715,572,0}, {858,715,0}, {858,858,286},
                   {858,1000,286}, {1000,1000,429}, {1000,1000,715},
                   {1000,1000,1000}, {-1,-1,-1} };

  for(i=0;i<10;work_in[i++]=1);     /* init string for VDI routine */
  work_in[10]=2;
  v_opnvwk(work_in,&handle,work_out); /* call VDI open virtual workstation */
  colours=work_out[13];               /* how much colours to manage        */
  vs_color(handle,0,background);
  vs_color(handle,1,foreground); /* standards */

  i=2;
  while (i<=colours && stdcolours[i-2][0]!=-1)
   {
   vs_color(handle,i,stdcolours[i-2]);
   i++;
   }
 
  return (TRUE);
}

#define testrast   FALSE

void *reserved_screen;

void reserve_screen()
{
  register long runner;
  register BYTE *clearer;

		/* special request for planes & resolutions */
  vq_extnd(handle,0,work_out); 	/* first the normal ones */
  screenbytes=(long) (work_out[0]+1)/8*(long) (work_out[1]+1);
  vq_extnd(handle,1,work_out); /* now look how much planes it needs */
  screenbytes*=(work_out[4]);

  reserved_screen=malloc((unsigned int) (screenbytes+3));
  target.fd_addr=reserved_screen;

    
  /* automatically on word boundary */
#if testrast
  printf("res:%lx tar.fd_addr:%lx\n",reserved_screen,target.fd_addr);
#endif
  clearer=(BYTE *) target.fd_addr;
  for (runner=0;runner<screenbytes;runner++)
    *(clearer++)='\0'; /* i hope 0 is no colour */

#if testrast
  printf("p: %lx s:%lx dcarpet:%ld\n",target.fd_addr,clearer,(long) (clearer-target.fd_addr));
  gemdos(7);
#endif

		/* aufbereiten beider DBF's */
		/*  fd_addr bereits getan */
  vq_extnd(handle,0,work_out); 		/* first the normal ones */
  target.fd_w=work_out[0]+1;
  target.fd_h=work_out[1]+1;
  target.fd_wdwidth=target.fd_w/16;
  target.fd_stand=0;
  vq_extnd(handle,1,work_out); /* now the enhanced */
  target.fd_nplanes=(work_out[4]);

  source=target;
  source.fd_addr=	Physbase();
	/* the ?pict var are allready installed in window_open */
  clearer=(BYTE *) source.fd_addr;
  clearer+=80*20;
  for (runner=2500;runner<screenbytes;runner++)
    *(clearer++)='\0'; /* i hope 0 is no colour */
}

#endif


WORD IntelWord(WORD w)
{
#if 0
return ((w % 0x100)*0x100 + (w/0x100));
#else
return w;
#endif
}

void main(void)   /* save_img */
/* speichert das aktuelle Bild als IMG! ab ohne Komprimierung	*/
/* Aufbau aus dem Supergraphikbuch rausgenommen						*/
{
/* Header  aus Words im INTEL! Format */
static WORD  header [8]    = { 01,     /* Versionnummer 	*/
										 0x8,	 	/* Words im Header 	*/ 
										 00,     /* Bits/Punkt zum Erg„nzen */
										 0x2,		/* L„nge im Pattern Run	*/
										 0x174,		/* etwa 1 Mill Breite 	*/
										 0x174,		/* und H”he */
										 00,		/* Punkte pro Zeile */
										 00 };	/* Zeilen pro Bild */
static BYTE linehead  [4]  = { 0,0,0xFF, 1 }; /* Linestart */
static BYTE bit_string[2]  = {0x80, 0}; 

int fsave;
register int counter,cols;
MFDB stand;
register BYTE *tmp,*tmp2,*tmp3;
							
/* Zuerst auffllen mit g„ngigen Werten */
#if TEST
	open_vwork();
	reserve_screen();
#endif
header[2]=IntelWord(source.fd_nplanes);

header[6]=IntelWord(source.fd_w); 
header[7]=IntelWord(source.fd_h);

bit_string[1]=source.fd_wdwidth*2;

fsave=creat("C:\\wordplus\\tmp\\TMP.IMG",0xFFFF);
if (fsave!=-1)
	{
	write(fsave,header,16);
	/* ich hoffe, die idiotische, nirgends!!! dokumentierte Standard-	*/
	/* rasterform entspricht dem IMG-File										*/
	stand=source;
	stand.fd_addr=malloc(screenbytes+3);
	tmp=stand.fd_addr;
	vr_trnfm(handle,&source,&stand);
	linehead[3]=1; 
	for(counter=0; counter<source.fd_h; counter++)
		if (counter<source.fd_h-1 && linehead[3]<100)  /* d.h. nicht die letzte */
			{	
			tmp2=tmp;
			tmp3=tmp+source.fd_nplanes*source.fd_wdwidth*2; /* n„chste Zeile */
			while ((tmp2<tmp+source.fd_nplanes*source.fd_wdwidth*2)
					 && (*tmp2==*tmp3))
				{
				tmp2++;
				tmp3++;
				}
			if (tmp2==tmp+source.fd_nplanes*source.fd_wdwidth*2)
				/* d.h. Zeilen gleich!	*/
				{
				tmp=tmp2;
				linehead[3]++;
				}
			else
				{	 
				write(fsave,linehead,4);
				linehead[3]=1;				
				write(fsave,bit_string,2);
				write(fsave,tmp,stand.fd_wdwidth*2*source.fd_nplanes);
				tmp+=stand.fd_wdwidth*2*source.fd_nplanes;
				}
			}
		else
			{
			write(fsave,linehead,4);
			linehead[3]=1;				
			write(fsave,bit_string,2);
			write(fsave,tmp,stand.fd_wdwidth*2*source.fd_nplanes);
			tmp+=stand.fd_wdwidth*2*source.fd_nplanes;
			}
	close(fsave);
	}															 
}						 