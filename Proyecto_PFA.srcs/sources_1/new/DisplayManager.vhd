library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DisplayManager is
    port (
        clk      : in  std_logic;          -- 100 MHz
        rst      : in  std_logic;
        sw_sel   : in  std_logic_vector(1 downto 0);
        temp     : in  std_logic_vector(7 downto 0);
        hum      : in  std_logic_vector(7 downto 0);
        luz      : in  std_logic_vector(7 downto 0);
        segments : out std_logic_vector(6 downto 0);
        anodes   : out std_logic_vector(3 downto 0)
    );
end DisplayManager;

architecture behavioral of DisplayManager is
    signal current_value : unsigned(7 downto 0);
    signal bcd_hun, bcd_ten, bcd_unit : unsigned(3 downto 0);
    signal dig_cnt : unsigned(1 downto 0) := "00";
    signal dig_clk : integer range 0 to 99999 := 0;  -- 100000 counts = 1ms @100MHz
    signal current_digit : integer range 0 to 3;
    signal digit_bcd : unsigned(3 downto 0);
    signal blank_hun, blank_ten : boolean;
    signal mode_digit : unsigned(3 downto 0);

    component Display
        port (
            code : in  std_logic_vector(3 downto 0);
            seg  : out std_logic_vector(6 downto 0)
        );
    end component;

    signal segs_int : std_logic_vector(6 downto 0);
begin
    -- seleccion mostra
    process(sw_sel, temp, hum, luz)
    begin
        case sw_sel is
            when "00"   => current_value <= unsigned(temp);
            when "01"   => current_value <= unsigned(hum);
            when "10"   => current_value <= unsigned(luz);
            when others => current_value <= unsigned(temp);
        end case;
    end process;

    -- bit -> BCD
    process(current_value)
        variable val_int : integer range 0 to 255;
    begin
        val_int := to_integer(current_value);
        bcd_hun  <= to_unsigned(val_int / 100, 4);
        bcd_ten  <= to_unsigned((val_int mod 100) / 10, 4);
        bcd_unit <= to_unsigned(val_int mod 10, 4);
    end process;

    blank_hun <= (bcd_hun = 0);
    blank_ten <= blank_hun and (bcd_ten = 0);

    -- 
    with sw_sel select
        mode_digit <= "0001" when "00",   -- 1 -> temp
                      "0010" when "01",   -- 2 -> hum
                      "0011" when "10",   -- 3 -> luz
                      "0001" when others;

    -- 1ms 
    process(clk, rst)
    begin
        if rst = '1' then
            dig_cnt <= "00";
            dig_clk <= 0;
        elsif rising_edge(clk) then
            if dig_clk = 99999 then   -- 100000-1
                dig_clk <= 0;
                dig_cnt <= dig_cnt + 1;
            else
                dig_clk <= dig_clk + 1;
            end if;
        end if;
    end process;

    current_digit <= to_integer(dig_cnt);

    -- seleccion digital
    process(current_digit, mode_digit, bcd_hun, bcd_ten, bcd_unit, blank_hun, blank_ten)
    begin
        case current_digit is
            when 0 =>
                digit_bcd <= mode_digit;        -- 
            when 1 =>
                if blank_hun then
                    digit_bcd <= "1111";        -- paga
                else
                    digit_bcd <= bcd_hun;
                end if;
            when 2 =>
                if blank_ten then
                    digit_bcd <= "1111";
                else
                    digit_bcd <= bcd_ten;
                end if;
            when 3 =>
                digit_bcd <= bcd_unit;
            when others =>
                digit_bcd <= "1111";
        end case;
    end process;

    U_DISP : Display port map(code => std_logic_vector(digit_bcd), seg => segs_int);

    segments <= segs_int;
    
    -- 
    anodes <= "1110" when current_digit = 3 else
              "1101" when current_digit = 2 else
              "1011" when current_digit = 1 else
              "0111" when current_digit = 0 else
              "1111";

end behavioral;