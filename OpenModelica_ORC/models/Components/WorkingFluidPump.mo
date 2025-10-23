within ORCSystem.Components;

model WorkingFluidPump
  "Pump för R245fa i ORC-system"

  /*
   * BESKRIVNING:
   * ===========
   * Centrifugalpump som pumpar flytande R245fa från kondensortryck
   * till förångartryck.
   *
   * Modellen inkluderar:
   * - Tryckuppbyggnad
   * - Isentropisk verkningsgrad
   * - Elektrisk effektförbrukning
   * - Kavitationsskydd (NPSH)
   *
   * FORSKNINGSFRÅGOR:
   * ================
   * 1. Hur stor andel av genererad effekt går åt till pumpning?
   * 2. Optimal pumpstorlek för olika systemkonfigurationer
   */

  import Modelica.SIunits.*;

  // ============ PARAMETRAR ============
  parameter Pressure dp_nominal = 10e5
    "Nominellt trycklyft [Pa]";
  parameter MassFlowRate m_flow_nominal = 0.5
    "Nominellt massflöde [kg/s]";
  parameter Real eta_pump = 0.70
    "Pumpverkningsgrad";
  parameter Real eta_motor = 0.90
    "Motorverkningsgrad";
  parameter AngularVelocity omega_nominal = 3000*2*Modelica.Constants.pi/60
    "Nominell varvtal [rad/s] (~3000 RPM)";
  parameter Height NPSH_required = 2.0
    "Erforderlig Net Positive Suction Head [m]";

  // ============ VARIABLER ============
  // Fluid-egenskaper
  Pressure p_in "Inloppstryck";
  Pressure p_out "Utloppstryck";
  Temperature T_in "Inloppstemperatur";
  Temperature T_out "Utloppstemperatur";
  SpecificEnthalpy h_in "Inloppsentalpi";
  SpecificEnthalpy h_out "Utloppsentalpi";
  SpecificEnthalpy h_out_s "Isentropisk utloppsentalpi";
  MassFlowRate m_flow "Massflöde";
  Density rho = 1300 "Densitet flytande R245fa [kg/m³]";

  // Prestanda
  Pressure dp "Faktiskt trycklyft";
  Power W_hydraulic "Hydraulisk effekt";
  Power W_shaft "Axeleffekt";
  Power W_electric "Elektrisk effekt";
  VolumeFlowRate V_flow "Volymflöde";
  Height NPSH_available "Tillgänglig NPSH";

  // Rotation
  AngularVelocity omega(start=omega_nominal) "Varvtal";

  // Mätvariabler
  Real specificPumpWork "Specifikt pumparbete [J/kg]";
  Real pumpEfficiency "Total pumpverkningsgrad";

equation
  // ============ TRYCKUPPBYGGNAD ============
  dp = p_out - p_in;

  // ============ VOLYMFLÖDE ============
  V_flow = m_flow / rho;

  // ============ HYDRAULISK EFFEKT ============
  // Ideal effekt för att lyfta vätskan
  W_hydraulic = V_flow * dp;

  // ============ AXELEFFEKT ============
  // Inkluderar pumpförluster
  W_shaft = W_hydraulic / eta_pump;

  // ============ ELEKTRISK EFFEKT ============
  // Inkluderar motorförluster
  W_electric = W_shaft / eta_motor;

  // ============ SPECIFIKT ARBETE ============
  specificPumpWork = W_shaft / m_flow;

  // ============ TOTAL VERKNINGSGRAD ============
  pumpEfficiency = eta_pump * eta_motor;

  // ============ ENERGIBALANS ============
  // Temperaturökning p.g.a. kompression och förluster
  h_out = h_in + specificPumpWork;
  T_out = T_in + specificPumpWork / 1400;  // Approximativt cp för R245fa vätska

  // ============ NPSH (KAVITATIONSSKYDD) ============
  // Tillgänglig NPSH
  NPSH_available = (p_in - 1e5) / (rho * 9.81);  // p_vapor ≈ 1 bar för R245fa vid 25°C

  // Kavitationsvarning (skulle kunna vara en assert i praktiken)
  assert(NPSH_available > NPSH_required,
    "VARNING: Otillräcklig NPSH - risk för kavitation!");

  // ============ VARVTALSBEROENDE ============
  // Förenklad affinitetslagmodell
  dp = dp_nominal * (omega / omega_nominal)^2;
  m_flow = m_flow_nominal * (omega / omega_nominal);

  // ============ ANNOTATIONS ============
  annotation(
    Icon(coordinateSystem(preserveAspectRatio=false), graphics={
      Ellipse(
        extent={{-80,80},{80,-80}},
        lineColor={0,0,0},
        fillColor={100,100,255},
        fillPattern=FillPattern.Solid),
      Polygon(
        points={{-30,40},{-30,-40},{40,0},{-30,40}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Line(
        points={{-100,0},{-80,0}},
        color={0,0,255},
        thickness=1),
      Line(
        points={{80,0},{100,0}},
        color={255,0,0},
        thickness=1),
      Text(
        extent={{-100,100},{100,80}},
        lineColor={0,0,255},
        textString="Pump"),
      Text(
        extent={{-100,-80},{100,-100}},
        lineColor={0,0,0},
        textString="η=%eta_pump")}),
    Documentation(info="<html>
<h4>Working Fluid Pump för ORC</h4>
<p>
Centrifugalpump som cirkulerar R245fa i ORC-systemet.
Pumpar vätska från kondensortryck till förångartryck.
</p>

<h5>Mätvariabler:</h5>
<ul>
<li><b>W_electric</b>: Elektrisk effektförbrukning [W]</li>
<li><b>dp</b>: Trycklyft [Pa]</li>
<li><b>pumpEfficiency</b>: Total verkningsgrad</li>
<li><b>NPSH_available</b>: Tillgänglig NPSH [m]</li>
</ul>

<h5>Forskningsfrågor:</h5>
<ul>
<li>Hur stor andel av genererad effekt förbrukas av pumpen?</li>
<li>Optimal dimensionering för minimal parasitisk förlust</li>
<li>NPSH-marginaler för olika driftspunkter</li>
</ul>
</html>"));

end WorkingFluidPump;
