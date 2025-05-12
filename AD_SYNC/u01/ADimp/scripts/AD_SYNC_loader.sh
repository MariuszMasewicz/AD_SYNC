#!/bin/bash

AD_SYNC_dir="/u01/AD_SYNC"

# Wyświetlenie daty i godziny rozpoczęcia
start_time=$(date "+%Y-%m-%d %H:%M:%S")
echo "Start skryptu: $start_time"
 
# Pobranie daty do nazw plików
current_date=$(date +%F)
 
# Szukanie plików .sql w bieżącym katalogu
for file in $AD_SYNC_dir/*.sql; do
    if [[ -f "$file" ]]; then
        echo "Znaleziono plik: $file"
 
        # Wywołanie sqlplus z przekierowaniem stdout i stderr do pliku logu
        sqlplus user/password@database @"$file" >"AD_SYNC_dir/logs/AD_SYNC_loader.log" 2>&1
 
        # Zmiana nazwy pliku SQL
        new_name="${file%.sql}_$current_date"
        mv "$file" "$new_name"
        echo "Zmieniono nazwę pliku na: $new_name"
    fi
done
 
# Wyświetlenie daty i godziny zakończenia
end_time=$(date "+%Y-%m-%d %H:%M:%S")
echo "Koniec skryptu: $end_time"