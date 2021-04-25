/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
|                Programm CVRT.C - Bit-Image-Converter                         |
|                ASSoft 10.1.1985 Version 0.0                                  |
|                                                                              |
|  Dient Zur Umwandlung von farbigen Bit-Images in Monochrome                  |
|  Die Outputfiles kînnen fÅr DEGAS ( 32034 Bytes ) oder normale LÑnge gewÑhlt |
|  werden ( 32128 ) Bytes                                                      |
|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#include "osbind.h"

#include "define.h"
#include "obdefs.h"
#include "gemdefs.h"
#include "gembind.h"
#include "tosdefs.h"

#include "cvrt.h"

#include "col2mon.c"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             ZUERST EIN HAUFEN ZEUGS, DER IN JEDEM PROGRAMM STEHEN MUSS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

extern int gl_apid;
       int handle;
       int gl_hchar, gl_wchar;
       int contrl[12];
       int intin[128];
       int ptsin[128];
       int intout[128];
       int ptsout[128];
       int work_in[11];
       int work_out[57];

OBJECT *tree;

char fi_alert[] = "[3][Systemfehler !|CVRT.RSC|File nicht gefunden][GIB'S auf]";

struct button {
   int  item;
   char string[11];
              };
/*
~~~~~~~~~~~ Objekt selektiert?~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
select( which )
int   which;
{ return( ((tree+which)->ob_state & SELECTED) ? TRUE : FALSE ); }


/*
~~~~~~~~~~~ Objekt deselektieren ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
ob_dsel( which )
int which;
{ (tree+which)->ob_state &= ~SELECTED; }


/*
~~~~~~~~~~~ Objekt selektieren~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
ob_sel( which )
int which;
{ (tree+which)->ob_state |= SELECTED; }

 

/*
~~~~~~~~~~~~ Pointer auf editierten Text laden~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 */
char *ptext( which )
int which;
{ return( ((tree+which)->ob_spec)->te_ptext); }


/*
~~~~~~~~~~~~ Open Virtuelle Workstation~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
open_vwork()
{
 int i, dummy;

 for( i=0; i<10; work_in[i++] = 1 );
                 work_in[10]  = 2;

 handle = graf_handle( &gl_wchar, &gl_hchar, &dummy, &dummy );

 v_opnvwk( work_in, &handle, work_out );
}


/*
~~~~~~~~~~~~ Dialog Adresse laden und Dialog machen~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
dialog( di, act )
int di, act;
{
 register int xd, yd, wd, hd;
 register int xh, yh, wh, hh;

 rsrc_gaddr( R_TREE, di, &tree );

 xd = 30; yd = 250;
 wd = tree->ob_width+10; hd = tree->ob_height+10;
 tree->ob_x = xd; tree->ob_y = yd;
 xh = 160; yh = 50; wh = 320; hh = 200;

 form_dial( FMD_START, xh, yh, wh, hh, xd, yd, wd, hd );
 form_dial( FMD_GROW , xh, yh, wh, hh, xd, yd, wd, hd );
 objc_draw( tree, ROOT, MAX_DEPTH, xd, yd, wd, hd );

 di = form_do( tree, act );

 form_dial( FMD_SHRINK, xh, yh, wh, hh, xd, yd, wd, hd );
 form_dial( FMD_FINISH, xh, yh, wh, hh, xd, yd, wd, hd );
 return( di );
}

/*
~~~~~~~~~~~~Aus path und auswahl end-filenamem zusammensetzen~~~~~~~~~~~~~~~~~~~
*/
char *makenam( path, wahl )
register char *path, *wahl;
{
 char *ret;

 ret = path;
 path += strlen( path );
 while( *--path != '\\' ) ;
 while( *++path = *wahl++ ) ;
 return( ret );
}


/*
~~~~~~Gerade gÅltigen path fÅr current drive als text mit wildcard bauen~~~~~~~~
*/
char *makepath( path, wild )
register char *path;
char *wild;
{
 char *ret;

 ret = path;
 *path++ = Dgetdrv()+'A';
 *path++ = ':';
 Dgetpath( path, 0 );
 strcat( path, wild );
 return( ret );
}

