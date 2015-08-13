/*****************************************************************************
 *                  Abspielen von Musik-Editor StÅcken                       *
 *                                        27. 7. 86    Eckhard Kruse         *
 *                                                     Reichenbergweg 7      *
 *                                                     D-3302 Weddel         *
 * Gleich einmal vorweg wie ein Programm aussieht, das die hier definierten  *
 * Routinen verwendet:                                                       *
 *                                                                           *
 * extern void m_laden(), m_musik(), m_wloop();                              *
 * main()                                                                    *
 * {                                                                         *
 *    int save_ssp;                                                          *
 *    m_laden("DATEI.MUS");             Datei laden                          *
 *    save_ssp=Super(0);                In Supervisor-Modus                  *
 *    m_musik();                        Musik abspielen                      *
 *    Super(save_ssp);                  In den User-Modus                    *
 * }                                                                         *
 * void m_wait()                        Warteschleife                        *
 * {                                                                         *
 *    m_wloop();                                                             *
 * }                                                                         *
 *****************************************************************************/
#include   "osbind.h"

extern void m_wait();  /* Diese Funktion muû in Ihrem Hauptprogramm stehen,  *
 * sie wird von m_musik() nach jedem 1/96 Takt aufgerufen, und sie sollte    *
 * immer eine bestimmte Zeitspanne warten ( bestimmt die Ablaufgeschwindig-  *
 * keit der Musik ). Dies kann durch den Aufruf von m_wloop() geschehen.     */

unsigned short *takte;
short buffer[100], *liste,
      max_abl, max_tkt, walz, tempo, temp,
      w_len, save7, reg7, kanal,
      tra[3], lau[3];
/**************** Tabellen fÅr Noten- und Frequenzwerte **********************/
short st_wert[] =
   { 15, 16, 17, 18, 19, 20, 21, 22, 24, 25, 27, 28, 30,
     32, 34, 36, 38, 40, 42, 45, 47, 50, 53, 56, 60,
     63, 67, 71, 75, 80, 84, 89, 95, 100, 106, 113, 119,
     127, 134, 142, 150, 159, 169, 179, 190, 201, 213, 226, 239,
     253, 268, 284, 301, 319, 338, 358, 379, 402, 426, 451, 478,
     506, 536, 568, 602, 638, 676, 716, 759, 804, 852, 903, 956,
     1013, 1073, 1136, 1204, 1276, 1351, 1432, 1517, 1607, 1703, 1804, 1911,
     2025, 2145, 2273, 2408, 2553, 2703, 2864, 3034, 3214, 3405, 3608, 3823 } ;

char  st_ton[] =
   { 0, 1, 3, 5, 7, 8, 10, 12, 13, 15, 17, 19, 20, 22, 24, 25,
     27, 29, 31, 32, 34, 36,  37, 39, 41, 43, 44, 46, 48, 49, 51, 53,
     55, 56, 58, 60, 61, 63, 65, 67, 68, 70, 72, 73,
     75, 77, 79, 80, 82, 84, 85, 87, 89, 91, 92, 94, 96 } ;
