ctrl_parms      = array[ 0..11 ] of integer;
int_in_parms    = array[ 0..15 ] of integer;
int_out_parms   = array[ 0..45 ] of integer;
pts_in_parms    = array[ 0..11 ] of integer;
pts_out_parms   = array[ 0..11 ] of integer;
pointer         = ^char;
addr_in_parms   = array[ 0..1 ] of pointer;
addr_out_parms  = array[ 0..0 ] of pointer;

mfdb            = record
                    mp  : long_integer;
                    fwp : integer;
                    fh  : integer;
                    fww : integer;
                    ff  : integer;
                    np  : integer;
                    r1  : integer;
                    r2  : integer;
                    r3  : integer;
                 end;

mfdbptr         = ^mfdb;

AR2             = array[ 0..1 ] of integer;

PXYARRAY        = array[ 0..100 ] of integer;

