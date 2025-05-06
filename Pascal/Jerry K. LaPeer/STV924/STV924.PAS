(*
 Atari 520 ST TeleVideo 924:

  a televidio 924 terminal emulator (all codes that we use) for the

  atari 520 ST,

  written in Optimized Systems Software, Inc. Personal Pascal,

  by Jerry K. LaPeer of LaPeer Systems inc.

  The Atari 520ST was purchased to replace the TeleVidio series of
    terminals we use on our multi - user TurboDOS z80h systems, with
    the hopes of extending our TurboDOS systems with color graphics
    terminals.  Well to say the least the Atari 520ST has done all
    of that and promises to do even more

  The only exception to configure rs232 from the desk top is setting
    the baud rate to 19.2k baud, see rsconf(0,-1,-1,-1,-1,-1); to
    change this just comment out the statment and use the desk top.

*)
program stv924;

const
  ack =         $06;
  nak =         $15;
  can =         $18;
  eot =         $04;

  esc =         $1b;

  modem =       1;
  console =     2;

  f01_key =     $3b00;
  f02_key =     $3c00;
  f03_key =     $3d00;
  f04_key =     $3e00;
  f05_key =     $3f00;
  f06_key =     $4000;
  f07_key =     $4100;
  f08_key =     $4200;
  f09_key =     $4300;
  f10_key =     $4400;
  f11_key =     $5400;
  f12_key =     $5500;
  f13_key =     $5600;
  f14_key =     $5700;
  f15_key =     $5800;
  f16_key =     $5900;
  f17_key =     $5a00;
  f18_key =     $5b00;
  f19_key =     $5c00;
  f20_key =     $5d00;

  help_key =    $6200;
  undo_key =    $6100;

  clr_key =     $4737;
  home_key =    $4700;

  ua_key =      $4800;
  la_key =      $4b00;
  ra_key =      $4d00;
  da_key =      $5000;

  alt_skey =    $1f00;
  alt_rkey =    $1300;

type
  gdstrdef =    packed array[1..128] of char;
  disk_buff_def = packed array[1..16384] of char;

var
  done:         boolean;
  dtron:        boolean;
  michar:       long_integer;
  cichar:       long_integer;
  backg_color:  integer;
  forg_color:   integer;
  cur_line:     integer;
  cur_col:      integer;
  lretcd:       long_integer;
  retcd:        integer;
  ifhandle:     integer;
  ofhandle:     integer;
  ifname:       gdstrdef;
  ofname:       gdstrdef;
  disk_buff:    disk_buff_def;
  ndisk_buff:   integer;
  reply:        char;

procedure do_send_file; forward;
procedure do_receive_file; forward;
procedure do_mhelp; forward;

function ci_status(device : integer) : integer;    bios(1);
function schar_in(device : integer) : long_integer;bios(2);
function co_status(device : integer) : integer;    bios(8);
procedure char_out(device,dout : integer);         bios(3);

procedure rsconf(baud_rate,flow,ucr,p4,p5,p6 : integer); xbios(15);

procedure offgibit(bitmask : integer); xbios(30);
procedure ongibit(bitmask  : integer); xbios(29);

function create_file(var fname : gdstrdef;
                         fattr : integer) :      long_integer; gemdos($3c);
function delete_file(var fname : gdstrdef) :     long_integer; gemdos($41);
function open_file(var fname : gdstrdef;
                       fattr : integer) :        long_integer; gemdos($3d);
function close_file(fhandle : integer) :         long_integer; gemdos($3e);
function read_file(fhandle : integer;
                   count   : long_integer;
                   var dbuff : disk_buff_def) :  long_integer; gemdos($3f);
function write_file(fhandle : integer;
                    count   : long_integer;
                    var dbuff : disk_buff_def) : long_integer; gemdos($40);

procedure set_dtr(switch : boolean);

const
  dtron_mask=           $ef;
  dtroff_mask=          $10;

begin
(*
  if switch
    then begin
      ongibit(dtron_mask);
      dtron := true;
    end
    else begin
      offgibit(dtroff_mask);
      dtron := false;
    end;
*)
end;

