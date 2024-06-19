# Utiliza la última versión de debian-slim como base
FROM docker.io/library/debian:bookworm-slim

# Establece el directorio de trabajo
WORKDIR /usr/src/app

# Instala las herramientas necesarias
RUN apt-get update && apt-get install -y \
    sudo \
    libimage-exiftool-perl \
    coreutils \
    ffmpeg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copia el script personalizado al contenedor
COPY to265.sh .

# Da permisos de ejecución al script
RUN chmod +x to265.sh

# Define el punto de entrada del contenedor
ENTRYPOINT ["./to265.sh"]

