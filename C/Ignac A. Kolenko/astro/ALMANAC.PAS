
                     {   A L M A N A C . P A S   }

{This is the include file for the support routines for the Almanac main menu
    choice which contains the Sky_Plot and Solar System sub menu choices.
    The routines presented here are based on spherical trigonometry
    formulas such as those found in the book PRACTICAL ASTRONOMY WITH YOUR
    CALCULATOR, by Peter Duffet-Smith, (a good reference book for astronomical
 calculations), and other formulas commonly found in the science of Astronomy.}

function h_m_s_to_decimal (h,m,s : integer) : real ;  {convert h mm ss to h.dd}

var
   x : real ;                               {temporary variable for conversion}

begin
   x := h ;
   x := x + (m / 60.0) ;                                      {convert minutes}
   x := x + (s / 3600.0) ;                                    {convert seconds}
   h_m_s_to_decimal := x ;
end ;  {h_m_s_to_decimal}


function d_m_s_to_decimal (d,m,s : integer) : real; {convert deg mm ss to d.dd}

var
   x : real ;                               {temporary variable for conversion}

begin
   x := d ;
   x := x + (m / 60.0) ;                               {convert minutes of arc}
   x := x + (s / 3600.0) ;                             {convert seconds of arc}
   d_m_s_to_decimal := x ;
end ;  {d_m_s_to_decimal}



function Rad_to_Deg (radians : real) : real ;      {convert radians to degrees}

const
   factor  = 57.29577951 ;                                 {degrees per radian}

begin
   Rad_to_Deg := radians * factor ;
end ;  {Rad_to_Deg}



function Deg_to_Rad (degrees : real) : real ;      {convert degrees to radians}

const
   factor  = 57.29577951 ;                                 {degrees per radian}

begin
   Deg_to_Rad := degrees / factor ;
end ;  {Deg_to_Rad}



function Julian_Day (y : integer ;                       {calculate Julian Day}
                     m : integer ;
                     d : integer ) : real ;
const
   jdconst = 1720994.5 ;                             {julian day initial value}

var
   a  : integer ;                             {temporary values in calculation}
   b  : integer ;
   c  : long_integer ;
   e  : integer ;

begin
   if m < 3 then begin                        {compensate in case of leap year}
      y := y-1 ;
      m := m + 12 ;
   end ;
   a  := (y div 100) ;
   b  := 2 - a + (a div 4) ;
   c  := long_trunc (365.25 * y) ;     {calculate number of days since 4713 BC}
   e  := trunc (30.6001 * (m+1)) ;
   Julian_Day := b + c + d + e + jdconst ;
end ;  {Julian_Day}



function Obliquity (JD : real) : real ;       {calculate obliquity of ecliptic}

const
   start    = 2415020.0 ;               {obliquity constants to reduce date to}
   cent     = 36525.0 ;                                       {days since 1900}
   arcsecs  = 3600.0 ;
   original  = 23.452294 ;

var
   ob, delteps         : real ;                           {temporary variables}

begin
   JD := JD - start ;                               {calculate days since 1900}
   ob := JD / cent ;
   delteps := 46.845 * ob + 0.0059 * ob * ob + 0.00181 * ob * ob * ob ;
   delteps := delteps / arcsecs ;
   ob := original - delteps ;
   Obliquity := Deg_to_Rad (ob) ; {return the angle of inclination of ecliptic}
end ;  {Obliquity}



procedure since_epoch ;    {calculate number of days since standard epoch 1980}

begin
   dday    := Julian_Day (year, month, day) ;          {get current Julian day}
   epsilon := Obliquity (dday) ;                          {calculate obliquity}
   dd      := Julian_Day (1980, 1, 0) ;         {get Julian day of Jan 0, 1980}
   dday    := dday - dd ;
   dday    := dday + (t_univ / 24.0) ;               {add hours from main menu}
end ;  {since_epoch}


{NOTE:  all trig functions defined here work in radians, as do the built in
        functions in Personal Pascal}

function ArcSin (radians : real) : real ;          {calculate inverse sin of x}

begin
   if radians > 1.0 then radians :=   0.999999999 ;
   if radians < -1.0 then radians := -0.999999999 ;
   ArcSin := ArcTan (radians / Sqrt (-radians * radians + 1.0)) ;