function char_in(device : integer) : long_integer;

begin

  if not dtron
    then begin
      if ci_status(modem) = 0
        then set_dtr(true);
    end;

  char_in := schar_in(device);

end;

procedure clear_screen;

begin

  char_out(console,esc);
  char_out(console,ord('E'));

  cur_line := 1;
  cur_col := 1;

end;

procedure gotoxy(row,col : char);

begin

  char_out(console,esc);
  char_out(console,ord('Y'));
  char_out(console,ord(row));
  char_out(console,ord(col));

  cur_line := ord(row);
  cur_col := ord(col);

end;

procedure do_postion_cursor;

var
  row,col:      char;

begin

  row := chr(int(char_in(modem)));
  col := chr(int(char_in(modem)));

  gotoxy(row,col);

end;

procedure do_char_color;

begin

  char_out(console,esc);
  char_out(console,ord('c'));
  char_out(console,ord(backg_color));

  char_out(console,esc);
  char_out(console,ord('b'));
  char_out(console,ord(forg_color));

end;

procedure do_vidio_attr;

var
  data_char:            char;
  data_char1:           char;

begin

  data_char := chr(int(char_in(modem)));

  case data_char of
    '0'  : do_char_color;
    '1'  : begin
             char_out(console,esc);
             char_out(console,ord('b'));
             char_out(console,backg_color);
           end;
    '2',
    '3'  : begin
           end;
    '4'  : begin
             char_out(console,esc);
             char_out(console,ord('b'));
             char_out(console,forg_color);
             char_out(console,esc);
             char_out(console,ord('c'));
             char_out(console,backg_color);
           end;
    '5'  : begin
             char_out(console,esc);
             char_out(console,ord('b'));
             char_out(console,forg_color);
             char_out(console,esc);
             char_out(console,ord('c'));
             char_out(console,forg_color);
           end;
    '6',
    '7',
    '8',
    '9',
    ':',
    ';',
    '<',
    '=',
    '>',
    '?'  : begin
           end;
    ' '  : begin
             char_out(console,esc);
             char_out(console,ord('b'));
             char_out(console,01);
           end;
    '$'  : begin
             char_out(console,esc);
             char_out(console,ord('b'));
             char_out(console,01);
           end;
  end;

end;

procedure do_cursor_attr;

var
  data_char:            char;

begin

  data_char := chr(int(char_in(modem)));

  case data_char of
    '0'  : begin
             char_out(modem,esc);
             char_out(modem,ord('f'))
           end;
    else : begin
             char_out(modem,esc);
             char_out(modem,ord('e'))
           end;
  end;

end;

procedure do_eol;

begin

  char_out(console,esc);
  char_out(console,ord('K'));

end;

procedure do_eos;

begin

  char_out(console,esc);
  char_out(console,ord('J'));

end;

procedure do_insert;

begin

  char_out(console,esc);
  char_out(console,ord('L'));

end;

procedure do_delete;

begin

  char_out(console,esc);
  char_out(console,ord('M'));

end;

procedure do_light_background;

begin

  forg_color := 0;
  backg_color := 2;

  do_char_color;

end;

procedure do_dark_background;

begin

  forg_color := 2;
  backg_color := 0;

  do_char_color;

end;

procedure do_escape;

var
  data_char:            char;

begin

  data_char := chr(int(char_in(modem)));

  case data_char of
    '='  : do_postion_cursor;
    'G'  : do_vidio_attr;
    '.'  : do_cursor_attr;
    '*'  : begin
             clear_screen;
             michar := char_in(modem);
           end;
    't',
    'T'  : do_eol;
    'y',
    'Y'  : do_eos;
    'E'  : do_insert;
    'R'  : do_delete;
    'b'  : do_light_background;
    'd'  : do_dark_background;
    else : begin
             char_out(console,esc);
             char_out(console,ord(data_char));
           end;
  end;

  if dtron then set_dtr(false);

end;

procedure do_home_cursor;

