MODULE FastBits;

FROM EasyGEM1 IMPORT SelectFile;
FROM EasyGEM0 IMPORT FormAlert;
FROM Strings IMPORT String;
FROM Files IMPORT State, File, Access, Open, Close;
FROM Binary IMPORT Seek, WriteByte, ReadWord, SeekMode;

VAR n, button: CARDINAL;
    ok: BOOLEAN;
    f: File;
    name: String;

BEGIN
  name:= '';
  LOOP
    FormAlert (3, "[0][ FASTBITS by Th.Tempelmann ][Set|Clear|Exit]", button);
    IF button = 3 THEN
      RETURN
    END;
    SelectFile ('', name, ok);
    IF ok THEN
      Open (f, name, readWrite);
      IF State (f) < 0 THEN
        FormAlert (1, "[1][ Error opening file ][OK]", button)
      ELSE
        ReadWord (f, n);
        IF n # $601A THEN
          Close (f);
          FormAlert (1, "[1][ This is no program file ][OK]", button)
        ELSE
          Seek (f, 25, fromBegin);
          IF button = 1 THEN
            WriteByte (f, SHORT (7))
          ELSE
            WriteByte (f, SHORT (0))
          END;
          Close (f);
          IF button = 1 THEN
            FormAlert (1, "[0][ Fast bits are set ][OK]", button)
          ELSE
            FormAlert (1, "[0][ Fast bits are cleared ][OK]", button)
          END
        END
      END
    END
  END (* LOOP *)
END FastBits.
