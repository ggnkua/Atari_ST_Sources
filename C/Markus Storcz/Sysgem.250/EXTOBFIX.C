/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        <stdio.h>
#include        <stdlib.h>
#include        <string.h>

/* ------------------------------------------------------------------- */

#include        "sys_gem2.h"
#include        "kernel.h"

/* ------------------------------------------------------------------- */

EXTERN  SYSGEM  sysgem;

/* ------------------------------------------------------------------- */

VOID    fix_objs      ( OBJECT *tree, BOOL is_dialog );
VOID    (*get_name)   ( VOID *window, WORD obj, BYTE *txt );
VOID    free_userblk  ( OBJECT *tree );
LONG    pinit_obfix   ( BOOL status );
VOID    test_form     ( OBJECT *tree, WORD editobj, LONG get_n, VOID *window );
VOID    do_alert      ( INT bt, BYTE *str );

/* ------------------------------------------------------------------- */

RECT            tdr;

/* ------------------------------------------------------------------- */

LOCAL LONG routines [] = { 0L, (LONG) do_alert, (LONG) test_form, '0610', '1964', (LONG) pinit_obfix };

/* ------------------------------------------------------------------- */

VOID do_alert ( INT bt, BYTE *str )

{
  Alert ( ALERT_STOP, bt, str );
}

/* ------------------------------------------------------------------- */

VOID test_form ( OBJECT *tree, INT editobj, LONG get_n, VOID *window )

{
  INT   i;
  BYTE  name [18], buf [200];

  *(LONG *) &get_name = get_n;

  nochmal:
  tdr.x = -1;
  tdr.y = -1;
  tdr.w = -1;
  tdr.h = -1;
  sysgem.new_dial = 0;
  NewDialog ( tree );
  ClearEditFields ( tree );
  editobj = first_edit ( tree );

  i = DoDialog ( tree, editobj, "|SysGem-Dialogtest" );
  if ( i == -1 )
    {
      DelDialog ( tree );
      form_alert ( 1, "[3][ Irgendwas ging schief... ][ Abbruch ]" );
      form_dial ( FMD_FINISH, sysgem.desk.x, sysgem.desk.y, sysgem.desk.w, sysgem.desk.h, sysgem.desk.x, sysgem.desk.y, sysgem.desk.w, sysgem.desk.h );
      return;
    }

  DelDialog ( tree );

  (*get_name)( window, i, name );
  sysgem.self_edit = 0;
  if ( sysgem.act_color >= 16 )
    {
      sprintf ( buf, "[1][ Angew„hltes Object: | %d = \'%s\' ][ Ed-E[in | Ed-A[us | [Weiter | [Abbruch | 3D-[Ein | 3D-Au[s ]", i, name );
    }
  else
    {
      sprintf ( buf, "[1][ Angew„hltes Object: | %d = \'%s\' ][ Ed-E[in | Ed-A[us | [Weiter | [Abbruch ]", i, name );
    }
  i = Alert ( ALERT_NORM, 4, buf );
  switch ( i )
    {
      case 1 : sysgem.new_dial = 0;
               UseOwnEditFields ();
               goto nochmal;
      case 2 : goto nochmal;
      case 3 : goto nochmal;
      case 4 : break;
      case 5 : Enable3D ();
               goto nochmal;
      case 6 : Disable3D ();
               goto nochmal;
      
    }
  if ( tdr.x != -1 )
    {
      form_dial ( FMD_FINISH, tdr.x, tdr.y, tdr.w, tdr.h, tdr.x, tdr.y, tdr.w, tdr.h );
    }
}

/* ------------------------------------------------------------------- */

LONG pinit_obfix ( BOOL status )

{
  if ( status )
    {
      _app = 1;
      if ( InitGem ( "", 'itex', "SysGem-Dialog" ) > 0 )
        {
          return ((LONG)( routines ));
        }
    }
  else
    {
      ExitGem ();
    }
  return ( 0L );
}

/* ------------------------------------------------------------------- */

INT main ( VOID )

{
  LONG  dummy;

  form_alert ( 1, "[3][ Dieses Programm kann nur | von Interface gestartet | werden! ][ Abbruch ]" );
  dummy = routines [6] + 1L;
  if ( dummy != 0L );
  return ( 0 );
}

/* ------------------------------------------------------------------- */
