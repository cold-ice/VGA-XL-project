-- Buffer che prende in ingresso i caratteri che arrivano dalla seriale e salva ,
-- DOPO che sono arrivati sia x che y che z, solo i bit di dato in tre registri da 16 bit

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;

entity control_unit is
  port (
    clock          : in  std_logic;
    reset          : in  std_logic;
    tc_char        : in  std_logic;
    start_byte     : in  std_logic_vector(7 downto 0);
    stop_byte      : in  std_logic_vector(7 downto 0);
    --tc_cnt3    : in std_logic;
    --clear       : out std_logic;
    en_reg1        : out std_logic;
    en_reg2        : out std_logic;
    en_reg_buff0   : out std_logic;
    en_reg_buff1   : out std_logic;
    en_reg_buff2   : out std_logic;
    en_reg_buff3   : out std_logic;
    en_reg_buff4   : out std_logic;
    en_reg_buff5   : out std_logic;
    --en_cnt3    : out std_logic;
    en_out_regs    : out std_logic;
    data_out_ready : out std_logic
   --sel_demux      : out std_logic_vector(2 downto 0)
    );
end entity control_unit;

architecture struct of control_unit is

  type state is (idle, stato1, stato2, stato3, stato4, stato4a, stato5, stato6, stato7, stato8, stato9, stato10, stato11, stato12, stato13, stato14, stato15, stato16, stato17, stato18, stato19, stato20, stato21);
  signal current_state, next_state : state;

--signal sel_demux_aux : std_logic_vector(2 downto 0);
--type mem is array (0 to 5) of std_logic_vector(7 downto 0);

--signal data_xyz : mem;
--signal stato : integer := 0;
--signal index : integer := 0;
--signal temp : std_logic_vector(7 downto 0);

begin

