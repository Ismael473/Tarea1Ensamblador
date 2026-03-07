.MODEL SMALL
.STACK 100h

.DATA
    ; Definiciones simbolicas para la estructura de datos
    MAX_ACC     equ 10
    ACC_SIZE    equ 27
    
    ACC_NUM     equ 0
    ACC_HOLDER  equ 2
    ACC_BAL     equ 22
    ACC_STATE   equ 26
    
    ; Variables para el manejo de cuentas
    ACCOUNTS    db ACC_SIZE * MAX_ACC dup(?) ; Define el espacio de memoria para diez cuentas.
    ACC_COUNT   db 0 ; Contador de cuentas
    
    TEST_INPUT  db 20, ?, 20 dup(?)
.CODE

create_account PROC
    mov cl, [TEST_INPUT+1]
    xor ch, ch
    lea si, TEST_INPUT+2
print_name:
    mov dl, [si]
    mov ah, 02h
    int 21h
    
    inc si
    loop print_name
    
    ret
        
create_account ENDP

end_program PROC
    mov ax, 4C00h
    int 21h
end_program ENDP

main:
    mov ax, @data
    mov ds, ax
    
    mov ah, 0Ah
    lea dx, TEST_INPUT
    int 21h
    
    call create_account 
    
    call end_program
END main