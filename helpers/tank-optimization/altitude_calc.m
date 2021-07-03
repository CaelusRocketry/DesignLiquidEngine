% Ron Nachum, Anya Mischel, Daniel DeConti - 3 July 2021
% MATLAB script that calculates plots for acceleration, velocity, and
% position of the rocket based on the thrust and mass flow rate plots
% derived through PropSim, as well as given values for rocket mass.
thrust = record.F_thrust;
m_fuel = record.m_fuel;
m_ox = record.m_lox + record.m_gox;
length = size(m_ox);
t = record.time;

m_rocket = 50 * ones(length) + m_fuel(1) + m_ox(1);

m_rocket = m_rocket - (m_ox(1) - m_ox) - (m_fuel(1) - m_fuel);

a_rocket = thrust ./ m_rocket;

a_rocket = a_rocket - 9.81 * ones(length);

a_rocket = cat(1, a_rocket, -9.81*ones(2500,1));

v_rocket = zeros(size(a_rocket));

for i = 2:1:size(v_rocket)
    v_rocket(i) = v_rocket(i-1) + 0.5*(a_rocket(i) + a_rocket(i-1))*(0.01);
end

p_rocket = zeros(size(v_rocket));
for i = 2:1:size(p_rocket)
    p_rocket(i) = p_rocket(i-1) + 0.5*(v_rocket(i) + v_rocket(i-1))*(0.01);
end

for i = 1:size(v_rocket)
    if v_rocket(i) > 100/3.281
        break;
    end
end

disp(i);

launch_rod_height = p_rocket(i)*3.281;

disp("Launch Rod Height: " + launch_rod_height + " ft");

plot(p_rocket);

disp("Rocket Max Altitude: " + max(p_rocket) * 3.281 + " ft");
