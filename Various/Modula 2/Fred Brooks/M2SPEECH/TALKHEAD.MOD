MODULE          game;

IMPORT  GEMVDIbase,VDIControls,AESGraphics,
        VDIOutputs,GEMAESbase,XBIOS,
        AESWindows;

FROM    SYSTEM  IMPORT  ADDRESS,ADR,TSIZE,BYTE,REGISTER;

FROM    Strings IMPORT  Concat;

FROM    TextIO  IMPORT  WriteLn,WriteInt,ReadLn;

FROM    GEMDOS  IMPORT  Open,Close,Read,OldTerm,SetDTA,SFirst,SNext;

FROM    speech  IMPORT  initspeechmodule,say,setrate,setpitch;

FROM    Storage IMPORT  CreateHeap,ALLOCATE,DEALLOCATE;

                        (* GEM imports *)

FROM    VDIAttribs      IMPORT         SetFillColour;

FROM    AESApplications IMPORT  ApplInitialise,ApplExit;

FROM    AESGraphics     IMPORT  GrafMouse;

TYPE    register      =       POINTER TO LONGINT;

VAR
        filenames,nulls                 :       ARRAY [0..255] OF CHAR;
        inbuffer                        :       ARRAY [0..1] OF CHAR;
        filehandle,i,j,mover,lipspos    :       INTEGER;
        done,eof                        :       BOOLEAN;
        workin                          :       GEMVDIbase.VDIWorkInType;
        workout                         :       GEMVDIbase.VDIWorkOutType;
        k,handle,result,window,
        wc,hc,wf,hf,np,linenumber,
        oldlinenumber,item,x,y,w,h      :       INTEGER;
        position,r,p,lips,background    :       CARDINAL;
        raster,rectArray                :       GEMVDIbase.PxyArrayType;
        pipebuff                        :       ARRAY [0..9] OF INTEGER;
        junkbuff                        :       ARRAY [0..50] OF INTEGER;
        savepal,newpal                  :       XBIOS.Palette;
        tree,maintree,screen,newscreen,
        adjscreen                       :       ADDRESS;
        D0                              :       POINTER TO register;
        recordsize,filesize             :       LONGCARD;

PROCEDURE       getsize;
VAR
        dta                             :       ARRAY [0..43] OF BYTE;
        name                            :       ARRAY [0..15] OF CHAR;
        fsize                           :       POINTER TO LONGCARD;
BEGIN
        SetDTA(ADR(dta));
        fsize:=ADR(dta)+26;
        name:="SPEECH.TXT";
        SFirst(name,0,result);
        filesize:=fsize^;
        IF result#0 THEN
           filesize:=LONGCARD(0);
        END;
END             getsize;

PROCEDURE       marker(number: INTEGER);
BEGIN
        WriteLn;
        WriteInt(number,8);
END     marker;

PROCEDURE       initscreen;
BEGIN
        k:=ApplInitialise(); 
        handle:=AESGraphics.GrafHandle(wc,hc,wf,hf);
        FOR k:=1 TO 9 DO workin[k]:=1 END;
        workin[10]:=2;
        VDIControls.OpenVirtualWorkstation(workin,handle,workout);
        AESGraphics.GrafMouse(GEMAESbase.Arrow,NIL);
        AESGraphics.GrafMouse(GEMAESbase.MouseOff,NIL);
        window:=AESWindows.WindowCreate(0,0,0,workout[0],workout[1]);
        AESWindows.WindowOpen(window,0,0,workout[0],workout[1]);
        raster[0]:=0;          raster[1]:=0;
        raster[2]:=workout[0]; raster[3]:=workout[1];
        wipewindow;
END             initscreen;

PROCEDURE       closescreen;
BEGIN
        AESWindows.WindowClose(window);
        AESWindows.WindowDelete(window);
        VDIControls.CloseVirtualWorkstation(handle); 
        ApplExit;
        XBIOS.SetScreenBase(ADDRESS(-1),ADDRESS(-1),1);
        OldTerm();
END             closescreen;                                     

PROCEDURE       wipewindow;
BEGIN
        AESGraphics.GrafMouse(GEMAESbase.MouseOff,NIL);
        result:=SetFillColour(handle,1);
        VDIOutputs.FillRectangle(handle,raster);
        AESGraphics.GrafMouse(GEMAESbase.MouseOn,NIL);
END             wipewindow;


BEGIN
        initscreen;
        getsize;
        lipspos:=1;
        mover:=1;
        FOR i:=0 TO 15 DO
        savepal[i]:=XBIOS.SetColour(i,-1);
        END;
        screen:=XBIOS.ScreenPhysicalBase();
        filenames:="SPEECH.NEO";
        Open(filenames,0,filehandle);
        recordsize:=4;
        Read(filehandle,recordsize,ADR(junkbuff));
        XBIOS.SetScreenBase(ADDRESS(-1),ADDRESS(-1),junkbuff[1]);
        recordsize:=32;
        Read(filehandle,recordsize,ADR(newpal));
        XBIOS.SetPalette(newpal);
        background:=newpal[6];
        lips:=newpal[1];
        recordsize:=92;
        Read(filehandle,recordsize,ADR(junkbuff));
        recordsize:=32000;
        Read(filehandle,recordsize,screen);
        done:=Close(filehandle);

        IF initspeechmodule() THEN
           filenames:="SPEECH.TXT";
           Open(filenames,0,filehandle);
           inbuffer[1]:=CHAR(0);
           REPEAT
                nulls:="";
                LOOP
                    IF filesize = LONGCARD(0) THEN
                       eof:=TRUE;
                       EXIT;
                    END;
                    recordsize:=1;
                    Read(filehandle,recordsize,ADR(inbuffer));
                    filesize:=filesize-LONGCARD(1);
                    eof:=FALSE;
                    Concat(nulls,inbuffer,nulls);
                    IF inbuffer[0]=' ' THEN EXIT END;
                END;
                IF nulls[0]#' ' THEN
                       IF mover=1 THEN
                          newpal[lipspos]:=background;
                          XBIOS.SetPalette(newpal);
                          ELSE
                          newpal[lipspos]:=lips;
                          XBIOS.SetPalette(newpal);
                       END;

                       lipspos:=lipspos+mover;

                       IF lipspos=4 THEN
                          mover:=(-1);
                          lipspos:=lipspos+mover;
                       END;
                       IF lipspos=0 THEN
                          mover:=1;
                          lipspos:=lipspos+mover;
                       END;
                END;

                say(nulls);
           UNTIL eof;
           done:=Close(filehandle);
        END;

        ReadLn;
        AESGraphics.GrafMouse(GEMAESbase.MouseOn,NIL); 
        AESGraphics.GrafMouse(GEMAESbase.Arrow,NIL); 
        XBIOS.SetPalette(savepal);
        closescreen;
END             game.