PROGRAM GDOS_Zeischensaetze (INPUT,OUTPUT);

USES GEMDecl,GEMVdi,GEMAes;

CONST
{$I GDOS\ZEICHEN.I}    

TYPE
    NAMEN_FELD = ARRAY[1..10] OF STRING[32]

{ Die Struktur Objekt enthÑlt alle wichtigen }
{ Informationen Åber Objekte. (z.B. Boxen,   }
{ Menutitel,-eintrÑge) siehe hierzu in [1]   }
    Object   = RECORD                      
            o_next, o_start, o_end,
            o_type, o_flags, o_status : INTEGER;
            o_spec : POINTER;
            o_x, o_y, o_w, o_h  :  INTEGER;
            END;
            
    Tree     = ARRAY [0..50] of Object;      
    TreePtr  = ^Tree;



VAR workin              : IntIn_Array;   
    workout             : WorkOut_Array;       
    men                 : TREEPtr;

{ folgende Felder sind fÅr Schriftinformationen }
    schrift_index       : ARRAY_10;
{ Index                                         }
    SCHRIFT             : ARRAY_10;
{ Nummer des MenÅeintrages                      }
    schrift_text        : NAMEN_FELD;
{ Name   der Schrift                            }

    GDOS_FEHLT,RSC_FEHLT,
    INFO                : STRING;
    x0,y0,w0,ch_bh,
    h0,anzahl,junk,
    handle,vdi_handle   : INTEGER;
    fenst_titel         : STRING;


FUNCTION vq_gdos:INTEGER;
EXTERNAL;
{ Unsere Assembler Routine }
{$L GDOS\GDOS.O}

FUNCTION Init_Resource:BOOLEAN;
VAR ResourceName :  STRING;
    fehler       :  INTEGER;
BEGIN

{ Wegen C-Konvention endet String mit ASCII 0 }
    ResourceName := 'ZEICHEN.RSC' + #0;          
{ und beginnt bei STRING[1] }
    rsrc_load(addr(ResourceName[1]));  

    fehler:=GemError;
    IF fehler = 0 THEN 
    junk:=form_alert(1,addr(RSC_FEHLT[1]))
    ELSE
        rsrc_gaddr(R_TREE,MENU, men);     
        Init_Resource:=fehler>0; 
{ true: RCS geladen              }
                            
END;

FUNCTION Init_Gem:BOOLEAN;
VAR aes_handle,la:INTEGER;
    rsc_load:BOOLEAN;
BEGIN
  AES_handle := appl_init;          
{ Beim AES  anmelden }
  
    IF AES_handle >= 0 THEN BEGIN   

        vdi_handle:=graf_handle(la,ch_bh,la,la);
{ Kennung des physikalischen ArbeitsgerÑtes und }
{ Hîhe des Zeichensatzes erfragen               } 

