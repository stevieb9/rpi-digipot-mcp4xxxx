#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <stdio.h>
#include <wiringPi.h>
#include <wiringPiSPI.h>

int setup (int channel, int speed){
    return wiringPiSPISetup(channel, speed);
}

int dpot_write (int channel, int data, int len){

    uint8_t buf[2];
    uint8_t cmd_bits, data_bits;

    unsigned char x;
    x = (unsigned char *)data;

    cmd_bits  = x & 0xFF;
    data_bits = x >> 8;

    printf("%d, %d, %d\n", data, cmd_bits, data_bits);
}

MODULE = RPi::DigiPot::MCP4XXXX  PACKAGE = RPi::DigiPot::MCP4XXXX

PROTOTYPES: DISABLE

int
setup (channel, speed)
	int	channel
	int	speed

int
dpot_write (channel, data, len)
	int	channel
	int data
	int	len

