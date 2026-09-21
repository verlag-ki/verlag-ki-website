# Täglicher Lernimpuls mit belegten Zitaten

Stand: 20. September 2026. Quellcodestand 0.3.1, Buildnummer 6.

Fünf kurze Zitate ergänzen die 31 eigenen Lernimpulse. Sie handeln von selbstständigem Denken, Neugier, Geduld, Konzentration und Selbstvertrauen. Die Zitate sind literarische Denkanstöße. Sie dienen nicht als wissenschaftlicher Beleg für Lernerfolg oder als Bestehensversprechen.

## In der App

Die Startseite zeigt weiterhin genau einen Impuls. Bei einem Zitat stehen deutsche Anführungszeichen um den Text; darunter folgen der ausgeschriebene Name und „Quelle“. Erst beim Antippen öffnet sich eine Quellenansicht mit Werk, genauer Fundstelle, Link, Abgleichdatum und gegebenenfalls historischem Wortlaut. Ein Klick auf den Weblink öffnet den Originaltext. Es wird kein Text automatisch aus dem Internet nachgeladen.

Die 36 unterschiedlichen Texte bilden einen festen Zyklus. Fünf Zitate sind mit jeweils sechs eigenen Impulsen dazwischen verteilt; nach dem letzten Zitat folgen sieben eigene Impulse bis zum nächsten Zyklus. Pro lokalem Kalendertag bleibt der Text gleich. Ein Neustart würfelt ihn nicht neu aus. Ein Datumswechsel beziehungsweise die Rückkehr in die App aktualisiert den Startseitentext. Die bereits geöffnete Quellenansicht behält das tatsächlich angetippte Zitat auch über Mitternacht.

Die Zitate erscheinen auch in der persönlichen Farbvorschau mit Urheberangabe. Der vorhandene Schalter „Täglichen Lernimpuls anzeigen“ blendet den ganzen Bereich aus. Es gibt weder einen zusätzlichen Onboarding-Schritt noch neue Erinnerungen, Abzeichen oder Nachfragefenster. Die acht Farbwelten, Name, Countdown und bisherigen freiwilligen Unterstützungsregeln bleiben erhalten.

Text, Quellenangabe und Wortlauthinweis sind mit der App gebündelt und offline lesbar. Nur der ausdrücklich geöffnete externe Originaltext benötigt Internet. Dynamic Type, mehrzeilige Autorennamen, 44-Punkt-Bedienelemente und VoiceOver-Beschriftungen sind im Quellcode berücksichtigt. Die Quellenansicht setzt ihre Textfarbe ausdrücklich auf die Systemfarbe zurück, damit sie im hellen und dunklen Modus nicht die weiße Schrift der Startseitenkarte übernimmt.

## Redaktionell abgeglichene Auswahl

Alle folgenden Fundstellen wurden am 20. September 2026 geöffnet und der verwendete Wortlaut gelesen. Die Quellen sind Transkriptionen historischer Texte; keine der ausgewählten Formulierungen beruht allein auf einer unbelegten Zuschreibung in einer Spruchsammlung. Ein unabhängiges Lektorat hat noch nicht stattgefunden.

