#include <stdint.h>

uint16_t* video_memory = (uint16_t*)0xB8000;

int cursor_x = 0;
int cursor_y = 0;

void print_char(char character, int x, int y) {
	const int index = y * 80 + x;
	video_memory[index] = (uint16_t)((0x0F << 8) | character);
}

void clear_screen() {
	for (int i = 0; i < 80 * 25; i++) {
		video_memory[i] = (uint16_t)((0x0F << 8) | ' ');
	}
}

void print_number(int number) {
	if (number < 0) {
		print_char('-', cursor_x, cursor_y);
		cursor_x++;
		number = -number;
	}

	if (number == 0) {
		print_char('0', cursor_x, cursor_y);
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
		print_char(buffer[j], cursor_x, cursor_y);
		cursor_x++;
	}
}

void print_string(const char* str) {
	while (*str != '\0') {
		if (*str == '\n') {
			cursor_x = 0; // Move to the start of the next line
			cursor_y++;
		} else {
			print_char(*str, cursor_x, cursor_y);
			cursor_x++;

			if (cursor_x >= 80) {
				cursor_x = 0; // Move to the start of the next line if at the end
				cursor_y++;
			}
		}

		if (cursor_y >= 25) {
			clear_screen(); // If the screen is full, clear it
			cursor_x = 0;
			cursor_y = 0;
		}

		str++;
	}
}

void set_cursor(int x, int y) {
	cursor_x = x;
	cursor_y = y;
}

int main() {
	clear_screen();
	set_cursor(0, 3);
	print_number(12345);
	print_string("\nHello, World!\nThis is a new line!\nThis is another line!\nThis is the last line!");
	return 0;
}
