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
    //return API::WiringPi::spiDataRW(channel, data, 2);
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

