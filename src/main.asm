; Some useful assambly docs
; https://hjlebbink.github.io/x86doc/

org 0x7c00
bits 16

%define ENDL 0x0D, 0x0A

start:
	jmp main


; si points to string (si -> 16bit gpr)
write:
	push si
	push ax

.loop:
	lodsb	; load next character from al
	or al, al ; verify content is not null
	jz .done

	mov ah, 0x0e ; call bios interupt
	mov bh, 0
	int 0x10

	jmp .loop

.done:
	pop ax
	pop si
	ret

main:
	
	; Reset ds (data segment) and es (extra data segment)
	mov ax, 0
	mov ds, ax
	mov es, ax
	
	; Setup stack at origin -> grows downwards
	mov ss, ax ; ss -> Stack segment
	mov sp, 0x7c00 ; sp -> Stack pointer

	; print message
	mov si, msg_hello
	call write

	hlt

.halt:
	jmp .halt

msg_hello: dw "Hello matzl!", ENDL, 0

; Bios required 512 bytes with boot signature for legacy boot
times 510-($-$$) db 0 ; db -> declare byte
dw 0AA55h ; dw -> Declare word
