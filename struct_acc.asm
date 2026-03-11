.MODEL SMALL
.STACK 100h

.DATA
    ; Definiciones simbolicas para la estructura de datos
    ; Indican el tamano en bytes de cada dato (para navegar la estructura)
    ; ACC_NUM 2 bytes
    ; ACC_HOLDER 20 bytes
    ; ACC_BAL 4 bytes
    ; ACC_STATE 1 byte
    MAX_ACC     equ 10
    ACC_SIZE    equ 28
    
    ACC_NUM     equ 0
    ACC_HOLDER  equ 2
    ACC_BAL     equ 23
    ACC_STATE   equ 27
    
    ; Variables para el manejo de cuentas
    ACCOUNTS    db ACC_SIZE * MAX_ACC dup(?) ; Define el espacio de memoria para diez cuentas.
    ACC_COUNT   db 0 ; Contador de cuentas 
                   
    CURRENT_ACC dw ? ; Cuenta seleccionada
    
    HOLDER_INPUT        db 21, ?, 21 dup(?)
    ACC_NUM_INPUT       db 6, ?, 6 dup(?)
    NUMBER32_INPUT      db 11, ?, 11 dup(?)
    
.CODE

; En number32_input debe de estar el numero
; Recibe AX, BX, CX y DX en 0   alta:baja 
; Devuelve en AX, DX un numero    dx:ax
; de 32 bits.                     bx:cx

convert_32 PROC
    mov ax, 0 ; Limpiar cuatro registros para convertir un numero de 32 bits
    mov bx, 0 
    mov cx, 0
    mov dx, 0
    
    xor di, di
    mov dl, [NUMBER32_INPUT+1]
    mov di, dx
    xor dx, dx
    lea si, NUMBER32_INPUT+2

convert_loop:
    cmp di, 0
    je exit
                    
    mov bl, [si]
    sub bl, '0'
    
    push bx
    
    shl ax, 1   
    rcl dx, 1
    
    mov bx, ax
    mov cx, dx
    
    shl ax, 1
    rcl dx, 1
    
    shl ax, 1
    rcl dx, 1
    
    add ax, bx
    adc dx, cx
    
    pop bx
    
    xor bh, bh
    add ax, bx
    adc dx, 0
    
    dec di
    inc si
    jmp convert_loop  
    
exit:
    ret
    
convert_32 ENDP

create_account PROC
    mov al, MAX_ACC
    cmp ACC_COUNT, al
    jae acc_limit ; Se fija si hay espacio para una nueva cuenta
    
    mov ah, 0Ah
    lea dx, HOLDER_INPUT ; INPUT DE TESTEO
    int 21h
    
    lea dx, ACC_NUM_INPUT ; INPUT DE TESTEO
    int 21h
    
    lea dx, NUMBER32_INPUT
    int 21h 
    
    xor ax, ax ; Limpiar registros
    xor cx, cx
    xor dx, dx
    xor bh, bh
    mov cl, [ACC_NUM_INPUT+1] ; Numero de caracteres que el usuario ingreso
    lea si, ACC_NUM_INPUT+2   ; La direccion de memoria donde empieza el string

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
    xor ax, ax               ; Estas lineas se utilizan para calcular
    mov al, ACC_COUNT        ; la direccion de memoria de la cuenta que vamos a crear
    mov bl, ACC_SIZE         ; de la siguiente forma: ACCOUNTS + ACC_SIZE * ACC_COUNT
    mul bl
    lea si, ACCOUNTS
    add si, ax
    mov CURRENT_ACC, si
    
    mov [si+ACC_NUM], dx     ; Guarda el numero de cuenta
    mov [si+ACC_STATE], 1    ; Colocamos el estado de la cuenta en activa (0 = inactiva, 1 = activa)
    lea di, HOLDER_INPUT     ; Primer byte del de input
    mov cl, [di+1]           ; Contador de caracteres, para un el loop de copy_acc_holder
    lea di, HOLDER_INPUT+2   ; Primer caracter del input
    lea si, si+ACC_HOLDER    ; Primer caracter del arreglo de la cuenta
    mov bx, ax
    
copy_acc_holder:
    mov dx, 0   
    
    mov al, [di]          ; Copiar del input a la cuenta que estamos creando
    mov [si], al
    
    inc di                ; Cambiamos de byte (caracter) para el input y el arreglo de la cuenta      
    inc si                       
    
    loop copy_acc_holder         
    
    mov al, '$'                  ; Al final de la cadena del nombre se le coloca $ para poder imprimir
    mov [si], al                 ; sin usar un loop

    call convert_32
    
    mov si, CURRENT_ACC
    
    mov [si+ACC_BAL], ax
    mov [si+ACC_BAL+2], dx
    
    inc ACC_COUNT
    ret    
     
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
    
    call create_account
    call create_account 
    
    call end_program
END main