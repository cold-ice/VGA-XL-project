library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGA_Controller is

  generic (ROWS    : integer := 525;    --525 2+33+480+10
           COLUMNS : integer := 797);   --797 95+47+640+15
  port(CLOCK_50  : in  std_logic;
       SW        : in  std_logic_vector(4 downto 0);
       VGA_R     : out std_logic_vector(9 downto 0);
       VGA_G     : out std_logic_vector(9 downto 0);
       VGA_B     : out std_logic_vector(9 downto 0);
       VGA_CLK   : out std_logic;
       VGA_BLANK : out std_logic;
       VGA_VS    : out std_logic;
       VGA_HS    : out std_logic;
       LEDR      : out std_logic_vector(0 downto 0);  -- AVVISA SE C'E' TRASMISSIONE SERIALE
       LEDG      : out std_logic_vector(0 downto 0);  -- AVVISA SE C'E' AGGIORNAMENTO POSIZIONE
       -- INGRESSI SERIALE
       UART_RXD  : in  std_logic;
       GPIO_1    : in  std_logic_vector(35 downto 0);
       -- SEGNALI DI DEBUG
       GPIO_0    : out std_logic_vector(35 downto 0);
       KEY       : in  std_logic_vector(3 downto 0);
       -- commenta righe seguenti per modalita' release o decommentale per modalita' testbench
       X_UPDATE                : IN STD_LOGIC_VECTOR(15 downto 0);
       Y_UPDATE                : IN STD_LOGIC_VECTOR(15 downto 0);
       Z_UPDATE                : IN STD_LOGIC_VECTOR(15 downto 0);
       data_out_ready: IN STD_LOGIC
       );

end VGA_Controller;

architecture behavioural of VGA_Controller is

  component RS232_BUFF_STRUCT
    port (
      clk            : in  std_logic;
      rst            : in  std_logic;
      uart_line      : in  std_logic;
      data_out_ready : out std_logic;
      data_out       : out std_logic_vector(9 downto 0);
      data_out_x     : out std_logic_vector(15 downto 0);
      data_out_y     : out std_logic_vector(15 downto 0);
      data_out_z     : out std_logic_vector(15 downto 0);
      uart_clock_out : out std_logic;
      status         : out std_logic
      );
  end component;

  component CU_VGA_H
    generic (COLUMNS : integer);
    port(CLOCK_50 : in  std_logic;
         RESET    : in  std_logic;
         COLUMN   : in  integer range 0 to COLUMNS;
         HC_EN    : out std_logic;
         VC_EN    : out std_logic;
         STR_EN   : out std_logic;
         HC_CL    : out std_logic;
         RGB_CTRL : out std_logic;
         HS_CTRL  : out std_logic
         );
  end component;

  component CU_VGA_V
    generic (ROWS : integer);
    port(CLOCK_50 : in  std_logic;
         RESET    : in  std_logic;
         ROW      : in  integer range 0 to ROWS;
         VC_CL    : out std_logic;
         RGB_CTRL : out std_logic;
         VS_CTRL  : out std_logic
         );
  end component;

  component DATAPATH
    generic (ROWS    : integer;
             COLUMNS : integer);
    port(CLOCK_50       : in  std_logic;
         HC_EN          : in  std_logic;
         VC_EN          : in  std_logic;
         STR_EN         : in  std_logic;
         RGB_EN         : in  std_logic;
         HS_CTRL        : in  std_logic;
         VS_CTRL        : in  std_logic;
         HC_CL          : in  std_logic;
         VC_CL          : in  std_logic;
         ROW            : out integer range 0 to ROWS;
         COLUMN         : out integer range 0 to COLUMNS;
         R              : out std_logic_vector(9 downto 0);
         G              : out std_logic_vector(9 downto 0);
         B              : out std_logic_vector(9 downto 0);
         VS             : out std_logic;
         HS             : out std_logic;
         VGA_CLK        : out std_logic;
         X_UPDATE       : in  signed(15 downto 0);
         Y_UPDATE       : in  signed(15 downto 0);
         Z_UPDATE       : in  signed(15 downto 0);
         data_out_ready : in  std_logic
         );
  end component;

  signal HC_EN, VC_EN, STR_EN, HC_CL, VC_CL, RGB_EN, HS_CTRL, VS_CTRL : std_logic;
  signal X_UPDATE_S, Y_UPDATE_S, Z_UPDATE_S                           : signed(15 downto 0);
  signal RGB_CTRL                                                     : std_logic_vector(1 downto 0);
  signal ROW                                                          : integer range 0 to 525;
  signal COLUMN                                                       : integer range 0 to 797;
  signal NRES, uart_line                                              : std_logic;
