within ORCSystem.Components;

model Condenser
  "Kondensor för ORC-system - kondenserar R245fa till vätska"

  /*
   * BESKRIVNING:
   * ===========
   * Kondensor där R245fa kondenseras från gasfas till vätskefas.
   * Kondenseringsvärmen överförs till kyltorn eller omgivande luft/vatten.
   *
   * Modellen inkluderar:
   * - Kondensering från ånga till vätska
   * - Värmeöverföring till kylmedium
   * - Underkylning
   * - Tryckfall
   *
   * FORSKNINGSFRÅGOR:
   * ================
   * 1. Hur påverkar kondenseringstemp ORC-verkningsgraden?
   * 2. Optimal underkylningsgrad?
   * 3. Dimensionering av kylsystem
   */

  import Modelica.SIunits.*;

  // ============ PARAMETRAR ============
  parameter Area A_heat = 1.5 "Värmeväxlaryta [m²]";
  parameter CoefficientOfHeatTransfer U = 600
    "Övergående värmeöverföringskoefficient [W/(m²·K)]";
  parameter Temperature T_cond_nominal = 273.15 + 40
    "Nominell kondenseringstemperatur [K]";
  parameter Pressure p_cond_nominal = 2e5
    "Nominellt kondenseringstryck [Pa]";
  parameter Temperature subcooling = 5
    "Underkylning [K]";
  parameter MassFlowRate m_flow_wf_nominal = 0.5
    "Nominellt massflöde arbetsmede [kg/s]";
  parameter MassFlowRate m_flow_cool_nominal = 2.0
    "Nominellt massflöde kylmedium [kg/s]";
  parameter Temperature T_cool_in_nominal = 273.15 + 25
    "Nominell inloppstemperatur kylmedium [K]";

  // ============ VARIABLER ============
  // Arbetsmedium (R245fa) sida
  Temperature T_wf_in "Inloppstemperatur arbetsmede (ånga)";
  Temperature T_wf_out "Utloppstemperatur arbetsmede (underkyld vätska)";
  Pressure p_wf_in "Inloppstryck arbetsmede";
  Pressure p_wf_out "Utloppstryck arbetsmede";
  SpecificEnthalpy h_wf_in "Inloppsentalpi arbetsmede";
  SpecificEnthalpy h_wf_out "Utloppsentalpi arbetsmede";
  MassFlowRate m_flow_wf "Massflöde arbetsmede";

  // Kylmedium sida (vatten eller luft)
  Temperature T_cool_in "Inloppstemperatur kylmedium";
  Temperature T_cool_out "Utloppstemperatur kylmedium";
  MassFlowRate m_flow_cool "Massflöde kylmedium";
  SpecificHeatCapacity cp_cool = 4180 "Specifik värmekapacitet kylmedium (vatten)";

  // Värmeöverföring
  HeatFlowRate Q_flow "Överförd värmeeffekt till kylmedium";
  HeatFlowRate Q_cond "Kondenseringsvärme";
  HeatFlowRate Q_subcool "Underkylningsvärme";
  TemperatureDifference LMTD "Logaritmisk medeltemperaturdifferens";

  // Prestanda
  Real effectiveness_actual "Faktisk effektivitet";
  Energy E_rejected(start=0) "Ackumulerad bortförd energi";

  // ============ BERÄKNADE STORHETER ============
  parameter SpecificEnthalpy h_fg = 180e3
    "Kondenseringsentalpi för R245fa [J/kg]";

equation
  // ============ TRYCKFALL ============
  p_wf_out = p_wf_in - 0.2e5;  // 0.2 bar tryckfall

  // ============ VÄRMEÖVERFÖRING TILL KYLMEDIUM ============
  Q_flow = m_flow_cool * cp_cool * (T_cool_out - T_cool_in);

  // ============ LOGARITMISK MEDELTEMPERATURDIFFERENS ============
  // Aritmetisk approximation
  LMTD = ((T_wf_in - T_cool_out) + (T_wf_out - T_cool_in)) / 2;

  // ============ VÄRMEVÄXLAREKVATION ============
  Q_flow = U * A_heat * LMTD;

  // ============ ENERGIBALANS FÖR ARBETSMEDE ============
  // Uppdelning i kondensering och underkylning
  Q_cond = m_flow_wf * h_fg;
  Q_subcool = m_flow_wf * cp_cool * subcooling;  // Approximation
  Q_flow = m_flow_wf * (h_wf_in - h_wf_out);

  // Utloppstemperatur arbetsmede (underkyld vätska)
  T_wf_out = T_cond_nominal - subcooling;

  // Entalpiminskning
  h_wf_out = h_wf_in - Q_flow / m_flow_wf;

  // ============ EFFEKTIVITET ============
  // Faktisk effektivitet
  effectiveness_actual = Q_flow / (m_flow_wf * (h_wf_in - h_wf_out));

  // ============ ACKUMULERAD BORTFÖRD ENERGI ============
  der(E_rejected) = Q_flow;

  // ============ ANNOTATIONS ============
  annotation(
    Icon(coordinateSystem(preserveAspectRatio=false), graphics={
      Rectangle(
        extent={{-80,60},{80,-60}},
        lineColor={0,0,0},
        fillColor={100,150,255},
        fillPattern=FillPattern.HorizontalCylinder),
      Line(
        points={{-80,40},{-40,40},{-40,-40},{0,-40},{0,40},{40,40},{40,-40},{80,-40}},
        color={0,0,255},
        thickness=1),
      Ellipse(
        extent={{-10,10},{10,-10}},
        lineColor={0,0,255},
        fillColor={200,230,255},
        fillPattern=FillPattern.Solid),
      Ellipse(
        extent={{20,5},{30,-5}},
        lineColor={0,0,255},
        fillColor={200,230,255},
        fillPattern=FillPattern.Solid),
      Ellipse(
        extent={{-30,5},{-20,-5}},
        lineColor={0,0,255},
        fillColor={200,230,255},
        fillPattern=FillPattern.Solid),
      Polygon(
        points={{-60,0},{-50,10},{-50,-10},{-60,0}},
        lineColor={255,0,0},
        fillColor={255,0,0},
        fillPattern=FillPattern.Solid),
      Polygon(
        points={{60,0},{50,10},{50,-10},{60,0}},
        lineColor={0,0,255},
        fillColor={0,0,255},
        fillPattern=FillPattern.Solid),
      Text(
        extent={{-100,80},{100,65}},
        lineColor={0,0,255},
        textString="Kondensor"),
      Text(
        extent={{-100,-65},{100,-80}},
        lineColor={0,0,0},
        textString="T=%T_cond_nominal K")}),
    Documentation(info="<html>
<h4>Condenser för ORC-system</h4>
<p>
Kondensor där R245fa kondenseras från ånga till underkyld vätska.
Kondenseringsvärmen överförs till kylmedium (vatten eller luft).
</p>

<h5>Mätvariabler:</h5>
<ul>
<li><b>Q_flow</b>: Bortförd värmeeffekt [W]</li>
<li><b>T_wf_out</b>: Utloppstemperatur arbetsmede [K]</li>
<li><b>effectiveness_actual</b>: Kondensoreffektivitet</li>
<li><b>E_rejected</b>: Total bortförd energi [J]</li>
</ul>

<h5>Forskningsfrågor:</h5>
<ul>
<li>Hur påverkar kondenseringstemp systemverkningsgraden?</li>
<li>Optimal underkylningsgrad</li>
<li>Dimensionering av kylsystem för olika miljöer</li>
</ul>
</html>"));

end Condenser;
