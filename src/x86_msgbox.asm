;x86_msgbox 
section .data 
	title db "Hello!",0
	message db "Hello, World!",0

	MB_OK equ 0x00000000
	MB_ICONINFORMATION equ 0x00000040

section .text 
	global main 
	extern _MessageBoxA@16
	extern _ExitProcess@4

main:
	push ebp 
	mov ebp, esp

	; Call _MessageBoxA@16 
	push	MB_OK | MB_ICONINFORMATION
	lea		edx, [title]
	push	edx 
	lea		edx, [message]
	push	edx
	push	0 
	call _MessageBoxA@16 

	leave

	; Call _ExitProcess@4 
	push 0 
	call _ExitProcess@4

