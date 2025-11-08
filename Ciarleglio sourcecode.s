.data
myplaintext: .string "Prog3tto 4sseMBly!123"
sostK: .word 14
blocKey: .string "OLE"
mycypher: .string "ABSCD"

.text
la a0,myplaintext  #indirizzo stringa da cifrare
la a1,mycypher     #indirizzo stringa di controllo
la s0,blocKey      #chiave per cifrario a blocchi
lw s1,sostK        #chiave per cifrario a sostituzione
li t0,0
li t1,10000
la a2,0x0000114c  #indirizzo pila per occorrenze

Copia:   #il metodo Copia crea una copia di myplaintext in una parte di memoria libera (in questo modo si evitano problemi di sovrapposizione)
    add t2,a0,t1
    add t3,t2,t0
    add t4,a0,t0
    lb t4,0(t4)
    beq t4,zero,Cifratura  #quando finisce di copiare la stringa si passa alla cifratura
    sb t4,0(t3)
    addi t0,t0,1  #contatore (i++)
    j Copia

Cifratura:
    add a0,t2,zero   #a0 indica la stringa copiata, i vari metodi vengono applicati su a0
    #mi assicuro di azzerare tutti i registri che andrò ad utilizzare
    li t0,0
    li t1,0
    li t2,0
    li t3,0
    li t4,0
    add s8,a0,zero  #nel loop vengono contati gli elementi della stringa con indirizzo s8
    jal loop
    add s2,s3,zero  #in s2 c'è la lunghezza di myplaintext
    li t0,0
    
    add s3,a0,s2  #s3 indica la prima posizione libera dopo la stringa
    li t0,10
    sb t0,0(s3)   #si aggiunge in fondo alla stringa il carattere 10 (newline)
    addi s3,s3,1
    li t0,13
    sb t0,0(s3)   #si aggiunge in fondo alla stringa il carattere 13 (carriage return)
    li a7,4
    ecall         #stampo la stringa iniziale
    
    add s8,a1,zero #si contano anche gli elementi di mycypher, per sapere quando si deve concludere il ciclo di cifratura
    li t0,0
    jal loop
    add s10,s3,zero #in s10 c'è la lunghezza di mycypher
    
    li s9,0 #contatore di mycypher (i=0)
    jal forCifratura  #alla fine di ogni funzione il programma viene rimandato a questo punto per ricominciare il ciclo
    forCifratura:
        #utilizzo i registri da t1 a t5 per indicare i valori da ricercare in mycypher (il codice ASCII delle lettere da A ad E)
        li t0,0
        li t1,65
        li t2,66
        li t3,67
        li t4,68
        li t5,69
        add s6,a1,s9
        beq s9,s10,Decifratura  #quando il programma finisce di scorrere la stringa da sinistra a destra, si passa alla decifratura
        addi s9,s9,1
        lb s6,0(s6)
        
        #si manda nella funzione corrispondente:
        beq s6,t1,Sostituzione
        beq s6,t2,Blocchi
        beq s6,t3,Occorrenze
        beq s6,t4,Dizionario
        beq s6,t5,Inversione
        j exit #esce se non trova nessuna lettera tra A ed E, ma se mycypher è scritta correttamente non dovrebbe mai arrivare a questo punto
    
Decifratura:   
    jal forDecifratura   #alla fine di ogni funzione il programma viene rimandato a questo punto per ricominciare il ciclo
    forDecifratura:
        li t0,0
        li t1,65
        li t2,66
        li t3,67
        li t4,68
        li t5,69
        blt s9,zero,exit  #quando si finisce di scorrere tutta la stringa anche da destra a sinistra, il programma termina
        add s6,a1,s9
        addi s9,s9,-1     #si decrementa il contatore per scorrere la stringa da destra a sinistra
        lb s6,0(s6)
        
        #si manda nella funzione corrispondente:
        beq s6,t1,SostituzioneInverso
        beq s6,t2,BlocchiInverso
        beq s6,t3,OccorrenzeInverso
        beq s6,t4,DizionarioInverso
        beq s6,t5,InversioneInverso
     
loop:                      #conta gli elementi di una stringa (in s8)
    add t1,s8,t0   
    lb t2, 0(t1)
    beq t2,zero,end_loop   #if(t2==0) end_loop (dopo la fine della stringa c'è zero)
    addi t0,t0,1           #incrementa i
    j loop
end_loop:
    add s3,t0,zero #lunghezza salvata in s3
    jr ra 

