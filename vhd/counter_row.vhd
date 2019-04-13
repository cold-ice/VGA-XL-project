library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity COUNTER_ROW is

  port(STROBE  : in  std_logic;
       EN      : in  std_logic;
       CL      : in  std_logic;
       COUNT_Y : out integer range 0 to 525
       );

end COUNTER_ROW;

architecture behavioural of COUNTER_ROW is

  signal COUNT_BUFFER : integer range 0 to 525 := 0;

begin

  COUNT_Y <= COUNT_BUFFER;

  Counter : process(STROBE, EN, CL)
  begin
    if(EN = '1') then
      if(FALLING_EDGE(STROBE)) then
        if(COUNT_BUFFER < 525-1) then
          COUNT_BUFFER <= COUNT_BUFFER+1;
        else
          COUNT_BUFFER <= 0;
        -- Giunti a 525 il contatore va resettato a 0 perche' e' trascorso esattamente
        -- il tempo totale di scansione dello schermo
        end if;
      end if;
    elsif(CL = '1') then
      COUNT_BUFFER <= 0;
    end if;
  end process;

end behavioural;
