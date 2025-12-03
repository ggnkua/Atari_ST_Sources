{***************************************************************************}
{*                                                                         *}
{*  Dises Programm Emuliert 2 Atari XE Diskettenstationen. Die Disketten   *}
{*  kînnen mit 128 oder 256 Bytes per Sector, mit 18 oder 26 Sectoren pro  *}
{*  Track, 35,40,77,80 Tracks pro Seite und 1 oder 2 Seiten pro Disk       *}
{*  formatiert werden. ZusÑtzlich kann eine ICD Hardisk emuliert werden.   *}
{*  Es ist damit voll Sparta Dos kompatiebel.                              *}
{*  Das Programm beherscht den Ultra Speed Standart und die wichtigsten    *}
{*  Spezialbefehle einer Speedy 1050.                                      *}
{*                                                                         *}
{*                    Ω 22.05.1988 by Martin Krischik                      *}
{*                                                                         *}
{*  26.11.87  ProgrammgerÅût Datenstruckturen                 Version 1.0  *}
{*  25.12.87  Erste Menuoptionen                                           *}
{*  02.01.88  Aenderung von Arrays auf Random Access Dateien  Version 2.0  *}
{*  03.01.88  Druckerroutienen                                             *}
{*  04.01.88  Diskroutienen                                                *}
{*  06.01.88  Fehlersuche in den Diskroutienen                             *}
{*  07.01.88  Fehler gefunden                                 Version 2.1  *}
{*  11.01.88  Datei I/O fÅr Druckerausgabe                    Version 2.2  *}
{*  27.01.88  Farb Monitor, div. Korrekturen                               *}
{*  01.04.88  Anpassung ST:Pascal plus V2.02 und PASTRIX                   *}
{*  21.04.88  Fortsetzung vom 01.04.88                        Version 2.3  *}
{*  24.04.88  Schreibschutz                                   Version 2.4  *}
{*  22.05.88  Write-Befehl und Fehler im Percom behoben       Version 2.5  *}
{*  29.05.88  Sparta Dos Hard Disk anpassung                  Version 2.6  *}
{*                                                                         *}
{*          Entwicket mit ST Pascal plus V2.02 von CCD-D.Beyelstein        *}
{*                                                                         *}
{***************************************************************************}

program XE_Disk_Simulator(input,output);

{$i lib\mk.i    }
{$i lib\std.i   }
{$i lib\tos.i   }
{$i lib\bios.i  }
{$i lib\xbios.i }
{$i lib\trix.i  }

const Version ='TOS Version 2.6 vom 29.05.1988';

type  sdsector=packed array [1..128] of byte;
      ddsector=packed array [1..256] of byte;
      format  =packed record
                 bps        :128..256;
                 spt        :18..65535;
                 tps        :1..80;
                 spd        :1..2;
               end;
      disk    =packed record
                 nr         :'0'..'8';
                 name       :string;
                 f1         :format;
                 f2         :format;
                 schutz     :boolean;
                 s          :packed file of sdsector;
                 d          :packed file of ddsector;
               end;
      drucker =packed record
                 nr         :char;
                 lf         :boolean;
                 name       :string;
                 output     :text;
               end;
      c_block =packed record
                 unit       :char;
                 command    :char;
                 nr         :short_integer;
                 case short_integer of
                   1:(aux2  :byte;
                      aux1  :byte);
                   2:(sector:short_integer);
               end;

var   ch        :char;
      c0, c1    ,
      c2, c3    ,
      pruef     ,
      screen_res:short_integer;
      void      :long_integer;
      c         :c_block;
      p         :drucker;
      lw        :packed array [1..2] of disk;

{ **********   Initialisierung   ****************************************** }

procedure init;

  var i :short_integer;
      ch:char;

  begin
    rsconf(0,0,-1,-1,-1,-1);
    while bconstat(1)<>0 do
      void :=bconin(1);
    while keypress do
      read(ch);
    lw[1].nr  :='0';
    lw[1].f1.bps:=128;
    lw[1].f1.spt:=18;
    lw[1].f1.tps:=40;
    lw[1].f1.spd:=1;
    lw[1].f2    :=lw[1].f1;
    lw[1].name  :='DISKA.DSK';
    lw[1].schutz:=false;
    lw[2]       :=lw[1];
    lw[2].name  :='DISKB.DSK';
    p.nr        :='0';
    p.name      :='PRN:';
    wrap_off;
  end;

