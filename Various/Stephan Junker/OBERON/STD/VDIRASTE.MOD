MODULE VDIRaster;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |17.1.93  |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM,VC:=VDIControl,VI:=VDIInput,VDI;

TYPE mfdbrec*   = RECORD                (* memory form definition block *)
                    Addr*   : LONGINT;  (* address of first plane       *)
                    Width*  : INTEGER;  (* form width in pixels         *)
                    Height* : INTEGER;  (* form height in pixels        *)
                    WidthW* : INTEGER;  (* form width in words          *)
                    Format* : INTEGER;  (* format, 0 = device specific
                                                    1 = standard format  *)
                    Planes* : INTEGER;  (* number of memory planes      *)
                    Rsrvd1  : INTEGER;
                    Rsrvd2  : INTEGER;
                    Rsrvd3  : INTEGER;
                  END(*RECORD*);
     pxyarray*  = ARRAY 8 OF INTEGER;

     helprec    = RECORD
                    dummy   : ARRAY 7 OF INTEGER;
                    Src,Des : LONGINT;
                  END(*RECORD*);
     helpptr    = POINTER TO helprec;

PROCEDURE VroCpyfm*(Handle,WrMode : INTEGER; VAR PxyArray : pxyarray;
                    VAR SrcMFDB,DesMFDB : mfdbrec);
  VAR Ptr : helpptr;
 BEGIN
  VDI.ParmBlk.Ptsin := S.ADR(PxyArray);
  VDI.Intin[0] := WrMode;
  Ptr := S.ADR(VDI.Contrl);
  Ptr.Src := S.ADR(SrcMFDB); Ptr.Des := S.ADR(DesMFDB);
  VDI.Call(109,0,Handle,04000100H);
  VDI.ParmBlk.Ptsin := S.ADR(VDI.Ptsin);
 END VroCpyfm;

PROCEDURE VrtCpyfm*(Handle,WrMode : INTEGER; VAR PxyArray : pxyarray;
                    VAR SrcMFDB,DesMFDB : mfdbrec; Color0,Color1 : INTEGER);
  VAR Ptr : helpptr;
 BEGIN
  VDI.ParmBlk.Ptsin := S.ADR(PxyArray);
  VDI.Intin[0] := WrMode; VDI.Intin[1] := Color0;
  VDI.Intin[2] := Color1; Ptr := S.ADR(VDI.Contrl);
  Ptr^.Src := S.ADR(SrcMFDB); Ptr^.Des := S.ADR(DesMFDB);
  VDI.Call(121,0,Handle,04000300H);
  VDI.ParmBlk.Ptsin := S.ADR(VDI.Ptsin);
 END VrtCpyfm;

PROCEDURE VrTrnfm*(Handle : INTEGER; VAR SrcMFDB,DesMFDB : mfdbrec);
  VAR Ptr : helpptr;
 BEGIN
  Ptr := S.ADR(VDI.Contrl);
  Ptr^.Src := S.ADR(SrcMFDB); Ptr^.Des := S.ADR(DesMFDB);
  VDI.Call(110,0,Handle,00000000H);
 END VrTrnfm;

PROCEDURE VGetPixel*(Handle,X,Y : INTEGER; VAR Pel,Index : INTEGER);
 BEGIN
  VDI.Ptsin[0] := X; VDI.Ptsin[1] := Y;
  VDI.Call(105,0,Handle,01000000H);
  Pel := VDI.Intout[0]; Index := VDI.Intout[1];
 END VGetPixel;

PROCEDURE ScrollDown*(Handle,x1,y1,x2,y2,Pixels : INTEGER);
  VAR Mfdb1,Mfdb2 : mfdbrec;
      Pxy         : pxyarray;
 BEGIN
  Mfdb1.Addr := 0; Mfdb2.Addr := 0;
  Pxy[0] := x1; Pxy[1] := y1;
  Pxy[2] := x2; Pxy[3] := y2 - Pixels;
  Pxy[4] := x1; Pxy[5] := y1 + Pixels;
  Pxy[6] := x2; Pxy[7] := y2;
  VC.VsClip(Handle,FALSE,0,0,0,0);
  VI.VHideC(Handle); VroCpyfm(Handle,3,Pxy,Mfdb1,Mfdb2); 
  VI.VShowC(Handle,TRUE);
END ScrollDown;

PROCEDURE ScrollUp*(Handle,x1,y1,x2,y2,Pixels : INTEGER);
  VAR Mfdb1,Mfdb2 : mfdbrec;
      Pxy         : pxyarray;
 BEGIN
  Mfdb1.Addr := 0; Mfdb2.Addr := 0;
  Pxy[0] := x1; Pxy[1] := y1 + Pixels;
  Pxy[2] := x2; Pxy[3] := y2;
  Pxy[4] := x1; Pxy[5] := y1;
  Pxy[6] := x2; Pxy[7] := y2 - Pixels;
  VC.VsClip(Handle,FALSE,0,0,0,0);
  VI.VHideC(Handle); VroCpyfm(Handle,3,Pxy,Mfdb1,Mfdb2); 
  VI.VShowC(Handle,TRUE);
 END ScrollUp;

PROCEDURE ScrollRight*(Handle,x1,y1,x2,y2,Pixels : INTEGER);
  VAR Mfdb1,Mfdb2 : mfdbrec;
      Pxy         : pxyarray;
 BEGIN
  Mfdb1.Addr := 0; Mfdb2.Addr := 0;
  Pxy[0] := x1; Pxy[1] := y1;
  Pxy[2] := x2 - Pixels; Pxy[3] := y2;
  Pxy[4] := x1 + Pixels; Pxy[5] := y1;
  Pxy[6] := x2; Pxy[7] := y2;
  VC.VsClip(Handle,FALSE,0,0,0,0);
  VI.VHideC(Handle); VroCpyfm(Handle,3,Pxy,Mfdb1,Mfdb2); 
  VI.VShowC(Handle,TRUE);
END ScrollRight;

PROCEDURE ScrollLeft*(Handle,x1,y1,x2,y2,Pixels : INTEGER);
  VAR Mfdb1,Mfdb2 : mfdbrec;
      Pxy         : pxyarray;
 BEGIN
  Mfdb1.Addr := 0; Mfdb2.Addr := 0;
  Pxy[0] := x1 + Pixels; Pxy[1] := y1;
  Pxy[2] := x2; Pxy[3] := y2;
  Pxy[4] := x1; Pxy[5] := y1;
  Pxy[6] := x2 - Pixels; Pxy[7] := y2;
  VC.VsClip(Handle,FALSE,0,0,0,0);
  VI.VHideC(Handle); VroCpyfm(Handle,3,Pxy,Mfdb1,Mfdb2); 
  VI.VShowC(Handle,TRUE);
 END ScrollLeft;

END VDIRaster.
