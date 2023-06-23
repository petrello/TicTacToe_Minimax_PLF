/* Programma Prolog che implementa il gioco del Tic-Tac-Toe 
   singolo giocatore con algoritmo di ottimiazzazione Minimax. 
   
   Nota: con "Giocatore" si fa riferimento al giocatore pilotato
   dall'utente, mentre con "CPU" ci si riferisce a quello pilotato
   dal computer. 
   
   Nota: nel programma si rappresenta la griglia di gioco ed il suo
   stato attraverso una lista di caratteri. I controlli fatti
   su questa lista non saranno particolarmente stringenti dato che 
   questa viene gestita interamente dal programma e quindi si 
   garantisce una correttezza intrinseca. */


/***************************************************************************
 **                      INIZIALIZZAZIONE DEL GIOCO                       **
 **************************************************************************/

main :- 
    write('Gioco del Tic-Tac-Toe!'), nl, nl,
    gioca.


/* Il predicato gioca inizializza l'interazione con il Giocatore
   acquisendo un carattere:
    - 's' allora si inizia una nuova partita;
    - 'h' vengono mostrate le regole al Giocatore. */

gioca :- 
    write('Digita \'s\' per iniziare a giocare oppure \'h\' per'),
    write(' consultare le regole:'), nl,
    get_char(C),
    pulisci_input_buffer,
    inizio_gioco(C).


/* Il predicato inizio_gioco gestisce la richiesta del Giocatore:
   - l'argomento è il comando dato dal Giocatore.
   La partita favorisce sempre il Giocatore che quindi partirà per primo. */

inizio_gioco(C) :- 
    C = 's',
    partita([' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '], 1, 1).
inizio_gioco(C) :- 
    C = 'h',
    mostra_regole,
    gioca.
inizio_gioco(C) :- 
    C \= 's', C \= 'h',
    write('Input \"'), write(C), write('\" non valido.'), nl,
    gioca.


/***************************************************************************
 **                IMPLEMENTAZIONE PREDICATI DI UTILITÀ                   **
 **************************************************************************/

/* Il predicato mostra_regole si occupa di mostrare al Giocatore le regole
   del gioco. */

mostra_regole :- 
    nl, write('REGOLE DEL GIOCO:'), nl,
    write(' - il primo turno spetta al Giocatore;'), nl,
    write(' - al Giocatore viene assegnato il simbolo \'o\';'), nl,
    write(' - a CPU viene assegnato il simbolo \'x\';'), nl,
    write(' - vince chi riesce a disporre tre dei propri simboli in linea'),
    write(' retta orizzontale, verticale o diagonale;'), nl,
    write(' - se la griglia viene riempita senza che nessuno dei'),
    write(' giocatori sia riuscito a completare una linea'),
    write(' retta di tre simboli, il gioco finisce in parità.'), nl, nl,
    write('COME FARE UNA MOSSA:'), nl,
    write(' - fare una mossa vuol dire digitare il numero che corrisponde'),
    write(' alla cella in cui si vuole aggiungere il proprio simbolo.'), nl,
    write('Ad esempio: digitare \'5\' per aggiungere \'o\' nella cella'),
    write(' centrale.'), nl, nl,
    write('COME SI COMPONE LA GRIGLIA:'), nl,
    write(' - la griglia si compone di nove celle;'), nl,
    write(' - le celle sono numerate da 1 a 9.'), nl, nl,
    write('GRIGLIA DI RIFERIMENTO:'), nl, nl,
    disegna_griglia(['1', '2', '3', '4', '5', '6', '7', '8', '9'], 1).


/* Il predicato disegna_griglia stampa la griglia di gioco:
   - il primo argomento è la lista contenente lo stato corrente del gioco;
   - il secondo argomento è un indice che identifica la cella da disegnare.
   Per stato corrente del gioco si intende l'insieme dei
   simboli attualmente presenti nella griglia. 
   L'uso del predicato nth permette di ottenere l'elemento all'indice
   specificato come primo argomento, della lista specificata come secondo 
   argomento. */

disegna_griglia(L, I) :- 
    mod(I, 3) =\= 0,
    nth(I, L, Y),
    write(' '), write(Y), write(' |'),
    J is I + 1,
    disegna_griglia(L, J).
