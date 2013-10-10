MODULE ForkShell;

FROM Strings IMPORT Assign;
FROM SysUtil1 IMPORT SuperPeek;
FROM SYSTEM IMPORT CALLEXT, ADR, ADDRESS;

VAR cmd: ARRAY [0..4] OF CHAR; l: ADDRESS; ok: BOOLEAN;

BEGIN
  Assign ("sh", cmd, ok); (* wegen bug, sonst geht's einfacher *)
  SuperPeek (4F6H, l);
  IF l # 0 THEN
    CALLEXT (l, ADR (cmd));
  END;
END ForkShell.
