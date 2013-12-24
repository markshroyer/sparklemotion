#include "sparkle.h"

#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>

#define NLEDS 60
#define DATA_SZ (3 * NLEDS)

int main(void)
{
    uint8_t *data;
    int led, color, primary;
    struct timespec delay = { 0, 500000000 };
    uint8_t pattern[9]={0,255,0,255,0,0,255,255,255};
    uint8_t step =0;
    unsigned char temp[3]={0,0,0};
    double decay = 0.5;
    unsigned char cleared=1;

    if (sparkle_init() < 0) {
        fprintf(stderr, "Could not initialize sparkle\n");
        exit(1);
    }

    sparkle_max_luminance = 0x60;

    data = malloc(DATA_SZ);
    if (! data) {
        fprintf(stderr, "Could not allocate data buffer\n");
        exit(1);
    }

    while(1){

        cleared =1; //assume cleared and needs new colour

        for(led=0;led<DATA_SZ;led++){ //decay all

            data[led] = data[led]*decay;

            if(data[led]>0 && cleared ==1){ //if any leds have value left no new colour needed
                cleared = 0;
            }
        }


        if(cleared){
            led = rand()%NLEDS; //random position
            data[led] = rand()%0xff; //random colour
            data[led] = rand()%0xff; //random colour
            data[led] = rand()%0xff; //random colour
        }

        for(led=0;led<DATA_SZ;led+=3){ //scan and smear

            if(led>0){ //check behind
                temp[0] = data[led-3];
                temp[1] = data[led-2];
                temp[2] = data[led-1];
            }

            if(led<NLEDS){ //check forward
                temp[0] += data[led+3];
                temp[1] += data[led+4];
                temp[2] += data[led-5];
            }

            data[led] = temp[0]/decay;
            data[led+1] = temp[1]/decay;
            data[led+2] = temp[2]/decay;
        }

        sparkle_write(data, DATA_SZ);
        nanosleep(&delay, NULL);

    }

    sparkle_exit();

    return 0;
}
