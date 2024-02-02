#ifndef CORA_KIO_H
#define CORA_KIO_H

#include <stdint.h>

void kernel_put(char character, int x, int y);
void kernel_clear_screen();
void kernel_print_number(int number);
void kernel_print_string(const char* str);
void kernel_set_cursor(int x, int y);

#endif //CORA_KIO_H
