IMPLEMENTATION MODULE  Application;

(*****************************************************************************)
(*                                                                           *)
(* Rekompiliertes LPR-MODULA-Originalmodul ,   hk  3'90                      *)
(*                                                                           *)
(*---------------------------------------------------------------------------*)
(*                                                                           *)
(* Offsets der Variablen ( sedezimal ):                                      *)
(*                                                                           *)
(*    Appl          : -$ 1E                                                  *)
(*    applist       : -$ D2                                                  *)
(*    applevel      : -$ D4                                                  *)
(*    VDIHandle     : -$ D6                                                  *)
(*    DeskTree      : -$ DA                                                  *)
(*    MenuTree      : -$ DE                                                  *)
(*    Colour        : -$ E0                                                  *)
(*    workOut       : -$154                                                  *)
(*    WidthChar     : -$156                                                  *)
(*    HeigthChar    : -$158                                                  *)
(*    WidthFont     : -$15A                                                  *)
(*    HeigthFont    : -$15C                                                  *)
(*    deskx         : -$15E                                                  *)
(*    desky         : -$160                                                  *)
(*    deskw         : -$162                                                  *)
(*    deskh         : -$164                                                  *)
(*    maxX          : -$166                                                  *)
(*    maxY          : -$168                                                  *)
(*                                                                           *)
(*****************************************************************************)

FROM  SYSTEM       IMPORT  (* PROC *)  ADR, SHORT;

FROM  GEMVDIbase   IMPORT  (* TYPE *)  VDIWorkInType,
                           (* VAR  *)  ptsout,
                           (* PROC *)  SetContrl, CallVDI;

FROM  GEMAESbase   IMPORT  (* CONST*)  MouseOn, MouseOff, Arrow,
                                       WorkXYWH, NewDesk,
                           (* TYPE *)  Object,
                           (* VAR  *)  AESGlobal, AESCallResult;

FROM  VDIControls  IMPORT  (* PROC *)  OpenVirtualWorkstation,
                                       CloseVirtualWorkstation;

FROM  AES          IMPORT  (* PROC *)  MenuItemCheck, MenuItemEnable,
                                       MenuTitleNormal, MenuBar,
                                       GrafMouse, GrafHandle,
                                       ApplInitialise, ApplExit,
                                       WindowGet, WindowSet,
                                       ResourceLoad, ResourceGetAddr, ResourceFree,
                                       ObjectDraw,
                                       FormAlert;
IMPORT  AES;       (*      (* PROC *)  EventMessage;  *)

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

VAR  workIn : VDIWorkInType;   (* Offset: -$ *)

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE  CheckItem ((* EIN/ -- *) item  : INTEGER;
                      (* EIN/ -- *) check : BOOLEAN );
 BEGIN
   MenuItemCheck( MenuTree, item, ORD( check ));
 END  CheckItem;

(*---------------------------------------------------------------------------*)

PROCEDURE  EnableItem ((* EIN/ -- *) item   : INTEGER;
                       (* EIN/ -- *) enable : BOOLEAN );
 BEGIN
   MenuItemCheck( MenuTree, item, ORD( enable ));
 END  EnableItem;

(*---------------------------------------------------------------------------*)

PROCEDURE  ShowNormal ((* EIN/ -- *) menu : INTEGER );
 BEGIN
   MenuTitleNormal( MenuTree, menu, 1 );
 END  ShowNormal;

(*---------------------------------------------------------------------------*)

PROCEDURE  ShowMenuBar ((* EIN/ -- *) show : BOOLEAN );
 BEGIN
   MenuBar( MenuTree, ORD( show ));
 END  ShowMenuBar;

(*---------------------------------------------------------------------------*)

PROCEDURE  EventMessage ((* -- /AUS *) VAR message : messagetype );
 BEGIN
   GrafMouse( Arrow, NIL );
   AES.EventMessage( ADR( message ));
 END  EventMessage;

(*---------------------------------------------------------------------------*)

PROCEDURE  Init;

  CONST inqCurrGrafTextAttr = 38;

  VAR  idx : INTEGER;

  BEGIN
    IF  applevel # 8  THEN
       WITH  applist[ applevel ]  DO
         rscaddr  := NIL;
         desktree := NIL;
         menutree := NIL;
       END;

       INC( applevel );
       IF  applevel <= 1  THEN
          Appl      := ApplInitialise( );
          VDIHandle := GrafHandle( WidthChar, HeightChar, WidthFont, HeightFont );

          SetContrl( inqCurrGrafTextAttr, 0, 0, 0, VDIHandle );
          CallVDI;

          WidthChar  := ptsout[ 0 ];
          HeightChar := ptsout[ 1 ];
          WidthFont  := ptsout[ 2 ];
          HeightFont := ptsout[ 3 ];

          idx := 0;
          WHILE  idx <= 9  DO
            workIn[ idx ] := 1;
            INC( idx );
          END;
          workIn[ 10 ] := 2;

          OpenVirtualWorkstation( workIn, VDIHandle, workOut );

          maxX   := workOut[ 0 ];
          maxY   := workOut[ 1 ];
          Colour := workOut[ 39 ] > 2;

          WindowGet( 0, WorkXYWH, deskx, desky, deskw, deskh );

          GrafMouse( Arrow, NIL );

       END; (* IF applevel <= 1 *)
    END; (* IF applevel # 8 *)
  END  Init;

(*---------------------------------------------------------------------------*)

PROCEDURE InitResource((* EIN/ -- *) deskindex,
                       (* EIN/ -- *) menuindex       : INTEGER;
                       (* EIN/ -- *) ResourceFileName: ARRAY OF CHAR ): BOOLEAN;

  CONST errmsg = '[3][ RSC-Datei nicht gefunden! ][OK]';

  VAR res      : INTEGER;
      error    : ARRAY [0..39] OF CHAR;
      desk     : POINTER TO  Object;
      filename : ARRAY [0..79] OF CHAR;
      idx      : INTEGER;
      ok       : BOOLEAN;

  BEGIN
    MenuTree := NIL;
    DeskTree := NIL;

    idx := 0;
    WHILE  idx <= 79  DO
      filename[ idx ] := 0C;
      INC( idx );
    END;

    idx := 0;
    WHILE    ( idx <= HIGH( ResourceFileName ))
           & ( idx <= 79                      )
           & ( ResourceFileName[ idx ] # 0C   )
    DO
      filename[ idx ] := ResourceFileName[ idx ];
      INC( idx );
    END;

    ResourceLoad( filename );
    IF  AESCallResult = 0  THEN
       error       := errmsg;
       error[ 36 ] := 0C;

       res := FormAlert( 1, error );
       ok := FALSE;
    ELSE
       GrafMouse( MouseOff, NIL );

       IF  deskindex > -1  THEN
          ResourceGetAddr( 0, deskindex, DeskTree );

          desk         := DeskTree;
          desk^.x      := deskx;
          desk^.y      := deskx;   (* Fehler, muss desky heissen *)
          desk^.width  := deskw;
          desk^.height := deskh + 18;

          WindowSet( 0,
                     NewDesk,
                     SHORT( DeskTree DIV 65536D ),
                     SHORT( DeskTree MOD 65536D ),
                     0,
                     0
                    );

          ObjectDraw( DeskTree, 0, 8, deskx, desky, deskw, deskh + 18 );
          WindowGet( 0, WorkXYWH, deskx, desky, deskw, deskh );

       END; (* IF deskindex > -1 *)

       IF  menuindex > -1  THEN
         ResourceGetAddr( 0, menuindex, MenuTree );
         MenuBar( MenuTree, 1 );
       END;

       GrafMouse( MouseOn, NIL );

       ok := TRUE;

    END; (* IF  AESCallResult *)

    WITH  applist[ applevel - 1 ]  DO
      desktree := DeskTree;
      menutree := MenuTree;
      rscaddr  := AESGlobal.apPTree;
    END;

    RETURN( ok );

  END  InitResource;

(*---------------------------------------------------------------------------*)

PROCEDURE  Terminate;

  BEGIN
    IF  applevel > 0  THEN
       DEC( applevel );

       WITH  applist[ applevel ]  DO
         IF  rscaddr # NIL  THEN
            IF  menutree # NIL  THEN
              MenuBar( menutree, 0 );
            END;

            ResourceFree;

            menutree := NIL;
            desktree := NIL;
            rscaddr  := NIL;
         END; (* IF rscaddr *)
       END; (* WITH *)

       IF  applevel > 0  THEN
          WITH  applist[ applevel - 1 ]  DO
             MenuTree := menutree;
             DeskTree := desktree;

             IF  rscaddr # NIL  THEN
                AESGlobal.apPTree := rscaddr;

                GrafMouse( MouseOff, NIL );

                IF  desktree # NIL  THEN

                  WindowSet( 0,
                             NewDesk,
                             SHORT( DeskTree DIV 65536D ),
                             SHORT( DeskTree MOD 65536D ),
                             0,
                             0
                            );

                  ObjectDraw( DeskTree, 0, 8, deskx, desky, deskw, deskh + 18 );

                END; (* IF desktree *)

                IF  menutree # NIL  THEN
                  MenuBar( menutree, 1 );
                END;

                GrafMouse( MouseOn, NIL );
             END; (* IF rscaddr *)
          END; (* WITH *)
       END; (* IF applevel *)

       IF  applevel <= 1  THEN
         CloseVirtualWorkstation( VDIHandle );
         ApplExit;
       END;
    END; (* IF applevel *)
  END  Terminate;


BEGIN (* Application *)

  applevel := 0;
  Init;

END  Application.
