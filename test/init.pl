use warnings;
use strict;

use RPi::DigiPot::MCP4XXXX;

my $p = RPi::DigiPot::MCP4XXXX->new(4, 0);

my $b1 = 0xFFFF;

$p->write($b1, 2);


