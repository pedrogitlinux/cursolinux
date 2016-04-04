#!/bin/bash

# Este programa contiene 3 funciones y un ciclo WHILE:
#
# 1- Función "datos"
#  Esta función procesa el archivo Datos para quitarle datos y dejar solo los datos
#  útiles y crea el archivo datos.dat que será usado para graficar
# 2- Función "graficar"
#  Esta función crea una gráfica con gnuplot del Indice de la Radiación Máxima y 
#  Mínima en KW/m2 entre 16/03/2012 y 30/05/2012
# 3- Función "menu"
#  Esta función muestra un menú y captura lo que el usuario seleccione para ejecutar una
# de las funciones anteriores o "SALIR" de la aplicación. El menú se vuelve a mostrar
# después de cada función, o si realiza una selección inválida, hasta que seleccione "SALIR".
# WHILE: Ejecuta el menú mientras el usuario no seleccione salir del programa.


# ------ INICIO DE FUNCION ------
# Este script manipula el archivo Datos y crea uno nuevo para usar para graficar

function datos {
# Variable que define el directorio donde se leerá el archivo
DATOS=../problema3

# Inicia el ciclo FOR que lee el archivo y le quita los datos que se le indican
# Imprime 3 columnas y modifica la hora eliminando ":". La salida la envía a archivo

for archivo in `find $DATOS -name "Datos"`
do
#	let M=M+1
	echo "Dando formato al archivo de datos: $archivo"
	cat $archivo |  awk -F "," '{print $1 " " $6 " " $7}' | grep -v TOA5| grep -v TIMESTAMP| grep -v TS| grep -v Max| sed '1, $ s/"//g' | sed '1, $ s/,//g' | sed '1, $ s/://g' > datos.dat

# La información de error que se genera se envía a error2.log
done 2> errorDatos.log

# Fin de la función
}

# ----- INICIO DE FUNCION -----
# Script para graficar los índices de radiación solar máximo y mínimo usando Gnuplot
# 
function graficar {
SALIDA_GRAFICA=graficoDatos.png
# SI el archivo existe se ejecuta, sino informa que los debe crear
if [ -a datos.dat ]
then
# Configura Gnuplot según los datos fuente que utiliza
	gnuplot << EOF 2> errorDatos2.log
	set xdata time
	set timefmt "%Y-%m-%d %H%M%S"
	set xrange [ '2012-03-16 110000' : '2012-05-30 220000' ]
	set format x "%m/%d"
	set format y "% g"
	set xlabel "Meses 2012"
	set ylabel "Radiación"
	set terminal png
	set output "$SALIDA_GRAFICA"
	plot "datos.dat" using 1:3 with lines title "Radiación Máxima", "datos.dat" using 1:4 with lines title "Radiación Mínima"
 
EOF
echo "Se ha creado el GRÁFICO en el archivo $SALIDA_GRAFICA "
echo " "
# exit 0

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
done

