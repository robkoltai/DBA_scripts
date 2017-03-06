Szia Zsolt!

Mellékeltem 2 sql scriptet. Mielõtt elindulna a feldolgozás nyiss 2-2 sysdba session-t minden példányhoz (CLVS1, CLVS2, CLVSDUP). Elõször indítsd el az sts.sql-t az egyik, majd a trc.sql-t a másik munkamenetben. Ha minden jól megy, ezek mindaddig futnak, amíg a teszt végén CTRL-C-vel le nem állítod õket.

Az sts.sql törli a Library Cache-bõl a figyelt 4 sql-t, létrehoz egy SQL tuning Set-et, majd leállításig gyûjtögeti a statisztákat róluk.

A trc.sql figyeli, hogy megjelent-e egy új child cursor a 4 sql valamelyikéhez, ha igen, akkor készít egy "Compiler" trace fájlt róla.

Üdv.

    Barna

2016.03.31. 10:46 keltezéssel, Nagy Zsolt írta:
Tisztelt Support!
 
Kérem az alábbi monitorozási témában a közremûködést.
Kiemelt fontosságú a jelentés készítés.
 
Köszönettel,
Nagy Zsolt Zoltán
IT infrastruktúra üzemeltetési senior szakértõ
Ügyeleti rendek
 
OTP Bank Nyrt.
DBMO-DBA 
Adatbázis Menedzsment Osztály
Telefon: +36 (1) 298 3433
Mobil: +36 (70) 708 0313
www.otpbank.hu
 
 
From: Nagy Zsolt 
Sent: Thursday, March 31, 2016 10:43 AM
To: Viczán Béla
Cc: Doktor Jánosné (DoktorJ@otpbank.hu); Irimi János; Anda Péter
Subject: 30U jelentés készítés
 
Kedves Béla!
 
Kérjük, hogy Április 4.-én reggel a 30U jelentést, reggel 8:30-kor egyszerre indítsátok el, a DUP-on és az élesen.
Elõtte, kérem, hogy a DUP-ot frissítsétek az élessel a szokásos módon, hogy minél jobban hasonlítson az élesre.
A folyamatokat monitorozni fogjuk és a futások végén kiértékeljük.
 
Köszönettel,
Nagy Zsolt Zoltán
IT infrastruktúra üzemeltetési senior szakértõ
Ügyeleti rendek
 
OTP Bank Nyrt.
DBMO-DBA 
Adatbázis Menedzsment Osztály
Telefon: +36 (1) 298 3433
Mobil: +36 (70) 708 0313
www.otpbank.hu
 
 

________________________________________

Ez az üzenet, s bármely melléklete bizalmas információkat tartalmazhat és kizárólag a címzettnek szól.
Amennyiben nem Ön ennek az üzenetnek a címzettje, kérjük azonnal értesítse a feladót, s az üzenetet törölje a rendszerébõl.

This message and any attachment may be confidential and intended exclusively for the addressee.
If you are not the intended addressee please notify the sender immediately and delete this message and any attachment from your system.

OTP Bank Nyrt.
1051 Budapest, Nádor utca 16.
Cégjegyzékszám: Cg.: 01-10-041585; Fõvárosi Törvényszék Cégbírósága

