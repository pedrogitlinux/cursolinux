#!/bin/bash

# Este script extrae archivos de excel y grafica datos

DATOS=../hojasDatos

SALIDA_DATOS=$DATOS/datos_csv

mkdir $SALIDA_DATOS

M=0

for archivo in `find $DATOS -name "*.xls"`
do
        let M=M+1
	echo "Procesando archivo $archivo"
	xls2csv $archivo > $SALIDA_DATOS/datos-$M.csv
done 2>error1.log

M=0
for archivo in `find $SALIDA_DATOS -name "*.csv"`
do
	let M=M+1
	echo "Dando formato al archivo de datos: $archivo"
	cat $archivo | awk -F "\",\"" '{print $1 " " $2 " " $3 " " $4 " " $5}' | grep -v Sensor | sed '1, $ s/"//g' > $SALIDA_DATOS/datos-$M.out

done 2> error2.log




