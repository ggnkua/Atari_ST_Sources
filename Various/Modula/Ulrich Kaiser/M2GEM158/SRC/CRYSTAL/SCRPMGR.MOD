IMPLEMENTATION MODULE ScrpMgr;

(*
AES Scrap Manager.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES     IMPORT IntOut,Addr,crystal,Version;
#ifdef MM2
FROM SYSTEM  IMPORT ADR,CADR;
#else
FROM SYSTEM  IMPORT ADR;
#endif
#if ST
#if use_POSIX
FROM types   IMPORT DIRSEP,PathName;
FROM dir     IMPORT access,fOK,unlink;
FROM str     IMPORT strcat,strcpy;
FROM lib     IMPORT void,ptr;
#endif
#endif

AES_SYSTEM_IMPORT

#if Seimet
CONST F80 = 050000101H;
      F81 = 051000101H;
      F82 = 052000100H;
#endif

#if ST
#if (defined LPRM2) || (defined SPCM2)
TYPE ScrapTypes = ARRAY[ScCSV..ScUSR] OF ARRAY[0..9] OF CHAR;
#else
TYPE ScrapTypes = ARRAY Scraps OF ARRAY[0..9] OF CHAR;
#endif
VAR Types: ScrapTypes;
#endif

PROCEDURE ScrpRead(VAR Path: ARRAY OF CHAR): Scrap;
#if ST
#if use_POSIX
VAR c   : Scraps;
    s   : Scrap;
    scrp: PathName;
    i   : CARDINAL;
#endif
#endif
BEGIN
  Path[0]:= 0C;
  Addr[0]:= ADR(Path);
  crystal(80,0,1,1);
#if ST
  IF (Version() = 0220H) OR (Version() = 1042H) OR (Version() = 0399H) THEN
#else
  IF Version() >= 0220H THEN (* GEM 2.x, GEM 3.x *)
#endif
    RETURN CAST(Scrap,IntOut[0]);
  ELSE
    (* read directory and set WORDSET *)
    IF Path[0] # 0C THEN
#if ST
#if use_POSIX
#warning ...using M2POSIX
      i:= 0;
      WHILE Path[i] # 0C DO
        INC(i);
      END;

      IF Path[i - 1] # DIRSEP THEN
        Path[i]:= DIRSEP;
        Path[i + 1]:= 0C;
      END;
      strcpy(ptr(scrp),ptr(Path));
      s:= Scrap{};
      FOR c:= ScCSV TO ScUSR DO
        strcat(ptr(scrp),ptr(Types[c]));
        IF access(scrp,fOK) = 0 THEN
          INCL(s,c);
        END;
      END;
      RETURN s;
#else
      ;
#endif
#endif
    ELSE
      RETURN NoScrap;
    END;
  END;
END ScrpRead;

PROCEDURE ScrpWrite(REF Path: ARRAY OF CHAR);
BEGIN
#ifdef MM2
  Addr[0]:= CADR(Path);
#else
  Addr[0]:= ADR(Path);
#endif
  crystal(81,0,1,1);
END ScrpWrite;

PROCEDURE ScrpClear;
#if ST
#if use_POSIX
VAR i   : CARDINAL;
    c   : Scraps;
    s   : Scrap;
    dir : PathName;
#endif
#endif
BEGIN
#if ST
  IF (Version() = 0220H) OR (Version() = 1042H) OR (Version() = 0399H) THEN
#else
  IF Version() >= 0220H THEN (* GEM 2.x, GEM 3.x *)
#endif
    crystal(82,0,1,0);
  ELSE
    (* clear directory *)
#if ST
#if use_POSIX
#warning ...using M2POSIX
    s:= ScrpRead(dir);

    IF s # NoScrap THEN
      i:= 0;
      WHILE dir[i] # 0C DO
        INC(i);
      END;

      IF dir[i - 1] # DIRSEP THEN
        dir[i]:= DIRSEP;
        dir[i + 1]:= 0C;
      END;

      FOR c:= ScCSV TO ScUSR DO
        strcat(ptr(dir),ptr(Types[c]));
        void(unlink(dir));
      END;
    END;
#else
    ;
#endif
#endif
  END;
END ScrpClear;

#if ST
BEGIN
  Types[ScCSV]:= "scrap.csv";
  Types[ScTXT]:= "scrap.txt";
  Types[ScGEM]:= "scrap.gem";
  Types[ScIMG]:= "scrap.img";
  Types[ScDCA]:= "scrap.dca";
  Types[ScDIF]:= "scrap.dif";
  Types[ScASC]:= "scrap.asc";
  Types[ScRTF]:= "scrap.rtf";
  Types[Sc1WP]:= "scrap.1wp";
  Types[ScWP]:= "scrap.wp";
  Types[ScTIF]:= "scrap.tif";
  Types[ScIFF]:= "scrap.iff";
  Types[ScEPS]:= "scrap.eps";
  Types[ScCVG]:= "scrap.cvg";
  Types[Sc14]:= "scrap.rsv";
  Types[ScUSR]:= "scrap.usr";
#endif
END ScrpMgr.
