within ORCSystem.Examples;

model CompleteORCSystem
  "Komplett ORC-system med Tesla-turbin, solfångare och ackumulatortank"

  /*
   * =============================================================================
   * KOMPLETT ORC-SYSTEMMODELL
   * =============================================================================
   *
   * Detta är den huvudsakliga modellen som kopplar ihop alla komponenter
   * till ett fungerande ORC-system.
   *
   * SYSTEMETS ENERGIFLÖDE:
   * ======================
   *
   * SOL → Solfångare → Ackumulatortank → Förångare → Tesla-turbin → Generator
   *                                           ↑             ↓
   *                                        Pump  ←   Kondensor
   *
   * SIMULERINGSSCENARIO:
   * ====================
   * - 24 timmars simulering
   * - Variabel solinstrålning (dag/natt-cykel)
   * - Ackumulatortank jämnar ut variationer
   * - Kontinuerlig ORC-drift när tillräckligt med lagrad energi
   *
   * MÄTPUNKTER FÖR FORSKNINGSFRÅGOR:
   * =================================
   * 1. Systemverkningsgrad: eta_system = W_net / Q_solar
   * 2. Tesla-turbin verkningsgrad: eta_turbine
   * 3. Energibalans: E_in - E_out - E_stored = 0
   * 4. Ekonomi: kWh producerat per m² solfångare
   */

  import Modelica.SIunits.*;
  import Modelica.Constants.pi;

  // ============================================================================
  // KOMPONENTER
  // ============================================================================

  // ORC-krets
  Components.TeslaTurbineExpander turbine(
    diskDiameter=0.30,
    numberOfDisks=20,
    eta_is_nominal=0.75,
    p_in_nominal=12e5,
    p_out_nominal=2e5,
    m_flow_nominal=0.5)
    annotation(Placement(transformation(extent={{20,40},{40,60}})));

  Components.Evaporator evaporator(
    A_heat=2.0,
    T_evap_nominal=273.15 + 85,
    p_evap_nominal=12e5,
    superheat=10,
    m_flow_wf_nominal=0.5,
    m_flow_hs_nominal=1.0)
    annotation(Placement(transformation(extent={{-40,40},{-20,60}})));

  Components.Condenser condenser(
    A_heat=1.5,
    T_cond_nominal=273.15 + 40,
    p_cond_nominal=2e5,
    subcooling=5,
    m_flow_wf_nominal=0.5,
    m_flow_cool_nominal=2.0)
    annotation(Placement(transformation(extent={{20,-20},{40,0}})));

  Components.WorkingFluidPump pump(
    dp_nominal=10e5,
    m_flow_nominal=0.5,
    eta_pump=0.70,
    eta_motor=0.90)
    annotation(Placement(transformation(extent={{-40,-20},{-20,0}})));

  // Värmesystem
  HeatSource.SolarCollector solarCollector(
    A_collector=10.0,
    eta_0=0.75,
    a1=4.0,
    a2=0.015)
    annotation(Placement(transformation(extent={{-80,60},{-60,80}})));

  HeatSource.StratifiedTank storageTank(
    V_tank=1.0,
    nLayers=5,
    h_tank=2.0,
    T_initial=273.15 + 50)
    annotation(Placement(transformation(extent={{-80,20},{-60,40}})));

  // ============================================================================
  // GLOBALA VARIABLER OCH MÄTPUNKTER
  // ============================================================================

  // Tidsberoende indata
  Time t "Simuleringstid";
  Irradiance G_solar "Solinstrålning [W/m²]";
  Temperature T_ambient "Omgivningstemperatur [K]";

  // Systemprestandamått
  Power W_turbine "Turbineffekt [W]";
  Power W_pump "Pumpeffekt [W]";
  Power W_net "Netto elektrisk effekt [W]";
  Power Q_solar_input "Inkommande solenergi [W]";
  Power Q_to_ORC "Värme till ORC [W]";
  Power Q_rejected "Bortkyld värme [W]";

  // Verkningsgrader
  Real eta_carnot "Carnot-verkningsgrad";
  Real eta_ORC "ORC-verkningsgrad (W_net/Q_to_ORC)";
  Real eta_system "Total systemverkningsgrad (W_net/Q_solar)";
  Real eta_turbine "Turbin isentropisk verkningsgrad";

  // Energibalanser (ackumulerade)
  Energy E_solar_collected(start=0) "Total insamlad solenergi [J]";
  Energy E_electrical_produced(start=0) "Total producerad el [J]";
  Energy E_stored_tank "Energi i tank [J]";

  // Temperaturer (övervakningspunkter)
  Temperature T_evap_out "Temperatur efter förångare [K]";
  Temperature T_turbine_out "Temperatur efter turbin [K]";
  Temperature T_cond_out "Temperatur efter kondensor [K]";
  Temperature T_tank_top "Temperatur topp av tank [K]";

  // Tryck (övervakningspunkter)
  Pressure p_high "Högtryck (före turbin) [Pa]";
  Pressure p_low "Lågtryck (efter turbin) [Pa]";

  // Ekonomiska mått
  Real specificEnergy "Energi per m² solfångare [kWh/m²]";
  Real capacityFactor "Kapacitetsfaktor [-]";

