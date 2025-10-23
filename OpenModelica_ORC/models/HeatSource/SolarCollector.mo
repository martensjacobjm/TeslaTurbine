within ORCSystem.HeatSource;

model SolarCollector
  "Solfångare för uppvärmning av värmebärare till ORC-systemet"

  /*
   * BESKRIVNING:
   * ===========
   * Plana solfångare eller vakuumrör som samlar solenergi och värmer
   * upp värmebäraren (vatten/glykol) som sedan värmer ORC-systemet.
   *
   * Modellen inkluderar:
   * - Solstrålningsabsorption
   * - Värmeutbyte till värmebärare
   * - Förluster (konvektion, strålning)
   * - Verkningsgrad som funktion av temperatur och instrålning
   * - Dynamisk respons
   *
   * FORSKNINGSFRÅGOR:
   * ================
   * 1. Hur påverkar molnighet och variabel instrålning ORC-prestandan?
   * 2. Optimal solfångararea för given ORC-storlek
   * 3. Fördelar med termisk lagring (ackumulatortank)
   */

  import Modelica.SIunits.*;

  // ============ PARAMETRAR ============
  parameter Area A_collector = 10.0 "Solfångararea [m²]";
  parameter Real eta_0 = 0.75 "Optisk verkningsgrad vid normalt infallande ljus";
  parameter Real a1 = 4.0 "Linjär förlustkoefficient [W/(m²·K)]";
  parameter Real a2 = 0.015 "Kvadratisk förlustkoefficient [W/(m²·K²)]";
  parameter Mass m_collector = 50 "Massa av solfångare (termisk massa) [kg]";
  parameter SpecificHeatCapacity cp_collector = 900 "Specifik värmekapacitet [J/(kg·K)]";
  parameter Temperature T_ambient_nominal = 273.15 + 15 "Nominell omgivningstemperatur [K]";
  parameter Irradiance G_nominal = 800 "Nominell solstrålning [W/m²]";

  // ============ VARIABLER ============
  // Meteorologiska indata
  Irradiance G "Solstrålning (global) [W/m²]";
  Temperature T_ambient "Omgivningstemperatur";
  Velocity v_wind "Vindhastighet [m/s]";

  // Solfångare tillstånd
  Temperature T_collector(start=T_ambient_nominal + 20) "Medeltemperatur solfångare";
  Temperature T_absorber "Absorbertemperatur";

  // Värmebärare
  Temperature T_fluid_in "Inloppstemperatur värmebärare";
  Temperature T_fluid_out "Utloppstemperatur värmebärare";
  MassFlowRate m_flow "Massflöde värmebärare";
  SpecificHeatCapacity cp_fluid = 4180 "Specifik värmekapacitet värmebärare (vatten)";

  // Energiflöden
  HeatFlowRate Q_solar "Absorberad solenergi";
  HeatFlowRate Q_loss "Värmeförluster till omgivningen";
  HeatFlowRate Q_useful "Nyttig värme till värmebärare";
  Power P_thermal "Termisk effekt till system";

  // Prestanda
  Real eta_collector "Aktuell solfångarverkningsgrad";
  TemperatureDifference dT_mean "Medeltemperaturdifferens (kollektor - omgivning)";
  Real reducedTemperature "Reducerad temperatur T*/G";

  // Ackumulerad energi
  Energy E_solar_total(start=0) "Total solenergi insamlad";
  Energy E_useful_total(start=0) "Total nyttig energi levererad";

equation
  // ============ MEDELTEMPERATURDIFFERENS ============
  T_absorber = T_collector;  // Förenkling
  dT_mean = T_absorber - T_ambient;

  // ============ REDUCERAD TEMPERATUR ============
  reducedTemperature = if G > 10 then dT_mean / G else 0;

  // ============ ABSORBERAD SOLENERGI ============
  Q_solar = eta_0 * A_collector * G;

  // ============ VÄRMEFÖRLUSTER ============
  // Enligt standardmodell för plana solfångare (EN 12975)
  Q_loss = A_collector * (a1 * dT_mean + a2 * dT_mean^2);

  // ============ NYTTIG VÄRME ============
  Q_useful = Q_solar - Q_loss;

  // ============ VERKNINGSGRAD ============
  eta_collector = if G > 10 then Q_useful / (A_collector * G) else 0;

  // ============ VÄRMEÖVERFÖRING TILL VÄRMEBÄRARE ============
  P_thermal = m_flow * cp_fluid * (T_fluid_out - T_fluid_in);
  P_thermal = Q_useful;

  // Utloppstemperatur
  T_fluid_out = T_fluid_in + Q_useful / (m_flow * cp_fluid);

  // ============ TERMISK DYNAMIK ============
  // Energibalans för solfångarens termiska massa
  m_collector * cp_collector * der(T_collector) = Q_solar - Q_loss - P_thermal;

  // ============ ACKUMULERADE ENERGIER ============
  der(E_solar_total) = Q_solar;
  der(E_useful_total) = Q_useful;

  // ============ ANNOTATIONS ============
  annotation(
    Icon(coordinateSystem(preserveAspectRatio=false), graphics={
      Rectangle(
        extent={{-80,60},{80,-60}},
        lineColor={0,0,0},
        fillColor={50,50,50},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{-70,50},{70,-50}},
        lineColor={255,200,0},
        fillColor={30,30,120},
        fillPattern=FillPattern.Solid),
      Line(
        points={{-60,40},{-40,20},{-20,40},{0,20},{20,40},{40,20},{60,40}},
        color={255,255,255},
        thickness=0.5),
      Polygon(
        points={{-20,80},{-10,60},{-30,60},{-20,80}},
        lineColor={255,200,0},
        fillColor={255,200,0},
        fillPattern=FillPattern.Solid),
      Line(points={{-20,60},{-20,50}}, color={255,200,0}, thickness=0.5),
      Line(points={{-35,70},{-25,60}}, color={255,200,0}, thickness=0.5),
      Line(points={{-5,70},{-15,60}}, color={255,200,0}, thickness=0.5),
      Line(points={{-50,60},{-30,50}}, color={255,200,0}, thickness=0.5),
      Line(points={{10,60},{-10,50}}, color={255,200,0}, thickness=0.5),
      Text(
        extent={{-100,90},{100,70}},
        lineColor={0,0,255},
        textString="Solfångare"),
      Text(
        extent={{-100,-70},{100,-90}},
        lineColor={0,0,0},
        textString="A=%A_collector m²")}),
    Documentation(info="<html>
<h4>Solar Collector för ORC värmekälla</h4>
<p>
Plana solfångare eller vakuumrör som samlar solenergi.
Värmer upp värmebärare (vatten/glykol) som driver ORC-systemet.
</p>

<h5>Modell enligt EN 12975:</h5>
<p>
Verkningsgrad: η = η₀ - a₁·(T*-T_amb)/G - a₂·(T*-T_amb)²/G
</p>

<h5>Mätvariabler:</h5>
<ul>
<li><b>Q_useful</b>: Nyttig värmeeffekt [W]</li>
<li><b>eta_collector</b>: Aktuell verkningsgrad</li>
<li><b>T_fluid_out</b>: Utloppstemperatur värmebärare [K]</li>
<li><b>E_useful_total</b>: Total levererad energi [J]</li>
</ul>

<h5>Forskningsfrågor:</h5>
<ul>
<li>Hur påverkar variabel instrålning ORC-driften?</li>
<li>Optimal solfångararea för given ORC-storlek</li>
<li>Betydelse av termisk lagring</li>
</ul>
</html>"));

end SolarCollector;
