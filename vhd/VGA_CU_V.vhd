library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CU_VGA_V is

  generic (ROWS : integer);
  port(CLOCK_50 : in  std_logic;
       RESET    : in  std_logic;
       ROW      : in  integer range 0 to 525;  -- Riga corrente
       VC_CL    : out std_logic;        -- Clear del contatore di riga
       RGB_CTRL : out std_logic;  -- Segnale di controllo per abilitare il componente VGA decoder
       VS_CTRL  : out std_logic         -- Segnale inviato a HSYNC
       );

end CU_VGA_V;

architecture behavioural of CU_VGA_V is

  constant V_S           : natural := 2;
  constant V_BACK_PORCH  : natural := 33;
  constant V_VIDEO_OUT   : natural := 480;
  constant V_FRONT_PORCH : natural := 10;
  constant V_BEGIN       : natural := V_S+V_BACK_PORCH;
  constant V_END         : natural := V_S+V_BACK_PORCH+V_FRONT_PORCH;

  type STATES is (RES, VSYNC, BACK_PORCH, VIDEO_ON, FRONT_PORCH);
  signal STATUS, NEXTSTATUS : STATES := VSYNC;

begin

  Status_update : process(CLOCK_50, RESET)
  begin
    if(RESET = '1') then
      STATUS <= RES;
    elsif(RISING_EDGE(CLOCK_50)) then
      STATUS <= NEXTSTATUS;
    end if;
  end process;

  Status_check : process(ROW, STATUS)
  begin

    RGB_CTRL <= '0';
    VC_CL    <= '0';

    VS_CTRL <= '1';
    case STATUS is

      when RES =>
        VC_CL      <= '1';
        VS_CTRL    <= '0';
        NEXTSTATUS <= VSYNC;

      when VSYNC =>
        VS_CTRL <= '0';
        if(ROW = V_S) then
          NEXTSTATUS <= BACK_PORCH;
        else
          NEXTSTATUS <= VSYNC;
        end if;

      when BACK_PORCH =>
        if(ROW = V_S+V_BACK_PORCH) then
          NEXTSTATUS <= VIDEO_ON;
        else
          NEXTSTATUS <= BACK_PORCH;
        end if;

      when VIDEO_ON =>
        RGB_CTRL <= '1';
        if(ROW = V_S+V_BACK_PORCH+V_VIDEO_OUT) then
          NEXTSTATUS <= FRONT_PORCH;
        else
          NEXTSTATUS <= VIDEO_ON;
        end if;

      when FRONT_PORCH =>
        if(ROW = 0) then
          NEXTSTATUS <= VSYNC;
        else
          NEXTSTATUS <= FRONT_PORCH;
        end if;

      when others =>
        VC_CL      <= '1';
        VS_CTRL    <= '0';
        NEXTSTATUS <= VSYNC;
    end case;
  end process;
end behavioural;
