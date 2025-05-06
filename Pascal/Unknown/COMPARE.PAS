(* a quick hack to check for equality of files *)

PROGRAM Compare( File1, File2 );

  CONST
    LineFeed = 10;

  VAR
    Name: STRING;
    File1, File2: FILE OF INTEGER;
    Location, Line: INTEGER;
    Stop, Error: BOOLEAN;
    Ch: CHAR;

  BEGIN
    WRITE( CHR( 27 ), 'E' );
    WRITE( 'Enter name of file #1 --> ' );
    READLN( Name );
    RESET( File1, Name );
    WRITE( 'Enter name of file #2 --> ' );
    READLN( Name );
    RESET( File2, Name );
    Location := 0;
    Line := 0;
    Stop := FALSE;
    Error := FALSE;
    WHILE NOT Stop DO
      BEGIN
        IF EOF( File1 ) OR EOF( File2 ) THEN Stop := TRUE;
        IF (EOF( File1 ) AND NOT EOF( File2 )) OR
           (EOF( File2 ) AND NOT EOF( File1 )) THEN Error := TRUE;
        IF NOT Stop THEN
          BEGIN
            IF File1^ = File2^ THEN
                BEGIN
                  GET( File1 );
                  GET( File2 );
                  Location := Location + 2;
                  IF (File1^ DIV 256 = LineFeed) OR
                     (File1^ MOD 256 = LineFeed) THEN Line := Line + 1;
                END
              ELSE
                BEGIN
                  Stop := TRUE;
                  Error := TRUE;
                END;
          END;
      END;
    WRITELN;
    IF Error THEN
        IF EOF( File1 ) THEN
            WRITELN( 'File #2 is longer than File #1.' )
          ELSE IF EOF( File2 ) THEN
            WRITELN( 'File #1 is longer than File #2.' )
          ELSE
            BEGIN
              WRITE( 'The two files differ at location ', Location );
              WRITELN( ' (line ', Line, ').' );
            END
     ELSE
        BEGIN
          WRITE( 'The two identical files each have ', Line );
          WRITELN( ' lines and ', Location, ' bytes.' );
        END;
    WRITELN;
    WRITELN( '---press any key to continue---' );
    READ( Ch );
  END.
