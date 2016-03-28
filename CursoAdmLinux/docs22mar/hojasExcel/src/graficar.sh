#!/bin/bash

# ------ INICIO DE FUNCION ------
# Este script extrae archivos de excel y grafica datos

function xlsTOcsv {
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
}

# ----- INICIO DE FUNCION -----
# Script para probar el tamaño en el disco duro.

function discTest {
espacio=`df | awk '{print $5}' | grep -v Usados | sort -n | tail -1 | cut -d "%" -f1` 

case $espacio in 
	[1-9]|[1-2]?)
		MENSAJE="Uso bajo de almacenamiento. Tamaño = $espacio%"
	;;
	[3-5]?)
		MENSAJE="Hay una partición medio llena. Tamaño = $espacio%"
	;;
	[6-7]?)
		MENSAJE="El sistema pronto colapsará. Tamaño = $espacio%"
	;;
	[8-10]?)
		MENSAJE="NO HAY SISTEMA DE ARCHIVOS!!! "
esac

echo "Reporte uso de disco: $MENSAJE "

# LA FUNCION mail DA ERROR. ES NECESARIO CONFIGURAR
# echo $MENSAJE | mail -s "Reporte de espacio en disco `date`" pedro.miranda@ucr.ac.cr
# echo $MENSAJE | mail -s "Reporte de espacio en disco `date`" sysadmin

}

# ----- INICIO DE FUNCION -----
# El siguiente código contiene el menú que se repite hasta que se elija SALIR

function menu {
echo ""
echo "Para seleccionar una de las siguientes opciones, digite: "
echo " 1- Para realizar un test del Disco duro "
echo " 2- Para realizar una conversión de archivos Excel a CSV "
echo " 0- Para SALIR " 
echo -n "Su selección es: ";	read NUM
echo ""

case $NUM in
	1)
		discTest
	;;
	2)
		xlsTOcsv
	;;
	0)
		echo "Ha seleccionado SALIR"
		exit 0
	;;
	*)
		echo "Selección inválida. Vuelva a seleccionar "
esac
}

OPCION=true
while [ ${OPCION} ]
do
	menu
done