{ **********   Unterprogramme fÅr Bildschimausgabe    **********************}

procedure ja_nein;

  begin
    inv_on; write('J'); inv_off; write('a/');
    inv_on; write('N'); inv_off; write('ein?');
  end;

procedure Deine_wahl;

  begin
    gotoXY(0,22);
    end_of_screen;
    write('      Deine Wahl?');
  end;

procedure invers(ch:char);

  begin
    inv_on;
    write(ch);
    inv_off;
  end;

procedure copyright;

  begin
    clear_home;
    if screen_res<2 then
      begin
        select_color(2);
        select_background(0);
      end;
    inv_on;
    writeln('XE Disk Simulator ',Version,'       Ω 1988 by Martin Krischik');
    writeln('            Entwicket mit ST Pascal plus V2.02 von CCD-D.Beyelstein             ');
    inv_off;
    if screen_res<2 then
      begin
        select_color(1);
        select_background(3);
      end;
  end;

procedure print_disk_stat(lw:disk; x:short_integer; name:char);

  begin
    save_cursor;
    gotoXY(x,3);
      writeln('Disk ',name,':');
    gotoXY(x,5);
    write('Laufwerksnummer: ',lw.nr);
    if lw.schutz then
      write('  gesichert')
    else
      write(' endsichert');
    gotoXY(x,6);    write('Filename:',lw.name:25);
    gotoXY(x,7);    write('Disk   Bytes    pro Sector:',lw.f1.bps);
    gotoXY(x,8);    write('       Sectoren pro Track :',lw.f1.spt);
    gotoXY(x,9);    write('       Tracks   pro Seite :',lw.f1.tps);
    gotoXY(x,10);   write('       Diskettenseiten    :',lw.f1.spd);
    gotoXY(x,11);   write('Format Bytes    pro Sector:',lw.f2.bps);
    gotoXY(x,12);   write('       Sectoren pro Track :',lw.f2.spt);
    gotoXY(x,13);   write('       Tracks   per Seite :',lw.f2.tps);
    gotoXY(x,14);   write('       Diskettenseiten    :',lw.f2.spd);
    restore_cursor;
  end;

procedure print_printer_stat;

  begin
    gotoXY(20,19);
    invers('P');
    if p.nr='0' then
      writeln('rinter ist Aus                   ')
    else
      writeln('rinter ist ',p.name);
  end;

procedure menu;

  begin
    copyright;
    print_disk_stat(lw[1],5,'A');
    print_disk_stat(lw[2],45,'B');
    gotoXY(20,16);  invers('A');  writeln('ktiviere Laufwerk');
    gotoXY(20,17);  invers('D');  writeln('esaktiviere Laufwerk');
    gotoXY(20,18);  invers('S');  writeln('chreibschutz');
    print_printer_stat;
    gotoXY(20,20);  invers('E');  writeln('nde');
    Deine_Wahl;
  end;

{ *********   Allgemeine SIO Unterprogramme   ***************************** }

procedure addpruef(x:byte);

  begin
    pruef:=pruef+x;
    if pruef>=256 then
      pruef:=pruef-255
  end;

procedure ACK;

  begin
    bconout_c(1,'A');
  end;

procedure NAK;

  begin
    bconout_c(1,'N');
  end;

procedure Complete;

  begin
    bconout_c(1,'C');
  end;

procedure Error;

  begin
    bconout_c(1,'E');
  end;

{ **********   Disk Format   ********************************************** }

procedure formatiere(var lw:disk);

  var i:short_integer;

  begin
    close(lw.d);
    close(lw.s);
    lw.f1:=lw.f2;
    if lw.f1.bps>128 then
      begin
        rewrite(lw.d,lw.name);
        lw.d^[1]:=0;
        lw.d^[2]:=1;
        lw.d^[3]:=lw.f1.spt mod 256;
        lw.d^[4]:=lw.f1.tps;
        lw.d^[5]:=lw.f1.spd;
        lw.d^[6]:=ord(lw.schutz);
        lw.d^[7]:=lw.f1.spt div 256;
        put(lw.d);
        for i:=1 to 256 do
          lw.d^[i]:=0;
        for i:=1 to lw.f1.spt*lw.f1.tps*lw.f1.spd do
          put(lw.d,i);
      end
    else
      begin
        rewrite(lw.s,lw.name);
        lw.s^[1]:=128;
        lw.s^[2]:=0;
        lw.s^[3]:=lw.f1.spt mod 256;
        lw.s^[4]:=lw.f1.tps;
        lw.s^[5]:=lw.f1.spd;
        lw.s^[6]:=ord(lw.schutz);
        lw.s^[7]:=lw.f1.spt div 256;  
        put(lw.s);
        for i:=1 to 128 do
          lw.s^[i]:=0;
        for i:=1 to lw.f1.spt*lw.f1.tps*lw.f1.spd do
          put(lw.s);
      end
  end;

