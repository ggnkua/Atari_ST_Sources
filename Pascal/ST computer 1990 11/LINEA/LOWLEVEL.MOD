IMPLEMENTATION MODULE LowLevelLineA;

FROM SYSTEM IMPORT VAL, REG, INLINE, ADDRESS;

CONST RegD0 =  0;
      RegA1 =  9;
      RegA2 = 10;

BEGIN
  INLINE (0A000H);
  LineAVars     := VAL(ADDRESS,REG(RegD0));
  SysFontTable  := VAL(ADDRESS,REG(RegA1));
  LineARoutines := VAL(ADDRESS,REG(RegA2));
END LowLevelLineA.
