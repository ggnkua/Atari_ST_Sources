#!/usr/bin/perl

@boot = (
0x60, 0x1c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x72, 0x1c, 0x62, 0x00, 0x02, 0x02, 0x01, 0x00,
0x02, 0x70, 0x00, 0xa0, 0x05, 0xf9, 0x05, 0x00, 0x09, 0x00, 0x02, 0x00, 0x00, 0x00
);

my $stage1prgfn = "temp/stage1.bin";
my $stage2prgfn = "temp/stage2.bin";
my $packedfn    = "temp/packed.n2b";
my $outfilefn   = "OUT.ST";
my $stage1, $stage2, $packed, $buffer;

open(FH, $stage1prgfn)  ||  die("unable to open " . $stage1prgfn . " for reading.");
binmode(FH);
read(FH, $stage1, -s FH);
close FH;
open(FH, $stage2prgfn)  ||  die("unable to open " . $stage2prgfn . " for reading.");
binmode(FH);
read(FH, $stage2, -s FH);
close(FH);
open(FH, $packedfn)  ||  die("unable to open " . $packedfn . " for reading.");
binmode(FH);
read(FH, $packed, -s FH);
close(FH);




$buffer = "";
foreach (@boot) {
    $buffer .= chr($_);
}

# append STAGE1.PRG
$buffer .= $stage1;

if (length($buffer) > 510) {
    die("$stage1prgfn is too big to fit in the boot sector.");
}

# complete up to 510 bytes
my $i;
for ($i=length($buffer); $i<510; $i++) {
    $buffer .= chr(0);
}

# make the boot sector executable
my $total;
$total = 0x1234;
for ($i=0; $i<510; $i+=2) {
    $total -= (ord(substr($buffer, $i, 1))<<8) + (ord(substr($buffer, $i+1, 1))) ;
    if ($total < 0) {
        $total += 65536;
    }
}
$buffer .= chr($total>>8);
$buffer .= chr($total&0xff);
#$buffer .= chr(0);
#buffer .= chr(0);



#print "total=$total\n";
#$total = 0;
#for ($i=0; $i<512; $i++) {
#    $total += ord(substr($buffer, $i, 1));
#}
#print "total=$total\n";exit;


# append STAGE2.PRG
$buffer .= $stage2;

# align to word boundary
if (1 == length($buffer) & 1) {
    $buffer .= chr(0);
}

# append packed.n2b
$buffer .= $packed;

for ($i=length($buffer); $i<368640*2; $i++) {
    $buffer .= chr(0);
}


open(FHW, ">" . $outfilefn)  ||  die("unable to open " . $outfilefn . " for writing.");
print FHW $buffer;
close(FHW);

print "file $outfilefn written, length: " . length($buffer) . "\n";


