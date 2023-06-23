{- Programma Haskell che implementa il gioco del Tic-Tac-Toe 
   singolo giocatore con algoritmo di ottimiazzazione Minimax. 
   
   Nota: con "Giocatore" si fa riferimento al giocatore pilotato
   dall'utente, mentre con "CPU" ci si riferisce a quello pilotato
   dal computer. 
   
   Nota: nel programma si rappresenta la griglia di gioco ed il suo
   stato attraverso una lista di caratteri. I controlli fatti
   su questa lista non saranno particolarmente stringenti dato che 
   questa viene gestita interamente dal programma e quindi si 
   garantisce una correttezza intrinseca. -}


{---------------------------------------------------------------------------
 --                       IMPORTAZIONE DEI MODULI                         --
 --------------------------------------------------------------------------}

{- Necessario per usare elemIndex, che restituisce l'indice del primo 
   elemento che soddisfa una certa condizione. -} 
import Data.List (elemIndex)

{- Necessario per usare inRange, che restituisce True nel caso in cui
   un valore dato si trovi all'interno dei limiti specificati. -}
import Data.Ix (inRange)

{- Necessario per usare fromJust, che estrae l'elemento da un costruttore 
   Just. -}
import Data.Maybe (fromJust)

{- Necessario per usare readMaybe, che consente di gestire la validazione
   dell'input. -}
import Text.Read (readMaybe)


{---------------------------------------------------------------------------
 --                      RIDENOMINAZIONE DEI TIPI                         --
 --------------------------------------------------------------------------}

{- Dato che la griglia di gioco viene rappresentata come una lista di
   caratteri mentre una mossa viene rappresentata mediante una cifra,
   si sceglie di effettuare le seguenti ridenominazioni:
   - il tipo strutturato [Char] viene ridenominato in Griglia;
   - il tipo scalare Int viene ridenominato in Mossa. -}

type Griglia = [Char]
type Mossa = Int

{---------------------------------------------------------------------------
 --                      INIZIALIZZAZIONE DEL GIOCO                       --
 --------------------------------------------------------------------------}

main :: IO ()
main = 
    do putStrLn "Gioco del Tic-Tac-Toe!\n"
       gioca


{- La funzione gioca inizializza l'interazione con il Giocatore
   acquisendo un carattere:
    - 's' allora si inizia una nuova partita;
    - 'h' vengono mostrate le regole al giocatore.
   L'uso di _ <- getLine consente la pulizia del buffer. -}

gioca :: IO ()
gioca = 
    do putStr   "Digita 's' per iniziare a giocare oppure 'h' per" 
       putStrLn " consultare le regole:"
       c <- getChar
       _ <- getLine
       inizio_gioco c


{- La funzione inizio_gioco gestisce la richiesta del Giocatore:
   - l'argomento è il comando dato dal Giocatore.
   La partita favorisce sempre il Giocatore che quindi partirà per primo. -}

inizio_gioco :: Char -> IO ()
inizio_gioco c 
    | c == 's'  = 
        do partita [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '] 1 1
    | c == 'h'  = 
        do mostra_regole
           gioca
    | otherwise = 
        do putStrLn $ "Input " ++ show [c] ++ " non valido."
           gioca


{---------------------------------------------------------------------------
 --                IMPLEMENTAZIONE FUNZIONI DI UTILITÀ                    --
 --------------------------------------------------------------------------}

{- La funzione mostra_regole si occupa di mostrare al Giocatore le regole
   del gioco. -}

mostra_regole :: IO ()
mostra_regole = 
    do putStrLn "\nREGOLE DEL GIOCO:"
       putStrLn " - il primo turno spetta al Giocatore;"
       putStrLn " - al Giocatore viene assegnato il simbolo 'o';"
       putStrLn " - a CPU viene assegnato il simbolo 'x';"
       putStr   " - vince chi riesce a disporre tre dei propri simboli in"
       putStrLn " linea retta orizzontale, verticale o diagonale;"
       putStr   " - se la griglia viene riempita senza che nessuno dei"
       putStr   " giocatori sia riuscito a completare una linea retta"
       putStrLn " di tre simboli, il gioco finisce in parità."
       putStrLn "\nCOME FARE UNA MOSSA:"
       putStr   " - fare una mossa vuol dire digitare il numero che"
       putStr   " corrisponde alla cella in cui si vuole aggiungere"
       putStrLn " il proprio simbolo."
       putStr   "Ad esempio: digitare '5' per aggiungere 'o' nella cella"
       putStrLn " centrale."
       putStrLn "\nCOME SI COMPONE LA GRIGLIA:"
       putStrLn " - la griglia si compone di nove celle;"
       putStrLn " - le celle sono numerate da 1 a 9."
       putStrLn "\nGRIGLIA DI RIFERIMENTO:\n"
       disegna_griglia ['1', '2', '3', '4', '5', '6', '7', '8', '9'] 1


{- La funzione disegna_griglia stampa la griglia di gioco:
   - il primo argomento è la lista contenente lo stato corrente del gioco;
   - il secondo argomento è un indice che identifica la cella da disegnare.
   Per stato corrente del gioco si intende l'insieme dei
   simboli attualmente presenti nella griglia. -}

disegna_griglia :: Griglia -> Int -> IO ()
disegna_griglia (s : ls) i 
    | i `mod` 3 /= 0     = 
        do putStr " "
           putChar s
           putStr " |"
           disegna_griglia ls (i + 1)
    | (i == 3 || i == 6) = 
        do putStr " "
           putChar s
           putStr "\n---+---+---\n"
           disegna_griglia ls (i + 1)
    | i == 9             = 
        do putStr " "
           putChar s
           putStr "\n\n"


{- La funzione acquisisci_mossa_giocatore ottiene la mossa
   fatta dal Giocatore:
   - l'argomento è la lista contenente lo stato corrente del gioco.
   Il nuovo stato del gioco dipenderà dalla mossa acquisita. 
   Si fa notare che alla funzione mossa_valida si passa la mossa
   decrementata di 1 (dato che in Haskell le liste sono indicizzate a 
   partire da 0); questo si fa per favorire l'esperienza di gioco
   dell'utente e mantenere la numerazione delle celle da 1 a 9. -}

acquisisci_mossa_giocatore :: Griglia -> IO Mossa
acquisisci_mossa_giocatore l = 
    do putStrLn "Digita il numero della cella:"
       input <- getLine
       let m = case readMaybe input :: Maybe Mossa of
                   Just i  -> i
                   Nothing -> -1
       if (mossa_valida l (m-1))
           then return m
           else do putStrLn "Mossa non valida."
                   acquisisci_mossa_giocatore l


{- La funzione mosse_rimaste verifica che la griglia di gioco non sia
   completamente piena:
   - l'argomento è la lista contenente lo stato corrente del gioco.
   La griglia di gioco si dice piena quando ogni sua cella è occupata
   dal un simbolo ('x' oppure 'o'). 
   L'uso di any consente di applicare la condizione specificata come
   primo argomento ad ogni elemento della lista (specificata come
   secondo). -}

mosse_rimaste :: Griglia -> Bool
mosse_rimaste l = any (==' ') l


{- La funzione mossa_valida verifica che una mossa sia valida:
   - il primo argomento è la lista contenente lo stato corrente del gioco;
   - il secondo argomento è la mossa che si vuole validare.
   Una mossa è valida quando la cella corrispondente è libera. -}

mossa_valida :: Griglia -> Mossa -> Bool
mossa_valida l m 
    | inRange (0,8) m && l!!m == ' ' = True
    | otherwise                      = False


{- La funzione aggiorna_griglia genera il nuovo stato della griglia di gioco
   inserendo un simbolo ('x' oppure 'o' a seconda del giocatore) nella cella 
   specificata:
   - il primo argomento è la lista contenente lo stato corrente del gioco;
   - il secondo argomento è il numero della cella che si vuole aggiornare;
   - il terzo argomento è il simbolo che si vuole aggiungere. -}

aggiorna_griglia :: Griglia -> Mossa -> Char -> Griglia
aggiorna_griglia (_ : ls) 0 s              = s : ls
aggiorna_griglia (ts : ls) i s | i > 0     = ts : aggiorna_griglia ls (i-1) s
                               | otherwise = []


{- La funzione stampa_risultato_partita stampa il risultato della partita.
   L'argomento indica la codifica del risultato:
   - 0 vuol dire che la partita termina in parità;
   - 1 vuol dire che Giocatore ha vinto;
   - 2 vuol dire che CPU ha vinto. -}

stampa_risultato_partita :: Int -> IO ()
stampa_risultato_partita n | n == 0 = do putStrLn "Pari!"
                           | n == 1 = do putStrLn "Hai vinto!"
                           | n == 2 = do putStrLn "Hai perso, CPU vince!"


{- La funzione controlla_vincitore verifica se nella griglia sia presente
   una configurazione per cui si possa decretare un vincitore:
   - il primo argomento è la lista contenente lo stato corrente del gioco;
   - il secondo argomento è il simbolo per cui si vuole controllare. -}

controlla_vincitore :: Griglia -> Char -> Bool
controlla_vincitore l s  | controlla_righe     = True
                         | controlla_colonne   = True
                         | controlla_diagonali = True
                         | otherwise           = False
    where
        controlla_righe     = (l!!0 == s && l!!1 == s && l!!2 == s)
                              || (l!!3 == s && l!!4 == s && l!!5 == s) 
                              || (l!!6 == s && l!!7 == s && l!!8 == s)
        controlla_colonne   = (l!!0 == s && l!!3 == s && l!!6 == s)
                              || (l!!1 == s && l!!4 == s && l!!7 == s)
                              || (l!!2 == s && l!!5 == s && l!!8 == s)
        controlla_diagonali = (l!!0 == s && l!!4 == s && l!!8 == s)
                              || (l!!2 == s && l!!4 == s && l!!6 == s)


{---------------------------------------------------------------------------
 --                     IMPLEMENTAZIONE LOOP DEL GIOCO                    --
 --------------------------------------------------------------------------}

{- La funzione partita implementa il loop del gioco, gestendo il passsaggio
   del turno, le mosse di Giocatore e CPU, e la terminazione della partita:
   - il primo argomento è la lista contenente lo stato corrente del gioco;
   - il secondo argomento rappresenta il giocatore in possesso del turno;
   - il terzo argomento rappresenta il numero del turno raggiunto. -}

partita :: Griglia -> Int -> Int -> IO ()
partita l p t
    {- Gestione del turno di Giocatore: secondo argomento uguale a 1. -}
    | p == 1 && t < 10 && not(controlla_vincitore l 'x')          = 
        do disegna_griglia l 1
           mossa_giocatore <- acquisisci_mossa_giocatore l
           partita (aggiorna_griglia l (mossa_giocatore - 1) 'o') 2 (t + 1)
    | p == 1 && t < 10 && controlla_vincitore l 'x'               = 
        do disegna_griglia l 1
           stampa_risultato_partita 2
    {- Gestione del turno di CPU: secondo argomento uguale a 2. -}
    | p == 2 && t > 2 && t < 10 && not(controlla_vincitore l 'o') = 
        do disegna_griglia l 1
           let mossa_cpu = cerca_mossa_migliore l
           partita (aggiorna_griglia l mossa_cpu 'x') 1 (t + 1)
    | p == 2 && t > 2 && t < 10 && controlla_vincitore l 'o'      = 
        do disegna_griglia l 1
           stampa_risultato_partita 1
    {- Per decidere la prima mossa di CPU non si utilizza l'algoritmo 
       di Minimax, bensì le strategie note del Tic-Tac-Toe:
       - se libera, prendere subito la cella centrale della griglia;
       - se la cella centrale è occupata, scegliere uno qualsiasi
         degli angoli della griglia. -}
    | p == 2 && t == 2 && mossa_valida l 4                        = 
        do disegna_griglia l 1
           partita (aggiorna_griglia l 4 'x') 1 (t + 1)
    | p == 2 && t == 2 && mossa_valida l 0                        = 
        do disegna_griglia l 1
           partita (aggiorna_griglia l 0 'x') 1 (t + 1)
    {- Per decidere il risultato una volta raggiunto il numero massimo
       di mosse: 10. -}
    | t == 10 && controlla_vincitore l 'o'                        = 
        do disegna_griglia l 1
           stampa_risultato_partita 1
    | t == 10 && not (controlla_vincitore l 'o')                  = 
        do disegna_griglia l 1
           stampa_risultato_partita 0


{---------------------------------------------------------------------------
 --                  IMPLEMENTAZIONE ALGORITMO DI MINIMAX                 --
 --------------------------------------------------------------------------}

{- La funzione cerca_mossa_migliore genera la miglior mossa possibile 
   che CPU possa fare:
   - l'argomento è la lista contenente lo stato corrente del gioco.
   Per mossa migliore si intende una mossa che non consenta a Giocatore
   di concludere la partita con una vittoria. -}

cerca_mossa_migliore :: Griglia -> Mossa
cerca_mossa_migliore l = fromJust (elemIndex (maximum rs) rs)
    where 
        rs = [if (mossa_valida l i)
                  then minimax (aggiorna_griglia l i 'x') 0 False
                  else -1000
              | i <- [0..8]]


{- La funzione minimax calcola il punteggio migliore ottenuto in seguito
   al compimento di una delle possibili mosse:
   - il primo argomento è la lista contenente lo stato corrente del gioco;
   - il secondo argomento è la profondità raggiunta durante la generazione
     dell'albero delle simulazioni di gioco;
   - il terzo argomento indica se la ricerca del punteggio migliore deve 
     essere fatta dal punto di vista del massimizzatore o del minimizzatore.
   Il punteggio migliore viene cercato all'interno di una lista generata
   ad ogni punto di ramificazione lungo l'albero delle simulazioni di gioco. -}

minimax :: Griglia -> Int -> Bool -> Int
minimax l d _     | p == 10                        = p - d
                  | p == -10                       = p + d
    where
        p = valuta l
        {- La funzione valuta calcola il punteggio ottenuto in seguito alla
           valutazione dello stato corrente della griglia del gioco:
           - l'argomento è la lista contenente lo stato corrente del gioco.
           Il punteggio vale:
           - 10 se la vittoria va a CPU;
           - -10 se la vittoria va a Giocatore;
           - 0 se non si è raggiunta una condizione di vittoria. -}
        valuta :: Griglia -> Int
        valuta l | controlla_vincitore l 'x' = 10
                 | controlla_vincitore l 'o' = -10
                 | otherwise                 = 0
minimax l _ _     | not (mosse_rimaste l)          = 0
minimax l d im    | mosse_rimaste l && im == True  = maximum rsMax
                  | mosse_rimaste l && im == False = minimum rsMin
    where 
        rsMax = [if (mossa_valida l i) 
                     then minimax (aggiorna_griglia l i 'x') (d+1) False 
                     else -1000 
                 | i <- [0..8]]
        rsMin = [if (mossa_valida l i) 
                     then minimax (aggiorna_griglia l i 'o') (d+1) True
                     else 1000  
                 | i <- [0..8]]