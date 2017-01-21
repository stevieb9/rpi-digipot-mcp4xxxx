use warnings;
use strict;

use Inline 'Noclean';
use Inline 'C';

print 1;
__END__
__C__

#include <stdio.h>
#include <wiringPi.h>
#include <wiringPiSPI.h>
