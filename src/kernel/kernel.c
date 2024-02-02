#include "kio.h"

int main() {
	kernel_clear_screen();
	kernel_set_cursor(0, 3);
	kernel_print_number(12345);
	kernel_print_string("\nHello, World!\nThis is a new line!");
	return 0;
}