Sostituzione: 
    li t0,0
    li t1,90
    li t2,97
    li t3,65
    li t4,122
    forSost:
        add s3,a0,t0
        lb s4,0(s3)         #elemento da cifrare
        beq s4,zero,fineSost  #il for termina dopo aver scorso tutta la stringa
        
        ble s4,t1,maiuscole  #if(myplaintext[i]<=90)
        bge s4,t2,minuscole  #if(myplaintext[i]>=97)
        j incremento
        
    maiuscole:  
        blt s4,t3,incremento #if(myplaintext[i]<65)
        add s4,s4,s1
        blt s4,t3,adj1       #nel caso in cui la somma tra elemento e chiave sia <65
        bgt s4,t1,adj2       #nel caso in cui la somma tra elemento e chiave sia >90
        j incremento
        adj1:
            sub s4,t3,s4
            sub s4,t1,s4
            addi s4,s4,1
            j incremento
        adj2:
            sub s4,s4,t1
            add s4,s4,t3
            addi s4,s4,-1
            j incremento
    minuscole:  
        bgt s4,t4,incremento #if(myplaintext[i]>122)
        add s4,s4,s1
        blt s4,t2,adj3       #nel caso in cui la somma tra elemento e chiave sia <97
        bgt s4,t4,adj4       #nel caso in cui la somma tra elemento e chiave sia >122
        j incremento
        adj3:
            sub s4,t2,s4
            sub s4,t4,s4
            addi s4,s4,1
            j incremento
        adj4:
            sub s4,s4,t4
            add s4,s4,t2
            addi s4,s4,-1
            j incremento
    incremento:       #sostituisce la lettera con la lettera cifrata e incrementa il contatore, facendo poi ripartire il ciclo
        sb s4,0(s3)
        addi t0,t0,1
        j forSost
    fineSost:
        ecall
        jr ra  #torna alla cifratura

SostituzioneInverso:  
    li t1,90
    li t2,97
    li t3,65
    li t4,122
    forSostInv:
        add s3,a0,t0
        lb s4,0(s3)  #elemento da decifrare
        beq t0,s2,fineSostInv
        ble s4,t1,maiuscoleInv  #if(myplaintext[i]<=90)
        bge s4,t2,minuscoleInv  #if(myplaintext[i]>=97)
        j incrementoInv
        
        maiuscoleInv:
            blt s4,t3,incrementoInv #if(myplaintext[i]<65)
            sub s4,s4,s1
            blt s4,t3,adj5      #nel caso in cui la somma tra elemento e chiave sia <65
            bgt s4,t1,adj6       #nel caso in cui la somma tra elemento e chiave sia >90
            j incrementoInv
        adj5:
            sub s4,t3,s4
            sub s4,t1,s4
            addi s4,s4,1
            j incrementoInv
        adj6:
            sub s4,s4,t1
            add s4,s4,t3
            addi s4,s4,-1
            j incrementoInv
        minuscoleInv:
            bgt s4,t4,incrementoInv #if(myplaintext[i]>122)
            sub s4,s4,s1
            blt s4,t2,adj7       #nel caso in cui la somma tra elemento e chiave sia <97
            bgt s4,t4,adj8       #nel caso in cui la somma tra elemento e chiave sia >122
            j incrementoInv
        adj7:
            sub s4,t2,s4
            sub s4,t4,s4
            addi s4,s4,1
            j incrementoInv
        adj8:
            sub s4,s4,t4
            add s4,s4,t2
            addi s4,s4,-1
            j incrementoInv
    incrementoInv:
        sb s4,0(s3)
        addi t0,t0,1
        j forSostInv
    fineSostInv:
        ecall
        jr ra   #torna alla decifratura

Blocchi:    
    add s8,s0,zero
    add s4,ra,zero
    jal loop  #dopo questo in s3 ci sarà la lunghezza di blocKey
    add ra,s4,zero
    
    li t0,0
    li t1,0  #determina quale carattere di blocKey scegliere
    li t2,96
    forBlocchi:
        add s4,a0,t0
        lb s5,0(s4)    #elemento da modificare
        beq t0,s2,fineBlocchi
        add s6,s0,t1   #carattere in base al quale modificare s5
        lb s7,0(s6)
        #applica 32+[cod(b)+cod(key)]mod96
        add s5,s5,s7
        bge s5,t2,modulo
        j notModulo
        modulo:
            sub s5,s5,t2
            bge s5,t2,modulo 
        notModulo:
        addi s5,s5,32
        
        addi t1,t1,1
        beq t1,s3,azzera  #quando lo scorrimento di blocKey è terminato si riparte daccapo
        j notAzzera
        azzera:
            li t1,0
        notAzzera:
        addi t0,t0,1
        sb s5,0(s4)  #sostituisce con il nuovo carattere
        j forBlocchi
        
    fineBlocchi:
        ecall
        jr ra
        
