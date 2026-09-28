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

## Was jedes Produkt zusätzlich braucht

Ohne diese beiden Angaben bleibt ein Produkt im Zustand „Metadaten fehlen" und wird nicht mitgeprüft.

**Screenshot für die Prüfung.** Ein Bild der Unterstützungsseite aus der laufenden App, erreichbar über Einstellungen, App unterstützen, Freiwilliges Trinkgeld. Dasselbe Bild kann für alle drei Produkte verwendet werden, weil dort alle drei nebeneinander stehen.

**Hinweise für die Prüfung.** Vorschlag:

> Freiwilliges Trinkgeld an den Entwickler. Es schaltet keine Inhalte und keine Funktionen frei; die App ist vollständig kostenlos nutzbar. Zu finden über Einstellungen, App unterstützen, Freiwilliges Trinkgeld. Kein Konto und keine Anmeldung nötig.

## Reihenfolge

1. Paid Apps Agreement unterschreiben, dazu Steuer- und Bankangaben hinterlegen. Ohne diesen Vertrag lassen sich In-App-Käufe nicht aktivieren, auch nicht bei einer kostenlosen App.
2. Die drei Produkte anlegen und vollständig ausfüllen.
3. Mit der ersten Version einreichen. Erste In-App-Käufe werden zusammen mit dem App-Build geprüft, nicht getrennt davon. Werden sie vergessen, erscheint die App ohne Kaufmöglichkeit und die Trinkgeldseite bleibt in der Fassung ohne Preise.

## Vorher lokal prüfen

Die Datei `Configuration/Tips.storekit` enthält dieselben drei Kennungen mit Testpreisen. In Xcode unter Product, Scheme, Edit Scheme, Run, Options als StoreKit-Konfiguration auswählen. Damit lassen sich Kauf, Abbruch und fehlende Verbindung ohne echtes Geld durchspielen. `Scripts/validate_project.py` vergleicht die Kennungen in dieser Datei mit denen in der App-Konfiguration und meldet eine Abweichung.

Der Preis in der App kommt immer von Apple, nie aus dieser Datei. Sind die Produkte im Store noch nicht freigegeben, zeigt die App die Unterstützungsseite freundlich ohne Beträge; das Lernen ist davon nicht betroffen.
