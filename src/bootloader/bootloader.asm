; Some useful assambly docs
; https://hjlebbink.github.io/x86doc/
; https://www.cs.cmu.edu/~ralf/files.html

BITS 16
[org 0x7c00]


start:
	mov si, string_to_print
	call print_string

	mov cx, 0x3ac7
	call print_hex

	jmp $

	string_to_print db "Some Value: ",0



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


; Bootloader signature
times 510-($-$$) db 0
dw 0xaa55