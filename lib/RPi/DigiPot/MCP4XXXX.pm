package RPi::DigiPot::MCP4XXXX;

use warnings;
use strict;

our $VERSION = '3.1802';

use RPi::Const qw(:all);
use WiringPi::API qw(:all);

sub new {
    if (@_ !=3 && @_ != 4){
        die "new() requires \$cs and \$channel at minimum\n";
    }

    my ($class, $cs, $channel, $speed) = @_;

    my $self = bless {}, $class;
    $self->_cs($cs);
    $self->{len} = 2;

    wiringPiSetupGpio();

    wiringPiSPISetup(
        $self->_channel($channel),
        $self->_speed($speed)
    );

    pinMode($self->_cs, OUTPUT);
    digitalWrite($self->_cs, HIGH);

    return $self;
}
sub set {
    my ($self, $data, $pot) = @_;

    if ($data < 0 || $data > 255){
        die "set() requires 0-255 as the data param\n";
    }

    if (defined $pot){
        if ($pot !=1 && $pot != 2 && $pot != 3){
            die "set() \$pot param must be 1-3\n";
        }
    }
   
    my $cmd = 0x01;
    $pot = 1 if ! defined $pot;

    my $bytes = $self->_bytes($cmd, $pot, $data);

    digitalWrite($self->_cs, LOW);
    spiDataRW($self->_channel, $bytes, $self->_len);
    digitalWrite($self->_cs, HIGH);
}
sub shutdown {
    my ($self, $pot) = @_;

    if (defined $pot){
        if ($pot !=1 && $pot != 2 && $pot != 3){
            die "shutdown() \$pot param must be 1-3\n";
        }
    }

    my $data = 0;
    my $cmd = 0x02; # shutdown bit
    $pot = 1 if ! defined $pot;
    
    my $bytes = $self->_bytes($cmd, $pot, $data);

    digitalWrite($self->_cs, LOW);
    spiDataRW($self->_channel, $bytes, $self->_len);
    digitalWrite($self->_cs, HIGH);
}
sub _bytes {
    
    # calculates and returns an aref of control/data bytes

    my ($self, $cmd, $chan, $data) = @_;

    if (! defined $cmd || ! defined $chan || ! defined $data){
        die "_bytes() requires \$cmd, \$chan (pot) and \$data params\n";
    }

    # shift the command byte left to get a nibble,
    # then OR the channel nibble to it

    my $cntl = ($cmd << 4) | $chan;
   
    return [$cntl, $data];
}
sub _channel {

    # sets/gets the SPI channel

    my ($self, $chan) = @_;
    $self->{channel} = $chan if defined $chan;

    if ($self->{channel} != 0 && $self->{channel} != 1){
        die "\$channel param must be 0 or 1\n";
    }

    return $self->{channel};
}
sub _cs {

    # sets/gets the chip select (CS) pin

    my ($self, $pin) = @_;

    if (defined $pin && ($pin < 0 || $pin > 63)){
        die "cs() param must be a valid GPIO pin number\n";
    }

    $self->{cs} = $pin if defined $pin;

    if (! defined $self->{cs}){
        die "cs() can't continue, we're not configured with a pin\n";
    }

    return $self->{cs};
}
sub _len {
    
    # returns the number of bytes to send to SPI
    # this number is hardcoded in new()

    my $self = shift;
    return $self->{len};
}
sub _speed {

    # sets/gets the SPI bus speed

    my ($self, $speed) = @_;
    $self->{speed} = $speed if defined $speed;
    $self->{speed} = 1000000 if ! defined $self->{speed}; # 1 MHz
    return $self->{speed};
}
sub _vim{};

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

    use warnings;
    use strict;

    use RPi::DigiPot::MCP4XXXX;

    # GPIO pin number connected to the potentiometer's
    # CS (Chip Select) pin

    my $cs = 18;  

    # SPI bus channel

    my $chan = 0;

    my $dpot = RPi::DigiPot::MCP4XXXX->new($cs, $chan);

    # potentiometer's output level (0-255).
    # 127 == ~50% output

    my $output = 127; 

    # set the output level

    $dpot->set($output);

    # shutdown (put to sleep) the potentiometer

    $dpot->shutdown;

