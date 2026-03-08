
.MODEL SMALL
.STACK 100h

.DATA
    ; Definiciones simbolicas para la estructura de datos
    ; Indican el tamano en bytes de cada dato (para navegar la estructura)
    ; ACC_NUM 2 bytes
    ; ACC_HOLDER 20 bytes
    ; ACC_BAL 4 bytes
    ; ACC_STATE 1 byte
    
    ;---Opciones del menu ---
    
    op_Crear db "1. Crear cuenta"
    op_Depos db "2. Depositar Dinero"
    op_Retir db "3. Retirar Dinero"
    op_Consul db "4. Consultar Saldo"
    op_MostRepo db "5. Mostrar Reporte General"
    op_Desac db "6. Desactivar cuenta"
    op_Salir db "7. Salir"
                             
    ;------------------------                             
    
    
    MAX_ACC     equ 10
    ACC_SIZE    equ 27
    
    ACC_NUM     equ 0
    ACC_HOLDER  equ 2
    ACC_BAL     equ 22
    ACC_STATE   equ 26
    
    ; Variables para el manejo de cuentas
    ACCOUNTS    db ACC_SIZE * MAX_ACC dup(?) ; Define el espacio de memoria para diez cuentas.
    ACC_COUNT   db 0 ; Contador de cuentas
    
    HOLDER_TEST_INPUT  db 21, ?, 21 dup(?)
    ACC_NUM_TEST_INPUT db 6, ?, 6 dup(?)
    
    
.CODE

print_menu PROC
    mov ds, op_Crear
    mov ah, 09h
    lea dx, op_Crear
    int 21h
    
    

create_account PROC
    mov al, MAX_ACC
    cmp ACC_COUNT, al
    jae acc_limit ; Se fija si hay espacio para una nueva cuenta
    
    mov ah, 0Ah
    lea dx, HOLDER_TEST_INPUT ; INPUT DE TESTEO
    int 21h
    
    mov ah, 0Ah
    lea dx, ACC_NUM_TEST_INPUT ; INPUT DE TESTEO
    int 21h
    
    xor ax, ax ; Limpiar registros
    xor cx, cx
    xor dx, dx
    xor bh, bh
    mov cl, [ACC_NUM_TEST_INPUT+1] ; Numero de caracteres que el usuario ingreso
    lea si, ACC_NUM_TEST_INPUT+2   ; La direccion de memoria donde empieza el string

convert_acc_number:
    mov bl, [si]  ; Asignamos el caracter
    sub bl, '0'   ; Conversion a entero
    mov dx, 10    ; Asignar diez para multiplicar el numero anterior ax * 10 + bl
    mul dx
    add ax, bx 
   
    inc si        ; Pasar al siguiente caracter

    loop convert_acc_number
    
    mov cl, ACC_COUNT
    lea si, ACCOUNTS  ; Inicio del bloque de memoria de las cuentas
    xor bx, bx   
    
check_existance:
    cmp cl, 0
    je create_new_acc    ; Ninguna cuenta tiene el mismo numero, creamos una nueva
    
    mov bx, [si]
    cmp ax, bx           ; El numero ingresado tiene es el mismo para otra cuenta, evitamos crear otra.
    je duplicated_acc
    
    dec cl
    add si, ACC_SIZE     ; Saltamos a la siguiente cuenta
    jmp check_existance    

create_new_acc:
    mov dx, ax
    xor ax, ax
    mov al, ACC_COUNT
    mov bl, ACC_SIZE
    mul bl
    lea si, ACCOUNTS
    add si, ax
    
    mov [si+ACC_NUM], dx
    
    inc ACC_COUNT
     
acc_limit:
    ret
    
duplicated_acc:
    ret
        
create_account ENDP

end_program PROC
    mov ax, 4C00h
    int 21h
end_program ENDP

main:
    mov ax, @data
    mov ds, ax
    
    call print_menu    
    call create_account
    call create_account 
    
    call end_program
END main 


