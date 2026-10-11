library ieee;
use ieee.std_logic_1164.all;

entity Led is
    port(
        reset     : in  std_logic;
        clk       : in  std_logic;
        intensidad : in  std_logic_vector(7 downto 0); -- 0-255
        led_out   : out std_logic                      -- señal PWM hacia el LED
    );
end Led;

architecture behavioral of Led is
    component PWM is
        port(
            reset     : in  std_logic;
            clk       : in  std_logic;
            w         : in  std_logic_vector(7 downto 0);
            pwm_pulse : out std_logic
        );
    end component;
begin
    comp : PWM
        port map(
            reset     => reset,
            clk       => clk,
            w         => intensidad,
            pwm_pulse => led_out
        );
end behavioral;