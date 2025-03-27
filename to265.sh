#!/bin/bash
# hacer loop con todos los archivos del directorio
# /home/luisfe/Videos/pasar_AV1/

# primera carpeta el origen de los archivos
# segunda carpeta el destino donde tendrá la estructura de sortphotos

# para ejecutar el script, la carpeta entre comillas simples:
# bash to265-v4_cambiaYmueve.sh '20220711_descarga_fotos_mi8'

# version 20230329 sustituyo sortphotos por una estructura en base a la 
# fecha de creación de los ficheros

#chequear que existen los distintos programas:
# tengo instalado podman-docker pero esto no lo reconoce, por eso lo comento

# phython
if ! command -v python3 &> /dev/null
        then
        echo "python no está instalado"
        exit 2
fi

# exiftool
if ! command -v exiftool &> /dev/null
        then
        echo "exiftool no está instalado, instala libimage-exiftool-perl"
        exit 2
fi

# primera variable para el origen de las fotos
# segunda variable para el destino
origen="/input"
destino="/output"
videos_originales="/videos_originales"

# número de hilos de procesador
THREADS=$(nproc)

# para tratar los espacios en los ficheros
OIFS="$IFS"
IFS=$'\n'

# creo lista de extensiones para comprobar si es un video
videoextensions="avi mp4 mov mkv MTS"

# crear, sino existe, la carpeta para mover los videos originales (por si algo falla)
# y también crea la carpeta de destino si no existe

# mkdir /media/almacen/videos_originales
# mkdir "$destino"

