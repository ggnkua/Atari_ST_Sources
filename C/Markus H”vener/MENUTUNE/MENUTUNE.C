/*********************************************/
/*  MODUL : MENUTUNE.C                       */
/*  AUTOR : Markus H”vener                   */
/*          (c) 1992 MAXON Computer GmbH     */
/*  DATUM : 20.10.1991                       */
/*********************************************/

# include <aes.h>
# include <portab.h>
# include <vdi.h>

#define FALSE   0
#define TRUE    !FALSE


MLOCAL USERBLK  _user;     
MLOCAL WORD     gv_handle;

/* Prototyp */
MLOCAL WORD cdecl DrawMenuRect( PARMBLK *parmblock );


/*********************************************/
/*   Aufgabe : Setzt einzelne Mengruppen in */
/*             die Bildschirmgrenzen         */
/* Parameter : Pointer auf Objektbaum        */
/*********************************************/
WORD MenuCorrect( OBJECT *menuptr )
{
   WORD   i = menuptr[2].ob_tail + 2,
          abs_x, abs_y;
   GRECT  work;
   
   
   /* Arbeitsbereich holen */
   wind_get( 0, WF_WORKXYWH,
                &work.g_x, &work.g_y,
                &work.g_w, &work.g_h );

   
   /*****************************/
   /* Men allgemein zu breit   */
   /*****************************/
   if( menuptr[menuptr[2].ob_tail].ob_x + 
       menuptr[menuptr[2].ob_tail].ob_width +
       menuptr[2].ob_x >
       work.g_x + work.g_w )
      return( FALSE );
   
   do
   {
      ++i;

      /****************************/
      /* Ein Hintergrundobjekt ?? */
      /****************************/
      if( menuptr[i].ob_type == G_BOX )
      {
         if( (menuptr[i].ob_width  >= work.g_w) ||
             (menuptr[i].ob_height >= work.g_h) )
            return( FALSE );
         
             
         /* Absolute Position */
         objc_offset( menuptr, i, &abs_x, &abs_y );
         
         /* Nicht komplett im Bildschirm ?? */
         if( abs_x >= work.g_x + work.g_w - menuptr[i].ob_width )
            menuptr[i].ob_x -= abs_x - (work.g_x + work.g_w - menuptr[i].ob_width) + 1;
      }
   }
   while( !(menuptr[i].ob_flags & LASTOB) );
   
   return( TRUE );
}


/*********************************************/
/*   Aufgabe : Graue DISABLED-Objekte finden */
/*             und in USERDEFS wandeln       */
/* Parameter : Pointer auf Objektbaum        */
/*             VDI-Handle                    */
/*********************************************/
VOID MenuTune( OBJECT *menuptr, WORD v_handle )
{
   WORD  i = -1;


   gv_handle = v_handle;
  
   /* USERBLK-Struktur fllen */
   _user.ub_parm = 0L;
   _user.ub_code = DrawMenuRect;

   do
   {
      ++i;
    
      /* Ist es ein passendes Objekt */
      if( menuptr[i].ob_type == G_STRING )
         if( (menuptr[i].ob_state & DISABLED) &&
             (menuptr[i].ob_spec.free_string[0] == '-') )
         {
            menuptr[i].ob_type = G_USERDEF;
            menuptr[i].ob_spec.userblk = &_user;
         }
   }
   while( !(menuptr[i].ob_flags & LASTOB) );
}



/*********************************************/
/*   Aufgabe : Zeichenfunktion fr Balken    */
/*             (wird vom AES aufgerufen)     */
/* Parameter : Pointer auf PARMBLK-Struktur  */
/*********************************************/
MLOCAL WORD cdecl DrawMenuRect( PARMBLK *parmblock )
{
   WORD  pxy[4];


   /* Koordinaten errechnen */
   pxy[0] = parmblock->pb_x;
   pxy[1] = parmblock->pb_y + (parmblock->pb_h / 2) - 1;
   pxy[2] = parmblock->pb_x + parmblock->pb_w - 1;
   pxy[3] = parmblock->pb_y + (parmblock->pb_h / 2);

   /* Grafikmodi setzen */
   vswr_mode( gv_handle, MD_REPLACE );
   vsf_interior( gv_handle, FIS_PATTERN );
   vsf_style( gv_handle, 4 );
   vsf_color( gv_handle, 1 );

   /* Box malen */
   vr_recfl( gv_handle,  pxy );
  

   return( 0 );
}
