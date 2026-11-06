format ELF64
public _start

include 'func.asm'

section '.text' executable
_start:
   pop rcx
   mov r12, [rsp+8]
   mov rsi, [rsp+16]
   call str_number
   mov rbx, rax
   mov rax, 80
   mov rdi, r12
   syscall
.loop:
   cmp rbx, 0
   je .done
   mov rax, 83
   mov rdi, r12
   mov rsi, 777o
   syscall
   mov rax, 80
   mov rdi, r12
   syscall
   dec rbx
   jmp .loop
.done:
   call exit