/*
~~~~~~~~~~~~ PROGRAMM INITIALISIEREN~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
prg_init()
{
 appl_init();
 if( gl_apid == FAILURE )               return( 3 );

 open_vwork();
 if( handle == FALSE )                  return( 2 );

 if( rsrc_load( "CVRT.RSC" ) == FALSE )
 { form_alert( 1, fi_alert );          return( 1 );
 }

 graf_mouse( ARROW, 0L );
 return( SUCCESS );
}



/*
~~~~~~~~~~~~ Programm versuchen zu starten~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
main()
{
 switch( prg_init() )
 {
  case ( SUCCESS ):    cvrt();
                       rsrc_free();
  case ( 1 )      :    v_clsvwk( handle );
  case ( 2 )      :    appl_exit();
  case ( 3 )      :    break;
 }
}




/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         HIER BEGINNT DAS EIGENTLICHE PROGRAMM
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
show()
{ v_show_c( handle ); }

hide()
{ v_hide_c( handle ); }

scr_copy( src, des )
register long *src, *des;
{
 register char *ende;

 hide();
 for( ende = src + 8000L; src < ende; *des++ = *src++ );
 show();
}

cvrt()
{
 int ret, exit;
 int  inp, out;
 int header[64];
 char inpath[64], oupath[64],
      inname[20], ouname[20],
      infile[80], oufile[80],
      *screen, *screen2;
 long count, fillen;

 static char memfail[] = "[3][Fehler:|zuwenig Speicher][GIB'S auf]";
 static char filfail[] = "[3][Fehler:|File nicht gefunden][ Ok ]";
 static char rezfail[] = "[3][Fehler:|Proramm lÑuft nur mit|hoher Auflîsung][ Ok ]";
 static char invfrag[] = "[2][Bild beim Umwandeln|invertieren ?][Nein| Ja |Abbruch]";
 static char noroom[]  = "[3][Fehler:|zuwenig Platz auf Disk!][ Ok ]";
 static char replace[] = "[2][Achtung:|Ein File mit diesem Namen|existiert bereits.][ Ersetzen | Abbruch ]";
 static char intext[]  = { 27, 'Y', 41, 38, 27, 'p', ' ','I','n','p','u','t','f','i','l','e',' ', 27, 'q', 0 };
 static char outext[]  = { 27, 'Y', 41, 38, 27, 'p', ' ','O','u','t','p','u','t','f','i','l','e',' ', 27, 'q', 0 };
 static char info[]    = "[1][  Autor: Arne Schween|Atari   Gruppe  SÅddeutschland|Der User-Club fÅr die ST-Serie|Kontakt: (089)/3231165 oder 7932340][ gelesen ]";

 if( Getrez() != 2 ) { form_alert( 1, rezfail ); return; }

 screen = Physbase();
 screen2 = Malloc( 32000L );
 if( screen2 == 0L ) { form_alert( 1, memfail ); return; }

 rsrc_gaddr( R_TREE, EINS, &tree );
 ob_sel( NORMAL );

 makepath( inpath, "\\*.*" );
 strcpy( oupath, inpath );
 scr_copy( screen, screen2 );

 while( (ret = dialog( EINS, -1 )) != ABBRUCH )
 {ob_dsel( ret );
  scr_copy( screen2, screen );
  switch( ret )
  { case INFO  :
      form_alert( 1, info ); break;
    case START :
      fillen = select( NORMAL )? 32128 : 32034;
      hide();
      Cconws( intext );
      show();
      fsel_input( inpath, inname, &exit );
      scr_copy( screen2, screen );
      if( exit == 1 )
      { strcpy( infile, inpath );
        if( (inp = Fopen( makenam( infile, inname ), 0 )) > 0 )
        { Fread( inp, fillen-32000L, header );
          header[0] = 2;
          Fseek( -32000L, inp, 2 );

          hide();
          Fread( inp, 32000L, screen );
          Fclose( inp );
          scr_copy( screen, screen2 );
          show();

          if( (ret = form_alert( 2, invfrag )) != 3 )
          { hide();
            col2mon( screen2, screen, ret-1 );
            scr_copy( screen, screen2 );

            Cconws( outext );
            show();
            fsel_input( oupath, ouname, &exit );
            scr_copy( screen2, screen );

            if( exit == 1 )
            { strcpy( oufile, oupath );
              ret = ( Fsfirst( makenam( oufile, ouname ), 255 ) == 0L );
              switch( ret )
              { case TRUE : if( form_alert( 1, replace ) == 2 ) break;
                            if( Fdelete( oufile ) < 0L )        break;
                default :
                 if( (out = Fcreate( oufile, 0 )) > 0 )
                 { hide();
                   count =  Fwrite( out, fillen-32000L, header );
                   count += Fwrite( out, 32000L, screen2 );
                   Fclose( out );
                   show();
                   if( count != fillen ) { Fdelete( oufile ); form_alert( 1, noroom ); }
                 }
              }
            }
          }
        }
        else form_alert( 1, filfail);
      }
   }
 }
 scr_copy( screen2, screen );
}