begin

  char_out(console,esc);
  char_out(console,ord('H'));

  cur_line := 1;
  cur_col := 1;

end;

procedure do_up_cursor;

begin

  char_out(console,esc);
  char_out(console,ord('A'));

end;

procedure do_down_cursor;

begin

  char_out(console,esc);
  char_out(console,ord('B'));

end;

procedure do_left_cursor;

begin

  char_out(console,esc);
  char_out(console,ord('D'));

end;

procedure do_right_cursor;

begin

  char_out(console,esc);
  char_out(console,ord('C'));

end;

procedure do_move_cursor;

begin

  case int(michar) of
    esc  : do_escape;
    $0b  : do_up_cursor;
    $16  : do_down_cursor;
    else : case int(michar) of
      $08  : do_left_cursor;
      $0c  : do_right_cursor;
      $1e  : do_home_cursor;
(*      else : char_out(console,int(michar));  *)
      else : char_out(console,int(michar) & $7f);
    end;
  end;

end;

procedure do_modem_input;

begin

  michar := char_in(modem);

  case int(michar) of
    $0a  : begin
             if dtron then set_dtr(false);
             char_out(console,int(michar));
             cur_line := cur_line + 1;
           end;
    $1a  : clear_screen;
    else : do_move_cursor;
  end;

end;

procedure do_console_input;

var
  data_char:            integer;

  procedure do_arrow_keys;

  begin

    case data_char of
      ua_key : char_out(modem,$0b);
      la_key : char_out(modem,$08);
      ra_key : char_out(modem,$0c);
      else   : case data_char of
        da_key : char_out(modem,$16);
        else   : char_out(modem,int(cichar & $0000007f));
      end
    end;

  end;

  procedure do_pfkeys;

  begin

    if        data_char = f01_key
      then char_out(modem,$01)
      else if data_char = f02_key
             then char_out(modem,$03)
      else if data_char = f03_key
             then char_out(modem,$04)
      else if data_char = f04_key
             then char_out(modem,$05)
      else if data_char = f05_key
             then char_out(modem,$06)
      else if data_char = f06_key
             then char_out(modem,$0b)
      else if data_char = f07_key
             then char_out(modem,$0e)
      else if data_char = f08_key
             then char_out(modem,$0f)
      else if data_char = f09_key
             then char_out(modem,$11)
      else if data_char = f10_key
             then char_out(modem,$14)
      else if data_char = f11_key
             then char_out(modem,$16)
      else if data_char = f12_key
             then char_out(modem,$17)
      else do_arrow_keys;

  end;

begin

  cichar := char_in(console);

  data_char := int((shr(cichar,8) & $ff00) | (cichar & $00ff));

  case data_char of
    undo_key : begin
                 done := true;
               end;
    help_key : begin
                 do_mhelp;
               end;
    else : case data_char of
      clr_key  : begin
                   char_out(modem,$1a);
                 end;
      home_key : begin
                   char_out(modem,$1e);
                 end;
      else     : begin
                   if data_char = alt_skey
                     then do_send_file
                     else if data_char = alt_rkey
                            then do_receive_file
                            else do_pfkeys;
                 end;
    end;
  end;

end;

procedure do_send_file;

var
  data_char:            integer;
  i:                    integer;
  sn:                   integer;
  kn:                   integer;
  bs:                   integer;
  fname:                string[128];

