{===========================================================================
    Routinen fÅr das Dateihandling mit ST:Pascal+ auf ATARI ST
    von Matthias Baldauf
    
    vom 15.10.1989
 ===========================================================================}
 
program DATEIHANDLING;

{--- Konstantendefinition ---}
const
  {$I o:TRIXCONS.PAS}
  {$I o:GEMCONST.PAS}
  
{--- Typ-Vereinbarungen ---}
type 
  {$I o:TRIXTYPE.PAS}
  {$I o:GEMTYPE.PAS}
  DatNameType = string[150];
  
{--- Variablendeklarationen ---}
var 
  dummy:boolean;
  dateipfad,dateiname,suffix,name:DatNameType;
  a:char;
           
{--- Prozedurteil ---}
  {$I o:TRIXSUBS.PAS}
  {$I o:GEMSUBS.PAS}

{---------------------------------------------------------------------------
           Nachschauen ob Datei mit angegebenem Pfad vorhanden ist
 ---------------------------------------------------------------------------}
function exist_file(dateiname:DatNameType):boolean;
var handle:integer;
    cstr:Cstring;
  function fsfirst(var dateiname:Cstring;attr:integer):integer;
  gemdos($4e);
begin
  PtoCstr(dateiname,cstr);
  handle := fsfirst(cstr,0);
  if handle < 0 then
    exist_file := false
  else
    exist_file := true;
end;

{---------------------------------------------------------------------------
                Pfad beim Starten des Programms ermitteln
 ---------------------------------------------------------------------------}
procedure get_akt_path(var path:DatNameType);
var path_char:Cstring;
    dummy:integer;
  function getdir(var path:Cstring; drv:integer):integer;
  gemdos($47); 
  function dgetdrv:integer;
  gemdos($19);
begin
  dummy := getdir(path_char,0);
  if dummy = 0 then
    begin
      CtoPstr(path_char,path);
      path := concat(chr(dgetdrv+65),':',path);
    end
  else  { Fehler ! }
    ;
end;

{---------------------------------------------------------------------------
                 Neuen Pfad/Dateinamen vom Benutzer holen 
 ---------------------------------------------------------------------------}
function get_new_path_and_filename(var pfad,dateiname:DatNameType):boolean;
var path,name:DatNameType;
    ergebnis:boolean;
begin
  path := copy(pfad,1,length(pfad));
  name := copy(dateiname,1,length(dateiname));
  ergebnis := Get_in_file(path,name);
  if ergebnis then
    begin
      pfad := copy(path,1,length(path));
      dateiname := copy(name,1,length(name));
    end;
  get_new_path_and_filename := ergebnis;
end;

{---------------------------------------------------------------------------
                          Neuen Pfad holen (Dialog)
                         ---------------------------
 Hier kînnen eigene Anpassungen vorgenommen werden (z.B.: Maus-Zeiger wieder
 sichtbar machen, Hintergrund restaurieren etc.)
 ---------------------------------------------------------------------------}                          
function set_path(var path,dateiname:DatNameType):boolean;
var dummy_bool:boolean;
begin
  dummy_bool := get_new_path_and_filename(path,dateiname); 
  set_path := dummy_bool;
end;

{---------------------------------------------------------------------------
            Routinen zum entfernen der Suffix eines Dateinamens    
 ---------------------------------------------------------------------------}
procedure revers_str(var name:DatNameType);
var i,len:integer;
    puffer:DatNameType;
begin
  len := length(name);
  puffer := '';
  for i := len downto 1 do
    puffer := concat(puffer,name[i]);
  name := puffer;
end;

procedure cut_suffix(var dateiname,name,suffix:DatNameType);
var i:integer;
begin
  revers_str(dateiname);
  if pos('\',dateiname) <> 0 then
    begin
      name := copy(dateiname,1,pos('\',dateiname)-1);
      delete(dateiname,1,length(name));
      revers_str(dateiname);
      if pos('.',name) <> 0 then
        begin
          suffix := copy(name,1,pos('.',name)-1);
          revers_str(suffix);
        end
      else
        suffix := '';
      revers_str(name);
      if pos('.',name) <> 0 then
        name := copy(name,1,pos('.',name)-1);
      dateiname := concat(dateiname,name);
    end
  else
    begin
      revers_str(dateiname);
      if pos('.',dateiname) <> 0 then
        name := copy(name,1,pos('.',name)-1);
      if pos('.',dateiname) <> 0 then
        begin
          suffix := copy(dateiname,1,pos('.',dateiname)-1);
          revers_str(suffix);
        end
      else
        suffix := '';
    end;
end;
{---------------------- Suffix Routinen Ende  ------------------------------}

{===========================================================================
                            Hauptprogramm (DEMO)
 ===========================================================================}
begin
  if Init_Gem >= 0 then
    begin
      Clear_Home;

      get_akt_path(dateipfad);                 { aktuellen Pfad ermitteln }
      writeln('Pfad bei Programmstart: ',dateipfad);
            
      writeln;
      writeln('Bitte irgendeine Datei auswÑhlen:');
      dateiname := concat(dateipfad,'\DEMO');   { Dateinamen 'basteln' }
      dateipfad := concat(dateipfad,'\*.*');   { das 'Auswahlpattern' hinzufÅgen }
      dummy := set_path(dateipfad,dateiname);  { File-Selector-Box aufrufen }
      
      if dummy then 
        begin
          Clear_Home;
          writeln('AusgewÑhlte Datei: ',dateiname);

          dummy := exist_file(dateiname);
          if dummy then
            writeln('+++ Datei existiert +++')
          else
            writeln('--- Datei nicht vorhanden ---');
            
          cut_suffix(dateiname,name,suffix);
          writeln('Dateiname und Pfad ohne Suffix: ',dateiname);
          writeln('Dateiname ohne Pfad und ohne Suffix: ',name);
          writeln('Suffix: ',suffix);

          writeln;
          writeln('--- Taste ---');
          read(a);
        end
      else
        begin
          Clear_Home;
          writeln('Sie haben auf ABBRUCH geklickt !!!');
          writeln;
          writeln('--- Taste ---');
          read(a);
        end;

      Exit_Gem;
    end;
end.                            
{------------------------------ PROGRAMMENDE -------------------------------}
