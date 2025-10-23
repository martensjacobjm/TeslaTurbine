within;

package ORCSystem
  "Organic Rankine Cycle system med Tesla Turbine och solvärmesystem"

  /*
   * =============================================================================
   * ORC-SYSTEM MED TESLA-TURBIN
   * =============================================================================
   *
   * Detta paket innehåller en komplett modell av ett Organic Rankine Cycle (ORC)
   * system med R245fa som arbetsmedium. Systemet drivs av en värmekälla
   * (solfångare + ackumulatortank) och använder en Tesla-turbin som expander.
   *
   * SYSTEMKOMPONENTER:
   * ==================
   *
   * ORC-krets (arbetsmede R245fa):
   * 1. Evaporator - Förångare där R245fa förångas till överhettad ånga
   * 2. TeslaTurbineExpander - Bladlös turbin där ångan expanderar och producerar arbete
   * 3. Condenser - Kondensor där ångan kondenseras tillbaka till vätska
   * 4. WorkingFluidPump - Pump som cirkulerar R245fa
   *
   * Värmesystem:
   * 5. SolarCollector - Solfångare som samlar solenergi
   * 6. StratifiedTank - Stratifierad ackumulatortank för termisk lagring
   *
   * FORSKNINGSFRÅGOR SOM BESVARAS:
   * ==============================
   *
   * 1. SYSTEMVERKNINGSGRAD
   *    - Hur hög totalverkningsgrad kan uppnås med Tesla-turbinen?
   *    - Hur påverkar olika tryckförhållanden verkningsgraden?
   *    - Jämförelse med konventionella ORC-system
   *
   * 2. TESLA-TURBINENS PRESTANDA
   *    - Isentropisk verkningsgrad vid olika driftspunkter
   *    - Effekttäthet jämfört med konventionella expandrar
   *    - Optimal rotationshastighet
   *
   * 3. VÄRMEKÄLLANS INVERKAN
   *    - Hur påverkar variabel solinstrålning systemets prestanda?
   *    - Betydelse av termisk lagring för kontinuerlig drift
   *    - Optimal tankvolym och solfångararea
   *
   * 4. EKONOMI OCH PRAKTISK TILLÄMPNING
   *    - Energiutbyte per m² solfångare
   *    - Payback-tid för systemet
   *    - Lämplighet för olika applikationer (villa, industri, etc.)
   *
   * BIBLIOTEKETS STRUKTUR:
   * ======================
   * ORCSystem/
   * ├── Components/         - ORC-komponenter
   * │   ├── TeslaTurbineExpander.mo
   * │   ├── Evaporator.mo
   * │   ├── Condenser.mo
   * │   └── WorkingFluidPump.mo
   * ├── HeatSource/         - Värmesystem
   * │   ├── SolarCollector.mo
   * │   └── StratifiedTank.mo
   * ├── Examples/           - Kompletta systemmodeller
   * │   └── CompleteORCSystem.mo
   * └── package.mo          - Detta paket
   *
   * ANVÄNDNING:
   * ===========
   * 1. Ladda biblioteken:
   *    - Modelica Standard Library
   *    - ExternalMedia/CoolProp (för R245fa)
   *    - ThermoCycle (valfritt, för validering)
   *    - Buildings (för tank/solfångare-alternativ)
   *
   * 2. Öppna Examples.CompleteORCSystem
   *
   * 3. Kör simulering:
   *    - Simuleringstid: 0-86400 s (24 timmar)
   *    - Tidssteg: 10 s
   *
   * 4. Analysera resultat:
   *    - Effektuttag från Tesla-turbin
   *    - Systemverkningsgrad
   *    - Temperatur- och tryckförlopp
   *    - Energibalans
   *
   * FÖRFATTARE: Claude (Anthropic)
   * DATUM: 2025-10-23
   * VERSION: 1.0
   * LICENS: Se LICENSE-fil
   *
   * =============================================================================
   */

  // Import av sub-paket
  extends Modelica.Icons.Package;

  annotation(
    version="1.0.0",
    versionDate="2025-10-23",
    Documentation(info="<html>
<h1>ORC System med Tesla Turbine</h1>

<p>
Detta bibliotek innehåller en komplett modell av ett Organic Rankine Cycle (ORC)
system med Tesla-turbin som expander och solvärme som energikälla.
</p>

<h2>Systemöversikt</h2>

<p>
Ett ORC-system fungerar likt en ångturbin men använder ett organiskt arbetsmedium
(R245fa) istället för vatten. Detta möjliggör effektiv energiomvandling vid
lägre temperaturer (60-150°C), perfekt för solvärme, spillvärme, biobränsle, etc.
</p>

<h3>ORC-processen</h3>
<ol>
<li><b>Förångning</b>: R245fa värms och förångas i förångaren</li>
<li><b>Expansion</b>: Ångan expanderar genom Tesla-turbinen och producerar arbete</li>
<li><b>Kondensering</b>: Ångan kondenseras i kondensorn</li>
<li><b>Pumpning</b>: Vätskan pumpas tillbaka till förångaren</li>
</ol>

<h3>Tesla-turbinen</h3>
<p>
En bladlös turbin där ångan flödar mellan roterande skivor. Fördelar:
</p>
<ul>
<li>Enkel konstruktion (inga blad)</li>
<li>Låg tillverkningskostnad</li>
<li>Kan hantera tvåfasflöde</li>
<li>Lågt underhåll</li>
</ul>

<h2>Forskningsfrågor</h2>

<h3>1. Systemverkningsgrad</h3>
<p>
Hur effektivt kan systemet omvandla termisk energi till elektrisk energi?
</p>
<ul>
<li>Total verkningsgrad: η_tot = W_net / Q_in</li>
<li>Jämförelse med Carnot-verkningsgrad</li>
<li>Inverkan av olika driftparametrar</li>
</ul>

<h3>2. Tesla-turbinens prestanda</h3>
<ul>
<li>Isentropisk verkningsgrad</li>
<li>Effekttäthet [W/m³]</li>
<li>Optimal rotationshastighet</li>
</ul>

<h3>3. Värmekällans betydelse</h3>
<ul>
<li>Variabel solinstrålning och molnighet</li>
<li>Termisk lagring för kontinuerlig drift</li>
<li>Optimal systemdimensionering</li>
</ul>

<h2>Exempel</h2>

<p>
Se <a href=\"modelica://ORCSystem.Examples.CompleteORCSystem\">CompleteORCSystem</a>
för ett körklart exempel.
</p>

<h2>Referenser</h2>
<ul>
<li>Quoilin et al. (2013): Thermo-economic optimization of waste heat recovery Organic Rankine Cycles</li>
<li>Tesla, N. (1913): Turbine, U.S. Patent 1,061,206</li>
<li>Lemort et al. (2009): Systematic optimization of subcritical and transcritical organic Rankine cycles</li>
</ul>

</html>"));

end ORCSystem;