--sel_demux <= sel_demux_aux;

  process(clock, reset)
  begin
    if (reset = '0') then
      current_state <= idle;
    elsif (clock'event and clock = '1') then
      current_state <= next_state;
    end if;
  end process;

  process(current_state, next_state, tc_char, start_byte, stop_byte)

  begin

    en_reg1      <= '0';
    en_reg2      <= '0';
    en_reg_buff0 <= '0';
    en_reg_buff1 <= '0';
    en_reg_buff2 <= '0';
    en_reg_buff3 <= '0';
    en_reg_buff4 <= '0';
    en_reg_buff5 <= '0';

    en_out_regs    <= '0';
    --sel_demux_aux <= "000";
-- clear <= '1';
    data_out_ready <= '0';

    case current_state is

      when idle =>
        en_reg1        <= '0';
        en_reg2        <= '0';
        en_reg_buff0   <= '0';
        en_reg_buff1   <= '0';
        en_reg_buff2   <= '0';
        en_reg_buff3   <= '0';
        en_reg_buff4   <= '0';
        en_reg_buff5   <= '0';
        en_out_regs    <= '0';
        -- sel_demux_aux <= "000";
        -- clear <= '0';
        data_out_ready <= '0';
        -- rst_cnt3 <= '0';

        if (tc_char = '1') then
          next_state <= stato1;
        else
          next_state <= idle;
        end if;

      when stato1 =>
        en_reg1    <= '1';
        next_state <= stato2;

--                      if(tc_char = '1')then
--                        next_state <= stato2;
--                      else

--                   next_state <= current_state;
--                      end if;


      when stato2 =>
        en_reg1 <= '0';
        if(tc_char = '1')then
          next_state <= stato3;
        else
          next_state <= current_state;
        end if;



      when stato3 =>
        en_reg2    <= '1';
        next_state <= stato4;

--                      if(start_byte = X"FF" )then
--                        next_state <= stato3;
--                      else
--                        next_state <= current_state;
--                      end if;
      when stato4 =>
        en_reg2 <= '0';
        if(start_byte = X"FF")then
          next_state <= stato4a;
        else
          next_state <= idle;           --next_state <= current_state;
        end if;


      when stato4a =>
        if(tc_char = '1')then
          next_state <= stato5;
        else
          next_state <= current_state;
        end if;


      when stato5 =>
        en_reg_buff0 <= '1';
        next_state   <= stato6;

      when stato6 =>
        en_reg_buff0 <= '0';
        if (tc_char = '1') then
          next_state <= stato7;
        else
          next_state <= current_state;
        end if;


      when stato7 =>
        en_reg_buff1 <= '1';
        next_state   <= stato8;

      when stato8 =>
        en_reg_buff1 <= '0';
        if (tc_char = '1') then
          next_state <= stato9;
        else
          next_state <= current_state;
        end if;
      when stato9 =>
        en_reg_buff2 <= '1';
        next_state   <= stato10;

      when stato10 =>
        en_reg_buff2 <= '0';
        if (tc_char = '1') then
          next_state <= stato11;
        else
          next_state <= current_state;
        end if;
      when stato11 =>
        en_reg_buff3 <= '1';
        next_state   <= stato12;

      when stato12 =>
        en_reg_buff3 <= '0';
        if (tc_char = '1') then
          next_state <= stato13;
        else
          next_state <= current_state;
        end if;
      when stato13 =>
        en_reg_buff4 <= '1';
        next_state   <= stato14;

      when stato14 =>
        en_reg_buff4 <= '0';
        if (tc_char = '1') then
          next_state <= stato15;
        else
          next_state <= current_state;
        end if;
      when stato15 =>
        en_reg_buff5 <= '1';
        next_state   <= stato16;

      when stato16 =>
        en_reg_buff5 <= '0';
        if (tc_char = '1') then
          next_state <= stato17;
        else
          next_state <= current_state;
        end if;


      when stato17 =>
        en_reg1    <= '1';
        next_state <= stato18;

--                      if(tc_char = '1')then
--                        next_state <= stato2;
--                      else

--                   next_state <= current_state;
--                      end if;


      when stato18 =>
        en_reg1 <= '0';
        if(tc_char = '1')then
          next_state <= stato19;
        else
          next_state <= current_state;
        end if;



      when stato19 =>
        en_reg2    <= '1';
        --if(tc_char = '1')then
        next_state <= stato20;

--                      if(start_byte = X"FF" )then
--                        next_state <= stato3;
--                      else
--                        next_state <= current_state;
--                      end if;
      when stato20 =>
        en_reg2 <= '0';
        if(stop_byte = X"FF")then
          next_state <= stato21;
        else
          next_state <= idle;
        end if;


--       when stato6 =>
--            en_reg1 <= '1';
--                      if(tc_char = '1')then
--                        next_state <= stato5;
--                      else
--                        next_state <= current_state;
--                       end if;
--
--       when stato5 =>
--            en_reg2 <= '1';
--                      if( stop_byte = X"FF") then
--                        next_state <= stato6;
--                      else
--                        next_state <= idle;
--                      end if;


      when stato21 =>
        en_out_regs    <= '1';
        data_out_ready <= '1';
        next_state     <= idle;


      when others =>
        next_state <= idle;


    end case;
  end process;






--PUSH_DATA_PROC : process (clock, reset, data_in_ready) --(reset, data_in_ready)
----variable index : integer;
--begin
--  if (reset = '0') then
--       index <= 0;
--       data_out_ready <= '0';
--       stato <= 0;
--  elsif (clock'event and clock = '0') then
--       case stato is
--         when 0 =>
--                if (data_in_ready = '1') then
--                  if (data_in_buff = "11111111") then
--                        stato <= stato + 1;
--                       else
--                        stato <= 0;
--                       end if;
--                else
--                  data_out_ready <= '0';
--                end if;
--              when 1 =>
--                if (data_in_ready = '1') then
--                  if (data_in_buff = "11111111") then
--                        stato <= stato + 1;                              -- stato <= stato + 1
--                       else
--                        stato <= 0;
--                       end if;
--                end if;
--              when 2 =>
--                if (data_in_ready = '1') then
--                  data_xyz(index) <= data_in_buff;
--                  if (index = 5) then
--                         --data_out_x <= data_xyz(0) & data_xyz(1); ---prima 8 MSB poi 8 LSB
--                    --data_out_y <= data_xyz(2) & data_xyz(3);
--                    --data_out_z <= data_xyz(4) & data_xyz(5);
--            stato <= stato + 1;
--            index <= 0;
--                  else
--                    index <= index + 1;       -- resto nello stato due finchÃ¨ index va a 6
--                  end if;
--                end if;
----              if (data_in_ready = '1') then
----                temp <= data_in_buff(8 downto 1); --data_xyz(index) <= data_in_buff(8 downto 1);
----                     index := index + 1;
----                     stato <= stato + 1;
----              end if;
--              when 3 =>
--                if (data_in_ready = '1') then
--                  if (data_in_buff = "00000000") then
--                        stato <= stato + 1;               -- stato <= stato + 1;
--                       else
--                        stato <= 0;
--                       end if;
--                end if;
--               when 4 =>
--                 if (data_in_ready = '1') then
--                  if (data_in_buff = "00000000") then
--                         data_out_x <= data_xyz(0) & data_xyz(1); ---prima 8 MSB poi 8 LSB
--                    data_out_y <= data_xyz(2) & data_xyz(3);
--                    data_out_z <= data_xyz(4) & data_xyz(5);
--                              data_out_ready <= '1';
----                      stato <= stato + 1;
----                     else
--                        stato <= 0;
--                        --it should be set an output valid signal here
--                       end if;
--                end if;
----            when 5 =>
----              data_xyz(index) <= temp;
----              if (index = 6) then
----                index := 0;
----                     stato <= 0;
----                     data_out_x <= data_xyz(0) & data_xyz(1); ---prima 8 MSB poi 8 LSB
----                data_out_y <= data_xyz(2) & data_xyz(3);
----                data_out_z <= data_xyz(4) & data_xyz(5);
----              else
----                index := index + 1;
----                     stato <= 0;
----              end if;
--              when others =>
--                null;
--              end case;
--  end if; -- reset
--end process PUSH_DATA_PROC;

end architecture struct;