BlocchiInverso:
    li t0,0
    add s8,s0,zero
    add s4,ra,zero
    jal loop   #dopo questo in s3 ci sarà la lunghezza di blocKey
    add ra,s4,zero
    
    li t0,0
    li t1,0  #determina quale carattere di blocKey scegliere
    li t2,32
    
    forBlocchiInv:
        add s4,a0,t0
        lb s5,0(s4)
        beq t0,s2,fineBlocchiInv  
        add s6,s0,t1
        lb s7,0(s6)
        #applica l'operazione inversa
        sub s5,s5,s7 
        addi s5,s5,-32
        addi s5,s5,96 
        blt s5,t2,moduloInv
        j notModuloInv
        moduloInv:
            addi s5,s5,96 
            blt s5,t2,moduloInv
        notModuloInv:
        addi t1,t1,1
        beq t1,s3,azzeraInv
        j notAzzeraInv
        azzeraInv:
            li t1,0
        notAzzeraInv:
        addi t0,t0,1
        sb s5,0(s4)  #carica il nuovo carattere
        j forBlocchiInv
    fineBlocchiInv:
        ecall
        jr ra
        
Occorrenze:
    addi a2,a2,1 
    add s8,a0,zero
    add s4,ra,zero
    jal loop
    add ra,s4,zero
    add s2,s3,zero   #si calcola la lunghezza attuale della stringa
    sb s2,0(a2)      #nel prossimo carattere della pila in a2 verrà salvata la lunghezza della stringa prima dell'applicazione di Occorrenze
    
    li t0,0
    li t3,0
    addi gp,gp,1000  #utilizzo un registro più lontano per non rischiare di sovrascrivere stringhe di lunghezze diverse
    forOcc:
    add t1,a0,t0
    lb t2,0(t1)
    addi t0,t0,1
    bgt t0,s2,fineOcc   #una volta scorsa tutta la stringa, il ciclo for termina
    li t1,10
    beq t2,t1,fineOcc   #termina anche se trova il valore 10, in quanto dopo alcune cifrature troviamo 10 alla fine della stringa (newline)
    add t1,gp,t3
    
    li t4,2
    beq t2,t4,forOcc  #il ciclo passa all'elemento successivo se trova 2, che è il valore con cui vengono contrassegnati i caratteri già analizzati
    sb t2,0(t1)
    addi t3,t3,1      #t3 è il contatore della nuova stringa che si genera
    
    loop_2:                    #se si trova un carattere uguale a quello che si sta esaminando, se ne salva la posizione
        add a3,a0,a4
        lb t5,0(a3) 
        beq a4,s2,space        #quando termina la stringa, si scrive uno spazio e si passa al prossimo carattere da analizzare
        addi a4,a4,1
        beq t5,t2,posizione_trovata
        j loop_2 
    posizione_trovata:
        li t4,2
        sb t4,0(a3)  #sostituisce l'elemento già salvato con un valore null (2)
        li t4,45
        add t1,t3,gp
        sb t4,0(t1)   #aggiunge il trattino nella nuova stringa
        addi t3,t3,1  #il contatore viene incrementato
        add t1,t3,gp 
        li t4,9
        add t5,a4,zero
        bgt t5,t4,piu_cifre  #questo serve per stampare bene indici composti da numeri a più cifre, dato che in ASCII ci sono solo 10 cifre
        addi a5,a4,48        #trasforma in ASCII
        sb a5,0(t1)          #lo salva nella nuova stringa
        addi t3,t3,1
        j loop_2
    piu_cifre:
        beq t5,zero,salvataggio
        add s4,ra,zero
        add a5,t5,zero
        jal modulo10   #esegue l'operazione di modulo per trovare la singola cifra
        add ra,s4,zero
        addi a5,a5,48  #trasforma la cifra in ASCII
        addi sp,sp,-1
        sb a5,0(sp)    #salva il valore in una pila
        li t4,10
        div t5,t5,t4   #quando dividerà per 10 e avrà come risultato 0, l'operazione del modulo sarà terminata
        j piu_cifre
    salvataggio:
        lb t5,0(sp)    #vengono aggiunti alla nuova stringa i valori salvati nella pila, che appariranno nella stringa come numeri a più cifre
        addi sp,sp,1
        beq t5,zero,loop_2
        sb t5,0(t1)
        addi t3,t3,1
        add t1,t3,gp
        j salvataggio
    space:
        add t1,t3,gp  #scrive uno spazio quando le occorrenze di una lettera sono state trovate tutte (ogni volta che scorre tutta la stringa)
        addi t3,t3,1
        li t4,32
        sb t4,0(t1)
        li a4,0
        j forOcc
    modulo10:
        li t6,9
        ble t5,t6,noModulo
        addi a5,a5,-10
        bgt a5,t6,modulo10  #si sottrae 10 finché il numero non è <9
        noModulo:
        jr ra
    fineOcc:
        add s8,gp,zero
        add t4,ra,zero
        jal loop
        add s2,s3,zero  #in s2 c'è la lunghezza della stringa dopo occorrenze
        add ra,t4,zero
        
        add t4,gp,s2
        #anche qui vengono aggiunti 10 e 13 per andare ad una nuova riga
        li t0,10
        sb t0,0(t4)
        addi t4,t4,1
        li t0,13
        sb t0,0(t4)
        
        add a0,gp,zero  #a0 prende l'indirizzo della nuova stringa
        ecall
        jr ra
    
