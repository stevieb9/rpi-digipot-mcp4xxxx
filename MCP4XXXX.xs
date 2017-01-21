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

    unsigned char buf[2];

    buf[0] = data & 0xFF;
    buf[1] = data >> 8;

    printf("%d, %d, %d\n", data, buf[0], buf[1]);
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

