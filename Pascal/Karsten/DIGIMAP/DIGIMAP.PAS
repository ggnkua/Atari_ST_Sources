{$S60}
{$C-,D-,P-,T+}

PROGRAM Digi_Info;


  CONST

    Version        = ' Ver 1.4.KH TOS';               (* Version *)
    Date           = 'AUGUST 92';                     (* Versionsdatum *)
    MaxDigi        = 2500;                            (* Anzahl der Digipeater *)
    MaxLink        = 6000;                            (* Maximale Anzahl der Links *)
    Link_Depth     = 30;                              (* Maximale Linktiefe *)
    pi             = 3.14156;

  type namens_typ   = packed array[1 .. 80] of char;
  
       dta_typ      = packed record
                        reserved  : packed array[0 .. 19] of byte;
                        reserved1 : byte;
                        attribut  : byte;
                        zeit      : integer;
                        datum     : integer;
                        laenge    : long_integer;
                        name      : packed array[1 .. 14] of char
                      end;
                      
       t_link_array = array[0 .. maxlink] of integer;
       
       t_s9         = array[0 .. maxdigi] of string[9];
       
       t_s7         = array[0 .. maxdigi] of string[7];
       
       t_s2         = array[0 .. maxdigi] of string[2];
       
       t_r          = array[0 .. maxdigi] of real;
       
       t_lm         = packed array[0 .. maxlink] of boolean;
       
       t_dm         = packed array[0 .. maxdigi] of boolean;
       
       t_save_rec   = record
                        testmaxdigi, testmaxlink : integer;
                        anz_digis,anz_links      : integer;
                        link_start,link_end,
                        link_gamma               : t_link_array;
                        call                     : t_s9;
                        qth,qrg                  : t_s7;
                        typ                      : t_s2;
                        ost,nord                 : t_r
                      end;
                      
  
 (******************* Globale Variablen ************************************)

  VAR

    daten                         : t_save_rec;
    Route                         : t_link_array;
    linkmask                      : t_lm;
    digimask                      : t_dm;
    ka                            : Integer;
    Dummy                         : String[2];
    ReadSTR, TmpSTR1              : String;
    DigiFile                      : Text;
    Line1, Line2                  : String[255];
    call1,s                       : string;
    i, Anfang, DigiA, DigiB, 
    paracount                     : integer;
    ausgabe                       : text;
    sp_flag                       : boolean;
    qual                          : real;
	record_size					  : Long_Integer;
	KAOS_Halt					  : long_integer;
 
 (************ Kleinschreibung in Gro·schreibung umwandeln *****************)

  
 {  Hier kommen die Deklarationen der benîtigten GEMDOS - Funktionen }
 
 function fcreate(var name : namens_typ;attribut : integer):integer;
 
   gemdos($3c);
   
 function fopen(var name : namens_typ;modus : integer):integer;
 
   gemdos($3d);
   
 procedure fclose(handle : integer);
 
   gemdos($3e);
   
 function fread(handle : integer;anzahl : long_integer;var daten : t_save_rec):long_integer;
 
   gemdos($3f);
   
 function fwrite(handle :integer;anzahl : long_integer;var daten : t_save_rec):long_integer;
 
   gemdos($40);
   
  procedure fsetdta(var dta : dta_typ);
  
    gemdos($1a);
    
  function fsfirst(var name : namens_typ; attribut : integer): integer;
  
    gemdos($4e);

  function Sconfig(mode: integer; value: long_integer): long_integer;
	gemdos($33);
    
  procedure clrscr;
  
    begin
      write(chr(27),'E')
    end;
    
  procedure gotoxy(x,y : integer);
  
    begin
      write(chr(27),'Y',chr(32+y),chr(32+x))
    end;
    
  PROCEDURE ToUpper ( VAR TmpSTR : Char );

  VAR
    Num      : Integer;

  BEGIN
    Num := Ord ( TmpSTR );
    IF ( Num >= 97 )  THEN TmpSTR := Chr ( Num-32 )
  END;

  function frac(e : real):real;
  
    begin
      frac := e - trunc(e)
    end;
    
  function suche_digi(diginame : string):integer;
  
    var              ch : char;
        n,loi,mii,hii,i : integer;
                     lg : real;
        
    begin
      for i := 1 to 9 do
        begin
          ch := diginame[i];
          toupper(ch);
          diginame[i] := ch
        end;
      lg := ln(daten.anz_digis) / ln(2);
      n := trunc(lg) + 2;
      loi := 1;
      hii := daten.anz_digis;
      mii := (loi + hii) div 2;
      i := 1;
      while not((i = n) or (daten.call[mii] = diginame)) do
        begin
          if daten.call[mii] < diginame then loi := mii
                                        else hii := mii;
          mii := (loi + hii) div 2;
          i := i + 1
        end;
      if daten.call[mii] = diginame then suche_digi := mii
                                    else suche_digi := 0
    end;
              
 (********************** Locator in QTH umrechnen **************************)
 (********************** nur zur Digiroute-KompatibilitÑt ******************)

 PROCEDURE locator_koordinaten ( QTH : String; VAR oest_laenge, noerd_breite : Real );


    VAR    asckor     : array[1..6] of byte;
           maske      : array[1..6] of byte;
           i          : integer;
           WiInfo     : ARRAY[1..6] OF integer;

    BEGIN
      qth := concat(qth,'       ');
      if pos(' ',qth) >6  then
        begin
          asckor[1] := 65;   asckor[2] := 65;
          asckor[3] := 48;   asckor[4] := 48;
          asckor[5] := 65;   asckor[6] := 65;
      
          maske[1] := 223;   maske[2] := 223;
          maske[3] := 255;   maske[4] := 255;
          maske[5] := 223;   maske[6] := 223;
      
   (* Ermittlung der Indexziffern aus dem QTH-Kenner *)

          FOR i := 1 TO 6 DO
            WiInfo[i] := ( Ord ( QTH[i] ) & Maske[i] ) -AscKor[i];

   (* Berechnung der geografischen Koordinate aus den Indexziffern *)

          oest_laenge := -180+WiInfo[1]*20+WiInfo[3]*2+WiInfo[5]/12+1/24;
          noerd_breite := -90+WiInfo[2]*10+WiInfo[4]*1+WiInfo[6]/24+1/48
        end
      else 
        begin
          oest_laenge := 400;
          noerd_breite := 400
        end

    END;   
 
  procedure  DMS ( e:real;f : boolean; var gms : string); { Umformen Dezimalgrad }
                                                          { in Grad/Minuten/Sekunden }
   VAR d, m, s : INTEGER;
       ds      : STRING[3];
       ms      : STRING[2];
       n_e_fl  : boolean;

    BEGIN
      n_e_fl := e >= 0;
      e := abs(e);
      d := trunc (e);
      if abs(d)>360 then gMS := '???'
      else
        begin
          e := 60*FRAC(e);
          m := trunc (e);
          writev(ds,d);
          writev(ms,m:2);
          IF ms[1]=' ' THEN ms[1]:='0';
         gMS := concat(ds,#248,ms,#39);
         { Sekunden-Angabe ist sinnlos, Loc-Feld hat 2.5 * 5 minuten ! }
         if f then
           if n_e_fl then gms := concat(gms,' N')
                     else gms := concat(gms,' S')
         else
           if n_e_fl then gms := concat(gms,' O')
                     else gms := concat(gms,' W')
       end
    END;


  function direct_dist(la,ba,lb,bb : real):real;
  
    var e,x : real;
    
    begin
      x := SIN(ba) * SIN(bb) + COS(ba) * COS(bb) * COS(lb-la);  
      if x < 1 then
        begin
          e := PI/2-ARCTAN ( x / SQRT (1-SQR(x) ) ) ;   { Berechnung fÅr ARCCOS }
          direct_Dist := e*6370
        end
      else direct_dist := 0;
    end;
      
  FUNCTION Dist ( a,b : INTEGER ) : REAL;           { Berechnen der Entfernung }
                                                    { zwischen 2 in Dezimalgrad }
   VAR ba,bb,la,lb : REAL;                          { angegebenen Punkten }

    BEGIN
      la := daten.OST[a]*pi/180;
      ba := daten.NORD[a]*pi/180;
      lb := daten.OST[b]*pi/180;
      bb := daten.NORD[b]*pi/180;
      dist := direct_dist(la,ba,lb,bb)
    END;
 
 (******************* einlesen der digipeaterdaten *************************)

  procedure load_name(var name : namens_typ);
  
    begin
      name[1]  := 'd' ; name[2]  := 'i';
      name[3]  := 'g' ; name[4]  := 'i';
      name[5]  := 'm' ; name[6]  := 'a';
      name[7]  := 'p' ; name[8]  := '.';
      name[9]  := 'f' ; name[10] := 's';
      name[11] := 't' ; name[12] := chr(0)
    end;
    
  FUNCTION Load_FST : BOOLEAN;               { Fast-Load von DG9EP }
  
    VAR    name   : namens_typ;
           handle : integer;
                l : long_integer;
             help : boolean;

    BEGIN
      load_name(name);
      handle := fopen(name,0);
      help := handle >= 0;
      if help then
        begin
          l := fread(handle,record_size,daten);
          help := l = record_size;
          if   (daten.testmaxdigi <> maxdigi) 
            or (daten.testmaxlink <> maxlink) then help := false;
          fclose(handle)
        end;
      load_fst := help
    end;
        
  procedure save_fst;
  
    var   name : namens_typ;
        handle : integer;
             l : long_integer;
        
    begin
      load_name(name);
      handle := fcreate(name,0);
      if handle >= 0 then 
        begin
          daten.testmaxdigi := maxdigi;
          daten.testmaxlink := maxlink;
          l := fwrite(handle,record_size,daten);
          fclose(handle)
        end
    end;
    

  function check_datum : boolean;
  
    var                       dta : dta_typ;
                             name : namens_typ;
                             help : boolean;
                    datum1,datum2 : integer;
    
    begin
      help := false;
      fsetdta(dta);
      load_name(name);
      i := fsfirst(name,0);
      if i <> -33 then 
        begin
          datum1 := dta.datum;
          load_name(name);
          name[9] := 'd';
          name[10] := 'a';
          name[11] := 't';
          i := fsfirst(name,0);
          if i <> -33 then
            begin
              datum2 := dta.datum;
              help := (datum2 > datum1)
            end
        end;
      check_datum := help
    end;
              
  PROCEDURE Load_Digi;

  VAR

    i,j,l                     : Integer;
    noerd_breite, oest_laenge : Real;
    DigiFile                  : Text;
    tmpstr2                   : string[255];
    last_call                 : string;
    flag                      : boolean;

  BEGIN
    Reset ( DigiFile,'digimap.dat' );
    writeln;
    i := 1;
    daten.anz_digis := 0;
    REPEAT
      REPEAT
        readln(digifile,tmpstr2);
        flag := tmpstr2 = '';
        if not flag then
        begin
            j := 1;
            l := length(tmpstr2);
            if tmpstr2[1] <> '#' then
			begin
	            daten.call[i] := '';
    	        while not ((j>l) or (tmpstr2[j] = ',')) do
        	      begin 
            	    if length(daten.call[i]) <> 9 then daten.call[i] := concat(daten.call[i],tmpstr2[j]);
                	j := j + 1
	              end;
    	        write(daten.call[i], #13);
        	    if daten.call[i] < last_call then
              	begin
                	write(chr(27),'j');
                	gotoxy(0,20);
                	writeln('Warnung : Eintrag von ',daten.call[i],' nicht in alphabetischer');
                	writeln('          Reihenfolge !!!');
                	write(chr(27),'k')
              	end
            	else last_call := daten.call[i];
            	j := j + 1;
            	daten.qth[i] := '';
            	while not ((j>l) or (tmpstr2[j] = ',')) do
            	begin 
                	daten.qth[i] := concat(daten.qth[i],tmpstr2[j]);
                	j := j + 1
              	end;
            	j := j + 1;
            	daten.typ[i] := '';
            	while not ((j>l) or (tmpstr2[j] = ',')) do
           	    begin 
                	if tmpstr2[j] <> ' ' then
                	daten.typ[i] := concat(daten.typ[i],tmpstr2[j]);
                	j := j + 1
              	end;
            	j := j + 2;
            	daten.qrg[i] := '';
            	while not ((j>l) or (tmpstr2[j] = ',')) do
              	begin 
                	daten.qrg[i] := concat(daten.qrg[i],tmpstr2[j]);
                	j := j + 1
              	end;
            	j := j + 1
			end;
        end;
      until ( ( tmpstr2[1]<>'#' )  OR ( EOF ( DigiFile ) ) );          { Kommentarzeilen Åberlesen }
      locator_koordinaten ( daten.qth[i], daten.Ost[i], daten.Nord[i] );  
      i := i+1;
    UNTIL EOF ( DigiFile ) or flag;
    daten.anz_digis := i-1;
    Reset ( DigiFile );
    Close ( DigiFile );
  END;

 (***************** Berechnen der Linktabelle ******************************)

  PROCEDURE Link_Tab;

  VAR
    i, l, j, Count : Integer;
    di, ci         : Integer;
    Anfang, Ende   : Integer;
    CCall, DCall   : String[10];              { Call-LÑnge 9 Zeichen }
    Line1, Line2   : String[255];
    Info           : String;
    DigiFile       : Text;
    Link           : Integer;                { Gewichtung fÅr Link-QualitÑt }

  BEGIN
    Reset ( DigiFile,'digimap.dat' );
    Count := 1;
    FOR i := 1 TO daten.anz_digis DO
      BEGIN
        WRITE (i : 5,' , ',count : 5,' : ',daten.call[i] , #13 );                 { MitzÑhlen, zur Beruhigung }
        REPEAT
          ReadLn ( DigiFile, Line1 );
        UNTIL ( ( Line1[1]<>'#' )  OR ( EOF ( DigiFile ) ) );
        Anfang := Pos ( '(', Line1 );
        Ende := Pos ( ')', Line1 );
        Line2 := COPY ( Line1, Anfang, ( Ende+1-Anfang ) );
        di := 2;
        WHILE ( Line2[di] <> ')' )  DO
          BEGIN
            ci := 1;
            CCall := '          ';
            WHILE ( Line2[di] <> ',' )  AND ( Line2[di] <> ')' )  DO
              BEGIN
                CCall[ci] := Line2[di];
                di := di+1;
                ci := ci+1;
              END;
            CASE CCall[ci-1] of
              '%' : BEGIN                    { Link-Gewichtung abhÑngig von Baud }
                     Link:=2;                { Wert fÅr Link_Gamma }
                     CCall[ci-1]:=' '        { Link-Symbol vernichten ! }
                    END;
		      '!' : begin
					 Link := 4;
					 CCall[ci-1] := ' '
					end;
              '?' : begin
                      link := 5;
                      ccall[ci-1] := ' '
                    end;
              '#' : BEGIN
                     Link:=7;
                     CCall[ci-1]:=' '
                    END;
              '@' : begin
                      link := 10;
                      ccall[ci-1] := ' '
                    end;
              '$' : BEGIN
                     Link:=16;
                     CCall[ci-1]:=' '
                    END;
              '&' : BEGIN
                     Link:=255;
                     CCall[ci-1]:=' '
                    END;
        otherwise : Link:=22;
             END;
            CCall := COPY ( CCall, 1, 9 );
            IF ( Line2[di] <> ')' ) THEN di := di+1;
            l := suche_digi(ccall);
            if l <> 0 then
              begin
                daten.link_start[Count] := i;
                daten.link_end[Count] := l;
                daten.link_gamma[Count] := Link;
                Count := Count+1;
              END
          end
      end;
    daten.anz_links := Count-1;
    Reset ( DigiFile );
    Close ( DigiFile );
  END;

 (*************************** Autorouter starten ***************************)
 (*                                                                        *)
 (* diese routine ist eine umcodierung des im Buch von Helmuth SpÑth       *)
 (*  -- AUSGEWéHLTE OPERATIONS RESEARCH ALGORITHMEN IN FORTRAN --          *)
 (* abgedruckten fortran programmes basierend auf einem algorithmus von    *)
 (* dijkstra                                                               *)
 (*                                                                        *)
 (*  Der Programmstruktur von Pascal angepasst und mit erlÑuternden        *)
 (*    Kommentaren versehen von Holger Flemming, DH4DAI                    *)
 (**************************************************************************)

  
  
  PROCEDURE auto_Route ( digi_quelle, digi_ziel:integer );

    VAR
         i, j, k, l, d  : Integer;
         dd, max        : Integer;
         kant, next, rn : ARRAY[1..MaxLink] OF Integer;
         flag,flag2     : boolean;
    
    {   Die Arrays kant, next und rn enthalten Tabellen, die dem Router
        auskÅnfte Åber einzelne Digis geben.
        
        
        kant[digi] enthÑlt einen Zeiger, der auf den ersten Link
        in der Linktabelle zeigt, der von "digi" ausgeht. Dies wird
        lediglich dazu genutzt, um wÑhrend des Routens nicht sÑmtliche
        Links durchsuchen zu mÅssen, ob sie von "digi" ausgehen.
        
        
        Die Tabelle next[digi] wird wÑhrend des Routens angelegt. Dabei
        steht in next[digi_quelle] immer der Index des Zieldigis, des
        aktuellen Links. WÑhlt man diesen Zieldigi des aktuellen Links 
        als Index fÅr next[digi], so erhÑlt man den Index des Zieldigis
        des letzten bearbeiteten Links. So lassen sich vorher bearbeitete
        Links wiederfinden, wenn ein Link in eine Sackgasse fÅhrte oder
        die QualitÑt zu schlecht wurde.
        
        rn[digi] enthÑlt die beste QualitÑt, mit der "digi" erreicht 
        werden konnte. Hat der Router "digi" noch nicht erreicht, so 
        steht hier der vorher initialisierte Wert 9999.
        Passent zu diesen qualitÑten steht in der Tabelle route[digi]
        der Nachbardigi, von dem aus "digi" mit der QualitÑt rn[digi]
        erreicht werden kann.
        
        															}
        															
        															
    begin
      route[1] := 0;
      j := 0;
      for k := 1 to daten.anz_links do  { Hier wird die Tabelle kant[digis] }
        begin                     { erzeugt, die fÅr jeden Digi       }
          ka := daten.link_start[k];    { den ersten Link in der Linktabelle}
          if ka <> j then         { enthÑlt                           }
            begin
              kant[ka] := k;
              j := ka
            end
        end;
      max := 9999;
      for i := 1 to daten.anz_digis do    { Hier werden die tabellen        }
        begin                       { next[digis] und rn[digis]       }
          next[i] := 0;             { initialisiert.                  }
          rn[i] := max
        end;
      rn[digi_quelle] := 0;         { Beste qualitÑt am Einstieg      }
      i := digi_quelle;             { Anfang der Strecke              }
      next[digi_quelle] := -1;      { Es gibt keinenvorherigen Digi   }
      repeat
        ka := kant[i];              { ka ist Zeiger auf ersten Link   }
        for k := ka to daten.anz_links do { alle Links durchgehen           }
          begin
            if daten.link_start[k] <> i then
              k := daten.anz_links        { Schon alle Links vom aktuellen  }
                                    { Digi durch .                    }
            else
              begin
                j := daten.link_end[k];                      { j = Ziel des aktuellen Links    }
                if not (linkmask[k] or digimask[j])          { Wurde der Link oder Zieldigi auch nicht Maskiert ? }
                   and ((daten.typ[j] = '3')                 { Nur Åber Digis, nicht Åber Boxen linken }
                        or (j = digi_ziel))	then			 { Am Ende ist alles erlaubt }
                  begin
                    d := rn[i] + daten.link_gamma[k];            { neue QualitÑt           }
                    if d < rn[j] then                      { neue Qual. besser als alte ?    }
                      begin
                        rn[j] := d;                        { neue QualitÑt beim Zieldigi     }
                        route[j] := i;                     { Ziel ist von Quelle aus erreichbar }
                        if next[j] = 0 then                { War das Ziel schon mal erreicht ?  }
                          begin
                            next[j] := next[digi_quelle];  { Beim Ziel das vorherige Linkziel eintragen }
                            next[digi_quelle] := j         { Bei Quelldigi aktuelles Linkziel eintragen }
                          end
                      end
                  end
              end
          end;
        flag := next[digi_quelle] < 0;      { Gibt es Åberhaupt noch einen Link ? }
        if not flag then                    { Ja ! }
          begin
            ka := digi_quelle;
            d  := max;                      { Initialisieren }
            repeat
              i := next[ka];                { letztes Linkziel nach ka }
              dd := rn[i];                   { qualitÑt nach dd         }
              if dd < d then                { QualitÑt besser als vorherige }
                begin
                  j := ka;                  { j zeigt jetzt auf besseren Link }
                  d := dd                   { bessere QualitÑt }
                end;
              ka := i;                      { nÑchster Link ausprobieren }
            until next[i]<= 0;              { solange bis alle Links durch sind }
            i := next[j];
            next[j] := next[i]
          end
      until (i = digi_ziel) or flag;        { Bis das Ziel erreicht ist oder 
                                              Keine Mîglichkeit mehr existiert }
      if not flag then
        begin
          ka := digi_ziel;                      { ka ist digi_ziel}
          i := 1;                               { i ist ZÑhlvariable }
          repeat
            rn[i] := ka;
            flag2 := ka = digi_quelle;
            if not flag2 then
              begin
                ka := route[ka];
                i := i + 1
              end
          until flag2;
          ka := i;
          k := ka + 1;
          for i := 1 to ka do
            route[i] := rn[k - i]
        end
    end;
    
 (************ Ausgabe der Digipeater-Links ********************************)

  PROCEDURE Show_Links ( i : Integer );

  VAR
    l : Integer;
    s : integer;

  BEGIN
    IF i<=daten.anz_digis THEN                 { Sicherheitsma·nahme gegen unerklÑrte AbstÅrze ... }
      FOR l := 1 TO daten.anz_links DO
        BEGIN
          IF ( daten.link_start[l] = i )  THEN
            BEGIN
              WRITE (ausgabe, daten.call[daten.link_end[l]] );
              s := round(dist(daten.link_start[l],daten.link_end[l]));
              if s < 0 then write(ausgabe,'   Entfernung : ----km ')
                       else write(ausgabe,'   Entfernung : ',s:4,'km ');
              case daten.link_gamma[l] of
                  2 : writeln (ausgabe, ' Drahtstrecke ');
				  4 : writeln (ausgabe, '38400 Baud');
                  5 : writeln (ausgabe, '19200 Baud');
                  7 : WRITELN (ausgabe, ' 9600 Baud' );
                 10 : writeln (ausgabe, ' 4800 Baud');
                 16 : WRITELN (ausgabe, ' 2400 Baud' );
                 22 : WRITELN (ausgabe, ' 1200 Baud' );
                255 : WRITELN (ausgabe, 'in Bau/Planung' )
              END
            END
        END
  END;


 (************ Ausgabe eines Digipeater-Links ******************************)

  PROCEDURE Show_Link ( i, j : Integer;var q,di : real );

  VAR
    l : Integer;

  BEGIN
    IF i<=daten.anz_digis THEN                 { Sicherheitsma·nahme gegen unerklÑrte AbstÅrze ... }
      l := 1;
      while not((l > daten.anz_links) or 
               ((daten.link_start[l] = i)  and (daten.link_end[l] = j))) do l := l + 1;
      case daten.link_gamma[l] of
          2 : write (ausgabe, '<----> ');
		  4 : write (ausgabe, '<38k4> ');
          5 : write (ausgabe, '<19K2> ');
          7 : WRITE (ausgabe, '< 9K6> ' );
         10 : write (ausgabe, '< 4K8> ');
         16 : WRITE (ausgabe, '< 2K4> ' );
         22 : WRITE (ausgabe, '< 1K2> ' );
        255 : WRITE (ausgabe, '<im Bau> ' );
      END;
      q := q * ((255 - daten.link_gamma[l]) / 255);
      di := di + dist(i,j)
  END;
  
  procedure kurz_anleitung;
  
    BEGIN
      GOTOXY ( 1, 10 );
      WRITELN(ausgabe,'Kurzanleitung: ' );
      WRITELN(ausgabe);
      writeln(ausgabe,'Anzahl der Digis : ',daten.anz_digis : 5);
      writeln(ausgabe,'Anzahl der Links : ',daten.anz_links : 5);
      writeln(ausgabe);
      WRITELN(ausgabe,'Aufruf: - DIGIINFO <Call>          : Liefert Infos zu <Call> ' );
      writeln(ausgabe,'        - DIGIINFO <Praef>         : Liefert eine Liste von Calls gemÑû Prafix');
      writeln(ausgabe,'        - DIGIINFO <QRG.xxx>       : Liefert eine Liste von Calls auf der QRG');
      writeln(ausgabe,'        - DIGIINFO <WW-Loc>        : Liefert die Geographischen Koordinaten zu');
      writeln(ausgabe,'                                     dem angegebenen Locator, sowie die ');
      writeln(ausgabe,'                                     Entfernung zu diesem Standort');
      WRITELN(ausgabe,'        - DIGIINFO <1> <2>         : Liefert Route von <1> zu <2>' );
      writeln(ausgabe,'        - DIGIINFO <1> <2> <3>     : Liefert Route von <1> zu <2>');
      writeln(ausgabe,'                                     die nicht Åber <3> fÅhrt');
      writeln(ausgabe,'        - DIGIINFO <1> <2> <3/4>   : Liefert Route von <1> zu <2>');
      writeln(ausgabe,'                                     die nicht Åber den Link <3>-<4> fÅhrt');
      writeln(ausgabe);
      writeln(ausgabe,' <1> <2> <3> und <4> sind durch Digipeaterrufzeichen zu ersetzen!');
      writeln(ausgabe,' Die Anzahl der RouterbeschrÑnkungen ist nur durch die LÑnge der');
      writeln(ausgabe,' Kommandozeile begrenzt.');
    END;

  function info_suche : boolean;
  
    var         i : integer;  
        ostr,nstr : string;
  
    begin
      Reset ( DigiFile,'digimap.dat' );
      if suche_digi(tmpstr1) <> 0 then 
        begin
          FOR i := 1 TO daten.anz_digis DO
            BEGIN
              REPEAT                                       { Kommentarzeilen Åberlesen }
                ReadLn ( DigiFile, Line1 );
              UNTIL ( ( Line1[1]<>'#' )  OR ( EOF ( DigiFile ) ) );
              Call1 := COPY ( Line1, 1, 9 );
              IF ( TmpSTR1 = Call1 )  THEN
                BEGIN
                  Anfang := Pos ( '),', Line1 );
                  Line2 := COPY ( Line1, Anfang+2, 60 );
                  GOTOXY ( 1, 9 );
                  WRITELN (ausgabe, 'Informationen zu: ', Call1 );
                  WRITELN (ausgabe);
                  dms(daten.ost[i],false,ostr);
                  dms(daten.nord[i],true,nstr);
                  writeln(ausgabe,' Koordinaten : ',ostr,'  und ',nstr);
                  writeln(ausgabe);
                  Show_Links ( i );
                  WRITELN (ausgabe);
                  WRITELN (ausgabe, 'typ   Locator    qrg      Infos' );
                  IF daten.typ[i]='2' THEN WRITE (ausgabe,'BBS   ' )  
                  ELSE if daten.typ[i] = '3' then WRITE (ausgabe, 'DIGI  ' )
                  else if daten.typ[i] = '4' then write (ausgabe, 'DXC   ')
                  else if daten.typ[i] = '5' then write (ausgabe, 'WX    ');
                  WRITELN (ausgabe, daten.qth[i], ' , ', daten.qrg[i], ' , ', Line2 );
                  i := daten.anz_digis;
                END
            END;
          info_suche := true
        end
      else info_suche := false
    end;
  
  procedure praefix_suche;
  
    var wx,i,l : integer;
          call : string;
            ch : char;
             f : boolean;
    begin
      f := false;
      writeln(ausgabe);
      writeln(ausgabe,'Suche nach PrÑfix : ');
      writeln(ausgabe);
      tmpstr1 := copy(tmpstr1,1,pos(' ',tmpstr1)-1);
      l := length(tmpstr1);
      for i := 1 to daten.anz_digis do
        begin
          call1 := copy(daten.call[i],1,l);
          if tmpstr1 = call1 then 
            repeat
              f := true;
              call := concat(daten.call[i],' ');
              write(ausgabe,copy(daten.call[i],1,pos(' ', call ) -1 ));
              if i mod 6 = 0 then writeln(ausgabe)
              else write(ausgabe,' ; ');
              i := i + 1;
              call1 := copy(daten.call[i],1,l);
            until (tmpstr1 <> call1) or (i = maxdigi)
        end;
      if not f then writeln(ausgabe,' Keine Information gefunden')
    end;

  procedure qrg_suche;
  
    var j,i : integer;
    
    begin
      j := 0;
      TmpSTR1 := COPY ( TmpSTR1, 1, POS ( ' ', TMPStr1 ) -1 );           { String kÅrzen }
      IF POS ( '.', TmpSTR1 ) =0 THEN TmpSTR1 := concat(TmpSTR1,'.');    { Dezimalpunkt anhÑngen }
      WHILE POS ( '.', TmpSTR1 )<4 DO TmpSTR1 := concat(' ',TmpSTR1);    { und Punkt in die Mitte }
      WHILE POS ( '.', TmpSTR1 )>4 DO DELETE ( TmpSTR1, 1, 1 );          { (POS=4) bringen }
      WRITELN(ausgabe);
      writeln(ausgabe,' Suche nach Digis auf der Frequenz :',tmpstr1,' MHz');
      for i := 1 to maxdigi do
        begin
          if tmpstr1 = daten.qrg[i] then 
            begin
              write(ausgabe,copy(daten.call[i],1,pos(' ',daten.call[i])-1),' ; ');
              j := j + 1;
              if j mod 8 = 0 then writeln(ausgabe)
            end
        end;
      if j = 0 then writeln(ausgabe,' Keine Digis auf dieser Frequenz gefunden !!! ')
    end;
  
  function check_loc : boolean;
  
    var h : boolean;
    
    begin
      h := true;
      if not (tmpstr1[1] in ['A' .. 'Z']) then h := false;
      if not (tmpstr1[2] in ['A' .. 'Z']) then h := false;
      if not (tmpstr1[3] in ['0' .. '9']) then h := false;
      if not (tmpstr1[4] in ['0' .. '9']) then h := false;
      if not (tmpstr1[5] in ['A' .. 'Z']) then h := false;
      if not (tmpstr1[6] in ['A' .. 'Z']) then h := false;
      check_loc := h
    end;
  
  procedure locator_info;
  
    var l,b,myb,myl,d : real;
            lstr,bstr : string;
                  dat : file of record
                                  b,l : real
                                end;
    
    begin
      locator_koordinaten(tmpstr1,l,b);
      dms(l,false,lstr);
      dms(b,true,bstr);
      l := l / 180 * pi;
      b := b / 180 * pi;
      writeln(ausgabe);
      writeln(ausgabe,'Umwandlung von Locator in Geographische Koordinaten :');
      writeln(ausgabe);
      writeln(ausgabe,'Ihr Locator ',tmpstr1,' entspricht den Koordinaten');
      writeln(ausgabe);
      writeln(ausgabe,lstr,' LÑnge und ',bstr,' Breite');
      writeln(ausgabe);
      io_check(false);
      reset(dat,'digiinfo.qth');
      if io_result = 0 then
        begin
          io_check(true);
          myl := dat^.l / 180 * pi;
          myb := dat^.b / 180 * pi;
          d := direct_dist(l,b,myl,myb);
          writeln(ausgabe,'Die Entfernung zwischen Ihrem Locator und dem Standort dieser');
          writeln(ausgabe);
          writeln(ausgabe,'Station betrÑgt : ',round(d) : 5,'km');
          writeln(ausgabe)
        end
      else io_check(true)
    end;
  procedure digi_infos;
  
    var wx,i,l : integer;
            ch : char;
             f : boolean;

    BEGIN
      f := true;
      cmd_getarg(1,readstr);
      ReadSTR:=COPY ( CONCAT (  readstr , '         ' ) , 1, 9 );
      TmpSTR1 := readstr;
      FOR i := 1 TO 9 DO 
        begin
          ch := tmpstr1[i];
          ToUpper (ch);
          tmpstr1[i] := ch
        end;
      if check_loc then locator_info
      else
        if tmpstr1[1] in ['1' .. '9'] then 
          if tmpstr1[2] in ['1' .. '9'] then qrg_suche
                                        else begin end
                                      else f := info_suche;
      if not f then praefix_suche;
      Close ( DigiFile )
    END;


  procedure mask_digi(digi : integer);
  
    begin
      digimask[digi] := true;
    end;
    
  procedure mask_link(d1,d2 : integer);
  
    var i : integer;
    
    begin
      for i := 1 to daten.anz_links do
        begin
          if (daten.link_start[i] = d1) and (daten.link_end[i] = d2) then linkmask[i] := true;
          if (daten.link_start[i] = d2) and (daten.link_end[i] = d1) then linkmask[i] := true
        end
    end;
          
  procedure masking;
  
    var diginame1,diginame2 : string;
        i,digi1,digi2,p,l   : integer;
        ch                  : char;
    
    begin
      for i := 3 to paracount do
        begin
          cmd_getarg(i,diginame1);
          p := pos('/',diginame1);
          if p=0 then 
            begin
              diginame1 := COPY ( CONCAT ( diginame1 , '         ' ) , 1, 9 );
              digi1 := suche_digi(diginame1);
              mask_digi(digi1)
            end
          else
            begin
              l := length(diginame1);
              diginame2 := copy(diginame1,p+1,l-p);
              diginame1 := copy(diginame1,1,p-1);
              diginame1 := COPY ( CONCAT ( diginame1 , '         ' ) , 1, 9 );
              diginame2 := COPY ( CONCAT ( diginame2 , '         ' ) , 1, 9 );
              digi1 := suche_digi(diginame1);
              digi2 := suche_digi(diginame2);
              mask_link(digi1,digi2)
            end
        end
    end;
    
  procedure routing;
  
    var  i : integer;
        ch : char;
        entf1,entf2 : real;
        
    BEGIN
      GOTOXY ( 1, 10 );
      cmd_getarg(1,tmpstr1);
      TmpSTR1 := COPY ( CONCAT ( tmpstr1 , '         ' ) , 1, 9 );
      digia := suche_digi(tmpstr1);
      cmd_getarg(2,tmpstr1);
      TmpSTR1 := COPY ( CONCAT ( tmpstr1 , '         ' ) , 1, 9 );
      digib := suche_digi(tmpstr1);
      if paracount > 2 then masking;
      ka := Link_Depth + 1;
      IF ( ( DigiA<>0 )  AND ( DigiB<>0 ) )
        THEN auto_Route ( DigiA, DigiB );         { Kein Routing wenn falsche Eingabe }
      IF ( ka < Link_Depth )  THEN
        BEGIN
          WRITE (ausgabe, daten.call[DigiA] );
          WRITE (ausgabe, 'connect to  ' );
          WRITEln (ausgabe, daten.call[DigiB] );
          IF ka > 2 THEN                                { Kein Pfad wenn direkt ! }
            BEGIN
              qual := 1;
              entf1 := 0;
              WRITELN (ausgabe);
              FOR i := 1 TO ka-1 DO
                BEGIN
                  WRITE (ausgabe, COPY ( daten.call[Route[i]], 1, POS ( ' ', daten.call[Route[i]] ) ) );
                  if i mod 6 = 0 then writeln(ausgabe);
                  Show_Link ( Route[i], Route[i+1],qual,entf1 )
                END;
              WRITELN (ausgabe, daten.call[Route[ka]] );
            END
			else
			entf1 := dist(route[1],route[ka]);
          entf2 := dist(route[1],route[ka]);
          writeln(ausgabe);
          writeln(ausgabe,'Die Entfernung zwischen beiden Digis betrÑgt : ',round(entf2) : 5,'km');
          writeln(ausgabe,'            Die gesammte Linkdistanz betrÑgt : ',round(entf1) : 5,'km');
          writeln(ausgabe);
          writeln(ausgabe,'    Das EntfernungsverhÑltnis ist : ',round(entf2 / entf1 * 100),'%');
          WRITELN(ausgabe); WRITELN (ausgabe, 'QualitÑt: ', round(Qual*100),'%' );
        END
      ELSE
        BEGIN
          IF ( ( DigiA<>0 )  AND ( DigiB<>0 ) )  THEN
            BEGIN
              WRITE (ausgabe, daten.call[DigiA] );                    { Auch Ausgabe, wenn nichts gefunden }
              WRITE (ausgabe, 'connect to  ' );
              WRITELN (ausgabe, daten.call[DigiB] );
            END;
          WRITELN(ausgabe);
          WRITELN (ausgabe, 'Kein Connect mîglich' );
        END;
   END;

   procedure erstelle_fst;
   
     BEGIN
       GOTOXY ( 5, 9 );WRITELN (ausgabe, 'digipeater loading' );
       Load_digi;                                      (* Digipeater vom Datenfile einlesen *)
       GOTOXY ( 5, 10 );WRITELN (ausgabe, 'building Link table' );
       Link_Tab;                                       (* Linktabelle erstellen *)
       Save_FST;
       GOTOXY ( 5, 9 );WRITELN (ausgabe, '                  ' );
       GOTOXY ( 5, 10 );WRITELN (ausgabe, '                   ' );
       writeln(ausgabe,'                     ');
     END;

 (********************************* Hauptprogramm ****************************)

  BEGIN
    paracount := cmd_args;
    if paracount > 2 then
      begin
        cmd_getarg(paracount-2,s);         { Drittletzten Parameter holen }
        sp_flag :=  length(s) < 3          { Wurde Programm von SP aus aufgerufen }
      end;

	record_size := sizeof(daten);

    if sp_flag then rewrite(ausgabe,'out.txt')
               else rewrite(ausgabe,'CON:');
    for i := 0 to maxdigi do digimask[i] := false;
    for i := 0 to maxlink do linkmask[i] := false;
    if not sp_flag then CLRSCR;
    GOTOXY ( 5, 3 );WRITELN (ausgabe, 'DIGI - INFO ',Version );
    GOTOXY ( 3, 5 );WRITELN (ausgabe, 'by Holger Flemming, DH4DAI ',Date );
	GOTOXY ( 3, 6 );writeln(ausgabe,'mal wieder modifiziert von DC7OS');
    gotoxy(2,7);writeln(ausgabe,' Nach einem MS DOS - Programm von Patrik Sesseler, DF3VI ');
    writeln(ausgabe);
    if check_datum then erstelle_fst
                   else if not load_fst then erstelle_fst;
    if sp_flag then paracount := paracount - 3; { Die letzten 3 Para. sind zu vernachlÑûigen }
         CASE paracount of 
           0 : kurz_anleitung;
           1 : digi_infos;
   otherwise : routing
         end;
	KAOS_Halt := Sconfig(0,$100);
	if KAOS_Halt > 0 then KAOS_Halt := (KAOS_Halt div $100) mod 2
					 else KAOS_Halt := 1;
    if (not sp_flag) and (KAOS_Halt = 1) then
      begin
        gotoxy(24,24);
        write(' ZurÅck zum Desktop mit <Return>');
        readln
      end
  END.

(DH4DAI) DH4DAI de DB0SGL>