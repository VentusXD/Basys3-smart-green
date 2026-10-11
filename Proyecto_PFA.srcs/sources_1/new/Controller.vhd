library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Controller is
    port(
        clk           : in  std_logic;
        rst           : in  std_logic;
        temp          : in  std_logic_vector(7 downto 0);
        hum           : in  std_logic_vector(7 downto 0);
        luz           : in  std_logic_vector(7 downto 0);
        override_fan  : in  std_logic;
        override_pump : in  std_logic;
        override_uv   : in  std_logic;   -- SW6
        uv_blue       : out std_logic_vector(7 downto 0);
        en_fan        : out std_logic;
        fan_speed     : out std_logic_vector(7 downto 0);
        en_pump       : out std_logic;
        pump_speed    : out std_logic_vector(7 downto 0)
    );
end Controller;

architecture behavioral of Controller is
    constant TEMP_MAX    : integer := 20;
    constant TEMP_CRIT   : integer := 35;
    constant HUM_MIN     : integer := 70;
    constant HUM_CRIT    : integer := 45;
    constant LUZ_UMBRAL  : integer := 50; 
begin
    process(clk, rst)
        variable t_int, h_int, l_int : integer;
        variable speed_fan, speed_pump : integer;
        variable uv_intensity : integer;
    begin
        if rst = '1' then
            en_fan        <= '0';
            fan_speed     <= (others => '0');
            en_pump       <= '0';
            pump_speed    <= (others => '0');
            uv_blue       <= (others => '0');
        elsif rising_edge(clk) then
            t_int := to_integer(unsigned(temp));
            h_int := to_integer(unsigned(hum));
            l_int := to_integer(unsigned(luz));

            -- Ventilador (igual)
            if override_fan = '1' then
                en_fan <= '1';
                speed_fan := 255;
            else
                if t_int > TEMP_MAX then
                    en_fan <= '1';
                    if t_int >= TEMP_CRIT then
                        speed_fan := 255;
                    else
                        speed_fan := (t_int - TEMP_MAX) * 25;
                        if speed_fan > 255 then speed_fan := 255; end if;
                    end if;
                else
                    en_fan    <= '0';
                    speed_fan := 0;
                end if;
            end if;
            fan_speed <= std_logic_vector(to_unsigned(speed_fan, 8));

            -- Bomba (igual)
            if override_pump = '1' then
                en_pump <= '1';
                speed_pump := 255;
            else
                if h_int < HUM_MIN then
                    en_pump <= '1';
                    if h_int <= HUM_CRIT then
                        speed_pump := 255;
                    else
                        speed_pump := (HUM_MIN - h_int) * 12;
                        if speed_pump > 255 then speed_pump := 255; end if;
                    end if;
                else
                    en_pump    <= '0';
                    speed_pump := 0;
                end if;
            end if;
            pump_speed <= std_logic_vector(to_unsigned(speed_pump, 8));

            
            if override_uv = '1' then
                uv_intensity := 255;
            else
                if l_int > LUZ_UMBRAL then         
                    uv_intensity := (l_int - LUZ_UMBRAL) * 5;
                if uv_intensity > 255 then uv_intensity := 255; end if;
                else
                    uv_intensity := 0;
                end if;
            end if;

            uv_blue <= std_logic_vector(to_unsigned(uv_intensity, 8));
        end if;
    end process;
end behavioral;