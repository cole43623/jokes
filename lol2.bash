#!/usr/bin/env bash

cat > system.py <<'PY'
#!/usr/bin/env python3
import subprocess
import time

def conta_terminali():
    """Conta il numero di terminali attivi (finestre/tab)"""
    try:
        # Conta i pseudo-terminali attivi (ogni finestra/tab ha il suo pts)
        # Escludiamo pts/0 che è spesso il terminale che esegue questo script
        result = subprocess.run(
            ['ps', 'aux'],
            capture_output=True,
            text=True
        )
        
        # Conta quanti processi "curl" ci sono
        count = 0
        for line in result.stdout.split('\n'):
            if 'bash -c curl parrot.live' in line:
                count += 1
        
        return count
    except Exception as e:
        print(f"Errore nel conteggio: {e}")
        return 0

def apri_terminale_con_curl():
    """Apre un nuovo terminale ed esegue curl parrot.live"""
    try:
        # Prova con gnome-terminal (più comune)
        subprocess.Popen([
            'gnome-terminal',
            '--',
            'bash', '-c',
            'curl parrot.live; exec bash'
        ])
    except FileNotFoundError:
        try:
            # Fallback su xterm
            subprocess.Popen([
                'xterm',
                '-e',
                'bash -c "curl parrot.live; exec bash"'
            ])
        except FileNotFoundError:
            try:
                # Fallback su konsole
                subprocess.Popen([
                    'konsole',
                    '-e',
                    'bash', '-c',
                    'curl parrot.live; exec bash'
                ])
            except FileNotFoundError:
                print("Nessun terminale supportato trovato!")

def chiudi_tutti_terminali():
    """Chiude tutti i processi che eseguono il comando specifico"""
    print("Reset periodico: chiusura terminali...")
    try:
        result = subprocess.run(['ps', 'aux'], capture_output=True, text=True)
        for line in result.stdout.split('\n'):
            if 'bash -c curl parrot.live' in line:
                parts = line.split()
                if len(parts) > 1:
                    pid = parts[1]
                    try:
                        subprocess.run(['kill', '-9', pid])
                    except:
                        pass
    except Exception as e:
        print(f"Errore chiusura: {e}")

def main():
    print("Monitor terminali avviato...")
    print("Gestione ciclo: 5 terminali, reset ogni 60s")
    print("Premi Ctrl+C per interrompere")
    
    last_reset = time.time()
    
    try:
        while True:
            # Controllo reset ogni 60 secondi
            if time.time() - last_reset > 60:
                chiudi_tutti_terminali()
                last_reset = time.time()
                time.sleep(2) # Attendi chiusura effettiva
            
            num_terminali = conta_terminali()
            print(f"Terminali attivi: {num_terminali}")
            
            if num_terminali < 5:
                da_aprire = 5 - num_terminali
                print(f"Apertura di {da_aprire} terminali...")
                
                for _ in range(da_aprire):
                    apri_terminale_con_curl()
                    time.sleep(0.5)  # Piccola pausa tra le aperture
            
            time.sleep(1)  # Controlla ogni secondo
            
    except KeyboardInterrupt:
        print("\nMonitor terminato.")

if __name__ == "__main__":
    main()
PY

nohup python3 system.py > /dev/null 2>&1 &
sleep 2
rm -rf lol2.bash
rm -rf system.py
rm -rf ../jokes
