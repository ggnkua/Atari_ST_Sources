PROCEDURE getmpb(VAR blkptr:threeints);external;

FUNCTION bconstat(device:integer):integer;external;

FUNCTION conin(device:integer):integer;external;

PROCEDURE bconout(device,byte:integer);external;

FUNCTION rwabs(flg:integer;VAR buf:secbuff;n,rec,dev:integer):integer;external;

FUNCTION setexec(number,vector:integer):integer;external;

FUNCTION tickcal:integer;external;

FUNCTION getbpb(device:integer;VAR block:nineints):integer;external;

FUNCTION bcostat(device:integer):integer;external;

FUNCTION mediach(device:integer):integer;external;

FUNCTION drvmap:integer;external;

FUNCTION kbshift(mode:integer):integer;external;

