library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGA_DECODER_tb is

end VGA_DECODER_tb;


architecture behavioural of VGA_DECODER_tb is

  component VGA_DECODER
    generic (ROWS    : integer;
             COLUMNS : integer);
    port(ROW    : in  integer range 0 to 525;
         COLUMN : in  integer range 0 to 797;
         EN     : in  std_logic;
         -- I tre dati seguenti rappresentano lo spostamento del quadrato dalla posizione iniziale
         -- rispetto ai 3 assi.
         XPOS   : in  std_logic_vector(15 downto 0);  -- RANGE -315 to 315;
         YPOS   : in  std_logic_vector(15 downto 0);  -- RANGE -235 to 235;
         ZPOS   : in  std_logic_vector(15 downto 0);  -- RANGE 0 to 195;
         R      : out std_logic_vector(9 downto 0);
         G      : out std_logic_vector(9 downto 0);
         B      : out std_logic_vector(9 downto 0)
         );

  end component;

  constant H_S           : natural := 95;
  constant H_BACK_PORCH  : natural := 47;  -- Dalle specifiche dovrebbe essere 47.5
  constant H_VIDEO_OUT   : natural := 640;  -- Dalle specifiche dovrebbe essere 635
  constant H_FRONT_PORCH : natural := 15;
  constant H_BEGIN       : natural := H_S+H_BACK_PORCH;  -- Inizio schermo lungo asse x
  constant H_END         : natural := H_S+H_BACK_PORCH+H_VIDEO_OUT;  -- Fine schermo lungo asse x

  constant V_S           : natural := 2;
  constant V_BACK_PORCH  : natural := 33;
  constant V_VIDEO_OUT   : natural := 480;
  constant V_FRONT_PORCH : natural := 10;
  constant V_BEGIN       : natural := V_S+V_BACK_PORCH;  -- Inizio schermo lungo asse z
  constant V_END         : natural := V_S+V_BACK_PORCH+V_VIDEO_OUT;  -- Fine schermo lungo asse z

  signal CLOCK_25, SYS0, SYS1, SYS2, SYS3, HCHECK, VCHECK, TOTCHECK : std_logic                     := '0';
  signal ROW, COLUMN, CHECKX, CHECKY, CHECKZ                        : integer                       := 0;
  signal XPOS, YPOS, ZPOS                                           : std_logic_vector(15 downto 0) := (others => '0');

begin

  VGA_ctrl : VGA_DECODER generic map(ROWS => 797, COLUMNS => 525)
    port map(ROW => ROW, COLUMN => COLUMN, EN => '1', XPOS => XPOS, YPOS => YPOS, ZPOS => ZPOS);

  CHECKX <= TO_INTEGER(signed(XPOS));
  CHECKY <= TO_INTEGER(signed(YPOS));
  CHECKZ <= TO_INTEGER(signed(ZPOS));

  HCHECK   <= SYS0 and SYS1;
  VCHECK   <= SYS2 and SYS3;
  TOTCHECK <= HCHECK and VCHECK;

-- Clock a 25 MHz
  CLK : process
  begin
    CLOCK_25 <= '0';
    wait for 20 ns;
    CLOCK_25 <= '1';
    wait for 20 ns;
  end process;

-- POSIZIONE X
  POSX : process(CLOCK_25)
  begin
    if(FALLING_EDGE(CLOCK_25)) then
      if(COLUMN < 796) then
        COLUMN <= COLUMN+1;
      else
        COLUMN <= 0;
      end if;
    end if;
  end process;

-- POSIZIONE Y
  POSY : process(COLUMN, CLOCK_25)
  begin
    if(FALLING_EDGE(CLOCK_25)) then
      if(COLUMN = 796) then
        if(ROW < 524) then
          ROW <= ROW+1;
        else
          ROW <= 0;
        end if;
      end if;
    end if;
  end process;

-- Segnali
  XPOS <= "0000000000001111";
  YPOS <= "1111111111110111";
  ZPOS <= "0000000000000011";

-- SYSTEM CHECK
  process(COLUMN, ROW)
  begin
    if (COLUMN >= H_BEGIN+315+to_integer(signed(XPOS))+to_integer(signed(YPOS))) then
      SYS0 <= '1';
    else
      SYS0 <= '0';
    end if;

    if(COLUMN < H_END-315+to_integer(signed(XPOS))-to_integer(signed(YPOS))) then
      SYS1 <= '1';
    else
      SYS1 <= '0';
    end if;

    if(ROW >= V_BEGIN+235+to_integer(signed(ZPOS))+to_integer(signed(YPOS))) then
      SYS2 <= '1';
    else
      SYS2 <= '0';
    end if;

    if(ROW < V_END-235+to_integer(signed(ZPOS))-to_integer(signed(YPOS))) then
      SYS3 <= '1';
    else
      SYS3 <= '0';
    end if;

  end process;
end behavioural;
