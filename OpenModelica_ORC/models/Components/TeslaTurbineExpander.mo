within ORCSystem.Components;

model TeslaTurbineExpander
  "Tesla Turbine Expander för ORC-system med R245fa"

  /*
   * BESKRIVNING:
   * ===========
   * Tesla-turbin som expander i ORC-systemet. Modellerar en bladlös turbin
   * där arbetsmediet (R245fa) expanderar mellan roterande skivor.
   *
   * Modellen inkluderar:
   * - Isentropisk verkningsgrad
   * - Mekaniska förluster
   * - Massflöde och tryckfall
   * - Effektuttag
   *
   * FORSKNINGSFRÅGOR SOM MÄTS:
   * =========================
   * 1. Isentropisk verkningsgrad vid olika tryckförhållanden
   * 2. Effektuttag som funktion av massflöde
   * 3. Optimal rotationshastighet för olika inloppsvillkor
   * 4. Jämförelse med konventionella expandrar
   */

  import Modelica.SIunits.*;

  // ============ PARAMETRAR ============
  parameter Length diskDiameter = 0.30 "Diskdiameter [m]";
  parameter Length diskSpacing = 0.0005 "Avstånd mellan diskar [m]";
  parameter Integer numberOfDisks = 20 "Antal roterande diskar";
  parameter Real eta_is_nominal = 0.75 "Nominell isentropisk verkningsgrad";
  parameter Real mechanicalEfficiency = 0.95 "Mekanisk verkningsgrad";
  parameter Pressure p_in_nominal = 15e5 "Nominellt inloppstryck [Pa]";
  parameter Pressure p_out_nominal = 2e5 "Nominellt utloppstryck [Pa]";
  parameter MassFlowRate m_flow_nominal = 0.5 "Nominellt massflöde [kg/s]";
  parameter AngularVelocity omega_nominal = 5000*2*Modelica.Constants.pi/60
    "Nominell vinkelhastighet [rad/s] (~5000 RPM)";

  // ============ VARIABLER ============
  // Termodynamiska tillstånd
  Pressure p_in(start=p_in_nominal) "Inloppstryck";
  Pressure p_out(start=p_out_nominal) "Utloppstryck";
  Temperature T_in "Inloppstemperatur";
  Temperature T_out "Utloppstemperatur";
  SpecificEnthalpy h_in "Inloppsentalpi";
  SpecificEnthalpy h_out "Utloppsentalpi";
  SpecificEnthalpy h_out_s "Isentropisk utloppsentalpi";
  SpecificEntropy s_in "Inloppsentropi";

  // Flödesvariabler
  MassFlowRate m_flow(start=m_flow_nominal) "Massflöde genom expander";

  // Prestanda
  Power W_is "Isentropisk effekt";
  Power W_actual "Faktisk effekt";
  Real eta_is(start=eta_is_nominal) "Aktuell isentropisk verkningsgrad";
  Real pressureRatio "Tryckförhållande (p_in/p_out)";

  // Rotationsdynamik
  AngularVelocity omega(start=omega_nominal) "Vinkelhastighet";
  AngularAcceleration alpha "Vinkelacceleration";
  Torque tau "Vridmoment";
  MomentOfInertia J "Tröghetsmoment";

  // Mätvariabler för forskningsfrågor
  Real specificWork "Specifikt arbete [J/kg]";
  Real powerDensity "Effekttäthet [W/m³]";
  Real volumetricFlowRate "Volymflöde [m³/s]";

  // ============ CONNECTORS ============
  // Fluid-portar (kräver ThermoCycle eller liknande bibliotek)
  // Modelica.Fluid.Interfaces.FluidPort_a inlet(redeclare package Medium = R245fa);
  // Modelica.Fluid.Interfaces.FluidPort_b outlet(redeclare package Medium = R245fa);

  // Mekanisk koppling
  Modelica.Mechanics.Rotational.Interfaces.Flange_a shaft
    "Mekanisk axel för effektuttag";

initial equation
  // Initialtillstånd
  omega = omega_nominal;

