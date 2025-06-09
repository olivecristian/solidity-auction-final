# Solidity Final Project – AuctionTP.sol

Trabajo práctico final del Módulo 2 – Curso de Solidity  
Autor: Cristian Olivé – Junio 2025
Contrato desplegado en Sepolia
Dirección del contrato:
https://sepolia.etherscan.io/address/0x1401c25ccE343932d92e752bA5eF9E2D52153ff8#code
Descripción
Este contrato inteligente implementa un mecanismo de subasta con las siguientes características:
- Acepta ofertas durante un tiempo limitado (45 minutos).
- Requiere que cada nueva oferta supere en al menos un 5 % la oferta más alta actual.
- Si se realiza una oferta válida durante los últimos 10 minutos, la subasta se extiende 10 minutos adicionales.
- Permite a los participantes no ganadores retirar sus depósitos al finalizar la subasta.
- Aplica una comisión del 2 % al monto ganador, que se transfiere al creador del contrato.
Constructor
El constructor inicializa el contrato con la dirección del creador y fija el tiempo de duración de la subasta en 45 minutos.
constructor() {
    owner = msg.sender;
    startTime = block.timestamp;
    stopTime = startTime + 45 minutes;
}
Funciones del contrato
bid()
Permite a los usuarios ofertar. La oferta debe ser mayor a cero y al menos un 5 % superior a la oferta actual más alta. Si se realiza dentro de los últimos 10 minutos, la subasta se extiende.
showWiner()
Devuelve la dirección del ganador actual y el monto de su oferta.
showOffers()
Devuelve una lista con todas las ofertas realizadas durante la subasta.
refund()
Permite a los usuarios que no ganaron retirar sus fondos luego de finalizada la subasta.
partialRefund()
Permite a los participantes retirar sus ofertas anteriores (excepto la última) mientras la subasta sigue activa.
finalizeAuction()
Solo el owner puede ejecutar esta función. Finaliza la subasta y transfiere el monto ganador menos el 2 % de comisión al owner.
Variables utilizadas
owner: dirección del creador del contrato.
startTime: momento en que comienza la subasta.
stopTime: momento en que termina la subasta.
commission: porcentaje de comisión (2 %).
winner: estructura que guarda la mejor oferta y el postor.
biders[]: arreglo con todas las ofertas realizadas.
deposits: mapping que asocia cada dirección con el total de ETH aportado.
biddingHistory: mapping que registra el historial de ofertas por dirección.
ended: booleano que indica si la subasta ha sido finalizada.
Eventos
NewOffer(address bider, uint256 amount): Se emite cuando se realiza una nueva oferta válida.
AuctionEnded(address winner, uint256 amount): Se emite cuando se finaliza la subasta correctamente.
Archivos del repositorio
AuctionTP.sol: código fuente del contrato inteligente.
README.md: archivo de documentación.
Notas
- El contrato fue desarrollado con Solidity versión 0.8.0 o superior.
- Está desplegado y verificado en la red de prueba Sepolia.
