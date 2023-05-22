# Contador-Binario-10-bits

## 1. Funcionamiento del proyecto.
El proyecto consiste en la realizacion de un contador ascendente-descendente de modulo 1024 a nivel de hardware usando un microcontrolador STM32F103C8T6 (blue pill) que proporciona 3 funcionalidades principales que son incrementar, decrementar y restablecimiento, esto mediante el uso de unos push buttons que al ser pulsados estos emitiran el resultado que se vera reflejado en los 10 leds correspondientes. Este programa se implemento mediante un tipo de programacion distinguido como bare-metal, la cual consiste en implementar un programa que interactue a nivel de hardware cuando hay ausencia de un sistema operativo que lo pueda soportar.
### A continuacion se presenta un diagrama de flujo que describe secuencialmente como se ve la ejecucion del programa implementado:

![Diagrama sin título-Página-3 drawio (2)](https://github.com/paprikadreamdetective/Contador-Binario-10-bits/assets/133156970/0f3b9158-04a0-46b2-9e15-f71d477cbd92)

## 2. Compilacion.
Para la compilacion del proyecto es necesario tener instalado el compilador cruzado de arm, la utilidad para grabar el programa en el grabador a usar y la utilidad make. El comando de instalacion es el siguiente: 
```asm
sudo apt install stlink-tools gcc-arm-none-eabi make

```
Este comando funciona siempre y cuando se este trabajando bajo una distribucion de linux basada en ubuntu.
Una vez se haya instalado correctamente los paquetes correspondientes queda realizar la compilacion de nuestro programa, para esto es importante tener los archivos .inc en el mismo directorio en el que se encuentran los archivos fuente del programa. Los archivos .inc contienen las compensaciones y la direccion base para poder configurar los registros GPIO. La compilacion se hace mediante los siguientes comandos:
```asm
$ make clean
$ make 
$ make write
```
make clean: Sirve para eliminar los codigo objeto .o.
make: Crea los codigos objeto con base en los archivos fuente .s.
make write: Sirve para grabar los archivos .bin en la tarjeta.

Tambien hay que tener en cuenta que si el codigo fuente fue escrito en diferentes archivos, entonces los archivos con terminacion .s tendran que ser añadidos a la linea 10 del makefile ya que si no se agregan el compilador no tomara en cuenta dichos archivos.
```asm
# List of source files
SRCS = cnt10.s ivt.s default_handler.s reset_handler.s # En esta parte van los archivos fuente a compilar
```
## 3. Diagrama del hardware.
Para las salidas de los leds, se usaron los pines A0-A9, para las entradas de los pines B0 y B1, el boton de incremento esta configurado en el pin B0, y el boton de decremento esta configurado al pin B1.
![esquematico](https://github.com/paprikadreamdetective/Contador-Binario-10-bits/assets/133156970/9e6322b6-36eb-4b77-bc25-f970ac820b54)