{ **********   Disk IO Routienen   **************************************** }

procedure sende_disk_status(var lw:disk);

  var stat1,stat2:byte;

  begin
    ACK;
    stat1:=0;
    stat2:=$ff;
    pruef:=0;
    if lw.f1.bps>128 then
      stat1:=stat1+$20;
    if lw.f1.spt>18 then
      stat1:=stat1+$80;
    if lw.schutz then
      begin
        stat1:=stat1+$04;
        stat2:=stat2-$40;
      end;
    complete;
    bconout(1,stat1);  addpruef(stat1);
    bconout(1,stat2);  addpruef(stat2);
    bconout(1,$ff);    addpruef($ff);
    bconout(1,0);
    bconout(1,pruef);
  end;

procedure sende_sector(var lw:disk);

  var i:short_integer;

  begin
    ACK;
    pruef:=0;
    if lw.f1.bps>128 then
      begin
        get(lw.d,c.sector);
        complete;
        if c.sector<4 then
          begin
            for i:=1 to 128 do
              begin
                bconout(1,lw.d^[i]);
                addpruef(lw.d^[i]);
              end;
          end
        else
          begin
            for i:=1 to lw.f1.bps do
              begin
                bconout(1,lw.d^[i]);
                addpruef(lw.d^[i]);
              end;
          end
      end
    else
      begin
        get(lw.s,c.sector);
        complete;
        for i:=1 to lw.f1.bps do
          begin
            bconout(1,lw.s^[i]);
            addpruef(lw.s^[i]);
          end;
      end;
    bconout(1,pruef);
  end;

procedure empfange_sector(var lw:disk);

  var i:short_integer;

  begin
    ACK;
    pruef:=0;
    if lw.f1.bps>128 then
      begin
        if c.sector<4 then
          begin
            for i:=1 to 128 do
              begin
                lw.d^[i]:=bconin(1);
                addpruef(lw.d^[i]);
              end
          end
        else
          begin
            for i:=1 to lw.f1.bps do
              begin
                lw.d^[i]:=bconin(1);
                addpruef(lw.d^[i]);
              end
          end;
        if pruef=bconin(1) then
          begin
            ACK;
            if lw.schutz then
              error
            else
              begin
                put(lw.d,c.sector);
                complete;
              end
          end
        else
          begin
            NAK;
            Error;
          end
      end
    else
      begin
        for i:=1 to lw.f1.bps do
          begin
            lw.s^[i]:=bconin(1);
            addpruef(lw.s^[i]);
          end;
        if pruef=bconin(1) then
          begin
            ACK;
            if lw.schutz then
              error
            else
              begin
                put(lw.s,c.sector);
                complete;
              end;
          end
        else
          begin
            NAK;
            Error;
          end
      end
  end;

procedure Format_Disk(var lw:disk);

  var i:short_integer;

  begin
    ACK;
    pruef:=0;
    if lw.schutz then
      begin
        error;
        for i:=1 to lw.f1.bps do
          bconout(1,$00);
        bconout(1,$00);
      end
    else
      begin
        formatiere(lw);
        if c.nr=1 then
          print_disk_Stat(lw,5,'A')
        else
          print_disk_stat(lw,45,'B');
        Complete;
        pruef:=0;
        for i:=1 to lw.f1.bps do
          begin
            bconout(1,$ff);
            addpruef($ff);
          end;
        bconout(1,pruef);
      end;
  end;

procedure Auto_Format_Disk(var lw:disk);

  var i:short_integer;

  begin
    ACK;
    if lw.schutz then
      error
    else
      begin
        Complete;
        formatiere(lw);
        if c.nr=1 then
          print_disk_Stat(lw,5,'A')
        else
          print_disk_stat(lw,45,'B');
      end;
  end;

