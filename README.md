# WIN3BU-Lokaverkefni
Lokaverkefni Fyrir WIN3BU Powershell áfangi þar sem manni er kynnt fyrir að nota GUI
# Verkefnið Mitt
Ég mun búa Til GUI með Powershell sem mun (vonandi) vera meira hnitmiðað og auðveldara í notkun þegar kemur að þessari almennri uppsetningu, það mun vera skipt í nokkra tabs og þar sem verður hægt að setja inn viðeigandi upplýsingar til að setja upp domainið og svo setja inn notendur og ýmislegt meira
# Tilgangur Verkefnis
það hljómar kannski skrýtið að vera búa til GUI fyrir eitthvað sem er til í GUI innbyggt en þetta mun vera aðeins fljótlegra að þessu "klassíska" en það er kannski ekki alltaf praktískara að nota þetta hinsvegar er þetta fyrst og fremst bara svo ég geti tileinkað mér nýjungar og lært á GUI manipulation í Powershell og í staðinn fyrir að vera gera bara bunch af nothings fannst mér þetta ekkert svo klikkuð hugmynd

# Staða
11/4/17 - Byrjað á því að  huga að útlitinu á GUIinu og hægt og rólega byggja það upp <br>
14/4/17 - Virkni fyrir fyrsta tab og uppsetningu klárað byrjað að huga að útliti og virkni fyrir dhcp uppsetningu <br>
19/4/17 - DHCP scope útfærsla kominn með Datagridview fyrir active scopes ásamt setja vél inná domain með datagrid fyrir vélar á domaini import með notendur verður útfært og reynt verður að hafa það eins dynamic og gerist til að það vinni sem best með mismunandi csv skrám<br>
23/4/17 - commit<br>
Lenti í veseni með að fá réttan kóða út úr þessu, og eftir ég náðí að raða þessu þannig þá las kóðinn út það sem ég vildi ss. $s.xxxxx nema mér til undrunar las scriptblock það sem streng en convertaði ekki í foreach value-ið þannig ég þurfti að endurhugsa þetta aðeins...<br>
03/05/17 - kóðinn skilar sér eðlilega fyrir hvern notenda en þegar þetta er keyrt þá crashar forritið við creation á notendum... <br> 
04/05/17 - Kóðinn býr til notendur eðlilega, prentara eðlilega, möppur eðlilega, grouppur eðlilega, nema forritið í keyrslu er að nota 200mb+ af ram, eftir smá endurröðun á kóða fer það niður í 160-180 og forrit krassar minna, náði 550 notendum inn af 1500, ætla athuga hvort það lagist við að gera kóðan "hreinni" <br>
04/05/17 - virknin er tilstaðar virkaði með minni csv skrám en þessi stóra virðist feila eftir 500+ notendur, en allt undir það virkar vel, held áfram að skoða lausnir síðar <br>
04/05/17 - TAB3 (Importa Notendum og Möppur) - virkaði án villumeldinga með 3 mismunandi CSV skrám bæði stóru og 2 litlum fjölbreyttum, hægt að error preventa meira og bæta við frekari hjálp t.d. að velja 2 OU og gera OU inní OU en það er seinni tíma thing, næst á dagskrá væri Notendastjórnborðið eða þá eiga við notendurnar (resetpass, disable, transfer etc... ) <br>
05/05/17 - Hafist handa á Tab4 Datagrid OU navigator kominn tilstaðar þar sem hægt er að tvíklikka á OU og opna þá undirOU ef það eru eitthver t.d. Notendur->Yfirstjórn og ef það er ekki annað OU undir þá kemur hann með alla Notendur inní OUinu, einnig verður hægt að bara slá inn nafn eða notendanafn og það mun leita <br>
07/05/17 - Fyrir meira smooth virkni var leitarstrengurinn takmarkaður bara í nafn, einnig var lagað villur sem olli því að gæjar með sama nafn en sitthvorar upplýsingar kæmu með mergaðar upplýsingar, gert undirbúning fyrir parametra breytingar á notendum og síðan verður bætt við meira manipulationi fyrir OU og færa notendur milli ou, 
