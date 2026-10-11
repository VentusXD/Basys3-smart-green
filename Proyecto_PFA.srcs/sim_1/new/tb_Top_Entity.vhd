library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_Invernadero is
end tb_Invernadero;

architecture sim of tb_Invernadero is
    -- Señales para conectar a la entidad Top
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '1';
    signal dht_dio     : std_logic := 'H';       -- pull-up (alta impedancia)
    signal luz_analog  : std_logic := '0';       -- entrada analógica simulada
    signal fan_pwm, pump_pwm, led_pwm : std_logic;
    signal segs        : std_logic_vector(27 downto 0);

    -- Constante de reloj
    constant CLK_PERIOD : time := 20 ns;        -- 50 MHz

    -- Señal interna para el modelo DHT11
    signal dht_response : std_logic_vector(39 downto 0) := (others => '0');
begin

    ------------------------------------------------------------------------
    -- Instancia del diseño completo (Top_Entity)
    ------------------------------------------------------------------------
    UUT: entity work.Top_Entity
        port map (
            clk         => clk,
            rst         => rst,
            dht_dio     => dht_dio,
            luz_analog  => luz_analog,          -- Única entrada analógica
            fan_pwm     => fan_pwm,
            pump_pwm    => pump_pwm,
            led_pwm     => led_pwm,
            segs        => segs
        );

    ------------------------------------------------------------------------
    -- Generación del reloj de 50 MHz
    ------------------------------------------------------------------------
    clk <= not clk after CLK_PERIOD/2;

    ------------------------------------------------------------------------
    -- Proceso de reset
    ------------------------------------------------------------------------
    process
    begin
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait;
    end process;

    ------------------------------------------------------------------------
    -- Modelo de comportamiento del DHT11
    ------------------------------------------------------------------------
    -- Trama fija: Humedad = 39% (0x27), Temp = 25°C (0x19),
    -- Checksum = 0x27+0+0x19+0 = 0x40
    dht_response <= x"27" & x"00" & x"19" & x"00" & x"40";

    process
    begin
        dht_dio <= 'H';                -- Línea en alta impedancia (pull-up externo)
        -- Esperar a que la FPGA (maestro) tire la línea a '0'
        wait until dht_dio = '0';
        -- Esperar a que la FPGA libere la línea (vuelva a 'H')
        wait until dht_dio = 'H';
        -- Respuesta del sensor: pulso bajo 80 µs + pulso alto 80 µs
        wait for 40 us;
        dht_dio <= '0';
        wait for 80 us;
        dht_dio <= '1';
        wait for 80 us;
        -- Enviar la trama de 40 bits
        for i in 39 downto 0 loop
            dht_dio <= '0';            -- bit de start 50 µs
            wait for 50 us;
            dht_dio <= '1';            -- subir línea
            if dht_response(i) = '1' then
                wait for 70 us;        -- duración para '1'
            else
                wait for 26 us;        -- duración para '0'
            end if;
            dht_dio <= '1';            -- gap entre bits
            wait for 30 us;
        end loop;
        -- Fin de la trama: liberar línea
        dht_dio <= 'H';
        -- Esperar antes de permitir otra lectura (2 segundos)
        wait for 2 sec;
        -- Repetir (en simulación se puede volver al inicio para lecturas continuas)
    end process;

    ------------------------------------------------------------------------
    -- Simulación del sensor de luz
    ------------------------------------------------------------------------
    -- En hardware real, luz_analog recibe una tensión analógica entre 0 V y 1 V.
    -- En simulación podemos tratarlo como un nivel digital:
    --   '0' -> 0 V (oscuridad total)
    --   '1' -> ~1 V (máxima luz)
    -- Para probar un valor intermedio, podemos dejarlo en '1' y confiar en que
    -- el modelo del XADC devuelva un código alto.
    luz_analog <= '1';   -- Simula una luz ambiente moderada/alta

end sim;