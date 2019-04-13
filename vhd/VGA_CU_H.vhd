library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CU_VGA_H is

  generic (COLUMNS : integer);
  port(CLOCK_50 : in  std_logic;
       RESET    : in  std_logic;
       COLUMN   : in  integer range 0 to 797;  -- Colonna corrente
       HC_EN    : out std_logic;        -- Enable del contatore orizzontale
       VC_EN    : out std_logic;        -- Enable del contatore verticale
       STR_EN   : out std_logic;  -- Enable del generatore di strobe a 25 MHz
       HC_CL    : out std_logic;        -- Clear del contatore orizzontale
       RGB_CTRL : out std_logic;  -- Segnale di controllo per abilitare il componente VGA decoder
       HS_CTRL  : out std_logic         -- Segnale inviato ad HSYNC
       );

end CU_VGA_H;

architecture behavioural of CU_VGA_H is

  constant H_S           : natural := 95;
  constant H_BACK_PORCH  : natural := 47;   --in teoria 47.5
  constant H_VIDEO_OUT   : natural := 640;  --in teoria 635
  constant H_FRONT_PORCH : natural := 15;
  constant H_BEGIN       : natural := H_S+H_BACK_PORCH;
  constant H_END         : natural := H_S+H_BACK_PORCH+H_VIDEO_OUT+H_FRONT_PORCH;

  type STATES is (RES, HSYNC, BACK_PORCH, VIDEO_ON, FRONT_PORCH, UPDATE_ROW);
  signal STATUS, NEXTSTATUS : STATES := HSYNC;

begin

  Status_update : process(CLOCK_50, RESET)
  begin
    if(RESET = '1') then
      STATUS <= RES;
    elsif(RISING_EDGE(CLOCK_50)) then
      STATUS <= NEXTSTATUS;
    end if;
  end process;

  Status_check : process(STATUS, COLUMN)
  begin
    HC_EN    <= '1';
    VC_EN    <= '0';
    STR_EN   <= '1';
    RGB_CTRL <= '0';

    HC_CL <= '0';

    HS_CTRL <= '1';
    case STATUS is

      when RES =>
        HC_EN      <= '0';
        HC_CL      <= '1';
        HS_CTRL    <= '0';
        STR_EN     <= '0';
        NEXTSTATUS <= HSYNC;

      when HSYNC =>
        HS_CTRL <= '0';
        if(column >= H_S) then
          NEXTSTATUS <= BACK_PORCH;
        else
          NEXTSTATUS <= HSYNC;
        end if;

      when BACK_PORCH =>
        if(column = H_S+H_BACK_PORCH) then
          NEXTSTATUS <= VIDEO_ON;
        else
          NEXTSTATUS <= BACK_PORCH;
        end if;

      when VIDEO_ON =>
        RGB_CTRL <= '1';
        if(column = H_S+H_BACK_PORCH+H_VIDEO_OUT) then
          NEXTSTATUS <= FRONT_PORCH;
        else
          NEXTSTATUS <= VIDEO_ON;
        end if;

      when FRONT_PORCH =>
        if(column = H_S+H_BACK_PORCH+H_VIDEO_OUT+H_FRONT_PORCH-1) then
          NEXTSTATUS <= UPDATE_ROW;
        else
          NEXTSTATUS <= FRONT_PORCH;
        end if;

      when UPDATE_ROW =>
        VC_EN <= '1';
        if(column = 0) then
          NEXTSTATUS <= HSYNC;
        else
          NEXTSTATUS <= UPDATE_ROW;
        end if;

      when others =>
        HC_EN      <= '0';
        HC_CL      <= '1';
        STR_EN     <= '0';
        HS_CTRL    <= '0';
        NEXTSTATUS <= HSYNC;
    end case;
  end process;
end behavioural;
