package RPi::DigiPot::MCP4XXXX;

use warnings;
use strict;

our $VERSION = '2.36.1';

require XSLoader;
XSLoader::load('RPi::DigiPot::MCP4XXXX', $VERSION);

use RPi::WiringPi::Constant qw(:all);
use WiringPi::API qw(:all);

sub new {
    if (@_ !=3 && @_ != 4){
        die "new() requires \$cs and \$channel at minimum\n";
    }

    my ($class, $cs, $channel, $speed) = @_;

    my $self = bless {}, $class;
    $self->cs($cs);


#    setup(
        $self->channel($channel),
        $self->speed($speed);
#    );

    return $self;
}
sub write {
    my ($self, $buf, $len) = @_;

    dpot_write($self->channel, $buf, $len);
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

=head1 TECHNICAL INFORMATION

=head2 OVERVIEW

The MCP4xxxx series digital potentiometers operate as follows:

    - CS pin goes LOW, signifying data is about to be sent
    - exactly 16 bits are sent over SPI to the digipot (first 8 bits for control
      second 8 bits for data)
    - CS pin goes HIGH, signifying communication is complete

There must be exactly 16 bits of data clocked in, or the commands and data will
be thrown away, and nothing accomplished.

Here's a diagram of the two bytes combined into a single bit string, showing the
respective positions of the bits, and their function:

         |<-Byte 1: Control->|<-Byte 2: Data->|
         |                   |                |
    fcn: | command | channel |      data      |
         |---------|---------|----------------|
    bit: | 7 6 5 4 | 3 2 1 0 | 7 6 5 4 3 2 1 0|
         --------------------------------------
           ^                                 ^
           |                                 |
       MSB (bit 15)                      LSB (bit 0)

=head1 CONTROL BYTE

The control byte is the most significant byte of the overall data being clocked
into the potentiometer, and consists of a command nibble and a channel nibble.

=head2 COMMAND

The command nibble is the most significant (leftmost) 4 bits of the control
byte (bits 7-4 in the above diagram). The following diagram describes all
possible valid values.

    Bits    Value
    -------------

    0000    NOOP
    0001    set a new resistance value
    0010    put potentiometer into 'shutdown' mode
    0011    NOOP

=head2 CHANNEL

The channel nibble is the least significant 4 bits (rightmost) of the control
byte (bits 3-0 in the above diagram). Valid values follow. Note that the
MCP41xxx series units have only a single potentiometer built in, there's but
one valid value for them.

    Bits    Value
    -------------

    0001    channel 0
    0010    channel 1    (MCP42xxx only)
    0011    both 0 and 1 (MCP42xxx only)

=head1 DATA BYTE

The data byte consists of the least significant 8 bits (rightmost) of the 16 bit
combined data destined to the potentiometer. Both the MCP41xxx and MCP42xxx
series potentiometers contain 256 taps, so the mapping of this byte is simple:
valid values are C<0> (0% output) through C<255> (100% output).

=head1 REGISTER BIT SEQUENCE

Here's an overview of the bits in order:

C<15-14>: Unused ("Don't Care Bits", per the datasheet)

C<13-12>: Command bits

C<11-10>: Unused

C<9-8>: Channel select bits

C<7-0>: Potentiometer tap setting data (0-255)

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2017 Steve Bertrand.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