begin

  writeln;
  write('enter the send file name ');
  readln(fname);

  if length(fname) > 0
    then begin

      for i := 1 to length(fname) do
        ifname[i] := fname[i];

      ifname[length(fname)+1] := chr($00);

      ifhandle := int(open_file(ifname,$02));

      if ifhandle < 0
        then begin
          writeln('couldn''t open that file! hit return');
          readln(reply);
          char_out(modem,can);
        end
        else begin

          bs := int(read_file(ifhandle,16384,disk_buff));

          if (bs mod 128) <> 0
            then bs := ((bs div 128) + 1) * 128;

          ndisk_buff := 1;

          sn := 0;
          kn := 0;

          if not dtron then set_dtr(true);

          write('sending block         ');

          char_out(modem,ack);

          while bs > ndisk_buff do begin

            for i := 1 to 128 do begin
              char_out(modem,ord(disk_buff[ndisk_buff]));
              ndisk_buff := ndisk_buff + 1;
            end;

            if ndisk_buff > bs
              then begin
                bs := int(read_file(ifhandle,16384,disk_buff));
                if (bs mod 128) <> 0
                  then bs := ((bs div 128) + 1) * 128;
                ndisk_buff := 1;
              end;

            sn := sn + 1;

            if (sn mod 8) = 0
              then begin
                kn := kn + 1;
                write(chr(8),chr(8),chr(8),chr(8),chr(8),chr(8),chr(8),chr(8),
                      kn:8);
              end;

            data_char := int(char_in(modem));

            if data_char <> ack
              then bs := -1
              else if bs > 0
                     then char_out(modem,ack)
                     else char_out(modem,eot);

          end;

          lretcd := close_file(ofhandle);

          if lretcd <> 0
            then begin
              writeln(';couldn''t close received file! hit return');
              readln(reply);
            end
            else begin
              writeln;
            end;

        end;

    end
    else char_out(modem,can);

end;

procedure do_receive_file;

var
  data_char:            integer;
  i:                    integer;
  sn:                   integer;
  kn:                   integer;
  fname:                string[128];

begin

  writeln;
  write('enter the receive file name ');
  readln(fname);

  if length(fname) > 0
    then begin
      for i := 1 to length(fname) do
        ofname[i] := fname[i];
      ofname[length(fname)+1] := chr($00);
      lretcd := delete_file(ofname);
      ofhandle := int(create_file(ofname,$00));
      if ofhandle < 0
        then begin
          writeln('couldn''t create that file! hit return');
          readln(reply);
          char_out(modem,can);
        end
        else begin
          ndisk_buff := 1;
          sn := 0;
          kn := 0;
          if not dtron then set_dtr(true);
          write('received block         ');
          char_out(modem,ack);
          repeat
            for i := 1 to 128 do begin
              disk_buff[ndisk_buff] := chr(int(char_in(modem)));
              ndisk_buff := ndisk_buff + 1;
            end;
            if ndisk_buff > 16384
              then begin
                lretcd := write_file(ofhandle,16384,disk_buff);
                ndisk_buff := 1;
              end;
            sn := sn + 1;
            if (sn mod 8) = 0
              then begin
                kn := kn + 1;
                write(chr(8),chr(8),chr(8),chr(8),chr(8),chr(8),chr(8),chr(8),
                      kn:8);
              end;
            char_out(modem,ack);
            data_char := int(char_in(modem));
          until data_char = eot;
          if ndisk_buff > 1
            then lretcd := write_file(ofhandle,ndisk_buff,disk_buff);
          lretcd := close_file(ofhandle);
          if lretcd <> 0
            then begin
              writeln(';couldn''t close received file! hit return');
              readln(reply);
            end
            else begin
              writeln;
            end;
        end;
    end
    else char_out(modem,can);

end;

procedure do_mhelp;

begin

  clear_screen;

  writeln('undo key    exit program.');
  writeln('help key    this screen.');
  writeln;
  writeln('alt s key   send a file.');
  writeln('alt r key   receive a file.');
  writeln;
  writeln('alt c key   configure rs232.');
  writeln('alt d key   set defaults.');
  writeln;
  writeln('alt p key   phone / modem stuff');

  writeln;
  write('strike any key to return');

  while ci_status(console) = 0 do;

  lretcd := char_in(console);

end;

begin

  done := false;

  rsconf(7,-1,-1,-1,-1,-1);  (* configured for 1200 baud *)

  set_dtr(true);

  backg_color := 0;
  forg_color := 3;

  do_char_color;

  clear_screen;

  cur_line := 1;
  cur_col  := 1;

  while not done do begin
    if ci_status(modem) <> 0
      then do_modem_input
      else if not dtron then set_dtr(true);

    if ci_status(console) <> 0
      then do_console_input;

  end;

  halt;

end.
