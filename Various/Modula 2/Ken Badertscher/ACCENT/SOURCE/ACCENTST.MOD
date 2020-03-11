IMPLEMENTATION MODULE AccentStrings;

(* Copyright 1987,1988 Ken Badertscher
 * Permission is granted to freely use this program and source code,
 * however it may NOT be used or modified for any commercial gain.
 * The author disclaims responsibility for any damages resulting
 * from the use or misuse of this program, and disclaims liability
 * for losses of any kind or nature, financial or otherwise,
 * incurred as a result of the use of this software.
 *)

BEGIN
    vowel[0] := 'e';
    vowel[1] := 'a';
    vowel[2] := 'o';
    vowel[3] := 'i';
    vowel[4] := 'u';
    vowel[5] := 'y';

    cocknie[0] := 'ruddy';
    cocknie[1] := 'bloody';
    cocknie[2] := 'bleedin';

    nerdism[0] := 'like';
    nerdism[1] := 'you know';
    nerdism[2] := 'uh';
    nerdism[3] := 'um';
    nerdism[4] := 'er';
    nerdism[5] := 'well';
    nerdism[6] := 'I mean';
    nerdism[7] := 'okay';
    nerdism[8] := 'oh';

    curse[0] := 'damn';
    curse[1] := 'damned';
    curse[2] := 'goddamn';
    curse[3] := 'goddamned';
    curse[4] := 'fucking';
    curse[5] := 'motherfucking';
    curse[6] := 'shitty';
    curse[7] := 'son-of-a-bitch';
    curse[8] := 'piece-of-shit';
    curse[9] := 'crappy';
    curse[10] := 'dumbass';
    curse[11] := 'bastard';
    curse[12] := 'screwed-up';
    curse[13] := 'fucked';

    censor[0] := '*';
    censor[1] := '%';
    censor[2] := '#';
    censor[3] := '!';
    censor[4] := '&';
    censor[5] := '+';
    censor[6] := '?';
    censor[7] := '@';

    article[0] := 'a';
    article[1] := 'the';
    article[2] := 'its';
    article[3] := 'my';
    article[4] := 'his';
    article[5] := 'her';
    article[6] := 'our';
(*
    article[7] := 'these';
    article[8] := 'those';
    article[9] := 'their';
*)
END AccentStrings.
