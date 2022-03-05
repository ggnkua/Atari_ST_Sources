
{-------------------------------}
{ build a Ymodem block 0 header }
{-------------------------------}
PROCEDURE MakeHeader( VAR filename: STRING );
VAR
	i,j,k,l : INTEGER;
	size : LONG_INTEGER;
	temp : STRING;
	tempfile : text;
	

		
BEGIN
	{ get the size of the file }
	reset( tempfile, filename );
	size := lseek( 0, handle(tempfile), 2 );
	chsent := chsent + size;
	close( tempfile );
	
	{ zero out the block }
	FOR i := 1 TO 130 DO
		sector_data[i] := 0;
		
	{ trim the filename }
	trim( filename, temp );
	
	{ insert the filename }
	l := length( temp );
	FOR i := 1 TO l DO
		sector_data[i] := ORD( LowerCase(temp[i]) );
	
	{ insert the file size }	
	writev( temp, size );
	i := l + 2;
	FOR k := 1 TO length( temp ) DO BEGIN
		sector_data[i] := ORD( temp[k] );
		i := i + 1;
	END;
	
	{ add file date and time -> optional so I won't do it }
END{ MakeHeader};

    
PROCEDURE CheckKeyboard;
VAR
	ch : char;
BEGIN
	IF InReady( CONSOLE ) THEN
		ch := Bconin( CONSOLE );
	{ check for ctrl-x }
	IF Ord(ch)=24 THEN  
		stop_send := true;
END;

		
PROCEDURE WaitCh( seconds:integer; VAR ch:integer );
VAR
	max : long_integer;
BEGIN
	max := timer + (seconds * 200);
	ch := -1 ;
	REPEAT
		CheckKeyboard;
		if InReady( MODEM ) then
			ch := ORD( Bconin( MODEM ) );
	UNTIL ( ch > -1 ) OR ( timer > max ) or (not carrier) or (stop_send);	
END;
	



{---------------------------------------}
{ send a null name to stop the transfer }
{---------------------------------------}
PROCEDURE SendNullName;
VAR
	i : integer;
	ch : integer;

	PROCEDURE Bconout( device, ch: integer );	
		Bios(3);
		
BEGIN
		REPEAT
			WaitCh( 1, ch );
		UNTIL ( ch = TIMEOUT );
	
		Bconout( MODEM, SOH );
		Bconout( MODEM, 0   );
		Bconout( MODEM, 255 );
	
		FOR i := 1 TO 130 DO
			Bconout( MODEM, 0 );
		
		WaitCh( 10, ch );
		IF( ch = ACK ) THEN
			writeln( 'End of batch mode acknowledged' )
		ELSE
			writeln( 'End of batch transfer not acknowledged' );	
END;


{---------------------------------------------}
PROCEDURE SendFile( filename: string; VAR result:boolean );
	
VAR
	filecount     : INTEGER;
	hour          : INTEGER;   { hours      for                         }
	minute        : INTEGER;   { minutes      time                      }
	second        : INTEGER;   { seconds        display                 }
	tries         : INTEGER;   { number of tries sending current sector }
	checksum      : INTEGER;   { sector checksum                        }
	crc           : INTEGER;   { CRC checksum                           }
	ch            : INTEGER;   { character received from serial port    }
	send_errors   : INTEGER;   { count send errors                      }
	sector_count  : INTEGER;   { sector count- no wrap at 255           }
	sector_number : BYTE;      {                                        }
	sector_size   : INTEGER;   {                                        }
	transfer_time : INTEGER;   { transfer time in seconds               }
	effective_rate: REAL;      { effective transmission rate            }
	EOF_Xfile     : BOOLEAN;   { EOF encountered on file to send        }
	use_crc       : BOOLEAN;   {                                        }
	max_tries     : INTEGER;   { maximum number of retries              }
	header_ch     : INTEGER;   { block header character                 }
	new_header_ch : INTEGER;   {                                        }
	bad_sectors   : INTEGER;   { bad sector count                       }
	good_sectors  : INTEGER;   { good sector count                      }
	xfile_size    : LONG_INTEGER; { size of the transfer file           }
	junk          : LONG_INTEGER;
	xfile         : FILE OF BYTE; { the file to be sent                 }
	nread         : LONG_INTEGER; { number of bytes read from the file  }
	n             : INTEGER;      { all purpose counter                 }
	

		
	FUNCTION Bconin( device: integer ): integer;
	Bios(2);
	
	
	FUNCTION Fread( handle:integer; count:long_integer;
	                VAR buf:secbuf_type):long_integer;
	Gemdos($3f);

	FUNCTION UpdateCrc( ch:BYTE; oldcrc:INTEGER ):INTEGER;
	C;

	PROCEDURE InitDisplay;
	BEGIN
	END;
	
	PROCEDURE UpdateDisplay;
	BEGIN
		;
	END;


	PROCEDURE DisplayError( message:STRING; ShowBlock:BOOLEAN );
	BEGIN
		writeln( message );
	END;



	{----------------------------------}
	{ Do the initial C/G/NAK handshake }
	{----------------------------------}
	PROCEDURE InitHandshake;
	BEGIN
		REPEAT
			WaitCh( 10, ch );  { wait for initial character - max 10 seconds }
			IF ch = CAN THEN
				WaitCh( 10, ch );  { if it was a CAN then insist upon another }
			tries := tries + 1;
			stop_send := stop_send OR ( NOT Carrier );
		UNTIL ( tries > 10    ) OR
		      ( ch = NAK      ) OR
			  ( ch = ORD('C') ) OR
			  ( ch = CAN      ) OR
			  stop_send;
			  
	    IF  ( ch = TIMEOUT ) OR
		    ( tries > 10   ) OR
		    ( ch = CAN     ) THEN
		    BEGIN
				mygotoxy( 5, 24 );
				write( 'Receiver timed out.  Did not initiate transfer.' );
			END
		ELSE IF ( ch = NAK ) THEN
			use_crc := FALSE
		ELSE IF ( ch = ORD('C') ) THEN
			use_crc := TRUE;
	END;


	PROCEDURE Bconout( device:integer; ch:byte );
	Bios(3);
	
	{------------------}
	{ send a character }
	{------------------}
	PROCEDURE SendCh( c:BYTE );
	BEGIN
		Bconout( MODEM, c );
	END;



	{----------------------------}
	{ Handle ACK/NAK for sectors }
	{----------------------------}
	PROCEDURE HandleAckNak;
	BEGIN
		ch := ACK;        { assume an ACK by default }
		WaitCh( 5, ch );
		
		IF ( ch = CAN ) THEN BEGIN
			WaitCh( 5, ch );
		END;
		
		IF ( ch <> ACK ) THEN BEGIN
			DisplayError( 'No ACK received.', true );
			send_errors := send_errors + 1;
		END;
	END;



	{----------------}
	{ send one block }
	{----------------}
	PROCEDURE SendBlock;
	VAR
		i : INTEGER;
		HiCrc,LoCrc: INTEGER;
		
	BEGIN
		tries := 0;
		
		REPEAT
			Bconout( MODEM, header_ch );
			Bconout( MODEM, sector_number );
			Bconout( MODEM, 255 - sector_number );
			
			{--------------------------------------------------}
			{ Bconout( MODEM, ORD(CHR(255 - sector_number)) ); }
			{--------------------------------------------------}
			
			Bconout( CONSOLE, 27 );
			Bconout( CONSOLE, ORD('l') );
			Write( 'Sending block ', sector_count );
			
			IF use_crc THEN
				BEGIN
					crc := 0;
					sector_data[ sector_size + 1 ] := 0;
					sector_data[ sector_size + 2 ] := 0;
					FOR i := 1 TO sector_size DO 
						BEGIN
							Bconout( MODEM, sector_data[i] );
							crc := UpdateCrc( sector_data[i], crc );
						END;
					crc := UpdateCRC( sector_data[ sector_size + 1], crc );
					crc := UpdateCRC( sector_data[ sector_size + 2], crc );
					LoCrc := (crc & $FF);
					HiCrc := (crc & $FF00);
					HiCrc := Shr( HiCrc, 8 );
					Bconout( MODEM, HiCrc );
					Bconout( MODEM, LoCrc );
				END
			ELSE
				BEGIN
					checksum := 0;
					FOR i := 1 TO sector_size DO BEGIN
						Bconout( MODEM, sector_data[i] );
						checksum := (checksum + sector_data[i]) & $FF;
					END;
					Bconout( MODEM, checksum );
				END;
			
			FlushInput;    { flush the input buffer }
			tries := tries + 1;
			HandleAckNak;
			UpdateDisplay;
		
		UNTIL ( ch = ACK     ) OR
		      ( ch = CAN     ) OR
			  ( tries > 10   ) OR
			  ( stop_send    ) OR
			  ( NOT carrier  );
			  
		if not carrier then stop_send := true;	  
	END;



	{---------------------------------}
	{ send special block 0 for Ymodem }
	{---------------------------------}
	PROCEDURE SendYmodemHeader;
	VAR
		save_size : INTEGER;
		save_header : INTEGER;
		
	BEGIN
		save_size := sector_size;
		save_header := header_ch;
		sector_size := 128;
		header_ch := SOH;
		SendBlock;
		
		sector_size := save_size;
		header_ch := save_header;
	END;


BEGIN{SendYmodem}
	result := true;
	MakeHeader( filename );
	RESET( xfile, filename );
	xfile_size := lseek( 0, handle(xfile), 2 );	
	junk := lseek( 0, handle(xfile), 0 );
	curs_off;  { turn off the cursor }
	header_ch := STX;
  new_header_ch := header_ch;
	sector_size := 1024;
	sector_number := 0;
	sector_count := 0;
 	send_errors := 0;
	stop_send := FALSE;
 	EOF_xfile := FALSE;
	tries := 0;
  use_crc := true;
	max_tries := 10;
	FlushInput;
	InitHandshake;
	IF ( NOT stop_send ) and (carrier) THEN BEGIN
		SendYmodemHeader;
		InitHandshake;
	END;
	{ begin the loop over blocks in the file }
	CheckKeyboard;
	if (not carrier) then stop_send := true;

	REPEAT
		CheckKeyboard;	
		IF NOT stop_send THEN BEGIN { send the next sector }
			{ first fill with ctrl-z }
			for n := 1 to sector_size do
				sector_data[n] := 26;
			header_ch := new_header_ch;
			nread := Fread( HANDLE(xfile), sector_size, sector_data );		
			IF (nread <= 0 ) THEN
				EOF_xfile := TRUE
			ELSE BEGIN
				IF ( nread < sector_size ) THEN 
					BEGIN
						;
					END;
				sector_count := sector_count + 1;
				sector_number := ((sector_number + 1) & $FF);
				SendBlock;
				IF ( ch = ACK ) THEN
					good_sectors := good_sectors + 1
				ELSE BEGIN 
					bad_sectors := bad_sectors + 1;
					{ back up in the file }
					junk := lseek( nread, handle(xfile), 1 );
					xfile_size := xfile_size + nread;
				END;
				
				xfile_size := xfile_size - nread;
			
				IF( xfile_size < 1024 ) THEN BEGIN
					new_header_ch := SOH;
					sector_size := 128;
				END;
			END;
		END;
	UNTIL( EOF_xfile         ) OR 
    	 ( tries > max_tries ) OR
	 	 ( ch = CAN          ) OR
	 	 ( stop_send         );
	
	IF stop_send THEN
		BEGIN
			writeln;
			writeln( 'Transfer aborted by sysop' );
			result := false;
		END
	ELSE IF NOT carrier THEN
		BEGIN
			writeln;
			writeln( 'User dropped carrier.' );
			stop_send := TRUE;
			result := false;
		END  
	ELSE IF ( tries > max_tries ) THEN
		BEGIN
			writeln;
			DisplayError( 'No ack ever received', false );
			result := false;
		END
	ELSE IF ( ch = CAN ) THEN
		BEGIN
			stop_send := true;
			writeln;
			DisplayError( 'Receiver cancelled transmission.', false );
			result := false;
		END
	ELSE IF ( NOT stop_send ) THEN 
		BEGIN
			tries := 0;
			REPEAT
				SendCh( EOT );
				tries := tries + 1;
				WaitCh( 3, ch );
				CheckKeyboard;
			UNTIL ( ch   = ACK        ) OR
		          ( tries > max_tries ) OR
			      ( ch = CAN          ) OR
			      stop_send;
			  			
			IF ( tries > max_tries ) THEN
				BEGIN
					writeln;
					DisplayError( 'No ACK on EOT.', false );
					result := FALSE;
				END
			ELSE IF ( ch = CAN ) THEN
				BEGIN
					writeln;
					DisplayError( 'Receiver cancelled transmission.', false );
					result := FALSE;
				END
			ELSE IF ( stop_send ) THEN
				BEGIN
					writeln;
					DisplayError( 'Sender aborted transfer.', false );
					result := FALSE;
				END
			ELSE
				BEGIN
					writeln;
					writeln( 'EOT acknowledged, send complete.' );
					result := TRUE;
				END;
		END;
	
	if (not carrier) then result := false;
			
	close( xfile );
	curs_on;
END{ SendYmodem };






{------------------------------------------}
{ send a ton of files in Ymodem batch mode }
{------------------------------------------}
PROCEDURE PerformTransfer;
VAR
	i, count, cps : integer;
	result : boolean;
	line : string;
	start, finish, total : long_integer;
	logfile : text;

	
	FUNCTION fwrite( h:integer; c:long_integer; a:long_integer):long_integer;
	Gemdos($40);
	
	FUNCTION addr( VAR what: String ): long_integer;
	External;
		
BEGIN
	i := 0;
	chsent := 0;
	start := timer;
	count := sendcount;
	lineout( 'Start the download NOW.' );
	while (i < count) and (carrier=true) do begin
		i := i + 1;
		trim( sendlist[i].name, line );
		writeln( 'Sending ', line, '  ', sendlist[i].size, ' bytes' );
		SendFile( sendlist[i].name, result );
		if (result = true) then
			begin
				;
			end
		else
			begin
				i := count + 2;
			end
	end;	
	
	if (result=true) and (carrier=true) then
		SendNullName;
		
	if (result=true) and (carrier=true) then
		begin
			finish := Timer;
			total := finish - start;
			total := total DIV 200;
			cps := chsent DIV total;
			writev( line, 'Effective transfer rate: ', cps, ' CPS.' );
			lineout( line );
			FlushInput;
			
			{ write to the log file }
			writeln( 'Writing to YBATCH.LOG file...' );
			if exists( 'YBATCH.LOG' ) then
				begin
					reset( logfile, 'YBATCH.LOG' );
					finish := lseek( 0, handle(logfile), 2 );
					line := '';
					line := concat( name, CHR($0D), CHR($0A) );
					finish := fwrite(handle(logfile),length(line),ADDR(line)+1);
					writeln( 'Wrote ', finish, ' bytes to ybatch.log' );
					finish := lseek( 0, handle(logfile) , 2 );
					line := '';
					writev( line, count );
					line := concat( line, CHR($0D), CHR($0A) );
					finish := fwrite(handle(logfile),length(line),ADDR(line)+1);
					writeln( 'Wrote ', finish, ' bytes to ybatch.log' );
					close( logfile );			
				end
			else
				begin
					rewrite( logfile, 'YBATCH.LOG' );
					writeln( logfile, name );
					writeln( logfile, count );
					close( logfile );
				end;
							
			StringOut( 'Press ENTER to continue:' );
			linein( line );
		end;			
END;