| Urheber | Anzeige | Fundstelle und Bearbeitung |
|---|---|---|
| Immanuel Kant | „Habe Mut, dich deines eigenen Verstandes zu bedienen!“ | [Beantwortung der Frage: Was ist Aufklärung?](https://de.wikisource.org/wiki/Beantwortung_der_Frage:_Was_ist_Aufkl%C3%A4rung%3F), Berlinische Monatsschrift, Dezember 1784, S. 481, erster Absatz. „Muth“ wird zu „Mut“, das Komma wird ergänzt. Historischer Wortlaut bleibt einsehbar. |
| Marie von Ebner-Eschenbach | „Wenn die Neugier sich auf ernsthafte Dinge richtet, dann nennt man sie Wissensdrang.“ | [Aphorismen, Erstes Hundert, Nr. 73](https://www.gutzitiert.de/aphorismen_parabeln_maerchen_und_gedichte-marie_von_ebner_eschenbach-kapitel_2.html). Gesammelte Schriften, Band 1, Ausgabe 1893. Wortlaut unverändert. |
| Rainer Maria Rilke | „Leben Sie jetzt die Fragen.“ | [Brief an Franz Xaver Kappus vom 16. Juli 1903](https://www.rilke.de/briefe/160703.htm), Worpswede. Vollständiger Satz aus dem Absatz, der mit „Sie sind so jung“ beginnt. Der Kontext handelt von offenen Lebensfragen. |
| Johann Wolfgang von Goethe | „In der Beschränkung zeigt sich erst der Meister“ | [Natur und Kunst](https://www.deutschelyrik.de/natur-und-kunst.html), 1800, Vers 13. Versauszug; das nachfolgende Komma entfällt. Das Gedicht handelt von Natur, Kunst und Form. |
| Marie von Ebner-Eschenbach | „Wenn es einen Glauben gibt, der Berge versetzen kann, so ist es der Glaube an die eigene Kraft.“ | [Aphorismen, Erstes Hundert, Nr. 29](https://www.gutzitiert.de/aphorismen_parabeln_maerchen_und_gedichte-marie_von_ebner_eschenbach-kapitel_2.html), Ausgabe 1893. „giebt“ wird zu „gibt“. Historischer Wortlaut bleibt einsehbar. |

Das [digitalisierte Titel- und Ausgabenverzeichnis bei Wikimedia Commons](https://commons.wikimedia.org/wiki/Category:Aphorismen_Ebner-Eschenbach_(1893)) belegt für die verwendete Ebner-Eschenbach-Ausgabe Band 1, Verlag Gebrüder Paetel, Berlin 1893. Die dortigen Scans wurden für diese Ergänzung nicht vollständig seitenweise geprüft; der Wortlautabgleich erfolgte an der verlinkten Transkription.

Es werden historische deutsche Originaltexte verwendet, keine modernen Übersetzungen, Fotos, Tonaufnahmen oder fremden redaktionellen Erläuterungen. Die Autoren starben 1804, 1832, 1916 beziehungsweise 1926. Für die Auswahl im deutschen Zielmarkt ist die allgemeine Schutzfrist von 70 Jahren nach dem Tod mit Berechnung ab Jahresende maßgeblich: [§ 64 UrhG](https://www.gesetze-im-internet.de/urhg/__64.html), [§ 69 UrhG](https://www.gesetze-im-internet.de/urhg/__69.html). Die Quellenansicht und die Erläuterungen zur Verwendung in der App sind eigene Texte. Neue Zitate brauchen vor Aufnahme ebenfalls einen Wortlautabgleich und eine dokumentierte Nutzungsgrundlage.

## Technischer Umfang und Prüfung

`Core/DailyImpulse.swift` enthält Text, stabile Kennung und optionale Quellenmetadaten sowie die lokale Tagesauswahl. Originalimpulse haben keine fremde Urheberangabe. `App/DailyImpulseView.swift` wird von Startseite und Profilvorschau gemeinsam genutzt. Eine geöffnete Quelle hält eine Kopie des ausgewählten Eintrags. Das Profil- und Sicherungsformat bleibt unverändert.

43 vorhandene XCTest-Prüfungen bestanden nach der Umstellung auf die Rotation mit 36 Tagen. Sie umfassen unter anderem Tagesstabilität, Datumswechsel, Sommerzeit, Zeitzonen, Profilwerte und alte Sicherungen. Der Foundation-Kern wurde auf Linux kompiliert und ausgeführt. Alle 20 App-Dateien wurden syntaktisch geprüft, das Xcode-Projekt mit 64 Objekten unabhängig geparst und die Projektintegrität geprüft.

Noch nicht erfolgt sind Apple-SDK-Typecheck, nativer Build, Darstellung auf dem iPhone und VoiceOver-Prüfung. Der vollständige externe Originaltext ist bewusst kein Offline-Versprechen. Die fachlichen AEVO-Inhalte behalten ihren bisherigen Entwurfs- und Freigabestand.
