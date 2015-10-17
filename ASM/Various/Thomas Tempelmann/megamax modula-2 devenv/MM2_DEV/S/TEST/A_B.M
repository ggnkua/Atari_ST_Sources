DEFINITION MODULE Amod;

VAR variable: CARDINAL;

END Amod.

DEFINITION MODULE Bmod;

PROCEDURE proced;

END Bmod.

IMPLEMENTATION MODULE Amod;

(*$N+,L-*)

FROM Bmod IMPORT proced;

END Amod.
