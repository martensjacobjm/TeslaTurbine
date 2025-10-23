within ORCSystem.HeatSource;

model StratifiedTank
  "Stratifierad ackumulatortank för termisk energilagring"

  /*
   * BESKRIVNING:
   * ===========
   * Stratifierad varmvattentank som lagrar termisk energi från solfångare
   * och levererar värme till ORC-förångaren.
   *
   * Stratifiering innebär att varmt vatten naturligt stiger till toppen
   * medan kallare vatten sjunker. Detta maximerar nyttig lagrad energi.
   *
   * Modellen inkluderar:
   * - Flera temperaturzoner (stratifiering)
   * - Värmeförluster till omgivningen
   * - In- och uttagspunkter på olika höjder
   * - Dynamisk laddning och urladdning
   *
   * FORSKNINGSFRÅGOR:
   * ================
   * 1. Hur mycket förbättrar termisk lagring ORC-verkningsgraden?
   * 2. Optimal tankvolym för given solfångararea
   * 3. Stratifieringens betydelse för systemets prestanda
   */

  import Modelica.SIunits.*;

  // ============ PARAMETRAR ============
  parameter Volume V_tank = 1.0 "Tankvolym [m³]";
  parameter Integer nLayers = 5 "Antal temperaturzoner (lager)";
  parameter Height h_tank = 2.0 "Tankhöjd [m]";
  parameter Diameter d_tank = sqrt(4*V_tank/(Modelica.Constants.pi*h_tank))
    "Tankdiameter [m]";
  parameter Length insulation_thickness = 0.10 "Isoleringstjocklek [m]";
  parameter ThermalConductivity lambda_ins = 0.04
    "Värmeledningsförmåga isolering [W/(m·K)]";
  parameter Temperature T_ambient = 273.15 + 20 "Omgivningstemperatur [K]";
  parameter Temperature T_initial = 273.15 + 50 "Initial tanktemperatur [K]";

  // ============ VARIABLER ============
  // Temperatur i varje lager (från topp till botten)
  Temperature T[nLayers](each start=T_initial) "Temperatur i varje lager";

  // Flöden
  MassFlowRate m_flow_charge "Massflöde vid laddning (från solfångare)";
  MassFlowRate m_flow_discharge "Massflöde vid urladdning (till ORC)";
  Temperature T_charge_in "Inloppstemperatur vid laddning";
  Temperature T_discharge_out "Utloppstemperatur vid urladdning (från toppen)";

  // Lagringsvärden
  Energy E_stored(start=rho*cp*V_tank*(T_initial-273.15)) "Lagrad energi";
  Energy E_stored_max "Maximal lagringskapacitet";
  Real SOC "State of Charge (laddningsnivå) [0-1]";

  // Värmeförluster
  HeatFlowRate Q_loss[nLayers] "Värmeförluster per lager";
  HeatFlowRate Q_loss_total "Total värmeförlust";

  // Materialegenskaper (vatten)
  parameter Density rho = 1000 "Densitet vatten [kg/m³]";
  parameter SpecificHeatCapacity cp = 4180 "Specifik värmekapacitet [J/(kg·K)]";

  // Beräknade storheter
  Mass m_layer "Massa per lager";
  Volume V_layer "Volym per lager";
  Area A_side "Sidoyta per lager";
  Real U_value "U-värde för tankväggar [W/(m²·K)]";

  // Prestanda
  Temperature T_top "Temperatur toppen (varmast)";
  Temperature T_bottom "Temperatur botten (kallast)";
  TemperatureDifference dT_stratification "Stratifieringsgradient";
  Real stratificationIndex "Stratifieringsindex [0-1]";

protected
  parameter Volume V_layer_const = V_tank / nLayers;
  parameter Mass m_layer_const = rho * V_layer_const;
  parameter Area A_side_const = Modelica.Constants.pi * d_tank * h_tank / nLayers;

