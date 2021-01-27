/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        "kernel.h"
#include        "sgem.h"
#include        <string.h>
#include        <stdlib.h>
#include        <stdio.h>
#include        "xfsl.h"

/* ------------------------------------------------------------------- */

EXTERN  SYSGEM  sysgem;
LOCAL   LONG    f_id            = 'xFnT';
LOCAL   BYTE    *fbuf;
LOCAL   BYTE    *fbpt;
LOCAL   INT     line;
LOCAL   BYTE    fs_pt   [10][5] = { "\t8", "\t9", "\t10", "\t11", "\t12", "\t14", "\t18", "\t24", "\t36", "\t48" };
LOCAL   INT     fid;
LOCAL   INT     fpt;
LOCAL   LONG    result_id;
LOCAL   INT     result_bt;
LOCAL   BYTE    exam            [100];
LOCAL   BOOL    hidden  = FALSE;

/* ------------------------------------------------------------------- */

INT CountFonts ( VOID )

{
  REG   FONT    *f;
  REG   INT     i;

  f = sysgem.font;
  i = 0;
  while ( f != NULL )
    {
      if ( i == 0 )
        {
          if ( fid == -1 )
            {
              fid = f->id;
              fpt = 10;
            }
        }
      i++;
      f = f->next;
    }
  return ( i );
}

/* ------------------------------------------------------------------- */

INT MakeBuffer ( VOID )

{
  REG   FONT    *f;
  REG   BYTE    *p;
  REG   INT     i;

  fbuf = Allocate ( 50L * (LONG)( CountFonts ()));
  if ( fbuf == NULL ) return ( FALSE );

  fbpt = Allocate ( 1024L );
  if ( fbpt == NULL )
    {
      Dispose ( fbuf );
      return ( FALSE );
    }

  p = fbpt;
  for ( i = 0; i < 99; i++ )
    {
      sprintf ( p, "\t%d", i + 1 );
      p += 5L;
    }

  f = sysgem.font;
  p = fbuf;
  while ( f != NULL )
    {
      sprintf ( p, "--\t%-40.40s", f->name );
      p [0] = (BYTE)( f->id >> 8 );
      p [1] = (BYTE)( f->id );
      f = f->next;
      p += 46L;
    }
  return ( TRUE );
}

/* ------------------------------------------------------------------- */

INT fsel_sgem_hdl_dialog ( INT msg, INT button, DIALOG_INFO *inf )