procedure MD_Format_Disk(var lw:disk);

  var i:short_integer;

  begin
    ACK;
    if lw.schutz then
      begin
        error;
        for i:=1 to lw.f1.bps do
          bconout(1,$00);
        bconout(1,$00);
      end
    else
      begin
        lw.f2.bps:=128;
        lw.f2.spt:=26;
        lw.f2.tps:=40;
        lw.f2.spd:=1;
        formatiere(lw);
        if c.nr=1 then
          print_disk_Stat(lw,5,'A')
        else
          print_disk_stat(lw,45,'B');
        Complete;
        pruef:=0;
        for i:=1 to lw.f1.bps do
          begin
            bconout(1,$ff);
            addpruef($ff);
          end;
        bconout(1,pruef);
      end;
  end;

procedure Sende_Config(var lw:disk);

  begin
    ACK;
    pruef:=0;
    Complete;
    bconout(1,lw.f2.tps);
    addpruef(lw.f2.tps);
    bconout(1,1);
    addpruef(1);
    bconout(1,lw.f2.spt div 256);
    addpruef(lw.f2.spt div 256);
    bconout(1,lw.f2.spt mod 256);
    addpruef(lw.f2.spt mod 256);
    bconout(1,lw.f2.spd-1);
    addpruef(lw.f2.spd-1);
    if (lw.f2.bps>128) or (lw.f2.spt>18) then
      begin
        bconout(1,4);
        addpruef(4);
      end
    else
      bconout(1,0);
    bconout(1,lw.f2.bps div 256);
    bconout(1,lw.f2.bps mod 256);
    addpruef(lw.f2.bps div 256);
    addpruef(lw.f2.bps mod 256);
    bconout(1,255);
    addpruef(255);
    bconout(1,0);
    bconout(1,0);
    bconout(1,0);
    bconout(1,pruef);
  end;

procedure Empfange_Config(var lw:disk);

  var bps1,bps2,spt1,spt2,tps,spd:byte;

  begin
    ACK;
    pruef:=0;
    tps:=bconin(1);
    addpruef(tps);
    addpruef(bconin(1));
    spt1:=bconin(1);
    spt2:=bconin(1);
    addpruef(spt1); 
    addpruef(spt2);
    spd:=bconin(1);
    addpruef(spd);
    addpruef(bconin(1));
    bps1:=bconin(1);
    bps2:=bconin(1);
    addpruef(bps1);
    addpruef(bps2);
    addpruef(bconin(1));
    addpruef(bconin(1));
    addpruef(bconin(1));
    addpruef(bconin(1));
    if bconin(1)=pruef then
      begin
        ACK;
        lw.f2.bps:=bps1*256+bps2;
        lw.f2.spt:=spt1*256+spt2;
        lw.f2.tps:=tps;
        lw.f2.spd:=spd+1;
        if c.nr=1 then
          print_disk_Stat(lw,5,'A')
        else
          print_disk_stat(lw,45,'B');
        complete;
      end
    else
      begin
        NAK;
        Error;
      end;
  end;

procedure Sende_SIO_Baut_Rate;

  begin
    ACK;
    Complete;
    bconout(1,40);
    bconout(1,40);
  end;

procedure Schreib_Buffer(var lw:disk);

  begin
    ACK;
    if lw.f1.bps>128 then
      begin
        close(lw.d);
        reset(lw.d,lw.name);
      end
    else
      begin
        close(lw.s);
        reset(lw.s,lw.name);
      end;
    Complete;     
  end;

procedure Ignoriere_Befehl;

  begin
    ACK;
    Complete;
  end;

{ **********   Printer IO Routienen *************************************** }

procedure printline;

  var i    :short_integer;
      dat  :packed array [1..40] of char;

  begin
    ack;
    pruef:=0;
    for i:=1 to 40 do
      begin
        dat[i]:=bconin_c(1);
        addpruef(ord(dat[i]));
      end;
    if bconin(1)=pruef then
      begin
        ACK;
        i:=0;
        repeat
          i:=i+1;
          if dat[i]<>chr(155) then
            write(p.output,dat[i])
          else
            if p.lf then
              writeln(p.output)
            else
              write(p.output,chr(13));
        until (i=40) or (dat[i]=chr(155));
        complete
      end
    else
      begin
        NAK;
        error;
      end;
  end;

procedure sendprintstat;

  begin
    ACK;
    Complete;
    bconout(1,128);
    bconout(1,78);
    bconout(1,5);
    bconout(1,0);
    bconout(1,211);
  end;

