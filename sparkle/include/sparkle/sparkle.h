#ifndef __SPARKLE_H__
#define __SPARKLE_H__

#include <stdint.h>

extern uint8_t sparkle_max_luminance;

int sparkle_init(void);
void sparkle_exit(void);
void sparkle_write(const uint8_t *buf, uint32_t buf_sz);

#endif