/******************** Laden und Speicher reservieren *************************/
void m_laden( string )
char *string;
{
   int f_handle;

   f_handle=Fopen( string, 0 );
   Fread( f_handle, 16, buffer );
   tempo=buffer[2];
   max_abl=buffer[3];
   max_tkt=buffer[4];
   walz=buffer[7];   if( walz ) w_len=72;  else w_len=96;

   liste=( short *)malloc( max_abl+2<<3 );  /*Statt der Lattice Funktion kann*/
    /* auch die Betriebssystemroutine  Malloc(...) verwandt werden */
   takte=( unsigned short *)calloc( w_len*2, max_tkt+2 ); /* Reserviert Spei-*/
    /* cherbereich der Grîûe (w_len*2)*(max_tkt+2) und lîscht ihn. */

   Fread( f_handle, 36, buffer );
   Fread( f_handle, max_abl+1<<3, liste );
   Fread( f_handle, (max_tkt+1)*w_len*2, &takte[100] );
   Fclose( f_handle );
}
/************************ StÅck spielen **************************************/
void m_musik()
{
   short  buf_ptr, lis_ptr, ende, help,
          kan1, kan2, kan3, rau;

   s_init();
   buffer[0]=0;  buffer[1]=-2;  buf_ptr=2;  lis_ptr=0;  temp=100;
   lau[0]=lau[1]=lau[2]=100;
   tra[0]=tra[1]=tra[2]=0;            ende=0;

   while( !ende )
   {
      switch( liste[lis_ptr] )
      {
         case -1: if( buffer[--buf_ptr]==-2 ) ende=1;
                  lis_ptr=buffer[--buf_ptr];                   break;
         case -2: tra[0]=liste[++lis_ptr];
                  tra[1]=liste[++lis_ptr];
                  tra[2]=liste[++lis_ptr];  lis_ptr++;         break;
         case -3: lau[0]=liste[++lis_ptr];
                  lau[1]=liste[++lis_ptr];
                  lau[2]=liste[++lis_ptr];  lis_ptr++;         break;
         case -4: temp=liste[++lis_ptr];    lis_ptr+=3;        break;
         case -5: lis_ptr+=4; buffer[buf_ptr++]=lis_ptr;
                  buffer[buf_ptr++]=0;                         break;
         case -6: lis_ptr+=4;
                  if( buffer[buf_ptr-1]==liste[lis_ptr-3] )
                  {
                     buf_ptr-=2;  help=0;
                     while( help>=0 )
                     {
                        if( liste[lis_ptr]==-1 )  help=-1;
                        help+=( liste[lis_ptr]==-5 )-( liste[lis_ptr]==-7 );
                        lis_ptr+=4;
                     }
                  }                                            break;
         case -7: buffer[buf_ptr-1]++;
                  lis_ptr=buffer[buf_ptr-2];                   break;
         case -8: if( liste[++lis_ptr]<0 )   lis_ptr+=3;
                  else
                  {
                     buffer[buf_ptr++]=lis_ptr+3;  buffer[buf_ptr++]=-5;
                     lis_ptr=liste[lis_ptr]-1<<2;
                  }                                            break;
         default: rau =( liste[lis_ptr]>=0 )*(( liste[lis_ptr++] )*w_len+100);
                  kan1=( liste[lis_ptr]>=0 )*(( liste[lis_ptr++] )*w_len+100);
                  kan2=( liste[lis_ptr]>=0 )*(( liste[lis_ptr++] )*w_len+100);
                  kan3=( liste[lis_ptr]>=0 )*(( liste[lis_ptr++] )*w_len+100);
                  for( help=0; help<w_len; help++ )
                  {
                     s_rausch( takte[rau++]&255 );
                     kanal=0; s_note( takte[kan1++] );
                     kanal++; s_note( takte[kan2++] );
                     kanal++; s_note( takte[kan3++] );

                     m_wait();

                     if( gemdos( 11 ) )
                     {
                        help=100; ende++;  /* Bei Taste Abbruch */
                     }
                  }
      }
   }
   s_quit();
}
/************* Standardroutine fÅr m_wait(): Pause machen ********************/
m_wloop()
{
   short i;
   for( i=0; i<temp*tempo/2000; i++ );
}
/*****************************************************************************
 * Und nun die Routinen zur eigentlichen Tonerzeugung; sie brauchen von      *
 * Ihrem Programm nicht aufgerufen zu werden.                                */
/****************************** Note spielen *********************************/
s_note( wert )
unsigned  wert;
{
   short ton_nr;
   ton_nr=st_ton[ wert>>2 & 63 ];
   if( wert & 0x4000 ) ton_nr--;
   if( wert & 0x8000 ) ton_nr++;
   if( ( wert & 0xc000 ) == 0xc000 )
   {
      s_rausch( wert&255 );
   }        
   else
   {
      ton_nr-=tra[kanal];
      if( ton_nr<0   ) ton_nr=0;
      if( ton_nr>95 ) ton_nr=95;
      s_freq( (st_wert[ton_nr]*(4-(wert&3))+st_wert[ton_nr+1]*(wert&3) )>>2 );
      if( wert & 0x1000 )  s_t_an();    else  s_t_aus();
      if( wert & 0x2000 )  s_r_an();    else  s_r_aus();
      s_laut( (wert>>8 & 15)*lau[kanal]/100 );
   }
}
/*************************** Sound Ansteuerung *******************************/
/**************************** Initialisierung ********************************/
s_init()
{
   reg7=save7=Giaccess( 0, 0x07 );
   s_rausch( 0 );
}
/*********************** Wiederherstellen vor Ende ***************************/
s_quit()
{
   Giaccess( save7, 0x87 );
}
/************************** Tonfrequenz setzen *******************************/
s_freq( freq )
unsigned short freq;
{
   short kan;
   kan=kanal<<1;
   Giaccess( freq&0xff, kan+0x80 );
   Giaccess( freq>>8, kan+0x81 );
}
/************************** LautstÑrke setzen ********************************/
s_laut( laut )
short laut;
{
   Giaccess( laut, kanal+0x88 );
}
/************************* Rauschperiode setzen ******************************/
s_rausch( periode )
short periode;
{
   Giaccess( periode, 0x86 );
}
/**************************** Ton einschalten ********************************/
s_t_an()
{
   reg7&=( 254-kanal-( kanal==2 ) );
   Giaccess( reg7, 0x87 );
}
/**************************** Ton ausschalten ********************************/
s_t_aus()
{
   reg7|=( 1+kanal+( kanal==2 ) );
   Giaccess( reg7, 0x87 );
}
/*************************** Rauschen einschalten ****************************/
s_r_an()
{
   reg7&=255-( 1+kanal+( kanal==2 ) << 3 );
   Giaccess( reg7, 0x87 );
}
/*************************** Rauschen ausschalten ****************************/
s_r_aus()
{
   reg7|=( 1+kanal+( kanal==2 ) << 3 );
   Giaccess( reg7, 0x87 );
}
/*************************** Sound abschalten ********************************/
s_aus()
{
   kanal=0; s_laut( 0 );
   kanal=1; s_laut( 0 );
   kanal=2; s_laut( 0 );
}
