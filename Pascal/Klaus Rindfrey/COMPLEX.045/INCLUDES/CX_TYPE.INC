{ Typdefinitionen fÅr COMPLEX.LIB bzw. CX_LIB.DBG. Dimensionen von }
{ Vektoren und Matrizen dÅrfen verÑndert werden. }

      cx_adr = Long_Integer;   { FÅr Adressen komplexer Zahlen. }

      cx_vektor = ARRAY[1..4] OF cx_adr;
      cx_mat    = ARRAY[1..3,1..3] OF cx_adr;
      cx_mat1   = ARRAY[1..i1,1..j1] OF cx_adr;
      cx_mat2   = ARRAY[1..i2,1..j2] OF cx_adr;
      cx_mat3   = ARRAY[1..i1,1..j2] OF cx_adr;
