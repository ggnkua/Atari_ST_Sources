MODULE Scrap;

IMPORT
  IO, Scrp, Sys;


VAR
  default: ARRAY 100 OF CHAR;


PROCEDURE Get*;
  VAR
    s: ARRAY 1000 OF CHAR;
 BEGIN
  Scrp.Read(s);
  IO.WriteString( "Contents of Scrap:"); IO.WriteLn;
  IO.WriteString( s); IO.WriteLn;
 END Get;


PROCEDURE Set*;
 BEGIN
  Scrp.Write( Sys.Basepage.Command);
  Get;
 END Set;


PROCEDURE Default*;
 BEGIN
  Scrp.Write( default);
  Get;
 END Default;


BEGIN
  Scrp.Read(default);
END Scrap.