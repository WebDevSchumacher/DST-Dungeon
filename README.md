# Abschlussprojekt

Elm Roguelike Game as University project for declarative programming.

## Beschreibung des Ablaufs und implementierter Features
### Game World
Der Spieler startet in einem kleinen Raum als Eingang.
Räume sind rechteckig aus Feldern aufgebaut, wobei ein Feld einer Schrittweite des Spielers entspricht.

Räume haben grundsätzlich Ausgänge an den 4 Seiten.

Beim Betreten eines Ausgangs gelangt man in den nächsten Raum. 
Existiert dieser noch nicht innerhalb der World Map, wird er zufällig generiert (Größe des Raums, Positionen der Hindernisse).
Beim Generieren wird dem Raum ein Level zugewiesen, das dem des Spielers entspricht und behält dieses auch beim erneuten Betreten bei.
Das Raumlevel bestimmt das Level der Gegner in diesem Raum.

Beim Betreten eines Raums wird ein zufälliger Gegner dort platziert. 
Dabei wird ihm auch der Loot zugewiesen, der aus mehreren zufälligen Items bestehen kann, die in der Summe der Item Levels dem Gegner Level entsprechen.

Besiegte Gegner lassen den Loot in Form einer Kiste fallen.

![Enemy](https://user-images.githubusercontent.com/62644021/132124979-1fcf29ef-57a3-4ecf-8b30-ff64c80a64fd.png)
![Loot](https://user-images.githubusercontent.com/62644021/132124997-c0673111-8f36-4c41-bba5-2deab8b4ec47.png)

Der Spieler sammelt Erfahrung und steigt im Level auf, wodurch anschließend neu generierte Räume schwieriger werden, aber auch besseren Loot ermöglichen.

Potentiell kann das Spiel unendlich weit durchlaufen werden, wobei Items bis Level 23 implementiert sind, Räume und Gegner jedoch ungeachtet dessen weiter skalieren.

### Interaktionen
Aktionen des Spielers werden durch die Laufrichtung bestimmt, bzw. durch den Kontext des Zielfeldes:

Freies Feld: Spieler läuft auf des Feld

Gegner: Spieler schlägt den Gegner

Lootkiste: Spieler sammelt Items ein

Ausgang: Spieler geht in den nächsten Raum

Gegner laufen und greifen den Spieler ebenfalls an, wobei dies durch ein Pathfinding Modul erreicht wird (Quellenangabe siehe unten, bzw Path.elm).

### Inventar
Über die Icons unter den gelisteten Items kann per Mausklick interagiert werden:

Benutzen (linkes Icon) unterscheidet sich zwischen den Item Typen. Waffen und Rüstung wird an- bzw abgelegt, Essen und Tränke werden konsumiert.

Wegwerfen (rechts Icon) entfernt den ganzen Stack aus dem Inventar.

Info (mittleres Icon oder Itembild) blendet die Iteminformation ein.

![Inventory](https://user-images.githubusercontent.com/62644021/132125112-7ae6d4b7-06a9-4720-bb61-597296b36c9b.png)

### Unterschiede zur geplanten Umsetzung
Anstelle der Steuerung in Mausrichtung haben wir eine WASD Steuerung umgesetzt, die dem Grid-Layout des Spieles dienlicher ist.

Interaktionen mit den Objekten im Raum nicht per Mausklick sondern wie oben beschrieben ebenfalls per WASD.

Blocken bzw. Schilde als Items sind nicht implementiert.

Ausgänge sind nicht zufällig generiert sondern stets oben, unten, links und rechts.

Spezielle Bossräume mit anspruchsvolleren Gegnern und besonderem Loot sind nicht implementiert.

Lootkisten tauchen nicht eigenständig in Räumen auf, sondern nur in Form von Gegnerloot.

# Elm App

This project is bootstrapped with [Create Elm App](https://github.com/halfzebra/create-elm-app).

## How to Start App

```sh
elm-app start
```

## Installing Elm packages

```sh
elm-app install <package-name>
```

## Credit Assets

Assets where taken from:  
https://pixel-boy.itch.io/ninja-adventure-asset-pack  
https://0x72.itch.io/dungeontileset-ii  
https://pixelfrog-assets.itch.io/pixel-adventure-1  
https://jeevo.itch.io/dungeoneering-eq-icon-pack

Pathfinding module taken from https://github.com/danneu/elm-hex-grid and adjusted to our needs