disegna_griglia(L, I) :-
    (I = 3 ; I = 6),
    nth(I, L, Y),
    write(' '), write(Y), nl, write('---+---+---'), nl,
    J is I + 1,
    disegna_griglia(L, J).
disegna_griglia(L, I) :-
    I = 9,
    nth(I, L, Y),
    write(' '), write(Y), nl, nl, !.


/* Il predicato acquisisci_mossa_giocatore ottiene la mossa
   fatta dal Giocatore:
   - il primo argomento è la lista contenente lo stato corrente del gioco;
   - il secondo argomento è la lista contenente il nuovo stato del gioco.
   Il nuovo stato del gioco dipenderà dalla mossa acquisita. 
   Il predicato catch permette di implementare il costrutto try-catch. */

acquisisci_mossa_giocatore(L, NL) :-
    write('Digita il numero della cella:'), nl,
    catch(    
        (    read_integer(M),
              (    mossa_valida(L, M) *->
                   aggiorna_griglia(L, M, 'o', NL)
              ;    throw(_)
              )
         ),
         error(_, _),
         (    write('Mossa non valida.'), nl,
              pulisci_input_buffer,
              acquisisci_mossa_giocatore(L, NL)
         )
    ).


/* Il predicato mossa_cpu aggiorna la griglia di gioco aggiungendo 
   la mossa fatta da CPU:
   - il primo argomento è la lista contenente lo stato corrente del gioco;
   - il secondo argomento è la lista contenente lo stato 
     aggiornato del gioco. */

mossa_cpu(L, NL) :- 
    cerca_mossa_migliore(L, MM),
    aggiorna_griglia(L, MM, 'x', NL).


/* Il predicato pulisci_input_buffer pulisce il buffer rimuovendo i
   caratteri in eccesso.
   La pulizia non termina finché non si legge un carattere
   con codice 10 (carattere di fine linea). */

pulisci_input_buffer :- repeat, get_code(I), I = 10, !.


/* Il predicato mosse_rimaste verifica che la griglia di gioco non sia
   completamente piena:
   - l'argomento è la lista contenente lo stato corrente del gioco.
   La griglia di gioco si dice piena quando ogni sua cella è occupata
   dal un simbolo ('x' oppure 'o'). 
   Il predicato between ha successo se il terzo argomento è 
   compreso tra i primi due (inclusi). */

mosse_rimaste(L) :- between(1, 9, I), mossa_valida(L, I), !.


/* Il predicato mossa_valida verifica che una mossa sia valida:
   - il primo argomento è la lista contenente lo stato corrente del gioco;
   - il secondo argomento è la mossa che si vuole validare.
   Una mossa è valida quando la cella corrispondente è libera. */

mossa_valida(L, M) :- nth(M, L, ' ').


/* Il predicato aggiorna_griglia genera il nuovo stato della griglia di 
   gioco inserendo un simbolo ('x' oppure 'o' a seconda del giocatore)
   nella cella specificata:
   - il primo argomento è la lista contenente lo stato corrente del gioco;
   - il secondo argomento è il numero della cella che si vuole aggiornare;
   - il terzo argomento è il simbolo che si vuole aggiungere;
   - il quarto argomento è la lista contenente lo stato aggiornato 
     del gioco. */

aggiorna_griglia([_|LS], 1, S, [S|LS]).
aggiorna_griglia([TS|LS], I, S, [TS|TLS]) :-
    I > 1, I1 is I-1,
    aggiorna_griglia(LS, I1, S, TLS).


/* Il predicato stampa_risultato_partita stampa il risultato della partita.
   L'argomento indica la codifica del risultato:
   - 0 vuol dire che la partita termina in parità;
   - 1 vuol dire che Giocatore ha vinto;
   - 2 vuol dire che CPU ha vinto. */

stampa_risultato_partita(0) :- write('Pari!'), nl.
stampa_risultato_partita(1) :- write('Hai vinto!'), nl.
stampa_risultato_partita(2) :- write('Hai perso, CPU vince!'), nl.


/* Il predicato controlla_vincitore verifica se nella griglia sia presente
   una configurazione per cui si possa decretare un vincitore:
   - il primo argomento è la lista contenente lo stato corrente del gioco;
   - il secondo argomento è il simbolo per cui si vuole controllare. */

