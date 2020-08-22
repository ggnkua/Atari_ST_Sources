PROGRAM ftest;

        CONST
                a = 0.5;
                b = 7.0;

        VAR
                c:real;

{$I f68881.pas}

BEGIN
        mctest;
        writeln('a = ',a);
        writeln('b = ',b);
        writeln('-----------------------------------------------------------');
        writeln('Funktion:        Sollergebnis:         MC68881 Ergebnis:');

        c := sin(a);
        writeln('c = sin(a)       4.7942553860e-01      ',c);
        c := cos(a);
        writeln('c = cos(a)       8.7758256189e-01      ',c);
        c := tan(a);
        writeln('c = tan(a)       5.4630248984e-01      ',c);
        c := arcsin(a);
        writeln('c = arcsin(a)    5.2359788560e-01      ',c);
        c := arccos(a);
        writeln('c = arccos(a)    1.0471975512e+00      ',c);
        c := arctan(a);
        writeln('c = arctan(a)    4.6364760900e-01      ',c);
        c := arctan2(a,b);
        writeln('c = arctan2(a)   7.1307464785e-02      ',c);
        c := sinh(a);
        writeln('c = sinh(a)      5.2109530549e-01      ',c);
        c := cosh(a);
        writeln('c = cosh(a)      1.1276259652e+00      ',c);
        c := tanh(a);
        writeln('c = tanh(a)      4.6211715726e-01      ',c);
        c := arcsinh(a);
        writeln('c = arcsinh(a)   4.8121182506e-01      ',c);
        c := arccosh(b);
        writeln('c = arccosh(b)   2.6339157938e+00      ',c);
        c := arctanh(a);
        writeln('c = arctanh(a)   5.4930614433e-01      ',c);
        c := sqrt(a);
        writeln('c = sqrt(a)      7.0710678119e-01      ',c);
        c := exp(a);
        writeln('c = exp(a)       1.6487212707e+00      ',c);
        c := pow(a,b);
        writeln('c = pow(a,b)     7.8125000000e-03      ',c);
        c := exp2(a);
        writeln('c = exp2(a)      1.4142135624e+00      ',c);
        c := exp10(a);
        writeln('c = exp10(a)     3.1622776602e+00      ',c);
        c := ln(a);
        writeln('c = ln(a)       -6.9314718056e-01      ',c);
        c := log2(a);
        writeln('c = log2(a)     -1.0000000000e+00      ',c);
        c := log10(a);
        writeln('c = log10(a)    -3.0102999566e-01      ',c);
END.
