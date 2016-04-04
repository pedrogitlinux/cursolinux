#!/bin/bash

# Este programa contiene 3 funciones y un ciclo WHILE:
#
# 1- Función "xlsTOcsv"
#  Esta función covierte 
#	- archivos Excel (xls) a archivos de texto (csv)
#       - después procesa los archivos CSV para quitarle datos y dejar solo los datos útiles.
#	- crea los archivos agua.dat y luz.dat que serán usados para graficar
# 2- Función "graficar"
#  Esta función crea una gráfica con gnuplot del consumo eléctrico de los
#  primeros 3 meses y del consumo de agua de 6 meses.
# 3- Función "menu"
#  Esta función muestra un menú y captura lo que el usuario seleccione para ejecutar una
# de las funciones anteriores o "SALIR" de la aplicación. El menú se vuelve a mostrar
# después de cada función, o si realiza una selección inválida, hasta que seleccione "SALIR".
# WHILE: Ejecuta el menú mientras el usuario no seleccione salir del programa.


# ------ INICIO DE FUNCION ------
# Este script extrae archivos de excel y grafica datos

function datos {
# Variables que definen los directorios donde se leerán los archivos y donde se 
# escribirán los nuevos
DATOS=../problema3

SALIDA_DATOS=$DATOS/datos_csv
NUEVA_SALIDA=$DATOS/datos_out

# SI el directorio no existe,lo crea para guardar nuevos archivos
if [ -a $NUEVA_SALIDA ]
then
        echo ""
        echo "Archivo $NUEVA_SALIDA existe. No es necesario crearlo"
        echo ""
else 
	mkdir $NUEVA_SALIDA
fi 

# Variable numérica que utiliza para leer el nombre de archivos y crear nuevos, la inicializa en 0
M=0

# Inicia el ciclo FOR que lee el archivos y les quita los datos que se le indican
# Las comas (,) de la primera fila la convierte en la palabra "Servicios" para que sea 
# eliminada la fila.
# Imprime solo 2 columnas y a "head" se le indica que muestre solo 2 filas
# Incrementa contador, muestra mensaje, lee archivo y elimina comillas. La salida la envía a archivo
# Lee los datos de los archivos para crear nuevos con datos del consumo de 
# agua y luz.

for archivo in `find $DATOS -name "Datos"`
do
#	let M=M+1
	echo "Dando formato al archivo de datos: $archivo"
	cat $archivo |  awk -F "," '{print $1 " " $2 " " $6 " " $7}' | grep -v TOA5| grep -v TIMESTAMP| grep -v TS| grep -v Max| sed '1, $ s/"//g' | sed '1, $ s/,//g'  > $NUEVA_SALIDA/datos.dat
#	if [ ${M} -lt ${LIMITE} ]
#	then
#	cat $NUEVA_SALIDA/datos.dat | grep -i Luz | sed '1, 3 s/Luz/'$M'/g' >> luz.dat
#	fi
#	cat $NUEVA_SALIDA/datos-$M.out | grep -i Agua | sed '1, 6 s/Agua/'$M'/g' >> agua.dat
# La información de error que se genera se envía a error2.log
done 2> errorDatos.log
exit 0
}

# ----- INICIO DE FUNCION -----
# Script para graficar consumo de Agua y Luz usando Gnuplot
# 
function graficar {
SALIDA_GRAFICA=graficoDatos.png
# SI los archivos existen se ejecuta, sino informa que los debe crear
if [ -a luz.dat ] && [ -a agua.dat ]
then
	gnuplot << EOF 2> errorDatos2.log
	set xrange [ * : * ]
	set format x "% g"
	set format y "% g"
	set xlabel "Tiempo"
	set ylabel "Radiación"
	set terminal png
	set output "$SALIDA_GRAFICA"
	plot "Datos.dat" using 1:4 with lines title "Radiación Máxima", "Datos.dat" using 1:5 with lines title "Radiación Mínima"
 
EOF
echo "Se ha creado el GRÁFICO en el archivo $SALIDA_GRAFICA "
exit 0

else
        echo ""
        echo "Archivos para graficar NO existen. Ejecuta opción 1 primero"
        echo ""
fi

}


# ----- INICIO DE FUNCION -----
# El siguiente código contiene el menú que se repite hasta que se elija SALIR

function menu {

# Se muestran las opciones al usuario
echo ""
echo "Para seleccionar una de las siguientes opciones, digite: "
echo " 1- Para realizar modificaciones la archivo Datos "
echo " 2- Para Graficar Radiación Máxima y Mínima "
echo " 0- Para SALIR "
# Se captura lo que digita el usuario y se guarda en variable NUM
echo -n "Su selección es: ";	read NUM
echo ""

# Inicia CASE que ejecuta una función, muestra un mensaje de error, o sale
# dependiendo del valor introducido por el usuario
case $NUM in
	1)
		 datos
	;;
	2)
		graficar
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
#	datos
done

