/*****************************************
 Simple Screen Protection Accessory (SSPA)
 
 (C) MAXON COMPUTER GmbH 1992
 
 Author: T.W. MÅller
         
 BORLAND TURBO C V2.03
*****************************************/

/* Einige Header-Dateien */
#include <aes.h>
#include <vdi.h>
 
/* Einige Definitionen, um das Programm
   lesbarer zu machen  */
   
#define MAX_COLORS work_out[39]
#define TT_STE_COLORS 4096
#define ANZ_COLORS work_out[13]
#define ShiftGreen 10
#define ShiftBlue  20
#define MaskRed   0x400003FF
#define MaskGreen 0x400FFC00
#define MaskBlue  0x7FF00000

/* Die Farben - um Konflikte mit den
   GEM-Konstanten zu vermeiden, mit
   Underscore's versehen. */

#define _Red_ RGB[0]
#define _Green_ RGB[1]
#define _Blue_ RGB[2]

/* so sieht also die Ewigkeit aus, naja ... */
#define forever for(;;)

#define isACC (!_app)  
#define Darkness (message[0] == AC_OPEN)

extern int _app;

    /* 
    Handles fÅr AES und VDI,
     ID-Nummern f. Prog. und ACC. 
    */
              
int   phys_handle,
      handle,
      appl_id,    
      menu_id,    
      dummy;  /* wasted storage ... */
      /* die Paletten, max. 256 Farben */
long  DarkPal[256],CurPal[256];
int   work_out[57];


/* Die Prototypen */
void WaitForMessage ( void );
void WaitForGodot ( void );
void GetPalette(int C1, int Cm, long C[256]);
void SetPalette(int C1, int Cm, long C[256]);

void main( void )
{
  int i;
  int work_in[11];
   
  /* Applikation anmelden */
  appl_id = appl_init( );
  if ( appl_id != -1 )
  {
    for ( i = 0; i < 10; work_in[i++] = 1);
    work_in[10] = 2;
    /* beim AES anmelden */
    phys_handle = graf_handle( &dummy, &dummy,
                               &dummy, &dummy);
    handle = phys_handle;
    /* Beim VDI anmelden
        -> AES-Handle,
        <- VDI-Handle  */
    v_opnvwk( work_in, &handle, work_out );
    if ( handle != 0 )
      if (isACC && (MAX_COLORS == TT_STE_COLORS)) 
      {
        for (i = 0; i < 256; DarkPal[i++] = 0L);
        menu_id = menu_register( appl_id,
                          "  Screen Protector" );
      /* 
         Aus der nÑchsten Zeile kehrt das
         Accessory nie wieder zurÅck ... 
      */
        WaitForMessage();
      }; /* isACC ... */
    /* 
       sobald APPL_INIT() keinen Fehler meldet,
       das Accessory aber nicht installiert
       wurde, landet es hier ...
    */
    WaitForGodot();  
  }; /* appl_id */
  exit( 0 );
} /* main () */

void WaitForMessage( void )
{
  int message[8],
      CurX,CurY,CurKeys,
      OldX,OldY,OldKeys;
       
  
  forever /* Auf immer und ewig ... */
  {
    evnt_mesag(message);
    if (Darkness)
    {
      message[0]=0; /* sicher ist sicher */
      /*
         Vergleichswerte ermitteln ...
      */
      vq_mouse(handle,&OldKeys,&OldX,&OldY);
      vq_key_s(handle,&OldKeys);
      /*
          Farben retten und 'Dunkel'-Palette
          setzen
      */
      GetPalette(0,ANZ_COLORS-1,CurPal);
      SetPalette(0,ANZ_COLORS-1,DarkPal);
      /*
          Warten ...
      */ 
      do
      {
        evnt_timer(250,0);
        vq_mouse(handle,&CurKeys,&CurX,&CurY);
        vq_key_s(handle,&CurKeys);
      }while ((OldKeys == CurKeys) && 
              (OldX == CurX) && (OldY == CurY));
      /*
          alte Farben wiederherstellen 
      */
      SetPalette(0,ANZ_COLORS-1,CurPal);
    }; /* Darkness */

   }; /* forever */
}

void WaitForGodot( void )
{
  forever evnt_timer(-1,-1);
}  

void GetPalette(int min, int max, long c[256])
{
  int i, RGB[3];
  for (i = min; i <= max ; i++)
  {
    vq_color(handle, i, 0, RGB);
    c[i]  = ((long) _Red_) ;
    c[i] += ((long) _Green_) << ShiftGreen;
    c[i] += ((long) _Blue_)  << ShiftBlue;
  }
}

void SetPalette(int min, int max, long c[256])
{
  int i, RGB[3];
  for (i = min; i <= max ; i++)
  {
    _Red_   = (c[i] & MaskRed);
    _Green_ = (c[i] & MaskGreen) >> ShiftGreen;
    _Blue_  = (c[i] & MaskBlue)  >> ShiftBlue;
    vs_color(handle, i, RGB);

  }
}  


 
