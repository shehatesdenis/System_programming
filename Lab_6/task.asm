format ELF64

public main
extrn initscr
extrn endwin
extrn cbreak
extrn noecho
extrn curs_set
extrn start_color
extrn init_pair
extrn getmaxy
extrn getmaxx
extrn werase
extrn mvwaddch
extrn wrefresh
extrn wtimeout
extrn wgetch

COLOR_BLACK = 0
COLOR_RED = 1
COLOR_WHITE = 7
KEY_RESIZE = 410
NORMAL_DELAY = 35
FAST_DELAY = 8

section '.data' writeable
window dq 0
row dd 0
column dd 0
color_pair dd 1
delay_ms dd NORMAL_DELAY

section '.text' executable
main:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    call initscr
    mov [window], rax
    call cbreak
    call noecho
    xor edi, edi
    call curs_set

    call start_color
    test eax, eax
    js .color_error
    mov edi, 1
    mov esi, COLOR_WHITE
    mov edx, COLOR_RED
    call init_pair
    test eax, eax
    js .color_error
    mov edi, 2
    mov esi, COLOR_WHITE
    mov edx, COLOR_BLACK
    call init_pair
    test eax, eax
    js .color_error

.resize:
    mov rdi, [window]
    call werase

.restart:
    ; Inclusive bounds of the unpainted rectangle.
    xor r12d, r12d               ; top
    xor r14d, r14d               ; left
    mov rdi, [window]
    call getmaxy
    lea r13d, [eax - 1]          ; bottom
    mov rdi, [window]
    call getmaxx
    lea r15d, [eax - 1]          ; right
    mov [row], r12d
    mov [column], r14d

.down:
    call paint_cell
    test eax, eax
    jnz .handle_key
    inc [row]
    cmp [row], r13d
    jle .down
    dec [row]
    inc r14d
    cmp r14d, r15d
    jg .next_color
    mov [column], r14d

.right:
    call paint_cell
    test eax, eax
    jnz .handle_key
    inc [column]
    cmp [column], r15d
    jle .right
    dec [column]
    dec r13d
    cmp r13d, r12d
    jl .next_color
    mov [row], r13d

.up:
    call paint_cell
    test eax, eax
    jnz .handle_key
    dec [row]
    cmp [row], r12d
    jge .up
    inc [row]
    dec r15d
    cmp r15d, r14d
    jl .next_color
    mov [column], r15d

.left:
    call paint_cell
    test eax, eax
    jnz .handle_key
    dec [column]
    cmp [column], r14d
    jge .left
    inc [column]
    inc r12d
    cmp r12d, r13d
    jg .next_color
    mov [row], r12d
    jmp .down

.next_color:
    xor [color_pair], 3         ; 1 -> 2 -> 1
    jmp .restart

.handle_key:
    cmp eax, KEY_RESIZE
    je .resize
    call endwin
    xor eax, eax
    jmp .return

.color_error:
    call endwin
    mov eax, 1

.return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

; Paint one position and wait for input up to the current step delay.
; Return 'l' or KEY_RESIZE to the caller when the spiral must stop.
paint_cell:
    sub rsp, 8
    mov rdi, [window]
    mov esi, [row]
    mov edx, [column]
    mov ecx, [color_pair]
    shl ecx, 8                  ; ncurses COLOR_PAIR attribute
    or ecx, '.'
    call mvwaddch
    mov rdi, [window]
    call wrefresh
    mov rdi, [window]
    mov esi, [delay_ms]
    call wtimeout
    mov rdi, [window]
    call wgetch
    cmp eax, 'l'
    je .return
    cmp eax, KEY_RESIZE
    je .return
    cmp eax, 'p'
    jne .continue
    xor [delay_ms], NORMAL_DELAY xor FAST_DELAY
.continue:
    xor eax, eax
.return:
    add rsp, 8
    ret

section '.note.GNU-stack'
