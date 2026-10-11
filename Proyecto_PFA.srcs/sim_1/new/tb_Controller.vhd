library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_Controller is
end tb_Controller;

architecture sim of tb_Controller is
    signal clk, rst : std_logic := '0';
    signal temp, hum, luz : std_logic_vector(7 downto 0) := (others => '0'); -- inicializados
    signal override_fan, override_pump, override_uv : std_logic := '0';
    signal en_fan, en_pump : std_logic;
    signal fan_speed, pump_speed : std_logic_vector(7 downto 0);
    signal uv_blue : std_logic_vector(7 downto 0);
begin
    -- Instancia del controlador (versión UV)
    uut: entity work.Controller
        port map(
            clk           => clk,
            rst           => rst,
            temp          => temp,
            hum           => hum,
            luz           => luz,
            override_fan  => override_fan,
            override_pump => override_pump,
            override_uv   => override_uv,
            uv_blue       => uv_blue,
            en_fan        => en_fan,
            fan_speed     => fan_speed,
            en_pump       => en_pump,
            pump_speed    => pump_speed
        );

    -- Reloj de 50 MHz
    clk <= not clk after 10 ns;

    -- Estímulos
    process
    begin
        -- Reset inicial
        rst <= '1';
        wait for 40 ns;
        rst <= '0';
        wait for 20 ns;

        -- Caso 1: temperatura normal, humedad normal, luz alta => todo apagado
        temp <= std_logic_vector(to_unsigned(25, 8));
        hum  <= std_logic_vector(to_unsigned(50, 8));
        luz  <= std_logic_vector(to_unsigned(200, 8));
        wait for 200 ns;  -- esperamos más para ver bien

        -- Caso 2: temperatura alta (>30) => ventilador activo (velocidad proporcional)
        temp <= std_logic_vector(to_unsigned(35, 8));
        wait for 200 ns;

        -- Caso 3: humedad baja (<40) => bomba activa
        hum <= std_logic_vector(to_unsigned(25, 8));
        temp <= std_logic_vector(to_unsigned(25, 8));
        wait for 200 ns;

        -- Caso 4: poca luz => UV activa (intensidad proporcional)
        luz <= std_logic_vector(to_unsigned(30, 8));
        hum <= std_logic_vector(to_unsigned(60, 8));
        wait for 200 ns;

        -- Caso 5: temperatura crítica >40 => ventilador al 100%
        temp <= std_logic_vector(to_unsigned(42, 8));
        wait for 200 ns;

        -- Caso 6: Borde exacto de temperatura (30°C) -> ventilador apagado
        temp <= std_logic_vector(to_unsigned(30, 8));
        wait for 200 ns;

        -- Caso 7: Temperatura justo por encima (31°C) -> velocidad 25
        temp <= std_logic_vector(to_unsigned(31, 8));
        wait for 200 ns;

        -- Caso 8: Humedad borde (40%) -> bomba apagada
        hum <= std_logic_vector(to_unsigned(40, 8));
        wait for 200 ns;

        -- Caso 9: Humedad 39% -> velocidad 12
        hum <= std_logic_vector(to_unsigned(39, 8));
        wait for 200 ns;

        -- Caso 10: Luz borde (50) -> UV apagada
        luz <= std_logic_vector(to_unsigned(50, 8));
        wait for 200 ns;

        -- Caso 11: Luz 49 -> intensidad UV = 5
        luz <= std_logic_vector(to_unsigned(49, 8));
        wait for 200 ns;

        -- Caso 12: Condiciones simultáneas automáticas: temp=35, hum=25, luz=30
        temp <= std_logic_vector(to_unsigned(35, 8));
        hum  <= std_logic_vector(to_unsigned(25, 8));
        luz  <= std_logic_vector(to_unsigned(30, 8));
        wait for 200 ns;

        -- ===================================================
        -- PRUEBAS DE OVERRIDES (por separado y combinados)
        -- ===================================================

        -- Override UV (SW6) forzado
        override_uv <= '1';
        wait for 200 ns;
        override_uv <= '0';
        wait for 100 ns;

        -- Override ventilador (SW4)
        override_fan <= '1';
        wait for 200 ns;
        override_fan <= '0';
        wait for 100 ns;

        -- Override bomba (SW5)
        override_pump <= '1';
        wait for 200 ns;
        override_pump <= '0';
        wait for 100 ns;

        -- Overrides múltiples simultáneos
        override_fan <= '1';
        override_pump <= '1';
        override_uv <= '1';
        wait for 200 ns;
        override_fan <= '0';
        override_pump <= '0';
        override_uv <= '0';
        wait for 100 ns;

        -- Verificar que vuelve al modo automático (debe dar fan=125, pump=180, uv=100)
        temp <= std_logic_vector(to_unsigned(35, 8));
        hum  <= std_logic_vector(to_unsigned(25, 8));
        luz  <= std_logic_vector(to_unsigned(30, 8));
        wait for 400 ns;

        wait;
    end process;
end sim;