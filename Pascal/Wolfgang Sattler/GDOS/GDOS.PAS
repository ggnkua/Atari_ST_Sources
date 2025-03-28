Unit GDOS;

{ von Wolfgang Sattler 1992   }
{ (c) MAXON Computer 1993     }

Interface
USES GEMVdi,GEMdecl,GEMAes;

TYPE 

{ Feld zum Verwalten von ZeichensÑtzen }
    SCH_NAME_TYP    =       STRING[32];
    SCHRIFTART = RECORD
            { Nummer die bei vst_font }
            { wird:                   }
                 index:INTEGER;
            { Zeichensatzname:        }     
                 name: SCH_NAME_TYP;
                 END;
    SCHRIFTFELD = ARRAY[1..20] OF SCHRIFTART;
    SchPtr      = ^SCHRIFTFELD;

VAR         
{ Schriftfelder }
    bild_schrift,device_schrift
                        : SCHRIFTFELD;
{ Anzahl der Schriften }
    bild_anz,device_anz :INTEGER;

{ GDOS installiert ? }
    gdos_flag           : BOOLEAN;
    
{ Felder zum ôffnen von VDI-Workstations }
    workin                      : IntIn_Array;   
    workout                     : WorkOut_Array; 
    
{ Handle, d.h. Kennung des virtuellen    }
{ Bildschirmes:                          }    
    vdi_handle                  : INTEGER;
    
{ Kennung des AES-Prozesses: }    
    aes_handle                  : INTEGER;


PROCEDURE vm_coords(handle,llx,lly,urx,ury
    : INTEGER);

PROCEDURE vm_pagesize(handle,pagew,pageh
    : INTEGER);

PROCEDURE Init_GDOS(ohne:BOOLEAN);

FUNCTION Open_Work(koord,device:INTEGER):INTEGER;

PROCEDURE Close_Work(handle:INTEGER);

PROCEDURE Exit_Gdos;

Implementation

TYPE

{ Parameterblock dient zur Konversation mit }
{ dem VDI:                                  } 
   VDIParBlk = RECORD                
        control       : ^control_Array;  
        intin         : ^intin_Array;    
        ptsin         : ^ptsin_Array;    
        intout        : ^intout_Array;   
        ptsout        : ^ptsout_Array;    
        END;


                    
VAR   vdipb : ^VDIParBlk;
      point:Pointer;
      GDOS_FEHLT :STRING;
      junk:INTEGER;             



{ öberprÅfung auf installiertes GDOS:  }
FUNCTION Vq_Gdos:INTEGER;ASSEMBLER;
ASM
        move.w  #-2,D0
        trap    #2
        cmp.w   #-2,d0
        sne     d0
        ext.w   d0 
        move.w  d0,@result
END;


PROCEDURE vm_coords(handle,llx,lly,urx,ury 
    : INTEGER);
BEGIN
    vdipb:=addr(vdi_pb);

    vdipb^.intin^[0]:=1;
    vdipb^.intin^[1]:=llx;
    vdipb^.intin^[2]:=lly;
    vdipb^.intin^[3]:=urx;
    vdipb^.intin^[4]:=ury;

    vdipb^.control^[0]:=5;
    vdipb^.control^[1]:=0;
    vdipb^.control^[2]:=0;
    vdipb^.control^[3]:=5;
    vdipb^.control^[4]:=0;
    vdipb^.control^[5]:=99;
    vdipb^.control^[6]:=handle;
    ASM
    { VDI-Parameterblock   }
       move.l   vdipb,d1 
    { Magic-Number fÅr VDI }       
       move.w   #115,d0 
    { GEM-Aufruf           }
       trap     #2             
    END;       
    
END;


PROCEDURE vm_pagesize(handle,pagew,pageh
    : INTEGER);
BEGIN
    vdipb:=addr(vdi_pb);

    vdipb^.intin^[0]:=0;
    vdipb^.intin^[1]:=pagew;
    vdipb^.intin^[2]:=pageh;

    vdipb^.control^[0]:=5;
    vdipb^.control^[1]:=0;
    vdipb^.control^[2]:=0;
    vdipb^.control^[3]:=3;
    vdipb^.control^[4]:=0;
    vdipb^.control^[5]:=99;
    vdipb^.control^[6]:=handle;
    ASM
    { VDI-Parameterblock   }
       move.l   vdipb,d1 
    { Magic-Number fÅr VDI }       
       move.w   #115,d0 
    { GEM-Aufruf           }
       trap     #2  
    END;       
    
