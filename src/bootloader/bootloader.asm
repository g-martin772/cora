; Some useful assambly docs
; https://hjlebbink.github.io/x86doc/
; https://www.cs.cmu.edu/~ralf/files.html

BITS 16
[org 0x7c00]


start:
	call enter_protected
	jmp $

bits 32
pm_start:
	; Print a character to video memory
	mov ah, 0x0F
	mov al, 'h'
	mov [0xb8000], ax
	mov al, 'i'
	mov [0xb8002], ax
	jmp $

bits 16
; BIOS Functions

; si = string address to print
print_string:
	pusha		; Preserve registers
	mov ah, 0xe	; ah=0xe: print char BIOS call
.next_char:
	mov al, [si]	; Move the character at the address of si into al
	cmp al, 0x0	; Are we at the end of the string?
	je .string_done	; if so, jump to .string_done
	int 0x10	; else, print the character
	inc si		; Move to next character memory location
	jmp .next_char	; Loop
.string_done:
	popa		; Restore registers
	ret		; Return


; cx: hex value to print
print_hex:
	pusha
	; Print prefix "0x"
	mov ah, 0xe
	mov al, '0'
	int 0x10
	mov ah, 0xe
	mov al, 'x'
	int 0x10
	; Print byte 3
	mov ax, cx	; Keep the cx value untouched. Do our work in ax
	and ax, 0xF000	; Select byte 3
	shr ax, 12	; Shift right by 12 (byte 3 now in position 0x000F)
	call print_byte	; Print the byte in lower half of al
	; Print byte 2
	mov ax, cx	; Refresh ax with the original value of cx
	and ax, 0x0F00	; Select next byte over
	shr ax, 8	; Shift
	call print_byte
	; Print byte 1
	mov ax, cx
	and ax, 0x00F0
	shr ax, 4
	call print_byte
	; Print byte 0
	mov ax, cx
	and ax, 0x000F	; No shift required for byte 0
	call print_byte
	popa
	ret


; al = value to print (valid: 0x0 to 0xf)
print_byte:
	; Is this a number or a letter?
	cmp al, 0xa
	jl .number
			; If letter:
	add al, 'A'
	sub al, 10	; Remember, A=10
	jmp .hex_done
.number: 		; If number:
	add al, '0'
.hex_done:
	mov ah, 0xe
	int 0x10
	ret

; GDT - Global Descriptor Table
gdt_start:
gdt_null:	; Entry 1: Null entry must be included first (error check)
	dd 0x0	; double word = 4 bytes = 32 bits
	dd 0x0
gdt_code:	; Entry 2: Code segment descriptor
	; Structure:
	; Segment Base Address (base) = 0x0
	; Segment Limit (limit) = 0xfffff
	dw 0xffff	; Limit bits 0-15
	dw 0x0000	; Base bits 0-15
	db 0x00		; Base bits 16-23
	; Flag Set 1:
		; Segment Present: 0b1
		; Descriptor Privilege level: 0x00 (ring 0)
		; Descriptor Type: 0b1 (code/data)
	; Flag Set 2: Type Field
		; Code: 0b1 (this is a code segment)
		; Conforming: 0b0 (Code w/ lower privilege may not call this)
		; Readable: 0b1 (Readable or execute only? Readable means we can read code constants)
		; Accessed: 0b0 (Used for debugging and virtual memory. CPU sets bit when accessing segment)
	db 10011010b	; Flag set 1 and 2
	; Flag Set 3
		; Granularity: 0b1 (Set to 1 multiplies limit by 4K. Shift 0xfffff 3 bytes left, allowing to span full 32G of memory)
		; 32-bit default: 0b1
		; 64-bit segment: 0b0
		; AVL: 0b0
	db 11001111b	; Flag set 3 and limit bits 16-19
	db 0x00		; Base bits 24-31
gdt_data:
	; Same except for code flag:
		; Code: 0b0
	dw 0xfffff	; Limit bits 0-15
	dw 0x0000	; Base bits 0-15
	db 0x00		; Base bits 16-23
	db 10010010b	; Flag set 1 and 2
	db 11001111b	; 2nd flags and limit bits 16-19
	db 0x00		; Base bits 24-31

gdt_end:		; Needed to calculate GDT size for inclusion in GDT descriptor

; GDT Descriptor
gdt_descriptor:
	dw gdt_end - gdt_start - 1	; Size of GDT, always less one
	dd gdt_start

; Define constants
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start


; 32bit protected mode

enter_protected:
	; Clear screen by switching to text mode (while we still have BIOS)
	mov ah, 0x0
	mov al, 0x3
	int 0x10

	; Disable interrupts
	cli
	; Load GDT
	lgdt [gdt_descriptor]

	; Switch to PM by setting control register cr0 (use eax b/c cannot set cr0 directly)
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax

	; Perform a far jump to flush CPU pipeline
	jmp CODE_SEG:pm_start


; Bootloader signature
times 510-($-$$) db 0
dw 0xaa55