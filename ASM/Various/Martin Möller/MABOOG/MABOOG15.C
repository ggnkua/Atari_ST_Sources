/*
        Martin's Bootsektor-Generator
        (c)1989 by Martin M”ller
                   Klopstockweg 23
                   4440 Rheine
        Version:
        1.5c
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <osbind.h>
#include <portab.h>
#include <gemlib.h>
#include <maboog.h>
#define anzahl 5

int work_in[11],work_out[57];
int ap_id;
int handle;
int dummy;
char    *fn[]=
{
 "BOOTPCPW.B",
 "BOOTPIC.B",
 "BOOTPSW.B",
 "BOOTPICC.B",
 "BOOTPCMC.B"
};
int len[]=
{ 
 150,
 118,
 100,
 212,
 252
};
unsigned char bt[6][513];
int     rt;
int     i;      
unsigned char prg[514];
unsigned char boot[514];
int a,b,c;
long adr1, adr2;
int button;
char pssw[10];

char bck[6];
char *ptr;

void cls()
{
        printf("\033E");
}

void init()
{
 for( i=0; i<10 ; i++ )
  work_in[i]=1;
 work_in[10]=2;
 v_opnvwk( work_in, &handle , work_out );
 ap_id=appl_init();
 graf_mouse( 0, 0L );
 cls();
 rsrc_load("MABOOG.RSC");
 rsrc_gaddr( 0,SELECT,&adr1);
 rsrc_gaddr( 0,PASSWORT,&adr2);
 for ( i=0 ; i<anzahl ; i++ )
 {
  if((rt=Fopen(fn[i],2))<0)
  {
   cls();
   printf(" Fehler beim ”ffnen des Bootprogrammes: %d\n",rt);
   printf(" Bitte starten Sie das System neu!\n");
   printf(" (c)1989 by Martin M”ller / Rheine\n");
   for(;;)
    ;
  }
  Fread( rt , len[i] , bt[i] );
  Fclose( rt );
 }
}

void normal( tree, ind )
OBJECT tree[];
int ind;
{
 tree[ind].ob_state &= -2;
}

int slct()
{
 int x,y,w,h;
 form_center (adr1, &x,&y,&w,&h);
 form_dial(0,x,y,w,h,x,y,w,h);
 objc_draw(adr1,0,6,0,0,639,399);
 button=form_do(adr1,0);
 normal(adr1,button);
 form_dial(3,x,y,w,h,x,y,w,h);
 if(button==ABBRUCH)
 {
  gmxt();
 }
 return((button-PCPW));
}

void cpy1( a )
int a;
{
 for ( i=0 ; i<len[a] ; i++ )
  prg[i]=bt[a][i];
}

void cpy2( a )
int a;
{
 for ( i=0 ; i<len[a] ; i++ )
  boot[i+58]=prg[i];
}

void inpass( pw )
OBJECT pw[];
{
 int x,y,w,h;
 TEDINFO *ti;
 form_center( adr2,&x,&y,&w,&h);
 form_dial(0,x,y,w,h,x,y,w,h);
 objc_draw( adr2,0,6,0,0,639,399);
 button=form_do(adr2,PASS);
 normal(adr2,button);
 form_dial(3,x,y,w,h,x,y,w,h);
 ti=( TEDINFO *)pw[PASS].ob_spec;
 strcpy(pssw,( char *)ti->te_ptext);
}

int makeboot( b )
int b;
{
 if(b==0)
 { 
  inpass((OBJECT *)adr2);
  for ( i=0 ; i<4 ; i++ )
   prg[i+112]=pssw[i];
 }
 if(b==2)
 {
  inpass((OBJECT *)adr2);
  for ( i=0 ; i<4 ; i++ )
   prg[i+36]=pssw[i];
 }
 dummy=form_alert(1,"[2][ Bitte eine Diskette einlegen! ][ O.K. ]");
 i=Floprd( boot ,0L,0,1,0,0,1);
 cpy2(b);
 boot[0]=0x60;  boot[1]=0x38;
 Protobt( boot , 0L, -1, 1);
 i=Flopwr( boot ,0L,0,1,0,0,1);
 return(i);
}

int gmxt()
{
 rsrc_free();
 appl_exit();
 v_clsvwk();
 exit(0);
}

void main()
{
 init();
 for(;;)
 {
  cls();
  rt=slct();
  cpy1( rt );
  if(makeboot( rt )<0)
  {
   dummy=form_alert(1,"[1][ Schreibfehler! ][ O.K. ]");
  }
 }
}

 
