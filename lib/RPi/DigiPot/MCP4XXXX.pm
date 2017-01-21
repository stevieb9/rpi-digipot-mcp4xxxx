package RPi::DigiPot::MCP4XXXX;

use warnings;
use strict;

our $VERSION = '2.36.1';

require XSLoader;
XSLoader::load('RPi::MCP4XXXX', $VERSION);

use RPi::WiringPi::Constant qw(:all);
use WiringPi::API qw(:all);

sub new {
    if (@_ !=3 && @_ != 4){
        die "new() requires \$cs and \$channel at minimum\n";
    }

    my ($class, $cs, $channel, $speed) = @_;

    my $self = bless {}, $class;
    $self->cs($cs)

    wiringPiSPISetup(
        $self->channel($channel),
        $self->speed($speed)
    );

    return $self;
}
sub write {
    my ($self) = @_;
}
sub channel {
    my ($self, $chan) = @_;
    $self->{channel} = $chan if defined $chan;
    return $self->{channel};
}
sub cs {
    my ($self, $pin) = @_;

    if ($pin < 0 || $pin > 63){
        die "cs() param must be a valid GPIO pin number\n";
    }

    $self->{cs} = $pin if defined $pin;

    if (! defined $self->{cs}){
        die "cs() can't continue, we're not configured with a pin\n";
    }

    return $self->{cs};
}
sub speed {
    my ($self, $speed) = @_;
    $self->{speed} = $speed if defined $speed;
    $self->{speed} = 1000000 if ! defined $self->{speed}; # 1 MHz
    return $self->{speed};
}

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

This software requires L<wiringPi|http://wiringpi.com> to be installed, as we
use its L<SPI library|http://wiringpi.com/reference/spi-library> to communicate
to the potentiometer over the SPI bus.

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