--Segnali per spostare con bottoni
  signal DATA_READY_KEY, FLAG, DATA_READY                             : std_logic;
  signal X_BUFF, Y_BUFF, Z_BUFF, X_KEY, Y_KEY, Z_KEY                  : signed(15 downto 0);
-- Commenta le due seguenti righe per modalita' testbench
--signal X_UPDATE, Y_UPDATE, Z_UPDATE                                 : std_logic_vector(15 downto 0);
--signal data_out_ready                                               : std_logic;

begin

  RGB_EN <= RGB_CTRL(0) and RGB_CTRL(1);  -- RGB_CTRL(0) e RGB_CTRL(1) sono inviati dalle due unita' di controllo per
                                          -- avvisare che ci troviamo nella fase VIDEO ON e che il segnale video puo'
                                          -- essere inviato.

  VGA_BLANK <= '1';                     -- Il VGA BLANK e' attivo basso

  NRES <= not SW(0);  -- Segnale di reset inviato al modulo RS232, che ha reset attivo basso

-- Da modulo RS232 a Datapath. Occorre convertire STD_LOGIC_VECTOR in SIGNED
  X_UPDATE_S <= signed(X_UPDATE);
  Y_UPDATE_S <= signed(Y_UPDATE);
  Z_UPDATE_S <= signed(Z_UPDATE);

-- Segnale per vedere se sta avvenendo un aggiornamento della posizione del quadrato
  LEDG(0) <= DATA_READY;

-- Commenta la riga seguente per modalita' testbench
--serial : RS232_BUFF_STRUCT port map (CLOCK_50, NRES, uart_line, data_out_ready, open, X_UPDATE, Y_UPDATE, Z_UPDATE, open, LEDR(0));

-- Unita' di controllo della scansione orizzontale
  CU_H : CU_VGA_H generic map(COLUMNS => COLUMNS)
    port map(CLOCK_50, SW(0), COLUMN, HC_EN, VC_EN, STR_EN, HC_CL, RGB_CTRL(0), HS_CTRL);

-- Unita' di controllo della scansione verticale
  CU_V : CU_VGA_V generic map(ROWS => ROWS)
    port map(CLOCK_50, SW(0), ROW, VC_CL, RGB_CTRL(1), VS_CTRL);

-- Datapath del componente di controllo VGA
  DP : DATAPATH generic map(ROWS => ROWS, COLUMNS => COLUMNS)
    port map(CLOCK_50, HC_EN, VC_EN, STR_EN, RGB_EN, HS_CTRL, VS_CTRL, HC_CL, VC_CL, ROW, COLUMN, VGA_R, VGA_G, VGA_B, VGA_VS, VGA_HS, VGA_CLK, X_BUFF, Y_BUFF, Z_BUFF, DATA_READY);

--------------------------------------------SEZIONE DI TESTING------------------------------------------------------

