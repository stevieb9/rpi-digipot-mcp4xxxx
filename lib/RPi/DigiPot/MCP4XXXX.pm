package RPi::DigiPot::MCP4XXXX;

use warnings;
use strict;

our $VERSION = '0.01';

1;
__END__

=head1 NAME

RPi::DigiPot::MCP4XXXX - Interface to the MCP4xxxx series digital potentiometers
on the Raspbery Pi

=head1 DESCRIPTION

This distribution allows you to interface directly with the MCP41xxx and
MCP42xxx series digital potentiomenters attached to the SPI bus on the
Raspberry Pi.

The MCP41xxx units have a single built-in potentiometer, where the MCP42xxx
units have two.

Both series will operate on either 3.3V or 5V, as the potentiometers do not send
anything back to the Pi's GPIO.

=head1 SYNOPSIS

=head1 METHODS

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2017 Steve Bertrand.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

