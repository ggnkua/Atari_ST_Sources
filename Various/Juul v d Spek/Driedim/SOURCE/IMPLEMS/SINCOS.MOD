IMPLEMENTATION MODULE sincos;

(*****************************************************)
(*                                                   *)
(*      SINCOS                                       *)
(*      ------                                       *)
(*                                                   *)
(*   Author: Juul v/d Spek, Valkenswaard.            *)
(*                                                   *)
(*****************************************************)
(*                                                   *)
(* This module provides a correct sine and cosine    *)
(* implementation.                                   *)
(*                                                   *)
(*****************************************************)

  CONST
    eps         = 0.00000000000001;
    pi          = 3.1415926536;
    halfpi      = pi/2.0;
    tweepi      = 2.0*pi;
    anderhalfpi = pi+halfpi;



PROCEDURE sin1(x: REAL): REAL;
  VAR i, d, res, fac, exp: REAL;
BEGIN
  res:= x;
  fac:= 6.0;
  i  := 3.0;
  exp:= x;
  x  := x*x;
  exp:= exp*x;

  REPEAT
    res:= res-exp/fac;
    i:= i+1.0; fac:= fac*i;
    i:= i+1.0; fac:= fac*i;
    exp:= exp*x;

    d:= exp/fac;
    res:= res+d;
    i:= i+1.0; fac:= fac*i;
    i:= i+1.0; fac:= fac*i;
    exp:= exp*x;
  UNTIL ABS(d)<eps;

  RETURN res
END sin1;



PROCEDURE cos1(x: REAL): REAL;
  VAR i, d, res, fac, exp: REAL;
BEGIN
  i  := 2.0;
  x  := x*x;
  exp:= x;
  fac:= 2.0;
  res:= 1.0;

  REPEAT
    res:= res-exp/fac;
    i:= i+1.0; fac:= fac*i;
    i:= i+1.0; fac:= fac*i;
    exp:= exp*x;

    d:= exp/fac;
    res:= res+d;
    i:= i+1.0; fac:= fac*i;
    i:= i+1.0; fac:= fac*i;
    exp:= exp*x;
  UNTIL d<eps;

  RETURN res
END cos1;


PROCEDURE cos(x: REAL): REAL;
BEGIN
  WHILE x>tweepi  DO x:= x-tweepi END;
  WHILE x<0.0     DO x:= x+tweepi END;
  IF      x >= anderhalfpi THEN RETURN  sin1(x-anderhalfpi)
    ELSIF x >= pi          THEN RETURN -cos1(x-pi         )
    ELSIF x >= halfpi      THEN RETURN -sin1(x-halfpi     )
    ELSE                        RETURN  cos1(x)
  END;
END cos;


PROCEDURE sin(x: REAL): REAL;
BEGIN
  WHILE x>tweepi  DO x:= x-tweepi END;
  WHILE x<0.0     DO x:= x+tweepi END;
  IF      x >= anderhalfpi THEN RETURN -cos1(x-anderhalfpi)
    ELSIF x >= pi          THEN RETURN -sin1(x-pi         )
    ELSIF x >= halfpi      THEN RETURN  cos1(x-halfpi     )
    ELSE                        RETURN  sin1(x)
  END;
END sin;


END sincos.