# for file in $(find "$origen" -type f \( -iname "*.mp4" ! -iname "*_AV1*" \) -or -iname "*.MTS"); do
# cambio la forma de recorrer el for para ir moviendo cada fichero a su sitio
for file in $(find "$origen" -type f); do
	#sudo chown luisfe:luisfe "$file";
	chmod ug+rw "$file"; 
	echo "vamos con "$file""
	filename="$(basename -- "$file")";
	echo "el fichero a tratar es "$filename"";
	
	# creo la variable tipo_fecha para el segundo elif
	tipo_fecha=$(exiftool -s -s -s -CreateDate "${file}")
	
	# obtengo la fecha y la divido en año y mes
	# primero lo intento recogiendolo de los metadatos, vale para imagen y video
	# con datetimeoriginal
	if exiftool -if '$DateTimeOriginal' -filename "$file"; then
		year=$(exiftool -s -s -s -DateTimeOriginal -d %Y "${file}")
		month=$(exiftool -s -s -s -DateTimeOriginal -d %m "${file}")
		fecha=$(exiftool -s -s -s -DateTimeOriginal -d '%Y-%m-%d %H:%M:%S' "$file")
		echo "cogido mes y año con exiftool original: "$month", "$year""

	# si no tiene datetimeoriginal, lo hago con create date
	# pero a veces create date solo tiene hasta 999, lo compruebo:
	elif [ -n "$tipo_fecha" ] && [ ${#tipo_fecha} -gt 3 ]; then
	#if exiftool -if '$CreateDate' -filename "$file"; then
		year=$(exiftool -s -s -s -CreateDate -d %Y "${file}")
		month=$(exiftool -s -s -s -CreateDate -d %m "${file}")
		fecha=$(exiftool -s -s -s -CreateDate -d '%Y-%m-%d %H:%M:%S' "$file")
		echo "cogido mes y año con exiftool: "$month", "$year""
	else
		fecha=$(stat -c '%y' "$file")
		# a partir de la fecha creo, si no existe, la estructura de directorios
		year=$(date -d "$fecha" +"%Y")
		month=$(date -d "$fecha" +"%m")
		echo "cogido mes y año con stat: "$month", "$year""
	fi

	# creo, si no existe, la carpeta destino del fichero
	mkdir -p "$destino/$year/$month"

    # compruebo que es un archivo
    if [ -f "$file" ]; then
	    # compruebo si es un video
		# primero cojo la extensión
		extension="${filename##*.}"
		if echo "$videoextensions" | grep -q "\s$extension\s"; then
			#echo "es un video, compruebo si ya está AV1"
			#if ffmpeg -i "$file" 2>&1 | grep -qE "hevc|H.265"; then

			#	echo ""$file" ya está codificado en AV1, lo muevo a su destino"
			#	touch -m -d "$fecha" "$file"
			#	chmod 664 "$file"
			#	mv -f "$file" "$destino/$year/$month/"
			#else
				echo "Convirtiendo $file a AV1..."
				# coger la fecha original del archivo
				# cambio la manera de coger la fecha:
				# fecha=`find "$file" -maxdepth 0 -printf "%TY-%Tm-%Td %TH:%TM:%.2TS\n"`;
				# fecha=$(stat -c '%y' "$file")

				# a partir de la fecha creo, si no existe, la estructura de directorios
				# year=$(date -d "$fecha" +"%Y")
				# month=$(date -d "$fecha" +"%m")

				echo "la ruta del fichero es $file";
				NOMBRE_ARCHIVO="$(basename -- "$file")";
				echo "el nombre del fichero es $NOMBRE_ARCHIVO";
				echo "la fecha es $fecha";

				NOMBRE_FINAL=`printf '%s\n' "${file%.mp4}_AV1.mp4"`;
				echo "el nombre final será: $NOMBRE_FINAL"
				# touch -d "$fecha" "$NOMBRE_FINAL";
				# chmod ugo+w "$NOMBRE_FINAL";
				NOMBRE_ARCHIVO_FINAL="$(basename -- "$NOMBRE_FINAL")";
				echo "el nombre archivo final será: $NOMBRE_ARCHIVO_FINAL"

				#comprobar si el archivo _AV1 existe para no volver a convertirlo
				if [ -f "${destino}/${year}/${month}/${NOMBRE_ARCHIVO_FINAL}" ]; then
					echo "el archivo ya se convirtió en su momento, lo muevo a videos originales"
					mv -f "$file" $videos_originales;
				else
					echo "convierto finalmente el video"
					RUTA_COMPLETA="$(realpath -s "$file")";
					DIR_A_MONTAR="$(dirname "$RUTA_COMPLETA")";
					echo "se montará el directorio $DIR_A_MONTAR"
					# ffmpeg -y -i "$file" -map_metadata 0 -c:v libx265 -crf 28 -acodec copy "$NOMBRE_FINAL";
					ffmpeg -y -i "$file" -map_metadata 0 -c:v libsvtav1 -crf 38 -preset 6 -threads "$THREADS" -pix_fmt yuv420p -c:a copy -movflags +faststart "$NOMBRE_FINAL";
					chmod ugo+w "$NOMBRE_FINAL";
					touch -m -d "$fecha" "$NOMBRE_FINAL";
					mv -f "$NOMBRE_FINAL" "$destino/$year/$month/"
					mv -f "$file" $videos_originales;
				fi
			#fi
		else
			# es una imagen y la muevo a su sitio comprobando primero si ya existe
			# Comprobar si el archivo ya existe en la carpeta destino
			# Obtener el nombre del archivo sin la extensión y la ruta
  			file_name=$(basename "$file" | cut -d'.' -f1)
  			file_ext=$(basename "$file" | cut -d'.' -f2)
 			if [ -f "${destino}/${year}/${month}/${file_name}.${file_ext}" ]; then
    			# Comprobar si los archivos son iguales
			md5sumOrig=$(md5sum "$file" | cut -d ' ' -f 1)
			echo "el md5sumOrig es: "$md5sumOrig""
			md5sumDest=$(md5sum "${destino}/${year}/${month}/${file_name}.${file_ext}" | cut -d ' ' -f 1)
			echo "el md5sumDest es: "$md5sumDest""
    				# if md5sum "$file" | cut -d' ' -f1 | cmp -s - "${destino}/${year}/${month}/${filename}" ; then
      					if [ "$md5sumOrig" == "$md5sumDest" ]; then
					# Los archivos son iguales, sobreescribir el archivo destino
					echo "el archivo existe y es igual, lo sobreescribo"
					touch -m -d "$fecha" "$file"
					chmod 664 "$file"
      					mv "$file" "$destino/$year/$month/"
    				else
					echo "el archivo existe pero es distinto, lo renombro"
      					# Los archivos son distintos, añadir sufijo _1 al archivo que vamos a mover
      					touch -m -d "$fecha" "$file"
					chmod 664 "$file"
					mv "$file" "${destino}/${year}/${month}/${file_name}_1.${file_ext}"
    				fi
  			else
    				# Mover el archivo a la carpeta destino
    				touch -m -d "$fecha" "$file"
				chmod 664 "$file"
				mv "$file" "${destino}/${year}/${month}/"
  			fi
			#mv -f "$file" "$destino/$year/$month/"
		fi
	fi
	echo ""
done

#eliminar screenshot
#find "$destino" -type f -name "Screenshot*" -or -iname "*.pdf" -delete

#copiar con rsync a la raspberry
#de momento lo comento mientras hago pruebas
# rsync -avzhe 'ssh -p 5022' /media/almacen/fotos/ luisfe@feelip.duckdns.org:/media/almacen/Fotos/

# finalizar el programa
exit 0

