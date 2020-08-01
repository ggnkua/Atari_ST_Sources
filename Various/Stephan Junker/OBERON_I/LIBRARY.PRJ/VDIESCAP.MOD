MODULE VDIEscape;

IMPORT S:=SYSTEM, VDI;


PROCEDURE VBitImage*(handle : INTEGER; filename : ARRAY OF CHAR;
               aspect,xscale,yscale,halign,valign,x1,y1,x2,y2 : INTEGER);
  VAR i : INTEGER;
 BEGIN
  VDI.Intin[0] := aspect; VDI.Intin[1] := xscale;
  VDI.Intin[2] := yscale; VDI.Intin[3] := halign;
  VDI.Intin[4] := valign;
  i := 0;
  WHILE filename[i] # 0X DO VDI.Intin[i+5] := ORD(filename[i]); INC(i) END;
  VDI.Ptsin[0] := x1; VDI.Ptsin[1] := y1;
  VDI.Ptsin[2] := x2; VDI.Ptsin[3] := y2;
  VDI.Call(5,23,handle,02000000H + (i+5)*256);
 END VBitImage;

PROCEDURE VClearDispList*(handle : INTEGER);
 BEGIN
  VDI.Call(5,22,handle,02000000H);
 END VClearDispList;

PROCEDURE VCurdown*(handle : INTEGER);
 BEGIN
  VDI.Call(5,5,handle,0);
 END VCurdown;

PROCEDURE VCurhome*(handle : INTEGER);
 BEGIN
  VDI.Call(5,8,handle,0);
 END VCurhome;

PROCEDURE VCurleft*(handle : INTEGER);
 BEGIN
  VDI.Call(5,7,handle,0);
 END VCurleft;

PROCEDURE VCurright*(handle : INTEGER);
 BEGIN
  VDI.Call(5,6,handle,0);
 END VCurright;

PROCEDURE VCurtext*(handle : INTEGER; string : ARRAY OF CHAR);
  VAR i : INTEGER;
 BEGIN
  i := 0;
  WHILE string[i] # 0X DO VDI.Intin[i] := ORD(string[i]); INC(i) END;
  VDI.Call(5,12,handle,S.LONG(i*256));
 END VCurtext;

PROCEDURE VCurup*(handle : INTEGER);
 BEGIN
  VDI.Call(5,4,handle,0);
 END VCurup;

PROCEDURE VDspcur*(handle,x,y : INTEGER);
 BEGIN
  VDI.Ptsin[0] := x; VDI.Ptsin[1] := y;
  VDI.Call(5,18,handle,01000000H);
 END VDspcur;

PROCEDURE VEeol*(handle : INTEGER);
 BEGIN
  VDI.Call(5,10,handle,0);
 END VEeol;

PROCEDURE VEeos*(handle : INTEGER);
 BEGIN
  VDI.Call(5,9,handle,0);
 END VEeos;

PROCEDURE VEnterCur*(handle : INTEGER);
 BEGIN
  VDI.Call(5,3,handle,0);
 END VEnterCur;

PROCEDURE VExitCur*(handle : INTEGER);
 BEGIN
  VDI.Call(5,2,handle,0);
 END VExitCur;

PROCEDURE VFormAdv*(handle : INTEGER);
 BEGIN
  VDI.Call(5,20,handle,0);
 END VFormAdv;

PROCEDURE VHardcopy*(handle : INTEGER);
 BEGIN
  VDI.Call(5,17,handle,0);
 END VHardcopy;

PROCEDURE VMetaExtents*(handle,minx,miny,maxx,maxy : INTEGER);
 BEGIN
  VDI.Intin[0] := minx; VDI.Intin[1] := miny;
  VDI.Intin[2] := maxx; VDI.Intin[3] := maxy;
  VDI.Call(5,98,handle,02000000H);
 END VMetaExtents;

PROCEDURE VOutputWindow*(handle,x1,y1,x2,y2 : INTEGER);
 BEGIN
  VDI.Intin[0] := x1; VDI.Intin[1] := y1;
  VDI.Intin[2] := x2; VDI.Intin[3] := y2;
  VDI.Call(5,21,handle,02000000H);
 END VOutputWindow;

PROCEDURE VRmcur*(handle : INTEGER);
 BEGIN
  VDI.Call(5,19,handle,0);
 END VRmcur;

PROCEDURE VRvoff*(handle : INTEGER);
 BEGIN
  VDI.Call(5,14,handle,0);
 END VRvoff;

PROCEDURE VRvon*(handle : INTEGER);
 BEGIN
  VDI.Call(5,13,handle,0);
 END VRvon;

PROCEDURE VmFilename(handle : INTEGER; filename : ARRAY OF CHAR);
  VAR i : INTEGER;
 BEGIN
  i := 0;
  WHILE filename[i] # 0X DO VDI.Intin[i] := ORD(filename[i]); INC(i) END;
  VDI.Call(5,100,handle,S.LONG(i*256) );
 END VmFilename;

PROCEDURE VqChcells*(handle : INTEGER; VAR rows,columns : INTEGER);
 BEGIN
  VDI.Call(5,1,handle,2);
  rows := VDI.Intout[0]; columns := VDI.Intout[1];
 END VqChcells;

PROCEDURE VqTabstatus*(handle : INTEGER) : BOOLEAN;
 BEGIN
  VDI.Call(5,16,handle,1); RETURN (VDI.Intout[0] = 1);
 END VqTabstatus;

PROCEDURE VsCuradress*(handle, row, column : INTEGER);
 BEGIN
  VDI.Intin[0] := row; VDI.Intin[1] := column;
  VDI.Call(5,11,handle,200H);
 END VsCuradress;

END VDIEscape.