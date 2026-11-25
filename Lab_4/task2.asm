format ELF64
public _start

result_text equ 'Sum: '

include 'common.inc'

_start:
    call read_number
    jc input_error
    xor r12d, r12d
    test rax, rax
    jle .print

    ; The magnitude is n(n + 1)/2. Divide the even factor first.
    mov r12, rax
    shr r12, 1
    test al, 1
    jnz .odd
    inc rax
    imul r12, rax
    jo input_error
    neg r12
    jmp .print

.odd:
    inc r12
    imul r12, rax
    jo input_error

.print:
    mov rsi, result_msg
    mov edx, result_len
    call write_stdout
    mov rax, r12
    call print_number
    jmp finish
