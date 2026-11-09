format ELF64
public _start

section '.data' writable
    number dq 5277616985
    newline db 0x0A

section '.bss' writable
    result_buf rb 20            ; 20 байт под цифры результата

section '.text' executable
_start:
    mov rax, [number]
    xor rbx, rbx                ; rbx = сумма цифр
sum_loop:
    xor rdx, rdx
    mov rcx, 10
    div rcx                     ; rax = частное, rdx = последняя цифра
    add rbx, rdx
    test rax, rax
    jnz sum_loop

    mov rax, rbx                ; превращаем сумму (56) в текст
    xor r8, r8                  ; r8 = сколько цифр получилось
convert_loop:
    xor rdx, rdx
    mov rcx, 10
    div rcx
    add dl, '0'                 ; цифра -> ASCII
    mov [result_buf + r8], dl
    inc r8
    test rax, rax
    jnz convert_loop

    mov r9, r8
    dec r9                      ; цифры лежат задом наперёд, печатаем с конца
print_loop:
    lea rsi, [result_buf + r9]
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rdx, 1
    syscall
    dec r9
    jge print_loop              ; пока r9 >= 0

    mov rax, 1                  ; перевод строки
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    mov rax, 60                 ; sys_exit
    xor rdi, rdi
    syscall
