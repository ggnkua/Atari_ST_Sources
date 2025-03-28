PROGRAM GDOS_Demo (INPUT,OUTPUT);

{ von Wolfgang Sattler 1992    }
{(c) MAXON Computer 1993       }

USES GEMDecl,GEMVdi,GEMAes,GDOS;

{$I GDOSDEMO.I}    


VAR men                 : Pointer;
    RSC_FEHLT,INFO      : STRING;
    x0,y0,w0,
    h0,junk,
    win_handle          : INTEGER;
    handle              : INTEGER;
    fenst_titel         : STRING;
    ch:CHAR;


{ Laden des Resource-Files: }

PROCEDURE Init_Resource;
VAR ResourceName :  STRING;
    fehler       :  INTEGER;

BEGIN

    If RunFromMemory THEN
        ResourceName := 'GDOS\GDOSDEMO.RSC' + #0
    ELSE
        ResourceName := 'GDOSDEMO.RSC' + #0;  

    rsrc_load(ResourceName[1]);  
    fehler:=GemError;

    IF fehler = 0 THEN 
        BEGIN
        junk:=form_alert(1,RSC_FEHLT[1]);
        halt(0);
        END
    ELSE
        rsrc_gaddr(R_TREE,MENU, men);     
                            
END;


{ Die 'Ausgabe'-Routine wird von allen GerÑten }
{ benutzt. öbergeben wird das GerÑtehandle     }

PROCEDURE Ausgabe(handle,x0,y0:INTEGER);
VAR p:ARRAY_4;
    la,dummy : INTEGER;

BEGIN

{ Textfarbe setzen:   }
    vst_color(handle,BLACK);

{ Texthîhe mit vst_point setzen  }
    vst_point(handle,12,dummy,dummy,
                    dummy,dummy);
  
    FOR la:=1 TO bild_anz DO
        BEGIN

{ Auswahl der Schrift mittels Schriftindex  }
 
        vst_font(handle,
        bild_schrift[la].index);

{ Ausgabe des Textes  }
        v_gtext(handle, x0+40,y0+la*40,
        'Das ist der GDOS-Zeichensatz: '
        + bild_schrift[la].name);

        END;                

END ;


{ Zeichnen des Fensterhintergrundes }

PROCEDURE Do_Redraw(window,x0,y0,w0,h0:INTEGER);
VAR p:ARRAY_4;

BEGIN

{ Bearbeitung beginnen  }
  graf_mouse(M_OFF,NIL);
  wind_update(BEG_MCTRL);      
  wind_update(BEG_UPDATE);      

  p[0] := x0;                    
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

{ Jetzt geht es zur Ausgabe des Textes      }
  Ausgabe(vdi_handle,x0,y0);

  wind_update(END_UPDATE);               
  wind_update(END_MCTRL);      
  graf_mouse(M_ON,NIL);

END ;



{ Event_Verwaltung: Es werden nur die MenÅ- }
{ aktionen Åberwacht.                       }

PROCEDURE Event_Loop;
VAR     msg     :   ARRAY[0..15] OF INTEGER ;
        schluss :   BOOLEAN;

BEGIN

    schluss:=FALSE;
    REPEAT
        Evnt_mesag(msg);

    { Programmende:     }    
        IF msg[4] = ENDE THEN
              schluss:=TRUE;
   
    { Ausgabe auf Drucker: }
        IF msg[4] = DRUC THEN
            BEGIN
            graf_mouse(BUSYBEE,NIL);

        { Laden des GerÑtetreibers und der }
        { ZeichensÑtze:                    }
            handle:=Open_Work(2,21);

        { Ausgabe-Routine aufrufen:        } 
            Ausgabe(handle,10,40);

        { Um den Ausdruck zu starten muû man   }
        { den internen Grafikpuffer vom        }
        { GDOS ausgeben:                       }
            v_updwk(handle);
        
        { GerÑtetreiber und ZeichensÑtze   }
        { lîschen:                         }
            Close_Work(handle);
            
            graf_mouse(ARROW,NIL);
            END;

    { Ausgabe auf Metafile:                }
        IF msg[4] = META THEN
            BEGIN
            graf_mouse(BUSYBEE,NIL);

        { Metafiletreiber hat GerÑtenummer 31 }
            handle:=Open_Work(2,31);

       { Dateiname auf 'GDOSDEMO.GEM' setzen }
            vm_filename(handle,'GDOSDEMO.GEM');  

            Ausgabe(handle,10,40);

        { Ausdehnung der Ausgabe:           }
            v_meta_extents(handle,0,0,450,280);

        { Koordinatensystem und Ausmaûe der }
        { Ausgabenseite festlegen:          }
            vm_coords(handle,0,200,480,0);
            vm_pagesize(handle,1905,2540);
        

            Close_Work(handle);
            graf_mouse(ARROW,NIL);
            END;
            
    { Infomeldung:     }
        IF msg[4] = ABOUT THEN
                junk:=form_alert(1,INFO[1]);

    { MenÅtitel normal darstellen:     }
        menu_tnormal(men,msg[3],1);

    UNTIL schluss;

END;




BEGIN  {HAUPTPROGRAM}
    RSC_FEHLT:='[3][ | GDOSDEMO.RSC nicht '
    + 'gefunden ! ][Ende]'+#00 ;
    INFO:='[0][  |    GDOS-Demo by|  Wolfgang'+
    ' Sattler ! |      Ω 1992 ][OK]'+#00;

{ Resourcen laden   }
    Init_Resource;

{ öberprÅfen ob GDOS geladen ist und gegeben- }
{ falls Programm beenden                      }
    Init_Gdos(FALSE);

    menu_bar(men,1);
    x0:=10;
    y0:=100;
    w0:=480;
    h0:=200;
    fenst_titel:=' Ausgabe ins Fenster ';
    fenst_titel:=fenst_titel +#00 +#00 ;
    win_handle:=wind_create(NAME,x0,y0,w0,h0);
    wind_set(win_handle,WF_NAME,
        HiPtr(fenst_titel[1]),
        LoPtr(fenst_titel[1]),0,0);
    graf_mouse(M_OFF, NIL);
    wind_open(win_handle,x0,y0,w0,h0);
    graf_mouse(M_ON, NIL);
    wind_get(win_handle,WF_WORKXYWH,
        x0,y0,w0,h0);
    Do_Redraw(win_handle,x0,y0,w0,h0);
        
    graf_mouse(ARROW, NIL);

    Event_Loop;
    
    wind_close(win_handle);
    wind_delete(win_handle);
    menu_bar(men,0);
    
{ BildschirmzeichensÑtze lîschen und }
{ beim VDI und AES abmelden:         }
    Exit_Gdos; 
    
END.