{ Parameter fÅr den v_opnvwk-Aufruf }
        FOR la := 0 TO 9 DO workin[la] := 1;
        workin[10] := 2;   { Rasterkoordinaten }
    
        v_opnvwk(workin, vdi_handle, workout);
{ virtueller Bildschirm erîffnen } 
    
        rsc_load:=Init_Resource;
        END;
    Init_Gem := (AES_handle >= 0) AND rsc_load;        
{ Hat alles geklappt!  Dann kann's losgehen }
END;

PROCEDURE Exit_Gem;
BEGIN
    rsrc_free;       
    v_clsvwk(vdi_handle);                        
{ Virtueller Bildscchirm abmelden }
    appl_exit;                                   
{ Beim AES abmelden }
END;




PROCEDURE Do_Redraw(window,x0,y0,w0,h0:INTEGER);
VAR p:ARRAY_4;
BEGIN
{ Bearbeitung beginnen }
    wind_update(BEG_UPDATE);     p[0] := x0;                    
    p[1] := y0;
    p[2] := x0 + w0 - 1;
    p[3] := y0 + h0 - 1;
{ Zeichenbereich festlegen }
    vs_clip(vdi_handle, 1, p);
{ Parameter festlegen und Fensterhintergrund }
{ malen                                      }            
    vsf_color(vdi_handle, WHITE);         
    vsf_interior(vdi_handle, SOLID);      
    vr_recfl(vdi_handle, p);              
{ Text ausgeben }
    v_gtext(vdi_handle, x0+40, y0 +40,
        'Das ist ein GDOS-Zeichensatz !  ');
    wind_update(END_UPDATE)               

END ;



PROCEDURE Menu_Vorbereitung;
VAR     la          :   INTEGER;
        hilf        :   STRING;
BEGIN
{ ZeichensÑtze laden }
    anzahl:=vst_load_fonts(vdi_handle,0);
    anzahl:=anzahl+1;
{ Systemzeichensatz zÑhlt auch }

{ Namen und Index werden erfragt  }
{ und in Felder eingetragen       }
    FOR la := 1 TO anzahl DO
        schrift_index[la]:=
        vqt_name(vdi_handle,la,schrift_text[la]);

    FOR la:=1 TO anzahl DO
{ Namen der ZeichensÑtze als MenÅeintrÑge  }    
        BEGIN
        hilf:=Copy(schrift_text[la],1,16);
        hilf:=Concat('  ',hilf);
{ Index des MenÅeintrages wird in SCHRIFT[ ] }
{ gespeichert                                } 
        Schrift[la]:=SCHRIFT1+la-1;
        menu_text(men,Schrift[la],addr(hilf[1]))
        END;
        
    FOR la:=anzahl+1 TO 11 DO
{ restliche EintrÑge verstecken  }
        men^[SCHRIFT1+la-1].o_flags:=
        men^[SCHRIFT1+la-1].o_flags OR HIDETREE;
{ Grîûe der MenÅbox anpassen }
        men^[MENU_BOX].o_h:=anzahl*ch_bh;     
            
{  Systemzeichensatz ist ausgewÑhlt     }
    Menu_iCheck(men,SCHRIFT[1],1);
END;


PROCEDURE Event_Loop;
VAR     la,dummy:   INTEGER;
        last    :   INTEGER;
        msg     :   ARRAY[0..15] OF INTEGER ;
        schluss :   BOOLEAN;

BEGIN
    last:=SCHRIFT[1];
{ last merkt sich MenÅindex, der zuletztaus-   }
{ ausgewÑhlten Schrift                         }

    schluss:=FALSE;
    REPEAT
        Evnt_mesag(@msg);
        IF msg[0] = MN_SELECTED THEN
        BEGIN FOR la:=1 TO anzahl DO
            IF msg[4] = SCHRIFT[la] THEN
{   Schrift setzen  und  MenÅeintrag      } 
{   kennzeichnen                          }               
                BEGIN
                vst_font(vdi_handle,
                schrift_index[la]);
                Do_Redraw(handle,x0,y0,w0,h0);
                menu_icheck(men,last,0);
                menu_icheck(men,SCHRIFT[la],1);
                last:=SCHRIFT[la];
                END;
        IF msg[4] = ENDE THEN
              schluss:=TRUE;
        IF msg[4] = ABOUT THEN
            junk:=form_alert(1,addr(INFO[1]));
        menu_tnormal(men,msg[3],1);
        END;

    UNTIL schluss;

END;




BEGIN  {HAUPTPROGRAM}
    GDOS_FEHLT:='[3][ | GDOS ist nicht 
    installiert ! ][Ende]'+#00 ;
    RSC_FEHLT:='[3][ | ZEICHNEN.RSC nicht 
    gefunden ! ][Ende]'+#00 ;
    INFO:='[0][ | GDOS-Demo by Wolfgang Sattler ! 
    ][OK]'+#00;

    junk:=0;
    IF vq_gdos = 0 THEN
        junk:=form_alert(1,addr(GDOS_FEHLT[1]));
    IF Init_Gem  AND (junk=0) THEN
        BEGIN
        Menu_Vorbereitung;
        menu_bar(men,1);

        x0:=10;
        y0:=100;
        w0:=400;
        h0:=100;
        fenst_titel:=' Ausgabefenster '
         +#00 +#00;
        handle:=wind_create(NAME,x0,y0,w0,h0);
        wind_set(handle,WF_NAME,
            HiPtr(fenst_titel[1]),
            LoPtr(fenst_titel[1]),0,0);
        wind_open(handle,x0,y0,w0,h0);
        wind_get(handle,WF_WORKXYWH,
            x0,y0,w0,h0);
        Do_Redraw(handle,x0,y0,w0,h0);
        
        graf_mouse(ARROW, NIL);

        Event_Loop;

        wind_close(handle);
        wind_delete(handle);
        menu_bar(men,0);
        vst_unload_fonts(vdi_handle,0);
{  lîscht ZeichensÑtze aus dem Speicher  }

        Exit_Gem;
        END; 

END.

