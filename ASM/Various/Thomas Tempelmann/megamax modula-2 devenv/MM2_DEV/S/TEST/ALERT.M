MODULE Alert;

FROM EasyGEM0 IMPORT FormAlert, WrapAlert;
IMPORT GEMDOS, PrgCtrl;

VAR c: CARDINAL;

BEGIN
  FormAlert (2, "[1][Terminate via][GEMDOS|PrgCtrl]", c);
  IF c = 2 THEN
    PrgCtrl.TermProcess (-39);
  ELSE
    GEMDOS.Term (-39);
  END
END Alert.
