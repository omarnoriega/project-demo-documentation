# Documentacion de arquitectura Proyecto Laboratorio Estraategia DevOps DIAN

## Estructura del Repositorio

        📦project-demo-dian
        ┣ 📂docs
        ┃ ┣ 📂recursos
        ┃ ┃ ┣ 📜diagrama-casos-uso.drawio.png
        ┃ ┃ ┣ 📜diagrama-componentes.drawio.svg
        ┃ ┃ ┗ 📜diagrama-secuencia.drawio.svg
        ┃ ┗ 📜documento-arquitectura.md
        ┣ 📂iac
        ┃ ┣ 📂aws
        ┃ ┃ ┗ 📜main.tf
        ┃ ┗ 📂azure
        ┃ ┃ ┗ 📜main.tf
        ┣ 📂pipelines
        ┃ ┗ 📜azure-pipelines.yml
        ┣ 📂application-resources
        ┣ 📜.gitignore
        ┗ 📜README.md

## Ejemplo Tabla

 | Componete | Descripcion |
|---|---|
| Colas de Mensajeria | Encargado de dividir el trabajo de envío de mensajes en grupos de mensajes más pequeños para luego enviarlos por lotes. |