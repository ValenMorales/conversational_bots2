# Documentación del Bot

## Acceso a Atributos

Toda función a ejecutar puede acceder a los siguientes atributos:

- **event**: El evento específico que devuelve la API.
- **message**: El mensaje del usuario.
- **user**: El usuario o ID del usuario que envió el mensaje.
- **instance**: Instancia del bot para ejecutar acciones (por ejemplo, llamar a `send_message`).

## Comandos

Todo comando debe tener una descripción. La estructura de un comando es la siguiente:

- **description**: Descripción del comando.
- **message**: Si tiene un `message`, significa que solo va a responder a un comando dado.
- **action**: Si tiene un `action`, significa que ejecutará esa función dado el comando.
- **type**: Si tiene un `type`, significa que la lógica será específica para un tipo de bot.

## Instancias

Toda instancia de bot tiene los siguientes elementos que pueden ser llamados:

- **send_message**: metodo que envia un mensaje a un usuario o canal específico.

- **bot**: elementos especificos del bot que permiten usar sus respectivas
apis para funciones personalizadas

## Ejemplo de Uso

Aquí podrías agregar un ejemplo de cómo utilizar los comandos y métodos en el bot.