END;



{ Ermitteln der LÑnge eines C-Strings: }
FUNCTION Strlen(name:STRING): INTEGER;
VAR la:INTEGER;
BEGIN
    la:=1;
    while name[la]<>chr(0) DO
        Inc(la);
    Strlen:=la-1;    
END;    


{ Laden von GDOS-ZeichensÑtzen:         }
PROCEDURE Loadfonts(handle:INTEGER;schrift
    :   SchPtr;VAR anzahl:INTEGER);
VAR la:INTEGER;
BEGIN

    IF handle>0 THEN
        BEGIN
    { ZeichensÑtze laden }
        anzahl:=vst_load_fonts(handle,0);
        anzahl:=anzahl+1; 

    { Namen und Index werden erfragt  }
    { und in das Feld eingetragen     }
        FOR la := 1 TO  anzahl DO
            WITH schrift^[la] DO
                BEGIN
                index:=vqt_name(handle,la,name);
          { LÑnge des C-Strings erfragen und in }
          { name[0] eintragen:                  }
                name[0]:=chr(strlen(name));
                END;        
        END;
END;


FUNCTION Open_Work(koord,device:INTEGER):INTEGER;
VAR la :INTEGER;
BEGIN

{ Bei installiertem GDOS îffnen der   }
{ Workstation, sonst den Wert '0' als }
{ Fehler zurÅckgeben:                 }
    IF gdos_flag THEN
        BEGIN
        { GDOS ist installiert }

        { Parameter fÅr den v_opnwk-Aufruf: }
        workin[0] := device;   

        FOR la := 1 TO 9 DO 
            workin[la] := 1;

        workin[10] := koord;   
        
        { ôffnen der Workstation: }    
        v_opnwk(workin,device,workout);

        { ZeichensÑtze laden }    
        loadfonts(device,@device_schrift,
            device_anz);
        END

    ELSE
    { GDOS nicht installiert:   }
    { Fehler: Open_Work:=0      }
        device:=0;     
    
    Open_Work:=device;

END;
    

PROCEDURE Init_GDOS(ohne:BOOLEAN);
BEGIN
    GDOS_FEHLT:='[3][ |  GDOS ist nicht '+
        'installiert ! ][OK]'+#00 ;

    IF gdos_flag=FALSE THEN
        { Kein GDOS installiert !   }
        BEGIN
        junk:=form_alert(1,GDOS_FEHLT[1]);
        { ohne = FALSE -> Programmabbruch }
        IF NOT ohne THEN
            BEGIN
            Halt(0);
            END;
       END

END;


{ Lîschen der ZeichensÑtze und        }
{ des GerÑtetreibers                  }
PROCEDURE Close_Work(handle:INTEGER);
BEGIN
    IF handle <> 0 THEN
        BEGIN
        vst_unload_fonts(handle,0);
        v_clswk(handle);
        END;
END; 



PROCEDURE Exit_Gdos;
BEGIN
{ Lîschen der BildschirmzeichensÑtze: }
    vst_unload_fonts(vdi_handle,0);
    rsrc_free;
    v_clsvwk(vdi_handle);     
    appl_exit;             
END;


PROCEDURE Init_GEM;
VAR la,dummy:INTEGER;
    feld:ARRAY_10;
BEGIN
    aes_handle := appl_init;      

    IF aes_handle >= 0 THEN 
        BEGIN
        vdi_handle := graf_handle(dummy,dummy
            ,dummy,dummy);

        FOR la := 0 TO 9 DO workin[la] := 1;
        workin[10] := 2;  
        v_opnvwk(workin, vdi_handle, workout); 
        
        END
    ELSE 
        BEGIN
        WRITELN(' Applikation konnte nicht '
        + 'geîffnet werden ! ');
        repeat until Keypressed;
        halt(0); 
        END;
END;



BEGIN
{ Anmelden beim GEM:   }
    Init_GEM;
    IF vq_gdos = 0 THEN
        gdos_flag:=FALSE
    ELSE
        BEGIN
        gdos_flag:=TRUE;    
    { BildschirmzeichensÑtze laden: }
        loadfonts(vdi_handle,@bild_schrift,
            bild_anz);
        END;
END.