OccorrenzeInverso:
    add t1,a0,t0
    lb t2,0(t1)
    addi t0,t0,2
    beq t2,zero,fineOccInv
    la s5,0x000005dc   #si crea una nuova stringa in una parte libera di memoria (a causa di lunghezze diverse date dal metodo potrebbero esserci sovrapposizioni altrimenti)

    loop_3:
        add t1,a0,t0
        lb t3,0(t1)  #elemento da considerare
        li t4,32
        beq t4,t3,spazio
        li t4,45
        beq t4,t3,trattino
        
        addi t1,t1,1
        lb t5,0(t1)
        addi t5,t5,-48
        li t4,10
        blt t5,t4,piu_cifre_2  #si gestiscono gli indici a più cifre
        
        continuo:
        addi t3,t3,-49 #si porta in decimale (-48-1)
        add t1,s5,t3
        sb t2,0(t1)    #in posizione t3 (indirizzo t1) si posiziona l'elemento analizzato
        
        addi t0,t0,1
        add t1,a0,t0
        lb t3,0(t1)
        beq t3,zero,fineOccInv  #quando si finisce di scorrere la stringa il metodo termina
        li t4,45
        beq t4,t3,trattino
        li t4,32
        beq t4,t3,spazio
        
        j OccorrenzeInverso
    #se si trova un trattino o uno spazio, si va semplicemente avanti con lo scorrimento, in quanto si stanno cercando solo le cifre
    trattino:
        addi t0,t0,1
        j loop_3                #se c'è un trattino, si continuano a cercare gli indici della lettera che si sta analizzando
    
    spazio:
        addi t0,t0,1
        j OccorrenzeInverso    #se c'è uno spazio, si passa alla prossima lettera
   
   piu_cifre_2:        #esegue le operazioni inverse di piu_cifre
       li t4,0
       blt t5,t4,continuo
       li t4,10
       addi t3,t3,-48
       mul t3,t3,t4
       add t3,t3,t5
       addi t3,t3,-1
       add t1,s5,t3
       sb t2,0(t1)
       addi t0,t0,2
       j loop_3
        
    fineOccInv:
        lb t0,0(a2)        #si riprende la vecchia lunghezza della stringa (prima di Occorrenze)
        add s2,t0,zero
        addi s2,s2,-2      #-2 perché nella stringa venivano contati anche 10 e 13
        addi a2,a2,-1      #si decrementa la pila, in questo modo alla prossima decifratura di occorrenze si riprenderà la lunghezza ancora precedente
        
        li t0,0
        addi a0,a0,1000    #la stringa viene copiata in una parte di memoria libera
        copia:
            beq t0,s2,fineCopia
            add t1,s5,t0
            lb t1,0(t1)
            add t2,a0,t0
            sb t1,0(t2)
            addi t0,t0,1
            j copia
            
        fineCopia:
        add s4,a0,s2
        li t0,10
        sb t0,0(s4)
        li t0,13
        addi s4,s4,1
        sb t0,0(s4)
        ecall
        jr ra

