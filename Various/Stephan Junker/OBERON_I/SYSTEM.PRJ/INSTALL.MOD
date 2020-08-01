MODULE Install; (* SJ 11.5.95 *)


IMPORT
  LTL, GC;


PROCEDURE Run;
  VAR
    s: ARRAY 80 OF CHAR;
 BEGIN
  s := "Env.Set LINK_FORM=IOFORM";
  LTL.Call(s);
  s := "OLink.Link -xTTP Compile";
  LTL.Call(s);
  GC.Collect;
  s := "OLink.Link -xTTP Link";
  LTL.Call(s);
  GC.Collect;
  s := "OLink.Link -xTTP Make";
  LTL.Call(s);
 END Run;


BEGIN
  Run
END Install.