=head1 METHODS

=head2 new

Instantiates a new L<RPi::DigiPot::MCP4XXXX> object, initiates communication
with the SPI bus, and returns the object.

Parameters:

    $cs

Mandatory: Integer, the GPIO pin number that connects to the potentiometer's
Chip Select C<CS> pin. This is the pin we use to start and finish communication
with the device over the SPI bus.

    $channel

Mandatory: Integer, represents the SPI bus channel that the potentiometer is
connected to. C<0> for C</dev/spidev0.0> or C<1> for C</dev/spidev0.1>.

    $speed

Optional: Integer. The clock speed to communicate on the SPI bus at. Defaults
to C<1000000> (ie: C<1MHz>).

=head2 set

This method allows you to set the variable output on the potentiometer(s).
These units have 256 taps, allowing that many different output levels.

Parameters:

    $data

Mandatory: Integer bewteen C<0> for 0% output and C<255> for 100% output.

    $pot

Optional: Integer, instructs the software which of the onboard potentiometers
to set the output voltage on. C<1> for the first potentiometer, C<2> for the second, and C<3> to change the value on both. Defaults to C<1>.

NOTE: Only the MCP42xxx units have dual built-in potentiometers, so if you have
an MCP41xxx unit, leave the default C<1> set for this parameter.

=head2 shutdown

The onboard potentiometers allow you to shut them down when not in use,
resulting in electricity usage. Using C<set()> will bring it out of sleep.

Parameters:

    $pot

Optional: Integer, the built-in potentiometer to shut down. C<1> for the first
potentiometer, C<2> for the second, and C<3> to change the value on both.
Defaults to C<1>.

NOTE: Only the MCP42xxx units have dual built-in potentiometers, so if you have
an MCP41xxx unit, leave the default C<1> set for this parameter.

=head1 TECHNICAL INFORMATION

The MCP4XXX datasheet is bundled with this distribution; see L</DATASHEET>.

=head2 DEVICE SPECIFICS

    - 256-tap digital potentiometers, in 10k, 50k and 100k versions
    - MCP41xxx: one potentiometer, 8 pins; MCP42xxx: two potentiometers,
      14 pins, adding hardware SHDN/RS pins and an SO daisy-chain output
    - Wiper powers up at mid-scale (0x80); the 42xxx RS pin resets it
      there in hardware
    - Software shutdown opens the A terminal and ties the wiper to B;
      set() brings the pot back out of it
    - Runs at 2.7-5.5V, under 1uA static; SPI modes 0,0 and 1,1, clocked
      up to 10MHz (this module defaults to 1MHz, adjustable in new())
    - +/-1 LSB max INL/DNL; wiper resistance 52 ohm typical on the 10k
      parts; channel matching within 1% on the dual parts

Wiring an MCP41xxx to the Pi: CS (pin 1) to the GPIO you hand L</new>,
SCK (pin 2) to SCLK (GPIO 11), SI (pin 3) to MOSI (GPIO 10), VSS (pin 4)
to ground, VDD (pin 8) to 3.3V; PA0/PW0/PB0 (pins 5-7) are the resistor
terminals. The chips also run at 5V - fine for the pot itself since
nothing here feeds back to the Pi, but if you daisy-chain a 42xxx at 5V,
keep its SO pin (which drives at VDD levels) away from the Pi's 3.3V
GPIO.

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

         |<-Byte 1: Control->|<-Byte 0: Data->|
         |                   |                |
    fcn: | command | channel |      data      |
         |---------|---------|----------------|
    bit: | 7 6 5 4 | 3 2 1 0 | 7 6 5 4 3 2 1 0|
         --------------------------------------
           ^                                 ^
           |                                 |
       MSB (bit 15)                      LSB (bit 0)

=head2 CONTROL BYTE

