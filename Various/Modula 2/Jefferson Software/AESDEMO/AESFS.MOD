MODULE aesfs;

(* Jefferson Software Copyright 1986 *)

(* Jefferson Software      *)
(* 12416 N 28th Dr #18-236 *)
(* Phoenix,  AZ 85029-2434 *)
(* (602)243-3106           *)

(* Phase BBS (602)849-1287 (up to 2400 baud) has source *)
(* and answers about Jefferson Software Modula in Sig 8 *)

(* Compuserve ID 73637, 1245 *)

(* Permission to use this source is given to all who   *)
(* agree to include Jefferson Software's copyright     *)
(* notice, address, and phone number in all copies of  *)
(* this source or source derived from this source.     *)
(* Please send any changes, updates or bugs to us at   *)
(* Jefferson Software. If you have code you want to    *)
(* share with us all, send it and any documentation to *)
(* us. Please tell us if you want your name included.  *)

FROM AESApplications IMPORT ApplInit, ApplExit;

FROM AESFileSelector IMPORT FselInput;

FROM FileSystem IMPORT File, Lookup, ReadChar, Close;

FROM Terminal IMPORT Write;

CONST
  OK = 1;

VAR
  i : INTEGER;
  path, selection : ARRAY [0..124] OF CHAR;
  exitbutton : INTEGER;
  f : File;
  ch : CHAR;

BEGIN
  i := ApplInit();
  path := 'D:\AES\*.MOD';
  selection := 'AESFS.MOD';
  i := FselInput(path, selection, exitbutton);
  IF exitbutton = OK THEN
    Lookup(f, selection, FALSE);
    ReadChar(f, ch);
    WHILE NOT f.eof DO
      Write(ch);
      ReadChar(f, ch);
    END;
    Close(f);
  END;
  i := ApplExit();
END aesfs.
