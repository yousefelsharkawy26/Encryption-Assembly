.MODEL SMALL

.DATA
    LOGO   db '                       Welcome In BitCode Team', 0dh,0ah,
    LOGO2  db '|          |                 |           |                      ', 0dh,0ah,
    LOGO3  db '|          |    -----        |           |          ---------   ', 0dh,0ah,
    LOGO4  db '|          |   |     |       |           |         |         |  ', 0dh,0ah,
    LOGO5  db '|__________|   |     |       |           |         |         |  ', 0dh,0ah,
    LOGO6  db '|          |   |-----        |           |         |         |  ', 0dh,0ah,
    LOGO7  db '|          |   |             |           |         |         |  ', 0dh,0ah,
    LOGO8  db '|          |   |             |           |         |         |  ', 0dh,0ah,
    LOGO9  db '|          |   |             |           |          ---------   ', 0dh,0ah,
    LOGO10 db '|          |   |__________   |______     |______                ', 0dh,0ah, '$'
    FileName db 10 dup(' '), 0
    fhandle dw ?    ; load an existing file in pc 
    FMsg db 0dh,0ah, "Enter your Text : ", "$"
    FileNameMsg db 0dh,0ah, "Enter your FileName + Extension .txt : ", "$"    
    MainMsg db 0dh,0ah," 1- New File",0dh,0ah, " 2- Open Existing File",0dh,0ah, ' 3- Encrypt Or Decrypt Existing File', 0dh,0ah,'$'
    Line db 0dh,0ah, '$'
    ErrorMsg db 0dh,0ah,'  We Find an error in this step', 0dh,0ah, '$'
    ErrorMsg_2 db 0dh,0ah,'  Choose Correct Number Between 1 - 3 : ', '$'
    ReturnMsg db 0dh,0ah,'  Do you want to go back to main menu [y / n] : ', '$'
    SucessMsg db 0dh,0ah, 0dh,0ah,'    Done :)', '$'
    buffer db 200 dup(' '), "$"

.STACK

.CODE
    MAIN PROC FAR
    .STARTUP
    Call StartProgram
        
    .EXIT
    MAIN ENDP
    
    StartProgram PROC NEAR
       CALL Logo
       CALL SecondScreen 
    RET
    
    Logo PROC NEAR
       LEA DX, LOGO
       MOV AH, 09H
       INT 21H
    RET
    
    SecondScreen PROC NEAR
        LEA DX, MainMsg
        MOV AH, 09H
        INT 21H
        
    ReadNumber:
        MOV AH, 01H
        INT 21H
        
        CMP AL, '1'
        JE NewFile
        
        CMP AL, '2'
        JE ExistingFile
        CMP AL, '3'
        JE EncryptExistingFile
        JNE ErrorMessage
        
    ErrorMessage:
        LEA DX,ErrorMsg_2
        MOV AH, 09H
        INT 21H
        JMP ReadNumber
        
    NewFile:
        Call ClearScreen
        Call ReadFileName
        Call CreateNewFile
        Call EmptyBuffer

        Call ClearScreen
        call OpenFile
        Call InputText
        CALL CloseFile
        LEA DX, SucessMsg
        MOV AH, 09H
        INT 21H
        CALL RepeatOrder
        RET
    ExistingFile:  
        Call ClearScreen        
        Call ReadFileName
        call OpenFile
        call ReadFile
        CALL EncryptDecrypt
        Call CloseFile
        LEA DX, buffer
        MOV AH, 09H
        INT 21H
        CALL RepeatOrder

        RET
        
    EncryptExistingFile:
        Call ClearScreen        
        Call ReadFileName
        call OpenFile
        call ReadFile
        
        LEA DX, buffer
        MOV AH, 09H
        INT 21H
        
        Call Encryption
        
        Call CloseFile
        LEA DX, SucessMsg
        MOV AH, 09H
        INT 21H
        
        CALL RepeatOrder
        RET
    
    RepeatOrder PROC NEAR
        
        LEA DX, ReturnMsg
        MOV AH, 09H
        INT 21H
        
        MOV AH, 01H
        INT 21H
        
        CMP AL, 'y'
        JE RepeatMain
        CMP AL, 'Y'
        JE RepeatMain
        JNE EXIT
        
    RepeatMain:
        CALL ClearScreen
        CALL SecondScreen 
        
    EXIT:
    RET
    
    ReadFileName PROC NEAR
        LEA DX, FileNameMsg
        MOV AH, 09H
        INT 21H
        
        MOV SI, 0
        MOV CX, 0
        
    Again2:
            MOV AH, 01H
            int 21h
            CMP AL, 13
            JE exit_FileName
            MOV FileName[SI], AL
            INC SI
            INC CX
            JMP Again2
        exit_FileName:
    RET
    
    Encryption PROC NEAR
        CALL EncryptDecrypt
        CALL CreateNewFile
        
        CALL WriteFile
        RET
    
    EmptyBuffer PROC NEAR
        MOV CX, 200
        MOV SI, 0
        SeedBuffer:
        MOV buffer[SI], ' '
        INC SI
        LOOP SeedBuffer
    RET
    
    InputText PROC NEAR
        lea dx, FMsg
        mov ah, 09h
        int 21h
    
        MOV SI, 0
        MOV CX, 0
        
        Again:
            MOV AH, 01H
            int 21h
            CMP AL, 13
            JE exit
            MOV buffer[SI], AL
            INC SI
            INC CX
            JMP Again
            
        exit:
            CALL Encryption
            Mov ah, 0
        RET
        
    
    EncryptDecrypt PROC NEAR
        MOV SI, 0
        MOV CX, 0
        
        A:
            CMP buffer[SI], ' '
            JE B
            XOR buffer[SI], 1
        B:
            INC SI
            INC CX
            CMP buffer[SI], '$'
            JNE A
        ret
        
    CreateNewFile PROC NEAR
        MOV AH, 3CH
        LEA DX, FileName
        MOV CL, 0  ;Attribute value 0 for read only 
        INT 21H
        MOV fhandle, ax
        JC if_error
        ret
     
     CloseFile PROC NEAR
        MOV AH, 3EH
        MOV BX, fhandle
        INT 21H
        JC if_error
        ret
        
     OpenFile PROC NEAR
        MOV AH, 3DH
        LEA DX, FileName
        MOV AL, 2        ;0 for read 1 for write 2 for read and write
        INT 21H
        MOV fhandle, AX
        JC if_error
        ret
     
     ReadFile PROC NEAR
        MOV AH, 3FH
        LEA DX, buffer
        MOV CX, 200
        MOV BX, fhandle
        INT 21H
        JC if_error
        ret
     
     WriteFile PROC NEAR
        MOV AH, 40H
        MOV BX, fhandle
        LEA DX, buffer
        MOV CX, 100              ; Number Of Characters
        INT 21H
        JC if_error
        ret
     LineBreak PROC NEAR
        LEA DX, Line
        MOV AH, 09H
        INT 21H
        
        RET
        
     ClearScreen PROC NEAR
         MOV AX,0600H
         MOV BH,07
         MOV CX,0000
         MOV DX,184FH
         INT 10H
         
         MOV AH,2
         MOV BH,00
         MOV DL,00
         MOV DH,00
         INT 10H
         CALL Logo
        RET   
        
    if_error:
        PUSH DX
        PUSH AX
        LEA DX, ErrorMsg
        MOV AH, 2H
        INT 21H
        POP AX
        POP DX
        ret
        
END MAIN