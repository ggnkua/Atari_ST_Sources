procedure AES_CALL(     OP : integer;
                    var int_in : int_in_parms;
                    var int_out : int_out_parms;
                    var addr_in : addr_in_parms;
                    var addr_out : addr_out_parms
                  );
external;

procedure VDI_CALL( CMD, SUB_CMD, NINTS, NPTS : integer;
                    var ctrl : ctrl_parms;
                    var int_in : int_in_parms; var int_out : int_out_parms;
                    var pts_in : pts_in_parms; var pts_out : pts_out_parms;
                    translate : boolean
                  );
external;

procedure vsf_interior( FILL_STYLE : integer );
  begin
    INT_IN[ 0 ] := FILL_STYLE;
    VDI_CALL( 23, 0, 1, 0,
              CONTROL,
              INT_IN, INT_OUT,
              PTS_IN, PTS_OUT,
              false
            );
  end;

procedure vsf_color( COLOR_INDEX : integer );
  begin
    INT_IN[ 0 ] := COLOR_INDEX;
    VDI_CALL( 25, 0, 1, 0,
              CONTROL,
              INT_IN, INT_OUT,
              PTS_IN, PTS_OUT,
              false
            );
  end;

procedure vsf_style( STYLE_INDEX : integer );
  begin
    INT_IN[ 0 ] := STYLE_INDEX;
    VDI_CALL( 24, 0, 1, 0,
              CONTROL,
              INT_IN, INT_OUT,
              PTS_IN, PTS_OUT,
              false
            );
  end;

procedure vst_alignment( HOR_IN, VERT_IN : integer;
                         var HOR_OUT, VERT_OUT : integer
                       );
  begin
    INT_IN[ 0 ] := HOR_IN;
    INT_IN[ 1 ] := VERT_IN;
    VDI_CALL( 39, 0, 2, 0,
              CONTROL,
              INT_IN, INT_OUT,
              PTS_IN, PTS_OUT,
              false
            );
    HOR_OUT  := INT_OUT[ 0 ];
    VERT_OUT := INT_OUT[ 1 ];
  end;

procedure vsl_ends( BEG_STYLE, END_STYLE : integer );
  begin
    INT_IN[ 0 ] := BEG_STYLE;
    INT_IN[ 1 ] := END_STYLE;
    VDI_CALL( 108, 0, 2, 0,
              CONTROL,
              INT_IN, INT_OUT,
              PTS_IN, PTS_OUT,
              false
            );
  end;

procedure vsl_color( COLOR_INDEX : integer );
  begin
    INT_IN[ 0 ] := COLOR_INDEX;
    VDI_CALL( 17, 0, 1, 0,
              CONTROL,
              INT_IN, INT_OUT,
              PTS_IN, PTS_OUT,
              false
            );
  end;

procedure vsl_width( LINE_WIDTH : integer );
  begin
    PTS_IN[ 0 ] := LINE_WIDTH;
    PTS_IN[ 1 ] := 0;
    VDI_CALL( 16, 0, 0, 1,
              CONTROL,
              INT_IN, INT_OUT,
              PTS_IN, PTS_OUT,
              false
            );
  end;

procedure mfdbptr_to_ar2( MP : mfdbptr;
                          var MA : AR2
                        );
  var
    COERCE : record
               case boolean of
                 false : ( MPTR : mfdbptr );
                 true  : ( MARR : AR2 );
             end;
  begin
    COERCE.MPTR := MP;
    MA[ 0 ] := COERCE.MARR[ 0 ];
    MA[ 1 ] := COERCE.MARR[ 1 ];
  end;


procedure vro_cpyform( WR_MODE : integer;
                       PXY : PXYARRAY;
                       SOURCE, DESTIN : mfdbptr
                     );
  var
    I : integer;
    AARRAY : AR2;
  begin
    INT_IN[ 0 ] := WR_MODE;
    for I := 0 to 7 do PTS_IN[ I ] := PXY[ I ];
    mfdbptr_to_ar2( SOURCE, AARRAY );
    CONTROL[ 7 ] := AARRAY[ 0 ];        CONTROL[ 8 ] := AARRAY[ 1 ];
    mfdbptr_to_ar2( DESTIN, AARRAY );
    CONTROL[ 9 ] := AARRAY[ 0 ];        CONTROL[ 10 ] := AARRAY[ 1 ];
    VDI_CALL( 109, 0, 1, 4,
              CONTROL,
              INT_IN, INT_OUT,
              PTS_IN, PTS_OUT,
              false
            );
  end;


procedure v_pline( COUNT : integer;
                   PXY   : PXYARRAY
                 );
  var
    I : integer;
  begin
    for I := 0 to (2*COUNT)-1 do PTS_IN[ I ] := PXY[ I ];
    VDI_CALL( 6, 0, 0, COUNT,
              CONTROL,
              INT_IN, INT_OUT,
              PTS_IN, PTS_OUT,
              false
            );

  end;


procedure v_gtext( X, Y : integer;
                   TEXT : string
                 );
  var
    I : integer;

  begin
    PTS_IN[ 0 ] := X;
    PTS_IN[ 1 ] := Y;
    for I := 1 to length(TEXT) do INT_IN[ I - 1 ] := ord( TEXT[ I ] );
    VDI_CALL( 8, 0, length(TEXT), 2,
              CONTROL,
              INT_IN, INT_OUT,
              PTS_IN, PTS_OUT,
              false
            );
  end;

procedure v_bar( XUL, YUL, XLR, YLR : integer );
  begin
    PTS_IN[ 0 ] := XUL;
    PTS_IN[ 1 ] := YUL;
    PTS_IN[ 2 ] := XLR;
    PTS_IN[ 3 ] := YLR;
    VDI_CALL( 11, 1, 0, 4,
              CONTROL,
              INT_IN, INT_OUT,
              PTS_IN, PTS_OUT,
              false
            );
  end;


procedure v_ellipse( X, Y, XRADIUS, YRADIUS : integer );
  begin
    PTS_IN[ 0 ] := X;
    PTS_IN[ 1 ] := Y;
    PTS_IN[ 2 ] := XRADIUS;
    PTS_IN[ 3 ] := YRADIUS;

    VDI_CALL( 11, 5, 0, 4,
              CONTROL,
              INT_IN, INT_OUT,
              PTS_IN, PTS_OUT,
              false
            );
  end;
