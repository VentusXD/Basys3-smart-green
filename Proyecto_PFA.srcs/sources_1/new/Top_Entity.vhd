library ieee;
use ieee.std_logic_1164.all;

entity Top_Entity is
    port(
        clk            : in  std_logic;
        rst            : in  std_logic;
        dht_dio        : inout std_logic;
        luz_analog_p   : in  std_logic;    -- VAUXP6
        luz_analog_n   : in  std_logic;    -- VAUXN6
        fan_pwm        : out std_logic;
        pump_pwm       : out std_logic;
        led_uv_b       : out std_logic;    -- Canal azul UV
        sw             : in  std_logic_vector(6 downto 0);
        segments       : out std_logic_vector(6 downto 0);
        anodes         : out std_logic_vector(3 downto 0)
    );
end Top_Entity;

architecture structural of Top_Entity is
    signal temp_data   : std_logic_vector(7 downto 0);
    signal hum_data    : std_logic_vector(7 downto 0);
    signal luz_data    : std_logic_vector(7 downto 0);
    signal en_fan, en_pump : std_logic;
    signal fan_speed, pump_speed : std_logic_vector(7 downto 0);
    signal uv_blue_intensity  : std_logic_vector(7 downto 0);

    component Sensor_Temp_Hum is
        generic (
            c_clkfreq : integer := 100_000_000;
            WAIT_TIME : integer := 2000000     
        );
        port (
            RST        : in  std_logic;
            CLK        : in  std_logic;
            DIO        : inout std_logic;
            tem_data   : out std_logic_vector(7 downto 0);
            hum_data   : out std_logic_vector(7 downto 0);
            data_valid : out std_logic
        );
    end component;

    component Sensor_Luz is
        port(
            clk_sys       : in  std_logic;  -- 100 MHz
            reset         : in  std_logic;
            luz_analog_p  : in  std_logic;  -- VAUXP6
            luz_analog_n  : in  std_logic;  -- VAUXN6
            luz_data      : out std_logic_vector(7 downto 0) -- 0-255
        );
    end component;

    component Controller is
        port(
            clk           : in  std_logic;
            rst           : in  std_logic;
            temp          : in  std_logic_vector(7 downto 0);
            hum           : in  std_logic_vector(7 downto 0);
            luz           : in  std_logic_vector(7 downto 0);
            override_fan  : in  std_logic;
            override_pump : in  std_logic;
            override_uv   : in  std_logic;
            uv_blue       : out std_logic_vector(7 downto 0);
            en_fan        : out std_logic;
            fan_speed     : out std_logic_vector(7 downto 0);
            en_pump       : out std_logic;
            pump_speed    : out std_logic_vector(7 downto 0)
        );
    end component;

    component Fan is
        port(
            En        : in  std_logic;
            CLK       : in  std_logic;
            Fan_speed : in  std_logic_vector(7 downto 0);
            out_Fan   : out std_logic
        );
    end component;

    component Pump is
        port(
            En         : in  std_logic;
            CLK        : in  std_logic;
            Pump_speed : in  std_logic_vector(7 downto 0);
            out_Pump   : out std_logic
        );
    end component;
    
    component Led is
        port(
            reset     : in  std_logic;
            clk       : in  std_logic;
            intensidad : in  std_logic_vector(7 downto 0); -- 0-255
            led_out   : out std_logic                      -- señal PWM hacia el LED
        );
    end component;

    component PWM is
        port(
            reset     : in  std_logic;
            clk       : in  std_logic;
            w         : in  std_logic_vector(7 downto 0);
            pwm_pulse : out std_logic
        );
    end component;

    component DisplayManager is
        port(
            clk      : in  std_logic;
            rst      : in  std_logic;
            sw_sel   : in  std_logic_vector(1 downto 0);
            temp     : in  std_logic_vector(7 downto 0);
            hum      : in  std_logic_vector(7 downto 0);
            luz      : in  std_logic_vector(7 downto 0);
            segments : out std_logic_vector(6 downto 0);
            anodes   : out std_logic_vector(3 downto 0)
        );
    end component;

begin

    -- Sensor de temperatura/humedad DHT11
    S_DHT : Sensor_Temp_Hum
        
        port map (
            RST        => rst,
            CLK        => clk,
            DIO        => dht_dio,
            tem_data   => temp_data,
            hum_data   => hum_data,
            data_valid => open
        );

    -- Sensor de luz con XADC (entrada diferencial)
    S_LUZ : Sensor_Luz
        port map (
            clk_sys       => clk,
            reset         => rst,
            luz_analog_p  => luz_analog_p,
            luz_analog_n  => luz_analog_n,
            luz_data      => luz_data
            
        );
    -- Controlador principal
    C_CTRL : Controller
        port map (
            clk           => clk,
            rst           => rst,
            temp          => temp_data,
            hum           => hum_data,
            luz           => luz_data,
            override_fan  => sw(4),
            override_pump => sw(5),
            override_uv   => sw(6),
            uv_blue       => uv_blue_intensity,
            en_fan        => en_fan,
            fan_speed     => fan_speed,
            en_pump       => en_pump,
            pump_speed    => pump_speed
        );

    -- Ventilador
    U_FAN : Fan
        port map (
            En        => en_fan,
            CLK       => clk,
            Fan_speed => fan_speed,
            out_Fan   => fan_pwm
        );

    -- Bomba
    U_PUMP : Pump
        port map (
            En         => en_pump,
            CLK        => clk,
            Pump_speed => pump_speed,
            out_Pump   => pump_pwm
        );


    -- PWM para UV azul
    U_LED : Led
        port map (
            reset           => '0',
            clk             => clk,
            intensidad      => uv_blue_intensity,
            led_out         => led_uv_b
        );

    -- Display de 4 dígitos
    D_DISP : DisplayManager
        port map (
            clk      => clk,
            rst      => rst,
            sw_sel   => sw(1 downto 0),   -- sw(1:0) selecciona temperatura/humedad/luz
            temp     => temp_data,
            hum      => hum_data,
            luz      => luz_data,
            segments => segments,
            anodes   => anodes
        );

end structural;