The control byte is the most significant byte of the overall data being clocked
into the potentiometer, and consists of a command nibble and a channel nibble.

=head3 COMMAND

The command nibble is the most significant (leftmost) 4 bits of the control
byte (bits 7-4 in the above diagram). The following diagram describes all
possible valid values.

    Bits    Value
    -------------

    0000    NOOP
    0001    set a new resistance value
    0010    put potentiometer into 'shutdown' mode
    0011    NOOP

=head3 CHANNEL

The channel nibble is the least significant 4 bits (rightmost) of the control
byte (bits 3-0 in the above diagram). Valid values follow. Note that the
MCP41xxx series units have only a single potentiometer built in, there's but
one valid value for them.

    Bits    Value
    -------------

    0001    potentiometer 0
    0010    potentiometer 1 (MCP42xxx only)
    0011    both 0 and 1    (MCP42xxx only)

=head2 DATA BYTE

The data byte consists of the least significant 8 bits (rightmost) of the 16 bit
combined data destined to the potentiometer. Both the MCP41xxx and MCP42xxx
series potentiometers contain 256 taps, so the mapping of this byte is simple:
valid values are C<0> (0% output) through C<255> (100% output).

=head2 REGISTER BIT SEQUENCE

Here's an overview of the bits in order:

C<15-14>: Unused ("Don't Care Bits", per the datasheet)

C<13-12>: Command bits

C<11-10>: Unused

C<9-8>: Channel (built-in potentiomenter) select bits

C<7-0>: Potentiometer tap setting data (0-255)

=head2 ON THE WIRE

L</set> and L</shutdown> each produce exactly one 16-bit SPI frame: the
GPIO CS pin drops, two bytes go out on C</dev/spidev0.0> or C<.1> (1MHz
default, SPI mode 0,0), and CS rises again. The chip latches SI bits on
rising SCK edges, and the command executes on that final CS rising edge.
The clock count while CS is low must be a multiple of 16 or the command
aborts - the "multiple" allowance (rather than "exactly") exists for
daisy-chained 42xxx parts; this module always sends exactly 16. Note the
Pi's hardware CE pin for the channel still toggles alongside the GPIO
CS, so don't hang a second device off it.

C<< $dpot->set(127) >> writes wiper tap 127 (about half scale) to
potentiometer 0 - bytes C<0x11 0x7F>:

    CS (GPIO)  \_________________________________/  <- command executes
                    +-----------+-----------+
    SI (MOSI)       | 0001 0001 | 0111 1111 |
                    +-----------+-----------+
                      Control     New wiper
                      byte        data

    0x11:
    +----+----+----+----+----+----+----+----+
    | X  | X  | C1 | C0 | X  | X  | P1 | P0 |
    | 0  | 0  | 0  | 1  | 0  | 0  | 0  | 1  |
    +----+----+----+----+----+----+----+----+

    C1 C0 = 01    Write data
    P1 P0 = 01    Potentiometer 0
    Data  = 127   Tap 127 of 255

C<< $dpot->shutdown(2) >> is the same frame with the shutdown command
and potentiometer 1 selected - bytes C<0x22 0x00>; the data byte is a
"don't care" for shutdowns, and this module sends zeros:

    +----+----+----+----+----+----+----+----+
    | X  | X  | C1 | C0 | X  | X  | P1 | P0 |
    | 0  | 0  | 1  | 0  | 0  | 0  | 1  | 0  |
    +----+----+----+----+----+----+----+----+

Nothing useful comes back on MISO: the single-pot 41xxx has no data-out
pin at all, and while the dual 42xxx has an C<SO> pin that echoes the
shift register 16 clocks behind SI (all zeros first) for daisy-chaining,
this module doesn't read it.

=head2 DATASHEET

The Microchip MCP41xxx/42xxx datasheet (DS11195C) is distributed with
this software as F<docs/datasheet/mcp4xxxx.pdf>. It covers the command
byte, the register layout, and the SPI framing this module implements.

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2017-2026 Steve Bertrand.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

