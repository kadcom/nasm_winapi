	; x64_msgbox
	; Show a message box with a title and message

section .data 
	title db "Hello!",0
	message db "Hello, World!",0

	MB_OK equ 0x00000000
	MB_ICONINFORMATION equ 0x00000040

section .text 
	global main 
	extern MessageBoxA
	extern ExitProcess

main:
	push rbp
	mov rbp, rsp
	sub rsp, 32 

	; Call MessageBoxA
	xor rcx, rcx
	lea rdx, [rel message]
	lea r8, [rel title]
	mov r9d, (MB_OK | MB_ICONINFORMATION)
	call MessageBoxA

	; Call ExitProcess
	leave
	xor rcx, rcx
	call ExitProcess

