#ifndef __SPARKLE_H__
#define __SPARKLE_H__

#include <stdint.h>

int sparkle_init(void);
void sparkle_exit(void);
void sparkle_send(uint32_t buf_sz, const uint8_t *buf);

#endif