initial equation
  t = 0;

equation
  // ============================================================================
  // TIDSBEROENDE INDATA: SOLINSTRÅLNING OCH TEMPERATUR
  // ============================================================================

  t = time;

  // Solinstrålning: Dag/natt-cykel med max 800 W/m² vid solar noon
  // Enkel sinuskurva för demonstration
  G_solar = if sin(2*pi*t/86400 - pi/2) > 0 then
              800 * sin(2*pi*t/86400 - pi/2)
            else
              0;

  // Omgivningstemperatur: Varierar mellan 15-25°C
  T_ambient = 273.15 + 20 + 5*sin(2*pi*t/86400 - pi/2);

  // ============================================================================
  // KOMPONENTKOPPLINGAR: SOLVÄRME
  // ============================================================================

  // Solfångare tar emot solinstrålning
  solarCollector.G = G_solar;
  solarCollector.T_ambient = T_ambient;
  solarCollector.v_wind = 3.0;  // Antag 3 m/s vindhastighet
  solarCollector.m_flow = 0.5;  // Cirkulationsflöde
  solarCollector.T_fluid_in = storageTank.T_bottom;  // Från tank-botten

  // Solfångare laddar tank
  storageTank.T_charge_in = solarCollector.T_fluid_out;
  storageTank.m_flow_charge = solarCollector.m_flow;

  // ============================================================================
  // KOMPONENTKOPPLINGAR: ORC-KRETS
  // ============================================================================

  // Tank till förångare (värmesidan)
  evaporator.T_hs_in = storageTank.T_top;  // Tar varmt vatten från toppen
  evaporator.m_flow_hs = 1.0;  // Flöde värmesida
  storageTank.m_flow_discharge = evaporator.m_flow_hs;

  // Förångare till turbin (arbetsmede R245fa)
  evaporator.m_flow_wf = 0.5;
  turbine.m_flow = evaporator.m_flow_wf;
  turbine.p_in = evaporator.p_wf_out;
  turbine.T_in = evaporator.T_wf_out;
  turbine.h_in = evaporator.h_wf_out;

  // Turbin till kondensor
  condenser.m_flow_wf = turbine.m_flow;
  condenser.p_wf_in = turbine.p_out;
  condenser.T_wf_in = turbine.T_out;
  condenser.h_wf_in = turbine.h_out;

  // Kondensor till pump
  pump.m_flow = condenser.m_flow_wf;
  pump.p_in = condenser.p_wf_out;
  pump.T_in = condenser.T_wf_out;
  pump.h_in = condenser.h_wf_out;

  // Pump till förångare (sluter kretsen)
  evaporator.p_wf_in = pump.p_out;
  evaporator.T_wf_in = pump.T_out;
  evaporator.h_wf_in = pump.h_out;

  // Kylvatten till kondensor
  condenser.T_cool_in = T_ambient + 5;  // Kylvatten något varmare än luft
  condenser.m_flow_cool = 2.0;

  // ============================================================================
  // MÄTPUNKTER OCH PRESTANDA
  // ============================================================================

  // Effekter
  W_turbine = turbine.W_actual;
  W_pump = pump.W_electric;
  W_net = W_turbine - W_pump;
  Q_solar_input = solarCollector.Q_useful;
  Q_to_ORC = evaporator.Q_flow;
  Q_rejected = condenser.Q_flow;

  // Temperaturer
  T_evap_out = evaporator.T_wf_out;
  T_turbine_out = turbine.T_out;
  T_cond_out = condenser.T_wf_out;
  T_tank_top = storageTank.T_top;

  // Tryck
  p_high = turbine.p_in;
  p_low = turbine.p_out;

  // Verkningsgrader
  eta_carnot = 1 - condenser.T_cond_nominal / evaporator.T_evap_nominal;
  eta_ORC = if Q_to_ORC > 100 then W_net / Q_to_ORC else 0;
  eta_system = if Q_solar_input > 100 then W_net / Q_solar_input else 0;
  eta_turbine = turbine.eta_is;

  // Energibalanser
  der(E_solar_collected) = Q_solar_input;
  der(E_electrical_produced) = W_net;
  E_stored_tank = storageTank.E_stored;

  // Ekonomiska mått
  specificEnergy = E_electrical_produced / (solarCollector.A_collector * 3600000);  // kWh/m²
  capacityFactor = if W_turbine > 0 then W_net / turbine.W_actual else 0;

  // ============================================================================
  // ANNOTATIONS
  // ============================================================================

  annotation(
    experiment(
      StartTime=0,
      StopTime=86400,
      Tolerance=1e-06,
      Interval=60),
    Documentation(info="<html>
<h1>Komplett ORC-System - Simuleringsmodell</h1>

<h2>Beskrivning</h2>
<p>
Detta är en komplett simuleringsmodell av ett ORC-system med:
</p>
<ul>
<li>10 m² solfångare</li>
<li>1 m³ stratifierad ackumulatortank</li>
<li>R245fa ORC-krets med Tesla-turbin</li>
</ul>

<h2>Simulering</h2>
<p>
Simulerar 24 timmar (86400 sekunder) med:
</p>
<ul>
<li>Variabel solinstrålning (0-800 W/m²)</li>
<li>Dag/natt-cykel</li>
<li>Dynamisk energilagring i tank</li>
</ul>

<h2>Resultat att analysera</h2>

<h3>Plots att skapa:</h3>
<ol>
<li><b>Effekter över tid</b>
   <ul>
   <li>Q_solar_input (solenergi in)</li>
   <li>W_net (netto eleffekt)</li>
   <li>W_turbine, W_pump</li>
   </ul>
</li>

<li><b>Temperaturer</b>
   <ul>
   <li>T_tank_top (tanktemperatur)</li>
   <li>T_evap_out (efter förångare)</li>
   <li>T_turbine_out (efter turbin)</li>
   </ul>
</li>

<li><b>Verkningsgrader</b>
   <ul>
   <li>eta_system (total)</li>
   <li>eta_ORC</li>
   <li>eta_turbine</li>
   <li>eta_carnot (teoretisk max)</li>
   </ul>
</li>

<li><b>Energibalanser</b>
   <ul>
   <li>E_solar_collected</li>
   <li>E_electrical_produced</li>
   <li>E_stored_tank</li>
   </ul>
</li>

<li><b>T-s diagram (Temperatur-Entropi)</b>
   <ul>
   <li>Visa ORC-processen</li>
   <li>Jämför med idealcykel</li>
   </ul>
</li>
</ol>

<h2>Forskningsfrågor som besvaras</h2>

<h3>1. Systemverkningsgrad</h3>
<p>
<b>Mätvärde:</b> eta_system<br>
<b>Fråga:</b> Hur effektivt omvandlas solenergi till el?<br>
<b>Förväntat:</b> 3-8% (solpanel: ~15-20%, men ORC kan använda spillvärme)
</p>

<h3>2. Tesla-turbinens prestanda</h3>
<p>
<b>Mätvärden:</b> eta_turbine, W_turbine, turbine.powerDensity<br>
<b>Fråga:</b> Hur presterar Tesla-turbinen vs konventionell expander?<br>
<b>Förväntat:</b> eta_is = 70-80% (konventionell: 80-85%)
</p>

<h3>3. Termisk lagring</h3>
<p>
<b>Mätvärden:</b> E_stored_tank, storageTank.SOC<br>
<b>Fråga:</b> Hur mycket förbättrar tanken systemets prestanda?<br>
<b>Förväntat:</b> Möjliggör drift även när sol ej finns
</p>

<h3>4. Ekonomi</h3>
<p>
<b>Mätvärde:</b> specificEnergy [kWh/m²/dag]<br>
<b>Fråga:</b> Hur mycket energi per solfångararea?<br>
<b>Förväntat:</b> 0.5-1.5 kWh/m²/dag
</p>

<h2>Användning</h2>

<h3>I OMEdit (grafiskt):</h3>
<pre>
1. File → Open → CompleteORCSystem.mo
2. Klicka på \"Check Model\" (kontrollera syntaxfel)
3. Simulation → Simulate
4. Plotting → Välj variabler att plotta
</pre>

<h3>Med script (.mos):</h3>
<pre>
loadModel(Modelica);
loadFile(\"ORCSystem.mo\");
simulate(ORCSystem.Examples.CompleteORCSystem, stopTime=86400);
plot({W_net, Q_solar_input});
</pre>

</html>"),
    Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
         graphics={
           Rectangle(extent={{-100,100},{100,-100}}, lineColor={0,0,0}),
           Text(extent={{-80,20},{80,-20}}, textString="ORC System")}),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-40},{100,100}})));

end CompleteORCSystem;
