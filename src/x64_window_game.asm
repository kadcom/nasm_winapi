; x64_window
section .data
    class_name db "x64_window_class", 0
    window_title db "x64_window", 0

    CS_HREDRAW equ 1
    CS_VREDRAW equ 2

    WM_DESTROY equ 2
		WM_QUIT equ 18

    COLOR_WINDOW equ 5

    WS_OVERLAPPEDWINDOW equ 0CF0000h

    CW_USEDEFAULT equ 80000000h

    SW_SHOW equ 5

		WCEX_SIZE equ 80

		PM_REMOVE equ 1

section .bss 
    ; WNDCLASSEX structure (aligned properly)
    wcex:
        .cbSize         resd 1    ; UINT        (4 bytes)
        .style          resd 1    ; UINT        (4 bytes)
        .lpfnWndProc    resq 1    ; WNDPROC     (8 bytes)
        .cbClsExtra     resd 1    ; int         (4 bytes)
        .cbWndExtra     resd 1    ; int         (4 bytes)
        .hInstance      resq 1    ; HINSTANCE   (8 bytes)
        .hIcon          resq 1    ; HICON       (8 bytes)
        .hCursor        resq 1    ; HCURSOR     (8 bytes)
        .hbrBackground  resq 1    ; HBRUSH      (8 bytes)
        .lpszMenuName   resq 1    ; LPCSTR      (8 bytes)
        .lpszClassName  resq 1    ; LPCSTR      (8 bytes)
        .hIconSm        resq 1    ; HICON       (8 bytes)
    
    msg: 
        .hwnd:    resq 1
        .message: resd 1
        .padding: resd 1  ; Added padding for alignment
        .wParam:  resq 1
        .lParam:  resq 1
        .time:    resd 1
        .pt:
            .x:   resd 1
            .y:   resd 1

    hInstance: resq 1
    hWnd:      resq 1

section .text
global main 
extern GetModuleHandleA, RegisterClassExA, CreateWindowExA, ShowWindow, UpdateWindow
extern GetMessageA, TranslateMessage, DispatchMessageA, DefWindowProcA
extern ExitProcess, PostQuitMessage, PeekMessageA

wnd_proc:
    push rbp 
    mov rbp, rsp
    sub rsp, 48

    cmp edx, WM_DESTROY    ; Compare with 32-bit part since message is UINT
    jne .def_window_proc

    xor ecx, ecx
    call PostQuitMessage
    xor rax, rax
    jmp .ret

.def_window_proc:
    call DefWindowProcA

.ret:
    leave
    ret

main: 
    push rbp
    mov rbp, rsp
    sub rsp, 32 

    ; GetModuleHandleA(NULL)
    xor rcx, rcx
    call GetModuleHandleA
    mov [rel hInstance], rax

    ; Zero wcex 
    lea rdi, [rel wcex]
    mov ecx, WCEX_SIZE 
    xor eax, eax
    rep stosb

    ; Fill wcex with proper alignment
    lea rbx, [rel wcex]
    mov dword [rel wcex.cbSize], WCEX_SIZE               ; cbSize
    mov dword [rel wcex.style], CS_HREDRAW | CS_VREDRAW  ; style
    lea rax, [rel wnd_proc]
    mov qword [rel wcex.lpfnWndProc], rax               ; lpfnWndProc
    mov dword [rel wcex.cbClsExtra], 0                  ; cbClsExtra
    mov dword [rel wcex.cbWndExtra], 0                  ; cbWndExtra
    mov rax, [rel hInstance]
    mov qword [rel wcex.hInstance], rax                 ; hInstance
    mov qword [rel wcex.hIcon], 0                       ; hIcon
    mov qword [rel wcex.hCursor], 0                     ; hCursor
    mov qword [rel wcex.hbrBackground], COLOR_WINDOW + 1 ; hbrBackground
    mov qword [rel wcex.lpszMenuName], 0                ; lpszMenuName
    lea rax, [rel class_name]
    mov qword [rel wcex.lpszClassName], rax             ; lpszClassName
    mov qword [rel wcex.hIconSm], 0                     ; hIconSm

    ; RegisterClassExA(&wcex)
    lea rcx, [rel wcex]
    call RegisterClassExA
    test rax, rax          ; Check if registration failed
    jz .exit_error

    ; CreateWindowExA
    sub rsp, 96           ; Space for parameters + shadow space

    xor rcx, rcx          ; dwExStyle
    lea rdx, [rel class_name]
    lea r8, [rel window_title]
    mov r9d, WS_OVERLAPPEDWINDOW
    mov dword [rsp + 32], CW_USEDEFAULT  ; X
    mov dword [rsp + 40], CW_USEDEFAULT  ; Y
    mov dword [rsp + 48], 800            ; Width
    mov dword [rsp + 56], 600            ; Height
    mov qword [rsp + 64], 0              ; hWndParent
    mov qword [rsp + 72], 0              ; hMenu
    mov rax, [rel hInstance]
    mov qword [rsp + 80], rax            ; hInstance
    mov qword [rsp + 88], 0              ; lpParam

    call CreateWindowExA
    mov [rel hWnd], rax

		add rsp, 96           ; Restore stack

    test rax, rax         ; Check if window creation failed
    jz .exit_error

    ; ShowWindow(hWnd, SW_SHOW)
    mov rcx, [rel hWnd]
    mov edx, SW_SHOW
    call ShowWindow

    ; UpdateWindow(hWnd)
    mov rcx, [rel hWnd]
    call UpdateWindow

.msg_loop:

		sub rsp, 4 
		lea rcx, [rel msg]
		xor rdx, rdx 
		xor r8, r8
		xor r9, r9
		mov dword [rsp + 32], PM_REMOVE
		call PeekMessageA
		add rsp, 4
		
		test rax, rax
		jz .no_messages
		
		cmp dword[rel msg.message], WM_QUIT 
		je .exit_loop

		lea rcx, [rel msg]
		call TranslateMessage

		lea rcx, [rel msg]
		call DispatchMessageA
		
		jmp .msg_loop

.no_messages:
		; Do render here
		jmp .msg_loop

.exit_error:
    mov ecx, 1            ; Exit with error code 1
    jmp .exit

.exit_loop:
    xor ecx, ecx          ; Exit with code 0

.exit:
		leave
    call ExitProcess
