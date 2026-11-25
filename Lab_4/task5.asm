format ELF64
public _start

result_text equ 'Count: '

include 'common.inc'

_start:
    call read_number
    jc input_error
    xor r12d, r12d
    test rax, rax
    jle .print

    ; A number fails both conditions only when divisible by 55.
    mov r12, rax
    xor edx, edx
    mov ecx, 55
    div rcx
    sub r12, rax

.print:
    mov rsi, result_msg
    mov edx, result_len
    call write_stdout
    mov rax, r12
    call print_number
    jmp finish