Dizionario:
    li t1,97
    li t2,122
    li t3,65
    li t4,90
    li t5,48
    li t6,57        #valori che dobbiamo considerare (estremi degli intervalli su cui dobbiamo lavorare in ASCII)
    
    add s3,a0,t0
    lb s4,0(s3)
    beq t0,s2,fineDiz    #il metodo termina dopo aver scorso l'intera stringa
    ble s4,t2,min        #se l'elemento è <=122, allora potrebbe essere una minuscola
    j sym                #altrimenti è un simbolo
    
    min:
        ble s4,t4,mai    #se è <=90, potrebbe essere una maiuscola
        blt s4,t1,sym    #se è <97 (ma >90) allora è un simbolo
        sub s5,s4,t1     #altrimenti è una minuscola, quindi si codifica come una minuscola
        sub s5,t4,s5
        j incrementa
        
    mai:
        ble s4,t6,num    #se è <=57, potrebbe essere un numero
        blt s4,t3,sym    #se è <65 (ma >57) allora è un simbolo
        sub s5,s4,t3     #altrimenti è una maiuscola, quindi si codifica come una maiuscola
        sub s5,t2,s5
        j incrementa
        
    num:
        blt s4,t5,sym    #se è <48, allora è un simbolo
        sub s5,s4,t5     #altrimenti è un numero, quindi si codifica come un numero
        sub s5,t6,s5
        j incrementa
        
    sym:
        add s5,s4,zero    #i simboli restano invariati
    
    incrementa:
        sb s5,0(s3)
        addi t0,t0,1
        j Dizionario
    fineDiz:
        li t1,10
        sb t1,0(s3)
        ecall
        jr ra
        
DizionarioInverso:         #la decifratura di Dizionario funziona esattamente come la sua cifratura
    li t1,97
    li t2,122
    li t3,65
    li t4,90
    li t5,48
    li t6,57
    
    add s3,a0,t0
    lb s4,0(s3)
    beq t0,s2,fineDizInv
    ble s4,t2,minInv
    j symInv
    
    minInv:
        ble s4,t4,maiInv
        blt s4,t1,symInv
        sub s5,s4,t1
        sub s5,t4,s5
        j incrementaInv
        
    maiInv:
        ble s4,t6,numInv
        blt s4,t3,symInv
        sub s5,s4,t3
        sub s5,t2,s5
        j incrementaInv
        
    numInv:
        blt s4,t5,symInv
        sub s5,s4,t5
        sub s5,t6,s5
        j incrementaInv
        
    symInv:
        add s5,s4,zero
    
    incrementaInv:
        sb s5,0(s3)
        addi t0,t0,1
        j DizionarioInverso
    fineDizInv:
        li t1,10
        sb t1,0(s3)
        ecall
        jr ra
        
Inversione:
    li t0,0
    la s3,0x00000650         #si lavora su una nuova stringa
    addi t1,s2,-1            #puntatore della nuova stringa (parte dall'ultima posizione)
    forInversione:
    add t2,a0,t0
    lb t3,0(t2)             #elemento da copiare nella nuova stringa
    add t4,s3,t1            #si considera la posizione (s2-i) della nuova stringa e si posiziona in essa l'elemento
    sb t3,0(t4)
    beq t0,s2,fineInversione    #il metodo termina quando finisce di scorrere la stringa
    addi t0,t0,1   #il contatore di a0 si incrementa
    addi t1,t1,-1  #il contatore di s3 si decrementa
    j forInversione
    fineInversione:
        #in fondo si aggiungono i caratteri per andare a capo
        add t1,s3,s2
        li t0,10
        sb t0,0(t1)
        addi t1,t1,1
        li t0,13
        sb t0,0(t1)
        li t0,0
        
        copia_stringa:   #si copia la stringa nell'indirizzo a0
            add t1,a0,t0
            add t2,s3,t0
            addi t4,s2,2
            beq t0,t4,fine_copia
            lb t3,0(t2)
            sb t3,0(t1)
            sb zero,0(t2)
            addi t0,t0,1
            j copia_stringa
        fine_copia:
        ecall
        jr ra
        
InversioneInverso:            #la decifratura di Inversione funziona esattamente come la sua cifratura
    li t0,0
    la s3,0x00000650
    addi t1,s2,-1
    forInversioneInv:
    add t2,a0,t0
    lb t3,0(t2)
    add t4,s3,t1
    beq t0,s2,fineInversioneInv
    sb t3,0(t4)
    addi t0,t0,1
    addi t1,t1,-1
    j forInversioneInv
    
    fineInversioneInv:
        li t0,0
        add t1,s3,s2
        li t0,10
        sb t0,0(t1)
        addi t1,t1,1
        li t0,13
        sb t0,0(t1)
        li t0,0
        li t1,0
        
        copia_stringaInv:
            add t1,a0,t0
            add t2,s3,t0
            addi t4,s2,2
            beq t0,t4,fine_copiaInv
            lb t3,0(t2)
            sb t3,0(t1)
            sb zero,0(t2)
            addi t0,t0,1
            j copia_stringaInv
        fine_copiaInv:
        ecall
        jr ra

exit:
    li t0,0