-- Con SW(1) si seleziona la modalita': 0 ingresso seriale via UART_RXD, 1 ingresso seriale via GPIO_1(13)
-- Nota: ci siamo poi resi conto dell'inutilita' di poter selezionare l'ingresso UART_RXD come input seriale.
  with SW(1) select uart_line <= not(UART_RXD) when '0',
                                 GPIO_1(13) when '1',
                                 UART_RXD   when others;

  with SW(1) select GPIO_0(0) <= UART_RXD when '0',
                                 GPIO_1(13) when '1',
                                 UART_RXD   when others;

-- Con SW(2) si seleziona la modalita': 0 spostamento via seriale, 1 spostamento via bottoni
  with SW(2) select X_BUFF <= X_UPDATE_S when '0',
                              X_KEY      when '1',
                              X_UPDATE_S when others;

  with SW(2) select Y_BUFF <= Y_UPDATE_S when '0',
                              Y_KEY      when '1',
                              Y_UPDATE_S when others;

  with SW(2) select Z_BUFF <= Z_UPDATE_S when '0',
                              Z_KEY      when '1',
                              Z_UPDATE_S when others;

  with SW(2) select DATA_READY <= data_out_ready when '0',
                                  DATA_READY_KEY when '1',
                                  data_out_ready when others;

-- Process per spostare figura tramite bottoni.
--Con SW(3) si scegliere se spostare su/giu' o ingrandire/rimpicciolire.
--Dato che KEY(3) sembra difettoso, SW(4) si usa per scegliere se KEY(2) aumenta o diminuisce la coordinata.
  POSupdate : process(CLOCK_50, SW)
  begin
    if(SW(0) = '1') then
      X_KEY          <= (others => '0');
      Y_KEY          <= (others => '0');
      Z_KEY          <= (others => '0');
      DATA_READY_KEY <= '0';
      FLAG           <= '1';
    elsif(CLOCK_50 = '1' and CLOCK_50'event) then
      if(KEY(0) = '0' and FLAG = '1') then     -- Sposta a destra
        X_KEY          <= "0000000000000001";
        Y_KEY          <= (others => '0');
        Z_KEY          <= (others => '0');
        DATA_READY_KEY <= '1';
      elsif(KEY(1) = '0' and FLAG = '1') then  -- Sposta a sinistra
        X_KEY          <= "1111111111111111";
        Y_KEY          <= (others => '0');
        Z_KEY          <= (others => '0');
        DATA_READY_KEY <= '1';
      elsif(KEY(2) = '0' and FLAG = '1' and SW(3) = '0' and SW(4) = '0') then  -- Sposta in alto
        Z_KEY          <= "0000000000000001";
        X_KEY          <= (others => '0');
        Y_KEY          <= (others => '0');
        DATA_READY_KEY <= '1';
      elsif(KEY(2) = '0' and FLAG = '1' and SW(3) = '0' and SW(4) = '1') then  -- Sposta in basso
        Z_KEY          <= "1111111111111111";
        X_KEY          <= (others => '0');
        Y_KEY          <= (others => '0');
        DATA_READY_KEY <= '1';
      elsif(KEY(2) = '0' and FLAG = '1' and SW(3) = '1' and SW(4) = '0') then  -- Rimpicciolisce
        Y_KEY          <= "0000000000000001";
        X_KEY          <= (others => '0');
        Z_KEY          <= (others => '0');
        DATA_READY_KEY <= '1';
      elsif(KEY(2) = '0' and FLAG = '1' and SW(3) = '1' and SW(4) = '1') then  -- Allarga
        Y_KEY          <= "1111111111111111";
        X_KEY          <= (others => '0');
        Z_KEY          <= (others => '0');
        DATA_READY_KEY <= '1';
      elsif(FLAG = '0') then
        X_KEY          <= (others => '0');
        Y_KEY          <= (others => '0');
        Z_KEY          <= (others => '0');
        DATA_READY_KEY <= '0';
      end if;
      FLAG <= KEY(0) and KEY(1) and KEY(2) and KEY(3);
    end if;
  end process;
end behavioural;
