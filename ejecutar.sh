#!bin/bash

#if [ ! $# -eq 1 ]
#then
#echo -e "\a Error: numero de argumentos incorrecto"
#echo -e "\a modo de uso: sh $0 <radio del kernel>"
#echo
#exit 1
#fi


file="dfs.out"
element=67108863
if [ ! -f "$file" ] ; then
	# if file is not created
        touch "$file"
else
	read -p "El archivo ya existe, desea sobreescribirlo? : ( s/n ) 	" doit 
	case $doit in  
	  s|S) echo sobreescribiendo... 
	       rm $file
	       touch $file;; 
	  n|N) echo ejecutando... ;; 
	  *) echo Opcion por defecto: no sobreescribir;; 
	esac
fi
echo *----------------------------------------------------------* >> "$file"
echo "Resultados version secuencial" >> "$file"
time -o "$file" -a -p ./Secuencial/dfs $element
echo *----------------------------------------------------------* >> "$file"

for NumThread in 2 4 8 16 32 64
do
	echo "Resultados version paralela con $NumThread hilos" >> "$file" 	
	time -o "$file" -a -p ./OpenMP/dfs $NumThread $element
	echo *----------------------------------------------------------* >> "$file"
done

