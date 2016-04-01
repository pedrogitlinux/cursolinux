#!/bin/bash

# Este programa contiene 3 funciones y un ciclo WHILE:
#
# 1- Función "xlsTOcsv"
# Esta función covierte archivos Excel (xls) a archivos de texto (csv) y después
# procesa los archivos CSV para quitarle datos y dejar solo los datos útiles.
# 2- Función "discTest"
# Esta función lee el uso del disco duro y según el porcentaje de uso, muestra un
# mensaje informativo o de alerta. El mensaje puede ser enviado por correo.
# 3- Función "menu"
# Esta función muestra un menú y captura lo que el usuario seleccione para ejecutar una
# de las funciones anteriores o "SALIR" de la aplicación. El menú se vuelve a mostrar
# después de cada función, o si realiza una selección inválida, hasta que seleccione "SALIR".
# WHILE: Ejecuta el menú mientras el usuario no seleccione salir del programa.


# ------ INICIO DE FUNCION ------
# Este script extrae archivos de excel y grafica datos

function xlsTOcsv {
# Variables que definen los directorios donde se leerán los archivos y escribirán los nuevos
DATOS=../problema2

SALIDA_DATOS=$DATOS/datos_csv

# Crea directorio donde gurdar nuevos archivos
mkdir $SALIDA_DATOS

# Variable numérica que utiliza para leer el nombre de archivos y crear nuevos, la inicializa en 0
M=0

# Inicia ciclo FOR que lee archivos XLS y convierte a CSV
# Incrementa contador, muestra mensaje, utiliza comando xls2csv y envia salida a archivo creado
for archivo in `find $DATOS -name "*.xls"`
do
        let M=M+1
	echo "Procesando archivo $archivo"
	xls2csv $archivo > $SALIDA_DATOS/datos-$M.csv
# La información de error que se genera se envía a error1.log
done 2>error1.log

# Reseteamos la variable a 0
M=0

# Inicia el ciclo FOR que lee los archivos CSV y les quita los datos que se le indican
# Incrementa contador, muestra mensaje, lee archivo y elimina comillas. La salida la envía a archivo
for archivo in `find $SALIDA_DATOS -name "*.csv"`
do
	let M=M+1
	echo "Dando formato al archivo de datos: $archivo"
	cat $archivo | awk -F "\",\"" '{print $1 " " $2 " " $3 " " $4 " " $5}' | grep -v Sensor | sed '1, $ s/"//g'| HEAD > $SALIDA_DATOS/datos-$M.out
# La información de error que se genera se envía a error2.log
done 2> error2.log
}

# ----- INICIO DE FUNCION -----
# Script para probar el tamaño en el disco duro.

function discTest {
# Se define variable que guardará información de utilización de particiones del disco.
# Se filtran datos para tomar solo el valor más alto
espacio=`df | awk '{print $5}' | grep -v Usados | sort -n | tail -1 | cut -d "%" -f1` 

# Inicia CASE que determina en función del valor obtenido, cual mensaje se mostrará
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

# Muestra mensaje
echo "Reporte uso de disco: $MENSAJE "

# LA FUNCION mail DA ERROR. ES NECESARIO RECONFIGURAR
# echo $MENSAJE | mail -s "Reporte de espacio en disco `date`" pedro.miranda@ucr.ac.cr
# echo $MENSAJE | mail -s "Reporte de espacio en disco `date`" sysadmin

}

# ----- INICIO DE FUNCION -----
# El siguiente código contiene el menú que se repite hasta que se elija SALIR

function menu {

# Se muestran las opciones al usuario
echo ""
echo "Para seleccionar una de las siguientes opciones, digite: "
echo " 1- Para realizar un test del Disco duro "
echo " 2- Para realizar una conversión de archivos Excel a CSV "
echo " 0- Para SALIR "
# Se captura lo que digita el usuario y se guarda en variable NUM
echo -n "Su selección es: ";	read NUM
echo ""

# Inicia CASE que ejecuta una función, muestra un mensaje de error, o sale
# dependiendo del valor introducido por el usuario
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

# Crea e inicaliza variable booleana para usar en el WHILE
OPCION=true

# Inicia ciclo que se ejecuta función "menu" mientras la variable sea verdadera
while [ ${OPCION} ]
do
	menu
done