controlla_vincitore(L, S) :- controlla_righe(L, S).
controlla_vincitore(L, S) :- controlla_colonne(L, S).
controlla_vincitore(L, S) :- controlla_diagonali(L, S).


/* Il predicato controlla_righe verifica se nella griglia sia presente
   una configurazione orizzontale per cui si possa decretare un vincitore:
   - il primo argomento è la lista contenente lo stato corrente del gioco;
   - il secondo argomento è il simbolo per cui si vuole controllare. */

controlla_righe([S1, S2, S3, _, _, _, _, _, _], I) :- S1 = I, S2 = I, S3 = I.
controlla_righe([_, _, _, S4, S5, S6, _, _, _], I) :- S4 = I, S5 = I, S6 = I.
controlla_righe([_, _, _, _, _, _, S7, S8, S9], I) :- S7 = I, S8 = I, S9 = I.


/* Il predicato controlla_colonne verifica se nella griglia sia presente
   una configurazione verticale per cui si possa decretare un vincitore:
   - il primo argomento è la lista contenente lo stato corrente del gioco;
   - il secondo argomento è il simbolo per cui si vuole controllare. */

controlla_colonne([S1, _, _, S4, _, _, S7, _, _], I) :- S1 = I, S4 = I, S7 = I.
controlla_colonne([_, S2, _, _, S5, _, _, S8, _], I) :- S2 = I, S5 = I, S8 = I.
controlla_colonne([_, _, S3, _, _, S6, _, _, S9], I) :- S3 = I, S6 = I, S9 = I.


/* Il predicato controlla_diagonali verifica se nella griglia sia presente
   una configurazione diagonale per cui si possa decretare un vincitore:
   - il primo argomento è la lista contenente lo stato corrente del gioco;
   - il secondo argomento è il simbolo per cui si vuole controllare. */

controlla_diagonali([S1, _, _, _, S5, _, _, _, S9], I) :- S1 = I, S5 = I, S9 = I.
controlla_diagonali([_, _, S3, _, S5, _, S7, _, _], I) :- S3 = I, S5 = I, S7 = I.


/***************************************************************************
 **                     IMPLEMENTAZIONE LOOP DEL GIOCO                    **
 **************************************************************************/

/* Il predicato partita implementa il loop del gioco, gestendo il passsaggio
   del turno, le mosse di Giocatore e CPU, e la terminazione della partita:
   - il primo argomento è la lista contenente lo stato corrente del gioco;
   - il secondo argomento rappresenta il giocatore in possesso del turno;
   - il terzo argomento rappresenta il numero del turno raggiunto. */

/* Gestione del turno di Giocatore: secondo argomento uguale a 1. */
partita(L, 1, T)  :-
    T < 10, 
    \+(controlla_vincitore(L, 'x')), 
    disegna_griglia(L, 1), 
    acquisisci_mossa_giocatore(L, NL), 
    NT is T + 1, 
    partita(NL, 2, NT).
partita(L, 1, T)  :- 
    T < 10,
    controlla_vincitore(L, 'x'),
    disegna_griglia(L, 1),
    stampa_risultato_partita(2), !.
/* Gestione del turno di CPU: secondo argomento uguale a 2. */
partita(L, 2, T)  :- 
    T > 2, T < 10,
    \+(controlla_vincitore(L, 'o')),
    disegna_griglia(L, 1),
    mossa_cpu(L, NL),
    NT is T + 1,
    partita(NL, 1, NT).
partita(L, 2, T)  :- 
    T > 2, T < 10, 
    controlla_vincitore(L, 'o'),
    disegna_griglia(L, 1),
    stampa_risultato_partita(1), !.
/* Per decidere la prima mossa di CPU non si utilizza l'algoritmo di Minimax,
   bensì le strategie note del Tic-Tac-Toe:
   - se libera, prendere subito la cella centrale della griglia;
   - se la cella centrale è occupata, scegliere uno qualsiasi degli angoli
     della griglia. */
partita(L, 2, T)  :- 
    T =:= 2,
    mossa_valida(L, 5),
    aggiorna_griglia(L, 5, 'x', NL), 
    disegna_griglia(L, 1), 
    NT is T + 1,
    partita(NL, 1, NT).
