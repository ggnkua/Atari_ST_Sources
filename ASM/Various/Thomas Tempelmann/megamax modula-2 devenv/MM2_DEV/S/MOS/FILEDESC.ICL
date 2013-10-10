(* 'FileDesc.Icl' *)

TYPE FileDesc = RECORD
              (* Dieses RECORD befindet sich in Files, Text, Binary, FileBase *)
              state: INTEGER; (* muž immer am Anfang des Records bleiben ! *)
              pos: LONGCARD;
              len: LONGCARD;
              CASE ondisk: BOOLEAN OF
                TRUE:
                  new: BOOLEAN;
                  handle: INTEGER;
                  modified: BOOLEAN|
                FALSE:
                  unit: Unit;
                  ucons: BOOLEAN;
                  uwrite: UDataProc;
                  uwrstr: UWStrProc;
                  uread: UDataProc;
                  urdchr: UGChrProc;
                  uclose: UCloseProc;
                  uflush: UFlushProc;
                  uecho: BOOLEAN;
                  uhandle: LONGWORD
              END;
              accmode: Access;
              buffer: ADDRESS;   (* nur bei readSeqTxt *)
              bufsize: CARDINAL; (* nur bei readSeqTxt *)
              bufpos: CARDINAL;  (* nur bei readSeqTxt *)
              getlast: BOOLEAN;
              lastch: CHAR;
              prevch: CHAR;
              eof: BOOLEAN;
              eol: BOOLEAN;
              chkeof: BOOLEAN;
              eofchr: CHAR;
              skipLF: BOOLEAN;
              name: ARRAY [0..139] OF CHAR;
              modlevel: INTEGER
            END;

(* End of 'FileDesc.Icl' *)