end ;  {ArcSin}



function ArcCos (radians : real) : real ;          {calculate inverse cos of x}

const
   cosconst = 1.5707633 ;                     {compensate for phase difference}

begin
   if radians > 1.0 then radians :=   0.999999999 ;
   if radians < -1.0 then radians := -0.999999999 ;
   ArcCos := - ArcTan (radians / Sqrt (-radians * radians + 1.0)) + cosconst ;
end ;  {ArcSin}



function Tan (radians : real) : real ;                     {calculate tan of x}

var x : real ;                                                  {temp variable}

begin
   x := Cos (radians) ;
   if (abs (x) < 1.0e-11) and (x > 0.0) then x :=  1.0e-11 ;
   if (abs (x) < 1.0e-11) and (x < 0.0) then x := -1.0e-11 ;
   Tan := Sin (radians) / x ;
end ;  {Tan}



function Hours (x : real) : integer ;{calculate integer hrs from decimal hours}

begin
   Hours := trunc (x) ;
end ;  {Hours}



function Minutes (x : real) : integer ;{calculate integer min from decimal hrs}

begin
   Minutes := trunc ((x - Hours(x)) * 60) ;
end ;  {Minutes}



function Seconds (x : real) : integer ;{calculate integer sec from decimal hrs}

begin
   Seconds := round ((x - Hours(x) - Minutes(x) / 60) * 3600) ;
end ;  {Seconds}