{
  INT   d;

  switch ( msg )
    {
      case SG_START   : LinkSlider    ( sysgem.fontsel, FO_UP, FO_DN, FO_SHOW, FO_HIDE, CountFonts (), FO_BOX, fbuf + 2L, 46, FALSE );
                        LinkSlider    ( sysgem.fontsel, FO_UP2, FO_DN2, FO_SHOW2, FO_HIDE2, 99, FO_BOX2, fbpt, 5, FALSE );
                        LinkSlider    ( sysgem.fontsel, FO_UP3, FO_DN3, FO_SHOW3, FO_HIDE3, 10, FO_BOX3, fs_pt, 5, FALSE );
                        SetSliderTab  ( sysgem.fontsel, FO_BOX,  1, TAB_LEFT );
                        SetSliderTab  ( sysgem.fontsel, FO_BOX2, 1, TAB_LEFT );
                        SetSliderTab  ( sysgem.fontsel, FO_BOX3, 1, TAB_LEFT );

                        LinkOwnRedraw ( sysgem.fontsel, FO_FBOX );
                        SelectSldItem ( sysgem.fontsel, FO_BOX, line, FALSE );

                        SelectSldItem ( sysgem.fontsel, FO_BOX2, fpt - 1, FALSE );
                        SetSliderPos  ( sysgem.fontsel, FO_BOX2, fpt - 1, FALSE );
                        for ( d = 0; d < 10; d++ )
                          {
                            if ( atoi ( fs_pt [d] ) == fpt )
                              {
                                SetSliderPos  ( inf->tree, FO_BOX3, d, FALSE );
                                SelectSldItem ( inf->tree, FO_BOX3, d, FALSE );
                                break;
                              }
                          }
                        if ( ! VectorFont ( fid ))
                          {
                            fpt = 10;
                            SelectSldItem ( inf->tree, FO_BOX3, -1, FALSE );
                            SelectSldItem ( inf->tree, FO_BOX3,  2, FALSE );
                            SelectSldItem ( inf->tree, FO_BOX2, -1, FALSE );
                            HideObj ( inf->tree, FO_BOX2,  FALSE );
                            HideObj ( inf->tree, FO_UP2,   FALSE );
                            HideObj ( inf->tree, FO_HIDE2, FALSE );
                            HideObj ( inf->tree, FO_DN2,   FALSE );
                            AddSliderItem ( inf->tree, FO_BOX3, -7 );
                            hidden = TRUE;
                          }
                        break;
      case SG_NEWFONT : SetSliderFont ( inf->tree, FO_BOX,  button, -1, FALSE );
                        SetSliderFont ( inf->tree, FO_BOX2, button, -1, FALSE );
                        SetSliderFont ( inf->tree, FO_BOX3, button, -1, FALSE );
                        break;
      case SG_DRAWOWN : SetFont ( fid, fpt );
/*                        vst_arbpt ( sysgem.vdi_handle, fpt, &d, &d, &d, &d );  /* [GS] */			*/
                        BeginControl ( CTL_MHIDE );
                        v_stext ( BLACK, inf->clip.x, inf->clip.y, exam );
                        EndControl ( CTL_MHIDE );
                        vst_point ( sysgem.vdi_handle, fpt, &d, &d, &d, &d );
                        NormalFont ();
                        break;
      case SG_SLIDER  : if (( inf->box == FO_BOX ) && ( button != line ))
                          {
                            SelectSldItem ( inf->tree, inf->box, button, TRUE );
                            line  = button;
                            fid   = *(INT *) &fbuf [line * 46];
                            if (( ! VectorFont ( fid )) && ( GetSliderItems ( inf->tree, FO_BOX3 ) > 5 ))
                              {
                                fpt = 10;
                                SelectSldItem ( inf->tree, FO_BOX3, -1, FALSE );
                                SelectSldItem ( inf->tree, FO_BOX3, 2, FALSE );
                                HideObj ( inf->tree, FO_BOX2,  TRUE );
                                HideObj ( inf->tree, FO_UP2,   TRUE );
                                HideObj ( inf->tree, FO_HIDE2, TRUE );
                                HideObj ( inf->tree, FO_DN2,   TRUE );
                                AddSliderItem ( inf->tree, FO_BOX3, -7 );
                                hidden = TRUE;
                              }
                            else
                              {
                                if (( hidden ) && ( VectorFont ( fid )))
                                  {
                                    fpt = 10;
                                    SelectSldItem ( inf->tree, FO_BOX3, -1, FALSE );
                                    SelectSldItem ( inf->tree, FO_BOX2, -1, FALSE );
                                    SelectSldItem ( inf->tree, FO_BOX3, 2, FALSE );
                                    SelectSldItem ( inf->tree, FO_BOX2, 9, FALSE );
                                    SetSliderPos  ( inf->tree, FO_BOX2, 9, FALSE );
                                    ShowObj ( inf->tree, FO_BOX2,  TRUE );
                                    ShowObj ( inf->tree, FO_UP2,   TRUE );
                                    ShowObj ( inf->tree, FO_HIDE2, TRUE );
                                    ShowObj ( inf->tree, FO_DN2,   TRUE );
                                    AddSliderItem ( inf->tree, FO_BOX3, 7 );
                                    RedrawSliderBox ( inf->tree, FO_BOX2 );
                                    hidden = FALSE;
                                  }
                              }
                            RedrawObj ( inf->tree, FO_FBOX, 0, NONE, UPD_STATE | USER_STATE );
                          }
                        if (( inf->box == FO_BOX2 ) && ( button != ( fpt - 1 )))
                          {
                            fpt = button + 1;
                            SelectSldItem ( inf->tree, inf->box, button, TRUE );
                            for ( d = 0; d < 10; d++ )
                              {
                                if ( atoi ( fs_pt [d] ) == fpt )
                                  {
                                    SetSliderPos  ( inf->tree, FO_BOX3, d, TRUE  );
                                    SelectSldItem ( inf->tree, FO_BOX3, d, TRUE  );
                                    goto mach_weiter;
                                  }
                              }
                            SelectSldItem ( inf->tree, FO_BOX3, -1, TRUE );
                            mach_weiter:
                            RedrawObj ( inf->tree, FO_FBOX, 0, NONE, UPD_STATE | USER_STATE );
                          }
                        if (( inf->box == FO_BOX3 ) && ( atoi ( fs_pt [button] ) != fpt ))
                          {
                            fpt = atoi ( fs_pt [button] );
                            SelectSldItem ( inf->tree, FO_BOX2, fpt - 1, FALSE );
                            SetSliderPos  ( inf->tree, FO_BOX2, fpt - 1, TRUE  );
                            SelectSldItem ( inf->tree, FO_BOX3, button, TRUE   );
                            RedrawObj ( inf->tree, FO_FBOX, 0, NONE, UPD_STATE | USER_STATE );
                          }
                        break;
      case SG_END     : switch ( button )
                          {
                            case -1             : button = FO_ABORT;
                            case FO_OK          :
                            case FO_ABORT       : result_id = inf->id;
                                                  result_bt = button;
                                                  break;
                            case FO_SYSTEM      : SetSysFont ( fid );
                                                  break;
                            default             : break;
                          }
                        break;
      case SG_HELP    : result_id = inf->id;
                        result_bt = FO_HELP;
                        break;
      case SG_QUIT    : UnLinkSlider ( sysgem.fontsel, FO_BOX  );
                        UnLinkSlider ( sysgem.fontsel, FO_BOX2 );
                        UnLinkSlider ( sysgem.fontsel, FO_BOX3 );
                        Dispose ( fbuf );
                        Dispose ( fbpt );
                        break;
    }
  return ( SG_CONT );
}

/* ------------------------------------------------------------------- */

BOOL fsel_begin ( LONG win_id, OBJECT *tree, INT edit, BYTE *title )

