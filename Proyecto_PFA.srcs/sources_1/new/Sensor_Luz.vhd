library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Sensor_Luz is
    port(
        clk_sys       : in  std_logic;  --  100 MHz
        reset         : in  std_logic;  -- 
        luz_analog_p  : in  std_logic;  -- XADC  P 
        luz_analog_n  : in  std_logic;  -- XADC  N 
        luz_data      : out std_logic_vector(7 downto 0)  -- 0~255
    );
end entity Sensor_Luz;

architecture behavioral of Sensor_Luz is
    component xadc_wiz_0 is
        port (
            dclk_in   : in  std_logic;
            reset_in  : in  std_logic;
            do_out    : out std_logic_vector(15 downto 0);
            drdy_out  : out std_logic;
            eoc_out   : out std_logic;
            eos_out   : out std_logic;
            vauxp6    : in  std_logic;
            vauxn6    : in  std_logic;
            daddr_in            : in  std_logic_vector(6 downto 0);
            den_in              : in  std_logic;
            di_in               : in  std_logic_vector(15 downto 0);
            dwe_in              : in  std_logic
        );
    end component;

    signal xadc_do    : std_logic_vector(15 downto 0) := (others => '0');
    signal xadc_drdy  : std_logic := '0';
    signal xadc_eoc   : std_logic := '0';
    signal xadc_eos   : std_logic := '0';

    signal adc12      : unsigned(11 downto 0) := (others => '0');
    signal adc8       : unsigned(7 downto 0)  := (others => '0');
    
    signal xadc_den : std_logic;
    signal xadc_daddr : std_logic_vector (6 downto 0);
    
    

begin
    xadc_den <= xadc_eoc;
    xadc_daddr <= "0010110";

    u_xadc : xadc_wiz_0
        port map(
            dclk_in   => clk_sys,
            reset_in  => reset,
            
            den_in => xadc_den,
            daddr_in => xadc_daddr,
            di_in   => (others => '0'),
            dwe_in  => '0',
            
            
            do_out    => xadc_do,
            drdy_out  => xadc_drdy,
            eoc_out   => xadc_eoc,
            eos_out   => xadc_eos,

            -- AUX6
            vauxp6    => luz_analog_p,
            vauxn6    => luz_analog_n
        );

    --  drdy ， 12  ADC 
    process(clk_sys)
    begin
        if rising_edge(clk_sys) then
            if reset = '1' then
                adc12 <= (others => '0');
                adc8  <= (others => '0');
            else
                if xadc_drdy = '1' then
                    -- 
                    adc12 <= unsigned(xadc_do(15 downto 4));
                    --  0~255
                    adc8  <= unsigned(xadc_do(15 downto 8));
                end if;
            end if;
        end if;
    end process;

    luz_data <= std_logic_vector(adc8);

end architecture behavioral;