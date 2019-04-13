library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity REG_16bit is

  port(DATA_IN  : in  std_logic_vector(15 downto 0);
       CLOCK_50 : in  std_logic;
       EN       : in  std_logic;
       CL       : in  std_logic;
       DATA_OUT : out std_logic_vector(15 downto 0)
       );

end REG_16bit;

architecture behavioural of REG_16bit is

begin

  reg : process(CLOCK_50, CL)
  begin
    if(CL = '1') then
      DATA_OUT <= (others => '0');
    elsif(RISING_EDGE(CLOCK_50)) then
      if(EN = '1') then
        DATA_OUT <= DATA_IN;
      end if;
    end if;
  end process;

end behavioural;
