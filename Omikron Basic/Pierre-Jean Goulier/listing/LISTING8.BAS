DEF PROC Trans_String(N%,Adr)
  DIM A$(N%)
  FOR I%=0 TO N%
    IF LPEEK(Adr+I%*6)=0 THEN EXIT
    R= LPEEK(Adr+I%*6):L= WPEEK(Adr+I%*6+4)
    Start= LPEEK( SEGPTR +28)+R
    FOR J%=0 TO L-1
      A$(I%)=A$(I%)+ CHR$( PEEK(Start+J%))
    NEXT J%
  NEXT I%
RETURN