equation
  // ============ TRYCKFÖRHÅLLANDE ============
  pressureRatio = p_in / p_out;

  // ============ TRÖGHETSMOMENT (BERÄKNAS FRÅN GEOMETRI) ============
  // Approximation för flera roterande skivor
  J = numberOfDisks * 0.5 * (7850 * Modelica.Constants.pi * (diskDiameter/2)^4 * 0.005);

  // ============ ISENTROPISK VERKNINGSGRAD ============
  // Verkningsgraden varierar med tryckförhållande och rotationshastighet
  eta_is = eta_is_nominal * (omega/omega_nominal)^0.1 *
           (1 - 0.1*abs(pressureRatio - (p_in_nominal/p_out_nominal))/(p_in_nominal/p_out_nominal));

  // ============ ENERGIBALANS ============
  // Isentropiskt arbete
  W_is = m_flow * (h_in - h_out_s);

  // Faktiskt arbete (med verkningsgrad)
  W_actual = eta_is * W_is * mechanicalEfficiency;

  // Faktisk utloppsentalpi
  h_out = h_in - W_actual / m_flow;

  // Specifikt arbete
  specificWork = W_actual / m_flow;

  // ============ ROTATIONSDYNAMIK ============
  // Effektbalans: P = τ * ω
  W_actual = tau * omega;

  // Rörelseekvation för rotation
  J * alpha = tau - shaft.tau;
  der(omega) = alpha;
  shaft.phi = omega;  // Koppling till mekanisk axel

  // ============ VOLYMFLÖDE OCH EFFEKTTÄTHET ============
  // Approximativt volymflöde (förenklar - använd rho från medium)
  volumetricFlowRate = m_flow / 1200;  // Approximativ densitet för R245fa gas

  // Effekttäthet (effekt per volym av turbinen)
  powerDensity = W_actual / (Modelica.Constants.pi * (diskDiameter/2)^2 *
                              diskSpacing * numberOfDisks);

  // ============ ANNOTATIONS FÖR VISUALISERING ============
  annotation(
    Icon(coordinateSystem(preserveAspectRatio=false), graphics={
      Ellipse(
        extent={{-80,80},{80,-80}},
        lineColor={0,0,0},
        fillColor={200,200,200},
        fillPattern=FillPattern.Solid),
      Line(points={{-60,0},{60,0}}, color={0,0,0}, thickness=0.5),
      Line(points={{0,-60},{0,60}}, color={0,0,0}, thickness=0.5),
      Polygon(
        points={{-10,40},{10,40},{0,60},{-10,40}},
        lineColor={255,0,0},
        fillColor={255,0,0},
        fillPattern=FillPattern.Solid),
      Text(
        extent={{-100,100},{100,80}},
        lineColor={0,0,255},
        textString="Tesla Turbin"),
      Text(
        extent={{-100,-80},{100,-100}},
        lineColor={0,0,0},
        textString="η=%eta_is_nominal")}),
    Documentation(info="<html>
<h4>Tesla Turbine Expander för ORC</h4>
<p>
Denna modell representerar en bladlös Tesla-turbin som används som expander
i ett ORC-system (Organic Rankine Cycle) med R245fa som arbetsmedium.
</p>

<h5>Forskningsfrågor som besvaras:</h5>
<ul>
<li>Hur påverkar tryckförhållandet verkningsgraden?</li>
<li>Vilken rotationshastighet ger optimal effekt?</li>
<li>Hur stor effekttäthet kan uppnås jämfört med konventionella expandrar?</li>
<li>Hur varierar prestandan med massflöde?</li>
</ul>

<h5>Mätvariabler:</h5>
<ul>
<li><b>eta_is</b>: Isentropisk verkningsgrad</li>
<li><b>W_actual</b>: Faktisk effekt [W]</li>
<li><b>pressureRatio</b>: Tryckförhållande</li>
<li><b>omega</b>: Rotationshastighet [rad/s]</li>
<li><b>powerDensity</b>: Effekttäthet [W/m³]</li>
</ul>
</html>"));

end TeslaTurbineExpander;
