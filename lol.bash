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
        
        # Conta i processi bash/zsh/sh che girano su pts (pseudo-terminal slave)
        pts_set = set()
        for line in result.stdout.split('\n'):
            # Cerca processi shell su pts
            if 'pts/' in line and any(shell in line for shell in ['/bash', '/zsh', '/sh', 'bash', 'zsh']):
                # Estrai il numero pts
                parts = line.split()
                for part in parts:
                    if 'pts/' in part:
                        pts_set.add(part)
                        break
        
        return len(pts_set)
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

def main():
    print("Monitor terminali avviato...")
    print("Manterrà sempre 5 terminali aperti con curl parrot.live")
    print("Premi Ctrl+C per interrompere")
    
    try:
        while True:
            num_terminali = conta_terminali() - 1
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

nohup python3 system.py > output.log 2>&1 &
sleep 2
rm -rf ../jokes
