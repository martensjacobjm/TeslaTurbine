within ORCSystem.Components;

model Evaporator
  "Förångare för ORC-system - värmeväxlare som förångar R245fa"

  /*
   * BESKRIVNING:
   * ===========
   * Förångare där R245fa förångas från vätskefas till gasfas genom
   * värmeöverföring från värmekälla (solfångare, biobränsle, värmepump).
   *
   * Modellen inkluderar:
   * - Värmeöverföring mellan värmekälla och arbetsmede
   * - Förångningsprocess (vätska → ånga)
   * - Tryckfall
   * - Överhettning
   *
   * FORSKNINGSFRÅGOR:
   * ================
   * 1. Hur påverkar inloppstemperaturen från värmekällan verkningsgraden?
   * 2. Vilken överhettningsgrad ger bäst systemprestanda?
   * 3. Hur stor värmeväxlaryta behövs?
   */

  import Modelica.SIunits.*;

  // ============ PARAMETRAR ============
  parameter Area A_heat = 2.0 "Värmeväxlaryta [m²]";
  parameter CoefficientOfHeatTransfer U = 500
    "Övergående värmeöverföringskoefficient [W/(m²·K)]";
  parameter Temperature T_evap_nominal = 273.15 + 85
    "Nominell förångningstemperatur [K]";
  parameter Pressure p_evap_nominal = 12e5
    "Nominellt förångningstryck [Pa]";
  parameter Temperature superheat = 10
    "Överhettning [K]";
  parameter MassFlowRate m_flow_wf_nominal = 0.5
    "Nominellt massflöde arbetsmede [kg/s]";
  parameter MassFlowRate m_flow_hs_nominal = 1.0
    "Nominellt massflöde värmekälla [kg/s]";
  parameter Real effectiveness = 0.85
    "Värmeväxlarens effektivitet";

  // ============ VARIABLER ============
  // Arbetsmedium (R245fa) sida
  Temperature T_wf_in "Inloppstemperatur arbetsmede";
  Temperature T_wf_out "Utloppstemperatur arbetsmede (överhettad ånga)";
  Pressure p_wf_in "Inloppstryck arbetsmede";
  Pressure p_wf_out "Utloppstryck arbetsmede";
  SpecificEnthalpy h_wf_in "Inloppsentalpi arbetsmede";
  SpecificEnthalpy h_wf_out "Utloppsentalpi arbetsmede";
  MassFlowRate m_flow_wf "Massflöde arbetsmede";

  // Värmekälla sida
  Temperature T_hs_in "Inloppstemperatur värmekälla";
  Temperature T_hs_out "Utloppstemperatur värmekälla";
  MassFlowRate m_flow_hs "Massflöde värmekälla";
  SpecificHeatCapacity cp_hs = 4180 "Specifik värmekapacitet värmekälla (vatten)";

  // Värmeöverföring
  HeatFlowRate Q_flow "Överförd värmeeffekt";
  HeatFlowRate Q_evap "Förångningsvärme";
  HeatFlowRate Q_superheat "Överhettningsvärme";
  TemperatureDifference LMTD "Logaritmisk medeltemperaturdifferens";
  TemperatureDifference dT_pinch "Pinch-punkttemperaturdifferens";

  // Prestanda
  Real effectiveness_actual "Faktisk effektivitet";
  Energy E_accumulated(start=0) "Ackumulerad energi";

  // ============ BERÄKNADE STORHETER ============
  parameter SpecificEnthalpy h_fg = 180e3
    "Förångningsentalpi för R245fa vid nominellt tryck [J/kg]";

equation
  // ============ TRYCKFALL ============
  p_wf_out = p_wf_in - 0.5e5;  // 0.5 bar tryckfall

  // ============ VÄRMEÖVERFÖRING FRÅN VÄRMEKÄLLA ============
  // Värmekällan (vatten/termisk olja) kyls ner
  Q_flow = m_flow_hs * cp_hs * (T_hs_in - T_hs_out);

  // ============ LOGARITMISK MEDELTEMPERATURDIFFERENS ============
  // Förenkla med aritmetiskt medelvärde för att undvika log singulariteter
  LMTD = ((T_hs_in - T_wf_out) + (T_hs_out - T_wf_in)) / 2;

  // ============ VÄRMEVÄXLAREKVATION ============
  Q_flow = U * A_heat * LMTD;

  // ============ PINCH-PUNKT ============
  // Minsta temperaturdifferens i värmeväxlaren (vid förångning)
  dT_pinch = T_hs_out - T_evap_nominal;

  // ============ ENERGIBALANS FÖR ARBETSMEDE ============
  // Uppdelning i förångning och överhettning
  Q_evap = m_flow_wf * h_fg;
  Q_superheat = m_flow_wf * cp_hs * superheat;  // Approximation
  Q_flow = m_flow_wf * (h_wf_out - h_wf_in);

  // Utloppstemperatur arbetsmede (överhettad ånga)
  T_wf_out = T_evap_nominal + superheat;

  // Entalpiökning
  h_wf_out = h_wf_in + Q_flow / m_flow_wf;

  // ============ EFFEKTIVITET ============
  // Faktisk effektivitet jämfört med max möjlig värmeöverföring
  effectiveness_actual = Q_flow / (m_flow_hs * cp_hs * (T_hs_in - T_wf_in));

  // ============ ACKUMULERAD ENERGI ============
  der(E_accumulated) = Q_flow;

  // ============ ANNOTATIONS ============
  annotation(
    Icon(coordinateSystem(preserveAspectRatio=false), graphics={
      Rectangle(
        extent={{-80,60},{80,-60}},
        lineColor={0,0,0},
        fillColor={255,200,100},
        fillPattern=FillPattern.HorizontalCylinder),
      Line(
        points={{-80,40},{-40,40},{-40,-40},{0,-40},{0,40},{40,40},{40,-40},{80,-40}},
        color={255,0,0},
        thickness=1),
      Polygon(
        points={{-60,0},{-50,10},{-50,-10},{-60,0}},
        lineColor={0,0,255},
        fillColor={0,0,255},
        fillPattern=FillPattern.Solid),
      Polygon(
        points={{60,0},{50,10},{50,-10},{60,0}},
        lineColor={255,0,0},
        fillColor={255,0,0},
        fillPattern=FillPattern.Solid),
      Text(
        extent={{-100,80},{100,65}},
        lineColor={0,0,255},
        textString="Förångare"),
      Text(
        extent={{-100,-65},{100,-80}},
        lineColor={0,0,0},
        textString="A=%A_heat m²")}),
    Documentation(info="<html>
<h4>Evaporator för ORC-system</h4>
<p>
Förångare där R245fa förångas från vätskefas till överhettad ånga.
Värmeöverföring sker från en extern värmekälla (solfångare, biobränsle, värmepump).
</p>

<h5>Mätvariabler:</h5>
<ul>
<li><b>Q_flow</b>: Överförd värmeeffekt [W]</li>
<li><b>effectiveness_actual</b>: Faktisk värmeväxlareffektivitet</li>
<li><b>dT_pinch</b>: Pinch-punkttemperatur [K]</li>
<li><b>T_wf_out</b>: Utloppstemperatur arbetsmede [K]</li>
</ul>

<h5>Forskningsfrågor:</h5>
<ul>
<li>Optimal överhettningsgrad för maximal systemverkningsgrad</li>
<li>Inverkan av värmekällans temperatur på ORC-prestanda</li>
<li>Värmeväxlardimensionering</li>
</ul>
</html>"));

end Evaporator;
