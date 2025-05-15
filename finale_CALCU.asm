.MODEL SMALL
.STACK 100H

.DATA
    menuText     DB 13,10, 'Select option:',13,10
                 DB '1. Add',13,10
                 DB '2. Subtract',13,10
                 DB '3. Multiply',13,10
                 DB '4. Divide',13,10
                 DB 'Enter choice: $'

    prompt1      DB 13,10, 'Enter first digit (0-9): $'
    prompt2      DB 13,10, 'Enter second digit (0-9): $'
    resultMsg    DB 13,10, 'Result: $'
    negativeMsg  DB 13,10, 'Error: Negative result not supported.',13,10,'$'
    divisionError DB 13,10, 'Error: Division by zero not allowed.',13,10,'$'
    invalidInput DB 13,10, 'Invalid input.',13,10,'$'
    tensDigit    DB ?
    onesDigit    DB ?

.CODE
MAIN:
    MOV AX, @DATA
    MOV DS, AX

    ; Display menu
    LEA DX, menuText
    MOV AH, 09h
    INT 21h

    ; Get user choice
    MOV AH, 01h
    INT 21h
    MOV BL, AL

    CMP BL, '1'
    JE ADDITION

    CMP BL, '2'
    JE SUBTRACTION

    CMP BL, '3'
    JE MULTIPLICATION

    CMP BL, '4'
    JE DIVISION

    ; Invalid choice
    LEA DX, invalidInput
    MOV AH, 09h
    INT 21h
    JMP EXIT

; -------------------------------
ADDITION:
    CALL GET_INPUT
    ADD BH, AL          ; BH = BH + AL
    CALL DISPLAY_TWO_DIGIT_RESULT
    JMP EXIT

; -------------------------------
SUBTRACTION:
    CALL GET_INPUT
    CMP BH, AL
    JL NEGATIVE_RESULT
    SUB BH, AL          ; BH = BH - AL
    CALL DISPLAY_TWO_DIGIT_RESULT
    JMP EXIT

; -------------------------------
MULTIPLICATION:
    CALL GET_INPUT
    MOV AL, BH          ; First number in AL
    MOV BL, AL          ; Save first number in BL (we'll need it later)
    CALL GET_SECOND_INPUT ; Get second number in AL
    MUL BL              ; AX = AL * BL
    MOV BH, AL          ; Move result to BH
    CALL DISPLAY_TWO_DIGIT_RESULT
    JMP EXIT

; -------------------------------
DIVISION:
    CALL GET_INPUT
    CMP AL, 0
    JE DIVISION_ERROR
    MOV BL, AL          ; Store divisor in BL
    MOV AL, BH          ; Move dividend to AL
    MOV AH, 0           ; Clear AH for division
    DIV BL              ; AL = AX / BL, AH = remainder
    MOV BH, AL          ; Move quotient to BH
    CALL DISPLAY_TWO_DIGIT_RESULT
    JMP EXIT

; -------------------------------
GET_INPUT:
    ; Get first number
    LEA DX, prompt1
    MOV AH, 09h
    INT 21h
    MOV AH, 01h
    INT 21h
    SUB AL, '0'
    MOV BH, AL          ; Store first number in BH

    ; Get second number
GET_SECOND_INPUT:
    LEA DX, prompt2
    MOV AH, 09h
    INT 21h
    MOV AH, 01h
    INT 21h
    SUB AL, '0'
    RET

; -------------------------------
DISPLAY_TWO_DIGIT_RESULT:
    ; BH contains the result (0-99)
    LEA DX, resultMsg
    MOV AH, 09h
    INT 21h

    CMP BH, 9
    JLE SINGLE_DIGIT    ; If result = 9, display as single digit

    ; For two-digit numbers
    MOV AL, BH
    MOV AH, 0      ; Clear AH for division
    MOV BL, 10
    DIV BL         ; AL = quotient (tens digit), AH = remainder (ones digit)
    
    MOV tensDigit, AL
    MOV onesDigit, AH

    ; Display tens digit
    MOV DL, tensDigit
    ADD DL, '0'
    MOV AH, 02h
    INT 21h

    ; Display ones digit
    MOV DL, onesDigit
    ADD DL, '0'
    MOV AH, 02h
    INT 21h
    RET

SINGLE_DIGIT:
    ; Display single digit
    MOV DL, BH
    ADD DL, '0'
    MOV AH, 02h
    INT 21h
    RET

; -------------------------------
NEGATIVE_RESULT:
    LEA DX, negativeMsg
    MOV AH, 09h
    INT 21h
    JMP EXIT

; -------------------------------
DIVISION_ERROR:
    LEA DX, divisionError
    MOV AH, 09h
    INT 21h
    JMP EXIT

; -------------------------------
EXIT:
    MOV AH, 4Ch
    INT 21h

END MAIN