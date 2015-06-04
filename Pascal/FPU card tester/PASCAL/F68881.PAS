{ f68881.pas - Personal Pascal GEM library MC68881 functions. }

FUNCTION exp2(i:real):real;             { 2^i }
EXTERNAL;

FUNCTION exp10(i:real):real;            { 10^i }
EXTERNAL;

FUNCTION log2(i:real):real;             { log zur Basis 2 }
EXTERNAL;

FUNCTION log10(i:real):real;            { log zur Basis 10 }
EXTERNAL;

FUNCTION pow(i,j:real):real;            { i^j }
EXTERNAL;

FUNCTION tan(i:real):real;              { tan(i) }
EXTERNAL;

FUNCTION arcsin(i:real):real;           { arcsin(i) }
EXTERNAL;

FUNCTION arccos(i:real):real;           { arccos(i) }
EXTERNAL;

FUNCTION arctan2(i,j:real):real;        { arctan2(i/j) }
EXTERNAL;

FUNCTION sinh(i:real):real;             { sinh(i) }
EXTERNAL;

FUNCTION cosh(i:real):real;             { cosh(i) }
EXTERNAL;

FUNCTION tanh(i:real):real;             { tanh(i) }
EXTERNAL;

FUNCTION arcsinh(i:real):real;          { arcsinh(i) }
EXTERNAL;

FUNCTION arccosh(i:real):real;          { arccosh(i) }
EXTERNAL;

FUNCTION arctanh(i:real):real;          { arctanh(i) }
EXTERNAL;

PROCEDURE mctest;                       { MC68881 test und init }
EXTERNAL;
