section '.data' writable
    prompt db 'Enter n: '
    prompt_len = $ - prompt
    result_msg db result_text
    result_len = $ - result_msg
    newline db 10
    space db ' '

section '.bss' writable
    input rb 128
    number_buf rb 21

section '.text' executable
; Read one decimal integer from stdin. CF is set for invalid input.
read_number:
    mov rsi, prompt
    mov edx, prompt_len
    call write_stdout
    xor r8d, r8d

.read:
    xor eax, eax
    xor edi, edi
    lea rsi, [input + r8]
    mov edx, 1
    syscall
    cmp rax, -4
    je .read
    test rax, rax
    js .invalid
    jz .parse
    cmp byte [rsi], 10
    je .parse
    cmp byte [rsi], 0
    je .invalid
    inc r8
    cmp r8, 127
    jb .read
    jmp .invalid

.parse:
    mov byte [rsi], 0
    mov rsi, input
    call skip_whitespace
    xor r8d, r8d
    cmp byte [rsi], '+'
    je .sign
    cmp byte [rsi], '-'
    jne .first_digit
    mov r8d, 1

.sign:
    inc rsi

.first_digit:
    xor eax, eax
    movzx edx, byte [rsi]
    sub edx, '0'
    cmp edx, 9
    ja .invalid

.digits:
    imul rax, 10
    jo .invalid
    sub rax, rdx
    jo .invalid
    inc rsi
    movzx edx, byte [rsi]
    sub edx, '0'
    cmp edx, 9
    jbe .digits

    call skip_whitespace
    cmp byte [rsi], 0
    jne .invalid
    test r8d, r8d
    jnz .done
    neg rax
    jo .invalid

.done:
    clc
    ret

.invalid:
    stc
    ret

skip_whitespace:
.next:
    mov dl, [rsi]
    cmp dl, ' '
    je .skip
    cmp dl, 9
    jb .done
    cmp dl, 13
    ja .done
.skip:
    inc rsi
    jmp .next
.done:
    ret

; Print the signed number in RAX.
print_number:
    mov rsi, number_buf + 21
    mov r9, rsi
    mov ecx, 10
    xor r8d, r8d
    test rax, rax
    jns .convert
    mov r8d, 1
    neg rax

.convert:
    xor edx, edx
    div rcx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    test rax, rax
    jnz .convert
    test r8d, r8d
    jz .write
    dec rsi
    mov byte [rsi], '-'

.write:
    mov rdx, r9
    sub rdx, rsi
    jmp write_stdout

print_newline:
    mov rsi, newline
    mov edx, 1

write_stdout:
    mov eax, 1
    mov edi, 1
    syscall
    ret

finish:
    call print_newline
    xor edi, edi
    jmp exit

input_error:
    mov edi, 1
exit:
    mov eax, 60
    syscall