{ *********   Hole Kommando von Tatatur oder Åber Schittstelle ************ }

function getcommando:boolean;

  var gueltig,
      keyhit :boolean;

  begin
    repeat
      gueltig:=false;
      keyhit :=false;
      while (bconstat(1)=0) and (not keyhit) do
        if keypress then
          keyhit:=true;
      if keyhit then
        begin
          read(input,ch);
          ch:=upper(ch);
          write(chr(8));
        end
      else
        begin
          pruef:=0;
          c.unit:=bconin_c(1);
          addpruef(ord(c.unit));
          if c.unit in [lw[1].nr,lw[2].nr,p.nr] then
            begin
              if lw[1].nr=c.unit then
                c.nr:=1
              else
                c.nr:=2;
              c.command :=bconin_c(1);
              addpruef(ord(c.command));
              c.aux1    :=bconin(1);
              addpruef(c.aux1);
              c.aux2    :=bconin(1);
              addpruef(c.aux2);
              if bconin(1)=pruef then
                gueltig:=true;
            end
        end;
    until gueltig or keyhit;
    getcommando:=gueltig;
  end;

{ **********   MenÅ Optionen ********************************************** }

procedure aktiviere;

  var nr   :short_integer;
      drive:char;
      name :string;

  procedure open(var lw:disk);

    procedure new_disk;

      begin
        copyright;
        repeat
          print_disk_stat(lw,15,chr(nr+64));
          gotoXY(20,16);  invers('B');  write('ytes pro Sector');
          gotoXY(20,17);  invers('S');  write('ectoren pro Track');
          gotoXY(20,18);  invers('T');  write('acks pro Disk');
          gotoXY(20,19);  invers('D');  write('iskseiten');
          gotoXY(20,20);  invers('H');  write('ard Disk');
          gotoXY(20,21);  invers('F');  write('Fertig');
          Deine_Wahl;
          read(input,ch);
          ch:=upper(ch);
          write(chr(8));
          case ch of
            'B':if lw.f2.bps>128 then
                  lw.f2.bps:=128
                else
                  lw.f2.bps:=256;
            'S':if lw.f2.spt>18 then
                  lw.f2.spt:=18
                else
                  lw.f2.spt:=26;
            'T':if lw.f2.tps<40 then
                  lw.f2.tps:=40
                else
                  if lw.f2.tps<77 then
                    lw.f2.tps:=77
                  else
                    if lw.f2.tps<80 then
                      lw.f2.tps:=80
                    else
                      lw.f2.tps:=35;
            'D':if lw.f2.spd>1 then
                  lw.f2.spd:=1
                else
                  lw.f2.spd:=2;
            'H':begin
                  lw.f2.tps:=1;
                  lw.f2.spd:=1;
                  lw.f2.bps:=256;
                  delete_line;
                  write('Sectoren (4=1KB, 4096=1MB) ?');
                  readln(lw.f2.spt);
                end
          end;
        until ch in ['F','H'];
        io_check(true);
        formatiere(lw);
        menu;
      end;

    begin
      close(lw.d);
      close(lw.s);
      io_check(false);
      reset(lw.s,lw.name);
      if io_result<>0 then
        new_disk
      else
        begin
          lw.f1.bps:=lw.s^[1]+256*lw.s^[2];
          lw.f1.spt:=lw.s^[3]+256*lw.s^[7];
          lw.f1.tps:=lw.s^[4];
          lw.f1.spd:=lw.s^[5];
          lw.f2    :=lw.f1;
          if lw.s^[6]=1 then
            lw.schutz:=true
          else
            lw.schutz:=false;
          if lw.f1.bps>128 then
            begin
              close(lw.s);
              reset(lw.d,lw.name);
            end;
        end;
      io_check(true);
    end;

  begin
    delete_line;
    write('Disk: ');
    read(drive); nr:=ord(upper(drive))-64;
    delete_line;
    write('Laufwerknnummer : ');
    read(drive);
    delete_line;
    write('Filename: ');
    name:='';
    readln(name);
    if length(name)=0 then
      name:=lw[nr].name
    else
      if pos('.',name)=0 then
        name:=concat(name,'.DSK');
    if (drive in ['1'..'8']) and (nr in [1..2]) and filename(name) then
      begin
        lw[nr].nr  :=drive;
        lw[nr].name:=name;
        open(lw[nr]);
        if nr=1 then
          print_disk_Stat(lw[nr],5,'A')
        else
          print_disk_stat(lw[nr],45,'B');
      end
    else
      begin
        delete_line;
        write('Nicht mîglich');
        read(drive);
      end;
   Deine_Wahl;
  end;

