library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Sensor_Temp_Hum is
    generic (
        c_clkfreq : integer := 100_000_000;
        WAIT_TIME : integer := 2000000     -- 2 segundos entre lecturas
    );
    Port (
        RST      : in  std_logic;          -- Reset del sistema
        CLK      : in  std_logic;          -- Reloj del sistema
        DIO      : inout std_logic;        -- Pin de datos del DHT11
        tem_data : out std_logic_vector(7 downto 0);  -- Temperatura entera (ºC)
        hum_data : out std_logic_vector(7 downto 0);  -- Humedad entera (%)
        data_valid : out std_logic         -- '1' cuando los datos son válidos
    );
end Sensor_Temp_Hum;

architecture behavioral of Sensor_Temp_Hum is

    -- DHT11_Reader original (sin reset)
    component DHT11_Reader is
        generic (
            c_clkfreq : integer := 100_000_000;
            WAIT_TIME : integer := 2000000
        );
        Port (
            clk         : in  std_logic;
            rst         : in  std_logic;       -- 新增复位
            dht_pin     : inout std_logic;
            data_buffer : out std_logic_vector(39 downto 0);
            data_ready  : out std_logic
        );
    end component;

    signal data_buffer_internal : std_logic_vector(39 downto 0);
    signal data_ready_internal  : std_logic;

begin

    -- Instancia del lector DHT11 (sin reset)
    reader_inst: DHT11_Reader
        generic map (
            c_clkfreq => c_clkfreq,
            WAIT_TIME => WAIT_TIME
        )
        port map (
            clk         => CLK,
            dht_pin     => DIO,
            rst         => RST,
            data_buffer => data_buffer_internal,
            data_ready  => data_ready_internal
        );

    -----------------------------------------------------------------
    -- Extracción CORRECTA de humedad y temperatura
    -- Los bits del DHT11_Reader se almacenan en el orden de llegada:
    --   data_buffer(0)  = MSB humedad entera
    --   data_buffer(7)  = LSB humedad entera
    --   data_buffer(8)  = MSB humedad fraccional
    --   ...
    --   data_buffer(16) = MSB temperatura entera
    --   data_buffer(23) = LSB temperatura entera
    --   ...
    --   data_buffer(39) = LSB checksum
    -- Para formar vectores estándar (7 downto 0, 7=MSB) hay que
    -- reordenar los índices.
    -----------------------------------------------------------------
    process(data_buffer_internal)
    begin
        -- Temperatura entera (bits 16 a 23)
        tem_data(7) <= data_buffer_internal(16);   -- MSB
        tem_data(6) <= data_buffer_internal(17);
        tem_data(5) <= data_buffer_internal(18);
        tem_data(4) <= data_buffer_internal(19);
        tem_data(3) <= data_buffer_internal(20);
        tem_data(2) <= data_buffer_internal(21);
        tem_data(1) <= data_buffer_internal(22);
        tem_data(0) <= data_buffer_internal(23);   -- LSB

        -- Humedad entera (bits 0 a 7)
        hum_data(7) <= data_buffer_internal(0);    -- MSB
        hum_data(6) <= data_buffer_internal(1);
        hum_data(5) <= data_buffer_internal(2);
        hum_data(4) <= data_buffer_internal(3);
        hum_data(3) <= data_buffer_internal(4);
        hum_data(2) <= data_buffer_internal(5);
        hum_data(1) <= data_buffer_internal(6);
        hum_data(0) <= data_buffer_internal(7);    -- LSB
    end process;

    data_valid <= data_ready_internal;

end behavioral;