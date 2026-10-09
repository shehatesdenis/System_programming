format ELF64 executable 3
entry _start
segment readable writeable
prompt db "Enter n: "
plen = $-prompt
msg db "Numbers: "
mlen = $-msg
space db " "
newline db 10
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
    jle .empty
    mov r12,rax
    mov eax,1
    mov edi,1
    mov rsi,msg
    mov edx,mlen
    syscall
    mov r14,1
.loop:
    mov rax,r14
    xor edx,edx
    mov ebx,10
    div rbx
    test rdx,rdx
    jz .next
    mov r15,rdx
    mov rax,r14
    xor edx,edx
    mov ebx,10
    div rbx
    xor edx,edx
    mov ebx,10
    div rbx
    mov rbx,rdx
    test rbx,rbx
    jz .next
    mov rax,r14
    xor edx,edx
    div r15
    test rdx,rdx
    jnz .next
    mov rax,r14
    xor edx,edx
    div rbx
    test rdx,rdx
    jnz .next
    mov rax,r14
    call print_number
.next:
    inc r14
    cmp r14,r12
    jle .loop
    mov eax,1
    mov edi,1
    mov rsi,newline
    mov edx,1
    syscall
    jmp .exit
.empty:
    mov eax,1
    mov edi,1
    mov rsi,msg
    mov edx,mlen
    syscall
    mov eax,1
    mov edi,1
    mov rsi,newline
    mov edx,1
    syscall
.exit:
    mov eax,60
    xor edi,edi
    syscall
parse_int:
    xor eax,eax
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
.done: ret
print_number:
    mov rbx,rax
    lea rsi,[outbuf+63]
    mov byte [rsi],0
    xor ecx,ecx
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
    mov eax,1
    mov edi,1
    mov edx,ecx
    syscall
    mov eax,1
    mov edi,1
    mov rsi,space
    mov edx,1
    syscall
    ret