{
  return ( WindowDialog ( win_id, -1, -1, title, "", TRUE, TRUE, tree, NULL, edit, NULL, fsel_sgem_hdl_dialog ));
}

/* ------------------------------------------------------------------- */

INT fsel_handle ( LONG win_id )

{
  if ( find_window ( -1, win_id ) == NULL ) return ( -1 );
  forever
    {
      result_id = 0L;
      result_bt = 0;

      HandleEvents ();

      if ( result_id == win_id )
        {
          return ( result_bt );
        }
    }
}

/* ------------------------------------------------------------------- */

VOID fsel_finish ( LONG win_id )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      DestroyWindow ( win, TRUE );
    }
}

/* ------------------------------------------------------------------- */

BOOL FontSelect ( INT button, INT *id, INT *pt, BYTE *title, BYTE *example, BOOL internal, TPROC help_proc )

{
  INT   i, d;
  FONT  *f;
  xFSL  *xfsl;

  hidden = FALSE;
  assign ( "And may the force be with you...", exam );   /* [GS] */
  if ( example != NULL )
    {
      if ( length ( example ) > 0 ) strncpy ( exam, example, 98L );
    }

  if ( ! internal )
    {
      i = sysgem.act_font_id;
      d = sysgem.act_font_pt;
      if ( id != NULL ) i = *id;
      if ( pt != NULL ) d = *pt;
      if ( GetCookie ( 'xFSL', &xfsl ))
        {
          switch ( xfsl->xfsl_input ( 0, FF_ALL, BuildWinName ( title ), &i, &d ))
            {
              case 0  : return ( FALSE );
              case 1  : if ( id != NULL ) *id = i;
                        if ( pt != NULL ) *pt = d;
                        return ( TRUE );
              default : break;
            }
        }
    }

  if ( sysgem.english )
    {
      ChangeButton ( sysgem.fontsel, FO_OK,     "[OK" );
      ChangeButton ( sysgem.fontsel, FO_ABORT,  "[Abort" );
      ChangeButton ( sysgem.fontsel, FO_SYSTEM, "Sys[tem" );
      ChangeButton ( sysgem.fontsel, FO_HELP,   "HELP" );
    }
  else
    {
      ChangeButton ( sysgem.fontsel, FO_OK,     "[OK" );
      ChangeButton ( sysgem.fontsel, FO_ABORT,  "[Abbruch" );
      ChangeButton ( sysgem.fontsel, FO_SYSTEM, "Sys[tem" );
      ChangeButton ( sysgem.fontsel, FO_HELP,   "HILFE" );
    }
  HideObj ( sysgem.fontsel, FO_OK,     FALSE );
  HideObj ( sysgem.fontsel, FO_ABORT,  FALSE );
  HideObj ( sysgem.fontsel, FO_SYSTEM, FALSE );
  HideObj ( sysgem.fontsel, FO_HELP,   FALSE );
  DelFlags( sysgem.fontsel, FO_OK, DEFAULT );
  if ( button & BUT_OK )
    {
      ShowObj ( sysgem.fontsel, FO_OK, FALSE );
      SetFlags( sysgem.fontsel, FO_OK, DEFAULT );
    }
  if ( button & BUT_ABORT  ) ShowObj ( sysgem.fontsel, FO_ABORT,  FALSE );
  if ( button & BUT_SYSTEM ) ShowObj ( sysgem.fontsel, FO_SYSTEM, FALSE );
  if ( button & BUT_HELP   ) ShowObj ( sysgem.fontsel, FO_HELP,   FALSE );

  ShowObj ( sysgem.fontsel, FO_BOX2,  FALSE );
  ShowObj ( sysgem.fontsel, FO_UP2,   FALSE );
  ShowObj ( sysgem.fontsel, FO_HIDE2, FALSE );
  ShowObj ( sysgem.fontsel, FO_DN2,   FALSE );

  if ( MakeBuffer () == FALSE ) return ( FALSE );

  i    = 0;
  line = 0;
  fid  = sysgem.font->id;
  fpt  = 10;
  f    = sysgem.font;
  while ( f != NULL )
    {
      if ( id != NULL )
        {
          if ( *id == f->id )
            {
              fid = *id;
              break;
            }
        }
      f = f->next;
      i++;
    }
  if ( id != NULL ) line = i;
  if ( pt != NULL ) fpt  = *pt;
  if ( fpt <= 0 ) fpt = 10;

  if ( id == NULL ) fid = -1;
  if ( pt == NULL ) fpt = 10;
  
  if ( fsel_begin ( f_id, sysgem.fontsel, 0, title ))
    {
      forever
        {
          switch (( i = fsel_handle ( f_id )))
            {
              case FO_OK        :
              case FO_ABORT     : goto ende;
              case FO_HELP      : if ( help_proc != NULL )
                                    {
                                      help_proc ();
                                    }
                                  break;
              default           : break;
            }
        }
      ende:
      if ( id != NULL ) *id = fid;
      if ( pt != NULL ) *pt = fpt;
      fsel_finish ( f_id );
      return ( i == FO_OK );
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */
