PROGRAM Draw;

TYPE clip = ARRAY[0..3] OF INTEGER;

VAR clp:clip;
    phys:LONG_INTEGER;
    x1,x2,y1,y2,r,i,res:INTEGER;

FUNCTION rnd:INTEGER;
XBIOS(17);

FUNCTION xrnd:INTEGER;
BEGIN
xrnd:=(rnd&511)-72;
END;

FUNCTION yrnd:INTEGER;
BEGIN
yrnd:=(rnd&255)-28;
END;

FUNCTION rrnd:INTEGER;
BEGIN
rrnd:=rnd&127;
END;

FUNCTION Physbase:LONG_INTEGER;
XBIOS(2);

FUNCTION GetRez:INTEGER;
XBIOS(4);

PROCEDURE Setscreen(log,phys:LONG_INTEGER; res:INTEGER);
XBIOS(5);

PROCEDURE offmouse;
C;

PROCEDURE onmouse;
C;

PROCEDURE fhline(x1,y1,x2,c:INTEGER; log:LONG_INTEGER; VAR clp:clip);
C;

PROCEDURE fvline(x1,y1,y2,c:INTEGER; log:LONG_INTEGER; VAR clp:clip);
C;

PROCEDURE fcircle(x1,y1,r,c:INTEGER; log:LONG_INTEGER; VAR clp:clip);
C;

PROCEDURE fframe(x1,y1,x2,y2,c:INTEGER; log:LONG_INTEGER; VAR clp:clip);
C;

PROCEDURE fline(x1,y1,x2,y2,c:INTEGER; log:LONG_INTEGER; VAR clp:clip);
C;

PROCEDURE fbox(x1,y1,x2,y2,c:INTEGER; log:LONG_INTEGER; VAR clp:clip);
C;

PROCEDURE fpcircle(x1,y1,r,c:INTEGER; log:LONG_INTEGER; VAR clp:clip);
C;

PROCEDURE fplot(x1,y1,c:INTEGER; log:LONG_INTEGER; VAR clp:clip);
C;

BEGIN
    clp[0]:=0; clp[1]:=0; clp[2]:=319; clp[3]:=199;
    offmouse;
    phys:=Physbase;
    res:=GetRez;
    Setscreen(-1,-1,0);


    FOR i:=0 TO 499 DO fhline(xrnd,yrnd,xrnd,i&15,phys,clp);

    FOR i:=0 TO 499 DO fvline(xrnd,yrnd,yrnd,i&15,phys,clp);

    FOR i:=0 TO 499 DO fcircle(xrnd,yrnd,rrnd,i&15,phys,clp);

    FOR i:=0 TO 499 DO fframe(xrnd,yrnd,xrnd,yrnd,i&15,phys,clp);

    FOR i:=0 TO 499 DO fline(xrnd,yrnd,xrnd,yrnd,i&15,phys,clp);

    FOR i:=0 TO 499 DO fbox(xrnd,yrnd,xrnd,yrnd,i&15,phys,clp);

    FOR i:=0 TO 499 DO fpcircle(xrnd,yrnd,rrnd,i&15,phys,clp);

    FOR i:=0 TO 7499 DO fplot(xrnd,yrnd,i&15,phys,clp);

    Setscreen(-1,-1,res);
    onmouse;
END.
