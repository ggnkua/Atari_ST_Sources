
#
# convert an xpm image to a FNT-txt file.
# variables below need to be adjusted.
#

my $num_in_row = 16;
my $width = 8;
my $height = 16;
my $x_offset = 2;
my $y_offset = 4;
my $delta_x = 11;  /* interval between glyphs */
my $delta_y = 3

# skip XPM header
<>;<>;<>;<>;<>;<>;

my $i = 0;
my $c = 0x80;

my @a = ();
while(<>) {
  s/^\"//;
  s/\".*$//;
  s/\+/X/g;
  chomp;
  $a[$i] = $_;
  $i++;
  if($i == $height + $delta_y) {
    for($u = 0 ; $u < $num_in_row ; $u++) {
      printf "char 0x%02x\n", $c;
      for($j = $y_offset ; $j < $y_offset + $height ; $j++) {
        print substr($a[$j], $u*($width+$delta_x) + $x_offset, $width), "\n";
      }
      print "endchar\n";
      $c++;
    }
    $i = 0;
  }
}
