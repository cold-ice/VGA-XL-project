library ieee;
use ieee.std_logic_1164.all;

entity d_reg is
  generic(N : integer);
  port (clk  : in  std_logic;
        rst  : in  std_logic;
        load : in  std_logic;
        d    : in  std_logic_vector(N-1 downto 0);
        q    : out std_logic_vector(N-1 downto 0)
        );
end entity d_reg;

architecture rtl of d_reg is

begin

  REG_PROC : process (clk, rst, load)
  begin
    if (rst = '0') then
      q <= (others => '0');
    elsif (clk'event and clk = '0') then
      if (load = '1') then
        q <= d;
      end if;
    end if;
  end process REG_PROC;

end architecture rtl;