procedure desaktiviere;

  var nr   :short_integer;
      drive:char;

  begin
    delete_line;
    write('Disk: ');
    read(drive); nr:=ord(upper(drive))-64;
    if nr in [1..2] then
      begin
        lw[nr].nr:='0';
        if nr=1 then
          print_disk_Stat(lw[nr],5,'A')
        else
          print_disk_stat(lw[nr],45,'B');
        print_disk_stat(lw[nr],5+40*(nr-1),chr(nr+64));
      end
    else
      begin
        delete_line;
        write('Nicht mîglich');
        read(drive);
      end;
    Deine_wahl;
  end;

procedure Schreibschutz;

  var nr   :short_integer;
      drive:char;

  begin
    delete_line;
    write('Disk: ');
    read(drive); nr:=ord(upper(drive))-64;
    if nr in [1..2] then
      begin
        lw[nr].schutz:=not lw[nr].schutz;
        if lw[nr].f1.bps>128 then
          begin
            get(lw[nr].d,0);
            lw[nr].d^[6]:=ord(lw[nr].schutz);
            put(lw[nr].d,0)
          end
        else
          begin
            get(lw[nr].s,0);
            lw[nr].s^[6]:=ord(lw[nr].schutz);
            put(lw[nr].s,0)
          end;
        if nr=1 then
          print_disk_Stat(lw[nr],5,'A')
        else
          print_disk_stat(lw[nr],45,'B');
      end
    else
      begin
        delete_line;
        write('Nicht mîglich');
        read(drive);
      end;
    Deine_Wahl;
  end;

procedure printer;

  var name:string;
      ch  :char;

  begin
    delete_line;
    write('Drucker an '); ja_nein;
    read(ch);
    if upper(ch)='J' then
      begin
        delete_line;
        write('LF nach CR '); ja_nein;
        read(ch);
        if upper(ch)='J' then
          p.lf:=true
        else
          p.lf:=false;
        delete_line;
        write('Filename: ');
        name:='';
        readln(name);
        if length(name)=0 then
          name:=p.name
        else
          if pos('.',name)=0 then
            name:=concat(name,'.LST');
        if filename(name) then
          begin
            p.name:=name;
            rewrite(p.output,p.name);
            p.nr:='@';
          end
      end
    else
      p.nr:='0';
    Print_Printer_Stat;
    Deine_Wahl;
  end;

begin
  screen_res:=getrez;
  if getrez<2 then
    begin
      setscreen_rez(-1,-1,1);
      c0:=setcolor(0,$555);
      c1:=setcolor(1,$347);
      c2:=setcolor(2,$722);
      c3:=setcolor(3,$000);
      select_color(1);
      select_background(3);
    end;
  init;
  menu;
  repeat
    if getcommando then
      if c.unit='@' then
        case c.command of
          'P',
          'W':printline;
          'S':sendprintstat;
        otherwise:
          begin
            NAK;
            Error;
          end
        end
      else
        case c.command of
          'R':Sende_sector(lw[c.nr]);
          'P',
          'W':Empfange_sector(lw[c.nr]);
          'S':Sende_disk_status(lw[c.nr]);
          '!':Format_Disk(lw[c.nr]);
          ' ':Auto_Format_Disk(lw[c.nr]);
          '"':MD_Format_Disk(lw[c.nr]);
          '?':Sende_SIO_Baut_Rate;
          'N':Sende_Config(lw[c.nr]);
          'O':Empfange_Config(lw[c.nr]);
          'Q':Schreib_Buffer(lw[c.nr]);
          'D',
          'K':Ignoriere_Befehl;
        otherwise:
          begin
            NAK;
            Error;
          end
        end
    else
      case ch of
        'A':aktiviere;
        'D':desaktiviere;
        'P':printer;
        'S':schreibschutz;
     end;
  until ch='E';
  if screen_res<2 then
    begin
      setscreen_rez(-1,-1,screen_res);
      void:=setcolor(0,c0);
      void:=setcolor(1,c1);
      void:=setcolor(2,c2);
      void:=setcolor(3,c3);
      select_color(0);
      select_background(1);
    end;
end.

