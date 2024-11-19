# Maratonlistan i Giona

I maratonlistan identifieras en person med förnamn, efternamn och
födelsedatum.  Detta lagras i en egen tabell.

Sedan en annan tabell med en rad för varje genonmförd segling, och en
rad med importerat data.  Efter varje regatta uppdateras denna för
varje person.

## Tabeller

```
marathon_people
  first_name, last_name, birthday, hourglass, people_id?
```

`hourglass` sätts till det år personen fått utmärkelsen timglaset.

```
marathon_log
  marathon_people_id, regatta_id,
  sailed_dist, plaque_dist,
  boat_type, boat_name, year, organizer_id
```

`regatta_id` är `NULL` om det är historisk import.

Notera att import kan ske från olika kretsar.

I tabellen `person`:

```
marathon_people_id: integer
```

## Import från starema och andra kretsar

Enklast vore att vi hade fått uppdaterad maratontabell från de kretsar
som idag använder Giona.  Då hade vi kunnat verifierat att alla
personer som finns i Giona som har fullföljt minst en segling faktiskt
finns med i maratontabellen.

Gör detta som ett task.  Lämpligtvis tag gamla datat på csv-format och
läs in.  En del gamla poster kan ha okänd födelsedag.

För varje post i filen, kolla om det redan finns en rad i
maratontabellen med samma förnamn, efternamn och födelsedatum.  Om det
gör det, flagga den för manuell kontroll.  Om det inte gör det, lägg
in en ny rad i maratontabellen.

Alternativt, gör som Vk, kolla födelsedatium samt initialer, för att
slippa problem med olika stavning på namn mm.

Kör sedan ett nytt task som för varje person i `people` ser om det
finns en motsvarande post i maratontabellen.  Om det inte gör det och
vi har fått rådata från alla kretsar så är det ett fel.  Flagga för
manuell redigering.  Om vi inte har fått från alla kretsar så är det
bara ett fel om personen har seglat en regatta i en krets som vi fått
rådata från.  Detta skulle kunna automatiseras.

Om personen finns i maratontabellen, uppdatera personens
`marathon_people_id`.`

## Uppdatera maratontabellen automatiskt

När en regatta är färdigrättad, måste en funktionär klicka på
`Fastställ resultatet`.  Detta kan man bara göra en gång.  När man
klickar där uppdateras motsvarande rad i maratontabellen.  Om ingen
sådan rad finns så skapas den.

Man kan tänka sig att denna knapp bara går att klicka på om kretsen har
importerat existerande maratondata till Giona.

En annan ide är att betrakta maratontabellen som bara innehållande
historiskt data, och istället lägga till två nya fält i `teams`;
`sailed_dist` och `plaque_dist`.  Dessa fält skulle uppdateras när man
klickar `Fastställ resultatet`.  När man sedan tittar på maratonlistan
skulle vi ta maratontabellen och addera alla personens teams
fastställda distanser.

En fördel med denna lösning är att det går att ändra ett resultat i
efterhand, genom att göra en justering i loggboken och sedan klicka på
`Fastställ resultatet` igen.

Om vi gör detta är det viktigt att man inte kan göra `Fastställ
resultatet` på gamla regattor som redan är medräknade i
maratontabellen.

## Titta på maratontabellen

- per krets
- riks totalt
- exportera till excel

Endast funktionärer skall se födelsedag.

När man tittar på tabellen så skall man kunna se om en deltagare skall
få en ny plakett detta år.  Det kan man göra genom att man kan fylla i
vilket år man vill titta på (default innevarande år, eller möjligen
året för senast regatta med resultat).  Systemet kan sedan summera
fram till detta år - 1, och sedan addera resultaten från detta år, och
se om ett tröskelvärde passerats.

## Ny deltagare

När en ny deltagare skapas så kan man tänka sig att vi kollar i
maratonabellen och ser om personen finns där.  Om det är fallet så
sätter vi `marathon_id`, i annat fall blir den `null`.

Man kan också tänka sig att vi inte sätter denna, utan mailar admin.

## Potentiella fel

### Namn kan stavas olika

Framförallt accenter, dubbelnamn med eller utan bindestreck etc.

### Dubletter

Det finns redan idag dubbla konton för en del personer.  De kanske har
glömt sin gamla mailadress, eller inte längre kommer åt den.

Det kan förstås också skapas dubbla konton i framtiden också!

Å andra sidan gör det kanske inget - flera personer pekar på samma
maraton-person.  Det är ok.


# FRÅGOR TILL STEFAN


- Använd bin/rails generate model för att skapa ny tabell?

  A: Ja!

- Hur göra med vår gamla ruby och gamla rails...?

- Nackdel med hostad miljö - bara dålig erfarenhet av skakig drift?

---------

- många konstiga dubletter, hur hantera??

- hur undvika - ibland verkar det vara gammal/fel mail

- klurigt att hantera Kretsens egna maratonlista.  ska varje deltagare
  tillhöra en krets??

- Ensamseglingen skall INTE räknas in
  kanske en nytt fält på varje regatta som man måste välja?

---------

En ide är att slå ihop user & person till ett objekt.  Klurigt.  Kolla
devise som används för auth.

Ide på import: Exportera fil till kretsen som vill importera med alla
deltagare inklusive `person_id`.  Dom måste tillverka en fil med
maraton-data, och rätt `person_id` i de falll personen finns i Giona.

Se maratonhanteringen som en separat applikation med egna tabeller,
som råkar vara implementeradi Giona.  En tabell med namn etc och en
med resultat.  När man importerar blir det ett resultat som innehåller
allt historiskt.  När man fastställer resultatet på en regatta skapar
man ett nytt resultat per person.

