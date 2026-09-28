# Die drei Trinkgelder in App Store Connect anlegen

Stand: 28. September 2026. Die Produktkennungen stehen so im Quellcode. Weicht eine davon ab, lädt die App keine Preise und die Unterstützungsseite bleibt leer.

Anzulegen unter: App Store Connect, App auswählen, Monetarisierung, In-App-Käufe, Plus-Zeichen. Typ ist bei allen dreien **Verbrauchsartikel** (Consumable), weil ein Trinkgeld mehrfach gegeben werden kann und nichts dauerhaft freischaltet.

## Die drei Produkte

| Feld | Klein | Mittel | Groß |
|---|---|---|---|
| Typ | Verbrauchsartikel | Verbrauchsartikel | Verbrauchsartikel |
| Verweisname | Trinkgeld klein (Filterkaffee) | Trinkgeld mittel (Cappuccino) | Trinkgeld groß (Döner) |
| Produkt-ID | `de.juliankuerten.aevo.tip.small` | `de.juliankuerten.aevo.tip.medium` | `de.juliankuerten.aevo.tip.large` |
| Preis | 2,99 € | 5,99 € | 9,99 € |
| Anzeigename | Kleines Trinkgeld | Mittleres Trinkgeld | Großes Trinkgeld |
| Beschreibung | Ein Filterkaffee. Schaltet nichts frei. | Ein Cappuccino. Schaltet nichts frei. | Ein Döner. Schaltet nichts frei. |

Der **Verweisname** ist nur intern und taucht in Abrechnungen und Berichten auf. **Anzeigename** und **Beschreibung** sieht der Nutzer im Kaufdialog; sie sind auf 30 beziehungsweise 45 Zeichen begrenzt und liegen hier darunter. Die Lokalisierung braucht nur Deutsch, weil die App nur auf Deutsch erscheint.

Der Preis wird über einen Preispunkt gewählt, nicht frei eingetippt. Deutschland als Ausgangsland einstellen, dann die genannten Beträge auswählen. Apple leitet die Preise der übrigen Länder daraus ab.

## Den Screenshot machen, bevor die Produkte existieren

Auf den ersten Blick beißt sich die Katze in den Schwanz: App Store Connect möchte ein Bild der Kaufansicht, aber die Preise kommen doch erst von App Store Connect. Sie kommen nicht. Für die Entwicklung liefert die mitgelieferte Datei `Configuration/Tips.storekit` die drei Produkte lokal aus, mit deutschen Namen, dem Storefront DEU und den Beträgen 2,99 €, 5,99 € und 9,99 €. Das Gerät fragt dabei keinen Apple-Server.

So entsteht das Bild:

1. In Xcode das Scheme öffnen: Product, Scheme, Edit Scheme, Run, Reiter Options.
2. Bei **StoreKit Configuration** die Datei `Tips.storekit` auswählen.
3. Die App im Simulator starten, am besten auf einem iPhone mit 6,7 oder 6,9 Zoll.
4. In der App zu Einstellungen, App unterstützen, Freiwilliges Trinkgeld gehen. Dort stehen die drei Trinkgelder mit ihren Preisen.
5. Screenshot aufnehmen: im Simulator über Datei, Neuer Screenshot, oder mit Befehl-S.

Dasselbe Bild passt für alle drei Produkte, weil sie nebeneinander auf einer Seite stehen. Eine Größenvorgabe nennt Apple für dieses Bild nicht; ein gewöhnlicher Simulator-Screenshot genügt. Das Bild dient nur der Prüfung und erscheint nicht im App Store.

Ohne die StoreKit-Datei zeigt die App an dieser Stelle keine Beträge, weil sie dann tatsächlich bei Apple nachfragen würde und dort noch nichts angelegt ist. Genau dafür gibt es die Datei.

## Hinweise für die Prüfung

Vorschlag:

> Freiwilliges Trinkgeld an den Entwickler. Es schaltet keine Inhalte und keine Funktionen frei; die App ist vollständig kostenlos nutzbar. Zu finden über Einstellungen, App unterstützen, Freiwilliges Trinkgeld. Kein Konto und keine Anmeldung nötig.

## Reihenfolge

1. Paid Apps Agreement unterschreiben, dazu Steuer- und Bankangaben hinterlegen. Ohne diesen Vertrag lassen sich In-App-Käufe nicht aktivieren, auch nicht bei einer kostenlosen App.
2. Mit der StoreKit-Datei im Simulator den Screenshot aufnehmen, wie oben beschrieben.
3. Die drei Produkte anlegen, ausfüllen und Screenshot samt Prüfhinweisen hinterlegen.
4. Mit der ersten Version einreichen. Erste In-App-Käufe werden zusammen mit dem App-Build geprüft, nicht getrennt davon. Werden sie vergessen, erscheint die App ohne Kaufmöglichkeit.

## Kauf lokal durchspielen

Mit derselben StoreKit-Datei lassen sich vor dem Einreichen auch die Abläufe testen, ohne echtes Geld: erfolgreicher Kauf, Abbruch durch den Nutzer, fehlgeschlagene Prüfung und fehlende Verbindung. Xcode blendet dafür während des Laufs einen StoreKit-Transaktionsmanager ein, in dem sich Fehlerfälle erzwingen lassen.

`Scripts/validate_project.py` vergleicht die Kennungen in dieser Datei mit denen in der App-Konfiguration und meldet eine Abweichung, damit Test und Auslieferung nicht auseinanderlaufen.

In der ausgelieferten App kommt der Preis immer von Apple, nie aus dieser Datei; sie wirkt nur, wenn sie im Scheme ausgewählt ist. Sind die Produkte im Store noch nicht freigegeben, zeigt die App die Unterstützungsseite freundlich ohne Beträge. Das Lernen ist davon nicht betroffen.
