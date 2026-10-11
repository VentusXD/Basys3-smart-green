library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity GlobalTimer is
    generic (
        Ticks : integer := 150_000_000   -- 1.5s @100MHz
    );
    port (
        RST : in  std_logic;
        CLK : in  std_logic;
        EOT : out std_logic              -- 1个时钟周期脉冲
    );
end GlobalTimer;

architecture Behavioral of GlobalTimer is
    signal counter : integer range 0 to Ticks-1 := 0;
    signal eot_reg : std_logic := '0';
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                counter <= 0;
                eot_reg <= '0';
            else
                if counter = Ticks-1 then
                    counter <= 0;
                    eot_reg <= '1';
                else
                    counter <= counter + 1;
                    eot_reg <= '0';
                end if;
            end if;
        end if;
    end process;

    EOT <= eot_reg;
end Behavioral;