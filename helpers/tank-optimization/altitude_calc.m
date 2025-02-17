% Ron Nachum, Anya Mischel, Daniel DeConti - 3 July 2021
% MATLAB script that calculates plots for acceleration, velocity, and
% position of the rocket based on the thrust and mass flow rate plots
% derived through PropSim, as well as given values for rocket mass.
data = readtable('tank_data.csv');

ethanol_tank_sizes = zeros(4, height(data));
nitrous_tank_sizes = zeros(4, height(data));
altitudes =  zeros(4, height(data));
rod_height = zeros(4, height(data));

disp(data);

for index = 1:height(data)
    filename = string(cell2mat(data{index, 'Filename'}(1)));
    filename = 'tank-case-files\' + filename + '\PropSimOutput.mat';
    
    prop_mass = data{index, 'PropellantMass_kg_'}(1);    
    tank_mass = data{index, 'TankMass_kg_'}(1);
    
    ethanol_tank_size = data{index, 'FuelTankVolume_cuFt_'}(1);
    nitrous_tank_size = data{index, 'OxidizerTankVolume_cuFt_'}(1);
        
    count = 1;
    % disp(filename);
    for structure_mass = [25, 30, 35, 40]
        load(filename);
        
        thrust = record.F_thrust;
        m_fuel = record.m_fuel;
        m_ox = record.m_lox + record.m_gox;
        length = size(m_ox);
        t = record.time;
        
        m_rocket = structure_mass + tank_mass * ones(length) + m_fuel(1) + m_ox(1);
        rocket_mass = m_rocket;
        
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
            if v_rocket(i) > 70/3.281
                break;
            end
        end

        % disp(i);

        launch_rod_height = p_rocket(i)*3.281;

        % disp("Launch Rod Height: " + launch_rod_height + " ft");

        plot(p_rocket);

        % disp("Rocket Max Altitude: " + max(p_rocket) * 3.281 + " ft");

        altitudes(count, index) = max(p_rocket)*3.281;
        rod_height(count, index) = launch_rod_height;
        ethanol_tank_sizes(count, index) = ethanol_tank_size;
        nitrous_tank_sizes(count, index) = nitrous_tank_size;
                
        altitude = max(p_rocket)*3.281;
        formatSpec = "Rocket Mass: %d kg \t Launch Rod Height: %d ft \t Rocket Max Altitude: %d ft ";
        summary = sprintf(formatSpec, rocket_mass, launch_rod_height, altitude);
        % disp(summary);
        
        count = count + 1;
    end
end



% disp(altitudes);

ethanol_tank_sizes = ethanol_tank_sizes.';
nitrous_tank_sizes = nitrous_tank_sizes.';
altitudes = altitudes.';
rod_height = rod_height.';

scatter3(ethanol_tank_sizes(:,3), nitrous_tank_sizes(:,3), altitudes(:,3));
xlabel('Ethanol Tank Size (cu ft)');
ylabel('Nitrous Tank Size (cu ft)');
zlabel('Max Altitude (ft)');

figure();
plot(rod_height);