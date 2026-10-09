format ELF64 executable 3
entry _start
segment readable writeable
prompt db "Enter n: "
plen = $-prompt
msg db "Count: "
mlen = $-msg
input rb 128
outbuf rb 64
segment readable executable
_start:
    mov eax,1
    mov edi,1
    mov rsi,prompt
    mov edx,plen
    syscall
    xor eax,eax
    xor edi,edi
    mov rsi,input
    mov edx,127
    syscall
    test rax,rax
    jle .exit
    mov byte [input+rax],0
    mov rsi,input
    call parse_int
    test rax,rax
    jle .zero
    mov r12,rax
    xor r13,r13
    mov r14,1
.loop:
    mov rax,r14
    xor edx,edx
    mov ebx,11
    div rbx
    test rdx,rdx
    jz .next
    mov rax,r14
    xor edx,edx
    mov ebx,5
    div rbx
    test rdx,rdx
    jz .next
    inc r13
.next:
    inc r14
    cmp r14,r12
    jle .loop
    mov rax,r13
    call print_result
    jmp .exit
.zero:
    xor eax,eax
    call print_result
.exit:
    mov eax,60
    xor edi,edi
    syscall
parse_int:
    xor eax,eax
    xor r8d,r8d
    cmp byte [rsi],'-'
    jne .digits
    mov r8d,1
    inc rsi
.digits:
    movzx ecx,byte [rsi]
    cmp ecx,'0'
    jb .done
    cmp ecx,'9'
    ja .done
    imul rax,10
    sub ecx,'0'
    add rax,rcx
    inc rsi
    jmp .digits
.done:
    test r8d,r8d
    jz .ret
    neg rax
.ret: ret
print_result:
    mov rbx,rax
    mov eax,1
    mov edi,1
    mov rsi,msg
    mov edx,mlen
    syscall
    lea rsi,[outbuf+63]
    mov byte [rsi],10
    mov ecx,1
    mov rax,rbx
    xor r8d,r8d
    test rax,rax
    jns .convert
    neg rax
    mov r8d,1
.convert:
    xor edx,edx
    mov r9d,10
    div r9
    add dl,'0'
    dec rsi
    mov [rsi],dl
    inc ecx
    test rax,rax
    jnz .convert
    test r8d,r8d
    jz .write
    dec rsi
    mov byte [rsi],'-'
    inc ecx
.write:
    mov eax,1
    mov edi,1
    mov edx,ecx
    syscall
    ret
