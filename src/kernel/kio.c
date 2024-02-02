#include "kio.h"

uint16_t* video_memory = (uint16_t*)0xB8000;

int cursor_x = 0;
int cursor_y = 0;

void kernel_put(char character, int x, int y) {
    const int index = y * 80 + x;
    video_memory[index] = (uint16_t)((0x0F << 8) | character);
}

void kernel_clear_screen() {
    for (int i = 0; i < 80 * 25; i++) {
        video_memory[i] = (uint16_t)((0x0F << 8) | ' ');
    }
}

void kernel_print_number(int number) {
    if (number < 0) {
        kernel_put('-', cursor_x, cursor_y);
        cursor_x++;
        number = -number;
    }

    if (number == 0) {
        kernel_put('0', cursor_x, cursor_y);
        cursor_x++;
    }

    char buffer[20];
    int digit, i = 0;

    while (number > 0) {
        digit = number % 10;
        buffer[i] = '0' + digit;
        number /= 10;
        i++;
    }

    for (int j = i - 1; j >= 0; j--) {
        kernel_put(buffer[j], cursor_x, cursor_y);
        cursor_x++;
    }
}

void kernel_print_string(const char* str) {
    while (*str != '\0') {
        if (*str == '\n') {
            cursor_x = 0; // Move to the start of the next line
            cursor_y++;
        } else {
            kernel_put(*str, cursor_x, cursor_y);
            cursor_x++;

            if (cursor_x >= 80) {
                cursor_x = 0; // Move to the start of the next line if at the end
                cursor_y++;
            }
        }

        if (cursor_y >= 25) {
            kernel_clear_screen(); // If the screen is full, clear it
            cursor_x = 0;
            cursor_y = 0;
        }

        str++;
    }
}

void kernel_set_cursor(int x, int y) {
    cursor_x = x;
    cursor_y = y;
}