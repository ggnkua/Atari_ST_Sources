MODULE Load;

FROM InOut IMPORT ReadString, WriteString, WriteLn;
FROM StorBase IMPORT FullStorBaseAccess;
FROM ShellMsg IMPORT StdPaths, ShellPath;
FROM PathEnv IMPORT HomePath;
FROM Loader IMPORT LoadModule, LoaderResults;
FROM Strings IMPORT String;

VAR modName, errMsg: String;
VAR result: LoaderResults;

BEGIN
  HomePath:= ShellPath;
  IF FullStorBaseAccess () THEN
    WriteString ('Full access')
  ELSE
    WriteString ('Not full access')
  END;
  LOOP
    WriteLn;
    WriteString ('Load which module? ');
    ReadString (modName);
    IF modName[0] = '' THEN EXIT END;
    LoadModule (modName, StdPaths, modName, errMsg, result);
    WriteString (errMsg);
  END
END Load.
