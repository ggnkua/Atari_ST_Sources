

    IMPLEMENTATION MODULE dmanager;

      FROM realio IMPORT
        (* proc *) writereal;

      FROM util IMPORT
        (* type *) cursortype,
        (* proc *) setcursor;

      FROM termio IMPORT
        (* cnst *) cr, ra, la, ua, da, F1, F2, F5, F9, F10,
        (* type *) modetype,
        (* proc *) read, clrscreen, gotoxy, writestring, setmode, clrtoeol,
                   centermessage, spacebar, write, writeln, readstring,
                   keypressed;

      FROM SYSTEM IMPORT
        (* cont *) CX, ES, DI, AX, BX,
        (* type *) ADDRESS,
        (* proc *) DOSCALL, ADR, SIZE, SETREG, CODE, GETREG;

      FROM Strings IMPORT
        (* proc *) Concat, Length;

      FROM Mouse IMPORT
        (* type *) Button, ButtonSet,
        (* proc *) GetPosBut, ReadMotionCounters, FlagReset;


      CONST
            hmickey    = 20;  (* Constant that determines how far mouse
                                 must move horizontally to move cursor. *)
            vmickey    = 20;  (* Constant that determines how far mouse
                                 must move vertically to move cursor. *)
            buffersize = 5000;
            maxfiles   = 100;


      TYPE
           handle     = CARDINAL;

           dtarec     = RECORD
                          dos  : ARRAY[ 0 .. 29 ] OF CHAR;
                          file : filenametype;
                        END;

           butntype   = ( lfbutton, rtbutton, nobutton );

           nametype   = ARRAY[ 0 .. 24 ] OF CHAR;


      VAR
          names        : ARRAY[ 1 .. maxfiles ] OF filenametype;
          oldrow,
          oldcol       : CARDINAL;
          newrow,
          newcol       : CARDINAL;
          number       : CARDINAL;
          maxrow,
          maxcol       : CARDINAL;
          namespercol  : CARDINAL;
          selectarray  : ARRAY[ 1 .. maxfiles ] OF BOOLEAN;
          name         : nametype;
          readhandle,
          writehandle  : handle;
          dta          : dtarec;
          mousestatus  : INTEGER;
          numofbuttons : CARDINAL;
          error        : CARDINAL;


      PROCEDURE fillchar
                (     dest   : ADDRESS   (* in *);
                      length : CARDINAL  (* in *);
                      ch     : CHAR      (* in *) );
      (* Fills 'length' bytes of memory with the character 'ch' starting at
         the destination address. *)

      VAR
          destSeg,
          destOffset : CARDINAL;

      BEGIN
        IF ( length = 0 )
        THEN
          RETURN;
        END (* if then *);
        destSeg := dest.SEGMENT;
        destOffset := dest.OFFSET;
        SETREG( CX, length );
        SETREG( ES, destSeg );
        SETREG( DI, destOffset );
        SETREG( AX, ch );
        CODE( 0FCH );
        CODE( 0F2H );
        CODE( 0AAH );
      END fillchar;


      PROCEDURE drawbox
                (     c,
                      r,
                      l,
                      w : CARDINAL );
      (* draw box starting at coordinates (c, r) with l = length, w = width
      *)

      VAR
          i : CARDINAL;

      BEGIN (* drawbox *)
        gotoxy( c, r );
        writestring( 'É' );
        FOR i := 1 TO w DO
          writestring( 'Í' )
        END;   (* for *)
        writestring( '»' );
        FOR i := ( r + 1 ) TO ( r + l + 1 ) DO
          gotoxy( ( c + w + 1 ), i );
          writestring( 'º' );
          gotoxy( c, i );
          writestring( 'º' )
        END;   (* for *)
        gotoxy( c, ( r + l + 1 ) );
        writestring( 'È' );
        FOR i := 1 TO w DO
          writestring( 'Í' )
        END;   (* for *)
        writestring( '¼' )
      END drawbox;


      PROCEDURE sort
                (     end : CARDINAL );


        PROCEDURE greater() : BOOLEAN;

        VAR
            i,
            j : CARDINAL;

        BEGIN
          j := end - 1;
          i := 0;
          WHILE names[ j, i ] = dta.file[ i ] DO
            INC( i )
          END;   (* while *)
          RETURN ( names[ j, i ] > dta.file[ i ] )
        END greater;

      BEGIN (* sort *)
        LOOP
          IF end = 1
          THEN
            names[ end ] := dta.file;
            RETURN
          END;   (* if *)
          IF greater( )
          THEN
            names[ end ] := names[ end - 1 ];
            DEC( end )
          ELSE
            names[ end ] := dta.file;
            RETURN
          END (* if else *)
        END (* loop *)
      END sort;


      PROCEDURE rev;

      VAR
          row,
          col   : CARDINAL;
          index : CARDINAL;

      BEGIN
        index := ( oldcol - 1 ) * namespercol + oldrow;
        gotoxy( ( oldcol - 1 ) * 15 + 4, oldrow );
        IF NOT selectarray[ index ]
        THEN
          setmode( normal );
        ELSE
          setmode( highlight );
        END (* if then *);
        IF index <= number
        THEN
          writestring( names[ index ] );
          write( ' ' );
        END (* if then *);
        gotoxy( ( newcol - 1 ) * 15 + 4, newrow );
        index := ( newcol - 1 ) * namespercol + newrow;
        IF selectarray[ index ]
        THEN
          setmode( highlight );
        ELSE
          setmode( reverse );
        END (* if then *);
        IF index <= number
        THEN
          writestring( names[ index ] );
          IF selectarray[ index ]
          THEN
            write( '*' );
          END (* if then *);
        END (* if then *);
        oldrow := newrow;
        oldcol := newcol;
      END rev;


      PROCEDURE putmsg
                (     ln  : CARDINAL;
                      msg : ARRAY OF CHAR );

      BEGIN
        setmode( normal );
        gotoxy( 0, ln );
        clrtoeol;
        setmode( reverse );
        centermessage( msg );
        setmode( normal )
      END putmsg;


      PROCEDURE getpointer
                (     filehandle : handle    (* in *);
                  VAR high       : CARDINAL  (* out *);
                  VAR low        : CARDINAL  (* out *) );

      BEGIN (* getpointer *)
        SETREG( BX, filehandle );
        DOSCALL( 42H, filehandle, 1, 0, 0, high, low, error );
        IF ( high > 0 ) AND ( low > 0 )
        THEN
          low := low + 1;
        END (* if then *)
      END getpointer;


      PROCEDURE setpointer
                (     filehandle : handle    (* in *);
                      high       : CARDINAL  (* in *);
                      low        : CARDINAL  (* in *) );

      VAR
          outh,
          outl : CARDINAL;

      BEGIN (* setpointer *)
        SETREG( BX, filehandle );
        DOSCALL( 42H, filehandle, 2, 0, 0, outh, outl, error );
        IF result <> 0
        THEN
          RETURN;
        ELSE
          IF ( high < outh ) OR ( ( high = outh ) AND ( low <= outl ) )
          THEN
            IF high > 0
            THEN
              IF low <> 0
              THEN
                low := low - 1;
              ELSE
                low := 65535;
                high := high - 1;
              END (* if then *);
            END (* if then *);
            SETREG( BX, filehandle );
            DOSCALL( 42H, filehandle, 0, high, low, outh, outl, error );
          END (* if then *);
        END (* if then *);
      END setpointer;


      PROCEDURE openfile
                (     filename   : ARRAY OF CHAR;
                      att        : CARDINAL;
                  VAR filehandle : handle        );
      (* att : 0 = read, 1 = write, 2 = read and write *)

      BEGIN (* openfile *)
        DOSCALL( 3DH, ADR( filename ), att, filehandle, error );
        CODE( 9CH );
        CODE( 59H );
        GETREG( CX, error );
        IF ODD( error )
        THEN
          result := filehandle
        ELSE
          result := 0
        END (* if else *)
      END openfile;


      PROCEDURE getfilesize
                (     filehandle : handle    (* in *);
                  VAR high       : CARDINAL  (* out *);
                  VAR low        : CARDINAL  (* out *) );

      VAR
          outh,
          outl : CARDINAL;

      BEGIN
        getpointer( filehandle, outh, outl );
        DOSCALL( 42H, filehandle, 2, 0, 0, high, low, error );
        IF ( high > 0 ) AND ( low < 65535 )
        THEN
          low := low + 1;
        END (* if then *);
        setpointer( filehandle, outh, outl );
      END getfilesize;


      PROCEDURE closefile
                (     filehandle : handle );

      BEGIN (* closefile *)
        IF filehandle > 3
        THEN
          DOSCALL( 3EH, filehandle, result )
        ELSE
          result := 99
        END (* if else *)
      END closefile;


      PROCEDURE createfile
                (     filename   : ARRAY OF CHAR;
                  VAR filehandle : handle        );

      BEGIN (* createfile *)
        DOSCALL( 3CH, ADR( filename ), 0, filehandle, error );
        CODE( 9CH );
        CODE( 59H );
        GETREG( CX, error );
        IF ODD( error )
        THEN
          result := filehandle
        ELSE
          result := 0
        END (* if else *)
      END createfile;


      PROCEDURE writefile
                (     filehandle   : handle;
                      bytestowrite : CARDINAL;
                      fromlocation : ADDRESS;
                  VAR byteswritten : CARDINAL );

      BEGIN (* writefile *)
        DOSCALL( 40H, filehandle, bytestowrite, fromlocation, byteswritten,
                 error );
        CODE( 9CH );
        CODE( 59H );
        GETREG( CX, error );
        IF ODD( error )
        THEN
          result := filehandle
        ELSE
          IF bytestowrite <> byteswritten
          THEN
            result := 99
          ELSE
            result := 0
          END (* if else *)
        END (* if else *)
      END writefile;


      PROCEDURE reaäfile
                (     filehandle  : xandle;
                      bytestoread : CARDINAL?
                      tolocatio~  : ADDRESS;
                  VAR bytesread   : CARDINAL );

      BEGIN (* readfile *)
        DOSCALL( 3FH, filehandle, bytestoread, tolocation, bytesread, error
        )?
        CODE( 9CÈ );
        CODE( 59H )?
        GETREG( CX, errr );
        IF ODD( error )
        THEN
          result := filehandle
        ELSE           resõlt := 0
        END (* if else *)
      END readfile;


      PROCEDURE ioresult() : CARDINAL;

      BEGÉN
        RETURN result
      END ioresult;


      PROCEDURE right;
      (* Move cursoò right. Will wrap to beginning oæ line if at end. *)

      BEGIN
        INC( newcl );
        IF ( newrow > maxrow ) AND ( newcol = }axcïl )
        THEN
          newcol := 1;
        ELSIF newcol = maxcol + 1
        THEN
          newco| := 1;
        END (* if then *);
      END right;


      PROCEDURE left;
      (* Move cursor left. Will wrap. *)

      BEGIN
        DEC( newcol );
        IF newcol = 0
        T   END ioresult;


      PROCEDURE right;
      (* Move cursoò right. Will wrap to beginning oæ line if at end. *)

      BEGIN
        INC( newcl );
        IF ( newrow > maxrow ) AND ( newcol = }axcïl )
        THEN
          newcol := 1;
        ELSIF newcol = maxcol + 1
        THEN
          newco| := 1;
        END (* if then *);
      END right;


      PROCEDURE left;
      (* Move cursor left. Will wrap. *)

      BEGIN
        DEC( newcol );
        IF newcol = 0
        TTHEN
          newrow := 1;
        END (* if then *);
      END down;


      PROCEDURE up;
      (* Move cursor up. Will wrap. *)

      BEGIN
        DEC( newrow );
        IF newrow = 0
        THEN
          IF ( newcol = maxcol )
          THEN
            newrow := maxrow;
          ELSE
            newrow := namespercol;
          END (* if then *);
        END (* if then *);
      END up;


      PROCEDURE clearlines;
      (* Clear bottom 3 lines *)

      BEGIN
        gotoxy( 0, 22 );
        clrtoeol;
        gotoxy( 0, 23 );
        clrtoeol;
        gotoxy( 0, 24 );
        clrtoeol;
      END clearlines;


      PROCEDURE ok() : BOOLEAN;
      (* Function that puts OK / CANCEL message on screen and returns TRUE
         if user chose OK, FALSE if user chose CANCEL *)

      VAR
          box : CARDINAL;
          ch  : CHAR;


        PROCEDURE revbox;

        BEGIN
          IF box = 0
          THEN
            setmode( highlight );
            gotoxy( 40, 22 );
          writestring((( "ÚÄÄÄÄÄÄ¿    ÚÄÄÄÄÄÄÄÄÄÄ¿" );
            gotoxy( 40, 23 );
            writestring( "³  OK  ³    ³  CANCEL  ³" );
            gotoxy( 40, 24 );
            writestring( "ÀÄÄÄÄÄÄÙ    ÀÄÄÄÄÄÄÄÄÄÄÙ" );
          ELSIF box = 1
          THEN
            setmode( reverse );
            gotoxy( 41, 23 );
            writestring( "  OK  " );
            setmode( highlight );
            gotoxy( 53, 23 );
            writestring( "  CANCEL  " );
          ELSE
            setmode( highlight );
            gotoxy( 41, 23 );
            writestring( "  OK  " );
            setmode( reverse );
            gotoxy( 53, 23 );
            writestring( "  CANCEL  " );
            setmode( highlight );
          END (* if then *);
        END revbox;

      BEGIN (* ok *)
        box := 0;
        revbox;
        box := 1;
        REPEAT
          revbox;
          REPEAT
            mot := motion( direction );
            bp := buttonpressed( butn );
          UNTIL ( keypressed( ) ) OR ( mot ) OR ( bp );
          IF keypressed( )
          THEN
            read( ch );
            ch := CAP( ch );
            IF ch = 'O'
            THEN
              clearlines;
              ch := CHR( F10 );
              RETURN TRUE;
            ELSIF ch = 'C'
            THEN
              ch := CHR( F10 );
              clearlines;
              RETURN FALSE;
            END (* if then *);
          ELSIF mot
          THEN
            IF ORD( direction ) = ra
            THEN
              box := 2;
            ELSIF ORD( direction ) = la
            THEN
              box := 1;
            END (* if then *);
          ELSE
            clearlines;
            IF box = 1
            THEN
              RETURN TRUE;
            ELSE
              RETURN FALSE;
            END (* if then *);
          END (* if then *);
        UNTIL FALSE;
      END ok;


      PROCEDURE copyproc;
      (* Copies selected names to target directory specified by user after
         confirmation from user. *)

      VAR
          target     : nametype;
          buffer     : ARRAY[ 1 .. buffersize ] OF CHAR;
          bytesread,
          byteswrite : CARDINAL;
          date,
          time       : CARDINAL;
          i          : CARDINAL;

      BEGIN
        setmode( normal );
        clearlines;
        gotoxy( 10, 23 );
        i := 0;
        REPEAT
          INC( i );
        UNTIL ( i = maxfiles ) OR ( selectarray[ i ] );
        IF selectarray[ i ]
        THEN
          setmode( highlight );
          writestring( "Copy the highlighted files: " );
          IF ok( )
          THEN
            gotoxy( 0, 23 );
            setmode( highlight );
            centermessage( "Enter directory path to copy file to: " );
            readstring( target );
            IF NOT ( target[ Length( target ) - 1 ] = ':' )
            THEN
              Concat( target, "\", target );
            END (* if then *);
            FOR i := 1 TO maxfiles DO
              IF selectarray[ i ]
              THEN
                Concat( target, names[ i ], name );
                openfile( names[ i ], 0, readhandle );
                DOSCALL( 57H, readhandle, 0, date, time, error );
                openfile( name, 1, writehandle );
                IF ioresult( ) = 2
                THEN
                (* have new file to create *)
                  closefile( writehandle );
                  createfile( name, writehandle );
                  openfile( name, 1, writehandle );
                ELSIF ioresult( ) = 3
                THEN
                  write( CHR( 7 ) );
                  gotoxy( 0, 23 );
                  clrtoeol;
                  gotoxy( 0, 23 );
                  centermessage( "Target directory does not exist" );
                  spacebar;
                  RETURN;
                END (* if then *);
                readfile( readhandle, SIZE( buffer ), ADR( buffer ),
                          bytesread );
              WHILE bytesssread = SIZE( buffer ) DO
                  writefile( writehandle, SIZE( buffer ), ADR( buffer ),
                             byteswrite );
                  IF SIZE( buffer ) # byteswrite
                  THEN
                    write( CHR( 7 ) );
                    gotoxy( 0, 23 );
                    clrtoeol;
                    gotoxy( 0, 23 );
                    centermessage( "Target directory out of space" );
                  END (* if then *);
                  readfile( readhandle, SIZE( buffer ), ADR( buffer ),
                            bytesread );
                END (* while loop *);
                IF bytesread > 0
                THEN
                  writefile( writehandle, bytesread, ADR( buffer ),
                             byteswrite );
                  IF bytesread # byteswrite
                  THEN
                    write( CHR( 7 ) );
                    gotoxy( 0, 23 );
                    clrtoeol;
                    gotoxy( 0, 23 );
                    centermessage( "Target directory out of space" );
                  END (* if then *);
                END (* if then *);
                DOSCALL( 57H, writehandle, 1, date, time, error );
                closefile( readhandle );
                closefile( writehandle );
              END (* if selectarray *);
            END (* for i *);
          END (* if ok *);
        END (* if selectarray *);
        gotoxy( 0, 23 );
        clrtoeol;
      END copyproc;


      PROCEDURE deleteproc;
      (* Deletes selected files after confirmation from user. *)

      VAR
          i : CARDINAL;

      BEGIN
        setmode( normal );
        clearlines;
        gotoxy( 10, 23 );
        i := 0;
        REPEAT
          INC( i );
        UNTIL ( i = maxfiles ) OR ( selectarray[ i ] );
        IF selectarray[ i ]
        THEN
          setmode( highlight );
          writestring( "Delete the highlighted files: " );
          IF ok( )
          THEN
            FOR i := 1 TO maxfiles DO
              IF selectarray[ i ]
              THEN
                DOSCALL( 41H, ADR( names[ i ] ), error )
              END (* if selectarray *);
            END (* for i *);
          END (* if ok *);
        END (* if selectarray *);
      END deleteproc;


      VAR
          direction  : CHAR;
          butn       : butntype;
          slcô       : BOOLEAN;
          mot,
          bp         : BOOLEAN;
          horizontal,
          vertical   : INTEGER;
          bytes      : REAL;
          drag       : CHAR?


      PROCEDURE motion
                ( VAR direction : CHAR  (* out *) ) : BOOLEAN;
      (* Returns TRUE if motion, FALSE if none. direction will coîtain the
         character represe~tation of the movement -- la, ra, da, ua. *)

      VAR
          horiz,
          vert  : INTEGER;

      BEGIN
        IF mousestaôus = 0
        THEN
          RETURN FALSE;
        ELSE
          IF ( ORD( drag ) = ua ) OR ( ORD( drag ) = da ) OR ( ORD( drag )
             = la ) OR ( ORD( drag ) = ra )
          THEN
            direction := drag;
            drag := 'a';
            RETURN TRUE;
          ELSE
            ReadMotionCo}nters( horiz, vert );
            horizontal := horizntal + hoòiz;
            vertical := vertical + vert;
            IF ( ABS( hoòizontal ) > hmickey ) OR ( ABS( vertical ) >
               vmickey )
            THEN
              IF ABS( horizontal ) > ABS( vertical )
              THEN
                IF horizontal < 0
                THEN
                  direction := CHR( la );
                ELSE
                  direction := CHR( ra );
                END (* if then *);
              ELSE
                IF vertical < 0
                THEN
                  direction := CHR( ua );
                ELSE
                  direction := CHR( da );
                END (* if then *);
              END (* if then *);
              horizontal := 0;
              vertical := 0;
              RETURN TRUE;
            ELSE
              RETURN FALSE;
            END (* if then *);
          END (* if then *);
        END (* if then *);
      END motion;


      PROCEDURE buttonpressed
                ( VAR button : butntype  (* out *) ) : BOOLEAN;
      (* Return TRUE if button is pressed, FALSE if not. button will be one
         of the values in butntype enumeration type *)

      VAR
          buttonstatus : ButtonSet;
          horiz,
          vert         : INTEGER;

      BEGIN
        IF mousestatus = 0
        THEN
          button := nobutton;
          RETURN FALSE;
        ELSE
          GetPosBut( buttonstatus, horiz, vert );
          IF LeftButton IN buttonstatus
          THEN
            button := lfbutton;
            RETURN TRUE;
          ELSIF RightButton IN buttonstatus
          THEN
            button := rtbutton;
            RETURN TRUE;
          ELSE
            button := nobutton;
            RETURN FALSE;
          END (* if then *);
        END (* if then *);
      END buttonpressed;


      PROCEDURE select
                ( VAR namearray : namearraytype  (* out *);
                      get,
                      delete,
                      copy,
                      escape    : BOOLEAN        (* in *);
                      wildcard  : wildcardtype   (* in *);
                  VAR exit      : BOOLEAN        (* out *) );

      VAR
          i,
          k       : CARDINAL;
          row,
          col     : CARDINAL;
          ch      : CHAR;
          index   : CARDINAL;
          large   : BOOLEAN;  (* True if more than maxfiles files *)
          anyfile : filenametype;
          nofiles : BOOLEAN;
          w       : CARDINAL;
          mess    : ARRAY[ 0 .. 79 ] OF CHAR;
          high,
          low     : CARDINAL;
          page1   : BOOLEAN;


        PROCEDURE selectproc;
        (* Returns selected names to calling program by filling namearray
           with selected names *)

        VAR
            indx : CARDINAL;
            j    : CARDINAL;
            i    : CARDINAL;

        BEGIN
          indx := 0;
          FOR i := 1 TO maxfiles DO
            IF selectarray[ i ]
            THEN
              INC( indx );
              j := 0;
              WHILE names[ i ][ j ] # 0C DO
                namearray[ indx ][ j ] := names[ i ][ j ];
                INC( j );
              END (* while loop *);
              namearray[ indx ][ j ] := 0C;
            END (* if then *);
          END (* for i *);
          namearray[ 0 ][ 0 ] := CHR( indx );
        END selectproc;

      BEGIN (* select *)
        IF ( NOT get ) AND ( NOT escape )
        THEN
          namearray[ 0 ][ 0 ] := CHR( 0 );
          exit := TRUE;
          RETURN;
        END(* if *);
        exit := FALSE;
        page1 := TRUE;
        setcursor( none );
        LOOP
          FOR i := 1 TO maxfiles DO
            selectarray[ i ] := FALSE;   (* No files have been selected *)
          END (* for i *);
          setmode( normal );
          clrscreen;
          gotoxy( 31, 1 );
          writestring( "Alphabetizing ..." );
          DOSCALL( 1AH, ADR( dta ) );
          w := 1;
          anyfile := wildcard.filter[ w ];
          nofiles := TRUE;
          number := 0;   (* Number of files in directory *)
          WHILE ( w <= wildcard.amount ) DO
            DOSCALL( 4EH, ADR( anyfile ), 0, error );
            nofiles := nofiles AND ( error = 18 );
            (* Compute the number of file entries. *)
            WHILE ( error # 18 ) DO
              INC( number );
              DOSCALL( 4FH, error );
            END (* while loop *);
            INC( w );
            IF w < 11
            THEN
              anyfile := wildcard.filter[ w ];
            END(* if then *);
          END (* while loop *);
          IF nofiles
          THEN
            namearray[ 0 ][ 0 ] := CHR( 0 );
            setmode( normal );
            setcursor( small );
            gotoxy( 0, 10 );
            centermessage( "No files on this subdirectory." );
            spacebar;
            exit := TRUE;
            RETURN;
          END (* if then *);
          large := number > maxfiles;   (* More than one page *)
          ch := 'z';
          fillchar( ADR( names ), SIZE( names ), ch );
          w := 1;
          anyfile := wildcard.filter[ w ];
          DOSCALL( 4EH, ADR( anyfile ), 0, error );
          IF NOT page1 (* Skip first maxfiles files *)
          THEN
            k := 0;
            WHILE ( k < maxfiles ) AND ( w <= wildcard.amount ) DO
              DOSCALL( 4EH, ADR( anyfile ), 0, error );
              WHILE ( k < maxfiles ) DO
                IF error # 18
                THEN
                  INC( k );
                END (* if then *);
                DOSCALL( 4FH, error );
              END (* while loop *);
              IF k < maxfiles
              THEN
                INC( w );
              END (* if then *);
              IF w < 11
              THEN
                anyfile := wildcard.filter[ w ];
              END(* if then *);
            END (* while loop *);
          END (* if then *);
          k := 0;
          WHILE ( k < maxfiles ) AND ( error # 18 ) DO
            INC( k );
            names[ k ] := dta.file;
            sort( k );
            DOSCALL( 4FH, error );
          END (* while loop *);
          INC( w );
          anyfile := wildcard.filter[ w ];
          WHILE ( w <= wildcard.amount ) DO
            DOSCALL( 4EH, ADR( anyfile ), 0, error );
            WHILE ( k < maxfiles ) AND ( error # 18 ) DO
              INC( k );
              names[ k ] := dta.file;
              sort( k );
              DOSCALL( 4FH, error );
            END (* while loop *);
            INC( w );
            IF w < 11
            THEN
              anyfile := wildcard.filter[ w ];
            END(* while *);
          END (* while loop *);
          (* Sort names *)
          clrscreen;
          drawbox( 0, 0, 20, 78 );
          namespercol := k DIV 5 + 1;
          IF namespercol > 20
          THEN
            namespercol := 20;
          END (* if then *);
          FOR i := 1 TO k DO
            row := ( i - 1 ) MOD namespercol + 1;
            col := ( i - 1 ) DIV namespercol + 1;
            gotoxy( ( col - 1 ) * 15 + 4, row );
            writestring( names[ i ] );
          END (* for loop *);
          mess[ 0 ] := 0C;
          IF get
          THEN
            Concat( mess, "F5/Right Button--Select    ", mess );
          END (* if get *);
          IF copy
          THEN
            Concat( mess, "F9--Copy    ", mess );
          END (* if copy *);
          IF delete
          THEN
            Concat( mess, "F10--Delete    ", mess );
          END (* if delete *);
          IF escape
          THEN
            Concat( mess, "Esc--Exit", mess );
          END (* if escape *);
          putmsg( 23, mess );
          mess[ 0 ] := 0C;
          Concat( mess, "Use arrow keys or mouse to move cursor.", mess );
          Concat( mess, "  Hit Ret or Left button to select.", mess );
          putmsg( 22, mess );
          IF page1
          THEN
            IF large
            THEN
              maxrow := 20;
              maxcol := 5;
            ELSE
              maxrow := ( number - 1 ) MOD namespercol + 1;
              maxcol := ( ( number - 1 ) DIV namespercol ) + 1;
            END (* if then *);
          ELSE
            maxrow := ( number - 101 ) MOD namespercol + 1;
            maxcol := ( ( number - 101 ) DIV namespercol ) + 1;
          END (* if then *);
          oldrow := 1;
          oldcol := 1;
          newrow := 1;
          newcol := 1;
          setmode( highlight );
          bytes := 0.0;
          gotoxy( 24, 24 );
          writestring( "Byte Count of Files:  0" );
          setmode( normal );
          drag := 'a';   (* Initialize to dragging in no direction *)
          horizontal := 0;   (* No horizontal motion *)
          vertical := 0;   (* No vertical motion *)
          REPEAT
            rev;   (* Reverse name cursor is on. Unreverse name cursor used
                      to be on. Put asterisk in front of name if selected.
                   *)
            REPEAT
              mot := motion( direction );   (* Detect motion of mouse *)
              bp := buttonpressed( butn );   (* Detect button pressed on
                                                mouse *)
            UNTIL ( keypressed( ) ) OR ( mot ) OR ( bp );
            IF keypressed( )
            THEN
              read( ch );
            ELSIF mot
            THEN
              ch := direction;
            ELSIF butn = rtbutton
            THEN
              ch := CHR( F5 );
            ELSE
              ch := 'a';   (* Left button -- causes case statement to fall
                              through to the else clause *)
            END (* if then *);
            CASE ORD( ch ) OF
              ra :
                right; |
              la :
                left; |
              da :
                down; |
              ua :
                up; |
              F1 :
                page1 := TRUE; |
              F2 :
                IF large
                THEN
                  page1 := FALSE;
                END (* if then *); |
              F5 :
                IF get
                THEN
                  selectproc;
                  EXIT;
                ELSE
                  ch := 'a';   (* Go back to top of repeat loop *)
                END (* if then *); |
              F9 :
                IF copy
                THEN
                  copyproc;
                ELSE
                  ch := 'a';
                END (* if then *); |
              F10 :
                IF delete
                THEN
                  deleteproc;
                ELSE
                  ch := 'a';
                END (* if then *); |
              27 :
                IF escape
                THEN
                  namearray[ 0 ][ 0 ] := CHR( 0 );
                  setmode( normal );
                  exit := TRUE;
                  EXIT;
                ELSE
                  ch := 'a';
                END (* if then *);
            ELSE
              ;
            END (* case *);
            IF ( butn = lfbutton ) OR ( ch = cr )
            THEN
              index := ( newcol - 1 ) * namespercol + newrow;
              selectarray[ index ] := NOT selectarray[ index ];
              openfile( names[ index ], 0, readhandle );
              getfilesize( readhandle, high, low );
              closefile( readhandle );
              IF selectarray[ index ]
              THEN
                bytes := bytes + 65535.0 * FLOAT( high ) + FLOAT( low );
              ELSE
                bytes := bytes - 65535.0 * FLOAT( high ) - FLOAT( low );
              END (* if then *);
              gotoxy( 46, 24 );
              setmode( highlight );
              writereal( bytes, 0, 1 );
              writestring( "          " );
              IF butn = lfbutton
              THEN
                rev;
                REPEAT   (* Wait until let go of button or drag *)
                  mot := motion( direction );
                  bp := buttonpressed( butn );
                UNTIL ( mot ) OR ( NOT bp );
                IF mot
                THEN
                  drag := direction;
                END (* if then *);
              END (* if then *);
            END (* if then *);
          UNTIL ( ORD( ch ) = F5 ) OR ( ORD( ch ) = F9 ) OR ( ORD( ch ) =
                F10 ) OR ( ORD( ch ) = F1 ) OR ( ORD( ch ) = F2 );
        END (* loop *);
        setcursor( small );
        setmode( normal );
      END select;


      VAR
          result : CARDINAL;

    BEGIN
      result := 0;
      (* Determine if mouse hardware/software is installed *)
      FlagReset( mousestatus, numofbuttons );
    END dmanager.