{S16}
{ terminal - A Personal Pascal terminal program. }

Program Ftu_Term;
{$I D:\Pascal\Per_Pasc\AuxSubs.Pas}

  Const
    version = 'version 1.00  27 June, 1986';

    rs232 = 1;
    keyboard = 2;

    carriage_return = 13;
    line_feed = 10;

    max_path = 128;
    max_buf = 1024;

  Type
    path_name = String[ max_path ];
    GemDos_buffer = Packed Array[ 1..max_buf ] Of Char;

  Var
    half_duplex: Boolean;
    baud: ( b300, b1200, b2400, b9600 );
    xon_xOff: Boolean;
    auTo_lf: Boolean;

    capturing,
    uploading: Boolean;
    capture_name,
    upload_name: path_name;
    capture_file,
    upload_file: text;

    printing: Boolean;
    finished: Boolean;

    sTop_time: Long_Integer;

	Function Proc_addr( Procedure P ) : Long_Integer;
      External;

  Function key_waiting( device: Integer ): Boolean;
    Bios( 1 );

  Function get_Char( device: Integer ): Long_Integer;
    Bios( 2 );

  Procedure put_Char( device, Char: Integer );
    Bios( 3 );

  Procedure rs232_control( baud, ctrl, ucr, rsr, tsr, scr: Integer );
    XBios( 15 );

	Procedure MFPint( Num: Integer; Vect: Long_Integer );
		XBios( 13 );  { Initialize Interrupt on MFP - Reg 0-15 }

	Procedure Jdisint( Num: Integer );
		XBios( 26 );  { Disable Interrupt on MFP - Reg 0-15 }

	Procedure Jenabint( Num: Integer );
		XBios( 27 );  { Enable Interrupt on MFP - Reg 0-15 }

	Function hz200: Long_Integer;
	Type Long_ptr = ^Long_Integer;
	Var
		ssp: Long_Integer;
		r: Record
	Case Boolean Of
		True:  ( l: Long_Integer; );
		False: ( p: Long_ptr );
	End;

	Function super(ssp: Long_Integer): Long_Integer;
		GemDos( $20 );
	Begin
		ssp := super(0);
		{$P-}
		r.l := $4ba;
		hz200 := r.p^;
		{$P=}
		ssp := super(ssp);
	End;

  Procedure Start_Timer( time: Integer );
    Begin
      sTop_time := hz200 + time*200;
    End;

  Function Timer_Expired: Boolean;
    Begin
      Timer_Expired := (hz200 >= sTop_time);
    End;

  Procedure Delay( time: Integer );
    Begin
      Start_Timer( time DIV 5 );
      While Not Timer_Expired Do ;
    End;

  Function Wants_To_Abort: Boolean;
    Var c: Integer;
    Begin
      Wants_To_Abort := False;
      If key_waiting( keyboard ) Then
        Begin
          c := int(get_Char( keyboard ));
          If c = 24 Then { ctrl-x }
            Wants_To_Abort := True;
        End;
    End;

  Function Read_Modem( Var c: Char ): Boolean;
    Begin
      If Not key_waiting( rs232 ) Then
        Read_Modem := False
      Else
        Begin
          c := chr( int( get_Char( rs232 ) ) );
          Read_Modem := True;
        End;
    End;

  Function Write_Modem( Var c: Char ): Boolean;
    Begin
      put_Char( rs232, ord(c) );
      Write_Modem := True;
    End;

  Function Create_File( name: path_name; access: Integer ): Integer;
    Type fname = Packed Array[ 1..max_path ] Of Char;
    Var i: Integer; fn: fname;
    Function Fcreate( Var name: fname; attrib: Integer ): Integer;
      GemDos( $3c );
    Begin
      For i := 1 To length(name) Do fn[i] := name[i];
      fn[length(name)+1] := chr(0);
      Create_File := Fcreate( fn, 0 );
    End;

  Function Open_File( name: path_name; access: Integer ): Integer;
    Type fname = Packed Array[ 1..max_path ] Of Char;
    Var i: Integer; fn: fname;
    Function Fopen( Var name: fname; access: Integer ): Integer;
      GemDos( $3d );
    Begin
      For i := 1 To length(name) Do fn[i] := name[i];
      fn[length(name)+1] := chr(0);
      Open_File := Fopen( fn, access );
    End;

  Function Close_File( handle: Integer ): Integer;
    Procedure Fclose( handle: Integer );
      GemDos( $3e );
    Begin
      Fclose( handle );
      Close_File := 0;
    End;

  Function Read_File( handle: Integer; Var buf: GemDos_buffer; size: Integer )
                        : Integer;
    Function Fread( handle: Integer; size: Long_Integer;
                    Var buf: GemDos_buffer ): Long_Integer;
      GemDos( $3f );
    Begin
      Read_File := int( Fread( handle, size, buf ) );
    End;

  Function Write_File( handle: Integer; Var buf: GemDos_buffer; size: Integer )
                        : Integer;
    Function Fwrite( handle: Integer; size: Long_Integer;
                     Var buf: GemDos_buffer ): Long_Integer;
      GemDos( $40 );
    Begin
      Write_File := int( Fwrite( handle, size, buf ) );
    End;

 (* {$I bp.pas} *)

  Procedure banner;

    Begin
      writeln( 'Personal Pascal Terminal Program' );
      writeln( version );
      writeln( 'Written by Mark Rose For Compute!' );
      writeln;
      writeln( '<<Type HELP For a Function key menu>>' );
      writeln
    End;

  Procedure set_rs232;

   Var
     baud_index: Integer;

   Begin
      Case baud Of
         b300: baud_index := 9;
        b1200: baud_index := 7;
        b2400: baud_index := 4;
        b9600: baud_index := 1;
      End;
      rs232_control( baud_index, ord(xon_xOff), -1, -1, -1, -1 );
    End;

  Procedure initialize;

    Begin
      half_duplex := False;
      baud := b9600;
      xon_xOff := True;
      auTo_lf := False;
      uploading := False;
      capturing := False;
      printing := False;
      set_rs232;
    End;

  Procedure capture( c: Integer );

    Begin
      If c = carriage_return Then
        writeln( capture_file )
      Else If c <> line_feed Then
        write( capture_file, chr(c) )
      { otherwise it's a line feed, which we ignore }
    End;

  Procedure Echo_Char( c: Integer );
    Begin
      put_Char( keyboard, c );
      If (c = carriage_return) AND auTo_lf Then
        put_Char( keyboard, line_feed )
    End;

	Procedure Test_Routine;
	Begin
		Echo_Char( 7 );
	End;

	Procedure Install;
	Var
		T : Long_Integer;
	Begin
		T := Proc_addr( Test_Routine );
		MFPint( 1, T );
		Jenabint( 1 );
	End;

  Procedure handle_rs232;
    Var
      c: Integer;
    Begin
      c := int( get_Char( rs232 ) ) & $7F;
      If capturing Then
        capture( c );
      echo_Char( c )
    End;

  Procedure Send_Char( c: Integer );
   Begin
      If half_duplex Then
        Begin
          echo_Char( c );
          If capturing Then
            capture( c )
        End;
      put_Char( rs232, c );
      If (c = carriage_return) AND auTo_lf Then
        put_Char( rs232, line_feed )
    End;

  Procedure handle_upload;

    Var
      ch: Char;

    Begin
      If eOf( upload_file ) Then
        uploading := False
      Else If eoln( upload_file ) Then
        Begin
          readln( upload_file );
          sEnd_Char( carriage_return )
        End
      Else
        Begin
          read( upload_file, ch );
          sEnd_Char( ord(ch) )
        End
    End;

  Procedure show_menu;

    Begin
      writeln;
      writeln( 'F1 - change baud rate      F5 - printer ON/OfF' );
      writeln( 'F2 - Toggle XON/XOfF       F8 - upload a text file' );
      writeln( 'F3 - half/full duplex      F9 - start a capture file' );
      writeln( 'F4 - auTo-lf ON/OfF        F10- capture ON/OfF' );
      writeln( 'F6 - CIS-B transfer' );
      writeln
    End;

  Procedure Toggle_baud;

    Begin
      If baud = b9600 Then
        baud := b300
      Else
        baud := succ( baud );
      set_rs232;
      write( '<<' );
      Case baud Of
         b300: write( 300 );
        b1200: write( 1200 );
        b2400: write( 2400 );
        b9600: write( 9600 )
      End;
      writeln( ' baud>>' )
    End;

  Procedure Toggle_xonOff;

    Begin
      xon_xOff := Not xon_xOff;
      set_rs232;
      write( '<<XON/XOfF ' );
      If xon_xOff Then
        writeln( 'enabled>>' )
      Else
        writeln( 'disabled>>' )
    End;

  Procedure Toggle_capture;

    Begin
      capturing := Not capturing;
      write( '<<capture mode ' );
      If capturing Then
        writeln( 'ON>>' )
      Else
        writeln( 'OfF>>' )
    End;

  Procedure create_capture;

    Begin
      write( 'Name Of new capture file: ' );
      readln( capture_name );
      rewrite( capture_file, capture_name );
      capturing := False;
      uploading := False;
      writeln( '<<use F10 To start capturing>>' )
    End;

  Procedure start_upload;

    Begin
      write( 'Name Of file To upload: ' );
      readln( upload_name );
      reset( upload_file, upload_name );
      uploading := True;
      capturing := False
    End;

  Procedure Do_special( scan_code: Integer );

    Var status: Boolean;

    Begin
      Case scan_code Of
        {HELP} $62: show_menu;
        {UNDo} $61: finished := True;
        {F1}   $3B: Toggle_baud;
        {F2}   $3C: Toggle_xonOff;
        {F3}   $3D: half_duplex := Not half_duplex;
        {F4}   $3E: auTo_lf := Not auTo_lf;
        {F5}   $3F: printing := Not printing;
        {F6}   $40: Begin
                      writeln( 'Beginning CIS-B file transfer...' );
                     (* status := Transfer_File *);
                    End;
        {F8}   $42: start_upload;
        {F9}   $43: create_capture;
        {F10}  $44: Toggle_capture;
        {^2}   $03: sEnd_Char( 0 );
        OTHERWISE:  ; { ignore the Character }
      End
    End;

  Procedure handle_keyboard;

    Var
      c: Long_Integer;

    Begin
      c := get_Char( keyboard );
      If (c & $FF) = 0 Then
        Do_special( int(shr(c,16)) )
      Else
        sEnd_Char( int(c) )
    End;

  Procedure main_loop;

    Begin
      finished := False;
      While Not finished Do
        Begin
          If key_waiting( rs232 ) Then
            handle_rs232;
          If key_waiting( keyboard ) Then
            handle_keyboard;
          If uploading Then
            handle_upload;
        End
    End;

  Begin
		Install;
    initialize;
    banner;
    main_loop;
  End.

