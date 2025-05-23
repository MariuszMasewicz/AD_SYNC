#!/bin/bash

export ORACLE_HOME=/u01/product/19/db_1
export ORACLE_BASE=/u01
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH:$HOME/.local/bin:$HOME/bin
export ORACLE_SID=ORCL

AD_SYNC_dir="/u01/AD_SYNC"

# Wyświetlenie daty i godziny rozpoczęcia
start_time=$(date "+%Y-%m-%d %H:%M:%S")
echo "Start skryptu: $start_time"
 
# Pobranie daty do nazw plików
current_date=$(date +%Y%m%d_%H%M%S)
 
# Szukanie plików .sql w bieżącym katalogu
for file in $AD_SYNC_dir/*.sql; do
    if [[ -f "$file" ]]; then
        echo "Znaleziono plik: $file"
 
        # Wywołanie sqlplus z przekierowaniem stdout i stderr do pliku logu
        sqlplus user/password@database @"$file" 
            #>"AD_SYNC_dir/logs/AD_SYNC_loader.log" 2>&1
 
        # Zmiana nazwy pliku SQL
        new_name="${file}_$current_date"
        mv "$file" "$new_name"
        echo "Zmieniono nazwę pliku na: $new_name"
    fi
done
 
# Wyświetlenie daty i godziny zakończenia
end_time=$(date "+%Y-%m-%d %H:%M:%S")
echo "Koniec skryptu: $end_time"