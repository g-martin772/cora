; Some useful assambly docs
; https://hjlebbink.github.io/x86doc/

org 0x7c00
bits 16

%define ENDL 0x0D, 0x0A

; FAT12 Header
jmp short start
nop

bdb_oem:                    db 'MSWIN4.1'           ; 8 bytes
bdb_bytes_per_sector:       dw 512
bdb_sectors_per_cluster:    db 1
bdb_reserved_sectors:       dw 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 0E0h
bdb_total_sectors:          dw 2880                 ; 2880 * 512 = 1.44MB
bdb_media_descriptor_type:  db 0F0h                 ; F0 = 3.5" floppy disk
bdb_sectors_per_fat:        dw 9                    ; 9 sectors/fat
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0

; extended boot record
ebr_drive_number:           db 0                    ; 0x00 floppy, 0x80 hdd, useless
                            db 0                    ; reserved
ebr_signature:              db 29h
ebr_volume_id:              db 12h, 34h, 56h, 78h   ; serial number, value doesn't matter
ebr_volume_label:           db 'NANOBYTE OS'        ; 11 bytes, padded with spaces
ebr_system_id:              db 'FAT12   '           ; 8 bytes

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

	; read something from disk
	mov [ebr_drive_number], dl

	mov ax, 1 ; Second sector index
	mov cl, 1 ; 1 sector to read
	mov bx, 0x7e00 ; data after bootloader
	call disk_read

	cli
	hlt

floppy_error:
	mov si, msg_floppy_error
	call write
	jmp wait_key_and_reboot

wait_key_and_reboot:
	mov ah, 0
	int 16h ; wait for keypress
	jmp 0FFFh:0 ; jump to start of bios, should reboot
	htl

.halt:
	cli
	jmp .halt

; Parameters:
;	- ax: LBA address
; Return:
;	- cx bits 0-5 -> sector number
;	- cx bits 6-15 -> cylinder
lba_to_chs:
	push ax
	push dx

	xor dx, dx
	div word [bdb_sectors_per_track]
	
	inc dx
	mov cx, dx

	xor dx, dx
	div word [bdb_heads]

	mov dh, dl
	mov ch, al
	shl ah, 6
	or cl, ah

	pop ax
	mov dl, al
	pop ax
	ret

; Parameters:
;	- ax: LBA address
;	- cl: number of sectors to read
;	- dl: drive number
;	- es:bx: where to put the data
disk_read:
	push ax
	push bx
	push cx
	push dx
	push di

	push cx
	call lba_to_chs
	pop ax
	
	mov ah, 02h
	mov di, 3 ; retry count

.retry
	pusha
	stc ; set carry flag
	int 13h ; if carry flag is cleared we got a success
	jnc .done
	
	popa
	call disk_reset
	dec di
	test di, di
	jnz .retry

.fail:
	jmp floppy_error

.done:
	popa
	
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	ret

; Parameters:
;	- dl: drive number
disk_reset:
	pusha
	mov ah, 0
	stc
	int 13h
	jc floppy_error
	popa
	ret

msg_hello: dw "Hello matzl!", ENDL, 0
msg_floppy_error: dw "Failed to read floppy data", ENDL, 0

; Bios required 512 bytes with boot signature for legacy boot
times 510-($-$$) db 0 ; db -> declare byte
dw 0AA55h ; dw -> Declare word
