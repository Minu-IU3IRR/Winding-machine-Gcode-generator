

/*

generatore di Gcode per bobinatrice 

autore : Minutello Manuel
data   : 28/07/2021
rev    : 1.2

--------------------------------------------------------- configurazione macchina

-> pagina machine_configs -> primo paragrafo

  inserire le caratteristiche della macchina come vantaggi meccanici delle trasmissioni, step/rev motori, velocità e accelerazioni massime come da istruzioni

  NOTE : per cavi sottili ridurre la massima accelerazione del mandrino in modo da non causare strappi anche fino a 0.2 rotazioni/s^2

--------------------------------------------------------- parametri del lavoro

-> generatore_Gcode -> primo paragrafo

  inserire i parametri del lavoro come spire totali, lunghezza della bobina in mm, diametro del cavo in mm e velocità di avvolgimento in spire/minuto ( consiglio non superare le 100 );


  nel caso si voglia una pausa a una specifica spira per esempio creare una presa centrale abilitare la funzione selezionando enable_turn_pause = true, in caso contrario enable_turn_pause = false
  se la funzione viene abilitata inserire le spire a cui la macchina dovtà fermarsi nella variabile pause_at_turn[] all'interno delle parentesi graffe e separate da una virgola, se la funzione è disabilitata lasciare vuoto.

  esempi

  enable_turn_pause = false;     la macchinanon aplica pause
  pause_at_turn[] = {};

  enable_turn_pause = true;     la macchinanon aplica pause alle spire 220 e 500
  pause_at_turn[] = {220, 500};

  
  
  nel caso si voglia che la macchian applichi pause a ogni strato per esempio per applicare isolamenti selezioanre pause_between_layers = true, altrimenti inserire false
  
  
  
  nel caso si voglia invertire la direzione di un asse selezionarlo nelle righe invert_guide_direction e invert_spindle_direction come false o true ( false = normale, true = invertito ) (esempio rocchetto da PCB con un lato avvolto opposto all altro)
  
  
--------------------------------------------------------- istruzioni

-> una volta impostati i parametri del lavoro avviare il programma e una pagina per selezionare file verrà aperta, qui selezionare dove salvare il file e inserire il nome (l'estensione viene inserita automaticamente).
   Se tutti i parametri sono corretti il programma si chiude automaticamente una volta generato il file, altrimenti nella consolle qua sotto verranno visualizzati gli eventuali errori.
   
   una vota esportato il Gcode utilizzare un software come UGS (Universal Gcode Sender) per collegare la macchina e aprire il file appena generato. una volta posizionato il rocchetto collegare la macchina in modo da bloccare i motori e muovere manalmente
   la guida per portarla nella posizione di inizio della bobina (normalmente destra, se invert_guide_direction = true parte da sinistra). posizionata la guida alla posizione di partenza preparare il cavo di rame collegato alla bobina e assicurarsi che la 
   direzione di rotazione della bobina sia corretta muovendo manualmente l' alle Y-
   
   
   ATTENZIONE - IMPORTANTE - LEGGERE -> la macchina è una CNC e con il comando giusto causa danni a sè stessa e a chiunque non presti sufficente attenzione. 
                                        prestare particolare attenzione ai parametri di feed rate e movimento per comando del Gcode seder, un mm di movimento per la guida (1 unità) corrisponde a un comando di una rotazione per il rocchetto
                                        NON SONO RESPONSABILE DI NESSUN DANNO A COSE O PERSONE DOVUTE ALL'UTILIZZO DI QUESTO PROGRAMMA O MACCHINA ASSOCIATA
                                        
   una volta applicato il rame resettare lo zero macchina e avviare il ciclo.
   
   quando una pausa viene attivata per una spira o per uno strato è sufficente dare il comando di cycle start (o play per UGS) e il programma riprende
   
   NOTA : l' asse X nel Gcode rappresenta la posizione della guida in mm dallo zero macchina impostato all'inizio del rocchetto, l' asse Y rappresenta la spira corrente
   
   
   

*/
