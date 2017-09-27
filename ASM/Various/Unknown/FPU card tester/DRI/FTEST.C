/*
 *
 * Dieses Programm dient zum Test der Funktionen, die Åber
 * den MC68881 Koprozessor verfÅgbar sind
 *
*/

#include <math.h>

main()
{
        double a,b,c;
        int i;

        mctest();
        a = .5;
        b = 7;
        printf("a = %20.15e \n",a);
        printf("b = %20.15e \n",b);
        printf("Funktion:          Sollergebnis:           MC68881 Ergebnis:  \n");
        printf("--------------------------------------------------------------\n");
        c = a + b;
        printf("c = a+b            7.500000000000000e00    %20.15e \n",c);
        c = a - b;
        printf("c = a-b           -6.500000000000000e00    %20.15e \n",c);
        c = a * b;
        printf("c = a*b            3.500000000000000e00    %20.15e \n",c);
        c = a / b;
        printf("c = a/b            7.142857142857142e-02   %20.15e \n",c);
        c = sin(a);
        printf("c = sin(a)         4.794255386042030e-01   %20.15e \n",c);
        c = cos(a);
        printf("c = cos(a)         8.775825618903727e-01   %20.15e \n",c);
        c = tan(a);
        printf("c = tan(a)         5.463024898437904e-01   %20.15e \n",c);
        c = asin(a);
        printf("c = asin(a)        5.235987755982989e-01   %20.15e \n",c);
        c = acos(a);
        printf("c = acos(a)        1.047197551196598e00    %20.15e \n",c);
        c = atan(a);
        printf("c = atan(a)        4.636476090008060e-01   %20.15e \n",c);
        c = atan2(a,b);
        printf("c = atan2(a,b)     7.130746478529031e-02   %20.15e \n",c);
        c = sinh(a);
        printf("c = sinh(a)        5.210953054937474e-01   %20.15e \n",c);
        c = cosh(a);
        printf("c = cosh(a)        1.127625965206381e00    %20.15e \n",c);
        c = tanh(a);
        printf("c = tanh(a)        4.621171572600097e-01   %20.15e \n",c);
        c = asinh(a);
        printf("c = asinh(a)       4.812118250596035e-01   %20.15e \n",c);
        c = acosh(b);
        printf("c = acosh(b)       2.633915793849634e00    %20.15e \n",c);
        c = atanh(a);
        printf("c = atanh(a)       5.493061443340549e-01   %20.15e \n",c);
        c = sqrt(a);
        printf("c = sqrt(a)        7.071067811865475e-01   %20.15e \n",c);
        c = exp(a);
        printf("c = exp(a)         1.648721270700128e00    %20.15e \n",c);
        c = pow(a,b);
        printf("c = pow(a,b)       7.812500000000000e-03   %20.15e \n",c);
        c = exp2(a);
        printf("c = exp2(a)        1.414213562373095e00    %20.15e \n",c);
        c = exp10(a);
        printf("c = exp10(a)       3.162277660168379e00    %20.15e \n",c);
        c = log(a);
        printf("c = log(a)        -6.931471805599453e-01   %20.15e \n",c);
        c = log2(a);
        printf("c = log2(a)       -1.000000000000000e00    %20.15e \n",c);
        c = log10(a);
        printf("c = log10(a)      -3.010299956639812e-01   %20.15e \n",c);
}

