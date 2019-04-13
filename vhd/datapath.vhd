library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DATAPATH is

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
       ROW            : out integer range 0 to 525;
       COLUMN         : out integer range 0 to 797;
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

end DATAPATH;

architecture behavioural of DATAPATH is

  component COUNTER_COLUMN
    port(STROBE  : in  std_logic;
         EN      : in  std_logic;
         CL      : in  std_logic;
         COUNT_X : out integer range 0 to 797
         );
  end component;

  component COUNTER_ROW
    port(STROBE  : in  std_logic;
         EN      : in  std_logic;
         CL      : in  std_logic;
         COUNT_Y : out integer range 0 to 525
         );
  end component;

  component STROBE_GEN
    generic (DIVIDER : integer);
    port(CLOCK_50 : in  std_logic;
         EN       : in  std_logic;
         STROBE   : out std_logic
         );
  end component;

  component VGA_DECODER
    generic (ROWS    : integer;
             COLUMNS : integer);
    port(ROW    : in  integer range 0 to 525;
         COLUMN : in  integer range 0 to 797;
         EN     : in  std_logic;
         XPOS   : in  std_logic_vector(15 downto 0);  -- RANGE -315 to 315;
         YPOS   : in  std_logic_vector(15 downto 0);  -- RANGE -235 to 235;
         ZPOS   : in  std_logic_vector(15 downto 0);  -- RANGE 0 to 195;
         R      : out std_logic_vector(9 downto 0);
         G      : out std_logic_vector(9 downto 0);
         B      : out std_logic_vector(9 downto 0)
         );
  end component;

  component REG_16bit
    port(DATA_IN  : in  std_logic_vector(15 downto 0);
         CLOCK_50 : in  std_logic;
         EN       : in  std_logic;
         CL       : in  std_logic;
         DATA_OUT : out std_logic_vector(15 downto 0)
         );
  end component;

  component ADDER
    port(DATA_IN0 : in  signed(15 downto 0);
         DATA_IN1 : in  signed(15 downto 0);
         C0       : in  std_logic;
         DATA_OUT : out signed(15 downto 0)
         );
  end component;

  signal STROBE_25                    : std_logic := '0';
  signal PIXEL_Y                      : integer;  -- RANGE 0 to 525;
  signal PIXEL_X                      : integer;  -- RANGE 0 to 797;
  signal X_RESULT, Y_RESULT, Z_RESULT : signed(15 downto 0);
  signal XPOS, YPOS, ZPOS             : std_logic_vector(15 downto 0);

begin

  VGA_CLK <= STROBE_25;
  VS      <= VS_CTRL;
  HS      <= HS_CTRL;
-- I segnali dei contatori vengono inviati alle unita' di controllo
  ROW     <= PIXEL_Y;
  COLUMN  <= PIXEL_X;

-- Genera uno strobe con frequenza 25 MHz partendo dal segnale di clock
  Strobe_25MHz : STROBE_GEN generic map(DIVIDER => 1)
    port map(CLOCK_50, STR_EN, STROBE_25);

-- Contatore di colonna
  col_count : COUNTER_COLUMN port map(STROBE_25, HC_EN, HC_CL, PIXEL_X);

-- Contatore di riga
  row_count : COUNTER_ROW port map(STROBE_25, VC_EN, VC_CL, PIXEL_Y);

-- Componente per gestire i segnali RGB a partire dalle coordinate correnti (PIXEL_X, PIXEL_Y)
-- e dallo spostamento dalla posizione iniziale (XPOS, YPOS, ZPOS, contenuti dentro 3 registri).
  VGA_SIGNALS : VGA_DECODER generic map(ROWS => ROWS, COLUMNS => COLUMNS)
    port map(PIXEL_Y, PIXEL_X, RGB_EN, XPOS, YPOS, ZPOS, R, G, B);

-- Sommatori usati per aggiornare i dati di posizione XPOS, YPOS, ZPOS con nuovi dati di spostamento.
  xadder : ADDER port map(signed(XPOS), X_UPDATE, '0', X_RESULT);
  yadder : ADDER port map(signed(YPOS), Y_UPDATE, '0', Y_RESULT);
  zadder : ADDER port map(signed(ZPOS), Z_UPDATE, '0', Z_RESULT);

-- Registri usati per conservare il dato di posizione. Il segnale di load e' alto per un solo colpo di clock,
-- cosicche' le posizioni vengano aggiornate una volta sola quando arrivano nuovi dati.
-- Tale segnale proviene dal componente di controllo RS232_BUFF_STRUCT, che lo asserisce quando ha acquisito le nuove
-- posizioni.
  xreg : REG_16bit port map(std_logic_vector(X_RESULT), CLOCK_50, data_out_ready, HC_CL, XPOS);
  yreg : REG_16bit port map(std_logic_vector(Y_RESULT), CLOCK_50, data_out_ready, HC_CL, YPOS);
  zreg : REG_16bit port map(std_logic_vector(Z_RESULT), CLOCK_50, data_out_ready, HC_CL, ZPOS);

-- Processo per saturare i valori di posizione in modo da evitare che il quadrato esca dallo schermo - progettazione
-- abbandonata per mancanza di tempo:

--SATURATORS
--PROCESS(X_RESULT_BUFFER, HC_CL)
--BEGIN
--IF(HC_CL='1') THEN
--      X_RESULT <= others =>'0';
--ELSIF(to_integer(X_RESULT_BUFFER)<-315+to_integer(SIGNED(ZPOS))) THEN
--      X_RESULT <= -315+to_integer(SIGNED(ZPOS));
--ELSIF(to_integer(X_RESULT_BUFFER)>315-to_integer(SIGNED(ZPOS))) THEN
--      X_RESULT <= "0000000011000011";
--ELSE
--      X_RESULT <= X_RESULT_BUFFER;
--END IF;
--END PROCESS;
--
--PROCESS(Y_RESULT_BUFFER, HC_CL)
--BEGIN
--IF(HC_CL='1') THEN
--      Y_RESULT <= others =>'0';
--ELSIF(to_integer(Y_RESULT_BUFFER)<0) THEN
--      Y_RESULT <= others =>'0';
--ELSIF(to_integer(Y_RESULT_BUFFER)>195) THEN
--      Y_RESULT <= "0000000011000011";
--ELSE
--      Y_RESULT <= Y_RESULT_BUFFER;
--END IF;
--END PROCESS;
--
--PROCESS(Z_RESULT_BUFFER, HC_CL)
--BEGIN
--IF(HC_CL='1') THEN
--      Z_RESULT <= others =>'0';
--ELSIF(to_integer(Z_RESULT_BUFFER)<0) THEN
--      Z_RESULT <= others =>'0';
--ELSIF(to_integer(Z_RESULT_BUFFER)>195) THEN
--      Z_RESULT <= "0000000011000011";
--ELSE
--      Z_RESULT <= Z_RESULT_BUFFER;
--END IF;
--END PROCESS;

end behavioural;
