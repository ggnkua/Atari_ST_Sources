MODULE ST_Cookie;

(* Aus STE mach' ST *)

FROM CookieJar IMPORT Machine, GetCookie, ModifyCookie;

VAR dummy: BOOLEAN;
    c: LONGCARD;

BEGIN
  IF GetCookie (Machine, c) & (c = $10000) THEN
    dummy:= ModifyCookie (Machine, 0)
  END
END ST_Cookie.
