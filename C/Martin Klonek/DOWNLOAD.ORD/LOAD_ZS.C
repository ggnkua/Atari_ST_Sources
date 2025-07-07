/* 'LOAD_ZS.PRG' bzw. 'LOAD_ZS.ACC', je nach Extension zum laden
   eines Downloadzeichensatzes in den Drucker.
  -Wird es als Accessory gestartet, und ist eine der folgenden 
   Dateien vorhanden, so wird automatisch beim booten der 
   entsprechende Zeichensatz geladen.:
   'zeichen.lq'  -> Lq_10 , 'zeichen.drf' -> Draft_10 ,
   'zeichen.l12' -> Lq_12 , 'zeichen.pro' -> Proportional.
   Auûerdem kann, wenn eine Menuleiste vorhanden ist, jederzeit
   Åber die Fileselectorbox ein Downloadzeichensatz 
   nachgeladen werden.
  -Wird es als Programm gestatet, so steht nur die File_select_box
   zur VerfÅgung.  
   
   Programmiert in  Turbo C ( mein erstes Programm in C )
                von Martin Klonek
                vom 12.10.1989
                fÅr Alle ( Public-Domain ) 
*/

#include <STDIO.H>
#include <tos.h>
#include <AES.H>
#include <ext.h>
#include <string.h>
int auswahl( void );
int laden( char path[], char datei[]);
int ausdrucken(void);

extern int _app;
char path[64+13];
char datei[13];
unsigned char buf[14592];
int start=32,ende=127;            /* erstes und letztes Zeichen */
int handle;

main()
{
int desk_id,appl_id,msg_buf[8];

appl_id=appl_init();
if(_app)                                            /* .prg       */
  { 
  strcpy(path,"x:\\");path[0]=(char) Dgetdrv()+'A'; /* akt. Drive */
  Dgetpath(path+2,0);strcat(path,"\\*.*");          /* akt. Pfad  */
  auswahl(); 
  }
else                                                /* .acc       */
  {
  if((desk_id = menu_register(appl_id, "  Download ")) == -1)
    {
    form_alert(1,"[1],[Kein Platz mehr in der Menueleiste][Ok]");
    appl_exit();
    return 0;
    }
  strcpy(path,"x:\\*.*");path[0]=(char) Dgetdrv()+'A';
  
  strcpy(datei,"ZEICHEN.LQ");handle=Fopen(datei,0);
  if (handle > 0 ) { Fclose(handle);laden(datei,path); }
  strcpy(datei,"ZEICHEN.DRF");handle=Fopen(datei,0);
  if (handle > 0 ) { Fclose(handle);laden(datei,path); }
  strcpy(datei,"ZEICHEN.L12");handle=Fopen(datei,0);
  if (handle > 0 ) { Fclose(handle);laden(datei,path); }
  strcpy(datei,"ZEICHEN.PRO");handle=Fopen(datei,0);
  if (handle > 0 ) { Fclose(handle);laden(datei,path); }
  do
    {
    evnt_mesag(msg_buf);
    if((msg_buf[0] == AC_OPEN) && (msg_buf[4] == desk_id))
      {
      auswahl();
      }
    }
  while(1);
}
appl_exit();
return 0;
}
    
auswahl()
{
  int but;
  
  *datei='\0';
  fsel_input(path, datei, &but);
  if (but==1) 
    {
    laden(datei,path);
    }
  return 0;
}

laden(char datei[],char path[]) 
{
int i,j,ok,p_pos,laenge,nx;
char extn[4];

p_pos=strcspn(datei,".");
strncpy(extn,datei+p_pos+1,strlen(datei)-p_pos+1); /* extention */
if (strcmp(extn,"DRF")==0) nx=3*(12+1); 
  else if (strcmp(extn,"LQ") ==0) nx=3*(36+1); 
  else if (strcmp(extn,"L12")==0) nx=3*(30+1); 
  else if (strcmp(extn,"PRO")==0) nx=3*(37+1); 
  else { form_alert(1,"[1][UngÅlige Datei][Abbruch]"); return 0; }

do                                          /* drucker bereit ? */
  {  
  if (Cprnos()==0) ok=form_alert(2,
               "[3][Drucker ist nicht|bereit !][Abbruch|On-Line]");
  if (ok==1) return 0;
  }
while (Cprnos()==0);

graf_mouse(HOURGLASS,0);                    /* Vollautomatisch.. */

p_pos=strcspn(path,"*");                    /* voller pfadname   */
path[p_pos]='\0';strcat(path,datei);        /* fÅr's laden       */ 
laenge=nx*(ende-start+1);
handle=Fopen(path,0);
Fseek(start*nx,handle,0),
Fread(handle,laenge,&buf[0]);
Fclose(handle);
path[p_pos]='\0';strcat(path,"*.*");        /* pfadname mit *.*  */

Cprnout(28);Cprnout(64);                    /* reset    */
if (strcmp(extn,"DRF")==0) 
  { Cprnout(27);Cprnout(120);Cprnout(0);    /* Draft    */
    Cprnout(27);Cprnout(80); }              /* 10 cpi   */
if (strcmp(extn,"LQ") ==0) 
  { Cprnout(27);Cprnout(120);Cprnout(1);    /* lq       */
    Cprnout(27);Cprnout(80); }              /* 10 cpi   */ 
if (strcmp(extn,"L12")==0) 
  { Cprnout(27);Cprnout(120);Cprnout(1);    /* lq       */
    Cprnout(27);Cprnout(77); }              /* 12 cpi   */
if (strcmp(extn,"PRO")==0) 
  { Cprnout(27);Cprnout(112);Cprnout(1); }  /* proportional an    */ 
Cprnout(27);Cprnout(38);Cprnout(0);         /* Benutzerzs. init   */
Cprnout(start);Cprnout(ende);               /* anzahl der zeichen */

for (i=0; i<(ende-start+1)*nx; i+=nx)
  {
  Cprnout(buf[i]);                          /* Rand,Breite        */
  Cprnout(buf[i+1]);
  Cprnout(buf[i+2]);
  for (j=3; j<=3*buf[i+1]+2;j++)
    {
    Cprnout(buf[j+i]);                      /* Daten              */
    }
  }
/*ausdrucken();*/                           /* nur bei bedarf     */
if (strcmp(extn,"PRO")==0) 
   { Cprnout(27);Cprnout(112);Cprnout(0);}  /* proportional aus   */
graf_mouse(ARROW,0);
return 0;
}

ausdrucken()
{
int i;
Cprnout(65);                                /* A */
Cprnout(27);Cprnout(37);Cprnout(1);         /* Benutzerzs. an   */
for (i=start;i<=ende;i++)
  {
  Cprnout(i);
  }
Cprnout(27);Cprnout(37);Cprnout(0);         /* Benutzerzs. aus  */
Cprnout(65);                                /* A */
Cprnout(13);                                /* return */
Cprnout(10);
return 0;
}

    