function Kepler (M   : real ;             {solve Kepler's equation iteratively}
                 ecc : real) : real ;

const
   error = 1E-9 ;         {error threshold for bail out from iterative routine}

var
   E     : real ;                                {solution of Kepler's routine}
   de    : real ;            {difference between old and new iterative results}
   delta : real ;                                     {a new guess at solution}

begin
   E  := M ;
   repeat                          {loop until minimum error threshold reached}
      delta := E - ecc * Sin (E) - M ;
      de    := delta / (1 - ecc * cos (E)) ;
      E     := E - de ;
   until (Abs(delta) <= error) ;
   Kepler := E ;
end ;  {Kepler}



function Ambiguity (angle : real ; {compensate for ARCTAN function ambiguities}
                    x     : real ;
                    y     : real) : real ;
var
   a : real ;

procedure Adjust_Up ;                     {add 180 degrees to calculated angle}

  begin
     angle := angle + pi ;
  end ;  {Adjust_Up}

procedure Adjust_Down ;            {subtract 180 degrees from calculated angle}

   begin
      angle := angle - pi ;
   end ;  {Adjust_Down}

function First_Quad (x : real) : boolean ;  {check to see if in first quadrant}

   begin
      if ((a >= 0.0) and (a < 90.0)) or ((a >= -360.0) and (a < -270.0)) then
         First_Quad := TRUE
      else First_Quad := FALSE ;
   end ;  {First_Quad}

function Second_Quad (x : real) : boolean ;{check to see if in second quadrant}

   begin
      if ((a >= 90.0) and (a < 180.0)) or ((a >= -270.0) and (a < -180.0)) then
         Second_Quad := TRUE
      else Second_Quad := FALSE ;
   end ;  {Second_Quad}

function Third_Quad (x : real) : boolean ;  {check to see if in third quadrant}

   begin
      if ((a >= 180.0) and (a < 270.0)) or ((a >= -180.0) and (a < -90.0)) then
         Third_Quad := TRUE
      else Third_Quad := FALSE ;
   end ;  {Third_Quad}

function Fourth_Quad (x : real) : boolean ;{check to see if in fourth quadrant}

   begin
      if ((a >= 270.0) and (a <= 360.0)) or ((a >= -90.0) and (a <= -0.0)) then
         Fourth_Quad := TRUE
      else Fourth_Quad := FALSE ;
   end ;  {Fourth_Quad}

begin
   a := Rad_to_Deg (angle) ;   {convert radians to degrees: easier to compare!}
   if ((First_Quad(a)) and (x<0.0) and (y<0.0)) then Adjust_Up {do adjustments}
   else if ((Second_Quad(a)) and (x>0.0) and (y<0.0)) then Adjust_Up
     else if ((Third_Quad(a)) and (x>0.0) and (y>0.0)) then Adjust_Down
      else if ((Fourth_Quad(a)) and (x<0.0) and (y>0.0)) then Adjust_Down ;
   if angle < 0 then angle := angle + twopi ; {reduce to 0 to 360 degree range}
   if angle > twopi then angle := angle - twopi ;
   Ambiguity := angle ;
end ;  {Ambiguity}


{for the next four formulas, pass either Ecliptic Latitude, Ecliptic Longitude,
 or Right Ascension, Declination, and the obliquity for the current date,
 according to which function you want done: ie) if you want to get the
 declination, simply call Convert_Dec with the ecliptic latitude, longitude and
 the current obliquity, and the function will return the Declination in deg.}


function Convert_RA (la : real ;       {convert ecliptic co-ords to equatorial}
                     be : real ;
                     obliq : real ) : real ;
var
   x,y,ra  : real ;                        {temporary variables in calculation}

begin
   y  := Sin (la) * Cos (obliq) - Tan (be) * Sin (obliq) ;      {calculate the}
   x  := Cos (la) ;                       {projections and convert to an angle}
   ra := ArcTan (y / x) ;
   ra := Ambiguity (ra, x, y) ;            {compensate for ambiguity of ARCTAN}
   Convert_RA := Rad_to_Deg (ra) / 15.0 ;{divide by 15 since 24 hrs in 360 deg}
end ;  {Convert_RA}



function Convert_Dec (la : real ;      {convert ecliptic co-ords to equatorial}
                      be : real ;
                      obliq : real) : real ;
var
   de : real ;                                             {temporary variable}

begin
   de := Sin (be) * Cos (obliq) + Cos (be) * Sin (obliq) * sin (la) ;
   de := ArcSin (de) ;                     {more spherical trig formulas!!!!!!}
   Convert_Dec := Rad_to_Deg (de) ;
end ;  {Convert_Dec}


{the following functions are co-ordinate conversion routines, following normal
 sherical trigonometry rotation and translation formulas. The formulas need not
 concern the amateur astronomer, just the result of the formulas!}


function Calc_b (year : integer) : real ;  {calculate factor for sidereal time}

var
   JD, s, t, r, u, b   : real ;                 {temporary variables for calcs}

begin
   JD:= Julian_Day (year,1,0) ;  {calculate number of days since start of 1900}
   s := JD - 2415020.0 ;
   t := s / 36525.0 ;                                     {number of centuries}
   r := 6.6460656 + (2400.051262 * t) + (0.00002581 * t * t) ;
   u := r - (24.0 * (year - 1900)) ;
   b := 24.0 - u ;              {yearly constant for sidereal time conversions}
   Calc_b := b ;
end ;  {Calc_b}


function Convert_Loc (t : real) : real ;   {convert universal time to sidereal}

const
   a  = 0.0657098 ;                                 {time conversion constants}
   c  = 1.002738  ;

var
   b, days, t0, gt    : real ;                            {temporary variables}

begin
   b  := Calc_b (year) ;                        {get other conversion constant}
   days := Julian_Day (year, month, day) - Julian_Day (year, 1, 0) ;
   t0 := (days * a) - b ;                       {calculation opposite of above}
   t  := t * c ;                                                   {function!!}
   gt := t + t0 ;
   if gt > 24.0 then gt := gt - 24.0 ;
   if gt <  0.0 then gt := gt + 24.0 ;
   Convert_Loc := gt ;
end ;  {Convert_Loc}


function Calc_HA (t,ra : real) : real ;        {calculate hour angle of object}

var
   lst, H : real ;                                        {temporary variables}

begin
   t := Convert_Loc (t) ;                           {get current sidereal time}
   lst := t - (longitude / 15.0) ;       {hour angle is angle between sidereal}
   H := lst - ra ;                            {time and star's right ascension}
   if H < 0.0 then H := H + 24.0 ;
   if H > 24.0 then H := H - 24.0 ;
   Calc_HA := H ;
end ;  {Calc_HA}


function Calc_Alt (t,dec,ra : real) : real ;     {calculate horizontal co-ords}

var
   a,ha,l : real ;                                        {temporary variables}

begin
   l := Deg_to_Rad (latitude) ;            {get observer's latitude in radians}
   ha := Calc_HA (t,ra) ;                                      {get hour angle}
   ha := ha * 15.0 ;
   ha := Deg_to_Rad (ha) ; dec := Deg_to_Rad (dec) ;
   a  := ArcSin ((Sin (dec) * Sin (l)) + (Cos (dec) * Cos (l) * Cos (ha))) ;
   a  := Rad_to_Deg (a) ;                           {do co-ordinate conversion}
   Calc_Alt := a ;
end ;  {Calc_Alt}


function Calc_Azi (t,dec,ra : real) : real ;     {calculate horizontal co-ords}

var
   a,aa,ha,l : real ;                                     {temporary variables}

begin
   l := Deg_to_Rad (latitude) ;                       {get observer's latitude}
   ha := Calc_HA (t,ra) ;                                      {get hour angle}
   ha := ha * 15.0 ;  ha := Deg_to_Rad (ha) ; dec := Deg_to_Rad (dec) ;
   a  := ArcSin (Sin (dec) * Sin (l)+Cos (dec) * Cos (l) * Cos (ha)) ;
   aa := ArcCos ((Sin (dec) - Sin (l) * Sin (a)) / (Cos (l) * Cos (a))) ;
   if Sin(ha) >= 0.0 then aa := twopi - aa ;  {compensate for ARCSIN ambiguity}
   aa := Rad_to_Deg (aa) ;
   Calc_Azi := aa ;
end ;  {Calc_Azi}


procedure enter_data ; {convert dialog strings to integer and real data to be
                                                              used by formulas}

var
   a,b,c   : integer ;                     {temporary variables for conversion}
   s       : string[255] ;

begin
   s := Copy (latitude_str,1,2) ; a:=round (Val (s)) ; if a > 89 then a:= 89 ;
   s := Copy (latitude_str,3,2) ; b:=round (Val (s)) ; if b > 59 then b:= 59 ;
   s := Copy (latitude_str,5,2) ; c:=round (Val (s)) ; if c > 59 then c:= 59 ;
   latitude :=  d_m_s_to_decimal (a,b,c) ;    {convert latitude string to real}
   if latitude > 89.5 then latitude := 89.5 ;    {check if too close to poles!}
   s := Copy (latitude_str,7,1) ;
   if s = 'S' then latitude := - latitude ;               {negate if necessary}

   s := Copy (longitude_str,1,3); a:=round (Val (s)) ; if a> 179 then a := 179;
   s := Copy (longitude_str,4,2); b:=round (Val (s)) ; if b > 59 then b := 59 ;
   s := Copy (longitude_str,6,2); c:=round (Val (s)) ; if c > 59 then c := 59 ;
   longitude := d_m_s_to_decimal (a,b,c) ;   {convert longitude string to real}
   s := Copy (longitude_str,8,1) ;
   if s = 'E' then longitude := - longitude ;             {negate if necessary}

   s := Copy(date_str,1,4); year:=round (Val(s)); if year>2100 then year:=2100;
   s := Copy(date_str,5,2);month:=round (Val (s));if month>12 then month := 12;
   s := Copy(date_str,7,2); day:=round (Val (s)); if day > 31 then day := 31 ;
   if month = 0 then month := 1 ;     if day = 0 then day := 1 ;   {month, day}

   s := Copy (time_str,1,2); a :=round (Val (s)) ; if a > 23 then a := 23 ;
   s := Copy (time_str,3,2); b :=round (Val (s)) ; if b > 59 then b := 59 ;
   c := 0 ;  t_univ := h_m_s_to_decimal (a,b,c) ;    {convert to decimal hours}
end ;  {enter_data}



procedure calc_data ;                        {calculate RA and Dec for objects}

begin
   RA  := Convert_RA  (la, be, epsilon) ;
   Dec := Convert_Dec (la, be, epsilon) ;
end ;  {calc_data}



procedure Sun ;                                        {calculate sun's values}

const
   eccent   = 0.016718 ;                        {eccentricity of earth's orbit}
   r_nought = 149598500 ;                                    {average distance}
   yr_const = 0.985647332 ;                           {year multiplying factor}
   theta_0  = 0.533128 ;                          {average angular size of sun}

var
   epsil_g  : real ;             {temporary variables}  {eclip. longitude 1980}
   omega_g  : real ;                               {eclip longitude of perigee}
   N        : real ;
   M        : real ;                                    {mean anomaly of orbit}
   E        : real ;                                 {solution of Kepler's Eqn}
   v        : real ;                                    {true anomaly of orbit}

begin                                           {do major orbital calculations}
   epsil_g := Deg_to_Rad (278.833540) ;
   omega_g := Deg_to_Rad (282.596403) ;
   enter_data ;
   since_epoch ;
   N  := yr_const * dday ;
   while (N > 360.0) do N := N - 360.0 ;        {these while statements reduce}
   while (N < 0.0) do N := N + 360.0 ;          {to 0-360 degree range!!!!!!!!}
   N  := Deg_to_Rad (N) ;
   M  := N + epsil_g - omega_g ;                       {calculate Mean anomaly}
   if M < 0 then M := M + twopi ;
   E  := Kepler (M,eccent) ;       {solution to Kepler's eqn (better accuracy)}
   v  := (2.0 * ArcTan ((Tan (E/2.0)) * Sqrt ((1+eccent)/(1-eccent)))) ;
   la := v + omega_g ;                    {calculate ecliptic longitude of sun}
   if la < 0 then la := la + twopi ;
   if la > twopi then la := la - twopi ;
   be := 0.0 ;      {ecliptic latitude of sun is 0 since sun defines ecliptic!}
   calc_data ;
end ;  {Sun}


procedure Planets ;                              {calculate planet information}

const
   e_ep       = 1.724970684 ;                      {earth's longitude at epoch}
   e_om       = 1.790645033 ;                 {earth's longitude at perihelion}
   e_ee       = 0.016718 ;                      {earth's eccentricity of orbit}

var
   Np         : real ;             {temporary variables for planet calculation}
   Mp         : real ;                                           {mean anomaly}
   ll         : real ;                                 {heliocentric longitude}
   vp         : real ;                                           {true anomaly}
   lr         : real ;                                {radius vector of planet}
   Ne         : real ;              {temporary variables for earth calculation}
   Me         : real ;                                           {mean anomaly}
   bl         : real ;                                 {heliocentric longitude}
   ve         : real ;                                           {true anomaly}
   br         : real ;                                {radius vector for earth}
   phi        : real ;                                      {angle conversions}
   y, x       : real ;
   aprime, lprime, rprime     : real ;          {temporary latitude, longitude}
   ba         : real ;                           {temporary ecliptic longitude}


begin                                           {do major orbital calculations}
   enter_data ;
   since_epoch ;
   Np := (360.0 / 365.2422) * (dday / tp[p]) ;
   while Np > 360.0 do Np := Np - 360.0 ;
   while Np <   0.0 do Np := Np + 360.0 ;
   Np := Deg_to_Rad (Np) ;
   Mp := Np + ep[p] - om[p] ;
   ll := Np + 2.0 * ee[p] * Sin (Mp) + ep[p] ;
   while ll > twopi do ll := ll - twopi ;
   while ll <   0.0 do ll := ll + twopi ;
   vp := ll - om[p] ;
   lr := (ax[p] * (1.0 - ee[p] * ee[p])) / (1.0 + ee[p]* Cos (vp)) ;

   Ne := 0.985607907 * dday ;                 {do earth's orbital calculations}
   while Ne > 360.0 do Ne := Ne - 360.0 ;
   while Ne <   0.0 do Ne := Ne + 360.0 ;
   Ne := Deg_to_Rad (Ne) ;
   Me := Ne + e_ep - e_om ;
   bl := Ne + 2.0 * e_ee * Sin (Me) + e_ep ;
   while bl > twopi do bl := bl - twopi ;
   while bl <   0.0 do bl := bl + twopi ;
   ve := bl - e_om ;
   br := (1.0 - e_ee * e_ee) / (1.0 + e_ee * Cos (ve)) ;

   phi := ArcSin (Sin (ll - no[p]) * Sin (ii[p])) ;     {find ecliptic co-ords}
   y := Sin (ll - no[p]) * Cos (ii[p]) ;
   x := Cos (ll - no[p]) ;
   aprime := ArcTan (y / x) ;
   aprime := Ambiguity (aprime, x, y) ;
   lprime := aprime + no[p] ;
   rprime := lr * Cos (phi) ;                              {ecliptic longitude}
   if p < 4 then begin      {calculated differently for inner or outer planets}
      ba := ArcTan ((rprime*Sin(bl-lprime))/(br-rprime*Cos(bl-lprime))) ;
      la := pi + bl + ba ;
      if la <   0.0 then la := la + twopi ;
      if la > twopi then la := la - twopi ;
      be := ArcTan ((rprime*Tan(phi)*Sin(la-lprime))/(br*Sin(lprime-bl))) ;
   end
   else begin
      la := ArcTan ((br*Sin(lprime-bl))/(rprime-br*Cos(lprime-bl))) + lprime ;
      if la <   0.0 then la := la + twopi ;
      if la > twopi then la := la - twopi ;
      be := ArcTan ((rprime*Tan(phi)*Sin(la-lprime))/(br*Sin(lprime-bl))) ;
   end ;
   calc_data ;
end ;  {Planets}


procedure Comets ;                         {calculate information about comets}

const
   e_ep       = 1.724970684 ;      {same earth constants as for planet section}
   e_om       = 1.790645033 ;
   e_ee       = 0.016718 ;

var
   years          : real ;          {number of years since perihelion of comet}
   Mc             : real ;                              {mean anomaly of comet}
   E              : real ;                      {solution to Kepler's equation}
   v              : real ;                                       {true anomaly}
   ll             : real ;                             {heliocentric longitude}
   lr             : real ;                                      {radius vector}
   phi            : real ;                         {angle conversion variables}
   x,y            : real ;
   aprime         : real ;                                   {temporary angles}
   lprime         : real ;
   rprime         : real ;
   Ne             : real ;     {corresponding variables for earth calculations}
   Me, bl, ve, br : real ;

begin                                           {do major orbital calculations}
   enter_data ;
   since_epoch ;                              {calculate # years since year of}
   if month > 2 then begin                             {the comet's perihelion}
      years := month + 1 ;
      years := trunc (years * 30.6) - 63.0 + day ;
   end
   else begin
      years := month - 1 ;
      years := trunc ((years * 63.0) / 2.0) + day ;
   end ;
   years := (years - 1.0) / 365.25 ;
   years := (year + years) - c_pe[c] ;
   Mc := 360.0 * years / c_tp[c] ;
   while Mc > 360.0 do Mc := Mc - 360.0 ;
   while Mc <   0.0 do Mc := Mc + 360.0 ;
   Mc := Deg_to_Rad (Mc) ;
   E  := Kepler (Mc, c_ee[c]) ;
   v  := 2.0* ArcTan (tan (E / 2.0) * sqrt ((1.0+ c_ee[c]) / (1.0- c_ee[c]))) ;
   ll := v + c_pl[c] ;
   lr := (c_aa[c] * (1.0 - c_ee[c] * c_ee[c])) / (1.0 + c_ee[c] * Cos (v)) ;

   phi := ArcSin (Sin (ll - c_no[c]) * Sin (c_ii[c])) ;
   y   := Sin (ll - c_no[c]) * Cos (c_ii[c]) ;
   x   := Cos (ll - c_no[c]) ;

   aprime := ArcTan (y / x) ;
   aprime := Ambiguity (aprime,x,y) ;
   lprime := aprime + c_no[c] ;
   rprime := lr * Cos (phi) ;

   Ne := 0.985607907 * dday ;                       {do calculations for earth}
   while Ne > 360.0 do Ne := Ne - 360.0 ;
   while Ne <   0.0 do Ne := Ne + 360.0 ;
   Ne := Deg_to_Rad (Ne) ;
   Me := Ne + e_ep - e_om ;
   bl := Ne + 2.0 * e_ee * Sin (Me) + e_ep ;
   while bl > twopi do bl := bl - twopi ;
   while bl <   0.0 do bl := bl + twopi ;
   ve := bl - e_om ;
   br := (1.0 - e_ee * e_ee) / (1.0 + e_ee * Cos (ve)) ;

   if rprime < br then                                 {within orbit of earth?}
      la :=pi+ bl+ ArcTan ((rprime*Sin(bl-lprime))/ (br-rprime*Cos(bl-lprime)))
   else                                 {no, therefore do outer planet formula}
      la :=lprime+ ArcTan((br*Sin(lprime-bl))/(rprime-br*Cos(lprime-bl))) ;
   be := ArcTan ((rprime* Tan(phi)* Sin (la-lprime)) / (br* Sin (lprime-bl))) ;
   calc_data ;
end ;  {Comets}



procedure Moon ;                                {calculate information on moon}

const
   eccent   = 0.016718 ;                                 {earth's eccentricity}
   r_nought = 149598500 ;                          {average distance earth-sun}
   yr_const = 0.985647332 ;                        {solar year constant factor}
   m_l0     = 1.13403578 ;                              {moon's longitude 1980}
   m_p0     = 6.0978848 ;                      {moon's longitude at perihelion}
   m_n0     = 2.652035286 ;                    {longitude at the node of epoch}
   m_i      = 0.089804101 ;                                {moon's inclination}
   m_e      = 0.0549 ;                                    {moon's eccentricity}
   m_th     = 9.042550855E-3 ;                           {angular size of moon}

var
   epsil_g              : real ;        {temporary solar calculation variables}
   omega_g              : real ;           {needed for some lunar calculations}
   N, M, E, v, lsun, ll : real ;
   mm, bn, ev, bc, ae, a3, mmprime, ec, a4, lprime, bv : real ;
   llprime, bnprime, aprime  : real ;              {angle conversion variables}
   x,y                  : real ;


begin                                           {do major orbital calculations}
   enter_data ;
   since_epoch ;
   epsil_g := Deg_to_Rad (278.833540) ;
   omega_g := Deg_to_Rad (282.596403) ;
   N  := yr_const * dday ;
   while (N > 360.0) do N := N - 360.0 ;
   while (N < 0.0) do N := N + 360.0 ;
   N  := Deg_to_Rad (N) ;
   M  := N + epsil_g - omega_g ;
   if M < 0 then M := M + twopi ;
   E  := Kepler (M,eccent) ;
   v  := (2.0 * ArcTan ((Tan (E/2.0)) * Sqrt ((1+eccent)/(1-eccent)))) ;
   la := v + omega_g ;
   if la < 0 then la := la + twopi ;
   if la > twopi then la := la - twopi ;
   lsun := la ;
   ll := Deg_to_Rad (13.1763966 * dday) + m_l0 ;
   while ll > twopi do ll := ll - twopi ;
   while ll <   0.0 do ll := ll + twopi ;
   mm := ll - Deg_to_Rad (0.1114041 * dday) - m_p0 ;
   while mm > twopi do mm := mm - twopi ;
   while mm <   0.0 do mm := mm + twopi ;
   bn := m_n0 - Deg_to_Rad (0.0529539 * dday) ;
   while bn > twopi do bn := bn - twopi ;
   while bn <   0.0 do bn := bn + twopi ;
   bc := ll - la ;
   ev := Deg_to_Rad (1.2739) * Sin (2.0 * bc - mm) ;
   ae := Deg_to_Rad (0.1858) * Sin (M) ;
   a3 := Deg_to_Rad (0.37) * Sin (M) ;
   mmprime := mm + ev - ae - a3 ;
   ec := Deg_to_Rad (6.2886) * Sin (mmprime) ;
   a4 := Deg_to_Rad (0.214) * Sin (2.0 * mmprime) ;
   lprime := ll + ev + ec - ae + a4 ;
   bv := Deg_to_Rad (0.6583) * Sin (2.0 * (lprime - la)) ;
   llprime := lprime + bv ;
   bnprime := bn - (Deg_to_Rad (0.16) * Sin (M)) ;
   y := Sin (llprime - bnprime) * Cos (m_i) ;
   x := Cos (llprime - bnprime) ;
   aprime := ArcTan (y / x) ;
   aprime := Ambiguity (aprime, x, y) ;
   la := aprime + bnprime ;
   be := ArcSin (Sin (llprime - bnprime) * Sin (m_i)) ;
   calc_data ;
end ;  {Moon}




