IMPLEMENTATION MODULE LINEA;

(*$T-*) (*$S-*)
FROM SYSTEM IMPORT SETREG, REGISTER, CODE ;

PROCEDURE Line(x,y,x1,y1 : INTEGER) ;
BEGIN
    SETREG(1,x) ; SETREG(2,y) ; SETREG(3,x1) ; SETREG(4,y1) ;
    CODE(2047H,3141H,0026H) ;  (* move.l d7,a0  get address *)                   CODE(3142H,0028H,3143H) ;  (* move.w d1,38(a0) x        *)
    CODE(002AH,3144H,002CH) ;  (* move.w d2,40(a0) y        *)
    CODE(0A003H) ;             (* move.w d3,42(a0) x1       *)
END Line ;                     (* move.w d4,44(a0) y1, $a003*) 

PROCEDURE Plot(x, y : INTEGER) ;
BEGIN
    SETREG(1,x) ; SETREG(2,y) ;         (* move.l d7,a0     *)
    CODE(2047H,2468H) ;                 (* move.l 12(a0),a2 *)
    CODE(000CH,34C1H) ;                 (* move.w d1,(a2)+  *)
    CODE(3482H,0A001H) ;                (* move.w d2,(a2)   *)
END Plot ;                              (* dc.w $a001       *)

PROCEDURE Locate(x,y : INTEGER) : INTEGER ;
BEGIN
    SETREG(1,x) ; SETREG(2,y) ;         (* move.l d7,a0     *)
    CODE(2047H,2068H) ;                 (* move.l 12(a0),a0 *)
    CODE(000CH,30C1H) ;                 (* move.w d1,(a0)+  *)
    CODE(3082H,0A002H) ;                (* move.w d2,(a0)   *)
RETURN INTEGER(REGISTER(0)) ;           (* dc.w $a002       *)
END Locate ;

PROCEDURE PlotColour( color : INTEGER ) ;
BEGIN
        SETREG(1,color) ;               (* move.l d7,a0    *)
        CODE(2047H,2468H,0008H,3481H) ; (* move.l 8(a0),a0 *) 
END PlotColour ;                        (* move.w d1,(a0)  *)

PROCEDURE LineAttribs( linemask, wrtmode : INTEGER ) ;
BEGIN
    SETREG(1,linemask) ; SETREG(2,wrtmode) ; (* move.l d7,a0     *)
    CODE(2047H,3141H,0022H,3142H,0024H) ;    (* move.w d1,34(a0) *)
END LineAttribs ;                            (* move.w d2,36(a0) *)

PROCEDURE LineColour(p1,p2,p3,p4 : INTEGER) ; 
BEGIN
    SETREG(1,p1) ; SETREG(2,p2) ;       (* move.l d7,a0     *)
    SETREG(3,p3) ; SETREG(4,p4) ;       (* move.w d1,24(a0) *)
    CODE(2047H,3141H,0018H) ;           (* move.w d2,26(a0) *)
    CODE(3142H,001AH,3143H) ;           (* move.w d3,28(a0) *)
    CODE(001CH,3144H,001EH) ;           (* move.w d4,30(a0) *)
END LineColour ;

BEGIN   (* main *** initialize line_a variables *)
    CODE(0A000H,2E08H) ;                (* dc.w $a000  *)
                                        (* move.l a0,d7*)   
END LINEA.