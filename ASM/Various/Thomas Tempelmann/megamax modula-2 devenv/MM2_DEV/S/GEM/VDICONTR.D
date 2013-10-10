DEFINITION MODULE VDIControls;


(*  Megamax-Modula 2 GEM-Library :  Die VDI Kontrollfunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  29.10.87
 *
 *  Version   2.2     V#0015
 *)
 
FROM    SYSTEM   IMPORT WORD;

FROM    GrafBase IMPORT Rectangle;
 
FROM    GEMEnv   IMPORT DeviceHandle;
 
 
PROCEDURE ClearWorkstation (handle: DeviceHandle);

        (*  Lîscht den Arbeitsbereich oder lîst zum Beispiel bei Druckern
         *  einen Seitenvorschub aus.
         *)
                
PROCEDURE UpdateWorkstation (handle: DeviceHandle);

        (*  Ist fÅr Bildschirmarbeitsstationen irrelevant, bei Arbeits-
         *  stationen, die die Ausgaben erst puffern (z.B.: Drucker)
         *  werden durch diesem Aufruf alle gepufferten Aktionen ausge-
         *  fÅhrt.
         *)

PROCEDURE LoadFonts (    handle: DeviceHandle;
                         select: WORD;
                     VAR loaded: CARDINAL);

        (*  Damit kînnen gemÑû der Datei 'ASSIGN.SYS' (gehîrt zum optionalen
         *  GDOS) zusÑtzliche ZeichensÑtze geladen werden.
         *  'loaded' gibt an, wieviele ZeichensÑtze nachgeladen wurden.
         *  'select' wird bisher nicht unterstÅtzt.
         *  Im DEMO-Modul "TextDemo" finden Sie ein Beispiel, wie
         *  diese GDOS-Fonts benutzt werden.
         *)

PROCEDURE UnloadFonts (handle: DeviceHandle; select: WORD);

        (*  Die mit 'LoadFonts' nachgeladenen ZeichensÑtze werden
         *  wieder aus dem Speicher entfernt. Die ZeichensÑtze werden
         *  allerdings erst aus dem Speicher gelîscht, nachdem sie
         *  von allen Arbeitsstationen freigegeben wurden.
         *)

PROCEDURE SetClipping (handle: DeviceHandle; frame: Rectangle);

        (*  Mit dieser Procedur kann man erreichen, daû alle Ausgaben
         *  auûerhalb eines bestimmten Rechteckbereichs ('frame') unter-
         *  drÅckt werden.
         *  Dabei ist zu beachten, daû dies bei den Rasterkopierroutinen
         *  nur fÅr Speicherbereiche funktioniert, deren Startadresse mit
         *  'NIL' besetzt wurde. (siehe auch 'GEMRasters')
         *)
        
PROCEDURE DisableClipping (handle: DeviceHandle);

        (*  Hiernach werden alle Ausgaben wieder vollstÑndig durch-
         *  gefÅhrt.
         *)
        
END VDIControls.