partita(L, 2, T)  :-
    T =:= 2,
    mossa_valida(L, 1),
    aggiorna_griglia(L, 1, 'x', NL),
    disegna_griglia(L, 1), 
    NT is T + 1,
    partita(NL, 1, NT).
/* Per decidere il risultato una volta raggiunto il numero massimo
   di mosse: 10. */
partita(L, _, 10) :- 
    controlla_vincitore(L, 'o'),
    disegna_griglia(L, 1),
    stampa_risultato_partita(1), !.
partita(L, _, 10) :-
    \+(controlla_vincitore(L, 'o')),
    disegna_griglia(L, 1),
    stampa_risultato_partita(0), !.


/***************************************************************************
 **                  IMPLEMENTAZIONE ALGORITMO DI MINIMAX                 **
 **************************************************************************/

/* Il predicato cerca_mossa_migliore genera la miglior mossa possibile 
   che CPU possa fare:
   - il primo argomento è la lista contenente lo stato corrente del gioco;
   - il secondo argomento è la mossa migliore possibile.
   Per mossa migliore si intende una mossa che non consenta a Giocatore
   di concludere la partita con una vittoria.
   Il predicato findall consente di unificare in LR la lista (anche con
   duplicati) contenente tutte le istanze dei risultati R per i quali ha
   successo l'obbiettivo specificato come secondo argomento. */

cerca_mossa_migliore(L, BM) :-
    findall(
         R, 
         (    between(1, 9, I),
              (    mossa_valida(L, I),
                   aggiorna_griglia(L, I, 'x', NL),
                   minimax(NL, 0, 0, R) ->
                   true
              ;    R is -1000
              )
         ),
         LR
    ),
    max_list(LR, V),
    nth(BM, LR, V).


/* Il predicato minimax calcola il punteggio migliore ottenuto in seguito
   al compimento di una delle possibili mosse:
   - il primo argomento è la lista contenente lo stato corrente del gioco;
   - il secondo argomento è la profondità raggiunta durante la generazione
     dell'albero delle simulazioni di gioco;
   - il terzo argomento indica se la ricerca del punteggio migliore deve 
     essere fatta dal punto di vista del massimizzatore o del minimizzatore;
   - il quarto argomento è il punteggio migliore ottenuto.
   Il punteggio migliore viene cercato all'interno di una lista generata
   ad ogni punto di ramificazione lungo l'albero delle simulazioni di gioco. */

minimax(L, D, _,  BR) :- valuta(L, P), P =:= 10, BR is P - D, !.
minimax(L, D, _,  BR) :- valuta(L, P), P =:= (-10), BR is P + D, !.
minimax(L, _, _,  BR) :- \+(mosse_rimaste(L)), BR is 0, !.
minimax(L, D, IM, BR) :-
    mosse_rimaste(L),
    (    IM = 1 *->
         (    ND is D + 1,
              findall(
                  R,
                  (    between(1, 9, I),
                       (    mossa_valida(L, I),
                            aggiorna_griglia(L, I, 'x', NL),
                            minimax(NL, ND, 0, R) -> 
                            true 
                       ;    R is -1000
                       )
                  ), 
                  LR
              ),
              max_list(LR, BR)
         )
    ;    (    ND is D + 1,
              findall(
                  R, 
                  (    between(1, 9, I),
                      (    mossa_valida(L, I),
                            aggiorna_griglia(L, I, 'o', NL),
                            minimax(NL, ND, 1, R) ->
                            true
                       ;    R is 1000
                       )
                  ),
                  LR
              ),
              min_list(LR, BR)
         )
    ), !.


/* Il predicato valuta calcola il punteggio ottenuto in seguito alla 
   valutazione dello stato corrente della griglia del gioco:
   - il primo argomento è la lista contenente lo stato corrente del gioco;
   - il secondo argomento è il punteggio.
   Il punteggio vale:
   - 10 se la vittoria va a CPU;
   - -10 se la vittoria va a Giocatore;
   - 0 se non si è raggiunta una condizione di vittoria. */

valuta(L, P) :- controlla_vincitore(L, 'x'), P is 10.
valuta(L, P) :- controlla_vincitore(L, 'o'), P is (-10).
valuta(L, P) :- 
    \+(controlla_vincitore(L, 'x')), 
    \+(controlla_vincitore(L, 'o')),
    P is 0.