equation
  // ============ GEOMETRI ============
  V_layer = V_layer_const;
  m_layer = m_layer_const;
  A_side = A_side_const;

  // ============ U-VÄRDE ============
  U_value = lambda_ins / insulation_thickness;

  // ============ VÄRMEFÖRLUSTER PER LAGER ============
  for i in 1:nLayers loop
    Q_loss[i] = U_value * A_side * (T[i] - T_ambient);
  end for;
  Q_loss_total = sum(Q_loss);

  // ============ ENERGIBALANS PER LAGER ============
  // Topp-lager (lager 1) - tar emot varm laddning
  m_layer * cp * der(T[1]) = m_flow_charge * cp * (T_charge_in - T[1])
                              - Q_loss[1]
                              - (if T[1] < T[2] then 0 else 0.1*m_layer*cp*(T[1]-T[2]));
                              // Enkel mixningsterm

  // Mellan-lager
  for i in 2:nLayers-1 loop
    m_layer * cp * der(T[i]) = - Q_loss[i]
                                 - (if T[i] < T[i+1] then 0 else 0.05*m_layer*cp*(T[i]-T[i+1]))
                                 + (if T[i-1] < T[i] then 0 else 0.05*m_layer*cp*(T[i-1]-T[i]));
  end for;

  // Botten-lager (lager nLayers) - tar emot kallt retursvatten från ORC
  m_layer * cp * der(T[nLayers]) = m_flow_discharge * cp * (T[1] - T_discharge_out) / nLayers
                                     - Q_loss[nLayers]
                                     + (if T[nLayers-1] < T[nLayers] then 0
                                        else 0.05*m_layer*cp*(T[nLayers-1]-T[nLayers]));

  // ============ URLADDNINGSTEMPERATUR ============
  // Tar varmt vatten från toppen
  T_discharge_out = T[1];

  // ============ LAGRAD ENERGI ============
  E_stored = sum({m_layer * cp * (T[i] - 273.15) for i in 1:nLayers});

  // Maximal kapacitet (vid 95°C)
  E_stored_max = rho * cp * V_tank * (95);

  // State of Charge
  SOC = E_stored / E_stored_max;

  // ============ STRATIFIERING ============
  T_top = T[1];
  T_bottom = T[nLayers];
  dT_stratification = T_top - T_bottom;

  // Stratifieringsindex (1 = perfekt stratifierad, 0 = fullständigt mixad)
  stratificationIndex = dT_stratification / max(1.0, T_top - T_ambient);

  // ============ ANNOTATIONS ============
  annotation(
    Icon(coordinateSystem(preserveAspectRatio=false), graphics={
      Rectangle(
        extent={{-60,80},{60,-80}},
        lineColor={0,0,0},
        fillColor={200,200,200},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{-50,70},{50,20}},
        lineColor={255,0,0},
        fillColor={255,100,100},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{-50,20},{50,-30}},
        lineColor={255,200,0},
        fillColor={255,200,100},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{-50,-30},{50,-70}},
        lineColor={0,0,255},
        fillColor={100,150,255},
        fillPattern=FillPattern.Solid),
      Line(points={{-70,0},{-50,0}}, color={255,0,0}, thickness=1),
      Line(points={{50,0},{70,0}}, color={0,0,255}, thickness=1),
      Polygon(
        points={{-60,10},{-50,0},{-60,-10},{-60,10}},
        lineColor={255,0,0},
        fillColor={255,0,0},
        fillPattern=FillPattern.Solid),
      Polygon(
        points={{60,10},{50,0},{60,-10},{60,10}},
        lineColor={0,0,255},
        fillColor={0,0,255},
        fillPattern=FillPattern.Solid),
      Text(
        extent={{-100,100},{100,85}},
        lineColor={0,0,255},
        textString="Ackumulatortank"),
      Text(
        extent={{-100,-85},{100,-100}},
        lineColor={0,0,0},
        textString="V=%V_tank m³")}),
    Documentation(info="<html>
<h4>Stratified Storage Tank</h4>
<p>
Stratifierad varmvattentank för termisk energilagring.
Används för att jämna ut variationer från solfångare och optimera ORC-drift.
</p>

<h5>Stratifiering:</h5>
<p>
Tanken delas in i flera temperaturzoner där varmt vatten naturligt
samlas i toppen och kallt vatten i botten. Detta maximerar exergi.
</p>

<h5>Mätvariabler:</h5>
<ul>
<li><b>E_stored</b>: Lagrad energi [J]</li>
<li><b>SOC</b>: State of Charge [0-1]</li>
<li><b>T_top, T_bottom</b>: Topp- och bottentemperatur [K]</li>
<li><b>stratificationIndex</b>: Stratifieringskvalitet [0-1]</li>
<li><b>Q_loss_total</b>: Total värmeförlust [W]</li>
</ul>

<h5>Forskningsfrågor:</h5>
<ul>
<li>Hur mycket förbättrar lagring ORC-verkningsgraden?</li>
<li>Optimal tankvolym för systemstorlek</li>
<li>Betydelse av god stratifiering</li>
<li>Urladdningsstrategi för maximal effekt</li>
</ul>
</html>"));

end StratifiedTank;
